context("hyrefactor tests")

hl <- get_test_hygoeo_object()
fline <- hl$fline
catchment <- hl$cat
hl <- hl$hl

test_that("all functions run", {

  nexus <- get_nexus(fline)

  expect_true("ID" %in% names(nexus))
  expect_equal(nexus$ID[1], "nexus_4")
  expect_is(st_geometry(nexus), "sfc_POINT")
  expect_equal(nrow(nexus), 52)


  expect_equal(names(hl$catchment_edges), c("ID", "toID"))
  expect_equal(hl$catchment_edges$ID[1], "cat-1")
  expect_equal(hl$catchment_edges$toID[1], "nex-4")


  expect_equal(names(hl$waterbody_edges), c("ID", "toID"))
  expect_equal(hl$waterbody_edges$ID[1], "wat-1")
  expect_equal(hl$waterbody_edges$toID[1], "wat-4")

  waterbody_edge_list_drop_geo <- get_waterbody_edge_list(sf::st_drop_geometry(fline),
                                                          waterbody_prefix = "wat-")

  expect_equal(names(waterbody_edge_list_drop_geo), c("ID", "toID"))
  expect_equal(waterbody_edge_list_drop_geo$ID[1], "wat-1")
  expect_equal(waterbody_edge_list_drop_geo$toID[1], "wat-4")

  expect_error(
  catchment_data <- get_catchment_data(dplyr::select(catchment, -area_sqkm),
                                       hl$catchment_edges,
                                       catchment_prefix = "cat-"),
  "must supply area as AreaSqKM or area_sqkm")

  expect_is(st_geometry(hl$catchment), "sfc_MULTIPOLYGON")
  expect_true(all(c("ID", "area_sqkm") %in% names(hl$catchment)))

  expect_is(st_geometry(hl$waterbody), "sfc_LINESTRING")
  expect_true(all(c("ID", "length_km", "slope_percent", "main_id") %in% names(hl$waterbody)))

  expect_true("ID" %in% names(nexus))

  xwalk <- get_nhd_crosswalk(fline)

  expect_equal(nrow(xwalk), 130)

  expect_equal(xwalk$local_id[1], "wat-1")

  xwalk <- get_nhd_crosswalk(fline, "water-")

  expect_equal(xwalk$local_id[1], "water-1")
})

test_that("io_functions", {
  temp_path <- get_hygeo_temp()

  temp_path_2 <- write_hygeo(hl, out_path = temp_path, overwrite = TRUE)

  expect_equal(temp_path, temp_path_2)

  hl_read <- read_hygeo(temp_path)

  expect_equal(names(hl), names(hl_read))

  expect_equal(lapply(hl, get_names), lapply(hl_read, get_names))

  expect_equal(lapply(hl, nrow), lapply(hl_read, nrow))

  expect_equal(lapply(hl, ncol), lapply(hl_read, ncol))

  expect_true(mean(st_coordinates(hl_read$catchment)[, 1]) < 180,
              "coordinates not lat/lon?")
  expect_true(mean(st_coordinates(hl_read$catchment)[, 2]) < 180,
              "coordinates not lat/lon?")
})
