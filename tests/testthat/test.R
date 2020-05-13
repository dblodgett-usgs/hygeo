library(nhdplusTools)
library(dplyr)
library(sf)

test_that("all functions run", {
  sample_data <- system.file("gpkg/nhdplus_subset.gpkg", package = "hygeo")

  #st_layers("nhdplus_subset.gpkg")

  fline <- read_sf(sample_data, "NHDFlowline_Network") %>%
    align_nhdplus_names() %>%
    filter(COMID %in% get_UT(., 8895396))

  catchment <- read_sf(sample_data, "CatchmentSP") %>%
    align_nhdplus_names() %>%
    filter(FEATUREID %in% fline$COMID)

  nexus <- get_nexus(fline)

  expect_true("ID" %in% names(nexus))
  expect_equal(nexus$ID[1], "nexus_250031932")
  expect_is(st_geometry(nexus), "sfc_POINT")
  expect_equal(nrow(nexus), 3)

  catchment_edge_list <- get_catchment_edges(fline,
                                             catchment_prefix = "cat-",
                                             nexus_prefix = "nex-")

  expect_equal(names(catchment_edge_list), c("ID", "toID"))
  expect_equal(catchment_edge_list$ID[1], "cat-8895442")
  expect_equal(catchment_edge_list$toID[1], "nex-250031932")

  expect_warning(
  waterbody_edge_list <- get_waterbody_edge_list(fline,
                                                 waterbody_prefix = "wat-"),
  "Got NHDPlus data without a Terminal catchment. Attempting to find it.")
  expect_equal(names(waterbody_edge_list), c("ID", "toID"))
  expect_equal(waterbody_edge_list$ID[1], "wat-8895442")
  expect_equal(waterbody_edge_list$toID[1], "wat-8895402")

  catchment_data <- get_catchment_data(catchment,
                                       catchment_edge_list,
                                       catchment_prefix = "cat-")

  expect_is(st_geometry(catchment_data), "sfc_MULTIPOLYGON")
  expect_true(all(c("ID", "area_sqkm") %in% names(catchment_data)))

  waterbody_data <- get_waterbody_data(fline,
                                       waterbody_edge_list,
                                       waterbody_prefix = "wat-")

  expect_is(st_geometry(waterbody_data), "sfc_MULTILINESTRING")
  expect_true(all(c("ID", "length_km", "slope_percent", "main_id") %in% names(waterbody_data)))

  nexus_data <- get_nexus_data(nexus,
                               catchment_edge_list,
                               waterbody_edge_list)

  expect_true("ID" %in% names(nexus))

  hygeo_list <- list(catchment = catchment_data,
                     waterbody = waterbody_data,
                     nexus = nexus_data,
                     catchment_edges = catchment_edge_list,
                     waterbody_edges = waterbody_edge_list)

  class(hygeo_list) <- "hygeo"

  temp_path <- file.path(tempdir(check = TRUE), "hygeo")
  unlink(temp_path, recursive = TRUE)
  dir.create(temp_path, recursive = TRUE, showWarnings = FALSE)

  temp_path <- write_hygeo(hygeo_list, out_path = temp_path, overwrite = TRUE)

  expect_error(write_hygeo(hygeo_list, out_path = temp_path,
                                        overwrite = FALSE),
               "overwrite is FALSE and files exist")

  hygeo_list_read <- read_hygeo(temp_path)

  expect_equal(names(hygeo_list), names(hygeo_list_read))

  f <- function(x) {
    try(x<- sf::st_drop_geometry(x), silent = TRUE)
    names(x)
  }

  expect_equal(lapply(hygeo_list, f), lapply(hygeo_list_read, f))

  expect_equal(lapply(hygeo_list, nrow), lapply(hygeo_list_read, nrow))

  expect_equal(lapply(hygeo_list, ncol), lapply(hygeo_list_read, ncol))

  unlink(temp_path, recursive = TRUE)
  dir.create(temp_path, recursive = TRUE, showWarnings = FALSE)

  temp_path <- write_hygeo(hygeo_list, out_path = temp_path,
                           edge_list_format = "csv", data_format = "gpkg",
                           overwrite = TRUE)

  expect_equal(list.files(temp_path),
               c("catchment_edge_list.csv", "hygeo.gpkg", "waterbody_edge_list.csv"))
})
