#' is_r6_obj
#'
#' @description A utils function to test if an argument is an R6 object
#'
#' @return TRUE or FALSE
#'
#' @noRd

is_r6_obj <- function(x, class_name) {
  inherits(x, class_name)
}
