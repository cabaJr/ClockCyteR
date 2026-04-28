#' App_settings
#'
#' @description App_settings R6 class object
#'
#' @details A R6 class object to contain parameters of the app that can be
#'     accessible from the global.env, making possible to communicate between
#'     different R6 objects
#'
#' @return The return value, if any, from executing the function.
#' @importFrom dplyr tibble
#' @noRd

App_settings <-
  R6::R6Class("App_settings",
              public = list(
#' @field dashboardHeader_appearance TRUE/FALSE to enable/disable dashboard header
#' @field fileType type of files uploaded by user
#' @field dataList is a list of file paths uploaded by the user
#' @field listSamples list of sample names
#' @field plotTab list containing values for showing/hiding elements in Plots Tab
#' @field env1 contains environment #1
#' @field env2 contains environment #2
#' @field env3 contains environment #3
#' @field env4 contains environment #4
#' @field env_msg contains the environment of Message obj
#'
              dashboardHeader_appearance = TRUE,
              fileType = NULL,
              dataList = NULL,
              listSamples = NULL,
              vessels = list(FrontLeft = FALSE,
                             FrontRight = FALSE,
                             CentreLeft = FALSE,
                             CentreRight = FALSE,
                             RearLeft = FALSE,
                             RearRight = FALSE
              ),
              plotTab = list(tab = FALSE,
                             DPActo = FALSE,
                             acto = FALSE,
                             dayAct = FALSE,
                             period = FALSE,
                             avgDay = FALSE
              ),
              env1 = NULL,
              env2 = NULL,
              env3 = NULL,
              env4 = NULL,
              env_msg = NULL,

#' setData
#'
#' @param outsideData list of data files uploaded by the user
#'
              setData = function(outsideData){
                self$dataList <- outsideData
              },


#' setListSample
#'
#' @param env environment
#'
              setListSample = function(env){
                sampleList <- env$env2$myCleanSample
                d2 <- dplyr::tibble(
                  "pos" = as.numeric(),
                  "id" = as.character()
                )
                for(i in seq_along(1:length(sampleList))){
                  d1 <- dplyr::tibble(
                    "pos" = i,
                    "id" = sampleList[[i]]$sampleName
                  )
                  d2 <- rbind(d2, d1)
                }
                env$listSamples <- d2
              },

#' setListSampleFiltered
#'
#' @param x environment
#' @param idList list containing sample ids
#' @param genList list containing sample genotypes #TODO find a way to get 'genotype' from plate map
#'
              setListSampleFiltered = function(x, idList, genList){
                metadata <- x$Annotate$metaTable
                # browser()
                metadata$id <- as.character(metadata$id)
                idvector <- unlist(metadata[,1], use.names = FALSE)
                listSamples <- self$listSamples
                t1 = idList
                t2 = idvector[which(metadata$Genotype %in% genList)]
                # browser()
                d1 <- c(t1, t2)
                d2 <- unique(d1)
                d3 <- listSamples[listSamples$id %in% d2,]
                # browser()
                self$subsetting$sampleListFiltered = d3
              },

#' setExpstart
#'
#' @param ExpStart date value for when the experiment starts
#'
              setExpstart = function(ExpStart){
                self$ExpStart = ExpStart
              },

#' setVessel
#'
#' @param vessel string to modify the specified vessel
#' @description
#' Function to set which vessels have been uploaded
#'
#'
#' @return no value returned. Internal side effect

              setVessel = function(vessel){
                switch(vessel,
                       "Front-left" = {self$vessels$FrontLeft = TRUE},
                       "Front-right" = {self$vessels$FrontRight = TRUE},
                       "Centre-left" = {self$vessels$CentreLeft = TRUE},
                       "Centre-right" = {self$vessels$CentreRight = TRUE},
                       "Rear-left" = {self$vessels$RearLeft = TRUE},
                       "Rear-right" = {self$vessels$RearRight = TRUE}
                       )
                },

#' getVessel
#'
#' @param vessel string to retrieve the specified vessel
#' @description
#' Function to see if this vessel has been uploaded already
#'
#' @return TRUE/FALSE

              getVessel = function(vessel){
                switch(vessel,
                       "Front-left" = {present = self$vessels$FrontLeft},
                       "Front-right" = {present = self$vessels$FrontRight},
                       "Centre-left" = {present = self$vessels$CentreLeft},
                       "Centre-right" = {present = self$vessels$CentreRight},
                       "Rear-left" = {present = self$vessels$RearLeft},
                       "Rear-right" = {present = self$vessels$RearRight}
                )
                return(present)
                }


            ))
