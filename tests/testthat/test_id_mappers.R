context("get_hydrologic_location")

test_that("get_hydrologic_location integration test", {
  hl <- get_test_hygoeo_object()
  fline <- hl$fline
  catchment <- hl$cat
  hl <- hl$hl

  src_gpkg <- system.file("gpkg/sugar_creek_fort_mill.gpkg", package = "hygeo")

  mr_lp <- read_sf(src_gpkg, "NHDFlowline_Network") %>%
    st_drop_geometry() %>%
    align_nhdplus_names() %>%
    select(COMID, LevelPathI)

  main_id_xwalk <- select(st_drop_geometry(hl$flowpath),
                          local_id = ID, main_id) %>%
    left_join(get_nhd_crosswalk(fline), by = "local_id") %>%
    mutate(COMID = as.integer(COMID)) %>%
    select(-local_id) %>%
    distinct() %>%
    left_join(mr_lp, by = "COMID") %>%
    select(-COMID)

  hr_nodes <- read_sf(src_gpkg, "hr_NHDPlusFlowline") %>%
    select(NHDPlusID = COMID, LevelPathI, Hydroseq, mr_LevelPathI)

  hr_nodes <- sf::st_sf(sf::st_drop_geometry(hr_nodes),
                        geom =  st_geometry(nhdplusTools::get_node(hr_nodes))) %>%
    left_join(main_id_xwalk, by = c("mr_LevelPathI" = "LevelPathI"))

  hyl <- select(hr_nodes, NHDPlusID, main_id)
  flowpath <- hl$flowpath

  hyl <- st_transform(hyl, 5070)

  expect_error(get_hydrologic_locaton(hyl, flowpath), "crs must be equal")

  flowpath <- st_transform(flowpath, 5070)

  hyl_out <- get_hydrologic_locaton(hyl, flowpath)

  expect_equal(nrow(hyl_out), 5053)

  expect_equal(names(hyl_out), c("NHDPlusID", "ID", "measure", "offset", "geom"))
})
