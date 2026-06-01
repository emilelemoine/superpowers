# Scientific Figure Design — Full Principles & Citations

The 15 principles distilled from the literature, ordered by load-bearingness, with the mechanism / evidence each rests on and the conditions under which the principle can be bent. The eight foregrounded in `SKILL.md` are marked **[core]**.

Sources are listed at the end. Where authorities disagree, the disagreement is surfaced rather than papered over.

---

## 1. Match the visual encoding to the perceptual task [core]

**Statement.** When the goal is comparing magnitudes, encode values using channels humans decode accurately (position, length) rather than channels we decode poorly (angle, area, color saturation, volume).

**Evidence.** Cleveland & McGill (1984, *JASA*) ran psychophysical experiments and produced a now-canonical ranked list of elementary perceptual tasks (see *Cleveland–McGill hierarchy*, below). Heer & Bostock (2010, CHI) replicated on Mechanical Turk and broadly confirmed the ordering, with small refinements around rectangular area. Munzner (2014) operationalizes it as: *the importance of the attribute should match the salience of the channel*.

**Common violation.** Encoding the primary quantity in color hue or pie-slice angle while wasting the x-axis on a categorical label that could have been a row in a table.

**When to bend.** When the task is *identification* rather than magnitude comparison ("find the red points"), color hue and shape — bottom of the magnitude ranking — are correct choices. The ranking is for *ordered* attributes (Munzner).

---

## 2. Identify the message first, design second [core]

**Statement.** A figure exists to convey a single, identifiable claim. The design decisions follow from the claim.

**Evidence.** Rougier, Droettboom & Bourne (2014, *PLOS Comp Bio*, "Ten Simple Rules for Better Figures"), Rule 2. Cairo (*The Functional Art*, 2012) frames every chart as an argument. The FT *Visual Vocabulary* is organized entirely around *message categories* — deviation, correlation, ranking, distribution, change-over-time, magnitude, part-to-whole, flow, spatial — and recommends chart types per message, not per data type.

**Common violation.** Reaching for `df.plot()` and shipping whatever falls out; making a figure that shows ten things and asserts none of them.

**When to bend.** Exploratory plots for your own eyes have no audience-facing message and can be promiscuous.

---

## 3. Maximize the data-ink ratio — direction, not target

**Statement.** Most ink should encode data; non-data ink (heavy borders, grey backgrounds, redundant tick labels, 3D bevels) should be removed unless it adds information.

**Evidence.** Tufte (*Visual Display of Quantitative Information*, 1983) defined data-ink ratio = data-ink / total ink. Wilke (*Fundamentals*, ch. 17, "Proportional Ink") extends to proportional inked area.

**Counter-evidence.** Inbar, Tractinsky & Meyer (2007) found readers prefer some non-data ink. Bateman et al. (2010, CHI, "Useful Junk?") found embellished charts had no comprehension cost and *better* long-term recall than minimal charts. The synthesis: treat the ratio as a *direction* (less decoration, more data) not a *target* (erase everything erasable). Gridlines and reference markers often help readers look up specific numbers — useful in printed scientific figures.

---

## 4. Color: scale type follows data type [core]

**Statement.** Color comes in three flavors — qualitative (unordered categories), sequential (ordered/quantitative), diverging (values around a meaningful midpoint). Using the wrong flavor invents structure that isn't in the data.

**Evidence.** Wilke (chs. 4 & 19); Brewer (2003, *ColorBrewer*); Wong (2011). The pitfall chapter (Wilke ch. 19) names three failures: (a) >8 categorical hues becomes unreadable; (b) non-monotonic scale (rainbow/jet) for continuous values; (c) ignoring color-vision deficiency.

**Common violation.** Using matplotlib `tab10` for "model size" — readers can't tell which color is bigger without consulting the legend.

**See also.** `color.md` for the full palette catalogue and CB-safety guidance.

---

## 5. Make figures colorblind-safe by default [core]

**Statement.** ~8% of men of Northern European descent have some form of color-vision deficiency (Wong 2011, *Nat Methods*, "Color blindness"). Default to palettes that survive CVD simulation; verify before publication. Lower in other populations but never negligible.

**Evidence.** Wong (2011) popularized the Okabe-Ito 8-color palette — orange #E69F00, sky blue #56B4E9, bluish green #009E73, yellow #F0E442, blue #0072B2, vermillion #D55E00, reddish purple #CC79A7, black #000000 — designed by Masataka Okabe and Kei Ito (2002). Wilke adopts it as his book default. For continuous data, viridis/cividis (Smith & van der Walt 2015; Nuñez et al. 2018) are perceptually uniform, monotonic, and CB-safe.

**Pairings to avoid:** red/green (the famous one), green/brown, green/orange (all confused under deuteranopia/protanopia), blue/purple at low saturation (tritanopia), pastel red / pastel green.

**Reasonably safe:** blue/orange, blue/yellow, teal/orange (newsroom favorite), black/orange, the Okabe-Ito 8.

**When to bend.** Almost never for published figures. For private working plots, use whatever helps you think.

---

## 6. Don't use rainbow / jet colormaps for quantitative data

**Statement.** Rainbow scales fail as quantitative encodings: non-monotonic in luminance, introduce false sharp boundaries at hue transitions ("yellow band" artifact), and degrade to noise in grayscale and under CVD.

**Evidence.** Borland & Taylor (2007, *IEEE CG&A*, "Rainbow Color Map (Still) Considered Harmful") — the canonical citation. Crameri, Shephard & Heron (2020, *Nat Commun*, "The misuse of colour in science communication") quantified that ~25% of recent geoscience papers still used unsuitable rainbow maps.

**Counter-evidence.** Ware, Turton, Bujack et al. (2023, *IEEE CG&A*, "Rainbow Colormaps Are Not All Bad") — rainbow can outperform luminance-only maps for *detail discrimination* at the cost of accurate magnitude judgments. Synthesis: viridis-family for magnitude tasks; rainbow only when local feature detection is the explicit goal and the audience is trained on the map.

---

## 7. Show uncertainty, matched to the inference [core]

**Statement.** Point estimates without uncertainty mislead. Error bars themselves carry visual biases; alternative encodings (gradient/violin plots, confidence ribbons, hypothetical outcome plots) better match how readers reason.

**Evidence.** Correll & Gleicher (2014, *IEEE TVCG*, "Error Bars Considered Harmful") demonstrated the **within-the-bar bias**: when an error bar sits on top of a bar, readers judge values inside the bar's filled region as more likely than values an equal distance outside. Symmetric encodings (gradients, violins) avoid this. Hofman, Goldstein & Hullman (2020) showed that inferential uncertainty (CIs on means) is routinely misread as outcome uncertainty — showing predictive intervals improves calibration. Hullman et al. (2015, *PLOS One*) introduced Hypothetical Outcome Plots (HOPs).

**Common violation.** "Mean ± SEM" bar charts with no indication of n or distribution shape. SEM is not a confidence interval and underestimates spread by √n.

**See also.** `uncertainty.md` for the encoding ladder and HOPs treatment.

---

## 8. Prefer small multiples to overlays for "are these patterns similar?" [core]

**Statement.** When showing more than ~3–5 categories of time series or distributions, faceted panels with shared axes outperform an overlaid "spaghetti" plot.

**Evidence.** Tufte (*Envisioning Information*, 1990): "*Compared to what?* Small multiple designs… answer directly by visually enforcing comparisons." Cleveland's *Visualizing Data* (1993) operationalized this as Trellis displays. Wilke (ch. 21) endorses faceting for high-cardinality categorical variables.

**Common violation.** Plotting 30 subjects' EEG traces on one axes in slightly different colors — unreadable.

**When to bend.** Outlier detection in an ensemble (overlay with low-alpha lines + highlighted median); two or three series with strong semantic contrast; comparisons that ask "is A above B at time t?" rather than "do A and B have the same shape?"

---

## 9. Direct labeling beats legends, where possible [core]

**Statement.** A legend forces the reader to round-trip between plot and swatch lookup, consuming working memory. Labels placed *at* the visual mark (line endpoint, point, region) eliminate this cost.

**Evidence.** Few (*Show Me the Numbers*, 2012; *Now You See It*, 2009). Healy's *Data Visualization* (2018). Heer & Bostock (2010) indirectly support it: legends increase error and time on simple judgments. BBC `bbplot` cookbook recommends direct annotation as the line-chart default.

**When to bend.** When labels would themselves create clutter — then prefer faceting (Principle 8) over a legend.

---

## 10. Don't trust software defaults

**Statement.** Default plotting outputs are *generic*, optimized for no particular figure. Every published figure should have intentional choices about font size, marker size, line weight, color, aspect ratio, and tick density.

**Evidence.** Rougier et al. (2014), Rule 5. Wilke ch. 23: default font sizes are usually too small once the figure is shrunk to journal column width.

**Common violation.** Matplotlib's `figsize=(6.4, 4.8)`, `fontsize=10` axis labels, and `tab10` color cycle, shipped untouched into a publication.

**When to bend.** Rapid exploratory analysis. Bend back before publishing.

---

## 11. Captions are not optional and should make the figure standalone

**Statement.** The caption must (a) state what the figure shows, (b) define every symbol/color/error-bar convention used, and (c) state the message or finding.

**Evidence.** Rougier et al. (2014), Rule 4. Nature Methods, Cell, and most major journals require n, error-bar type, statistical test, and significance levels in the caption. Cairo (*The Truthful Art*, 2016) frames captions as the antidote to "the picture lies because the words are missing."

**Common violation.** "Figure 3: Results." — no n, no error bar definition, no scale convention.

---

## 12. Respect proportional ink on axes

**Statement.** The visual size of an encoded mark should be proportional to the data value. Bars truncated below zero, log-axes with linear-looking gridlines, and area marks scaled to radius rather than area all violate this.

**Evidence.** Wilke ch. 17. Cleveland & McGill (1984). For bar charts specifically, multiple sources are unanimous: bars encode by *length*, and length-from-zero is the only honest reading.

**When to bend.** Line charts of quantities with no meaningful zero (temperature in K, calendar dates, ratios around 1.0, log-ratios) should not be forced to include zero. Cairo's rule of thumb: include zero if zero is meaningful and including it doesn't flatten the signal.

---

## 13. Annotate findings, don't just plot them [core]

**Statement.** Use text annotations, arrows, and shaded regions to point at the conclusion the reader should reach.

**Evidence.** Cairo (*The Functional Art*, 2012; *The Truthful Art*, 2016): the difference between an exploratory chart and an explanatory chart is annotation. BBC `bbplot` bakes in annotation helpers. FT charts carry inline labels stating the headline finding.

**Common violation.** Abstract claims "40% lower X in condition A" but the figure shows two distributions with no markup pointing at the 40% gap.

---

## 14. Match the chart type to the message, not to the data type [core]

**Statement.** The same data can support multiple charts; pick the one whose visual structure matches the intended claim.

**Evidence.** FT *Visual Vocabulary* organizes ~70 chart types under nine message categories — deviation, correlation, ranking, distribution, change-over-time, magnitude, part-to-whole, spatial, flow. Munzner's task-channel matching is the formal version.

**Common violation.** Always reaching for a bar chart because the data is "categorical."

---

## 15. Test the figure against the reader's first question

**Statement.** Before shipping, ask: what is the first question a reviewer/reader will ask? Can they answer it from this figure without re-reading the methods?

**Evidence.** Rougier et al. (2014), Rules 1, 4, 9. Healy's "look at the data, then look again" workflow.

---

## The Cleveland–McGill perceptual hierarchy

From Cleveland & McGill (1984, *JASA* 79:531–554), confirmed and refined by Heer & Bostock (2010, CHI). Most accurate to least accurate for *magnitude* judgments:

1. **Position on a common scale** (dot plot, scatter plot)
2. **Position on identical, non-aligned scales** (small multiples)
3. **Length** (bar chart from a common baseline)
4. **Angle / slope** (pie slices, line slopes)
5. **Area** (bubble chart, treemap)
6. **Volume, curvature** (3D charts)
7. **Color saturation / luminance** (heatmap intensity)
8. **Color hue** (categorical color)

Heer & Bostock's crowdsourced replication: ordering held; rectangular areas (treemap-like) were perceived more accurately than circular areas; luminance contrast judgments improved when surrounding context was held constant.

Munzner restates this as the **magnitude channel ranking**: spatial position > length (1D) > area (2D) > depth (3D) > color luminance > color saturation > curvature > volume. Channels at the top get the important variable.

---

## The anti-list — rules that are taste, not bedrock

Commonly preached as absolute; actually context-dependent or contested.

- **"Never use pie charts."** Tufte said this; Cleveland was more nuanced. Pies test about as well as bars when judging part-to-whole with ≤3 slices, worse with many slices. Hill (2024, *Information Visualization*) provides a partial defense. Use case: single 2–3 slice part-to-whole is defensible; many small pies in a grid are usually worse than a stacked-bar small multiple.

- **"Always start the y-axis at zero."** True for *bar charts* (length encoding from a non-zero baseline is dishonest). False as a universal rule for line charts: temperature, stock price, calendar-year measurements, pH, log-ratios have no meaningful zero. Cairo: include zero if zero is meaningful and including it doesn't flatten the signal.

- **"3D is always bad."** Mostly true for *encoding* a 2D variable in a 3D chart. But genuinely 3D data (molecular structures, anatomical reconstructions, vector fields) requires 3D rendering. The rule is against fake 3D, not 3D.

- **"Maximize data-ink ratio."** Direction-correct, target-incorrect. Inbar et al. (2007), Bateman et al. (2010, *Useful Junk?*) found embellished charts had no comprehension cost and better recall. Strip junk; don't strip orientation cues.

- **"Never use red/green together."** True for standard saturated red/green. Red/green with strongly differentiated luminance (dark red against pale green) is often recognizable under CVD; but the safer move is red/blue or Okabe-Ito.

- **"Use viridis for everything."** Viridis is a good *magnitude* default; it's continuous, not categorical. Don't sample 5 colors from viridis for unordered groups — readers will read an order that isn't there. Use Okabe-Ito / ColorBrewer qualitative for categories.

- **"More chart types = better."** Few argues the opposite: master ~10 chart types deeply rather than reach for novelty types. Munzner agrees: novelty without task-channel match is decoration.

- **"Box plots are obsolete because violins are better."** Violins on small n invent structure. Box plots with overlaid raw points are usually safer for biomedical n-per-group sizes (Weissgerber et al. 2015).

---

## Sources

- Tufte, *The Visual Display of Quantitative Information* (1983); *Envisioning Information* (1990).
- Cleveland & McGill, "Graphical Perception: Theory, Experimentation, and Application…" *JASA* (1984).
- Cleveland, *The Elements of Graphing Data* (1985); *Visualizing Data* (1993).
- Wilke, *Fundamentals of Data Visualization* (2019). https://clauswilke.com/dataviz/
- Munzner, *Visualization Analysis and Design* (2014).
- Cairo, *The Functional Art* (2012); *The Truthful Art* (2016).
- Few, *Show Me the Numbers* (2nd ed., 2012); *Now You See It* (2009).
- Healy, *Data Visualization: A Practical Introduction* (2018). https://socviz.co/
- Heer & Bostock, "Crowdsourcing Graphical Perception," CHI (2010).
- Rougier, Droettboom & Bourne, "Ten Simple Rules for Better Figures," *PLOS Comp Bio* (2014).
- Wong, "Points of view: Color blindness," *Nature Methods* (2011).
- Okabe & Ito, "Color Universal Design" presentation (2002).
- Borland & Taylor, "Rainbow Color Map (Still) Considered Harmful," *IEEE CG&A* (2007).
- Ware, Turton, Bujack et al., "Rainbow Colormaps Are Not All Bad," *IEEE CG&A* (2023).
- Crameri, Shephard & Heron, "The misuse of colour in science communication," *Nat Commun* (2020).
- Correll & Gleicher, "Error Bars Considered Harmful," *IEEE TVCG* (2014).
- Hullman, Resnick & Adar, "Hypothetical Outcome Plots…," *PLOS One* (2015).
- Hofman, Goldstein & Hullman, "How Visualizing Inferential Uncertainty Can Mislead…" (2020).
- Kale, Nguyen, Kay & Hullman, HOPs follow-ups (2018+).
- Weissgerber et al., "Beyond Bar and Line Graphs," *PLOS Biology* (2015).
- Cumming, "The New Statistics," *Psychological Science* (2014).
- Bateman et al., "Useful Junk?" CHI (2010).
- Inbar, Tractinsky & Meyer, minimalism preference study (2007).
- Hill, "Are pie charts evil?" *Information Visualization* (2024).
- BBC Visual & Data Journalism, `bbplot` cookbook. https://github.com/bbc/bbplot
- Smith, FT *Visual Vocabulary*. https://ft-interactive.github.io/visual-vocabulary/
- Brewer, *ColorBrewer*. https://colorbrewer2.org/
