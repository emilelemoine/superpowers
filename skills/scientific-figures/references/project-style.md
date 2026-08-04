# Per-project Figure Style

Each project may declare its own visual identity in a `figure_style.yaml` at the project root. When present, this file is the source of truth — the skill defers to it for palette, font, sizes, and save conventions. Defaults from the skill apply only when no file is declared.

## Why per-project, not global

Every published paper deserves a distinctive visual identity. A skill that normalized all figures to one palette would defeat that. The skill's job is to enforce **principles** (CB-safety, scale-type matching, uncertainty representation, message-driven chart choice) across projects — not to enforce **palette**.

## File location

```
<project_root>/figure_style.yaml
```

Some projects may prefer to keep this hidden:

```
<project_root>/.figure_style.yaml
```

Both work. The skill checks both.

## Schema

```yaml
# figure_style.yaml — per-project figure conventions

font:
  family: "Roboto"                  # any installed font
  size_base: 9                      # axis tick labels, legend
  size_axis_label: 9                # x/y axis labels (defaults to base)
  size_title: 11                    # plot/subtitle (defaults to base * 1.2)
  size_strip: 10                    # facet strip text

sidecar:
  # Where the title/caption/methods prose goes, since it is never drawn on
  # the canvas (SKILL.md §6).
  #   "beside"  — <figure>.md next to the image (default)
  #   "shared"  — one markdown file per figure directory, section per figure
  #   "none"    — the project routes prose elsewhere (a report, a manuscript);
  #               the skill then asks where rather than assuming a file
  location: "beside"
  path: null            # for "shared": the file, relative to the figure dir
  state_finding: true   # false = descriptive only; the claim lives in the paper

palette:
  # Qualitative / categorical — for unordered groups
  categorical:
    - "#63BF9E"  # primary
    - "#F28A2E"  # secondary
    - "#19727A"  # tertiary
    - "#296073"  # quaternary (drop as needed)

  # Sequential — for ordered/quantitative values
  # Either a named colormap or a hex list (the list is interpolated)
  sequential: "viridis"
  # or:
  # sequential:
  #   - "#1D2671"
  #   - "#C33764"

  # Diverging — for values with a meaningful midpoint
  diverging:
    - "#296073"   # negative
    - "#FFFFFF"   # midpoint
    - "#7B3000"   # positive

  # Optional: a CB-safe categorical fallback the skill can suggest if asked
  categorical_cb_safe:
    - "#0072B2"   # blue
    - "#D55E00"   # vermillion
    - "#009E73"   # bluish green
    - "#CC79A7"   # reddish purple

reference_lines:
  color: "#BFBBB8"
  linetype: "dashed"
  alpha: 0.4
  linewidth: 0.4

# Style for inferential overlays (CI ribbons, error bars)
uncertainty:
  ribbon_alpha: 0.2
  errorbar_capsize: 3
  errorbar_linewidth: 1.0
  point_size: 4

save:
  formats: ["png", "pdf"]            # add "svg" if you hand-edit
  dpi: 400                            # for raster
  pdf_device: "cairo_pdf"             # R-specific; ignored in Python
  background: "white"                 # never transparent

# Default figure dimensions in inches, by use case
dimensions:
  single_column: [3.5, 2.5]           # journal single column
  one_half_column: [5.0, 3.5]
  double_column: [7.0, 4.0]
  slide_16_9: [13.3, 7.5]
  poster_panel: [10.0, 6.0]

# Optional: when true, skill flags palettes that aren't CB-safe.
# Turn off if you've made a deliberate choice and don't want the nudge.
cb_safety_check: true

# Optional: human-readable notes about palette rationale.
# Useful for "why these colors?" reviewer questions later.
notes: |
  Palette derived from project logo. Green-orange pairing is borderline
  for deuteranopia; for the manuscript figures (Fig 3–5) we verified
  distinguishability in deuteranopia/protanopia simulation via colorspace::deutan.
```

All fields are optional. Missing fields fall back to skill defaults.

## Loading the style — R

```r
library(yaml)
library(here)

load_project_style <- function() {
  paths <- c(here("figure_style.yaml"), here(".figure_style.yaml"))
  path  <- paths[file.exists(paths)][1]
  if (is.na(path)) return(list())
  yaml::read_yaml(path)
}

style <- load_project_style()

# Use:
categorical_palette <- style$palette$categorical
font_family         <- style$font$family %||% "Roboto"
```

(`%||%` is rlang's null-coalesce; or write `if (is.null(x)) default else x`.)

## Loading the style — Python

```python
from pathlib import Path
import yaml

def load_project_style(project_root: Path = None) -> dict:
    if project_root is None:
        project_root = Path.cwd()
    for name in ("figure_style.yaml", ".figure_style.yaml"):
        path = project_root / name
        if path.exists():
            with open(path) as f:
                return yaml.safe_load(f) or {}
    return {}

style = load_project_style()
categorical = style.get("palette", {}).get("categorical",
    ["#63BF9E", "#F28A2E", "#19727A"])
```

## Default fallbacks (when no `figure_style.yaml` exists)

The skill uses these — they are intentionally generic and CB-safe:

```yaml
font:
  family: "Roboto"        # if installed; else system sans
  size_base: 9
palette:
  categorical: ["#0072B2", "#D55E00", "#009E73", "#CC79A7",
                "#F0E442", "#56B4E9", "#E69F00", "#000000"]  # Okabe-Ito
  sequential: "viridis"
  diverging:  ["#2166AC", "#FFFFFF", "#B2182B"]              # ColorBrewer RdBu endpoints
reference_lines:
  color: "#BFBBB8"
  linetype: "dashed"
  alpha: 0.4
save:
  formats: ["png", "pdf"]
  dpi: 400
  background: "white"
```

## When the skill should ask before adopting defaults

If the user is making figures for what's clearly a publication context (a `paper/`, `manuscript/`, or `Article/` directory; tex files in the repo; explicit mention of submission), and no `figure_style.yaml` exists, the skill should ask:

> *"I don't see a `figure_style.yaml` in this project. Want me to (a) create one with sensible defaults you can edit, (b) use defaults without committing them, or (c) tell me the palette/font inline?"*

Don't ask for one-off exploratory plots — the cost outweighs the benefit.

## Example: the `dl_eeg` project palette as a `figure_style.yaml`

For reference — this is what the user's `dl_eeg` paper would have looked like if it had used this convention from the start:

```yaml
font:
  family: "Roboto"
  size_base: 9

palette:
  categorical:
    - "#63BF9E"  # teal — DeepEpilepsy
    - "#F28A2E"  # orange — IED
    - "#19727A"  # dark teal — DeepEpilepsy + IED
  sequential: "viridis"
  diverging: ["#296073", "#FFFFFF", "#7B3000"]
  categorical_alt_3:
    - "#296073"
    - "#F49432"
    - "#7B3000"
  categorical_alt_4:
    - "#296073"
    - "#7FB3C8"
    - "#F49432"
    - "#7B3000"

reference_lines:
  color: "#BFBBB8"
  linetype: "dashed"
  alpha: 0.4

save:
  formats: ["png", "pdf", "svg"]
  dpi: 400
  pdf_device: "cairo_pdf"
  background: "white"

dimensions:
  single_column: [4.5, 3.0]
  double_column: [8.5, 4.5]

cb_safety_check: true   # the green-orange pairing is borderline; we verified

notes: |
  Palette derived from project visual identity. The green/orange (#63BF9E/#F28A2E)
  pairing is borderline for deuteranopia; distinguishability was verified in
  colorspace::deutan() simulation before publication. For maximum CB safety
  on supplementary or follow-up figures, fall back to the Okabe-Ito categorical
  default.
```

The user can copy `assets/project_style.example.yaml` and fill it in.
