
library(nhdplusTools)
library(dplyr)
library(sf)

get_hygeo_temp <- function() {
  temp_path <- file.path(tempdir(check = TRUE), "hygeo")
  unlink(temp_path, recursive = TRUE)
  dir.create(temp_path, recursive = TRUE, showWarnings = FALSE)
  temp_path
}

get_names <- function(x) {
  try(x<- sf::st_drop_geometry(x), silent = TRUE)
  names(x)
}

check_io <- function(hygeo_list, temp_path){
  hygeo_list_read <- read_hygeo(temp_path)

  expect_equal(names(hygeo_list), names(hygeo_list_read))

  expect_equal(lapply(hygeo_list, get_names), lapply(hygeo_list_read, get_names))

  expect_equal(lapply(hygeo_list, nrow), lapply(hygeo_list_read, nrow))

  expect_equal(lapply(hygeo_list, ncol), lapply(hygeo_list_read, ncol))

  expect_true(all(sf::st_is_valid(hygeo_list$catchment)))
  expect_true(all(sf::st_is_valid(hygeo_list$flowpath)))
  expect_true(all(sf::st_is_valid(hygeo_list$nexus)))
}

get_test_hygoeo_object <- function() {
  sample_data <- list.files(pattern = "sugar_creek_hyRefactor.gpkg", recursive = TRUE)[1]

  fline <- read_sf(sample_data, "reconcile")

  catchment <- read_sf(sample_data, "reconcile_divides")

  nexus <- get_nexus(fline)

  catchment_edge_list <- get_catchment_edges(fline,
                                             catchment_prefix = "cat-",
                                             nexus_prefix = "nex-")


  waterbody_edge_list <- get_waterbody_edge_list(fline,
                                                 waterbody_prefix = "fp-")



  sqkm_per_sqm <- 1 / 1000^2
  catchment$area_sqkm <- as.numeric(sf::st_area(sf::st_transform(catchment, 5070))) * sqkm_per_sqm

  catchment_data <- get_catchment_data(catchment,
                                       catchment_edge_list,
                                       catchment_prefix = "cat-")

  flowpath_data <- get_flowpath_data(fline,
                                       waterbody_edge_list,
                                       flowpath_prefix = "fp-")

  nexus_data <- get_nexus_data(nexus,
                               catchment_edge_list)

  hygeo_list <- list(catchment = catchment_data,
                     flowpath = flowpath_data,
                     nexus = nexus_data,
                     catchment_edges = catchment_edge_list,
                     waterbody_edges = waterbody_edge_list)

  class(hygeo_list) <- "hygeo"

  return(list(hl = hygeo_list, fline = fline, cat = catchment))
}
