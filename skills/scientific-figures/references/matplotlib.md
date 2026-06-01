# matplotlib & seaborn — Implementation Patterns

Reference for writing figures in matplotlib / seaborn that follow the skill's principles. Patterns adapted from published practice and the user's own conventions.

## The `style_paper.mplstyle` starter

A drop-in matplotlib stylesheet that sets sensible publication defaults. Copy `assets/style_paper.mplstyle` into your project and activate:

```python
import matplotlib.pyplot as plt
plt.style.use("path/to/style_paper.mplstyle")
```

The stylesheet covers: font, sizes, axis spines, gridlines, legend frame, save defaults. Override per-figure as needed.

## Don't trust defaults — set these once

matplotlib's defaults are designed to "look reasonable on a notebook screen at 6×4 inches with a 10pt font." For publication, override:

```python
import matplotlib as mpl

mpl.rcParams.update({
    "figure.figsize":    (6.5, 4.0),      # single-column journal default
    "figure.dpi":         100,             # screen preview
    "savefig.dpi":        400,             # output
    "savefig.bbox":       "tight",
    "savefig.facecolor":  "white",         # not transparent
    "font.family":        "Roboto",        # project default
    "font.size":          9,
    "axes.titlesize":     10,
    "axes.labelsize":     9,
    "axes.spines.top":    False,
    "axes.spines.right":  False,
    "axes.grid":          True,
    "grid.color":         "#F2EEEB",
    "grid.linewidth":     0.4,
    "legend.frameon":     False,
    "lines.linewidth":    1.5,
    "lines.markersize":   4,
})
```

## Use the Agg backend on the cluster

For cluster scripts (no display), set the backend before importing pyplot:

```python
import matplotlib
matplotlib.use("Agg")   # MUST come before importing pyplot
import matplotlib.pyplot as plt
```

Otherwise scripts will hang or crash trying to connect to a non-existent display.

## Figure dimensions in inches, tied to journal columns

| Target | width (in) | typical use |
|---|---|---|
| Single column | 3.5 | small figure |
| 1.5 column | 5.0 | medium |
| Double column | 7.0 | large, full-width |
| Slide (16:9) | 13.3 × 7.5 | presentation |
| Poster panel | varies | usually 8–14 in |

Set `figsize=(w, h)` in inches with intentional aspect ratio. Don't accept the default `(6.4, 4.8)`.

## Save in multiple formats

```python
fig.savefig("figures/plot.png", dpi=400, bbox_inches="tight", facecolor="white")
fig.savefig("figures/plot.pdf",          bbox_inches="tight", facecolor="white")
# SVG only if you'll hand-edit it
fig.savefig("figures/plot.svg",          bbox_inches="tight", facecolor="white")
```

PDF is vector and the right format for journal submission. PNG for quick preview / web. SVG for hand-editing in Inkscape.

Always close the figure after saving to free memory in scripts:

```python
plt.close(fig)
```

## Uncertainty: prefer `errorbar(fmt='o')`, `fill_between`, not bars

Never put error bars on top of bars (within-the-bar bias — Correll & Gleicher 2014).

For point estimates with CIs:

```python
ax.errorbar(x, y, yerr=[y - lower, upper - y],
            fmt='o', markersize=4, capsize=3, linewidth=1.0)
ax.axhline(0.5, linestyle='--', color='#BFBBB8', alpha=0.4, linewidth=0.6)
```

For continuous uncertainty over a covariate:

```python
ax.fill_between(x, lower, upper, alpha=0.2, color=color, linewidth=0)
ax.plot(x, y, color=color, linewidth=1.5)
```

Ribbon alpha 0.2 is a good default.

For distributions, prefer `ax.violinplot` only when n ≥ 30/group. For smaller n, use a strip + summary overlay:

```python
import seaborn as sns

sns.stripplot(data=df, x='group', y='value', color='#888',
              size=3, alpha=0.5, jitter=0.2, ax=ax)
sns.pointplot(data=df, x='group', y='value', estimator='mean',
              errorbar=('ci', 95), color='black',
              markers='_', linestyle='', ax=ax)
```

## Multi-panel layouts: `constrained_layout` over `tight_layout`

`constrained_layout` is the modern default — handles axis labels, titles, legends correctly without the manual `tight_layout` recipe:

```python
fig, axes = plt.subplots(1, 2, figsize=(10, 4),
                          constrained_layout=True)
```

For complex layouts, use `subplot_mosaic`:

```python
fig, axes = plt.subplot_mosaic(
    [['roc', 'pr'],
     ['cal', 'cal']],
    figsize=(10, 8),
    constrained_layout=True
)
axes['roc'].plot(...)
axes['cal'].plot(...)   # spans both columns
```

## Panel labels (A, B, C)

```python
for label, ax in zip("ABCD", axes.flat):
    ax.text(-0.1, 1.05, label, transform=ax.transAxes,
            fontsize=12, fontweight='bold', va='top', ha='right')
```

## Direct labeling over legends

For ≤4 lines, label endpoints directly:

```python
for name, color, y_end in zip(names, colors, ys[:, -1]):
    ax.annotate(name, xy=(x[-1], y_end),
                xytext=(5, 0), textcoords='offset points',
                color=color, va='center', fontsize=8)
ax.legend().remove()
```

For dense layouts where endpoint labels would overlap, use [`adjustText`](https://github.com/Phlya/adjustText) to space them out automatically.

## Color: palettes that don't lie

For categorical (≤8 levels), seaborn's `colorblind` palette approximates Okabe-Ito:

```python
import seaborn as sns
sns.set_palette("colorblind")          # 10 colors, CB-safe
# or explicitly:
okabe_ito = ["#000000", "#E69F00", "#56B4E9", "#009E73",
             "#F0E442", "#0072B2", "#D55E00", "#CC79A7"]
```

For sequential / continuous, use viridis (matplotlib default since 2.0):

```python
ax.scatter(x, y, c=values, cmap="viridis", s=8, alpha=0.7, rasterized=True)
plt.colorbar(...)
```

For diverging (data has meaningful zero/midpoint):

```python
ax.imshow(matrix, cmap="RdBu_r", vmin=-vmax, vmax=vmax)
```

Always set `vmin = -vmax` symmetrically for diverging maps — otherwise the midpoint shifts away from zero.

## Rasterize dense scatter plots

For scatter plots with >10k points being saved as PDF, rasterize the points themselves (axes/labels stay vector):

```python
ax.scatter(x, y, c=values, cmap="viridis",
           s=1, alpha=0.5, rasterized=True)
fig.savefig("plot.pdf", dpi=300)
```

Without this, the PDF can be 50+ MB and slow to render.

## Seaborn: when to reach for it

Seaborn is matplotlib with sensible defaults for statistical plots:

- **`sns.relplot`** / **`sns.catplot`** — faceted scatter/categorical plots in one call.
- **`sns.regplot`** / **`sns.lmplot`** — scatter with regression line + CI.
- **`sns.stripplot`** + **`sns.pointplot`** — the small-n alternative to violins.
- **`sns.heatmap`** — annotated matrix heatmaps with one line.
- **`sns.pairplot`** — quick exploratory pairs plot.

Drop down to raw matplotlib when you need fine control or custom layouts.

## Per-project palette pattern

Load from `figure_style.yaml`:

```python
import yaml
from pathlib import Path

def load_project_style(project_root: Path) -> dict:
    style_path = project_root / "figure_style.yaml"
    if not style_path.exists():
        return {}
    with open(style_path) as f:
        return yaml.safe_load(f)

style = load_project_style(Path.cwd())
palette = style.get("palette", {}).get("categorical",
    ["#63BF9E", "#F28A2E", "#19727A"])

sns.set_palette(palette)
```

Or apply via rcParams:

```python
mpl.rcParams["axes.prop_cycle"] = mpl.cycler(color=palette)
```

## Common pitfalls in matplotlib specifically

- **Forgetting to close figures** in a loop → memory leak in long-running scripts. Always `plt.close(fig)`.
- **Mixing OO and pyplot APIs** — pick one per function. Prefer the OO API (`fig, ax = plt.subplots(); ax.plot(...)`) for readability.
- **`plt.savefig` without `bbox_inches='tight'`** — labels get clipped.
- **`plt.savefig` with default `facecolor`** — `'white'` is the safe choice; `'none'` (transparent) renders unpredictably across viewers.
- **Setting `figsize` then changing it after creating axes** — coordinates won't update. Set figsize once at creation.
- **Using `plt.gca()` repeatedly** instead of holding a reference to `ax` — fragile when there are multiple subplots.
- **Tiny axis labels in a poster figure** — the default font sizes don't scale with figsize. Bump `axes.labelsize` to 14–18 for posters.

## Useful packages beyond matplotlib

- **`seaborn`** — statistical plotting defaults.
- **`adjustText`** — non-overlapping text labels.
- **`mplcursors`** — interactive hover labels for exploration.
- **`palettable`** — every named palette (ColorBrewer, Tableau, Tol, etc.) accessible by name.
- **`colorspacious`** — perceptual color space utilities, including CVD simulation.
- **`scienceplots`** — opinionated stylesheets for various journals (IEEE, Science, Nature).
