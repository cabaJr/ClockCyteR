#' R6_raw_data
#'
#' @description R6_Raw_data R6 class object
#'
#' @details A R6 class object to contain the uploaded files divided into data and
#'    metadata. Also contains the key (channel) to which the data refer to.
#'    Performs first round of preprocessing to store data in a convenient format
#'    to be further processed.
#' @return The return value, if any, from executing the function.
#'
#' @noRd


Raw_sample_data <- R6::R6Class("Raw_data",
                               list(
                                 #' @field key key describing what channel the data refer to
                                 #' @field metadata the first 6 rows of the txt file
                                 #' @field data the values contained after the first 6 rows
                                 #' @field samples number of samples
                                 #' @field length length of data
                                 #'
                                 key = as.character(),
                                 metadata = as.data.frame(NULL),
                                 data = as.data.frame(NULL),
                                 samples = as.numeric(),
                                 length = as.numeric(),
                                 #' initialize
                                 #'
                                 #' @return initializes some field with the required type
                                 #'
                                 initialize = function(){
                                   key = as.character()
                                   metadata = data.frame()
                                   data = data.frame()
                                   samples = as.numeric()
                                 },
                                 #' add
                                 #'
                                 #' @param datapath path where to find the uploaded data filed
                                 #' @param key value representing the channel that the data refer to
                                 #' @param env App_settings environment
                                 #'
                                 #' need to implement a function that from the txt file outputted from Incucyte it
                                 #' brings the values to a structure similar to the one in the previous MACEr
                                 #' version. This is in order to simplify the data handling progression.
                                 #'
                                 add = function(datapath, env, key = NULL){ #function to read from csv files and insert data inside the object
                                   path <- datapath
                                   # extract from txt file. Data are contained past the first 6 rows
                                   data <- utils::read.table(path, skip = 6, dec = ".", header = TRUE, sep = "\t", check.names = FALSE)
                                   metadata <- utils::read.table(path, nrows = 6, sep = ":")
                                   colnames(metadata) <- c("Field", "Value")
                                   samples <- ncol(data) - 2

                                   # fill data
                                   self$key <- key
                                   self$metadata <- metadata
                                   self$data <- data
                                   self$samples <- samples
                                   self$length <- {nrow(data)}
                                 }
                               )
)
