---
name: scientific-figures
description: Use when designing, drafting, reviewing, or critiquing any scientific or technical figure — matplotlib, seaborn, ggplot2, or any other tool. Covers chart-type selection by message, color (categorical / sequential / diverging + colorblind-safety), uncertainty representation, faceting, direct annotation, and per-project style conventions. Use proactively when the user asks to make, fix, polish, or evaluate any plot or figure for a paper, poster, slide deck, or analysis — even quick exploratory plots. Also use when the user pastes or links a figure and asks for feedback. Teaches judgment with cited evidence (Cleveland & McGill, Wong, Wilke, Correll & Gleicher, Tufte) and named exemplars (Tabula Muris UMAP pattern, AlphaFold PAE, Manhattan plot, slopegraph, climate stripes, Anscombe's quartet). Does NOT prescribe a fixed template — every project has its own palette and the skill defers to per-project style when declared.
---

# Scientific Figures

This skill teaches judgment for designing figures that argue clearly. It is **not** a template. Every project can have its own palette and house style; the principles below apply regardless.

The skill operates in one of three modes:

1. **Making a new figure** — start with §1 (Identify the message), then §2 (Pick the chart), then §3 (Color & uncertainty), then §6 (Per-project style).
2. **Critiquing an existing figure** — jump to §5 (Critique mode).
3. **Polishing a draft** — work through §4 (Common mistakes) as a checklist.

Every recommendation here is backed by perceptual research or by widely-praised exemplars. Where the literature disagrees, the disagreement is surfaced rather than papered over — see `references/principles.md` for citations.

## 1. Identify the message before you design

A scientific figure exists to make **one claim**. Before opening a plotting library, finish this sentence: *"This figure shows that ___."* If you can't, the figure isn't ready to design.

The FT *Visual Vocabulary* groups all charts under nine message categories — pick yours:

| Message | Examples |
|---|---|
| **Deviation** | from a baseline, control, chance, expected value |
| **Correlation** | one variable against another |
| **Ranking** | who is highest / lowest |
| **Distribution** | shape of values in one group |
| **Change over time** | trajectory, growth, decay |
| **Magnitude** | absolute size comparison across categories |
| **Part-to-whole** | composition of a total |
| **Flow** | transitions, transfers, pipelines |
| **Spatial** | geographic, anatomic, network layout |

The message determines the chart type, not the column types of the dataframe. Reach for a bar chart because you want to compare magnitudes, not because the data is "categorical."

> A figure that shows ten things and asserts none is not ready. Split it.

## 2. Match the encoding to the perceptual task

Cleveland & McGill (1984) ranked how accurately humans decode visual channels for magnitude comparison. The ranking, most-accurate first:

1. Position on a common scale
2. Position on identical, non-aligned scales (small multiples)
3. Length (bars from a common baseline)
4. Angle / slope
5. Area
6. Volume, curvature
7. Color saturation / luminance
8. Color hue

**Rule of thumb (Munzner): the importance of the variable should match the salience of the channel.** Put the variable you most want compared in position. Use length next. Use color as a magnitude encoding only as a last resort — color is excellent for *identity*, weak for *quantity*.

This is why a heatmap encoding model accuracy is worse than a dot plot of the same data, and why a bar chart of values is almost always better than a pie chart.

## 3. Color: scale type first, palette second

Three flavors. Picking the wrong one invents structure that isn't in the data.

- **Qualitative / categorical** — unordered groups. Keep to ≤8 levels (Okabe-Ito's eight are designed for the limit). Defaults: Okabe-Ito (Wong 2011), ColorBrewer Set2/Dark2, Tol's Bright/Muted.
- **Sequential** — ordered or quantitative. Monotonic in luminance. Defaults: viridis, cividis, magma.
- **Diverging** — values around a meaningful midpoint (zero, chance, log-fold-change of 1). Defaults: ColorBrewer RdBu, Crameri `vik`.

**Do not use viridis as a categorical palette.** Sampling five colors out of viridis for unordered groups makes readers see an order that isn't there.

**Do not use rainbow / jet for quantitative data** (Borland & Taylor 2007). Non-monotonic luminance hides real features and invents false edges.

**Colorblind safety.** Wong (2011) — ~8% of men of Northern European descent have some form of CVD. Specifically avoid: red/green, green/orange, green/brown, blue/purple at low saturation. Safer: blue/orange, teal/orange (used as a newsroom default), the Okabe-Ito 8.

For palette decisions specifically, load `references/color.md`. For per-project palette declarations, see §6.

## 4. Show uncertainty, and avoid bar + error-bar specifically

Point estimates without uncertainty mislead. **Bar charts with error bars on top mislead in a specific named way** — Correll & Gleicher (2014) demonstrated the *within-the-bar bias*: values inside the filled bar region get judged as more likely than equally-distant values outside the bar. This violates the statistical meaning of the interval.

Better encodings (best-to-worst for typical scientific use):

1. Predictive distribution as ribbon, strip, or violin (when n ≥ 30/group)
2. Confidence ribbons with the CI level stated in the caption
3. Points with CI bars (`geom_pointrange`, `ax.errorbar` with `fmt='o'`) — replaces bar+error-bar
4. Box plot with overlaid raw points (preferred for n < 30/group, per Weissgerber et al. 2015)
5. Bar + SEM — the canonical anti-pattern; do not use

For animated talks/slides, consider Hypothetical Outcome Plots (Hullman et al. 2015) — animated draws from the inferred distribution. Used by NYT election needles and FiveThirtyEight.

Deeper treatment in `references/uncertainty.md`.

## 5. Direct labeling beats legends; small multiples beat overlay (often)

**Legends cost a saccade and working memory.** When you can put the label where the data lives (line endpoint, cluster centroid, region), do it. The slopegraph and the Tabula Muris UMAP both do this; almost every figure that gets praised does this.

**Small multiples beat overlay** when:

- More than ~3–5 series share an axis
- The question is "do these patterns *look alike*?" rather than "is A above B at time t?"
- You want outliers to stand out *relative to their own panel*

**Overlay beats small multiples** when:

- Two or three series with strong semantic contrast (treatment vs control)
- The question is rank order at a fixed x-value
- You want the reader to see a crossing point

## 6. Common mistakes to scan for

A scan-list, in rough order of frequency:

- **Bar + error-bar** — the within-the-bar bias. Use points + CI instead.
- **Default rainbow / jet** colormap on quantitative data.
- **Default `tab10`** used as both categorical and ordered (e.g. for model sizes).
- **Truncated y-axis on a bar chart** — bars encode by length, length-from-zero is the only honest reading.
- **Dual y-axes** — two arbitrary scales let the author manufacture any correlation.
- **Missing axis labels or units** (`"time"` not `"Time (s)"`).
- **Missing n** in the caption or annotation.
- **Spaghetti line plots** with >5 series in similar colors.
- **Significance stars only** — show effect sizes and CIs, not just `***`.
- **Default font sizes** — matplotlib's `fontsize=10` is illegible once shrunk to journal column width.
- **Color-coded without explanation** in the caption.

## 7. Critique mode — reviewing a figure

When the user shows you a figure and asks "is this OK?", run these questions in order. Stop at the first failure.

1. **What is the message?** Can you finish "This figure shows that ___" in one sentence from the figure alone? If no, the figure isn't focused.
2. **Is the strongest channel given to the most important variable?** If model accuracy is the headline, is it on the y-axis or only in the color legend?
3. **Is the chart type matched to the message?** (See §1.)
4. **Is color doing the right job?** Categorical for unordered, sequential for ordered, diverging only with a meaningful midpoint.
5. **Is uncertainty shown?** If yes, is the encoding non-bar?
6. **Are axes labeled with units?** Is n stated? Is the error bar type defined in the caption?
7. **Could a colorblind reader distinguish the groups?** Run mentally or with a simulator.
8. **Are legends necessary, or could direct labels replace them?**
9. **If multi-panel, do panels share axes? Is panel order meaningful?**
10. **Could you remove ink without losing information?** (Direction, not target — see *Anti-list* in `references/principles.md`.)

## 8. Eight named touchstones

When you're not sure how to lay out a figure, ask: which exemplar matches my data shape?

- **The Tabula Muris UMAP pattern** — fix the projection coordinates across panels, vary only the coloring. Reader learns the embedding once, then queries it. *Use for: embeddings / latent spaces with several metadata overlays.*
- **The AlphaFold PAE matrix** — symmetric heatmap with single-hue sequential color and meaningful diagonal/block structure. *Use for: confusion matrices, attention matrices, distance matrices where row/column order is meaningful.*
- **The Manhattan plot** — −log y-axis turns rare hits into tall spikes; alternating muted chromosome colors give navigation without competing with the y-axis. *Use for: hit-finding over a long ordered index (electrodes, frequency bands, time).*
- **The slopegraph** — endpoint labels do all the readout work; slope angle encodes change directly. *Use for: comparing many entities (models, institutions, conditions) at two settings.*
- **The climate stripes** — strip everything; one variable, one channel, sequential color tied to cultural priors. *Use for: poster / talk hero figures where impact > readout.*
- **The NYT election needle** — animate uncertainty so it's felt, not annotated. *Use for: talks and live demos; never for static print.*
- **The Anscombe / Datasaurus pattern** — small-multiples grid of raw data with identical summary statistics in the header. *Use for: any "look, the summary lies" argument — residuals, calibration, per-subject variability.*
- **The Transformer architecture diagram** — one recurring visual motif per recurring concept (the "Add & Norm" pill); `Nx` annotation abstracts repetition. *Use for: architecture / dataflow figures where wiring is the contribution.*

Full catalogue with links in `references/praised-figures.md`. Treat these as references to *adapt*, not patterns to copy literally.

## 9. Per-project style — projects own their palette

Every project may declare a `figure_style.yaml` at its root. When present, **the per-project style is the source of truth** — the skill follows it, the defaults above are fallbacks only.

Minimum example:

```yaml
font:
  family: "Roboto"
  size_base: 9
palette:
  categorical: ["#63BF9E", "#F28A2E", "#19727A"]
  sequential: "viridis"
  diverging: ["#296073", "#FFFFFF", "#7B3000"]
reference_lines:
  color: "#BFBBB8"
  linetype: "dashed"
  alpha: 0.4
save:
  formats: ["png", "pdf", "svg"]
  dpi: 400
  background: "white"
```

Full schema and how to load it in R / Python: `references/project-style.md`. Starter file: `assets/project_style.example.yaml`.

If no `figure_style.yaml` is present, **ask the user whether to create one** before adopting cross-project defaults silently. Each paper deserves its own visual identity.

## 10. Implementation references

When you're actually writing code, load the appropriate reference:

- **ggplot2 / R** → `references/ggplot.md` — `theme_paper()` template, `ggsave` conventions, layered annotation patterns, `cowplot::plot_grid` for multi-panel. Sourceable file: `assets/theme_paper.R`.
- **matplotlib / seaborn / Python** → `references/matplotlib.md` — `rcParams` conventions, `savefig` patterns, seaborn integration, `constrained_layout`. Drop-in stylesheet: `assets/style_paper.mplstyle`.

No plotly reference is included — add one when there's a real use case.

## 11. When NOT to use this skill

- Throwaway debugging plots you'll close in 30 seconds — defaults are fine.
- Logging / monitoring output (wandb runs, tensorboard) — the dashboard handles it.
- Tables (use a table skill or write Markdown / LaTeX directly).

Otherwise: prefer to over-apply this skill rather than under-apply. Even a "quick exploratory plot" benefits from labeled axes and a stated message.

---

## Deeper reading inside this skill

- `references/principles.md` — full 15 principles + Cleveland-McGill hierarchy + the "anti-list" (rules that are taste, not bedrock) + citations.
- `references/praised-figures.md` — all 18 touchstones with links and design notes.
- `references/color.md` — color in depth: scale types, CB-safety, when to deviate, palette catalogue.
- `references/uncertainty.md` — uncertainty representation in depth, the within-the-bar bias, the inferential-vs-outcome confusion.
- `references/ggplot.md` and `references/matplotlib.md` — implementation patterns.
- `references/project-style.md` — `figure_style.yaml` schema and loaders.
