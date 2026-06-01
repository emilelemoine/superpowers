# Praised Scientific Figures — Design Touchstones

A working catalogue of named, real figures to reference as design touchstones. Each entry: what it is, where to see it, the specific design choices that make it work, what it teaches, and (where relevant) what rule it knowingly breaks.

The eight foregrounded in `SKILL.md` are marked **[core]**.

---

## 1. The climate stripes (Ed Hawkins, 2018) [core]

- **What.** A horizontal sequence of vertical color bars, one per year (1850 → present), each colored by that year's global temperature anomaly relative to a 1971–2000 baseline. No axes, no numbers.
- **Link.** https://showyourstripes.info
- **Design choices.**
  1. **One variable, one channel.** Temperature anomaly is encoded by color and only color.
  2. **Sequential diverging palette tied to cultural priors** (blue = cold, red = warm). No legend needed.
  3. **Baseline period chosen for visual balance.** Hawkins picked 1971–2000 so the dark blues at left match the dark reds at right in saturation — making the rightward warming trend the only asymmetry left, which is the *story*.
  4. **Strips axes, ticks, gridlines, labels.** Year ordering is implicit (left-to-right time).
- **Use for.** Single ordered variable across many units when you want the trend to be the entire message and you can afford to drop precise readout.
- **Risk.** Zero precision — you can't read off a specific year. The figure trades all readout for all impact.

## 2. Minard's Napoleon march (1869)

- **What.** A flow map of Napoleon's 1812 Russia campaign that simultaneously encodes army size, geographic path, direction, and temperature on the return leg.
- **Link.** https://en.wikipedia.org/wiki/File:Minard.png
- **Design choices.**
  1. **Band width = troop count** at 1 mm per 10,000 men, inside the geographic path.
  2. **Two-color flow** (gold out, black back) with no legend — direction encoded by branching geometry.
  3. **Temperature panel shares x-axis (longitude/time)** with the return path.
  4. **No statistical chart conventions** — encodings labeled inline once.
- **Use for.** Spatial trajectory combined with a quantity varying along it.
- **Risk.** Six variables in one figure works only because five are *co-registered to the same path*.

## 3. John Snow's Broad Street cholera map (1854/1855)

- **What.** Street map of Soho marked with stacks of hash marks at each cholera-death address, plus public water pump locations.
- **Link.** https://www.york.ac.uk/depts/maths/histstat/snow_map.htm
- **Design choices.**
  1. **One mark per death, stacked at address.** Visual density is the count.
  2. **Pumps as differently-shaped point symbols.** Eye finds Broad Street pump because it's the only one with a death-stack halo.
  3. **(1855 version) Dotted "Voronoi" boundary** of households closest to Broad Street pump. Converts the map from "a hypothesis" to "a hypothesis with a control region."
  4. **Geographic base layer deliberately faint** so data overlay wins figure-ground.
- **Use for.** Spatial distribution of a rare or count-valued event when arguing co-location → causation.

## 4. Florence Nightingale's coxcomb (1858)

- **What.** Two polar-area diagrams of monthly British Army deaths in the Crimean War, partitioned by cause (disease, wounds, other), before and after sanitary reform.
- **Link.** https://en.wikipedia.org/wiki/File:Nightingale-mortality.jpg
- **Design choices.**
  1. **Two panels of the same chart for before/after** — only data changes, eye forced onto the difference.
  2. **Preventable cause (disease) on the outside** so its shrinkage between panels is the loudest visual change.
  3. **Wedges by month around the circle**, mimicking calendar.
- **Use for.** Persuasive policy/clinical figures where a counterfactual ("if we'd intervened earlier…") needs to be visually undeniable.
- **Risk.** Polar area exaggerates differences (area ∝ radius²). Nightingale wanted the exaggeration; modern usage on neutral data is widely criticized.

## 5. Hans Rosling's Gapminder bubble chart

- **What.** Scatter of countries with GDP per capita (log x) vs. life expectancy (linear y); bubble area = population; color = world region; animated frame = year.
- **Link.** https://www.gapminder.org/tools/
- **Design choices.**
  1. **Log x-axis** so low-income countries (spanning 2–3 orders of magnitude) aren't crushed.
  2. **Area, not radius, encodes population.**
  3. **Region as color, kept to ~6 categories.**
  4. **Time as animation, not as another encoding** — static frame stays at 5 variables.
- **Use for.** Multi-variable scatter when one variable is categorical-and-few and one is temporal-and-ordered.
- **Risk.** Color + size simultaneously is normally over-budget; works here because color has few levels.

## 6. The Okabe–Ito / Bang Wong colorblind-safe palette

- **What.** 8-color qualitative palette designed for distinguishability under deuteranopia/protanopia, popularized by Bang Wong's 2011 *Nature Methods* "Points of View" column.
- **Link.** https://www.nature.com/articles/nmeth.1618 ; swatches https://mk.bcgsc.ca/colorblind/palettes.mhtml
- **Design choices.**
  1. **Categorical colors selected in CVD perceptual space**, not RGB.
  2. **Black is one of the eight** — strong anchor.
  3. **Vermillion + sky blue replaces red + green** as the default high-contrast pair.
- **Use for.** Any categorical encoding with ≤8 levels. The default to reach for before designing a custom palette.

## 7. Manhattan plot (GWAS) [core]

- **What.** Scatter where each point is a SNP; x = genomic position (chromosomes laid end to end); y = −log₁₀(p) for that SNP's trait association.
- **Link.** https://en.wikipedia.org/wiki/Manhattan_plot
- **Design choices.**
  1. **−log transform on y** turns tiny p-values into tall spikes — interesting points become literally the most visible.
  2. **Alternating chromosome color** (two muted shades) gives navigation without competing with the y-axis story.
  3. **Horizontal significance threshold line** (e.g., 5×10⁻⁸) gives an unambiguous "above the line = real hit" rule.
  4. **Density of points is the texture** — peak structure visually pops.
- **Use for.** Hit-finding over a long ordered index (genome, time, frequency band, electrode).
- **Risk.** Many overlapping points hide individual identities — Manhattan++ variants address this when count-within-peak matters.

## 8. Slope chart / slopegraph (Tufte) [core]

- **What.** Two columns of labeled values (time 1 and time 2) connected by straight lines.
- **Link.** https://www.edwardtufte.com/notebook/slopegraphs-for-comparing-gradients-slopegraph-theory-and-practice/
- **Design choices.**
  1. **Label = data label = axis label = legend** — each entity's name sits next to its starting and ending value.
  2. **Slope (line angle) directly encodes rate of change** — strongest pre-attentive cue carries the most important variable.
  3. **No grid, no axes** — endpoint labels do all readout.
- **Use for.** Comparing many entities (countries, models, conditions) at two settings, when both ranking and per-entity delta matter.
- **Risk.** Falls apart with >~20 entities (overlap) or tiny changes (flat slopes).

## 9. Anscombe's quartet (1973) and the Datasaurus dozen (2017) [core]

- **What.** Four (or thirteen) datasets with nearly identical mean, variance, correlation, OLS fit — but radically different scatter shapes.
- **Link.** https://en.wikipedia.org/wiki/Anscombe%27s_quartet ; Datasaurus https://www.research.autodesk.com/publications/same-stats-different-graphs/
- **Design choices.**
  1. **Small multiples in a 2×2 grid** with identical axes.
  2. **Each subplot is just raw points + the same regression line** — minimal ink, so the visual difference is the message.
  3. **Summary statistics written above the grid** so the contradiction with the plotted shape is immediate.
- **Use for.** Any "look, the data isn't what the summary suggests" argument — model residuals, calibration plots, per-subject variability.

## 10. AlphaFold predicted-aligned-error (PAE) plot [core]

- **What.** Residue × residue heatmap where cell (i, j) is colored by expected position error at residue i if structure were aligned on residue j.
- **Link.** https://www.ebi.ac.uk/training/online/courses/alphafold/inputs-and-outputs/evaluating-alphafolds-predicted-structures-using-confidence-scores/pae-a-measure-of-global-confidence-in-alphafold-predictions/
- **Design choices.**
  1. **Symmetric matrix layout** — domain structure shows as bright low-error blocks along the diagonal; inter-domain confidence as off-diagonal block brightness.
  2. **Single-hue sequential colormap** — error is 1D; single hue keeps the diagonal-block story uncluttered.
  3. **Paired with 3D structure colored by per-residue pLDDT** — complementary figures, neither tries to encode both signals.
- **Use for.** Pairwise quantity (confusion matrix, attention, distance matrix, inter-region coupling) where block structure carries the scientific story.
- **Risk.** Works only when row/column ordering is meaningful; arbitrary ordering loses the block structure.

## 11. UMAP / t-SNE single-cell atlases (Tabula Muris pattern) [core]

- **What.** 2D nonlinear projection of single-cell expression, with cells colored by cluster / cell type / tissue / age, laid out as small multiples of the same projection with different colorings.
- **Link.** https://www.nature.com/articles/s41586-020-2496-1/figures/5
- **Design choices.**
  1. **Hold projection coordinates fixed across panels; only swap coloring** — reader learns the embedding once, then queries it with each panel.
  2. **Direct on-figure cluster labels** beat a 50-entry legend.
  3. **Categorical palette chosen for distinctness in dense regions**, with grey for "unannotated/other" so the labeled story dominates.
- **Use for.** Any learned 2D representation (embedding, latent space) with several metadata fields to overlay. Direct match to EEG-embedding scatter colored by site / age / diagnosis.
- **Risk.** UMAP/t-SNE distances are not metric; readers over-interpret cluster size, shape, between-cluster distance. Pair with a quantitative result that doesn't depend on the projection.

## 12. The Transformer architecture diagram ("Attention Is All You Need", 2017) [core]

- **What.** Encoder–decoder block diagram with stacked sub-layers, residual connections, attention boxes.
- **Link.** https://arxiv.org/abs/1706.03762 (Figure 1)
- **Design choices.**
  1. **Two stacks side by side** with arrows showing exactly which encoder output feeds which decoder cross-attention.
  2. **"Nx" annotation** abstracts repetition into one symbol.
  3. **Sub-blocks labeled by operation name only.**
  4. **"Add & Norm" pill** as a recurring visual identifier wraps each sub-block.
- **Use for.** Architecture / dataflow figures where the contribution is the wiring, not the inner machinery. Reuse the "one visual motif per recurring concept" pattern.
- **Risk.** Omits dimensions, masking, parameter counts — pairs with a table/pseudocode, not a substitute.

## 13. The Illustrated Transformer (Jay Alammar)

- **What.** Long blog-post sequence of figures building up the attention mechanism from "vector of values" to full multi-head attention with worked numbers.
- **Link.** https://jalammar.github.io/illustrated-transformer/
- **Design choices.**
  1. **Each figure adds one new idea on top of the previous** — visual style constant, only the new arrow/box is new information.
  2. **Concrete tensor shapes drawn as small grids of cells**, not abstract math.
  3. **Worked example with actual token strings** ("Thinking", "Machines") — abstract operations get a concrete substrate.
- **Use for.** Tutorial / supplementary explanatory figures. When the reader needs to be *taught*, prefer many incremental figures over one dense one.
- **Risk.** Inappropriate for a paper figure caption; ideal for blog, README, appendix.

## 14. The Pudding's "Film Dialogue, by Gender" (2016)

- **What.** Scrollytelling piece quantifying share of dialogue spoken by male vs. female characters across 2,000 screenplays.
- **Link.** https://pudding.cool/2017/03/film-dialogue/
- **Design choices.**
  1. **Headline summary bar at top** (overall split), then drill down into per-film small multiples.
  2. **Diverging horizontal bars centered at 50/50** — asymmetry is the deviation from center.
  3. **Sortable, searchable** — reader finds a film they care about.
- **Use for.** Large dataset, story is "the distribution is skewed in one direction." Lead with aggregate; let reader find their anchor in small multiples.
- **Risk.** Interactivity-dependent. Static version is much weaker.

## 15. The IPCC "burning embers" diagrams

- **What.** Column of vertical bars, one per "reason for concern," colored yellow → red → purple as global mean warming on the y-axis increases, summarizing expert risk elicitation.
- **Link.** https://www.ipcc.ch/report/ar6/syr/figures/summary-for-policymakers/figure-spm-4/
- **Design choices.**
  1. **Single shared y-axis** (warming in °C) — reader compares across categories at a given temperature.
  2. **Continuous color gradient instead of discrete risk levels** — honors actual elicitation.
  3. **Each ember bar is a category, not a quantity** — chart admits up front it's expert judgment on qualitative scale.
- **Use for.** Communicating expert-judgement / qualitative ordinal data without pretending it's continuous measurement.
- **Risk.** Reviewers attack subjectivity; defense is that the figure makes aggregation auditable rather than hiding it in text.

## 16. The NYT Election Night "needle" / probability gauge [core]

- **What.** Live needle on a dial running from one candidate to another, with shaded uncertainty bands, jittering as returns come in.
- **Link.** https://www.nytimes.com/elections/2016/forecast/president (archived)
- **Design choices.**
  1. **One scalar (probability) gets one of the strongest possible encodings (angular position of a literal needle).**
  2. **Live jitter visualizes simulation uncertainty** — motion is the uncertainty.
  3. **Named anchors at dial ends** replace numerical probability labels for non-technical readers.
- **Use for.** Communicating probability / forecast under uncertainty to a non-technical audience, especially live.
- **Risk.** Animating uncertainty makes it visceral, which is the goal and the side effect (the 2016 jitter was famously stressful).

## 17. The Allen Mouse Brain Atlas anatomical sections

- **What.** High-resolution coronal sections of mouse brain with ISH staining for individual genes, registered to a common 3D reference atlas.
- **Link.** https://mouse.brain-map.org
- **Design choices.**
  1. **Fixed anatomical reference (the atlas)** as substrate; every gene/experiment is an overlay on the same canvas.
  2. **Expression intensity = single sequential colormap on greyscale anatomy underlay** — figure-ground unambiguous.
  3. **Region boundaries as thin contour lines** rather than filled regions, so data shows through.
- **Use for.** Data overlaid on a spatial substrate (brain, genome track, geographic map). Lock substrate, vary overlay.

## 18. Bret Victor — "Up and Down the Ladder of Abstraction" (2011)

- **What.** Interactive essay where a simple car-driving simulation is progressively abstracted — same system shown as single trajectory, then many trajectories, then a phase portrait of parameters.
- **Link.** https://worrydream.com/LadderOfAbstraction/
- **Design choices.**
  1. **Each rung of the ladder is a new figure** showing the same system at higher abstraction.
  2. **Direct manipulation:** drag a slider, see dependent figures update simultaneously. Reader builds intuition by perturbing.
  3. **Verbal narration short, between figures** — figures carry the explanation.
- **Use for.** Building intuition for a parameterized system (hyperparameters, sweeps, optimization trajectories).
- **Risk.** Interactive only. Static version loses 90% of the pedagogical force.

---

## Patterns across the praised examples

Not universal — several famous figures (Nightingale, Gapminder, election needle) deliberately violate one to gain another.

1. **One figure carries one argument.** Climate stripes, Snow's map, slopegraph, burning embers — each summarizable in a single sentence.

2. **Strongest pre-attentive channel is reserved for the most important variable.** Position (Manhattan, slopegraph), area (coxcomb, bubble), angle (election needle), color saturation (climate stripes).

3. **Direct annotation beats legends.** Slopegraph endpoints, UMAP cluster labels, Snow's pump symbol, "Add & Norm" pills.

4. **Substrate is held still while data varies.** Allen Atlas, Tabula Muris small multiples, Bret Victor's ladder — the small-multiples principle generalized.

5. **Data shape drives chart type, not the reverse.** Manhattan plots exist because GWAS data has a "long ordered index, sparse peaks" shape. PAE matrices exist because protein domains form contiguous residue blocks. None is a default chart — each was invented because no existing chart fit the data's grain.

6. **Famous figures often break a "rule" on purpose, and pay for it.** Coxcombs exaggerate via area; climate stripes drop readout; election needle animates uncertainty. The pattern: a rule is broken when the figure's communicative goal directly demands it.

7. **Praised tutorial figures are sequences; praised paper figures are dense singles.** Different goals, different forms.

8. **Aesthetic decisions are also analytic decisions.** Hawkins's choice of baseline year determined what trend was visible. AlphaFold's single-hue PAE colormap prevents readers from inventing a categorical risk threshold. "Looks nice" and "argues correctly" are usually the same axis.
