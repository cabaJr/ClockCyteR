# ClockCyteR — Development Plan

> **Status legend:** ✅ Implemented · 🔲 Pending · ⚠️ Partially done

------------------------------------------------------------------------

------------------------------------------------------------------------

# Part 1 — Pre-Release Improvement Plan

## Context

ClockCyteR is a Golem-based Shiny app for circadian rhythm analysis of
Incucyte microscope data. Before public release on GitHub, it needs: a
better README, a pkgdown documentation site on GitHub Pages, bug fixes
for known crashes, and incremental feature improvements.

------------------------------------------------------------------------

## Tier 1 — Blockers

### ✅ 1. Fix DESCRIPTION

All fixes applied: - `testthat` and `usethis` are in `Suggests:` only
(not `Imports:`) - No `Remotes:` block (was a circular self-reference) -
`URL:` and `BugReports:` point to correct GitHub URLs (no `.git`
suffix) - Version bumped to `0.1.0` - All required imports present:
`lubridate`, `zeitgebr`, `ggetho`, `behavr`, `circular`, etc.

**Verify:** `devtools::check()`

------------------------------------------------------------------------

### ✅ 2. Bug Fix — Detrend with no outliers crashes on plot

**File:** `R/fct_Annotate.R`, `R/fct_R6_clean_data.R`

Both fixes applied: - `xbreaks` now uses
`seq(floor(min(df$timevar)), ceiling(max(df$timevar)), by = 24)` — no
longer tied to row count - Guard in `detrend()` skips processing when
all values are NA after outlier removal

------------------------------------------------------------------------

### ✅ 3. Bug Fix — Time \> 240h plot clipping

**File:** `R/mod_analysis.R`, `R/fct_Annotate.R`

Fixed on two fronts: - Single `observeEvent(input$TsPlot)` block reads
time range from `rv$t_min` / `rv$t_max` (not stale
`input$xlimits_tsplot`) - `plot_Timeserie()` in `fct_Annotate.R` has
`use_days <- max(df$timevar) > 240` logic that switches axis units and
tick spacing automatically

------------------------------------------------------------------------

### ✅ 4. Bug Fix — Period method crash with single-value group

**File:** `R/fct_Custom_tables.R`

All five periodogram branches (`chi_sq`, `ac`, `ls`, `fourier`, `cwt`)
now use [`as.double()`](https://rdrr.io/r/base/double.html) cast and a
full-ID defensive merge:

``` r
summary$period <- as.double(summary$period)
summary2 <- merge(data.table(id = all_ids), summary, by = "id", all.x = TRUE)
```

This prevents `data.table` rbind failures when `find_peaks()` returns
zero rows for a group.

------------------------------------------------------------------------

### ✅ 5. Bug Fix — Multi-image label parsing (`"A1, Image 1"` format)

**File:** `R/fct_R6_clean_data.R`

Fallback parser added inside `extract_components()` for the simpler
Incucyte format (no parentheses, no group). Download filename guard
(`nzchar(img_number)`) also in place.

------------------------------------------------------------------------

### ⚠️ 6. Rewrite README.Rmd

**File:** `README.Rmd`

Written and structured: hex logo, lifecycle/CI/last-commit badges,
overview paragraph, installation (CRAN + non-CRAN rethomics
dependencies), usage, workflow walkthrough. Placeholder comments exist
for composite screenshots.

**Still needed:** 3 screenshots from the user (save to
`man/figures/`): - `screenshot_input.png` — Input tab after loading
`Test_data.txt` - `screenshot_analysis.png` — Analysis tab with
timeseries plotted - `screenshot_period.png` — Period results table +
scatter plots

After adding screenshots run: `devtools::build_readme()`

------------------------------------------------------------------------

### ✅ 7. Add pkgdown + GitHub Pages workflow

**File:** `.github/workflows/pkgdown.yaml`

Workflow exists and is configured. After first CI push: go to repo
`Settings > Pages`, set source to `gh-pages` branch, `/ (root)`. Add
pkgdown badge to README once site URL is confirmed.

------------------------------------------------------------------------

## Tier 2 — High-Value Features

### ⚠️ 8. Resolve residual plotly warnings

**File:** `R/mod_analysis.R`

**A. Startup event-registration warnings** —
[`suppressWarnings()`](https://rdrr.io/r/base/warning.html) applied as
workaround. Root cause: `event_data()` observers fire before
`renderPlotly` runs (box was `collapsed = TRUE`). Box is no longer
collapsed; box is now fully hidden via
[`shinyjs::hidden()`](https://rdrr.io/pkg/shinyjs/man/hidden.html) until
period analysis runs, so this may be partially resolved. Full fix: use
`outputOptions(output, "scatter_period", suspendWhenHidden = FALSE)` so
`event_register()` fires even when the box is hidden.

**B. “No trace type specified” warnings** — Empty-trace filter
(`Filter(function(tr) length(tr$x) > 0 || length(tr$y) > 0, ...)`)
applied but warning persists. Investigate with `str(plt$x$data)` to
identify which ggplotly layer produces the empty trace.

------------------------------------------------------------------------

### ✅ 9. Interactive Plotly timeseries

**Files:** `R/fct_Annotate.R`, `R/mod_analysis.R`

Timeseries is rendered via
[`plotly::ggplotly()`](https://rdrr.io/pkg/plotly/man/ggplotly.html) in
`output$TSplot_out`. Hover text is injected from the `hover_text` column
stored in the layer data frame
(`plotly::style(plt, text = layer_data$hover_text, hoverinfo = "text")`).

------------------------------------------------------------------------

### ✅ 10. Linked scatter plots for period / amplitude / RAE / phase

**File:** `R/mod_analysis.R`

All four plots live side-by-side in box3_25 (“Period analysis plots”): -
Three scatter plots (period, amplitude, RAE) + Rayleigh circular plot
(phase) - Cross-plot highlighting via `rv$selected_id`: clicking any
point dims unselected points in all three scatter plots via
`plotlyProxy` / `restyle`; circular plot re-renders with per-point alpha
baked in - Single-click selects / deselects; double-click anywhere
clears selection - `customdata` injection carries sample ID through
ggplotly for reliable click detection - Phase variable selector
(`phase_circ`, `phase_rad`, `phase_abs`) below the Rayleigh plot

------------------------------------------------------------------------

### ✅ 11. Days instead of hours for long experiments

**File:** `R/fct_Annotate.R`

`use_days <- max(df$timevar, na.rm = TRUE) > 240` switches axis label,
breaks, and minor-breaks automatically when recording exceeds 10 days.

------------------------------------------------------------------------

### ✅ 12. Dynamic dropdown choices

**File:** `R/mod_analysis.R`

`updatePickerInput()` called in both `TsDetrend` and `remove_out`
observers to add `"detrended"` / `"cleaned"` to `plot_this` and
`period_data` pickers only after those datasets are created.

------------------------------------------------------------------------

### 🔲 13. Improve test coverage

**New files:** `tests/testthat/test-fct_R6_clean_data.R`,
`tests/testthat/test-fct_data_loader.R`

Key tests to add: - `extract_components()` with all three label
formats - Regression test: `detrend()` with no outliers does not crash -
End-to-end load test using `inst/extData/Test_data.txt`

``` r
devtools::test()
covr::package_coverage()
```

------------------------------------------------------------------------

## Tier 3 — Refactoring (Long-Term)

| Status | Item                  | File(s)                                     | Description                                                                                                                                                                                               |
|--------|-----------------------|---------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ✅     | Phase / Rayleigh plot | `R/fct_circular_plot.R`, `R/mod_analysis.R` | `plot_rayleigh_app()` implemented in `fct_circular_plot.R`; rendered as interactive plotly in box3_25 with group colouring, per-point alpha, and customdata injection                                     |
| 🔲     | Processing refactor   | New `R/fct_processing.R`                    | Move `detrend()`, `remove_outliers()`, `normalize_vals()` to standalone pure functions; R6 methods call them                                                                                              |
| 🔲     | Plot navigator module | `R/mod_analysis.R`                          | Extract first/prev/next/last navigation into `mod_plot_navigator`                                                                                                                                         |
| 🔲     | Fix idList reactive   | `R/mod_input_data.R`, `R/app_server.R`      | Case mismatch `listsample` vs `listSamples`; wire reactive to YourData module                                                                                                                             |
| 🔲     | Messages system       | New `R/fct_messages.R`                      | Implement `Messages` R6 class wrapping `showNotification()` (stub already commented in `app_server.R`)                                                                                                    |
| 🔲     | Help button modals    | All modules                                 | Wire up all HELP buttons with [`shiny::showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html). Reference: MaceR app (`Documents/GitHub/MaceR`) — companion app sharing the same Golem infrastructure |

------------------------------------------------------------------------

## Verification Checklist

``` r
devtools::check()        # 0 errors, 0 warnings
devtools::test()         # all tests pass
devtools::build_readme() # README renders with screenshots
pkgdown::build_site()    # docs site builds locally
clockcyteR::run_app()    # smoke test: load Test_data.txt, plot, detrend, period analysis, download
```

------------------------------------------------------------------------

## Documentation — Incucyte Analysis Guide

Write a step-by-step guide (vignette or pkgdown article) covering
Incucyte experiment setup and data export for ClockCyteR.

**Content:** 1. Experiment setup — plate layout, imaging schedule,
channel configuration 2. Defining analysis regions — ROIs in Vessel View
/ Confluence module 3. Metric selection — Integrated Intensity vs
Confluence % 4. Exporting data — tab-delimited `.txt`, 6 header rows,
one column per well/image 5. Naming conventions —
`"Group (Well), Image N"` and `"Well, Image N"` formats 6. Annotated
Incucyte screenshots at each step

**Suggested location:** `vignettes/incucyte_guide.Rmd`

------------------------------------------------------------------------

------------------------------------------------------------------------

# Part 2 — UX Improvement Plan

> **Philosophy:** progressive disclosure · immediate specific feedback ·
> visual consistency

------------------------------------------------------------------------

## Tier 1 — Quick wins (all ✅)

| \#  | Item                                                                                    | Status | Files                                |
|-----|-----------------------------------------------------------------------------------------|--------|--------------------------------------|
| 1   | `showNotification()` after: data load, Plot, Detrend, Remove outliers, Period analysis  | ✅     | `mod_analysis.R`, `mod_input_data.R` |
| 2   | `TsNormalize` disabled; “smooth”/“smooth detrended” removed from initial picker choices | ✅     | `mod_analysis.R`                     |
| 3   | YourData tab hidden (sidebar + body)                                                    | ✅     | `app_ui.R`                           |
| 4   | Nav buttons replaced with icon-only buttons (`|<` `<` `>` `>|`) + `firstBtn` observer   | ✅     | `mod_analysis.R`                     |
| 5   | Sidebar `collapsed = FALSE`                                                             | ✅     | `app_ui.R`                           |

------------------------------------------------------------------------

## Tier 2 — Medium effort (all ✅)

| \#  | Item                                                                                                                                                                           | Status | Files            |
|-----|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|------------------|
| 6   | “Timeserie plotting” + “Data Manipulation” merged into single “Timeseries” box with `hr()` separator                                                                           | ✅     | `mod_analysis.R` |
| 7   | Download buttons labelled with `icon("download")` + descriptor (“Timeseries plots”, “Period table (.csv)”, “Analysis plots (.zip)”)                                            | ✅     | `mod_analysis.R` |
| 8   | `period_timefr` slider auto-corrects to actual data range at start of `period_an` observer                                                                                     | ✅     | `mod_analysis.R` |
| 9   | “Plots” box status fixed to `"primary"`; “Period Analysis” box flips to `box-success` via [`shinyjs::runjs()`](https://rdrr.io/pkg/shinyjs/man/runjs.html) when results appear | ✅     | `mod_analysis.R` |

------------------------------------------------------------------------

## Branding & landing page (all ✅)

| \#  | Item                                                                                                                                             | Status | Files                                 |
|-----|--------------------------------------------------------------------------------------------------------------------------------------------------|--------|---------------------------------------|
| 10  | Header re-enabled; title uses `logo-mini` / `logo-lg` AdminLTE classes (icon only when collapsed, icon + “ClockCyteR” when expanded); typo fixed | ✅     | `app_ui.R`, `inst/app/www/custom.css` |
| 11  | Landing page redesigned: hex logo, tagline, 3-step workflow cards, green CTA button, footer                                                      | ✅     | `mod_landing_page.R`                  |

------------------------------------------------------------------------

## Tier 3 — Deferred

- 🔲 Complete YourData module (server logic uncommented, dropdown
  reactive to loaded data)
- 🔲 Help modals — wire up all Help buttons with
  [`shiny::showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html)
- 🔲 Input validation — warn when selected data (e.g. “cleaned”) doesn’t
  exist before running period analysis

------------------------------------------------------------------------

------------------------------------------------------------------------

# Part 3 — Analysis Enhancements

## ✅ 1. Progress indicator for long operations

**Files:** `R/mod_analysis.R`

`withProgress` + `incProgress` added to three observers: - `TsDetrend` —
per-sample progress (1/n per sample) - `remove_out` — per-sample
progress (1/n per sample) - `period_an` — three-step progress (preparing
data → computing periods → rendering)

------------------------------------------------------------------------

## ✅ 2. Group-level summary statistics table

**Files:** `R/mod_analysis.R`

`compute_group_summary()` helper computes per-group: N, Period mean ±
SD, Amplitude mean ± SD, RAE mean ± SD, Phase mean ± SD (h), Rayleigh R̄,
Rayleigh p (using `circular` package).

Rendered as `DT::renderDT(output$summary_table)` in a hidden div
(`summary_stats_div`) inside box3_25, shown after period analysis.
Download button `Dl_summary` exports CSV. Table updates dynamically when
samples are excluded.

------------------------------------------------------------------------

## ✅ 3. FFT-NLLS fitted curve overlay on timeseries

**File:** `R/mod_analysis.R`

`prettyToggle(ns("show_fit"), ...)` in box3_1 nav row, hidden until
FFT-NLLS runs. When toggled on, `output$TSplot_out` overlays the
reconstructed sinusoid:

``` r
fitted <- offset + amplitude * sin(2 * pi * t_seq / period + phase_rad)
```

Parameters matched by `sampleName == fft_data$id`. Overlay rendered as a
dashed red `geom_line` before `ggplotly()` conversion. Toggle hidden for
non-FFT-NLLS methods.

------------------------------------------------------------------------

## ✅ 4. Sample exclusion

**File:** `R/mod_analysis.R`

- `rv$excluded_ids` (character vector, initially empty) tracks excluded
  sample IDs
- `fft_data_display` reactive filters `rv$fft_data` by exclusions — all
  scatter plots, circular plot, summary table, and download handlers use
  this reactive
- “Exclude selected” button moves `rv$selected_id` into
  `rv$excluded_ids`; “Restore all” clears it
- Exclusion count shown as text next to buttons
- Period table rendered reactively from `rv$period_tbl`; excluded rows
  shown with strikethrough + grey via
  [`DT::formatStyle`](https://rdrr.io/pkg/DT/man/formatCurrency.html)
- Controls shown in hidden div `excl_controls` (revealed after first
  period analysis)

------------------------------------------------------------------------

------------------------------------------------------------------------

# Part 4 — Feature Plan: Multi-Channel Support

## Context

The Incucyte records up to three simultaneous channels (green, red,
brightfield). ClockCyteR currently parses only `ch1`. Supporting a
second channel unlocks cross-channel comparisons central to many
circadian experiments (e.g. Bmal1-GFP + Per2-mCherry in the same
sample).

------------------------------------------------------------------------

## 🔲 Stage 1 — Data layer

**1a.** Detect available channels on load and store as metadata on the
`CleanData` R6 object. **Files:** `R/fct_data_loader.R`,
`R/fct_R6_clean_data.R`

**1b.** Extend `CleanData` to hold `ch2` alongside `ch1`. Processing
methods accept a `channel` argument. **File:** `R/fct_R6_clean_data.R`

**1c.** Channel selector `pickerInput` in the Input tab after upload.
**File:** `R/mod_input_data.R`

------------------------------------------------------------------------

## 🔲 Stage 2 — Single-channel analysis with channel switcher

**2a.** `channel_sel` picker in “Timeseries” box. All existing
operations use the selected channel. **File:** `R/mod_analysis.R`

**2b.** Per-channel processed data storage (`ch1_detrended`,
`ch2_detrended`, etc.) so switching channels does not discard results
from the other. **File:** `R/fct_R6_clean_data.R`

------------------------------------------------------------------------

## 🔲 Stage 3 — Dual-channel comparison visualisations

New **“Channel comparison”** box, revealed only when ≥ 2 channels are
loaded.

| Plot                      | Description                                                                                        |
|---------------------------|----------------------------------------------------------------------------------------------------|
| Overlay timeseries        | Dual-axis (or normalised) timeseries showing both channels per sample                              |
| Period comparison scatter | Paired jitter of period estimates per channel, matched samples connected by line                   |
| Amplitude ratio           | `amplitude_ch2 / amplitude_ch1` per group — captures relative reporter expression                  |
| Phase difference Δφ       | `phase_ch2 − phase_ch1` as a Rayleigh circular plot; Δφ is independent of absolute phase alignment |
| Cross-channel correlation | `ch1` vs `ch2` signal scatter coloured by time                                                     |

**Implementation notes:** - Backwards compatible: if only one channel
present, all existing behaviour is unchanged - Extend `fft` output in
`new_compute_per()` to include `period_ch2`, `amplitude_ch2`,
`phase_ch2` - `Dl_scatter` download handler extended to include
comparison plots when available - **Critical files:**
`R/fct_data_loader.R`, `R/fct_R6_clean_data.R`, `R/fct_Custom_tables.R`,
`R/fct_Annotate.R`, `R/mod_input_data.R`, `R/mod_analysis.R`

------------------------------------------------------------------------

*This file lives in the repo root alongside `dev_history.R` and
`Improvement_list.R`.*
