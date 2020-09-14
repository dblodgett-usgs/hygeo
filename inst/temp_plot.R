nhd <- nhdplusTools::plot_nhdplus(list(9731454),
                                  plot_config = list(flowline = list(col = NA)),
                                  gpkg = src_gpkg,
                                  overwrite = FALSE,
                                  nhdplus_data = src_gpkg)
gt <- function(x) sf::st_geometry(sf::st_transform(x, 3857))

prettymapr::prettymap({
  rosm::osm.plot(nhd$plot_bbox, type = "cartolight", quiet = TRUE, progress = "none")
  plot(gt(nhd$basin), add = TRUE)
  plot(gt(nexus_data), add = TRUE, col = "red")
  plot(gt(nhd$basin), add = TRUE)
})

prettymapr::prettymap({
  rosm::osm.plot(nhd$plot_bbox, type = "cartolight", quiet = TRUE, progress = "none")
  plot(gt(nhd$basin), add = TRUE)
  plot(gt(nexus_data), add = TRUE, col = "red")
  plot(gt(nhd$basin), add = TRUE)
  plot(gt(nhd$catchment), add = TRUE)
})

prettymapr::prettymap({
  rosm::osm.plot(nhd$plot_bbox, type = "cartolight", quiet = TRUE, progress = "none")
  plot(gt(nhd$basin), add = TRUE)
  plot(gt(nexus_data), add = TRUE, col = "red")
  plot(gt(nhd$basin), add = TRUE)
  # plot(gt(nhd$catchment), add = TRUE)
  plot(gt(reconcile_divides), add = TRUE)
})

prettymapr::prettymap({
  rosm::osm.plot(nhd$plot_bbox, type = "cartolight", quiet = TRUE, progress = "none")
  plot(gt(nhd$basin), add = TRUE)
  plot(gt(nexus_data), add = TRUE, col = "red")
  plot(gt(nhd$basin), add = TRUE)
  # plot(gt(nhd$catchment), add = TRUE)
  plot(gt(hi_res_divides), add = TRUE)
})
