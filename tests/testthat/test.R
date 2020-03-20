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
  expect_equal(nexus$ID[1], 8895442)
  expect_is(st_geometry(nexus), "sfc_POINT")
  expect_equal(nrow(nexus), 4)

  catchment_edge_list <- get_catchment_edges(fline,
                                             catchment_prefix = "cat-",
                                             nexus_prefix = "nex-")

  expect_equal(names(catchment_edge_list), c("ID", "toID"))
  expect_equal(catchment_edge_list$ID[1], "cat-8895442")
  expect_equal(catchment_edge_list$toID[1], "nex-250031932")

  waterbody_edge_list <- get_waterbody_edge_list(catchment_edge_list,
                                                 catchment_prefix = "cat-",
                                                 waterbody_prefix = "wat-")

  expect_equal(names(waterbody_edge_list), c("ID", "toID"))
  expect_equal(waterbody_edge_list$ID[1], "wat-8895442")
  expect_equal(waterbody_edge_list$toID[1], "nex-250031932")

  catchment_data <- get_catchment_data(catchment, catchment_prefix = "cat-")

  expect_is(st_geometry(catchment_data), "sfc_MULTIPOLYGON")
  expect_true(all(c("ID", "area_sqkm") %in% names(catchment_data)))

  waterbody_data <- get_waterbody_data(fline, waterbody_prefix = "wat-")

  expect_is(st_geometry(waterbody_data), "sfc_MULTILINESTRING")
  expect_true(all(c("ID", "length_km", "slope_percent", "main_id") %in% names(waterbody_data)))

  nexus_data <- get_nexus_data(nexus)

  expect_true("ID" %in% names(nexus))
})
