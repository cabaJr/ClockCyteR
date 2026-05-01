
#' R6_clean_data
#'
#' @description R6 class object fectory. Each uploaded file by the user is
#'     combined with metadata to create a Clean_mouse_data object, that can
#'     be stored in a list with other uploads.
#'     NOTE to create multiple experiments make lists myCleanMiceX
#'
#' @return A Clean_mouse_data object
#'
#' @noRd

Clean_sample_data <-
  R6::R6Class("Clean_data",
               list(
                 #' @field vesselName character vector describing the vessel name
                 #' @field metric factor value describing what metric is being measured
                 #' @field cellType character describing the cell type used
                 #' @field passage Integer value.
                 #' @field notes character vector with possible experimental notes
                 #' @field analysis character vector containing the name of the analysis used
                 #' @field realTime contains real time
                 #' @field elapsed double value contains time elapsed from start of the experiment
                 #' @field sampleName Character containing the each sample name (column title)
                 #' @field group If a plate map has been defined, the plate map name
                 #' @field img_number description
                 #' @field intensity double vector containing the intensity values measured
                 #' @field intensity_clean description
                 #' @field smooth_vals description
                 #' @field normalized description
                 #' @field detrended description
                 #' @field outliers description
                 #' @field data_length double value containg info about length of data
                 #' @field metadata description
                 vesselName = as.character(),
                 metric = as.character(),
                 cellType = as.character(),
                 passage = as.integer(),
                 notes = as.character(),
                 analysis = as.character(),
                 realTime = as.character(),
                 elapsed = as.character(),
                 days = as.double(),
                 sampleName = as.character(),
                 group = as.character(),
                 img_number = as.character(),
                 intensity = as.double(),
                 intensity_clean = as.double(),
                 smooth_vals = as.double(),
                 smooth_detr_vals = as.double(),
                 normalized = as.double(),
                 detrended = as.double(),
                 outliers = as.double(),
                 data_length = as.double(),
                 metadata = NULL,

                 #' compileMeta
                 #'
                 #' @param x Raw_sample_data object

                 compileMeta = function(x){
                   raw <- x
                   vesselName <- as.vector(raw$metadata[1,])
                   metric <- as.vector(raw$metadata[2,])
                   cellType <- as.vector(raw$metadata[3, ])
                   passage <- as.vector(raw$metadata[4, ])
                   notes <- as.vector(raw$metadata[5, ])
                   analysis <- as.vector(raw$metadata[6, ])
                   if(vesselName$Value == " "){vesselName$Value[1] = "None"}
                   if(metric$Value == " "){metric$Value[1] = "None"}
                   if(cellType$Value == " "){cellType$Value[1] = "None"}
                   if(passage$Value == " "){passage$Value[1] = 0}
                   if(notes$Value == " "){notes$Value[1] = "None"}
                   self$vesselName <- vesselName$Value
                   self$metric <- metric$Value
                   self$cellType <- cellType$Value
                   self$passage <- passage$Value
                   self$notes <- notes$Value
                   self$analysis <- analysis$Value
                 },

                 #' compileData
                 #'
                 #' @param x data table
                 #' @param App_settings App settings object
                 #' @param i integer representing the sample position in the data table
                 #'
                 compileData = function(x, App_settings, i){ #more comments on these fun
                   # add all parameters that can be extracted from the data fields
                   # browser()
                   fulldata <- x$data
                   # extract time columns and make them into a posiXct object
                   timepaste <- fulldata[, 1]#stringr::str_c(fulldata[, 1], fulldata[, 2], sep = " ")
                   realTime <- as.POSIXct(timepaste, tz = "", format = "%d/%m/%Y %H:%M:%S")
                   elapsed = fulldata$Elapsed
                   days = round(elapsed/24, 2)
                   # extract data and sample name
                   data <- fulldata[, i+2]
                   name_string <- colnames(fulldata)[i+2]
                   extracted_values <- self$extract_components(name_string)
                   group <- if(extracted_values$Group == "" | is.na(extracted_values$Group)){"Exp"}else{extracted_values$Group}
                   unique_id = if(extracted_values$Image == "" | is.na(extracted_values$Image)){
                     extracted_values$Well
                   }else{
                     stringr::str_c(extracted_values$Well, "_", extracted_values$Image)
                   }
                   # get data length
                   data_length <- length(data)
                   #create metadata table
                   meta_table <- data.frame(Group = group,
                                            Well = extracted_values$Well,
                                            Image = extracted_values$Image,
                                            Unique_id = unique_id,
                                            Length = data_length,
                                            Analysis = self$analysis,
                                            metric = self$metric)
                   #load inside attributes
                   self$realTime <- realTime
                   self$elapsed <- elapsed
                   self$days <- days
                   self$intensity <- data/1000 # divide data by 1000 as comma is omitted when exporting
                   self$intensity_clean <- NULL
                   self$detrended <- NULL
                   self$normalized <- NULL
                   self$outliers <- NULL
                   self$sampleName <- unique_id
                   self$group <- group
                   self$img_number <- extracted_values$Image
                   self$data_length <- data_length
                   self$metadata <- meta_table
                 },

      #' extract_components
      #' @description Extracts components from the name of the timeseries
      #' @param string input string from column names
      #'
      #' @return a table containing Group, well and Image
      #'
                 extract_components = function(string) {
                   if(nchar(string)< 3){ # no groups no multiple images
                     group <- ""
                     well <- string
                     image <- ""
                   } else{
                     # regexpr to capture the different parts
                     pattern <- "^(?:([^\\(]+)\\s)?(?:\\((A[1-6]|B[1-6]|C[1-6]|D[1-6])\\))?(?:,\\s(.*))?$"
                     match_result <- regexec(pattern, string)

                     group <- ifelse(match_result[[1]][2] != -1, regmatches(string, match_result)[[1]][2], "")
                     well <- ifelse(match_result[[1]][3] != -1, regmatches(string, match_result)[[1]][3], "")
                     image <- ifelse(match_result[[1]][4] != -1, regmatches(string, match_result)[[1]][4], "")
                     # strip "Image " prefix when captured by the main regex
                     if (grepl("^[Ii]mage\\s+", image)) {
                       image <- sub("^[Ii]mage\\s+", "", image)
                     }
                     # fallback for Incucyte "WELL, Image N" format (no parentheses, no group)
                     if ((is.na(well) || well == "") &&
                           grepl("^[A-D][1-6](,\\s*[Ii]mage\\s+\\d+)?$", string)) {
                       parts <- strsplit(string, ",\\s*")[[1]]
                       well  <- trimws(parts[1])
                       image <- if (length(parts) > 1) trimws(sub("[Ii]mage\\s+", "", parts[2])) else ""
                       group <- ""
                     }
                   }
                   return(data.frame(Group = group, Well = well, Image = image))
                 },

      #' remove_outliers
      #'
      #' @param env App_settings environment
      #' @param sdval value to set how many SD from the smoothened curve
      #' @param method outlier detection strategy
      #' @param span value to use in loess function to create smoothened curve
      #'
      #' @return data table returned internally to the function
      #'
                 remove_outliers = function(env, sdval = 0.6, method = "loess", span = 0.08){
                   # retrieve list containing R6 objects with data
                   all_data <- self$intensity
                   # retrieve x values
                   x_vals <- self$elapsed
                   # create vector with NA vals
                   outliers_vector <- rep(NA, length(all_data))
                   # create vector for cleaned data
                   cleaned_ts = all_data
                   switch(method,
                          "sd" = {
                           # Strategy #1 : use when data are more than x*SD vals from mean
                           # remove outliers from detrended data
                           sd = stats::sd(all_data)
                           mean_val = mean(all_data)
                           outliers <- which(abs(all_data)-abs(mean_val)> sd*sdval)
                           # store outliers
                           outliers_vector[outliers] <- all_data[outliers]
                           # replace original data
                           all_data[outliers] = NA
                           },
                           "lag" = {
                           # Strategy #2 : when values next to eachother are more than the avg lag between points
                           # 0. compute lag value for the all_data vec
                           # 1. get list of points that could be deleted
                           # 2. get list of surrounding points and compute
                               # numerical threshold
                               lag_all_data = all_data - dplyr::lag(all_data)
                               loess_series = stats::loess(all_data ~ seq_along(all_data), span = 0.13)
                               loess_values = predict(loess_series, newdata = data.frame(x = seq(1:length(all_data))))
                               mean_lag <- mean(lag_all_data, na.rm = TRUE)
                               outliers <- which(abs(abs(all_data) - abs(loess_values)) > 20*lag_all_data)
                               outliers_vector[outliers] <- all_data[outliers]
                               all_data[outliers] = NA

                             },
                           "loess" = {
                                 # combination of two methods for big outliers exclusion and curve approximation with loess
                                 # perform first loess approximation
                                 smoothed_series <- loess(all_data ~ seq_along(all_data), span = span)
                                 smoothed_values <- predict(smoothed_series, newdata = data.frame(x = x_vals))
                                 # calculate outliers based on distance from loess curve and sd
                                 stdev_ts <- sd(smoothed_values)
                                 outliers <- which(abs(smoothed_values - all_data) > stdev_ts*sdval)

                                 # delete outliers from data
                                 cleaned_ts[outliers] <- NA
                                 # save outliers into outliers_vector
                                 outliers_vector[outliers] <- all_data[outliers]
                                 self$outliers <- outliers_vector
                                 # perform second loess approximation on clean data
                                 smoothed_clean_series <- loess(cleaned_ts ~ seq_along(cleaned_ts), span = 0.08)
                                 smoothed_clean_values <- predict(smoothed_clean_series, newdata = data.frame(x = x_vals))
                                 # save cleaned data
                                 self$intensity_clean <- cleaned_ts
                                 # save second loess approximation
                                 self$smooth_vals <- smoothed_clean_values
                               }
                            ) # switch end

                 },

                #' make_list
                #'
                #' @param object clean_data R6 object to be returned as simple list
                #'
                #' @return a list

                 make_list = function(){

                   obj_as_list <- list(vesselName = self$vesselName,
                                       metric = self$metric,
                                       cellType = self$cellType,
                                       passage = self$passage,
                                       notes = self$notes,
                                       analysis = self$analysis,
                                       realTime = self$realTime,
                                       elapsed = self$elapsed,
                                       sampleName = self$sampleName,
                                       sampleGroup = self$group,
                                       img_number = self$img_number,
                                       intensity = self$intensity,
                                       intensity_clean = self$intensity_clean,
                                       smooth_vals = self$smooth_vals,
                                       smooth_detr_vals = self$smooth_detr_vals,
                                       normalized = self$normalized,
                                       detrended = self$detrended,
                                       outliers = self$outliers,
                                       data_length = self$data_length
                                         )
                   return(obj_as_list)
                 },

      #' get_meta
      #' @description
      #' A function to access and export the table containig the metadata values in
      #' self$metadata
      #'
      #' @return a table containing the metadata fields for the sample

                  get_meta = function(){
                    meta_table <- self$metadata
                    return(meta_table)
                  },

      #' detrend
      #' @description
      #' function to normalize values of a timeserie, based on min/max
      #'
      #' @return function returns value internally

                  detrend = function(grade){
                    outliers_rm = FALSE
                    # runs a check if the dataset with removed outliers is available
                    if(length(self$intensity_clean) > 0){
                      outliers_rm = TRUE
                      # import data from cleaned values
                      intensity <- self$intensity_clean
                      outliers <- which(is.na(intensity))
                      # interpolate missing values before detrending
                      intensity <- imputeTS::na_interpolation(intensity, option = "spline")
                    }else{
                    intensity <- self$intensity
                    }
                    if (all(is.na(intensity))) {
                      warning("All values are NA. Skipping detrend.")
                      return(invisible(self))
                    }
                    detr_vals <- astsa::detrend(intensity, grade)
                    x_vals <- self$elapsed
                    # perform loess approximation on detrended data
                    smoothed_clean_series <- loess(detr_vals ~ seq_along(detr_vals), span = 0.08)
                    smoothed_clean_values <- predict(smoothed_clean_series, newdata = data.frame(x = x_vals))
                    if(outliers_rm){
                    # remove interpolated values to avoid fake representation
                    detr_vals[outliers] <- NA
                    }
                    self$detrended <- detr_vals
                    self$smooth_detr_vals <- smoothed_clean_values
                  },

#' normalize_vals
#' @description
#' Function to normalize values by making them between 0 and 1
#'
#' @return functions returns values internally

                  normalize_vals = function(){
                    # import data from intensity_clean or detrended

                    if(!is.null(self$clean)){
                      data = self$intensity_clean
                    } else{data = self$detrended}
                    # perform min/max normalization step
                    normalized_data <- (data - min(data)) / (max(data) - min(data))
                    # save data into normalized field
                    self$normalized <- normalized_data
                  },

      #' phase_align
      #'
      #' @param ... general param to the function
      #'
      #' @return returns internally the timeseries but phase aligned

                  phase_align = function(...){
                    # import the timeseries to be analysed
                    # requires data to be detrended, normalised. no outliers

                    # find all peaks

                    # align peaks to
                  }


               )
)
