# ggplot2 — Implementation Patterns

Reference for writing figures in ggplot2 / R that follow the skill's principles. Patterns extracted from published scientific work; not boilerplate. Adapt.

## The `theme_paper()` starter

A clean publication-leaning theme. Copy or source from `assets/theme_paper.R`.

```r
library(ggplot2)
library(showtext)

# Optional: register Roboto (the user's default)
font_add_google("Roboto", "Roboto")
showtext_auto()

theme_paper <- function(base_size = 9, font = "Roboto") {
  theme_minimal(base_size = base_size) +
    theme(
      text = element_text(family = font),
      panel.grid.major = element_line(colour = "#F2EEEB", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      strip.text = element_text(size = rel(1.1), colour = "#1A242F"),
      plot.title = element_text(size = rel(1.2), face = "plain"),
      legend.title = element_blank()
    )
}
```

Notes on choices:

- `theme_minimal` over `theme_classic` because faint gridlines aid value lookup (the Inbar/Bateman counter-evidence to strict data-ink maximalism). Strip them by setting `panel.grid = element_blank()` if a specific figure benefits.
- `legend.title = element_blank()` by default — title is usually redundant with axis/caption. Override per-figure when needed.
- Per-project font/size overrides via `figure_style.yaml`.

## Save figures with a white background

ggsave's default is transparent. PDFs and slides render this differently across viewers. Force white:

```r
ggsave <- function(..., bg = "white") ggplot2::ggsave(..., bg = bg)
```

Override once at the top of every analysis script. Cheap and prevents the "why is my slide background showing through" surprise.

## Save in multiple formats per figure

Manuscript-grade figures should ship as PNG (preview / web), PDF (vector, journal submission), and optionally SVG (editing in Inkscape/Illustrator):

```r
# PNG for preview
ggsave("figures/plot.png", p, width = 8.5, height = 4.5, dpi = 400)
# PDF for vector
ggsave("figures/plot.pdf", p, width = 8.5, height = 4.5, device = cairo_pdf)
# SVG only when you'll hand-edit it
ggsave("figures/plot.svg", p, width = 8.5, height = 4.5)
```

`device = cairo_pdf` is important for non-ASCII characters and consistent font rendering.

## Reference lines

For chance lines, baselines, identity lines, etc., use a faint dashed grey so they don't compete with the data:

```r
geom_hline(yintercept = 0.5, linetype = "dashed", colour = "#BFBBB8",
           linewidth = 0.4, alpha = 0.4)
```

The light warm grey `#BFBBB8` recedes against both white and light gridlines.

## Uncertainty: prefer pointrange, ribbons over bar+errorbar

Never put error bars on top of bars (within-the-bar bias). Use points-and-bars instead:

```r
ggplot(df, aes(x = group, y = estimate, colour = group)) +
  geom_pointrange(aes(ymin = lower_ci, ymax = upper_ci),
                  size = 0.5, fatten = 2) +
  geom_hline(yintercept = 0.5, linetype = "dashed",
             colour = "#BFBBB8", alpha = 0.4)
```

For continuous uncertainty over a covariate (ROC curves, time series, sample-size curves):

```r
ggplot(df, aes(x = x, y = estimate, colour = group, fill = group)) +
  geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci),
              alpha = 0.2, colour = NA) +
  geom_line(linewidth = 0.7)
```

Ribbon alpha 0.2 is a good default — opaque enough to read, transparent enough to overlap.

## Multi-panel layouts

For panels with shared aesthetic but different facets, prefer `facet_wrap` / `facet_grid`. For panels that are conceptually different (e.g. ROC + PR), use `cowplot::plot_grid`:

```r
library(cowplot)

p1 <- roc_plot + theme(legend.position = "none")
p2 <- pr_plot   # legend lives here, on the right panel

combined <- plot_grid(p1, p2,
                       rel_widths = c(0.75, 1.0),
                       labels = c("A", "B"),
                       label_fontfamily = "Roboto",
                       label_size = 12)

ggsave("figures/curves.pdf", combined,
       width = 12, height = 6, device = cairo_pdf)
```

Hide legends on inner panels (`legend.position = "none"`); keep one shared legend on the outermost panel.

For grids of subgroup AUC plots (the covariables figure pattern), hide y-axis text on all but the first panel:

```r
p_inner <- p_base + theme(
  axis.title.y = element_blank(),
  axis.text.y  = element_blank(),
  axis.ticks.y = element_blank(),
  axis.line.y  = element_blank()
)
```

## Direct labeling over legends

When you have ≤4 lines, label endpoints directly instead of using a legend:

```r
library(ggrepel)

ggplot(df, aes(x = time, y = value, colour = group)) +
  geom_line() +
  geom_text_repel(
    data = df %>% filter(time == max(time)),
    aes(label = group),
    nudge_x = 0.5,
    hjust = 0,
    direction = "y",
    segment.size = 0.2
  ) +
  theme(legend.position = "none") +
  coord_cartesian(clip = "off") +
  theme(plot.margin = margin(5, 60, 5, 5))  # extra right margin for labels
```

`coord_cartesian(clip = "off")` lets labels extend past the panel.

## Annotation: state the finding on the figure

```r
ggplot(df, aes(x = x, y = y, colour = model)) +
  geom_line() +
  annotate("text", x = 0.6, y = 0.27,
           label = "DeepEpilepsy: 0.76 (0.69--0.83)",
           hjust = 0, size = 3.5, family = "Roboto")
```

Use `--` (en-dash) for ranges in printed numbers. Compose the annotation string with `sprintf("%.2f (%.2f--%.2f)", est, lci, uci)` — leading zeros stripped by default for values < 1 in R (`format(round(x, 2), nsmall = 2)` if you want them).

## Faceting with free scales

For subgroup AUC plots where panels have different x-categories but a shared y-scale:

```r
ggplot(df, aes(x = level, y = AUC, colour = level)) +
  geom_pointrange(aes(ymin = lower_ci, ymax = upper_ci)) +
  facet_grid(cols = vars(variable), scales = "free_x", space = "free_x") +
  scale_x_discrete(guide = guide_axis(angle = 60)) +
  ylim(0, 1) +
  geom_hline(yintercept = 0.5, linetype = "dashed",
             colour = "#BFBBB8", alpha = 0.4)
```

`scales = "free_x"` lets each facet have its own categories; `space = "free_x"` keeps the bar widths proportional to category count.

## Project palette pattern

Declare palettes once at the top of the file (or load from `figure_style.yaml`):

```r
# From figure_style.yaml or hardcoded
project_palette <- list(
  categorical = c("#63BF9E", "#F28A2E", "#19727A"),
  diverging   = c("#296073", "#FFFFFF", "#7B3000"),
  sequential  = "viridis"
)

p + scale_colour_manual(values = project_palette$categorical)
```

For a colorblind-safe alternative when the project palette is borderline (e.g. green+orange), keep Okabe-Ito available as a fallback:

```r
okabe_ito <- palette.colors(palette = "Okabe-Ito")  # built-in R 4.0+
```

## Common pitfalls in ggplot specifically

- **Default `tab10`-style colors via `scale_colour_brewer(palette = "Set1")`** — Set1's red and green are CB-unsafe. Prefer Set2 / Dark2 / Okabe-Ito.
- **Forgetting to set `bg = "white"`** in `ggsave` — PDFs render transparent on some viewers.
- **`scale_colour_gradient(low = ..., high = ...)`** between two arbitrary hues — usually not perceptually uniform. Use `scale_colour_viridis_c()` instead.
- **Using `geom_smooth()` without showing `n` per group** — the smooth hides sample-size differences. Show the raw points too.
- **Default facet labels (`facet_wrap(~ var)`)** — often abbreviated or unclear. Override with `labeller = labeller(var = c("a" = "Label A", ...))`.
- **`coord_cartesian(ylim = ...)` vs `ylim(...)`** — `ylim()` *drops* data outside the range, breaking `geom_smooth` and CIs. Use `coord_cartesian(ylim = ...)` to zoom without dropping.

## Useful packages beyond ggplot2

- **`cowplot`** — multi-panel layouts (`plot_grid`).
- **`patchwork`** — newer, more ergonomic multi-panel (`p1 | p2 / p3`).
- **`ggrepel`** — non-overlapping text labels.
- **`scales`** — axis label formatters (`label_percent`, `label_scientific`, `unit_format`).
- **`ggdist`** — distribution geoms (eye plots, gradient intervals, halfeye) — the modern way to show uncertainty.
- **`colorspace`** — CVD simulation (`deutan`, `protan`, `tritan`) for verifying palettes.
