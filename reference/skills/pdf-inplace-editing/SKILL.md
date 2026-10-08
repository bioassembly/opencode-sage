---
name: pdf-inplace-editing
description: In-place PDF editing/anonymization, zero layout drift — content-stream swaps, raster re-lettering, pixel-diff verified.
---

# In-Place PDF Editing (Zero Layout Drift)

## What I do
- Surgically edit text inside existing PDFs — anonymize run/sample IDs, fix values, swap labels — with no reflow, font, or layout change.
- Re-letter identifying text baked into raster images (plot titles, headers inside PNGs).
- Verify every edit: pixel-diff against the original + residual identifier scan before delivery.

## Golden rules
1. Never use redact/insert_text for text-layer edits — redaction erases and re-typesets → font/size/kerning drift. Swap bytes in the content stream instead.
2. Always back up the original first (`cp ORIG /tmp/opencode/<name>.orig.pdf`). Never work without a pristine copy.
3. `scan` before editing: dump spans (bbox, size, font) and image list to build the edit list. PDFs escape parens as `\(` `\)`.
4. Replace longest/most specific strings first (full paths before fragments); every pair must report hits > 0 (script exits non-zero on MISS).
5. Shorter replacement text is safe under absolute Tm positioning (line just ends earlier). Longer text can overlap neighbors — check span width from scan output first.
6. Raster re-lettering: font size comes from measured cap height (`fs = cap_px * sy / 0.717`), never from OCR box height; the whiteout box must stay inside the measured text line.
7. Verify before delivery, always: every changed pixel region must map to an intended edit; residual scan must return 0 hits.

## Workflow
```bash
S=~/.config/opencode/skills/pdf-inplace-editing/pdf_edit.py
cp ORIG.pdf /tmp/opencode/name.orig.pdf          # pristine backup
python3 $S scan ORIG.pdf                          # text spans: page, bbox, size, font
python3 $S scan ORIG.pdf --images                 # raster images: bbox + pixel size + xref
# write pairs file: old<TAB>new per line (# comments ok)
python3 $S swap ORIG.pdf OUT.pdf --pairs edits.tsv [--meta-date 2026-08-22T01:18:47Z]
python3 $S reletter OUT.pdf OUT2.pdf --old m84182_... --new demo_run2   # tesseract auto-locates ID
# if OCR misses a page that really has the ID: --left "6:734" (page:left_px)
python3 $S verify ORIG.pdf OUT2.pdf --scan m84182,RSCM,bc2159           # pixel diff + residual scan
```

## Pitfalls (learned the hard way)
- Tesseract boxes are sloppy (±3 px, wrong height) — use only to locate; measure ink pixels for geometry.
- Ink row profile must stop at first ≥4-row empty gap; a too-tall window catches plot frame lines → wrong baseline + whiteout erases the frame.
- Underscored text: baseline = mode of per-column ink bottoms (underscores lose the vote).
- Flood-fill bbox: track rows (r0/r1) and cols (c0/c1) separately — swapping x/y silently corrupts the diff report.
- Pages may be landscape; don't assume header position — take it from scan bboxes.
- Pixmap stride has padding — slice `[:width]` per row before numpy ops; convert CMYK/RGB pixmaps to gray first.
- A SKIP from reletter is often correct (image genuinely lacks the ID) — confirm against ground truth before forcing --left.

## Verification protocol
- Pixel diff at 150 dpi: changed components listed per page (X/Y ranges in px). Cross-check each against the edit list; any component outside an intended span, or a LARGE (>2000 px) one → stop and fix.
- Residual scan: search text layer for every old identifier → expect 0 hits.
- Human review (optional): render both PDFs to PNGs (pymupdf, ~100 dpi), build a side-by-side CSS-grid HTML in /tmp/opencode/, open in browser.

## Files
- `pdf_edit.py` — scan / swap / reletter / verify subcommands (pymupdf, numpy, PIL, tesseract). Tested on 27-page PacBio Revio run reports: byte-swap round-trip = 1 glyph diff; reletter = changes confined to title zones only.
