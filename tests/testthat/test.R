context("nhdplus tests")

sample_data <- system.file("gpkg/nhdplus_subset.gpkg", package = "hygeo")

fline <- read_sf(sample_data, "NHDFlowline_Network") %>%
  align_nhdplus_names() %>%
  filter(COMID %in% get_UT(., 8895396))

catchment <- read_sf(sample_data, "CatchmentSP") %>%
  align_nhdplus_names() %>%
  filter(FEATUREID %in% fline$COMID)

nexus <- get_nexus(fline)

catchment_edge_list <- get_catchment_edges(fline,
                                           catchment_prefix = "cat-",
                                           nexus_prefix = "nex-")

catchment_data <- get_catchment_data(catchment,
                                     catchment_edge_list,
                                     catchment_prefix = "cat-")

suppressWarnings(waterbody_edge_list <- get_waterbody_edge_list(fline,
                                                                waterbody_prefix = "fp-"))

flowpath_data <- get_flowpath_data(fline,
                                   waterbody_edge_list,
                                   catchment_prefix = "cat-")

nexus_data <- get_nexus_data(nexus,
                             catchment_edge_list)

hygeo_list <- list(catchment = catchment_data,
                   flowpath = flowpath_data,
                   nexus = nexus_data,
                   catchment_edges = catchment_edge_list,
                   waterbody_edges = waterbody_edge_list)

class(hygeo_list) <- "hygeo"

test_that("all functions run", {

  expect_true("ID" %in% names(nexus))
  expect_equal(nexus$ID[1], "nexus_250031932")
  expect_is(st_geometry(nexus), "sfc_POINT")
  expect_equal(nrow(nexus), 3)

  expect_equal(names(catchment_edge_list), c("ID", "toID"))
  expect_equal(catchment_edge_list$ID[1], "cat-8895442")
  expect_equal(catchment_edge_list$toID[1], "nex-250031932")

  expect_warning(
  waterbody_edge_list <- get_waterbody_edge_list(fline,
                                                 waterbody_prefix = "fp-"),
  "Got NHDPlus data without a Terminal catchment. Attempting to find it.")

  expect_equal(names(waterbody_edge_list), c("ID", "toID"))
  expect_equal(waterbody_edge_list$ID[1], "fp-8895442")
  expect_equal(waterbody_edge_list$toID[1], "fp-8895402")

  expect_is(st_geometry(catchment_data), "sfc_MULTIPOLYGON")
  expect_true(all(c("ID", "area_sqkm") %in% names(catchment_data)))

  expect_is(st_geometry(flowpath_data), "sfc_MULTILINESTRING")
  expect_true(all(c("ID", "length_km", "slope_percent", "main_id") %in% names(flowpath_data)))

  expect_true("ID" %in% names(nexus))
})

test_that("io functions", {
  temp_path <- get_hygeo_temp()

  temp_path_2 <- write_hygeo(hygeo_list, out_path = temp_path,
                             overwrite = TRUE)

  temp_path_2 <- write_hygeo(hygeo_list, out_path = temp_path,
                             overwrite = TRUE)

  expect_equal(temp_path, temp_path_2)

  expect_error(write_hygeo(hygeo_list, out_path = temp_path,
                                        overwrite = FALSE),
               "overwrite is FALSE and files exist")

  check_io(hygeo_list, temp_path, lower = TRUE)

  temp_path <- get_hygeo_temp()

  temp_path <- write_hygeo(hygeo_list, out_path = temp_path,
                           edge_list_format = "csv", data_format = "gpkg",
                           overwrite = TRUE)

  temp_path <- write_hygeo(hygeo_list, out_path = temp_path,
                           edge_list_format = "csv", data_format = "gpkg",
                           overwrite = TRUE)

  expect_equal(list.files(temp_path),
               c("catchment_edge_list.csv", "hygeo.gpkg", "waterbody_edge_list.csv"))

  check_io(hygeo_list, temp_path, lower = FALSE)
})

test_that("io errors", {
  temp_path <- get_hygeo_temp()

  expect_error(write_hygeo(hygeo_list, out_path = temp_path,
                           edge_list_format = "gpkg"),
               'edge_list_format "gpkg" not implemented yet')
  expect_error(write_hygeo(hygeo_list, out_path = temp_path,
                           edge_list_format = "borked"),
               "edge_list_format must be 'csv', 'gpkg', or 'json'")
  expect_error(write_hygeo(hygeo_list, out_path = temp_path,
                           data_format = "borked"),
               "data_format must be 'gejson' or 'gpkg'")

  class(hygeo_list) <- "borked"
  expect_error(write_hygeo(hygeo_list, out_path = temp_path,
                           edge_list_format = "csv", data_format = "gpkg",
                           overwrite = TRUE),
               "hygeo_list must be class 'hygeo'")

  class(hygeo_list) <- "hygeo"
  names(hygeo_list)[1] <- "borked"
  expect_error(write_hygeo(hygeo_list, out_path = temp_path,
                           edge_list_format = "csv", data_format = "gpkg",
                           overwrite = TRUE),
               "hygeo_list must contain all of catchment, flowpath, nexus, catchment_edges, waterbody_edges")
})
