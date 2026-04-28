#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  # create home tab Item using fct_generate_UI
  output$Home <- render_tabItem_ui(tabname = "Home",
                                   text = "Home",
                                   icon = "calendar")
  # create Messages object
  # Messages <- Messages$new()
  # create necessary R6 class objects (App_settings and Messages)
  App_settings <- App_settings$new()
  # store Messages obj environment in App_settings
  # App_settings$env_msg <- pryr::where("Messages")

  # move active tab to Home tab item
  move_tab(session, "Home")
  # server side of landing page module
  mod_landing_page_server("landing_page_1")

  # activate Input tab and set it as active tab
  observeEvent(input$new_experiment, {
    output$InputData <- render_tabItem_ui(tabname = "InputData",
                                        text = "Input",
                                        icon = "upload")
    new_experiment(session, App_settings)
  })

  # server side of input_data module
  input_data_out <- mod_input_data_server("input_data_1", env = App_settings)

  # render Data Structure sidebar button
  # observeEvent(input_data_out$YourDataTab(), {
  #   if(isTRUE(input_data_out$YourDataTab()) == TRUE){ #to be changed with req()
  #     output$YourData <- render_tabItem_ui(tabname = "YourData",
  #                                               text = "Your Data",
  #                                               icon = "database")
  #   }
  # })

  # render Analysis sidebar button
  observeEvent(input_data_out$AnalysisTab(), {
    if(isTRUE(input_data_out$AnalysisTab()) == TRUE){ #to be changed with req()
      output$Analysis <- render_tabItem_ui(tabname = "Analysis",
                                           text = "Analysis",
                                           icon = "sliders-h")
      move_tab(session = session, tabname = "Analysis")
    }
  })

  # server side of your_data module
  # your_data_out <- mod_your_data_server("your_data_1", env = App_settings)

  # server side of analysis module
  analysis_out <- mod_analysis_server("analysis_1", env = App_settings)

#### DEBUG ########################################

#DEBUG in app
observeEvent(input$debug, {
  #browser()
})


}
