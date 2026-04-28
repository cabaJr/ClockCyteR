#' input_data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_input_data_ui <- function(id){
  ns <- NS(id)
  tagList(

    fluidRow(style="", # TODO add a selector for different channels files to be uploaded
             shinydashboard::box(title= "select files", id = ns("box0_1"), width = 12, solidHeader = TRUE, status = "primary", # to add the
                                 fluidRow(
                                   column(width = 6,
                                          fileInput(inputId = ns("fileListId"), label = "Select files to analyse", multiple = FALSE, div(style = "left" ))),
                                   column(width = 6,
                                          shinyWidgets::pickerInput(inputId = ns("platePos"), label = "Select what vessel you are uploading",
                                                                    choices = c("Front-left", "Front-right", "Centre-left", "Centre-right", "Rear-left", "Rear-right"),
                                                                    selected = "Front-left", multiple = FALSE, div(style = "left" )))
                                   ),
                                 fluidRow(
                                   column(width = 4,
                                          shiny::br(),
                                          actionButton(inputId = ns("load_test_data"), label = "Load example data",
                                                       style="color: #fff; background-color: #2171b5; border-color: #125588")
                                   ),
                                   column(width = 1, offset = 3,
                                          shiny::br(),
                                          actionButton(inputId = ns("help_0_2"), label = "HELP",
                                                       style="color: #fff; background-color: #1e690c; border-color: #1e530c")
                                   )
                                 )
             ) #box end
    ), #fluidrow end

    fluidRow(style = "",
             shinydashboardPlus::box(title= "Uploaded files", id = ns("box0_2"), width = 12, solidHeader = TRUE, collapsible = TRUE, status = "danger",
                                     fluidRow(
                                       column(width = 8, tableOutput(ns('list')))
                                     )
             )
    ),

    ## Update box borrowed form data structure module

    fluidRow(style = "",
             shinydashboard::box(title = "Load data", id = ns("box1_1_5"), solidHeader = TRUE, width = 12, status = "primary", collapsible = TRUE,
                                 fluidRow(
                                   column(width = 7,
                                          actionButton(inputId = ns("go1"), label = "Load into Data frame")
                                   )
                                 )
             )
    ),
    ## try ##
    fluidRow(style = "",
             div(id = "placeholder")
    )
    ## end of try ##
  )
}

#' input_data Server Functions
#'
#' @noRd
mod_input_data_server <- function(id, env){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # initialize returnable reactiveValue
    toReturn = reactiveValues(ui = NULL,
                              YourDataTab = NULL,
                              AnalysisTab = NULL,
                              idList = NULL)
    App_settings <- env
    # TODO create message object
    # show help messages
    # observeEvent(input$help_0_2, {show_help(App_settings, 1)})

    # Store data
    observeEvent(input$fileListId, {
      # TODO add case when user re-uploads different files to prevent duplicate
      # rownames and app crashing

      # upload any given data file to App_settings
      App_settings$setData(input$fileListId)
      # display filename of uploaded file
      output$list <- renderTable(App_settings$dataList$name)
      if(check_uploads(App_settings) == TRUE){
        toReturn$ui <- TRUE
      }
      # preload data into raw_data obj
      preload_data(App_settings)

    })


    observeEvent(input$load_test_data, {
      test_path <- system.file("extData", "Test_data.txt", package = "clockcyteR")
      if (nzchar(test_path)) {
        App_settings$setData(data.frame(name = "Test_data.txt", datapath = test_path,
                                        stringsAsFactors = FALSE))
        output$list <- renderTable(App_settings$dataList$name)
        preload_data(App_settings)
        toReturn$ui <- TRUE
        shiny::showNotification("Example data loaded", type = "message", duration = 3)
      }
    })

    observeEvent(input$go1, { # add condition to check if data have been loaded
      # load data inside myCleansample object
      # browser()
      if(!is.null(App_settings$dataList)){
      # check if vessel is already present
        update_vessel <- input$platePos
        vessel <- App_settings$getVessel(update_vessel)
      if(!vessel){ # option when there's no other vessel taking space
        load_data(App_settings, vessel) # TODO add check if data are present + way to store in different vessel containers
      }


      toReturn$YourDataTab <- TRUE
      toReturn$AnalysisTab <- TRUE
      # initialize menu in DataStructure tab
      # Upload selector from listSamples to choose what data to display in YourData
      toReturn$idList <- App_settings$listsample[,2]
      n_samples <- length(App_settings$listsample[,2])
      shiny::showNotification(
        paste0("Data loaded successfully (", n_samples, " samples)"),
        type = "message", duration = 4
      )
      }
    })

    # create list to be returned
    input_data_out <- list(YourDataTab = reactive(toReturn$YourDataTab),
                        AnalysisTab = reactive(toReturn$AnalysisTab),
                        idList = reactive(toReturn$idList),
                        ui = reactive(toReturn$ui)
    )

    return(input_data_out) # = reactive(toReturn$ui)

  })
}

## To be copied in the UI
# mod_input_data_ui("input_data_1")

## To be copied in the server
# mod_input_data_server("input_data_1")
