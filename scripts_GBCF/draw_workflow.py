#!/usr/bin/env python3
"""Generate a ddRAD-seq bioinformatics workflow diagram."""

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, ax = plt.subplots(figsize=(10, 16))
ax.set_xlim(0, 10)
ax.set_ylim(0, 20)
ax.axis("off")

# Color scheme by category
colors = {
    "input":   ("#e3f2fd", "#1565c0"),
    "preproc": ("#fff3e0", "#e65100"),
    "qc":      ("#e8f5e9", "#2e7d32"),
    "align":   ("#fce4ec", "#c62828"),
    "variant": ("#f3e5f5", "#6a1b9a"),
    "result":  ("#e0f2f1", "#00695c"),
}

box_w, box_h = 6.0, 0.95
cx = 5.0  # center x

steps = [
    ("Raw FASTQ\nIllumina PE reads · 3 pools (UDP22/24/87)", "input"),
    ("Spacer Removal\ncutadapt", "preproc"),
    ("Demultiplexing\nprocess_radtags (Stacks) · EcoRI / MseI", "preproc"),
    ("Pre-trim QC\nFastQC + MultiQC", "qc"),
    ("Read Trimming\nfastp · adapter & quality filtering", "preproc"),
    ("Post-trim QC\nFastQC + MultiQC", "qc"),
    ("Alignment\nBWA-MEM → samtools sort\nRef: M. edulis GCF_963676685.1", "align"),
    ("Read Clipping & Merge\nGATK ClipReads → samtools merge", "align"),
    ("Variant Calling\nbcftools mpileup + call\n96 samples · ~23.5 M records", "variant"),
    ("VCF Filtering · VCFtools\nBiallelic SNPs · DP≥3 · GQ≥10\nMAF≥0.01 · max-missing≤0.5", "variant"),
    ("Sample QC\nRemove >95% & >80% missing\n84 samples · 158,603 SNPs", "variant"),
]

# Draw main pipeline boxes
y_positions = []
y = 18.5
for label, cat in steps:
    n_lines = label.count("\n") + 1
    h = box_h if n_lines <= 2 else box_h + 0.3
    fc, ec = colors[cat]
    rect = mpatches.FancyBboxPatch(
        (cx - box_w / 2, y - h / 2), box_w, h,
        boxstyle="round,pad=0.12", facecolor=fc, edgecolor=ec, linewidth=1.5
    )
    ax.add_patch(rect)
    ax.text(cx, y, label, ha="center", va="center", fontsize=8,
            fontweight="bold" if cat == "input" else "normal",
            linespacing=1.3)
    y_positions.append(y)
    y -= h + 0.4

# Draw arrows between pipeline boxes
for i in range(len(y_positions) - 1):
    n_lines_cur = steps[i][0].count("\n") + 1
    h_cur = box_h if n_lines_cur <= 2 else box_h + 0.3
    n_lines_nxt = steps[i + 1][0].count("\n") + 1
    h_nxt = box_h if n_lines_nxt <= 2 else box_h + 0.3
    y1 = y_positions[i] - h_cur / 2
    y2 = y_positions[i + 1] + h_nxt / 2
    ax.annotate("", xy=(cx, y2), xytext=(cx, y1),
                arrowprops=dict(arrowstyle="-|>", color="#555", lw=1.5))

# Draw downstream analysis fan-out
downstream = [
    ("PCA\nSNPRelate", "result"),
    ("Structure\nfastSTRUCTURE\nK=1–15", "result"),
    ("Hybrid Index\ntriangulaR", "result"),
    ("FST & Pop Stats\nStacks populations", "result"),
    ("Nucleotide\nDiversity · pixy", "result"),
]

fan_y = y - 0.3
hub_y = y_positions[-1]
n_lines_last = steps[-1][0].count("\n") + 1
h_last = box_h if n_lines_last <= 2 else box_h + 0.3

xs = [1.0, 2.8, 5.0, 7.2, 9.0]
dw, dh = 1.6, 1.1

for (label, cat), bx in zip(downstream, xs):
    fc, ec = colors[cat]
    rect = mpatches.FancyBboxPatch(
        (bx - dw / 2, fan_y - dh), dw, dh,
        boxstyle="round,pad=0.1", facecolor=fc, edgecolor=ec, linewidth=1.3
    )
    ax.add_patch(rect)
    ax.text(bx, fan_y - dh / 2, label, ha="center", va="center", fontsize=6.5,
            linespacing=1.2)
    # Arrow from last pipeline box to each downstream box
    ax.annotate("", xy=(bx, fan_y), xytext=(cx, hub_y - h_last / 2),
                arrowprops=dict(arrowstyle="-|>", color="#555", lw=1.0,
                                connectionstyle="arc3,rad=0"))

# Legend
legend_items = [
    ("Input", colors["input"]),
    ("Preprocessing", colors["preproc"]),
    ("Quality Control", colors["qc"]),
    ("Alignment", colors["align"]),
    ("Variant Processing", colors["variant"]),
    ("Population Genomics", colors["result"]),
]
for i, (lbl, (fc, ec)) in enumerate(legend_items):
    lx = 0.3
    ly = 19.7 - i * 0.35
    rect = mpatches.FancyBboxPatch((lx, ly - 0.12), 0.25, 0.25,
                                    boxstyle="round,pad=0.03",
                                    facecolor=fc, edgecolor=ec, linewidth=1)
    ax.add_patch(rect)
    ax.text(lx + 0.4, ly, lbl, va="center", fontsize=7)

ax.set_title("ddRAD-seq Bioinformatics Workflow", fontsize=14, fontweight="bold", pad=15)
fig.tight_layout()
fig.savefig("results/downstream_plots/workflow_diagram.png", dpi=200, bbox_inches="tight",
            facecolor="white")
print("Saved: results/downstream_plots/workflow_diagram.png")
