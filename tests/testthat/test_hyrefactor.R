context("hyrefactor tests")

library(nhdplusTools)
library(dplyr)
library(sf)

sample_data <- list.files(pattern = "sugar_creek_hyRefactor.gpkg", recursive = TRUE)[1]

fline <- read_sf(sample_data, "reconcile")

catchment <- read_sf(sample_data, "reconcile_divides")

nexus <- get_nexus(fline)

catchment_edge_list <- get_catchment_edges(fline,
                                           catchment_prefix = "cat-",
                                           nexus_prefix = "nex-")


waterbody_edge_list <- get_waterbody_edge_list(fline,
                                               waterbody_prefix = "wat-")

waterbody_edge_list_drop_geo <- get_waterbody_edge_list(sf::st_drop_geometry(fline),
                                                        waterbody_prefix = "wat-")

sqkm_per_sqm <- 1 / 1000^2
catchment$area_sqkm <- as.numeric(st_area(st_transform(catchment, 5070))) * sqkm_per_sqm

catchment_data <- get_catchment_data(catchment,
                                     catchment_edge_list,
                                     catchment_prefix = "cat-")

waterbody_data <- get_waterbody_data(fline,
                                     waterbody_edge_list,
                                     waterbody_prefix = "wat-")

nexus_data <- get_nexus_data(nexus,
                             catchment_edge_list,
                             waterbody_edge_list)

hygeo_list <- list(catchment = catchment_data,
                   waterbody = waterbody_data,
                   nexus = nexus_data,
                   catchment_edges = catchment_edge_list,
                   waterbody_edges = waterbody_edge_list)

class(hygeo_list) <- "hygeo"

test_that("all functions run", {

  expect_true("ID" %in% names(nexus))
  expect_equal(nexus$ID[1], "nexus_4")
  expect_is(st_geometry(nexus), "sfc_POINT")
  expect_equal(nrow(nexus), 52)


  expect_equal(names(catchment_edge_list), c("ID", "toID"))
  expect_equal(catchment_edge_list$ID[1], "cat-1")
  expect_equal(catchment_edge_list$toID[1], "nex-4")


  expect_equal(names(waterbody_edge_list), c("ID", "toID"))
  expect_equal(waterbody_edge_list$ID[1], "wat-1")
  expect_equal(waterbody_edge_list$toID[1], "wat-4")

  expect_equal(names(waterbody_edge_list_drop_geo), c("ID", "toID"))
  expect_equal(waterbody_edge_list_drop_geo$ID[1], "wat-1")
  expect_equal(waterbody_edge_list_drop_geo$toID[1], "wat-4")

  expect_error(
  catchment_data <- get_catchment_data(dplyr::select(catchment, -area_sqkm),
                                       catchment_edge_list,
                                       catchment_prefix = "cat-"),
  "must supply area as AreaSqKM or area_sqkm")

  expect_is(st_geometry(catchment_data), "sfc_MULTIPOLYGON")
  expect_true(all(c("ID", "area_sqkm") %in% names(catchment_data)))

  expect_is(st_geometry(waterbody_data), "sfc_LINESTRING")
  expect_true(all(c("ID", "length_km", "slope_percent", "main_id") %in% names(waterbody_data)))

  expect_true("ID" %in% names(nexus))
})

test_that("io_functions", {
  temp_path <- get_hygeo_temp()

  temp_path_2 <- write_hygeo(hygeo_list, out_path = temp_path, overwrite = TRUE)

  expect_equal(temp_path, temp_path_2)

  hygeo_list_read <- read_hygeo(temp_path)

  expect_equal(names(hygeo_list), names(hygeo_list_read))

  expect_equal(lapply(hygeo_list, get_names), lapply(hygeo_list_read, get_names))

  expect_equal(lapply(hygeo_list, nrow), lapply(hygeo_list_read, nrow))

  expect_equal(lapply(hygeo_list, ncol), lapply(hygeo_list_read, ncol))

  expect_true(mean(st_coordinates(hygeo_list_read$catchment)[, 1]) < 180,
              "coordinates not lat/lon?")
  expect_true(mean(st_coordinates(hygeo_list_read$catchment)[, 2]) < 180,
              "coordinates not lat/lon?")
})
