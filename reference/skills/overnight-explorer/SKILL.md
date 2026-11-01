---
name: overnight-explorer
description: Autonomous deep exploration of metagenomic/omics samples (novel microbes, viruses, CRISPR, enzymes, BGCs) with literature-verified findings, methods report, and impact ranking. Trigger: "explore this sample", "find anything interesting", user goes to sleep mid-analysis.
---

# Overnight Explorer — autonomous discovery protocol

Goal: take one sample folder, run everything interesting while the user sleeps, and deliver
two files IN THE SAMPLE ROOT: `FINDINGS_REPORT.md` and `ANALYSIS_METHODS.md`.
Never ask questions while the user is away; decide, document, keep going.

## Iron rules (every finding survives all three)
1. **Two independent evidence lines** minimum (e.g., 16S + protein annotation; HMM + diamond; read-level + contig-level). One line = "candidate", not a finding.
2. **Cross-check against literature/DBs online** (websearch/WebFetch: genus ecology, known novelty, the tool's own manual) OR state plainly why not checked.
3. **Alignment evidence is the referee.** classifier calls (kraken/bracken) are leads only. A contig that looks like X but has no X marker gene (16S/rRNA/structural) is not X. Record refuted hypotheses as negative results — they are findings too.
4. Never infer "host species" from what the user used for host-depletion; depletion reference ≠ host. Report mapping identity + coverage + caveats.
5. Tool vocabulary traps: CheckV `checkv_quality` = genome-bin completeness, NOT virus-ness (use viral_genes vs host_genes). VirSorter2 NCLDV silence = weak training set, not refutation.

## Standard pipeline (skip what the data doesn't support; keep going)
- **Assembly census**: blastn all contigs vs NCBI 16S/18S/28S/ITS targeted-loci DB (`~/Documents/database/ncbi_16s_18s_28s_ITS.fna`, megablast, e<1e-100). %ID bands: ≥98.5 known sp / 95–97 novel sp / <95 novel genus–family. Join with assembly_info coverage for "who is abundant".
- **Virome cascade**: minimap2 `-cx asm20` contigs→RefSeq viral genomes (known viruses, usually 0 hits) → diamond blastx contigs→viral proteins (region-density per contig; this diamond needs `--query`, watch max-hsps=1 default!) → **CheckV end_to_end** (fix missing .dmnd via diamond makedb) → **VirSorter2 all-mode on candidates** (install gotchas: pkg `virsorter`, snakemake≤5.26, `-j` not `-p`, precreate conda env, numpy=1.23.5, `--conda-frontend conda`) → targeted rescue: hmmsearch viral combined.hmm + Swiss-Prot names.
- **Function**: dbCAN5 CAZyme census (`--methods diamond,hmm --e_value_threshold`, diamond on PATH); antiSMASH 8 BGCs on the most novel high-coverage genomes (`--genefinding-tool prodigal --databases ~/Documents/database/antismash`, needs hmmer/diamond/prodigal in env); diamond blastp everything interesting vs Swiss-Prot (`sprot.dmnd`, ~90MB — the workhorse annotator).
- **CRISPR/Cas**: minced (`-sp` may be missing in build — parse main output manually) on top genomes; find cas genes via Swiss-Prot (`CRISPR-associated endonuclease Cas9`); **pair spacers vs the sample's own phage contigs** (blastn word_size 9) → direct phage–host network. Novel Cas9 = flag as S-tier (gene-editing IP value).
- **Host/origin**: identity histogram of host-depletion BAM (median ≈ ONT error → same species; 80–90% → relative), check pileup concentration (collapsed rDNA inflates counts), eukaryotic 18S/28S contigs, and marker-organism ecology (insect-gut genera, rumen taxa, hospital taxa = provenance clues). Report origin as inference with confidence.
- **Biotech/health lens** on every annotation table: polymerases, recombinases/integrases, Cas, proteases, glycosylases, lytic enzymes (endolysins), cellulosome/thermostable enzymes, toxins/VFs, antibiotic-resistance/efflux, antimicrobial BGCs (lanthipeptides/ranthipeptides).

## FINDINGS_REPORT.md format
Per finding: Name & contig IDs → Evidence chain (commands/numbers) → Literature check (what's known; what makes it novel) → **Significance rating**:
S = publishable / real-world impact / IP potential (novel Cas, new antibiotic class candidate, giant virus)
A = solid notable (novel genus genome in good completeness, host-phage pairing, PUL-rich unusual host)
B = sample-QC / housekeeping (contamination calls, DB advice)
Include a "retracted/refuted" section and a "not yet run" section. No unsupported adjectives.

## ANALYSIS_METHODS.md format
Reproducible protocol: envs (exact conda env + binary quirks), DB paths (all under ~/Documents/database — never datadrive paths), exact commands in order, thresholds, gotchas hit, output paths. A human must be able to rerun cold.

## House DB/tool facts
DBs: `~/Documents/database/` (k2_core_nt, PlusPFP notes, refseq_viral_<date>, checkv-db-v1.5, virsorter2-db, dbcan, antismash, ncbi_16s_18s_28s_ITS.fna).
Env gotchas (miniforge): diamond flag names differ per build (`--query` in dbcan blastx, `--in` in dbcan blastp); mawk has no `and()`; CheckV needs its env bin on PATH; kraken2_confidence≥0.2 for readable output; Flye meta drops collapsed rRNA — "no 16S" on a big contig ≠ non-cellular.
Budget: 16 cores; keep ≤12 busy; RAM ~20 GB for tools (Strata owns the rest); background long jobs and continue independent work; never poll job completion.
