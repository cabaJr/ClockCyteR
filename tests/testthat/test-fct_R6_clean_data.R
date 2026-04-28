# Source required R6 class definitions (not exported from package)
source(here::here("R", "fct_R6_clean_data.R"))
source(here::here("R", "fct_R6_raw_data.R"))
source(here::here("R", "fct_App_settings.R"))
source(here::here("R", "fct_data_loader.R"))
source(here::here("R", "fct_Custom_tables.R"))
source(here::here("R", "fct_Annotate.R"))

# ---- Annotate store/retrieve ------------------------------------------------

test_that("Annotate store/retrieve round-trip works", {
  ann <- Annotate$new()
  dummy <- list(ggplot2::ggplot())
  ann$store_obj("ts_original", dummy)
  expect_identical(ann$retrieve_obj("ts_original"), dummy)
  expect_null(ann$retrieve_obj("nonexistent_key"))
})

test_that("Annotate store overwrites existing key", {
  ann <- Annotate$new()
  ann$store_obj("ts_original", list("first"))
  ann$store_obj("ts_original", list("second"))
  expect_equal(ann$retrieve_obj("ts_original"), list("second"))
})

test_that("Annotate store keeps independent keys separate", {
  ann <- Annotate$new()
  ann$store_obj("ts_original",  list("a"))
  ann$store_obj("ts_annotated", list("b"))
  expect_equal(ann$retrieve_obj("ts_original"),  list("a"))
  expect_equal(ann$retrieve_obj("ts_annotated"), list("b"))
})

# ---- extract_components() ---------------------------------------------------

test_that("extract_components: standard 'Group (Well), Image N' format", {
  clean  <- Clean_sample_data$new()
  result <- clean$extract_components("Control (A1), Image 1")
  expect_equal(result$Group, "Control")
  expect_equal(result$Well,  "A1")
  expect_equal(result$Image, "1")
})

test_that("extract_components: bare well label (no group, no image)", {
  clean  <- Clean_sample_data$new()
  result <- clean$extract_components("A1")
  expect_equal(result$Well,  "A1")
  expect_equal(result$Image, "")
  expect_equal(result$Group, "")
})

test_that("extract_components: 'Well, Image N' format (no parentheses)", {
  clean  <- Clean_sample_data$new()
  result <- clean$extract_components("A1, Image 1")
  expect_equal(result$Well,  "A1")
  expect_equal(result$Image, "1")
  expect_equal(result$Group, "")
})

test_that("extract_components: short string handled without error", {
  clean  <- Clean_sample_data$new()
  result <- clean$extract_components("B3")
  expect_equal(result$Well, "B3")
})

# ---- helpers ----------------------------------------------------------------

load_test_env <- function() {
  test_path <- system.file(
    "extData", "Test_data.txt", package = "clockcyteR"
  )
  skip_if(test_path == "", message = "Test_data.txt not found")
  env <- App_settings$new()
  env$dataList <- data.frame(
    name     = "Test_data.txt",
    datapath = test_path,
    stringsAsFactors = FALSE
  )
  preload_data(env)
  load_data(env)
  env
}

# ---- detrend() regression tests ---------------------------------------------

test_that("detrend: no crash when intensity_clean is NULL", {
  env    <- load_test_env()
  sample <- env$env2$myCleanSample[[1]]
  expect_null(sample$intensity_clean)
  expect_no_error(sample$detrend(grade = 1))
  expect_true(is.numeric(sample$detrended))
  expect_equal(length(sample$detrended), length(sample$intensity))
})

test_that("detrend: populates detrended field with numeric values", {
  env    <- load_test_env()
  sample <- env$env2$myCleanSample[[1]]
  sample$detrend(grade = 1)
  expect_true(is.numeric(sample$detrended))
  expect_false(all(is.na(sample$detrended)))
})

# ---- end-to-end load pipeline -----------------------------------------------

test_that("load_data: produces Clean_sample_data objects from Test_data.txt", {
  env     <- load_test_env()
  samples <- env$env2$myCleanSample
  expect_true(length(samples) > 0)

  first <- samples[[1]]
  expect_true(nzchar(first$sampleName))
  expect_true(is.numeric(first$elapsed))
  expect_true(is.numeric(first$intensity))
  expect_equal(length(first$elapsed), length(first$intensity))
  expect_true(nzchar(first$metric))
})

test_that("load_data: elapsed and intensity lengths are consistent", {
  env <- load_test_env()
  for (s in env$env2$myCleanSample) {
    expect_equal(length(s$elapsed), length(s$intensity))
    expect_true(
      all(diff(s$elapsed) > 0),
      info = paste("elapsed not monotonic for", s$sampleName)
    )
  }
})
