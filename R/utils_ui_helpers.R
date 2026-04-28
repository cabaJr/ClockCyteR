#' ui_helpers
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd

#' @title render_tabItem_UI
#' @description function to dynamically render sidebar menu as the user
#'     progresses through the experiment
#' @details Call to the function render_tabItem_UI() requires the specification
#'     of params tabname, text, and icon to render a menuItem in the sidebar
#'     of the dahboardSidebar. Calling of the function can be associated to
#'     a call to movetab() to make it the active tab.
#' @param tabname a character string containing the name of the tabItem to
#'     render. It must match one of the menuItemOutput
#' @param text a character string containing the text to be displayed in the
#'     sidebar
#' @param icon a character string containing the icon to appear on the left
#' @return A new menuItem is generated in the app sidebar.
#' @noRd

render_tabItem_ui <- function(tabname, text, icon){

  shinydashboard::renderMenu({
    shinydashboard::menuItem(tabName = tabname, text = text, icon = icon(icon))
  })

}

#' @title move_tab
#' @description activate a specific tabItem.
#' @details Calling the move_tab function allows to dynamically change the
#'     active tab to a desired one. It is used to seamlessly progress through
#'     the app when the user finishes the tasks in one section of the app.
#' @param session the current R session
#' @param tabname the tabItem to be activated
#' @return a different tabItem is activated
#' @noRd

move_tab <- function(session, tabname){
  shinydashboard::updateTabItems(session, inputId = "mainmenu", selected = tabname)
}

#' @title new_experiment
#' @description set up the app for a new experiment
#' @details change the app appearance from the landing page to the
#'     configuration used to start a new experiment. Restores the dashboard
#'     header, enables the sidebar and moves the active tab to Input.
#' @param session the current R session
#' @param env to access App_settings
#' @return the app is now ready to receive the files for a new experiment
#' @noRd

new_experiment <- function(session, env){
  ## inside here call a function that:
  ## restores the dashboard header (2),
  ## enables the sidebar (3)
  ## and moves the active tab to inputDF (4).

  # call to shinyjs providing a null argument to hidehead
  shinyjs::js$hidehead('') #2
  move_tab(session, tabname = "InputData") #4

}

#' overwrite_vessel
#'
#' @param session session value
#' @param vessel name of vessel
#'
#' @return no return

overwrite_vessel <- function(session, vessel = "Front-left"){

  msg_display = stringr::str_c("The existing data of the ", vessel, " vessel will be overwritten. Would you like to continue?")

  modalDialog(

    span(msg_display),

    footer = tagList(
      actionButton("canc", "Cancel"),
      actionButton("OW", "Overwrite")
    )
  )
}
