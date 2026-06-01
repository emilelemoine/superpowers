# Uncertainty in Scientific Figures

The undervalued half. Point estimates without uncertainty mislead, but the *way* uncertainty is encoded matters as much as showing it at all — error bars themselves carry visual biases that distort how readers reason.

## The within-the-bar bias (the named anti-pattern)

Correll & Gleicher (2014, *IEEE TVCG*, "Error Bars Considered Harmful: Exploring Alternate Encodings for Mean and Error"):

When an error bar sits on top of a filled bar, readers judge values *inside* the bar's filled region as more probable than values an equal distance *outside* the bar, even though the error bar treats them symmetrically.

This is a **perceptual** bias, not a statistical one — it violates the actual meaning of the interval. The filled bar pulls perceived probability toward itself.

**Practical consequence: do not put error bars on top of bar charts.** Use points with CI bars (`geom_pointrange` in ggplot, `ax.errorbar(fmt='o')` in matplotlib), or gradient/violin plots that are symmetric.

## Inferential vs outcome uncertainty (the named misreading)

Hofman, Goldstein & Hullman (2020, "How Visualizing Inferential Uncertainty Can Mislead Readers About Treatment Effects in Scientific Results"):

95% CIs on group means convey the uncertainty of *where the mean is*. Readers routinely interpret them as the uncertainty of *individual outcomes* — leading to dramatic overestimation of effect-size reliability.

Predictive intervals (showing the range of individual outcomes) yield much more calibrated reading. When the goal is communicating "how different are the groups in practice," predictive intervals beat CIs on means.

**Practical consequence.** When writing the caption, be explicit: *"Bars represent 95% CIs of the mean. The 95% predictive interval is wider."* Or, better, show both.

## Hypothetical Outcome Plots (HOPs)

Hullman, Resnick & Adar (2015, *PLOS One*): animate 20–50 draws from the inferred distribution as discrete frames. Each frame shows one possible realization.

Kale, Nguyen, Kay & Hullman (2018, *IEEE TVCG*) and follow-ups: HOPs **outperform** static CIs and violin plots for judging variable ordering reliability ("which group is higher?") because the animation lets viewers count and integrate rather than translate from statistical conventions.

In use at NYT (election needles), FiveThirtyEight, and a growing share of communication-oriented stats reporting.

**Practical consequence.** For talks, slides, or interactive contexts, consider HOPs over static error bars. For print, fall back to ribbons/strips.

## The encoding ladder (best-to-worst for typical scientific use)

1. **Predictive distribution as ribbon, strip, or violin** — when n ≥ 30/group. Honest about both location and shape.
2. **Confidence ribbons** (`geom_ribbon`, `ax.fill_between`) with the CI level stated in the caption. Default for regressions and time series.
3. **Points with CI bars** (`geom_pointrange`, `ax.errorbar(fmt='o')`). Replaces bar+error-bar.
4. **Box plot with overlaid raw points** — preferred for n < 30/group (Weissgerber et al. 2015, *PLOS Biology*). The points expose what the box hides.
5. **Violin plots alone** — only when n ≥ 30/group. The kernel density invents structure on small samples; multiple sources warn explicitly.
6. **Bar + SEM** — the canonical anti-pattern. Specifically discouraged by Correll & Gleicher (2014) and most modern style guides. SEM is also *not* a confidence interval; it underestimates spread by √n.

## "Show the data" — Weissgerber et al. 2015

Weissgerber et al. (*PLOS Biology*, "Beyond Bar and Line Graphs: Time for a New Data Presentation Paradigm") surveyed biomedical papers and found bar/SEM plots routinely hide:

- **Bimodality** — two clusters that the mean smooths over.
- **Outliers** — driving the mean disproportionately.
- **Sample size** — n is not visually encoded.
- **Distribution shape** — skew, kurtosis.

Their recommendation: dot plots / strip plots with summary overlay (mean line + CI brackets), especially for small n. The raw data is small enough to plot directly in biomedical contexts (typically n=5–30 per group).

This applies directly to clinical EEG studies, animal experiments, and any per-subject comparison.

## Significance stars vs. effect sizes

Cumming (2014, *Psychological Science*, "The New Statistics"): annotating figures with only `*`, `**`, `***` for p-values hides what readers actually need — the effect size and its uncertainty.

**Practical consequence.** Annotate figures with effect-size estimates and CIs, not stars. If you must include stars (journal house style), put the numeric effect size next to them.

## How to caption uncertainty

A minimum-acceptable uncertainty caption includes:

- **What** is shown (mean, median, individual outcomes)
- **What** the interval/band represents (95% CI of the mean, IQR, ± 1 SD, predictive interval)
- **How** the interval was computed (bootstrap with R draws, parametric, etc.)
- **n** for each group

Example: *"Points show mean AUROC; error bars are 95% CIs computed by 1000-replicate bootstrap. n = 47 subjects per institution."*

## When the data is truly noisy

Sometimes the honest answer is "the uncertainty swamps the effect." Resist the temptation to compress the y-axis to make differences look bigger. Instead:

- Show the predictive distribution at full scale.
- Annotate the figure with the actual effect size and its CI.
- Consider whether the question deserves a different figure or more data.
