#' analysis UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
utils::globalVariables(c("group", "timevar", ".data", "fitted"))
mod_analysis_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(div(style = ""),
             # shinydashboard::box(title= "Timeserie plotting", id = "box3_0", width = 12, solidHeader = TRUE, collapsible = TRUE, status = "primary",
             #                     fluidRow(column(width = 8,
             #                                     # shinyWidgets::prettyRadioButtons(inputId = ns("timeValues"), label = "Do you want to plot real time or hours?", choices = c("Hours", "Real time"), inline = TRUE, selected = "Hours")
             #                     ),
             #                     column(width = 3, offset = 1,
             #                            actionButton(ns('help3_0'), label = 'Help',
             #                                         style="color: #fff; background-color: #1e690c; border-color: #1e530c;")
             #                            )
             #                     ),
             #                     fluidRow(column(width = 8,
             #                                     # shinyWidgets::prettyCheckboxGroup(inputId = ns("datasets"), label = "Select the what channels to plot:",
             #                                                                       # choiceNames = c("Channel 1", "Channel 2", "Channel 3"),
             #                                                                       # choiceValues = c("ch1", "ch2", "ch3"),
             #                                                                       # inline = TRUE, width = "85%"),
             #                                    # actionButton(ns("subset_plot"), label = "Subset Plot"),
             #                                    shiny::sliderInput(inputId = ns("xlimits_tsplot"), label = "Select time window to visualize", min = 0, max = 200, step = 0.5, value = c(0, 200), dragRange = TRUE), #TODO add update val with min max values based on real data
             #                                     ),
             #                              column(width = 4,
             #                                     actionButton(inputId = ns("TsPlot"), label = "Plot"),
                                                 # shinyWidgets::pickerInput(inputId = ns("plot_this"), label = "Select data to plot",
                                                 #                           choices = c("original", "detrended", "cleaned"),
                                                 #                           selected = "original", multiple = FALSE),
             #                                     downloadButton(outputId = ns("Dl_plots"), label = "Download"),
             #                                     downloadButton(outputId = ns("Dl_data"), label = "Download data")
             #                                     ),
             #                              column(width = 4,
             #                                     actionButton(inputId = ns("TsDetrend"), label = "Detrend"),
                                                 # shinyWidgets::pickerInput(inputId = ns("detr_opt"), label = "Select detrending method",
                                                 #                           choices = c("linear", "cubic"), selected = "linear", multiple = FALSE)
             #                              ),
             #                              column(width = 4,
             #                                     actionButton(inputId = ns("TsNormalize"), label = "Normalize"),
             #                                     )
             #                              ),
             #
             # ),
             shinydashboard::box(title = "Timeseries", id = "box3_0", width = 12, solidHeader = TRUE, collapsible = TRUE, status = "primary",
                                 fluidRow(column(width = 8),
                                          column(width = 4,
                                                 actionButton(ns('help3_0'), label = 'Help',
                                                              style = "color: #fff; background-color: #1e690c; border-color: #1e530c;")
                                          )
                                 ),
                                 fluidRow(
                                   column(width = 6,
                                          shiny::sliderInput(inputId = ns("xlimits_tsplot"),
                                                             label = "Select time window to visualize",
                                                             min = 0, max = 200, step = 0.5, value = c(0, 200),
                                                             dragRange = TRUE)
                                   ),
                                   column(width = 3,
                                          shinyWidgets::pickerInput(inputId = ns("plot_this"), label = "Select data to plot",
                                                                    choices = c("original", "detrended", "cleaned"),
                                                                    selected = "original", multiple = FALSE)
                                   ),
                                   column(width = 3,
                                          actionButton(inputId = ns("TsPlot"), label = "Plot")
                                   )
                                 ),
                                 shiny::hr(),
                                 fluidRow(
                                   column(width = 4, actionButton(inputId = ns("TsDetrend"), label = "Detrend")),
                                   column(width = 4, actionButton(ns("remove_out"), "Remove outliers")),
                                   column(width = 4, shinyjs::disabled(actionButton(inputId = ns("TsNormalize"), label = "Normalize")))
                                 ),
                                 fluidRow(
                                   column(width = 4,
                                          shinyWidgets::pickerInput(inputId = ns("detr_opt"), label = "Select detrending method",
                                                                    choices = c("linear", "cubic"), selected = "linear", multiple = FALSE)
                                   ),
                                   column(width = 4),
                                   column(width = 4)
                                 )
             ),
             shinydashboard::box(title= "Plots", id = "box3_1", width = 12, solidHeader = TRUE, collapsible = TRUE, status = "primary",
                                 shinyjs::hidden(div(id = ns("ts_plot_output"),
                                   fluidRow(
                                     column(width = 6,
                                       actionButton(ns("firstBtn"), NULL, icon = icon("backward-step")),
                                       actionButton(ns("prevBtn"),  NULL, icon = icon("chevron-left")),
                                       actionButton(ns("nextBtn"),  NULL, icon = icon("chevron-right")),
                                       actionButton(ns("lastBtn"),  NULL, icon = icon("forward-step")),
                                       shinyjs::hidden(div(id = ns("show_fit_div"),
                                         style = "display: inline-block; margin-left: 12px; vertical-align: middle;",
                                         shinyWidgets::prettyToggle(
                                           inputId   = ns("show_fit"),
                                           label_on  = "Hide fit", label_off = "Show fit",
                                           icon_on   = icon("eye-slash"), icon_off = icon("eye"),
                                           status_on = "default", status_off = "default",
                                           value     = FALSE
                                         )
                                       ))
                                     ),
                                     column(width = 3, offset = 1,
                                       downloadButton(outputId = ns("Dl_plots"),
                                                      label = tagList(" Timeseries plots"))
                                     )
                                   ),
                                   fluidRow(column(width = 12,
                                     plotly::plotlyOutput(ns("TSplot_out"))
                                   ))
                                 ))
                                 ),
             shinydashboard::box(title= "Period Analysis", id = "box3_2", width = 12, solidHeader = TRUE, collapsible = TRUE, status = "primary",
                                 fluidRow(column(width = 12,
                                                 shinyWidgets::pickerInput(inputId = ns("period_data"), label = "Select data to use for period analysis",
                                                                           choices = c("original", "detrended", "cleaned"),
                                                                           selected = "original", multiple = FALSE),
                                                 actionButton(ns("period_an"), "launch period analysis"),
                                                 shinyjs::disabled(downloadButton(outputId = ns("Dl_period"),
                                                                                   label = tagList(" Period table (.csv)")))
                                                 )
                                          ),
                                 fluidRow(column(width = 12,
                                                 shiny::sliderInput(inputId = ns("period_timefr"), label = "Select time window to use for period analysis", min = 0, max = 1000, step = 0.5, value = c(0, 1000), dragRange = TRUE),
                                                 shinyWidgets::pickerInput(inputId = ns("period_fun"), label = "Select period function",
                                                                           choices = c("chi_sq_periodogram", "ac_periodogram", "ls_periodogram", "fourier_periodogram", "cwt_periodogram", "FFT-NLLS"),
                                                                           selected = "FFT-NLLS", multiple = FALSE)
                                                 )
                                          ),
                                 # Results hidden until period analysis runs; shown via shinyjs::show("period_results")
                                 shinyjs::hidden(div(id = ns("period_results"),
                                   fluidRow(column(width = 12,
                                                   div(style = "overflow-x: auto; width: 100%;",
                                                       DT::DTOutput(ns("period_table")))
                                                   )
                                            ),
                                   fluidRow(column(width = 12, plotOutput(ns("Periodplot_out")))),
                                   fluidRow(column(width = 12, plotOutput(ns("Periodplot_out2")))),
                                   fluidRow(column(width = 12, plotOutput(ns("Periodplot_out3"))))
                                 )) # end hidden div
                                 ),
             shinyjs::hidden(div(id = ns("period_plots_box"),
               shinydashboard::box(title= "Period analysis plots", id = "box3_25", width = 12, solidHeader = TRUE, collapsible = TRUE, status = "primary",
                                   fluidRow(
                                     column(width = 3, style = "width: 20.833%;",
                                            plotly::plotlyOutput(ns("scatter_period"),    height = "400px")),
                                     column(width = 3, style = "width: 20.833%;",
                                            plotly::plotlyOutput(ns("scatter_amplitude"), height = "400px")),
                                     column(width = 3, style = "width: 20.833%;",
                                            plotly::plotlyOutput(ns("scatter_rae"),       height = "400px")),
                                     column(width = 3, style = "width: 37.5%;",
                                            plotly::plotlyOutput(ns("scatter_phase"), height = "430px"),
                                            shinyWidgets::pickerInput(
                                              inputId  = ns("phase_var"),
                                              label    = "Phase variable",
                                              choices  = c("phase_circ", "phase_rad", "phase_abs"),
                                              selected = "phase_circ",
                                              multiple = FALSE)
                                     )
                                   ),
                                   fluidRow(column(width = 12,
                                                   downloadButton(ns("Dl_scatter"),
                                                                  label = tagList(" Analysis plots (.zip)"))
                                   )),
                                   shinyjs::hidden(div(id = ns("excl_controls"),
                                     style = "margin-top: 12px; padding: 0 15px;",
                                     fluidRow(column(width = 12,
                                       actionButton(ns("exclude_sel"), "Exclude selected",
                                                    style = "color: #fff; background-color: #d95f02; border-color: #b84d02; margin-right: 8px;"),
                                       actionButton(ns("restore_all"), "Restore all",
                                                    style = "color: #fff; background-color: #6a6a6a; border-color: #555; margin-right: 8px;"),
                                       textOutput(ns("excl_count"), inline = TRUE)
                                     ))
                                   )),
                                   shinyjs::hidden(div(id = ns("summary_stats_div"),
                                     style = "margin-top: 16px; padding: 0 15px;",
                                     fluidRow(column(width = 12,
                                       h4("Group summary", style = "margin-bottom: 8px;"),
                                       div(style = "overflow-x: auto; width: 100%;",
                                           DT::DTOutput(ns("summary_table"))),
                                       shiny::br(),
                                       downloadButton(ns("Dl_summary"),
                                                      label = tagList(" Summary table (.csv)"))
                                     ))
                                   ))
               )
             )) # end hidden div
             # shinydashboard::box(title= "Assemble plots", id = "box3_3", width = 12, solidHeader = TRUE, collapsible = TRUE, collapsed = TRUE, status = "primary",
             #                     fluidRow(column(width = 12
             #                                     # actionButton(ns("assemble_plot"), "add period info to plots"),
             #                                     # downloadButton(outputId = ns("Dl_plots_ann"), label = "Download plots")
             #                     )
             #                     )
             # )

             )
    )
}

#' analysis Server Functions
#'
#' @param id id value
#' @param env super environment for cross module access
#'
#' @noRd
mod_analysis_server <- function(id, env){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # create empty list of reactiveValues to be returned
    toReturn = reactiveValues(first = NULL)

    # define a reactiveValues object to store the current state
    rv <- reactiveValues(currentPlotIndex = 1,
                         t_min = 0,
                         t_max = 1000,
                         fft_data = NULL,
                         selected_id = NULL,
                         excluded_ids = character(0),
                         period_tbl = NULL)

    # Reactive view of fft_data with excluded rows removed.
    fft_data_display <- reactive({
      df <- rv$fft_data
      if (is.null(df)) return(NULL)
      ex <- rv$excluded_ids
      if (length(ex) > 0) df <- df[!df$id %in% ex, , drop = FALSE]
      df
    })

    # Per-group summary stats using circular package for phase.
    compute_group_summary <- function(df) {
      groups <- unique(as.character(df$group))
      out <- lapply(groups, function(g) {
        sub <- df[as.character(df$group) == g, , drop = FALSE]
        n   <- nrow(sub)
        phase_rad_ok <- sub$phase_rad[!is.na(sub$phase_rad)]
        if (length(phase_rad_ok) > 1) {
          circ      <- circular::circular(phase_rad_ok, type = "angles", units = "radians")
          r_bar     <- as.numeric(circular::rho.circular(circ))
          rayleigh_p <- tryCatch(circular::rayleigh.test(circ)$p.value, error = function(e) NA)
          phase_mean_h <- as.numeric(circular::mean.circular(circ)) * 24 / (2 * pi)
          phase_sd_h   <- sqrt(max(0, -2 * log(r_bar))) * 24 / (2 * pi)
        } else {
          r_bar <- NA; rayleigh_p <- NA; phase_mean_h <- NA; phase_sd_h <- NA
        }
        data.frame(
          Group       = g,
          N           = n,
          Period_h    = sprintf("%.2f \u00b1%.2f", mean(sub$period,    na.rm = TRUE), stats::sd(sub$period,    na.rm = TRUE)),
          Amplitude   = sprintf("%.4f \u00b1%.4f", mean(sub$amplitude, na.rm = TRUE), stats::sd(sub$amplitude, na.rm = TRUE)),
          RAE         = sprintf("%.3f \u00b1%.3f", mean(sub$RAE,       na.rm = TRUE), stats::sd(sub$RAE,       na.rm = TRUE)),
          Phase_h     = sprintf("%.2f \u00b1%.2f", phase_mean_h, phase_sd_h),
          Rayleigh_R  = round(r_bar, 3),
          Rayleigh_p  = signif(rayleigh_p, 3),
          stringsAsFactors = FALSE
        )
      })
      do.call(rbind, out)
    }

    # TODO create a reactive value that when updating the data it automatically updates the slider max and min values
#
#     observe({shinyjs::hide(id = input$xlimits_tsplot)},
#             autoDestroy = TRUE)

    #Import Annotate object
    Annotate <- env$env2$Annotate

    #Import Custom_tables object
    Custom_tables <- env$env2$Custom_tables

    # BOX 3.0

    # actions to perform after pressing the TsPlot button
    observeEvent(input$TsPlot, {
      shinyjs::show("ts_plot_output")
      shiny::showNotification("Timeseries plotted", type = "message", duration = 3)
      # update time range from actual data first, then use those values for plotting
      # (avoids reading stale input$xlimits_tsplot before the slider re-renders)
      rv$t_min <- round(min(env$env2$myCleanSample[[1]]$elapsed), 1)
      rv$t_max <- round(max(env$env2$myCleanSample[[1]]$elapsed), 1)

      # update the slider inputs with real data range
      updateSliderInput(session, "xlimits_tsplot", min = rv$t_min, max = rv$t_max, value = c(rv$t_min, rv$t_max))
      updateSliderInput(session, "period_timefr",  min = rv$t_min, max = rv$t_max, value = c(rv$t_min, rv$t_max))

      # use rv values as xlimits -- slider may not have re-rendered yet
      xlimits <- c(rv$t_min, rv$t_max)

      datasets <- input$datasets
      Annotate <- env$env2$Annotate

      # access the data to be plotted
      datalist <- env$env2$myCleanSample
      plot_this <- input$plot_this
      # extract data from R6 object Clean data
      datalist_list <- purrr::map(datalist, function(obj) obj$make_list())
      plots <- list()
      for (i in seq_len(length(datalist_list))){
        plots[[i]] <- Annotate$plot_Timeserie(datalist_list[[i]], value = plot_this,
                                              env = env, tmin = xlimits[1], tmax = xlimits[2])
      }

      # add an extra object with all traces in a single faceted plot
      extraPlotPos <- (length(plots)+1)
      plots[[extraPlotPos]] <- Annotate$plot_Timeserie_facet(datalist_list, value = plot_this,
                                                              env = env, tmin = xlimits[1], tmax = xlimits[2])

      # store the unannotated timeseries plots
      Annotate$store_obj("ts_original", plots)

      # store plots into a reactive value
      rv$plots <- plots

      # Set the initial index
      rv$currentPlotIndex <- 1
    })


    # Plot downloader
    # TODO create a output Zip function that returns the temp location path
    output$Dl_plots <- downloadHandler(
      filename = function(){"TS_plots.zip"},
      content = function(file){
        Annotate <- env$env2$Annotate
        if (length(Annotate$retrieve_obj("ts_original")) > 0) {
          # Create a temporary directory to store individual plot files
          temp_dir <- file.path(tempdir(), "TS_plots")
          temp_zip <- file.path(temp_dir, "TS_plots.zip")
          file_list <- NULL

          # Save each plot as a separate file in the temporary directory
          for (i in seq_along(Annotate$retrieve_obj("ts_original"))) {
            if(i != length(Annotate$retrieve_obj("ts_original"))){
            img_num <- env$env2$myCleanSample[[i]]$img_number
            plot_id <- if (nzchar(img_num)) {
              paste0(env$env2$myCleanSample[[i]]$sampleName, "_", img_num, "_plot.png")
            } else {
              paste0(env$env2$myCleanSample[[i]]$sampleName, "_plot.png")
            }
            }else{plot_id = "All_plots.png"}
            plot_file <- file.path(temp_dir, plot_id)
            ggplot2::ggsave(plot_id, path = temp_dir, plot = Annotate$retrieve_obj("ts_original")[[i]], device = "png", width = 3600, height = 1800, units = "px", )
            file_list[i] <- plot_file
          }

          # Create a zip file containing all the saved plots
          zip::zip(temp_zip, files = file_list, mode = "cherry-pick")

          # remove temp files
          file.remove(file_list)

          # use file copy to override the problems in indexing
          file.copy(temp_zip, file)
        }
      },
      contentType = "application/zip"
    )

    output$Dl_data <- downloadHandler(
      filename = function(){
        data_choice <- input$plot_this
        #add case when there's multiple files to output
        stringr::str_c(data_choice, "_data_table.csv")
      },
      content = function(file){
        #get period_table choice
        data_choice <- input$plot_this
        Custom_tables <- env$env2$Custom_tables
        out_file <- Custom_tables$createTable(env, data_choice)
        utils::write.csv(out_file, file, quote = FALSE, row.names = FALSE)
      },
      contentType = "text/csv"
    )



    observeEvent(input$TsDetrend, {
      datalist <- env$env2$myCleanSample
      method <- input$detr_opt
      grade = NULL
      if (method == "linear"){grade = 1}
      else if(method == "cubic"){grade = 3}
      n <- length(datalist)
      shiny::withProgress(message = "Detrending...", value = 0, {
        for (i in seq_len(n)) {
          shiny::incProgress(1 / n, detail = paste("Sample", i, "of", n))
          datalist[[i]]$detrend(grade)
        }
      })
      new_choices <- union(input$plot_this, c("original", "detrended"))
      shinyWidgets::updatePickerInput(session, "plot_this",
        choices = new_choices, selected = "detrended")
      shinyWidgets::updatePickerInput(session, "period_data",
        choices = union(isolate(input$period_data), c("original", "detrended")),
        selected = "detrended")
      shiny::showNotification("Detrending complete", type = "message", duration = 3)
    })

    observeEvent(input$TsNormalize, {
      # TODO before normalization, data need to be detrended and possibly outliers
      # removed. therefore, the normalize button should be made accessible after
      # these steps are completed. The dataset to import is the cleaned data
      # run the normalization function on all the MyClean sample objects in the list


    })


    # BOX 3.1

    # Function to render the current TS plot
    # TODO make it into a function that takes as argument the reactive object
    # containing the plots
    renderCurrentPlot <- function() {
      current_plot_index <- rv$currentPlotIndex
      if (current_plot_index >= 1 && current_plot_index <= length(rv$plots)) {
        return(rv$plots[[current_plot_index]])
      } else {
        return(NULL)
      }
    }

    # Render the initial plot
    output$TSplot_out <- plotly::renderPlotly({
      p <- renderCurrentPlot()
      if (!is.null(p)) {
        is_last <- rv$currentPlotIndex == length(rv$plots)
        if (!is_last) {
          # Overlay FFT-NLLS sinusoidal fit when toggle is on and data are available
          if (isTRUE(input$show_fit) && !is.null(rv$fft_data)) {
            idx        <- rv$currentPlotIndex
            sample_obj <- env$env2$myCleanSample[[idx]]
            sample_id  <- sample_obj$sampleName
            fit_row    <- rv$fft_data[rv$fft_data$id == sample_id, , drop = FALSE]
            if (nrow(fit_row) == 1 &&
                all(c("offset", "amplitude", "period", "phase_rad") %in% names(fit_row))) {
              layer_df <- p$layers[[1]]$data
              t_seq  <- seq(min(layer_df$timevar, na.rm = TRUE),
                            max(layer_df$timevar, na.rm = TRUE),
                            length.out = 500)
              fitted <- fit_row$offset[1] + fit_row$amplitude[1] *
                sin(2 * pi * t_seq / fit_row$period[1] + fit_row$phase_rad[1])
              fit_df <- data.frame(timevar = t_seq, fitted = fitted)
              p <- p + ggplot2::geom_line(
                data        = fit_df,
                ggplot2::aes(x = timevar, y = fitted),
                colour      = "#e31a1c",
                linetype    = "dashed",
                linewidth   = 0.8,
                inherit.aes = FALSE
              )
            }
          }
          plt <- plotly::ggplotly(p, height = 320)
          # inject hover text stored in the layer data frame (not in ggplot aes)
          layer_data <- p$layers[[1]]$data
          if (!is.null(layer_data) && "hover_text" %in% names(layer_data)) {
            plt <- plotly::style(plt, text = layer_data$hover_text, hoverinfo = "text", traces = 1)
          }
        } else {
          n_facets <- length(rv$plots) - 1
          n_rows   <- ceiling(n_facets / 6)
          plt <- plotly::ggplotly(p, height = max(160, n_rows * 85 + 40))
        }
        plt
      } else plotly::plotly_empty()
    })

    # Update the plot when the current plot index changes
    observe({
      shinyjs::enable("firstBtn")
      shinyjs::enable("prevBtn")
      shinyjs::enable("nextBtn")
      shinyjs::enable("lastBtn")
      if (rv$currentPlotIndex <= 1) {
        shinyjs::disable("firstBtn")
        shinyjs::disable("prevBtn")
      }
      if (rv$currentPlotIndex >= length(rv$plots)) {
        shinyjs::disable("nextBtn")
        shinyjs::disable("lastBtn")
      }
    })

    # Button actions
    observeEvent(input$firstBtn, {
      rv$currentPlotIndex <- 1
    })

    observeEvent(input$prevBtn, {
      rv$currentPlotIndex <- rv$currentPlotIndex - 1
    })

    observeEvent(input$nextBtn, {
      rv$currentPlotIndex <- rv$currentPlotIndex + 1
    })

    observeEvent(input$lastBtn, {
      rv$currentPlotIndex <- length(rv$plots)
    })

    # Helper: render one scatter plot (initial render only -- no opacity state).
    # Opacity is managed separately via plotlyProxy so ggplotly never gets a
    # chance to reset our per-point marker settings on each interaction.
    make_scatter_plot <- function(df, col_name, y_label, title, source_id) {
      p <- ggplot2::ggplot(df, ggplot2::aes(x = group, y = .data[[col_name]])) +
        ggplot2::geom_point(
          ggplot2::aes(colour = group),
          size     = 3,
          position = ggplot2::position_jitter(seed = 42, width = 0.2)
        ) +
        ggplot2::labs(x = NULL, y = y_label, title = title) +
        ggpubr::theme_pubr() +
        ggplot2::theme(legend.position = "none",
                       plot.title     = ggplot2::element_text(hjust = 0.5, size = 12),
                       axis.title.y   = ggplot2::element_text(size = 13,
                                                              margin = ggplot2::margin(r = 12)),
                       axis.text      = ggplot2::element_text(size = 11))

      plt <- plotly::ggplotly(p, source = source_id, height = 400)

      # Drop spurious empty traces ggplotly sometimes emits (no x or y data).
      # These produce "No trace type specified" warnings in the browser console.
      plt$x$data <- Filter(function(tr) length(tr$x) > 0 || length(tr$y) > 0, plt$x$data)

      # Inject customdata (id) and hover text per trace.
      # Detect marker traces dynamically -- ggplotly trace order can include extras.
      groups     <- levels(factor(df$group))
      marker_idx <- which(vapply(plt$x$data, function(tr) {
        !is.null(tr$mode) && grepl("markers", tr$mode, fixed = TRUE)
      }, logical(1)))

      for (j in seq_along(groups)) {
        i      <- marker_idx[j]
        g      <- groups[j]
        grp_df <- df[df$group == g, , drop = FALSE]
        if (!is.null(i) && length(plt$x$data[[i]]$x) > 0 &&
            nrow(grp_df) == length(plt$x$data[[i]]$x)) {
          plt$x$data[[i]]$customdata <- as.character(grp_df$id)
          plt$x$data[[i]]$text       <- paste0("ID: ", grp_df$id,
                                               "<br>Group: ", grp_df$group,
                                               "<br>", y_label, ": ",
                                               round(grp_df[[col_name]], 3))
          plt$x$data[[i]]$hoverinfo  <- "text"
        }
      }

      plt |>
        plotly::config(displayModeBar = FALSE) |>
        plotly::event_register("plotly_click") |>
        plotly::event_register("plotly_doubleclick")
    }

    # Initial render -- fires when fft_data or exclusion state changes
    output$scatter_period <- plotly::renderPlotly({
      shiny::req(fft_data_display())
      make_scatter_plot(fft_data_display(), "period",    "Period (h)",      "Period",    "scatter_period")
    })

    output$scatter_amplitude <- plotly::renderPlotly({
      shiny::req(fft_data_display())
      make_scatter_plot(fft_data_display(), "amplitude", "Amplitude (A.U.)", "Amplitude", "scatter_amplitude")
    })

    output$scatter_rae <- plotly::renderPlotly({
      shiny::req(fft_data_display())
      make_scatter_plot(fft_data_display(), "RAE",       "RAE (A.U.)",      "RAE",       "scatter_rae")
    })

    # Helper: build the circular (Rayleigh) plot as a plotly object.
    # Re-renders on every selection change (bakes alpha per-row into the
    # ggplot2 object) so no proxy is needed.
    make_circular_plot <- function(df, phase_col, selected_id) {
      result <- plot_rayleigh_app(df,
                                   phase_col   = phase_col,
                                   selected_id = selected_id,
                                   pt_size     = 2,
                                   pt_alpha    = 0.7)
      if (is.null(result$pts_df)) return(plotly::plotly_empty())

      plt    <- plotly::ggplotly(result$plot, source = "scatter_phase",
                                  height = 430)

      # Drop spurious empty traces ggplotly sometimes emits.
      plt$x$data <- Filter(function(tr) length(tr$x) > 0 || length(tr$y) > 0, plt$x$data)

      pts_df <- result$pts_df
      groups <- levels(factor(df$group))

      # Find marker traces (geom_point) by mode -- circle, ticks, and labels come
      # first and have mode "lines" or "text", so we can't assume trace index == group index.
      marker_idx <- which(vapply(plt$x$data, function(tr) {
        !is.null(tr$mode) && grepl("markers", tr$mode, fixed = TRUE)
      }, logical(1)))

      # Suppress hover on all non-marker traces (circle, ticks, hour labels).
      for (i in seq_along(plt$x$data)) {
        if (!(i %in% marker_idx)) plt$x$data[[i]]$hoverinfo <- "none"
      }

      # Inject customdata and hover showing the original phase value (h or rad).
      # pts_df is angle-sorted, groups are in factor-level order -- match must hold.
      for (j in seq_along(groups)) {
        i      <- marker_idx[j]
        g      <- groups[j]
        grp_df <- pts_df[as.character(pts_df$group) == g, , drop = FALSE]
        if (!is.null(i) && length(plt$x$data[[i]]$x) > 0 &&
            nrow(grp_df) == length(plt$x$data[[i]]$x)) {
          phase_vals <- as.numeric(df[[phase_col]][match(grp_df$id, df$id)])
          plt$x$data[[i]]$customdata <- as.character(grp_df$id)
          plt$x$data[[i]]$text <- paste0(
            "ID: ", grp_df$id,
            "<br>Group: ", grp_df$group,
            "<br>", phase_col, ": ", round(phase_vals, 2)
          )
          plt$x$data[[i]]$hoverinfo <- "text"
        }
      }

      plt |>
        plotly::config(displayModeBar = FALSE) |>
        plotly::event_register("plotly_click") |>
        plotly::event_register("plotly_doubleclick")
    }

    # Circular plot re-renders on data change, selection change, or variable change.
    output$scatter_phase <- plotly::renderPlotly({
      shiny::req(fft_data_display())
      phase_col <- input$phase_var
      shiny::req(phase_col %in% names(fft_data_display()))
      make_circular_plot(fft_data_display(), phase_col, rv$selected_id)
    })

    # ggplot2-only version of make_scatter_plot, used by the download handler.
    make_scatter_gg <- function(df, col_name, y_label, title) {
      ggplot2::ggplot(df, ggplot2::aes(x = group, y = .data[[col_name]])) +
        ggplot2::geom_point(
          ggplot2::aes(colour = group),
          size     = 3,
          position = ggplot2::position_jitter(seed = 42, width = 0.2)
        ) +
        ggplot2::labs(x = NULL, y = y_label, title = title) +
        ggpubr::theme_pubr() +
        ggplot2::theme(legend.position = "none",
                       plot.title     = ggplot2::element_text(hjust = 0.5, size = 12),
                       axis.title.y   = ggplot2::element_text(size = 13,
                                                              margin = ggplot2::margin(r = 12)),
                       axis.text      = ggplot2::element_text(size = 11))
    }

    output$Dl_scatter <- shiny::downloadHandler(
      filename = function() "scatter_plots.zip",
      content  = function(file) {
        shiny::req(fft_data_display())
        df        <- fft_data_display()
        phase_col <- input$phase_var
        if (is.null(phase_col) || !(phase_col %in% names(df))) phase_col <- "phase_circ"

        temp_dir <- file.path(tempdir(), paste0("scatter_", format(Sys.time(), "%H%M%S")))
        dir.create(temp_dir, showWarnings = FALSE, recursive = TRUE)
        temp_zip <- file.path(tempdir(), "scatter_plots.zip")

        file_list <- c(
          file.path(temp_dir, "Period.png"),
          file.path(temp_dir, "Amplitude.png"),
          file.path(temp_dir, "RAE.png"),
          file.path(temp_dir, "Phase.png")
        )
        # Scatter: portrait ratio matching ~250 px wide x 400 px tall on screen (5:8)
        ggplot2::ggsave(file_list[1],
                        plot = make_scatter_gg(df, "period",    "Period (h)",      "Period"),
                        device = "png", width = 5, height = 8, dpi = 150)
        ggplot2::ggsave(file_list[2],
                        plot = make_scatter_gg(df, "amplitude", "Amplitude (A.U.)", "Amplitude"),
                        device = "png", width = 5, height = 8, dpi = 150)
        ggplot2::ggsave(file_list[3],
                        plot = make_scatter_gg(df, "RAE",       "RAE (A.U.)",      "RAE"),
                        device = "png", width = 5, height = 8, dpi = 150)
        # Rayleigh: slightly landscape matching ~450 px wide x 430 px tall on screen
        ggplot2::ggsave(file_list[4],
                        plot = plot_rayleigh_app(df, phase_col = phase_col,
                                                  selected_id = NULL,
                                                  pt_size = 2, pt_alpha = 0.7)$plot,
                        device = "png", width = 8, height = 7.7, dpi = 150)

        zip::zip(temp_zip, files = file_list, mode = "cherry-pick")
        file.remove(file_list)
        file.copy(temp_zip, file)
      },
      contentType = "application/zip"
    )

    # Push marker.opacity arrays to all three plots via Plotly.restyle().
    # observeEvent fires only when rv$selected_id actually changes (not continuously).
    # ignoreNULL = FALSE so it also fires on deselection (NULL -> restore full opacity).
    apply_scatter_opacity <- function(sel) {
      df <- shiny::isolate(fft_data_display())
      if (is.null(df)) return()
      groups <- levels(factor(df$group))
      for (out_id in c("scatter_period", "scatter_amplitude", "scatter_rae")) {
        proxy <- plotly::plotlyProxy(out_id, session)
        for (ti in seq_along(groups)) {
          g      <- groups[ti]
          grp_df <- df[df$group == g, , drop = FALSE]
          opacities <- if (is.null(sel)) {
            rep(0.7, nrow(grp_df))
          } else {
            ifelse(as.character(grp_df$id) == sel, 0.7, 0.15)
          }
          plotly::plotlyProxyInvoke(proxy, "restyle",
            list(`marker.opacity` = list(opacities)),
            list(ti - 1L)
          )
        }
      }
    }

    observeEvent(rv$selected_id, ignoreNULL = FALSE, ignoreInit = TRUE, {
      apply_scatter_opacity(rv$selected_id)
    })

    # Single-click: select/deselect a point (click same point again to deselect).
    # req(rv$fft_data) prevents event_data() from being evaluated before the plots
    # have rendered and called event_register() -- avoids the "not registered" warning.
    observeEvent({ shiny::req(rv$fft_data); plotly::event_data("plotly_click", source = "scatter_period") },
                 ignoreNULL = TRUE, ignoreInit = TRUE, {
      click <- plotly::event_data("plotly_click", source = "scatter_period")
      if (!is.null(click$customdata)) {
        sel <- as.character(click$customdata[[1]])
        rv$selected_id <- if (!is.null(rv$selected_id) && rv$selected_id == sel) NULL else sel
      }
    })
    observeEvent({ shiny::req(rv$fft_data); plotly::event_data("plotly_click", source = "scatter_amplitude") },
                 ignoreNULL = TRUE, ignoreInit = TRUE, {
      click <- plotly::event_data("plotly_click", source = "scatter_amplitude")
      if (!is.null(click$customdata)) {
        sel <- as.character(click$customdata[[1]])
        rv$selected_id <- if (!is.null(rv$selected_id) && rv$selected_id == sel) NULL else sel
      }
    })
    observeEvent({ shiny::req(rv$fft_data); plotly::event_data("plotly_click", source = "scatter_rae") },
                 ignoreNULL = TRUE, ignoreInit = TRUE, {
      click <- plotly::event_data("plotly_click", source = "scatter_rae")
      if (!is.null(click$customdata)) {
        sel <- as.character(click$customdata[[1]])
        rv$selected_id <- if (!is.null(rv$selected_id) && rv$selected_id == sel) NULL else sel
      }
    })

    # Double-click anywhere on any plot -> deselect all points
    observeEvent({ shiny::req(rv$fft_data); plotly::event_data("plotly_doubleclick", source = "scatter_period") },
                 ignoreNULL = TRUE, ignoreInit = TRUE, { rv$selected_id <- NULL })
    observeEvent({ shiny::req(rv$fft_data); plotly::event_data("plotly_doubleclick", source = "scatter_amplitude") },
                 ignoreNULL = TRUE, ignoreInit = TRUE, { rv$selected_id <- NULL })
    observeEvent({ shiny::req(rv$fft_data); plotly::event_data("plotly_doubleclick", source = "scatter_rae") },
                 ignoreNULL = TRUE, ignoreInit = TRUE, { rv$selected_id <- NULL })

    # Circular plot click/doubleclick -- same pattern as scatter plots.
    observeEvent({ shiny::req(rv$fft_data); plotly::event_data("plotly_click", source = "scatter_phase") },
                 ignoreNULL = TRUE, ignoreInit = TRUE, {
      click <- plotly::event_data("plotly_click", source = "scatter_phase")
      if (!is.null(click$customdata)) {
        sel <- as.character(click$customdata[[1]])
        rv$selected_id <- if (!is.null(rv$selected_id) && rv$selected_id == sel) NULL else sel
      }
    })
    observeEvent({ shiny::req(rv$fft_data); plotly::event_data("plotly_doubleclick", source = "scatter_phase") },
                 ignoreNULL = TRUE, ignoreInit = TRUE, { rv$selected_id <- NULL })

    # BOX 3.2 behavr_table period_an period_table
    # observeEvent(input$behavr_table, {
    #   Custom_tables <- env$env2$Custom_tables
    #   source <- input$plot_this
    #   behavr_tbl <- Custom_tables$behavrTable(env, source)
    # })

    # Period table rendered reactively -- updates when analysis reruns or exclusions change
    output$period_table <- DT::renderDT({
      shiny::req(rv$period_tbl)
      df <- rv$period_tbl
      ex <- rv$excluded_ids
      df$Excluded <- ifelse(df$id %in% ex, "Yes", "")
      DT::datatable(df, filter = "top",
                    options = list(scrollX = TRUE, pageLength = 10),
                    rownames = FALSE) |>
        DT::formatStyle(
          "Excluded",
          target          = "row",
          color           = DT::styleEqual("Yes", "#aaaaaa"),
          textDecoration  = DT::styleEqual("Yes", "line-through"),
          backgroundColor = DT::styleEqual("Yes", "#f7f7f7")
        )
    })

    output$summary_table <- DT::renderDT({
      shiny::req(fft_data_display())
      compute_group_summary(fft_data_display())
    }, options = list(scrollX = TRUE, pageLength = 25, dom = "t"), rownames = FALSE)

    output$Dl_summary <- shiny::downloadHandler(
      filename = function() "group_summary.csv",
      content  = function(file) {
        shiny::req(fft_data_display())
        utils::write.csv(compute_group_summary(fft_data_display()), file,
                         quote = FALSE, row.names = FALSE)
      },
      contentType = "text/csv"
    )

    output$excl_count <- renderText({
      n <- length(rv$excluded_ids)
      if (n == 0) "" else paste0(n, " sample(s) excluded")
    })

    observeEvent(input$exclude_sel, {
      if (!is.null(rv$selected_id) && nzchar(rv$selected_id)) {
        rv$excluded_ids <- unique(c(rv$excluded_ids, rv$selected_id))
        rv$selected_id  <- NULL
      }
    })

    observeEvent(input$restore_all, {
      rv$excluded_ids <- character(0)
    })

    # perform period analysis on data
    observeEvent(input$period_an, {
      rv$selected_id  <- NULL   # clear any selection when new analysis runs
      rv$excluded_ids <- character(0)  # reset exclusions for fresh analysis

      # Auto-range period_timefr to actual data if the user hasn't plotted first
      t_min_data <- round(min(env$env2$myCleanSample[[1]]$elapsed), 1)
      t_max_data <- round(max(env$env2$myCleanSample[[1]]$elapsed), 1)
      if (input$period_timefr[2] > t_max_data || input$period_timefr[1] < t_min_data) {
        updateSliderInput(session, "period_timefr",
                          min = t_min_data, max = t_max_data,
                          value = c(t_min_data, t_max_data))
      }

      Custom_tables <- env$env2$Custom_tables
      Annotate      <- env$env2$Annotate
      source        <- input$period_data
      method        <- input$period_fun
      t_lim         <- input$period_timefr

      period_tbl <- shiny::withProgress(message = "Running period analysis...", value = 0, {
        shiny::incProgress(0.2, detail = "Preparing data")
        Custom_tables$behavrTable(env, source)
        shiny::incProgress(0.5, detail = "Computing periods")
        tbl <- Custom_tables$new_compute_per(env, method, tmin = t_lim[1], tmax = t_lim[2])
        shiny::incProgress(0.3, detail = "Rendering results")
        tbl
      })

      # Store for reactive period_table and downstream use
      rv$period_tbl <- period_tbl

      # reveal result sections that are hidden until first analysis completes
      shinyjs::show("period_results")
      shinyjs::show("period_plots_box")
      shinyjs::show("excl_controls")
      shinyjs::show("summary_stats_div")
      # flip Period Analysis box header from blue (config) to green (results)
      shinyjs::runjs('$("#box3_2").removeClass("box-primary").addClass("box-success");')
      # enable button to download period table
      shinyjs::enable("Dl_period")
      n_cells <- if (is.data.frame(period_tbl)) nrow(period_tbl) else length(env$env2$myCleanSample)
      shiny::showNotification(
        paste0("Period analysis complete (", n_cells, " cells analysed)"),
        type = "message", duration = 4
      )

      if (method == "FFT-NLLS") {
        shinyjs::hide(id = "Periodplot_out")
        shinyjs::hide(id = "Periodplot_out2")
        shinyjs::hide(id = "Periodplot_out3")
        rv$fft_data <- Custom_tables$period_tbl$fft
        shinyjs::show("show_fit_div")
      } else {
        rv$fft_data <- NULL
        shinyjs::hide("show_fit_div")
        periodogram_plots <- list()
        periodogram_plots[[1]] <- Annotate$retrieve_obj("periodogram_total")
        periodogram_plots[[2]] <- Annotate$retrieve_obj("periodogram_faceted")
        periodogram_plots[[3]] <- Annotate$retrieve_obj("periodogram_averaged")
        output$Periodplot_out  <- shiny::renderPlot(periodogram_plots[[2]])
        output$Periodplot_out2 <- shiny::renderPlot(periodogram_plots[[1]])
        output$Periodplot_out3 <- shiny::renderPlot(periodogram_plots[[3]])
      }
    })

    output$Dl_period <- downloadHandler(
      filename = function(){
        #add case when there's multiple files to output
        "period_table.csv"
      },
      content = function(file){
        #get period_table choice
        per_choice <- input$period_fun
        Custom_tables <- env$env2$Custom_tables
        switch(per_choice,
               "chi_sq_periodogram" = {
                 out_file <- Custom_tables$period_tbl$xsq
               },
               "ac_periodogram" = {
                 out_file <- Custom_tables$period_tbl$ac
               },
               "ls_periodogram" = {
                 out_file <- Custom_tables$period_tbl$ls
               },
               "fourier_periodogram" = {
                 out_file <- Custom_tables$period_tbl$fourier
               },
               "cwt_periodogram" = {
                 out_file <- Custom_tables$period_tbl$cwt
               },
               "FFT-NLLS" = {
                 out_file <- Custom_tables$period_tbl$fft
               })
        utils::write.csv(out_file, file, quote = FALSE, row.names = FALSE)
      },
      contentType = "text/csv"
    )

    observeEvent(input$remove_out, {
      myCleanSample <- env$env2$myCleanSample
      n <- length(myCleanSample)
      shiny::withProgress(message = "Removing outliers...", value = 0, {
        for (i in seq_len(n)) {
          shiny::incProgress(1 / n, detail = paste("Sample", i, "of", n))
          myCleanSample[[i]]$remove_outliers(env)
        }
      })
      new_choices <- union(isolate(input$plot_this), c("original", "cleaned"))
      shinyWidgets::updatePickerInput(session, "plot_this",
        choices = new_choices, selected = "cleaned")
      shinyWidgets::updatePickerInput(session, "period_data",
        choices = union(isolate(input$period_data), c("original", "cleaned")),
        selected = "cleaned")
      shiny::showNotification("Outliers removed", type = "message", duration = 3)
    })

    # Box 3.3

    observeEvent(input$assemble_plot, {

      Annotate <- env$env2$Annotate
      Custom_tables <- env$env2$Custom_tables
      # get plots
      plots <- Annotate$retrieve_obj("ts_original")
      newplots <- list()
      # get period data
      method <- input$period_fun
      switch(method,
             "chi_sq_periodogram" = {
               period_tbl <- Custom_tables$period_tbl$xsq
             },
             "ac_periodogram" = {
               period_tbl <- Custom_tables$period_tbl$ac
             },
             "ls_periodogram" = {
               period_tbl <- Custom_tables$period_tbl$ls
             },
             "fourier_periodogram" = {
               period_tbl <- Custom_tables$period_tbl$fourier
             },
             "cwt_periodogram" = {
               period_tbl <- Custom_tables$period_tbl$cwt
             },
             "FFT-NLLS" = {
               period_tbl <- Custom_tables$period_tbl$fft
             })
      # method to subset the string without using any additional package
      method_plot <- gsub('.{0,12}$', '', method) %>% stringr::str_to_upper()

      #for cycle to process file and add additional data
      for(k in seq(1:(length(plots)-1))){
        id_val <- plots[[k]]$labels$title
        plot <- plots[[k]]
        if(method == "FFT-NLLS"){
        period_data <- period_tbl[which(period_tbl$id == id_val), ]
        period_val <- round(period_data$period, 2)
        amplitude_val <- round(period_data$amplitude, 4)
        plot_params <- ggplot2::ggplot_build(plot)
        xpos <- plot_params$layout$panel_params[[1]]$x.range[2]
        ypos <- plot_params$layout$panel_params[[1]]$y.range[2]
        row1 <- paste("Method: ", "FFT-NLLS")
        row2 <- paste("Period: ", period_val)
        row3 <- paste("Amplitude: ", amplitude_val)
        }else{
        period_data <- period_tbl[which(period_tbl$id == id_val), ]
        period_val <- round(period_data$period, 2)
        power_val <- round(period_data$power, 4)
        plot_params <- ggplot2::ggplot_build(plot)
        xpos <- plot_params$layout$panel_params[[1]]$x.range[2]
        ypos <- plot_params$layout$panel_params[[1]]$y.range[2]
        row1 <- paste("Method: ", method_plot)
        row2 <- paste("Period: ", period_val)
        row3 <- paste("power: ", power_val)
        }
        label <- stringr::str_c(row1, row2, row3, sep = '\n')
        # add info to plot and store in new list
        newplots[[k]] <- plot+
          ggplot2::annotate("text", x = xpos, y = ypos, hjust = 1, vjust = 1, label = label, size = 5
                            )

      }
      # add period info to last plot not working yet. need to change this for
      # last plot to be generated and info added on generation. make another#
      # call to plot_Timeserie_facet and add period info

      # browser()
      lastplot <- length(plots)
      # period_data <- period_tbl[, 1:2]
      # period_data$period <- round(period_data$period, 2)
      newplots[[lastplot]] <- plots[[lastplot]]
      #   ggplot2::geom_text(period_data, x = xpos, y = ypos, data = period_data$period, size = 4
      #   )

      # store period info to last plot

      Annotate$store_obj("ts_annotated", newplots)
      rv$plots <- newplots
    })

    # Plot downloader
    # TODO create a output Zip function that returns the temp location path
    output$Dl_plots_ann <- downloadHandler(
      filename = function(){"TS_plots_annotated.zip"},
      content = function(file){
        Annotate <- env$env2$Annotate
        if (length(Annotate$retrieve_obj("ts_annotated")) > 0) {
          # Create a temporary directory to store individual plot files
          temp_dir <- file.path(tempdir(), "TS_plots_annotated")
          temp_zip <- file.path(temp_dir, "TS_plots_annotated.zip")
          file_list <- NULL

          # Save each plot as a separate file in the temporary directory
          for (i in seq_along(Annotate$retrieve_obj("ts_annotated"))) {
            if(i != length(Annotate$retrieve_obj("ts_annotated"))){
              img_num <- env$env2$myCleanSample[[i]]$img_number
            plot_id <- if (nzchar(img_num)) {
              paste0(env$env2$myCleanSample[[i]]$sampleName, "_", img_num, "_plot.png")
            } else {
              paste0(env$env2$myCleanSample[[i]]$sampleName, "_plot.png")
            }
            }else{plot_id = "All_plots.png"}
            plot_file <- file.path(temp_dir, plot_id)
            ggplot2::ggsave(plot_id, path = temp_dir, plot = Annotate$retrieve_obj("ts_annotated")[[i]], device = "png", width = 3600, height = 1800, units = "px", )
            file_list[i] <- plot_file
          }

          # Create a zip file containing all the saved plots
          zip::zip(temp_zip, files = file_list, mode = "cherry-pick")

          # remove temp files
          file.remove(file_list)

          # use file copy to override the problems in indecing
          file.copy(temp_zip, file)
        }
      },
      contentType = "application/zip"
    )


    # RETURNED VALUES

    # add values to be returned
    analysis_out <- list(first = reactive(toReturn$first)
    )

    # return your_data_out list
    return(analysis_out)

  })
}

## To be copied in the UI
# mod_analysis_ui("analysis_1")

## To be copied in the server
# mod_analysis_server("analysis_1")
