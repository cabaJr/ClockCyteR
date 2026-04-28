# fct_circular_plot.R
utils::globalVariables(c("x", "y", "label", "x_circ", "y_circ", "group", "pt_alpha"))
# ggplot2 Rayleigh / circular plot for use inside the ClockCyteR Shiny app.
# Designed to be called from mod_analysis.R; returns a ggplot object and the
# angle-sorted point data.frame (used for plotly customdata injection).

# ---------------------------------------------------------------------------
# Internal: compute angle-sorted Cartesian positions with overlap jitter.
# Returns the rows of df_valid that have non-NA phases, sorted by angle,
# with x_circ / y_circ columns added.
# ---------------------------------------------------------------------------
.make_circ_pts <- function(df_valid, inside_plot) {
  ph    <- df_valid$ph_rad_plot
  ord   <- order(ph)
  df_s  <- df_valid[ord, , drop = FALSE]
  ph_s  <- ph[ord]
  ph_c  <- ph_s
  r     <- rep(0.99, length(ph_s))

  if (inside_plot && length(ph_s) > 1) {
    for (i in 2:length(ph_s)) {
      if (abs(ph_s[i] - ph_s[i - 1]) < 0.01) {
        r[i]    <- max(r[i - 1] - stats::runif(1, 8, 15) / 1000, 0.25)
        ph_c[i] <- ph_s[i] + stats::runif(1, 0, 1) / 15
      }
    }
  } else if (!inside_plot) {
    r <- rep(1, length(ph_s))
  }

  df_s$x_circ <- r * sin(ph_c)
  df_s$y_circ <- r * cos(ph_c)
  df_s
}

# ---------------------------------------------------------------------------
# Internal: empty circular frame (no data)
# ---------------------------------------------------------------------------
.empty_circ_plot <- function(plot_title = NULL) {
  th       <- seq(0, 2 * pi, length.out = 500)
  circ_df  <- data.frame(x = sin(th), y = cos(th))
  tick_rad <- (c(0, 6, 12, 18) / 24) * 2 * pi
  label_df <- data.frame(x = 1.18 * sin(tick_rad), y = 1.18 * cos(tick_rad),
                         label = c("0", "6", "12", "18"))
  ggplot2::ggplot() +
    ggplot2::geom_path(data = circ_df, ggplot2::aes(x, y),
                       linewidth = 0.8, colour = "black") +
    ggplot2::geom_text(data = label_df, ggplot2::aes(x, y, label = label),
                       size = 3.5, fontface = "bold") +
    ggplot2::coord_fixed(xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5)) +
    ggplot2::theme_void() +
    ggplot2::labs(title = plot_title)
}

# ---------------------------------------------------------------------------
#' Build a ggplot2 Rayleigh circular plot from a period-results data frame.
#'
#' @param df         data.frame with columns \code{id}, \code{group}, and the
#'   column named in \code{phase_col}.
#' @param phase_col  Name of the phase column to plot. \code{"phase_circ"}
#'   (circadian hours, 0-24) is converted to radians internally.
#'   \code{"phase_rad"} is used as-is.
#' @param selected_id Character ID of the currently highlighted point, or
#'   \code{NULL} for no selection.
#' @param align      Logical; shift phases so the circular mean lands at
#'   \code{align_to} h.
#' @param align_to   Target hour for mean after alignment (default 6 = CT6).
#' @param inside_plot Logical; place points inside the unit circle with
#'   radius/angle jitter for overlapping angles (TRUE) or on the rim (FALSE).
#' @param pt_size    Point size (\code{geom_point} size aesthetic).
#' @param pt_alpha   Base opacity for points (selected point) / all points
#'   when nothing is selected. Unselected points are dimmed to 0.15.
#' @param plot_title Optional title string.
#'
#' @return Named list:
#'   \item{plot}{A \code{ggplot} object.}
#'   \item{pts_df}{Angle-sorted data.frame used for plotly customdata injection.}
#'   \item{vec_len}{Mean resultant length (Rayleigh Rbar).}
#'   \item{variance}{Angular variance.}
#'   \item{meanP}{Circular mean phase (radians) computed before alignment.}
# ---------------------------------------------------------------------------
plot_rayleigh_app <- function(df,
                               phase_col   = "phase_circ",
                               selected_id = NULL,
                               align       = TRUE,
                               align_to    = 6,
                               inside_plot = TRUE,
                               pt_size     = 2,
                               pt_alpha    = 0.7,
                               plot_title  = NULL) {

  # ---- convert selected phase column to radians ----------------------------
  if (phase_col == "phase_circ") {
    df$ph_rad_plot <- (as.numeric(df[[phase_col]]) / 24) * 2 * pi
  } else {
    df$ph_rad_plot <- as.numeric(df[[phase_col]])
  }

  df_valid <- df[!is.na(df$ph_rad_plot), , drop = FALSE]

  if (nrow(df_valid) == 0) {
    return(list(plot = .empty_circ_plot(plot_title), pts_df = NULL,
                vec_len = NA, variance = NA, meanP = NA))
  }

  # ---- circular mean BEFORE alignment (returned as meanP) ------------------
  raw_circ  <- circular::circular(df_valid$ph_rad_plot, units = "radians",
                                   template = "none", modulo = "asis", zero = 0)
  real_mean <- as.numeric(
    circular::mean.circular(raw_circ, Rotation = "counter", na.rm = TRUE)
  )

  # ---- alignment -----------------------------------------------------------
  if (align) {
    df_valid$ph_rad_plot <- df_valid$ph_rad_plot + ((align_to / 24) * 2 * pi) - real_mean
  }

  # ---- circular stats ------------------------------------------------------
  al_circ    <- circular::circular(df_valid$ph_rad_plot, units = "radians",
                                    template = "clock24")
  RT         <- circular::rayleigh.test(al_circ)
  vec_len    <- as.numeric(RT$statistic[1])
  p_val      <- round(as.numeric(RT$p.value[1]), 3)
  variance   <- as.numeric(circular::angular.variance(al_circ, na.rm = TRUE))
  mean_phase <- as.numeric(
    circular::mean.circular(al_circ, Rotation = "counter", na.rm = TRUE)
  )

  # ---- angle-sorted Cartesian positions ------------------------------------
  pts_df <- .make_circ_pts(df_valid, inside_plot)

  # ---- per-point alpha based on selection ----------------------------------
  pts_df$pt_alpha <- if (is.null(selected_id)) {
    rep(pt_alpha, nrow(pts_df))
  } else {
    ifelse(as.character(pts_df$id) == selected_id, pt_alpha, 0.15)
  }

  # ---- structural elements -------------------------------------------------
  th       <- seq(0, 2 * pi, length.out = 500)
  circ_df  <- data.frame(x = sin(th), y = cos(th))

  tick_h   <- c(0, 6, 12, 18)
  tick_rad <- (tick_h / 24) * 2 * pi
  tick_df  <- data.frame(x0 = 0.92 * sin(tick_rad), y0 = 0.92 * cos(tick_rad),
                         x1 =        sin(tick_rad), y1 =        cos(tick_rad))
  label_df <- data.frame(x     = 1.18 * sin(tick_rad),
                         y     = 1.18 * cos(tick_rad),
                         label = as.character(tick_h))

  # ---- assemble plot -------------------------------------------------------
  p <- ggplot2::ggplot() +
    ggplot2::geom_path(data = circ_df, ggplot2::aes(x, y),
                       linewidth = 0.4, colour = "black") +
    ggplot2::geom_segment(data = tick_df,
                          ggplot2::aes(x = x0, y = y0, xend = x1, yend = y1),
                          linewidth = 0.4, colour = "black") +
    # Points: alpha is a per-row column; scale_alpha_identity() passes the
    # raw values through -- no spurious plotly traces because alpha is in
    # geom_point aes (not global aes), and colour = group gives one trace
    # per group which matches the customdata injection logic.
    ggplot2::geom_point(data = pts_df,
                        ggplot2::aes(x_circ, y_circ,
                                     colour = group,
                                     alpha  = pt_alpha),
                        size = pt_size, shape = 16) +
    ggplot2::scale_alpha_identity() +
    ggplot2::scale_colour_discrete(guide = "none") +
    ggplot2::geom_text(data = label_df,
                       ggplot2::aes(x, y, label = label),
                       size = 3.5, fontface = "bold") +
    ggplot2::coord_fixed(xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5)) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5, size = 11)) +
    ggplot2::labs(title = plot_title)

  list(plot = p, pts_df = pts_df, vec_len = vec_len,
       variance = variance, meanP = real_mean)
}
