#' Custom_tables
#'
#' @title Custom_tables
#'
#' @description A R6 object that contains methods to analyse the uploaded data.
#'     The secondary data that are generated are stored inside the object.
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd


# Custom tables class initializer
##### CUSTOM TABLES ###########
Custom_tables <- R6::R6Class("Custom_tables",
                             list(
                               #' @field metadata list of metadata
                               #' @field behavr_data object containing the bahavr table used for next analysis
                               #' @field cleaned_data Data table where outliers have been removed
                               #' @field detrended_data list containing tables containing data after detrending
                               #' @field average_day list containing tables related to average circadian day
                               #' @field periodograms list containing tables related to periodograms
                               #' @field cacheKeys table storing the cacheKeys to avoid reloading the same plots
                               metadata = NULL,
                               behavr_data = NULL,
                               period_tbl = list(xsq = NULL,
                                                 ac = NULL,
                                                 ls = NULL,
                                                 fourier = NULL,
                                                 cwt = NULL,
                                                 fft = NULL,
                                                 fft_plots = NULL),
                               peak_tbl = list(xsq = NULL,
                                                 ac = NULL,
                                                 ls = NULL,
                                                 fourier = NULL,
                                                 cwt = NULL),
                               cleaned_data = list(),
                               detrended_data = list(linear = NULL,
                                                     cubic = NULL),
                               periodograms = list(),
                               cacheKeys = dplyr::tibble("table" = seq(1:8), #table to store keys of hashed tables
                                                         "key" = 0),
                               #' compile
                               #'
                               #' @param env App_settings object to access the env containing myCleanMice obj
                               #'
                               #' @details method to generate a metadata table, integrating the metadata file
                               #'     uploaded from the user with computing of each raw data file in the
                               #'     dataset.
                               #'
                               #' @return Metadata table to be stored inside the Custom_tables R6 object.

                               compile = function(env){ #requires myClean mice to exist, therefore


                                 idList <- c(0,0)
                                 lengthList <- c(0,0)
                                 myCleanSample <-  env$env2$myCleanSample

                                 for (i in seq_len(length(myCleanSample))){
                                   idList[i] <- as.character(myCleanSample[[i]]$sampleName)
                                   lengthList[i] <- (myCleanMice[[i]]$length)
                                 }
                                 metadataExtr <- dplyr::tibble(
                                   "id" = idList,
                                   "Data_lenght" = lengthList
                                 )
                                 self$metadata <- metadataExtr
                                 # browser()
                               },

                               #
                               #' CheckIf
                               #'
                               #' @param funEnv env containing App_settings
                               #' @param subsetPlot Yes/No value

                               checkIf = function(funEnv, subsetPlot){#to add option to check for presence of different tables

                                 # if(is.null(self$locomotor_act[[1]]) == TRUE){ #add conditions to see if values changed and it's necessary to recalculate the table
                                 # if(funEnv$env2$Annotate$cacheKeys[1, 2] != self$cacheKeys[1, 2]){
                                 self$behavrTable(funEnv, subsetPlot)
                                 # }else{}
                               },

                              #' createTable
                              #'
                              #' @param env App settings environment
                              #' @param datachoice which data to output
                              #'
                              #' @return a table containg intensity data

                               createTable = function(env, source){
                                 # write lines to decide where to get the data from based on the preprocessing
                                 data_obj <- env$env2$myCleanSample

                                 # new version

                                 # get data from inputs
                                 data_list <- purrr::map(data_obj, function(obj) obj$make_list())
                                 data_clean <- data.frame()
                                 column_names <- NULL
                                 # create long table containing all data
                                 for (i in seq_along(data_list)){
                                   if (i == 1){
                                     timecol <- data_list[[i]]$elapsed
                                     column_names[i] <- "Time"
                                     data_clean <- timecol
                                   }
                                   switch(source,
                                          "original" = {vals <- data_list[[i]]$intensity},
                                          "detrended" = {vals <- data_list[[i]]$detrended},
                                          "cleaned" = {
                                            vals <- data_list[[i]]$intensity_clean
                                            # add interpolation of missing data
                                            vals <- imputeTS::na_interpolation(vals, option = "spline")
                                          },
                                          "smooth" = {vals <- data_list[[i]]$smooth_vals},
                                          "smooth detrended" = {vals <- data_list[[i]]$smooth_detr_vals})
                                   column_names[i+1] <- data_list[[i]]$sampleName
                                   data_clean <- cbind(data_clean, vals)
                                   if (i == length(data_list)){
                                     colnames(data_clean) <- column_names
                                   }
                                 }
                                 data_wide <- data.table::as.data.table(data_clean)
                               },

                               #' behavrTable
                               #'
                               #' @param env App_settings environment
                               #' @param subsetVal Yes/No value if to subset dataset or not
                               #'
                               behavrTable = function(env, source, subsetVal = "No"){

                                 # write lines to decide where to get the data from based on the preprocessing
                                 data_obj <- env$env2$myCleanSample

                                 # new version

                                 # get data from inputs
                                 data_list <- purrr::map(data_obj, function(obj) obj$make_list())
                                 data_clean <- data.frame()
                                 column_names <- NULL
                                 # create long table containing all data-
                                 for (i in seq_along(data_list)){
                                   if (i == 1){
                                     timecol <- data_list[[i]]$elapsed
                                     column_names[i] <- "Time"
                                     data_clean <- timecol
                                   }
                                   switch(source,
                                   "original" = {vals <- data_list[[i]]$intensity},
                                   "detrended" = {vals <- data_list[[i]]$detrended},
                                   "cleaned" = {
                                         vals <- data_list[[i]]$intensity_clean
                                         # add interpolation of missing data
                                         vals <- imputeTS::na_interpolation(vals, option = "spline")
                                         },
                                   "smooth" = {vals <- data_list[[i]]$smooth_vals},
                                   "smooth detrended" = {vals <- data_list[[i]]$smooth_detr_vals})
                                   column_names[i+1] <- data_list[[i]]$sampleName
                                   data_clean <- cbind(data_clean, vals)
                                   if (i == length(data_list)){
                                     colnames(data_clean) <- column_names
                                   }
                                 }
                                 data_wide <- data.table::as.data.table(data_clean)
                                 data_wide$Time <- data_wide$Time * 3600

                                 #make it into long table format
                                 data_long <- tidyr::pivot_longer(data_wide,
                                                                  cols = colnames(data_wide)[-1],
                                                                  names_to = "id") %>% data.table::as.data.table(key = "id")

                                 # reorder columns, change names, set key
                                 data_long <- data_long[, c("id", "Time", "value")]
                                 colnames(data_long) <- c("id", "t", "value")
                                 data.table::setkey(data_long, id)

                                 # get metadata file from each Clean_data obj
                                 metadata_list <- purrr::map(data_obj, function(obj) obj$get_meta())
                                 # metadata_all <- do.call(rbind, metadata_list)
                                 metadata_clean <- data.frame(id = as.character(),
                                                              group = as.character())
                                 for (i in seq_along(data_list)){
                                   new_row <- data.frame(id = metadata_list[[i]]$Unique_id,
                                                                     group = metadata_list[[i]]$Group)
                                   metadata_clean = rbind(metadata_clean, new_row)
                                 }
                                 metadata <- data.table::data.table(metadata_clean)

                                 # extract data from table

                                 # set key on tables
                                 data.table::setDT(data_long, key = "id")
                                 data.table::setDT(metadata, key = "id")

                                 # Generate behavr table
                                 behavrTable <- behavr::behavr(data_long, metadata)

                                 # Store behavr table inside Custom_Table object
                                 self$behavr_data <- behavrTable
                                 self$metadata <- metadata

                                 # Return behavr Table outside the function
                                 return(behavrTable)


                                 #add a vector containing the myCleanMice numbers in the list:
                                 # if no subsetting list all --> toLoad <- seq_len(length(myCleanMice))
                                 # if subsetting (subsetPlot == "Yes") --> toLoad <-  listMicefiltered[,1]
                                 # if (subsetVal == "Yes"){
                                 #   validate(
                                 #     need(is.null(x$subsetting$miceListFiltered) == FALSE,
                                 #          message = showModal(modalDialog("You need to select a group of mice", title = "Data", easyClose = TRUE))
                                 #     )
                                 #   )
                                 # }
                                 # range = c((x$subsetting$timespan[1]*1440),(x$subsetting$timespan[2]*1440))
                                 # switch(subsetVal,
                                 #        "Yes" = {
                                 #          toLoad <- x$subsetting$miceListFiltered$pos
                                 #          range = c((x$subsetting$timespan[1]*1440),(x$subsetting$timespan[2]*1440))
                                 #        },
                                 #        "No" = {
                                 #          toLoad <- seq_len(length(myCleanSample))
                                 #          range = c(0,max(x$env2$Custom_tables$metadata$Data_lenght))
                                 #        })
                                 # for (i in toLoad){
                                 #   range1 <- which(myCleanSample[[i]]$timepoint >= range[1]*60)
                                 #   range2 <- which(myCleanSample[[i]]$timepoint <= range[2]*60)
                                 #   range3 <- intersect(range1, range2)
                                 #   data <- myCleanSample[[i]]$countsMinute[range3]    #filter based on timepoint
                                 #   timepoint <- myCleanSample[[i]]$timepoint[range3]  #filter based on timepoint
                                 #   realtime <- myCleanSample[[i]]$realTime[range3]    #filter based on timepoint
                                 #   id <- as.character(myCleanSample[[i]]$id)
                                 #   sex <- as.character(myCleanSample[[i]]$sex)
                                 #   genotype <- as.character(myCleanSample[[i]]$genotype)
                                 #   d1 <- dplyr::tibble("id" = id,
                                 #                       "t" = timepoint,
                                 #                       "Activity" = data,
                                 #                       "Sex" = sex,
                                 #                       "Genotype" = genotype)
                                 #   d2 <- rbind(d2, d1)
                                 # }
                                 # d2
                                 #
                                 # metadata <- self$metadata
                                 # data.table::setDT(d2, key = "id")
                                 # data.table::setDT(metadata, key = "id")
                                 # self$locomotor_act[[1]] <- behavr::behavr(d2, metadata)
                                 #
                                 #
                                 # # add NULL values as placeholder for other tables
                                 # self$locomotor_act[[2]] <- "0"
                                 # self$locomotor_act[[3]] <- "0"
                                 # self$locomotor_act[[4]] <- "0"
                                 #self$cacheKeys[1,2] <- digest::digest(self$locomotor_act[[1]], "xxhash64")
                               },

                               #' new_compute_per
                               #'
                               #' @description function to analyse data generated with behavrTable() to
                               #'     extract period lenght in data if present.
                               #'     Describe Analysis methods and link to papers that compare the different
                               #'     methods
                               #' @param env App settings environment
                               #' @param method method to use to compute period
                               #'
                               #' @return a table of data containing the period estimation
                               #'
                               new_compute_per = function(env, method, tmin = 0, tmax){
                                 # import Annotate object
                                 Annotate <- env$env2$Annotate
                                 # import data
                                 if(!is.null(self$behavr_data)){
                                   data_all <- self$behavr_data
                                   all_ids <- unique(data_all$id)
                                   t_max_s <- tmax * 3600
                                   t_min_s <- tmin * 3600
                                   data <- data.table::setkey(data_all[data_all$t <= t_max_s & data_all$t >= t_min_s,], key = "id")
                                   method = method
                                   # different options based on method xsq ac ls fourier cwt FFT-NLLS
                                   switch(method,
                                          "chi_sq_periodogram" = {
                                            chi_sq_period_quant <- zeitgebr::periodogram(value,
                                                                                         data,
                                                                                         period_range = c(behavr::hours(20),
                                                                                                          behavr::hours(30)),
                                                                                         resample_rate = 1/behavr::mins(6),
                                                                                         alpha = 0.05,
                                                                                         FUN = zeitgebr::chi_sq_periodogram)

                                            chi_sq_period_quant_peaks <- zeitgebr::find_peaks(chi_sq_period_quant)
                                            chi_sq_summary <- chi_sq_period_quant_peaks[chi_sq_period_quant_peaks$peak==1, ]
                                            chi_sq_summary$period <- as.double(chi_sq_summary$period/3600)
                                            chi_sq_summary2 <- merge(data.table::data.table(id = all_ids), chi_sq_summary, by = "id", all.x = TRUE)
                                            self$peak_tbl$xsq <- chi_sq_period_quant_peaks
                                            self$period_tbl$xsq <- chi_sq_summary2
                                            period_table <- chi_sq_summary2
                                            # compute periodogram plots
                                            Annotate$plot_periodogram(method = "chi_sq_periodogram", FunEnv = env)
                                          },
                                          ac = NULL,
                                          ls = NULL,
                                          fourier = NULL,
                                          cwt = NULL,
                                          "ac_periodogram" = {
                                            ac_period_quant <- zeitgebr::periodogram(value,
                                                                                     data,
                                                                                     period_range = c(behavr::hours(20),
                                                                                                      behavr::hours(30)),
                                                                                     resample_rate = 1/behavr::mins(3),
                                                                                     alpha = 0.05,
                                                                                     FUN = zeitgebr::ac_periodogram)

                                            ac_period_quant_peaks <- zeitgebr::find_peaks(ac_period_quant)
                                            ac_summary <- ac_period_quant_peaks[ac_period_quant_peaks$peak==1, ]
                                            ac_summary$period <- ac_summary$period/3600
                                            # add missing values
                                            ac_summary2 <- merge(data.table::data.table(id = all_ids), ac_summary, by = "id", all.x = TRUE)
                                            self$peak_tbl$ac <- ac_period_quant_peaks
                                            self$period_tbl$ac <- ac_summary2
                                            period_table <- ac_summary2
                                            # compute periodogram plots
                                            Annotate$plot_periodogram(method = "ac_periodogram", FunEnv = env)
                                          },
                                          "ls_periodogram" = {
                                            ls_period_quant <- zeitgebr::periodogram(value,
                                                                                     data,
                                                                                     period_range = c(behavr::hours(20), behavr::hours(30)),
                                                                                     resample_rate = 1/behavr::mins(1),
                                                                                     alpha = 0.05,
                                                                                     FUN = zeitgebr::ls_periodogram)#oversampling = 24))

                                            ls_quant_peaks <- zeitgebr::find_peaks(ls_period_quant)
                                            ls_summary <- ls_quant_peaks[ls_quant_peaks$peak==1, ]
                                            ls_summary$period <- as.double(ls_summary$period/3600)
                                            ls_summary2 <- merge(data.table::data.table(id = all_ids), ls_summary, by = "id", all.x = TRUE)
                                            self$peak_tbl$ls <- ls_quant_peaks
                                            self$period_tbl$ls <- ls_summary2
                                            period_table <- ls_summary2
                                            # compute periodogram plots
                                            Annotate$plot_periodogram(method = "ls_periodogram", FunEnv = env)
                                          },
                                          "fourier_periodogram" = {
                                            fourier_period_quant <- zeitgebr::periodogram(value,
                                                                                          data,
                                                                                          period_range = c(behavr::hours(20), behavr::hours(30)),
                                                                                          resample_rate = 1/behavr::mins(2),
                                                                                          alpha = 0.05,
                                                                                          FUN = zeitgebr::fourier_periodogram)

                                            fourier_period_quant_peaks <- zeitgebr::find_peaks(fourier_period_quant)
                                            fourier_summary <- fourier_period_quant_peaks[fourier_period_quant_peaks$peak==1, ]
                                            fourier_summary$period <- as.double(fourier_summary$period/3600)
                                            fourier_summary2 <- merge(data.table::data.table(id = all_ids), fourier_summary, by = "id", all.x = TRUE)
                                            self$peak_tbl$fourier <- fourier_period_quant_peaks
                                            self$period_tbl$fourier <- fourier_summary2
                                            period_table <- fourier_summary2
                                            # compute periodogram plots
                                            Annotate$plot_periodogram(method = "fourier_periodogram", FunEnv = env)
                                          },
                                          "cwt_periodogram" = {
                                            cwt_period_quant <- zeitgebr::periodogram(value,
                                                                                      data,
                                                                                      period_range = c(behavr::hours(20), behavr::hours(30)),
                                                                                      resample_rate = 1/behavr::mins(6),
                                                                                      alpha = 0.05,
                                                                                      FUN = zeitgebr::cwt_periodogram)

                                            cwt_quant_peaks <- zeitgebr::find_peaks(cwt_period_quant)
                                            cwt_summary <- cwt_quant_peaks[cwt_quant_peaks$peak==1, ]
                                            cwt_summary$period <- as.double(cwt_summary$period/3600)
                                            cwt_summary2 <- merge(data.table::data.table(id = all_ids), cwt_summary, by = "id", all.x = TRUE)
                                            self$peak_tbl$cwt <- cwt_quant_peaks
                                            self$period_tbl$cwt <- cwt_summary2
                                            period_table <- cwt_summary2
                                            # compute periodogram plots
                                            Annotate$plot_periodogram(method = "cwt_periodogram", FunEnv = env)
                                          },
                                          "FFT-NLLS" = {
                                            #convert to hours
                                            data$t <- data$t/3600
                                            unique_ids = unique(data$id)
                                            results_list <- list()
                                            # Initialize an empty list to store results
                                            plot_list <- list()
                                            for (i in seq_len(length(unique_ids))) {

                                              # Filter data for the current ID
                                              id = unique_ids[i]
                                              toget = which(data$id == id)
                                              data_id <- data[toget,]

                                              # perform linear detrending (handle NAs -- lm drops them, residuals are shorter)
                                              complete_idx <- which(!is.na(data_id$value))
                                              if (length(complete_idx) > 1) {
                                                fit <- lm(data_id$value[complete_idx] ~ data_id$t[complete_idx])
                                                detrended_full <- rep(NA_real_, nrow(data_id))
                                                detrended_full[complete_idx] <- residuals(fit)
                                                data_id$value <- detrended_full
                                              }
                                              # Estimate period and other parameters
                                              result <- self$fft_nlls_period(data_id)

                                              # Add the ID to the result
                                              result$id <- id
                                              result$group <-  "exp"

                                              # Append the result to the results list
                                              results_list[[id]] <- result

                                              data_id$fitted <- with(result, amplitude * sin(2 * pi * data_id$t / period + phase_rad) + offset)
                                              plot_list[[id]] <- ggplot2::ggplot(data_id, ggplot2::aes(x = t)) +
                                                ggplot2::geom_line(ggplot2::aes(y = value), color = "blue") +
                                                ggplot2::geom_line(ggplot2::aes(y = fitted), color = "red") +
                                                ggplot2::labs(title = "Timeseries Data with Fitted Sinusoidal Model",
                                                     x = "Time", y = "Value") +
                                                ggplot2::theme_minimal()
                                            }
                                            period_table = do.call(rbind, lapply(results_list, as.data.frame))
                                            # round all digits in the table
                                            period_table <- period_table %>%
                                              dplyr::mutate(dplyr::across(.cols = -all_of(c("id", "group")), ~ round(., 2)))
                                            self$period_tbl$fft <- period_table
                                            self$period_tbl$fft_plots <- plot_list
                                          }
                                   ) # end of switch
                                   # reduce number of significant digits
                                   period_table$period <- round(period_table$period, 2)
                                   return(period_table)

                                 } # end of if statement
                               }, # end of new_compute_per

                              #' fft_nlls_period
                              #'
                              #' @param data the data to be analysed. A table containing id, t and value columns
                              #'
                              #' @return a table of resultys containing Period length, phase, amplitude, offset and error

                                fft_nlls_period = function(data) {
                                  # Drop NAs before FFT — NAs propagate through fft() and make
                                  # which.max() return integer(0), causing nls.lm length mismatch.
                                  valid_idx <- !is.na(data$value)
                                  fft_vals  <- data$value[valid_idx]
                                  fft_t     <- data$t[valid_idx]
                                  n_valid   <- length(fft_vals)

                                  if (n_valid < 10) {
                                    return(list(period = NA_real_, amplitude = NA_real_,
                                                phase_rad = NA_real_, phase_circ = NA_real_,
                                                phase_abs = NA_real_, offset = NA_real_,
                                                error = NA_real_, GOF = NA_real_, RAE = NA_real_))
                                  }

                                  # Perform FFT on complete cases
                                  n          <- n_valid
                                  dt         <- mean(diff(fft_t))
                                  fft_result <- stats::fft(fft_vals)
                                  frequencies <- seq(0, 1/dt, length.out = n)

                                  # Identify the dominant frequency (excluding the zero frequency)
                                  dominant_idx <- which.max(base::Mod(fft_result)[2:floor(n/2)])
                                  if (length(dominant_idx) == 0) {
                                    initial_period <- 24  # fallback to circadian period
                                  } else {
                                    dominant_frequency <- frequencies[dominant_idx + 1]
                                    initial_period <- if (is.finite(dominant_frequency) && dominant_frequency > 0) {
                                      1 / dominant_frequency
                                    } else 24
                                  }

                                  # Define the sinusoidal model function
                                  sinusoidal_model = function(params, t) {
                                    amplitude <- params[1]
                                    period <- params[2]
                                    phase <- params[3]
                                    offset <- params[4]
                                    return(amplitude * sin(2 * pi * t / period + phase) + offset)
                                  }

                                  # Define the residual function for nonlinear least squares
                                  residuals = function(params, t, y) {
                                    return(y - sinusoidal_model(params, t))
                                  }

                                  # Initial parameter estimates (using NA-free vectors)
                                  initial_amplitude <- (max(fft_vals) - min(fft_vals)) / 2
                                  initial_phase <- 0
                                  initial_offset <- mean(fft_vals)
                                  initial_params <- c(initial_amplitude, initial_period, initial_phase, initial_offset)

                                  # Perform nonlinear least squares fitting on complete cases
                                  fit <- minpack.lm::nls.lm(
                                    par = initial_params,
                                    fn = residuals,
                                    t = fft_t,
                                    y = fft_vals,
                                    lower = c(-Inf, 12, -Inf, -Inf),
                                    upper = c(Inf, 32, Inf, Inf)
                                    )

                                  # Extract fitted parameters
                                  fitted_params <- fit$par
                                  fitted_amplitude <- fitted_params[1]
                                  fitted_period <- fitted_params[2]
                                  fitted_phase <- fitted_params[3]
                                  fitted_offset <- fitted_params[4]

                                  # Ensure the amplitude is positive
                                  if (fitted_amplitude < 0) {
                                    fitted_amplitude <- abs(fitted_amplitude)
                                    fitted_params[1] <- fitted_amplitude
                                    fitted_phase <- fitted_phase + pi  # Adjust the phase by 180 degrees (pi radians)
                                    fitted_params[3] <- fitted_phase
                                  }

                                  # Wrap the phase into the 0-2pi radians range
                                  if (fitted_phase > 2*pi) {
                                    fitted_phase <- fitted_phase %% 2*pi
                                  }
                                  if (fitted_phase < 0) {
                                    fitted_phase <- fitted_phase + 2*pi
                                  }

                                  # Convert phase to time units (hours)
                                  fitted_phase <- circular::as.circular(fitted_phase, type = "angles", units = "radians",
                                                                        rotation = "clock", template = "none", modulo = "asis", zero = 0)
                                  phase_circadian <- circular::conversion.circular(fitted_phase, units = "hours")
                                  phase_absolute <- phase_circadian*(fitted_period/24)

                                  # Compute residual error (using NA-free vectors)
                                  fitted_values <- sinusoidal_model(fitted_params, fft_t)
                                  residual_error <- sqrt(mean((fft_vals - fitted_values)^2))

                                  # Calculate R-squared (GOF)
                                  ss_total <- sum((fft_vals - mean(fft_vals))^2)
                                  ss_res <- sum((fft_vals - fitted_values)^2)
                                  r_squared <- 1 - (ss_res / ss_total)

                                  # Compute standard deviation of residuals
                                  residual_std <- sqrt(sum((fft_vals - fitted_values)^2) / (length(fft_vals) - length(fitted_params)))

                                  # Compute RAE
                                  RAE <- residual_std / fitted_amplitude


                                  # Return the results
                                  result <- list(
                                    period = fitted_period,
                                    amplitude = fitted_amplitude,
                                    phase_rad = fitted_phase,
                                    phase_circ = phase_circadian,
                                    phase_abs = phase_absolute,
                                    offset = fitted_offset,
                                    error = residual_error,
                                    GOF = r_squared,
                                    RAE = RAE
                                  )
                                  return(result)
                                },

                               ##### OLD FUNCTIONS #####

                               #' dailyAct
                               #'
                               #' @param subsetVal Yes/No value
                               #' @param env environment containing myCleanMice object
                               #'
                               #' @description function to generate the sum of the activity for each day and
                               #'     store it on a table.

                               dailyAct = function(env, subsetVal){ #substitute x with env in whole fun
                                 # browser()
                                 #switch to allow for data subsetting
                                 switch(subsetVal,
                                        "Yes" = {
                                          filteredMice <- env$subsetting$miceListFiltered$pos
                                          range = c((env$subsetting$timespan[1]*1440),(env$subsetting$timespan[2]*1440))
                                        },
                                        "No" = {
                                          filteredMice <- seq_len(length(env$env2$myCleanMice))
                                          range = c(0,max(env$env2$Annotate$metaTable$Datapoints))
                                        })
                                 startDay = range[1]/1440
                                 mouseData <- env$env3$myCleanMice[filteredMice]
                                 number <- 86400/env$App_settings$timepointDur #number of timepoints in a day

                                 activity <- dplyr::tibble("id" = as.character(), #resolve similarity between table name and field Activity
                                                           "Day" = as.numeric(),
                                                           "Activity" = as.numeric(),
                                                           "Cabinet" = as.numeric(),
                                                           "Sex" = as.character(),
                                                           "Genotype" = as.character())
                                 for (h in seq_len(length(filteredMice))){
                                   #if condition to handle time subsetting
                                   if(subsetVal == "Yes"){
                                     range1 <- which(mouseData[[h]]$timepoint >= range[1]*60)
                                     range2 <- which(mouseData[[h]]$timepoint <= range[2]*60)
                                     range3 <- intersect(range1, range2)
                                     mouseData[[h]]$countsMinute <- mouseData[[h]]$countsMinute[range3]    #filter based on timepoint
                                     mouseData[[h]]$timepoint <- mouseData[[h]]$timepoint[range3]  #filter based on timepoint
                                     mouseData[[h]]$realTime <- mouseData[[h]]$realTime[range3]    #filter based on timepoint
                                   }
                                   d1 <- split(mouseData[[h]]$countsMinute, ceiling(seq_along(mouseData[[1]]$countsMinute)/1440))
                                   d2 <- lapply(d1, sum)
                                   d3 <- dplyr::tibble("id" = mouseData[[h]]$id,
                                                       "Day" = seq(from = startDay, length.out = length(d2)),
                                                       "Activity" = unlist(d2),
                                                       "Cabinet" = mouseData[[h]]$cabinet,
                                                       "Sex" = mouseData[[h]]$sex,
                                                       "Genotype" = mouseData[[h]]$genotype,
                                   )
                                   activity <- rbind(activity, d3)
                                 }
                                 self$daily_act[[1]] <- activity
                                 #create wide table for export
                                 activity_wide <- activity %>%
                                   tidyr::pivot_wider(
                                     names_from = c(id, Genotype, Sex, Cabinet),
                                     values_from = Activity,
                                     names_glue = "{id}_{Sex}_{Genotype}_{Cabinet}",
                                     values_fill = 0
                                   )
                                 self$daily_act[[2]] <- activity_wide
                               },

                               #' AvgDay
                               #' @description function to create tibble with mouse activity daily grouped in
                               #'     15 minutes bins
                               #'
                               #' @param per_len customizable period length value, used to normalise Circadian day
                               #' @param env App_settings environment
                               #' @param subsetVal Yes/No value
                               #'
                               #' @return A table with the sum

                               AvgDay = function(env, per_len, subsetVal){ #handle NA values to avoid dropping of values
                                 d6 <- NULL
                                 #browser()
                                 #switch to allow for data subsetting
                                 switch(subsetVal,
                                        "Yes" = {
                                          # subset_input_check(idlist = App_settings$subsetting$miceListFiltered)
                                          idlist = env$subsetting$miceListFiltered
                                          if (is.na(idlist) || is.null(idlist)){
                                            shinyjs::alert("You need to select at least one animal in the subsetting options")
                                          }
                                          req(!is.null(idlist))
                                          filteredMice <- env$subsetting$miceListFiltered$pos
                                          range = c((env$subsetting$timespan[1]*1440),(env$subsetting$timespan[2]*1440))
                                        },
                                        "No" = {
                                          filteredMice <- seq_len(length(env$env2$myCleanMice))
                                          range = c(0,max(env$env2$Annotate$metaTable$Datapoints))
                                        })
                                 myCleanMice <- env$env3$myCleanMice[filteredMice]
                                 for (i in seq_len(length(myCleanMice))){
                                   #get light length
                                   light_len <- env$LDparams$light
                                   # discard half of light_len to align data
                                   discard_first <- (light_len/2)*60
                                   allData <- myCleanMice[[i]]

                                   #if condition to handle time subsetting
                                   if(subsetVal == "Yes"){
                                     range1 <- which(allData$timepoint >= range[1]*60)
                                     range2 <- which(allData$timepoint <= range[2]*60)
                                     range3 <- intersect(range1, range2)
                                     allData$countsMinute <- allData$countsMinute[range3]    #filter based on timepoint
                                   }
                                   data <- allData$countsMinute
                                   data <- data[-(1:discard_first), drop = FALSE]
                                   id <- as.factor(myCleanMice[[i]]$id)
                                   sex <- as.character(myCleanMice[[i]]$sex)
                                   genotype <- as.character(myCleanMice[[i]]$genotype)
                                   # split into daily chunks and divide into columns
                                   # add option to split data based on animal period length
                                   d1 <- split(data, ceiling(seq_along(data)/per_len))
                                   # elongate last chunk to 1440
                                   ## register the length of missing part and return a
                                   ## message if too short, maybe discard data
                                   toAdd <- replicate((per_len-length(d1[[length(d1)]])), 0)
                                   d1[[length(d1)]] <- append(d1[[length(d1)]], toAdd)
                                   ## compute mean across days
                                   d2 <- rowMeans(do.call(cbind, d1), na.rm = TRUE)
                                   # reduce and get the sum of 15 minutes chunks
                                   d3 <- split(d2, ceiling(seq_along(d2)/15))
                                   # from list of vectors of length 1 get the atomic values into a vector
                                   d4 <- unlist(lapply(d3, sum), recursive = TRUE, use.names = FALSE)
                                   d5 <- data.frame(seq(0, 23.75, by = 0.25), id,  d4, sex, genotype)
                                   d6 <- rbind(d6, d5)
                                 }
                                 d7 <- dplyr::tibble(
                                   "CT" = d6[,1],
                                   "mouse" = d6$id,
                                   "activity" = d6$d4,
                                   "sex" = d6$sex,
                                   "genotype" = d6$genotype)
                                 self$average_day[[1]] <- d7

                                 #create wide table for export
                                 avg_day_wide <- d7 %>%
                                   tidyr::pivot_wider(
                                     names_from = c(mouse, genotype, sex),
                                     values_from = activity,
                                     names_glue = "{mouse}_{sex}_{genotype}",
                                     values_fill = 0
                                   )
                                 self$average_day[[2]] <- avg_day_wide

                                 # create wide table that summarizes between males and females

                               }

                             )
)

#' @noRd
