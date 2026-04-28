#' landing_page UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_landing_page_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(style = "text-align: center; padding: 4px 20px 10px;",

      # Hex logo
      tags$img(src = "www/hex-ClockCyteR.png", height = "130px",
               style = "margin-bottom: 4px;"),

      # App name
      h1("ClockCyteR", style = "font-weight: bold; margin-bottom: 4px; margin-top: 0;"),

      # Tagline
      p("Circadian rhythm analysis for Incucyte timeseries data",
        style = "font-size: 18px; color: #555; margin-bottom: 20px;"),

      # 3-step workflow cards
      fluidRow(
        style = "max-width: 800px; margin: 0 auto 30px;",
        column(width = 4,
          div(class = "well", style = "text-align: center; padding: 24px 16px;",
            icon("upload", style = "font-size: 36px; color: #2171b5; display: block; margin-bottom: 12px;"),
            h4("1. Upload", style = "margin-bottom: 8px;"),
            p("Load your Incucyte timeseries data file", style = "color: #555; margin: 0;")
          )
        ),
        column(width = 4,
          div(class = "well", style = "text-align: center; padding: 24px 16px;",
            icon("chart-line", style = "font-size: 36px; color: #2171b5; display: block; margin-bottom: 12px;"),
            h4("2. Analyse", style = "margin-bottom: 8px;"),
            p("Plot timeseries, run period analysis, and explore results", style = "color: #555; margin: 0;")
          )
        ),
        column(width = 4,
          div(class = "well", style = "text-align: center; padding: 24px 16px;",
            icon("download", style = "font-size: 36px; color: #2171b5; display: block; margin-bottom: 12px;"),
            h4("3. Download", style = "margin-bottom: 8px;"),
            p("Export plots and tables ready for presentations", style = "color: #555; margin: 0;")
          )
        )
      ),

      # CTA button
      div(style = "margin: 10px 0 40px;",
        actionButton(inputId = "new_experiment",
                     label = "Start a new experiment",
                     style = "color: #fff; background-color: #1e690c; border-color: #1e530c; width: 220px; height: 50px; font-size: 16px;")
      ),

      # Footer
      div(style = "color: #999; font-size: 13px; border-top: 1px solid #eee; padding-top: 20px;",
        p("Developed at Imperial College London -- Brancaccio Lab"),
        p(tags$a(href = "mailto:m.ferrari20@imperial.ac.uk",
                 "m.ferrari20@imperial.ac.uk",
                 style = "color: #999;"))
      )
    )
  )
}

#' landing_page Server Functions
#'
#' @noRd
mod_landing_page_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
  })
}

## To be copied in the UI
# mod_landing_page_ui("landing_page_1")

## To be copied in the server
# mod_landing_page_server("landing_page_1")
