#' @title check_uploads
#' @description Function to check uploaded files
#' @details Functions that returns TRUE if data have been uploaded.
#' @param App_settings passed to the functions to access values stored in the
#' App_settings object.
#' @return TRUE or FALSE
#' @noRd

check_uploads <- function(App_settings){
  if(is.null(App_settings$dataList) == FALSE){
    check <- TRUE
  } else {check <- FALSE}
  return(check)
}

#' data_loader
#'
#' @param App_settings to access App_settings object
#'
#' @description A function to create the Raw_sample_data and preload the
#'     uploaded files inside of it, decomposing the metadata file and the
#'     data files.
#'
#' @return No returned value to the user. Stores the environment location in app settings
#'
#' @noRd
# TODO change last line into a function that saves env locations in a private value of App_settings. create foo in App_sett that stores locations
preload_data <- function(App_settings){ # add a factor to select what channel the data belong to
  mySample <- NULL
  for(i in seq_len(length.out = length(App_settings$dataList$name))) { # not necessary to make a for cycle but only select the channel
    # TODO reset mySample object when new data are uploaded
    mySample[[i]] <- Raw_sample_data$new()
    mySample[[i]]$initialize()
    mySample[[i]]$add(App_settings$dataList$datapath[i], App_settings)
  }
  App_settings$env1 <- environment()
}

#' load_data
#' @param env App_settings environment
#' @param vessel Vessel position when uploaded
#' @description creates Clean_sample_data object and stores into myCleanSample list
#' @export
#'
load_data <- function(env, vessel = "Front-Left"){
  # browser()
  App_settings <- env
  mySample2 <- App_settings$env1$mySample
  samples <- mySample2[[1]]$samples
  myCleanSample <- list()
  # go through all the raw_sample_data object in the mySample list and compile
  #    the clean_sample_data object
  for (i in c(1:samples)){ # TODO check if this value exist and has been set
    myCleanSample[[i]] <- Clean_sample_data$new()
    myCleanSample[[i]]$compileMeta(mySample2[[1]])
    myCleanSample[[i]]$compileData(mySample2[[1]], App_settings, i)
  }
  #after having generate a clean_sample data for each
  env$env2 <- environment()
  App_settings$setListSample(env)
  # creation of custom tables objects
  # TODO move this step outside of this function and into the server logic
  Custom_tables <- Custom_tables$new()
  Custom_tables$compile(App_settings$env2)
  App_settings$env3 <- environment()
  # creation of annotate object to store plots
  # TODO move this step into server logic
  Annotate <- Annotate$new()
  App_settings$env4 <- environment()
}
