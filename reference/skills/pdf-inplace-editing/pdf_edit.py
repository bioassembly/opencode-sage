#!/usr/bin/env python3
"""In-place PDF editing with zero layout drift.

Subcommands:
  scan      dump text spans (page, bbox, size, font, text) or the image list
  swap      byte-replace strings in page content streams (text layer only)
  reletter  whiteout + re-type text baked into raster images (plot titles etc.)
  verify    pixel-diff two PDFs per page + residual identifier scan

Deps: pymupdf, numpy, PIL; tesseract for reletter auto-detection.
Assumes ASCII strings in the target PDF text.
"""
import argparse
import os
import signal
import subprocess
import tempfile
from collections import Counter, deque

try:
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)  # clean exit when piped to head
except AttributeError:
    pass

import numpy as np
import pymupdf
from PIL import Image


def pdf_escape(s):
    return s.replace("\\", r"\\").replace("(", r"\(").replace(")", r"\)")


# ---------------- scan ----------------

def cmd_scan(a):
    doc = pymupdf.open(a.pdf)
    if a.images:
        for pno in range(len(doc)):
            for im in doc[pno].get_image_info(xrefs=True):
                bb = im["bbox"]
                print(f"p{pno+1:02d} xref={im['xref']} "
                      f"bbox=({bb[0]:.0f},{bb[1]:.0f},{bb[2]:.0f},{bb[3]:.0f}) "
                      f"px={im['width']}x{im['height']}")
        return 0
    for pno in range(len(doc)):
        d = doc[pno].get_text("dict")
        for b in d["blocks"]:
            if b.get("type") != 0:
                continue
            for l in b["lines"]:
                for s in l["spans"]:
                    x0, y0, x1, y1 = (round(v, 1) for v in s["bbox"])
                    t = s["text"].rstrip()
                    if not t:
                        continue
                    print(f"p{pno+1:02d} [{x0:7.1f},{y0:6.1f},{x1:7.1f},{y1:6.1f}] "
                          f"sz={s['size']:5.1f} {s['font'][:18]:18s} | {t}")
    return 0


# ---------------- swap ----------------

def load_pairs(path):
    pairs = []
    for line in open(path):
        line = line.rstrip("\n")
        if not line or line.startswith("#"):
            continue
        old, new = line.split("\t", 1)
        pairs.append((old, new))
    # longest first so specific strings win over their substrings
    pairs.sort(key=lambda p: len(p[0]), reverse=True)
    return pairs


def iso_to_pdfdate(iso):
    # 2026-08-22T01:18:47Z -> D:20260822011847+00'00'
    core = iso.replace("T", "").replace("Z", "")[:15]
    return f"D:{core[:8]}{core[8:10]}{core[10:12]}{core[12:14]}+00'00'"


def cmd_swap(a):
    pairs = load_pairs(a.pairs)
    doc = pymupdf.open(a.pdf)
    cxs = set()
    for p in doc:
        cxs.update(p.get_contents())
    hits = {old: 0 for old, _ in pairs}
    for xref in sorted(cxs):
        try:
            data = doc.xref_stream(xref)
        except Exception:
            continue
        if not isinstance(data, (bytes, bytearray)):
            continue
        buf = bytes(data)
        for old, new in pairs:
            repl = pdf_escape(new).encode()
            forms = {old.encode(), pdf_escape(old).encode()}
            for form in forms:
                if form in buf:
                    hits[old] += buf.count(form)
                    buf = buf.replace(form, repl)
        if buf != bytes(data):
            doc.update_stream(xref, buf)
    bad = False
    for old, new in pairs:
        ok = hits[old] > 0
        bad |= not ok
        print(f"{'OK  ' if ok else 'MISS'} {hits[old]:3d}x  {old!r} -> {new!r}")
    if a.meta_date:
        md = doc.metadata or {}
        d = iso_to_pdfdate(a.meta_date)
        md["creationDate"] = d
        md["modDate"] = d
        doc.set_metadata(md)
    doc.save(a.out, garbage=3, deflate=True)
    print(f"saved {a.out}")
    return 1 if bad else 0


# ---------------- reletter ----------------

def img_gray(doc, xref):
    pix = pymupdf.Pixmap(doc, xref)
    if pix.n - pix.alpha != 1:
        pix = pymupdf.Pixmap(pymupdf.csGRAY, pix)
    arr = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.stride)
    return np.ascontiguousarray(arr[:, :pix.width])


def find_id_left(g, old_id, strip=60):
    """Locate left edge (px) of old_id in the top strip via tesseract word boxes."""
    h = min(strip, g.shape[0])
    crop = Image.fromarray(g[:h]).resize((g.shape[1] * 3, h * 3), Image.LANCZOS)
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
        crop.save(f.name)
        tmp = f.name
    try:
        r = subprocess.run(
            ["tesseract", tmp, "stdout", "--psm", "11", "tsv"],
            capture_output=True, text=True, timeout=120)
    finally:
        os.unlink(tmp)
    keys = {old_id.lower(), old_id[:12].lower(), old_id[-8:].lower()}
    best = None
    for line in r.stdout.splitlines()[1:]:
        c = line.split("\t")
        if len(c) < 12 or c[0] != "5":
            continue
        try:
            x, conf = int(c[6]), float(c[10])
        except ValueError:
            continue
        w = c[11].strip().lower()
        if not w or conf < 30:
            continue
        hit = any(k in w or w in k for k in keys if len(k) >= 6)
        if hit and (best is None or x < best):
            best = x
    return None if best is None else max(0, best // 3 - 3)


def measure_zone(g, L, strip=80):
    """Ink rows of the title line in column window [L, W).
    Returns (top, zend, base) or None. Stops at first >=4-row empty gap so plot
    frame lines below the title are never included."""
    H, W = g.shape
    dark = (g[:, L:W] < 128).sum(axis=1)
    top = next((r for r in range(min(H, strip)) if dark[r] >= 3), None)
    if top is None:
        return None
    zend, gap = top, 0
    for r in range(top + 1, min(H, strip)):
        if dark[r] >= 3:
            zend, gap = r, 0
        else:
            gap += 1
            if gap >= 4:
                break
    bottoms = []
    for c in range(L, W):
        col = np.where(g[top:zend + 1, c] < 128)[0]
        if len(col):
            bottoms.append(top + int(col[-1]))
    if not bottoms:
        return None
    base = Counter(bottoms).most_common(1)[0][0]  # underscores lose the vote
    return top, zend, base


def cmd_reletter(a):
    doc = pymupdf.open(a.pdf)
    lefts = {}
    if a.left:
        for part in a.left.split(","):
            pno, lpx = part.split(":")
            lefts[int(pno)] = int(lpx)
    done, skipped = [], []
    pages = range(len(doc)) if a.pages is None else \
        [p - 1 for p in a.pages]
    for pno in pages:
        page = doc[pno]
        for im in page.get_image_info(xrefs=True):
            w_px, h_px = im["width"], im["height"]
            if h_px < a.min_h:
                continue
            xref = im["xref"]
            g = img_gray(doc, xref)
            L = lefts.get(pno + 1)
            how = "manual"
            if L is None:
                L = find_id_left(g, a.old)
                how = "ocr"
            if L is None:
                skipped.append(f"p{pno+1} xref={xref}: id not found (pass --left {pno+1}:{Lpx_hint(g, a.old)})")
                continue
            m = measure_zone(g, L)
            if m is None:
                skipped.append(f"p{pno+1} xref={xref}: no ink zone at L={L}")
                continue
            top, zend, base = m
            rect = pymupdf.Rect(im["bbox"])
            sx, sy = rect.width / w_px, rect.height / h_px
            cap = base - top + 1
            fs = max(8.0, min(20.0, cap * sy / 0.717))  # 0.717 ~ helv cap ratio
            page.draw_rect(pymupdf.Rect(rect.x0 + (L - 2) * sx, rect.y0 + (top - 2) * sy,
                                        rect.x0 + w_px * sx, rect.y0 + (zend + 2) * sy),
                           color=None, fill=(1, 1, 1), width=0)
            page.insert_text((rect.x0 + L * sx, rect.y0 + (base + 1) * sy),
                             a.new, fontsize=fs, fontname="helv", color=(0, 0, 0))
            done.append(f"p{pno+1} xref={xref} [{how}] zone=({top},{zend}) "
                        f"base={base} cap={cap}px fs={fs:.1f} L={L}")
    doc.save(a.out, garbage=3, deflate=True)
    for d in done:
        print("DONE  " + d)
    for s in skipped:
        print("SKIP  " + s)
    print(f"saved {a.out} ({len(done)} relettered, {len(skipped)} skipped)")
    return 0 if not skipped else 1


def Lpx_hint(g, old_id):
    """Crude fallback hint: rightmost dark column of the top strip."""
    h = min(60, g.shape[0])
    cols = (g[:h] < 128).sum(axis=0)
    nz = np.nonzero(cols)[0]
    return int(nz[-1]) if len(nz) else "?"


# ---------------- verify ----------------

def render_gray(path, dpi):
    doc = pymupdf.open(path)
    Z = dpi / 72
    out = []
    for p in doc:
        pm = p.get_pixmap(matrix=pymupdf.Matrix(Z, Z),
                          colorspace=pymupdf.csGRAY, alpha=False)
        out.append(np.frombuffer(pm.samples, np.uint8).reshape(pm.height, pm.width))
    return out


def components(mask):
    """8-connected components -> list of (r0,c0,r1,c1,npix)."""
    ys, xs = np.nonzero(mask)
    pts = set(zip(ys.tolist(), xs.tolist()))
    seen = set()
    comps = []
    for pt in pts:
        if pt in seen:
            continue
        q = deque([pt])
        seen.add(pt)
        r0 = r1 = pt[0]
        c0 = c1 = pt[1]
        n = 0
        while q:
            y, x = q.popleft()
            n += 1
            r0 = min(r0, y)
            r1 = max(r1, y)
            c0 = min(c0, x)
            c1 = max(c1, x)
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    if dy == 0 and dx == 0:
                        continue
                    nb = (y + dy, x + dx)
                    if nb in pts and nb not in seen:
                        seen.add(nb)
                        q.append(nb)
        comps.append((r0, c0, r1, c1, n))
    return comps


def cmd_verify(a):
    orig = render_gray(a.orig, a.dpi)
    new = render_gray(a.new, a.dpi)
    if len(orig) != len(new):
        print(f"FAIL page count {len(orig)} != {len(new)}")
        return 1
    total = 0
    for i, (o, n) in enumerate(zip(orig, new)):
        if o.shape != n.shape:
            print(f"p{i+1:02d} FAIL size mismatch {o.shape} vs {n.shape}")
            continue
        mask = o != n
        if not mask.any():
            continue
        comps = sorted(components(mask), key=lambda c: (c[0], c[1]))
        total += len(comps)
        print(f"p{i+1:02d} {len(comps)} changed region(s):")
        for r0, c0, r1, c1, npix in comps:
            flag = "  <-- LARGE" if npix > 2000 else ""
            print(f"    X[{c0}-{c1}] Y[{r0}-{r1}] {npix}px{flag}")
    print(f"total changed regions: {total}")
    if a.scan:
        doc = pymupdf.open(a.new)
        text = "".join(p.get_text("text") for p in doc)
        resid = False
        for sid in [s.strip() for s in a.scan.split(",") if s.strip()]:
            n = text.count(sid)
            resid |= n > 0
            print(f"residual {sid!r}: {n} hit(s)")
        print("RESIDUAL SCAN: " + ("FAIL" if resid else "clean (0 hits)"))
        return 1 if resid else 0
    return 0


# ---------------- main ----------------

def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("scan")
    p.add_argument("pdf")
    p.add_argument("--images", action="store_true", help="list raster images instead of text spans")
    p.set_defaults(fn=cmd_scan)

    p = sub.add_parser("swap")
    p.add_argument("pdf")
    p.add_argument("out")
    p.add_argument("--pairs", required=True, help="file with old<TAB>new per line")
    p.add_argument("--meta-date", help="ISO datetime for /CreationDate + /ModDate")
    p.set_defaults(fn=cmd_swap)

    p = sub.add_parser("reletter")
    p.add_argument("pdf")
    p.add_argument("out")
    p.add_argument("--old", required=True, help="identifier string baked into the image")
    p.add_argument("--new", required=True, help="replacement label to type over it")
    p.add_argument("--min-h", type=int, default=150, help="skip images shorter than this (px)")
    p.add_argument("--left", help="manual page:left_px overrides, e.g. '5:652,9:668'")
    p.add_argument("--pages", type=int, nargs="*", help="page numbers to process (default all)")
    p.set_defaults(fn=cmd_reletter)

    p = sub.add_parser("verify")
    p.add_argument("orig")
    p.add_argument("new")
    p.add_argument("--dpi", type=int, default=150)
    p.add_argument("--scan", help="comma-separated old identifiers; expect 0 hits in new")
    p.set_defaults(fn=cmd_verify)

    a = ap.parse_args()
    raise SystemExit(a.fn(a))


if __name__ == "__main__":
    main()
