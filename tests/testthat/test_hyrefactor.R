library(nhdplusTools)
library(dplyr)
library(sf)

test_that("all functions run", {
  sample_data <- list.files(pattern = "sugar_creek_hyRefactor.gpkg", recursive = TRUE)[1]

  st_layers(sample_data)

  fline <- read_sf(sample_data, "reconcile")

  catchment <- read_sf(sample_data, "reconcile_divides")

  nexus <- get_nexus(fline)

  expect_true("ID" %in% names(nexus))
  expect_equal(nexus$ID[1], "nexus_4")
  expect_is(st_geometry(nexus), "sfc_POINT")
  expect_equal(nrow(nexus), 97)

  catchment_edge_list <- get_catchment_edges(fline,
                                             catchment_prefix = "cat-",
                                             nexus_prefix = "nex-")

  expect_equal(names(catchment_edge_list), c("ID", "toID"))
  expect_equal(catchment_edge_list$ID[1], "cat-1")
  expect_equal(catchment_edge_list$toID[1], "nex-4")

  waterbody_edge_list <- get_waterbody_edge_list(catchment_edge_list,
                                                 catchment_prefix = "cat-",
                                                 waterbody_prefix = "wat-")

  expect_equal(names(waterbody_edge_list), c("ID", "toID"))
  expect_equal(waterbody_edge_list$ID[1], "wat-1")
  expect_equal(waterbody_edge_list$toID[1], "nex-4")

  sqkm_per_sqm <- 1 / 1000^2

  expect_error(
  catchment_data <- get_catchment_data(catchment,
                                       catchment_edge_list,
                                       catchment_prefix = "cat-"),
  "must supply area as AreaSqKM or area_sqkm")

  catchment$area_sqkm <- as.numeric(st_area(st_transform(catchment, 5070))) * sqkm_per_sqm

  catchment_data <- get_catchment_data(catchment,
                                       catchment_edge_list,
                                       catchment_prefix = "cat-")

  expect_is(st_geometry(catchment_data), "sfc_MULTIPOLYGON")
  expect_true(all(c("ID", "area_sqkm") %in% names(catchment_data)))

  waterbody_data <- get_waterbody_data(fline,
                                       waterbody_edge_list,
                                       waterbody_prefix = "wat-")

  expect_is(st_geometry(waterbody_data), "sfc_LINESTRING")
  expect_true(all(c("ID", "length_km", "slope_percent", "main_id") %in% names(waterbody_data)))

  nexus_data <- get_nexus_data(nexus,
                               catchment_edge_list,
                               waterbody_edge_list)

  expect_true("ID" %in% names(nexus))
})
