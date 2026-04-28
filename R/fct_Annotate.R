#' Annotate
#'
#' @description R6 class object used for generating and storing plots and other
#'     processed data. It is accessed internally to display data. Each top level
#'     list contains a different type of plot. Sublists are organised to store
#'     different plot versions.
#'     Functions for plotting (i.e. plot_actogram, plot_DAct) get data from
#'     fct_R6_Custom_tables object and generate a plot that is saved into the
#'     relative list.
#'     There should be a method to pass plots to an external container based on
#'     the handler.
#'
#' @return An Annotate object
#'

Annotate <-
  R6::R6Class("Annotate",
    list(
#' @field store named list used as a keyed registry for all plot objects.
#' Use store_obj(key, object) and retrieve_obj(key) to read and write.
#' Keys used in the app: "ts_original", "ts_annotated",
#' "periodogram_total", "periodogram_faceted", "periodogram_averaged",
#' "period_barplot".
#' @field actTable Table containing data assembled using showData()
#' @field metaTable Table containing data assembled using showMeta()
      store = list(),
      actTable = NULL,
      metaTable = NULL,
#' showMeta
#' @description function to create a table that arranges all the available
#' metadata in a table, and saves it in metaTable var
#' @param env App_settings environment to access myCleanMice object
#'
#' @return no return

      showMeta = function(env){
        # browser()
        myCleanMice <- env$myCleanMice
        d1 <- dplyr::tibble(
          "id" = as.character(),
          "Sex" = as.character(),
          "Genotype" = as.character(),
          "Cabinet" = as.character(),
          "Light_On" = as.character(),
          "Datapoints" = as.character()
        )
        for(h in seq_len(length(myCleanMice))){
          d2 <- dplyr::tibble(
            "id" = myCleanMice[[h]]$id,
            "Sex" = myCleanMice[[h]]$sex,
            "Genotype" = myCleanMice[[h]]$genotype,
            "Cabinet" = myCleanMice[[h]]$cabinet,
            "Light_On" = myCleanMice[[h]]$lightOn,
            "Datapoints" = myCleanMice[[h]]$length
          )
          d1 <- rbind(d1, d2)
        }
        self$metaTable <- d1
      },

#' showdata
#'
#' @description function to create a table that arranges activity data in a
#' table, and saves it in actTable var
#' @param env App_settings environment to access myCleanMice object
#' @param id mouse Id value from the list of Ids or "All" to display all data
#' @param miceList list of all available mouse Ids
#' @return no return

      showData = function(env, id, miceList){
        myCleanMice <- env$myCleanMice
        d2 <- dplyr::tibble(
          "id" = as.character(),
          "Sex" = as.character(),
          "Genotype" = as.character(),
          "Real time" = as.character(),
          "Time point" = as.character(),
          "Days" = as.character(),
          "Activity" = as.character()
        )
        if (id == "All"){
          for (h in seq_len(length(myCleanMice))){
            d1 <- dplyr::tibble(
              "id" = myCleanMice[[h]]$id,
              "Sex" = myCleanMice[[h]]$sex,
              "Genotype" = myCleanMice[[h]]$genotype,
              "Real time" = myCleanMice[[h]]$realTime,
              "Time point" = myCleanMice[[h]]$timepoint,
              "Days" = round(((myCleanMice[[h]]$timepoint)/86400), 2),
              "Activity" = myCleanMice[[h]]$countsMinute
            )
            d2 <- rbind(d2, d1)
          }

        }else if(id == ""){

        }else{
          id <- id
          miceList <- miceList
          y <- which(miceList$id == id)
          h <- as.numeric(miceList[y, 1])
          d2 <- dplyr::tibble(
            "id" = myCleanMice[[h]]$id,
            "Sex" = myCleanMice[[h]]$sex,
            "Genotype" = myCleanMice[[h]]$genotype,
            "Real time" = myCleanMice[[h]]$realTime,
            "Time point" = myCleanMice[[h]]$timepoint,
            "Days" = round(((myCleanMice[[h]]$timepoint)/86400), 2),
            "Activity" = myCleanMice[[h]]$countsMinute
          )
        }
        self$actTable <- d2
      },

#' store_obj
#' @description a function to store objects inside the Annotate R6 obj
#'
#' @param object the object to be stored
#' @param key string to discriminate cases for storing file
#'
#' @return no value returned

      store_obj = function(key, object){
        self$store[[key]] <- object
      },

#' retrieve_obj
#' @description retrieve a stored object by key
#'
#' @param key string key used when storing the object
#'
#' @return the stored object, or NULL if the key does not exist

      retrieve_obj = function(key){
        self$store[[key]]
      },

#' plot_Timeserie
#'
#' @description a function to create Timeseries plots
#'
#' @param datatable list contain all the data
#' @param value string to select data source: original, detrended or cleaned
#' @param env environment. App settings environment
#' @param data1 Boolean. is dataset 1 present?
#' @param data2 Boolean. is dataset 2 present?
#' @param data3 Boolean. is dataset 3 present?
#' @param timeformat String. is the time in hours or posixt
#' @param tmin double. minimum time to be plotted
#' @param tmax double. maximum time to be plotted
#'
#' @return a ggplot object

      plot_Timeserie = function(datatable, value, env, tmin = 0, tmax = 999.81, data1 = TRUE, data2 = FALSE, data3 = FALSE, timeformat = "Hours"){
        # assign table to data variable
        data <- datatable
        subset <- NULL

        # extract time data
        if(timeformat == "Hours"){timevar <- data$elapsed}
        else if(timeformat == "Real time"){timevar <- data$realTime}

        # get timedata between subsetting options
        if(!(tmin == 0) || !(tmax == 999.81)){
          tmin = tmin
          tmax = tmax
          timevar = timevar
          subset <- which(timevar <= tmax & timevar >= tmin)
          timevar <- timevar[subset]
        }

        if(value == "original"){values1 = data$intensity}else
          if(value == "detrended"){values1 = data$detrended}else
            if(value == "cleaned"){values1 = data$intensity_clean}
        # assign data
        if(data1){ch1 <- values1}
        if(data2){ch2 <- data$intensity1} # TODO add compatibility with multiple channels
        if(data3){ch3 <- data$intensity1}

        # subset data
        if(!is.null(subset)){
          ch1 <- ch1[subset]
        }

        plt_title <- stringr::str_c(data$sampleName)#, data$img_number, sep = ", Image ")
        plt_sub <- data$vesselName
        yaxis <- stringr::str_wrap(data$metric, width = 26)
        # get data
        df <- data.frame(timevar = timevar, ch1 = ch1)
        group_label <- if (!is.null(data$sampleGroup) && nzchar(data$sampleGroup) && data$sampleGroup != "Exp") {
          paste0("<br>Group: ", data$sampleGroup)
        } else ""
        df$hover_text <- paste0(
          "ID: ", data$sampleName,
          group_label,
          "<br>Metric: ", data$metric,
          "<br>Time: ", round(df$timevar, 2), " h",
          "<br>Value: ", round(df$ch1, 2)
        )

        use_days <- max(df$timevar, na.rm = TRUE) > 240
        if (use_days) {
          df$timevar <- df$timevar / 24
          grp <- if (
            !is.null(data$sampleGroup) &&
              nzchar(data$sampleGroup) &&
              data$sampleGroup != "Exp"
          ) paste0("<br>Group: ", data$sampleGroup) else ""
          df$hover_text <- paste0(
            "ID: ", data$sampleName,
            grp,
            "<br>Metric: ", data$metric,
            "<br>Time: ", round(df$timevar, 2), " days",
            "<br>Value: ", round(df$ch1, 2)
          )
          xlab       <- "Time (days)"
          step_major <- 1
          step_minor <- 0.5
        } else {
          xlab       <- "Time (hours)"
          step_major <- 24
          step_minor <- 12
        }
        xbreaks <- seq(
          from = floor(min(df$timevar)),
          to   = ceiling(max(df$timevar)),
          by   = step_major
        )
        xminbreaks <- seq(
          from = floor(min(df$timevar)),
          to   = ceiling(max(df$timevar)),
          by   = step_minor
        )

        #create plot
        plot_object <- ggplot2::ggplot()+
          ggplot2::geom_line(data = df, ggplot2::aes(x = timevar, y = ch1), linewidth = 0.75)+
          ggplot2::labs(
            title = plt_title,
            subtitle = plt_sub
          ) +
          ggplot2::scale_y_continuous(name = yaxis)+
          ggpubr::theme_pubr()+
          ggplot2::theme(
          plot.title = ggplot2::element_text(hjust = 0.5, size = 14),
          plot.subtitle = ggplot2::element_text(hjust = 0.5, size = 12),
          axis.text = ggplot2::element_text(size = 11),
          axis.title.y = ggplot2::element_text(size = 13, margin = ggplot2::margin(r = 12)),
          axis.title.x = ggplot2::element_text(size = 13),
          panel.grid.major.x = ggplot2::element_line(color = "black",
                                            linewidth = 0.5,
                                            linetype = 2))+
          ggplot2::scale_x_continuous(name = xlab, breaks = xbreaks, minor_breaks = xminbreaks)+
          ggplot2::theme(plot.background = ggplot2::element_rect(fill = "transparent", colour = NA),
                         legend.background = ggplot2::element_rect(fill = "transparent"),
                         panel.background = ggplot2::element_rect(fill = "transparent")
          )




        #return plot object
        return(plot_object)

      },


#' plot_Timeserie_facet
#'
#' @description a function to create Timeseries plots stacked inside a grid
#'
#' @param datalist list contain all the data
#' @param value string to select data source: original, detrended or cleaned
#' @param env environment. App settings environment
#' @param data1 Boolean. is dataset 1 present?
#' @param data2 Boolean. is dataset 2 present?
#' @param data3 Boolean. is dataset 3 present?
#' @param timeformat String. is the time in hours or posixt
#' @param tmin double. minimum time to be plotted
#' @param tmax double. maximum time to be plotted
#'
#' @return a ggplot object

      plot_Timeserie_facet = function(datalist, value, env, tmin = 0, tmax = 999.81, data1 = TRUE, data2 = FALSE, data3 = FALSE, timeformat = "Hours"){
        # browser()

        # assign table to data variable
        datalist <- datalist

        # extract time data
        if(timeformat == "Hours"){timevar <- datalist[[1]]$elapsed}
        else if(timeformat == "Real time"){timevar <- datalist[[1]]$realTime} #TODO implement real time option

        #create table containing all values
        time_values <- timevar

        #create initial dataframe
        df <- data.frame(Time = time_values)

        # Iterate over the remaining elements of the list
        for (i in seq_len(length(datalist))) {
          # assign the detrended/original/cleaned values
          if(value == "original"){values1 = datalist[[i]]$intensity}else
            if(value == "detrended"){values1 = datalist[[i]]$detrended}else
              if(value == "cleaned"){values1 = datalist[[i]]$intensity_clean}
          # assign data
          if(data1){ch1 <- values1}
          if(data2){ch2 <- data$intensity1} # TODO add compatibility with multiple channels
          if(data3){ch3 <- data$intensity1}

          # Extract values and sample name

          values <- values1
          sample_name <- datalist[[i]]$sampleName

          # Add values as a new column with the sample name as the column title
          df[[sample_name]] <- values
        }


        subset <- NULL

        # get timedata between subsetting options
        if(!(tmin == 0) || !(tmax == 999.81)){
          tmin = tmin
          tmax = tmax
          timevar = timevar
          subset <- which(timevar <= tmax & timevar >= tmin)
          timevar <- timevar[subset]
        }

        # subset data
        if(!is.null(subset)){
          ch1 <- ch1[subset]
        }

        plt_sub <- datalist[[1]]$vesselName
        yaxis <- stringr::str_wrap(datalist[[1]]$metric, width = 58)
        # modify time to days
        df$Time <- round((df$Time/24), digits = 2)

        xbreaks <- seq(from = 0, to = max(df$Time), by = 1)
        xminbreaks <- seq(from = 0, to = max(df$Time), by = 0.5)

        # transform data in long table
        df <- tidyr::pivot_longer(df, cols = c(2:length(colnames(df))), values_to = "intensity", names_to = "samplename")

        #create plot
        plot_object <- ggplot2::ggplot()+
          ggplot2::geom_line(data = df, ggplot2::aes(x = Time, y = intensity), linewidth = 0.4)+
          ggplot2::labs(
            title = NULL,
            subtitle = NULL
          ) +
          ggplot2::scale_y_continuous(name = yaxis)+
          ggpubr::theme_pubr()+
          ggplot2::theme(
            plot.title = ggplot2::element_blank(),
            axis.text = ggplot2::element_text(size = 6),
            axis.title.y = ggplot2::element_text(size = 9),
            axis.title.x = ggplot2::element_text(size = 9),
            panel.grid.major.x = ggplot2::element_line(color = "black",
                                                       linewidth = 0.25,
                                                       linetype = 2),
            plot.background = ggplot2::element_rect(fill = "transparent", colour = NA),
            legend.background = ggplot2::element_rect(fill = "transparent"),
            panel.background = ggplot2::element_rect(fill = "transparent")
            )+
          ggplot2::scale_x_continuous(name = "Time (days)", breaks = xbreaks, minor_breaks = xminbreaks)+
          ggplot2::facet_wrap(~samplename, ncol = 6)+
          ggplot2::theme(strip.text = ggplot2::element_text(size = 8))

        #return plot object
        return(plot_object)

      },

#' plot_periodogram
#'
#' @description
#' Function to generate periodogram plots
#'
#' @param method function to use from zeitgebr::periodogram function
#' @param plotType the different type of plots to generate. default to total and faceted
#' @param FunEnv AppSettings environment
#'
#' @return function returns internally, no direct output
#'
      plot_periodogram = function(method, plotType = c("Pertotal", "Perfaceted", "Peraveraged"), FunEnv){
        # access Custom_table object
        Custom_tables <- FunEnv$env2$Custom_tables

        # get correct data table based on method
        switch(method,
               "chi_sq_periodogram" = {
                 dataset = Custom_tables$peak_tbl$xsq
               },
               "ac_periodogram" = {
                 dataset = Custom_tables$peak_tbl$ac
               },
               "ls_periodogram" = {
                 dataset = Custom_tables$peak_tbl$ls
               },
               "fourier_periodogram" = {
                 dataset = Custom_tables$peak_tbl$fourier
               },
               "cwt_periodogram" = {
                 dataset = Custom_tables$peak_tbl$cwt
               })

        data_obj <- FunEnv$env2$myCleanSample
        full_meta_list <- purrr::map(data_obj, function(obj) obj$get_meta())
        full_meta <- do.call(rbind, full_meta_list)

        metadata = Custom_tables$metadata
        # TODO to add a choice to filter out data that do
        # not pass the threshold (no peak =+ 1)

      #recreate behavr table
        # set key on tables
        data.table::setDT(dataset, key = "id")
        data.table::setDT(metadata, key = "id")

        # Generate behavr table
        data <- behavr::behavr(dataset, metadata)

        # if having multi-images, split the dataset based on how many images
        # are being taken. To calculate, get the number of unique images from
        # metadata$
          if ("Pertotal" %in% plotType){
            plot <- ggetho::ggperio(data, mapping = ggplot2::aes(y = power, peak = peak))+
              ggplot2::geom_line(ggplot2::aes(group = id, colour = group), size = 1.3)+
              ggplot2::geom_line(ggplot2::aes(y = signif_threshold), colour = "red", alpha = 0.4)+
              ggetho::geom_peak()+
              ggpubr::theme_pubr()+
              ggplot2::theme(plot.background = ggplot2::element_rect(fill = "transparent", colour = NA),
                             legend.background = ggplot2::element_rect(fill = "transparent"),
                             panel.background = ggplot2::element_rect(fill = "transparent"))
            self$store_obj("periodogram_total", plot)
          }
          if ("Perfaceted" %in% plotType){
            plot <- ggetho::ggperio(data, mapping = ggplot2::aes(y = power, peak = peak))+
              ggplot2::geom_line(ggplot2::aes(group = id, colour = group), size = 1)+
              ggplot2::geom_line(ggplot2::aes(y = signif_threshold), colour = "red", alpha = 0.4)+
              ggetho::geom_peak()+
              ggpubr::theme_pubr()+
              ggplot2::facet_wrap(~id, ncol = 6, labeller = ggplot2::label_wrap_gen(multi_line=FALSE))+
              ggplot2::theme(plot.background = ggplot2::element_rect(fill = "transparent", colour = NA),
                             legend.background = ggplot2::element_rect(fill = "transparent"),
                             panel.background = ggplot2::element_rect(fill = "transparent"))
            self$store_obj("periodogram_faceted", plot)
          }
        if ("Peraveraged" %in% plotType){
          plot <- ggetho::ggperio(data, ggplot2::aes(y = power - signif_threshold, colour=group)) +
            ggetho::stat_pop_etho()+
            ggpubr::theme_pubr()+
            ggplot2::theme(plot.background = ggplot2::element_rect(fill = "transparent", colour = NA),
                           legend.background = ggplot2::element_rect(fill = "transparent"),
                           panel.background = ggplot2::element_rect(fill = "transparent"))
          self$store_obj("periodogram_averaged", plot)
        }
      },

#' plot_period_barplot
#'
#' @param method function used to run period analysis
#' @param FunEnv AppSettings environment
#'
#' @return function returns internally
      plot_period_barplot = function(method, FunEnv){
        summary_data <- FunEnv$env2$Custom_tables$period_tbl$fft
        plot <- ggplot2::ggplot(summary_data, ggplot2::aes(group, period, fill= NA)) +
          ggplot2::geom_jitter(ggplot2::aes(size=abs(amplitude), fill = group), alpha=.5, width = 0.2)+
          ggpubr::theme_pubr()
        self$store_obj("period_barplot", plot)
      }
    )
)


