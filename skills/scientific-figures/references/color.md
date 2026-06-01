# Color in Scientific Figures

This card covers: the three scale types and when to use each, colorblind safety, palette catalogue with hex codes, and how to think about per-project palettes.

## The three scale types

Picking the wrong one invents structure that isn't in the data.

### Qualitative (categorical)

For **unordered** groups — treatment vs control, model A vs B vs C, brain regions, cell types.

- Keep to **≤8 levels.** The Okabe-Ito palette tops out at 8 for a reason: distinguishability drops fast above this.
- Hues should be of equal salience — no one color should "win."
- If you have >8 categories, group them first (semantic merging) or use a `+ "other"` bin. If you truly need >8, faceting is better than packing more hues.

**Recommended palettes:**

- **Okabe-Ito 8** (Wong 2011) — the CB-safe default. Hex codes below.
- **ColorBrewer Set2** / **Dark2** — 3–8 levels each, CB-safe.
- **Paul Tol's** "Bright" and "Muted" qualitative palettes — alternatives.

### Sequential

For **ordered or quantitative** values — model accuracy, age, fold change magnitude, intensity.

- **Must be monotonic in luminance** — darker = more (or vice versa, but pick one).
- Single hue (e.g. all blues) or hue-progression that mimics natural gradients (dark blue → yellow).
- Verify monotonicity by converting the palette to grayscale: it should still read as a smooth ramp.

**Recommended palettes:**

- **viridis** family (`viridis`, `magma`, `inferno`, `plasma`, `cividis`) — perceptually uniform, CB-safe, monotonic. The default for most quantitative purposes. `cividis` is the most CB-accessible of the family.
- **ColorBrewer** single-hue ramps (`Blues`, `Greens`, `Reds`, `Greys`).
- **Crameri's scientific colour maps** (`batlow`, `lajolla`, `oslo`) — designed for scientific use, available in R/Python.

### Diverging

For values with a **meaningful midpoint** — log fold change around 1, correlation around 0, deviation from baseline.

- Two sequential ramps joined at a neutral midpoint (often white or pale yellow).
- The midpoint must be data-meaningful. If your data ranges from 0.6 to 0.9 with no zero or chance reference, a diverging palette will *invent* a midpoint.
- Pick endpoints with strong perceptual contrast and ideally pre-learned semantics (blue-cold/red-warm; red-bad/blue-good).

**Recommended palettes:**

- **ColorBrewer RdBu** — red-blue, the most-used diverging palette.
- **Crameri `vik` and `roma`** — CB-safer alternatives.
- **Wilke's brown-to-teal** — distinct from the red-blue defaults, also CB-safer.

## Colorblind safety

Wong (2011, *Nature Methods*, "Points of view: Color blindness"): **~8% of men and 0.5% of women of Northern European descent** have some form of color-vision deficiency. Most common: deuteranopia and protanopia (red-green confusion). The figure is lower in other populations but never negligible.

### Pairings to avoid

- **Red / green** — the famous one. Indistinguishable for ~5% of men.
- **Green / brown** — confused under deuteranopia/protanopia.
- **Green / orange** — confused under deuteranopia. *(Note: this is the user's `green_orange` palette family. It is borderline; consider it for slides where you control the audience but use a CB-safe alternative for manuscripts.)*
- **Blue / purple** — confused under tritanopia and at low saturation generally.
- **Pastel red / pastel green** — low saturation makes hue discrimination harder.

### Reasonably safe pairings

- **Blue / orange** — newsroom default for deviation; strong contrast under all CVD types.
- **Blue / yellow** — high luminance contrast.
- **Teal / orange** — slightly less safe than blue/orange but still good.
- **Black / orange** — strong luminance contrast; works under any CVD.
- **The Okabe-Ito 8** (full palette).

### Verifying

Use a CVD simulator before publication. Easy options:

- **Python:** `colorspacious` + `mpl-axes-aligner`, or the online `Color Oracle` tool.
- **R:** `colorspace::deutan()`, `colorspace::protan()`, `colorspace::tritan()` — apply to your palette and re-render.
- **Online:** https://www.color-blindness.com/coblis-color-blindness-simulator/
- **System-wide:** macOS Accessibility > Display > Color Filters; works for the whole screen.

## The Okabe-Ito palette (full hex codes)

The CB-safe categorical default. Memorize these; they are widely supported.

```
#000000  Black
#E69F00  Orange
#56B4E9  Sky blue
#009E73  Bluish green
#F0E442  Yellow
#0072B2  Blue
#D55E00  Vermillion
#CC79A7  Reddish purple
```

Available built-in:

- **R / ggplot2:** `scale_color_manual(values = palette.colors(palette = "Okabe-Ito"))` (built into base R since 4.0).
- **Python / matplotlib:** `seaborn.color_palette("colorblind")` is close; or the [`tol_colors`](https://personal.sron.nl/~pault/) package.

## Don't use rainbow / jet for quantitative data

Borland & Taylor (2007, *IEEE CG&A*) — the canonical reference. Three failures:

1. **Non-monotonic luminance.** The rainbow brightens through yellow and darkens at the ends — the eye reads brightness as magnitude, so the actual data magnitude is hidden.
2. **False sharp boundaries.** Hue transitions (e.g. green-to-yellow) are perceived as edges even where the data is smooth, inventing features.
3. **Degrades to noise** in grayscale printing and under CVD.

Crameri et al. (2020, *Nat Commun*) quantified that ~25% of recent geoscience papers still use rainbow. They offer the scientific colour-maps suite as a drop-in replacement.

**Counter-evidence (Ware et al. 2023):** rainbow can outperform luminance-only maps for *detail discrimination* tasks. Synthesis: use viridis for magnitude tasks; use rainbow only when local feature detection is the explicit goal and the audience is trained on the map (e.g. medical imaging where the convention is established).

## Don't use viridis as a categorical palette

Viridis is a *continuous gradient*. Sampling five colors from it for unordered groups makes readers see an order that isn't there. Use Okabe-Ito or ColorBrewer Set2/Dark2 for categories.

## Color as primary vs secondary encoding

Cleveland & McGill rank color saturation and hue near the *bottom* of the magnitude hierarchy. Color works best as a **secondary cue** layered on a strong primary encoding (position, length).

When color is the only carrier of a quantitative claim, perceptual error rises sharply. If you find yourself encoding the headline variable in color, ask: could position carry it instead?

## Per-project palettes

Every published paper deserves its own visual identity. The `figure_style.yaml` at the project root declares the palette; the skill defers to it. See `project-style.md` for the schema and loader code.

If a project palette is borderline for CB-safety (e.g. green+orange), the skill can flag this on demand but does **not** automatically substitute — the user owns the choice.

## Quick decision tree

```
Is the variable unordered (categories)?
├─ Yes → qualitative palette (Okabe-Ito, ColorBrewer Set2/Dark2)
└─ No, it's ordered
   ├─ Does it have a meaningful midpoint (zero, chance, baseline)?
   │  ├─ Yes → diverging (RdBu, vik, brown-to-teal)
   │  └─ No → sequential (viridis, cividis, single-hue ramp)
```

If you need both categorical + quantitative on the same chart (e.g. cluster identity + cluster density): give *position* to one and *color* to the other. Putting both in color compounds perceptual error.
