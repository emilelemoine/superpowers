# theme_paper.R — opt-in ggplot2 theme for publication figures.
#
# Source this file in an analysis script:
#   source("path/to/theme_paper.R")
#   p + theme_paper()
#
# Designed to work with the scientific-figures skill conventions.
# Override per-project via figure_style.yaml; see references/project-style.md.

library(ggplot2)

# ---- Optional font registration --------------------------------------------
# If Roboto is the project font and showtext is installed, register it.
# Comment out if your project font is already available system-wide.

if (requireNamespace("showtext", quietly = TRUE)) {
  showtext::showtext_auto()
  if (requireNamespace("sysfonts", quietly = TRUE) &&
      !"Roboto" %in% sysfonts::font_families()) {
    sysfonts::font_add_google("Roboto", "Roboto")
  }
}

# ---- Theme ------------------------------------------------------------------

theme_paper <- function(base_size = 9, font = "Roboto") {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      text             = ggplot2::element_text(family = font),
      panel.grid.major = ggplot2::element_line(colour = "#F2EEEB",
                                                linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      strip.text       = ggplot2::element_text(size = ggplot2::rel(1.1),
                                                colour = "#1A242F"),
      plot.title       = ggplot2::element_text(size = ggplot2::rel(1.2),
                                                face = "plain"),
      legend.title     = ggplot2::element_blank()
    )
}

# ---- Save with white background --------------------------------------------
# ggplot2::ggsave defaults to transparent, which renders unpredictably in
# slide decks and PDF viewers. This wrapper forces white.

ggsave_white <- function(..., bg = "white") {
  ggplot2::ggsave(..., bg = bg)
}

# Optionally shadow the global ggsave with the white-bg version:
# ggsave <- ggsave_white

# ---- Default reference-line aesthetics -------------------------------------
# Use as: p + geom_hline(yintercept = 0.5, !!!ref_line_args)
# Or: do.call(geom_hline, c(list(yintercept = 0.5), ref_line_args))

ref_line_args <- list(
  linetype  = "dashed",
  colour    = "#BFBBB8",
  alpha     = 0.4,
  linewidth = 0.4
)

# ---- Okabe-Ito palette (CB-safe fallback) ----------------------------------

okabe_ito <- c(
  "#000000",  # black
  "#E69F00",  # orange
  "#56B4E9",  # sky blue
  "#009E73",  # bluish green
  "#F0E442",  # yellow
  "#0072B2",  # blue
  "#D55E00",  # vermillion
  "#CC79A7"   # reddish purple
)

# ---- Loader for figure_style.yaml ------------------------------------------
# Returns a list with palette / font / save settings, or empty list if absent.

load_project_style <- function(root = getwd()) {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    warning("yaml package not installed; skipping figure_style.yaml")
    return(list())
  }
  candidates <- c(file.path(root, "figure_style.yaml"),
                  file.path(root, ".figure_style.yaml"))
  for (path in candidates) {
    if (file.exists(path)) {
      return(yaml::read_yaml(path))
    }
  }
  list()
}
