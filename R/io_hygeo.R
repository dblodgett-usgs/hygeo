#' @title Write hygeo
#' @param hygeo_list list of class hygeo containing:
#'   catchment, flowpath, nexus, catchment_edges, and waterbody_edges.
#' @param out_path character path to store outputs
#' @param edge_list_format character 'json' or 'csv'
#' @param data_format character 'geojson' or 'gpkg'
#' @param overwrite boolean overwrite output or not
#' @importFrom utils write.csv
#' @importFrom sf write_sf st_make_valid st_transform
#' @export
write_hygeo <- function(hygeo_list,
                        out_path,
                        edge_list_format = "json",
                        data_format = "geojson",
                        overwrite = FALSE) {

  check_hygeo(hygeo_list)

  if(edge_list_format == "csv") {
    cfe <- file.path(out_path, "catchment_edge_list.csv")
    wfe <- file.path(out_path, "waterbody_edge_list.csv")
  } else if(edge_list_format == "json") {
    cfe <- file.path(out_path, "catchment_edge_list.json")
    wfe <- file.path(out_path, "waterbody_edge_list.json")
  } else if(edge_list_format == "gpkg") {
    stop('edge_list_format "gpkg" not implemented yet')
  } else {
    stop("edge_list_format must be 'csv', 'gpkg', or 'json'")
  }

  if(data_format == "geojson") {
    cf <- file.path(out_path, "catchment_data.geojson")
    wf <- file.path(out_path, "flowpath_data.geojson")
    nf <- file.path(out_path, "nexus_data.geojson")
  } else if(data_format == "gpkg") {
    cf <- file.path(out_path, "hygeo.gpkg")
    wf <- file.path(out_path, "hygeo.gpkg")
    nf <- file.path(out_path, "hygeo.gpkg")
  } else {
    stop("data_format must be 'gejson' or 'gpkg'")
  }

  if(overwrite) {
    if(file.exists(cfe)) unlink(cfe)
    if(file.exists(wfe)) unlink(wfe)
    if(file.exists(cf)) unlink(cf)
    if(file.exists(wf)) unlink(wf)
    if(file.exists(nf)) unlink(nf)
  } else {
    if(any(file.exists(cfe), file.exists(wfe))) {
      stop("overwrite is FALSE and files exist")
    }
  }

  if(edge_list_format == "csv") {
    write.csv(hygeo_list$catchment_edges, cfe,
              row.names = FALSE)
    write.csv(hygeo_list$waterbody_edges, wfe,
              row.names = FALSE)
  } else if(edge_list_format == "json") {

    names(hygeo_list$catchment_edges) <- tolower(names(hygeo_list$catchment_edges))
    names(hygeo_list$waterbody_edges) <- tolower(names(hygeo_list$waterbody_edges))

    jsonlite::write_json(hygeo_list$catchment_edges, cfe,
                         pretty = TRUE)
    jsonlite::write_json(hygeo_list$waterbody_edges, wfe,
                         pretty = TRUE)
  }

  if(data_format == "geojson") {

    write_fun <- function(x, y) {
      names(x) <- tolower(names(x))

      write_sf(st_make_valid(st_transform(x, 4326)), y,
               layer_options = c("ID_FIELD=id", "ID_TYPE=String"))
    }

    write_fun(hygeo_list$catchment, cf)
    write_fun(hygeo_list$flowpath, wf)
    write_fun(hygeo_list$nexus, nf)

  } else if(data_format == "gpkg") {
    write_sf(st_make_valid(hygeo_list$catchment), cf, "catchment")
    write_sf(st_make_valid(hygeo_list$flowpath), wf, "flowpath")
    write_sf(st_make_valid(hygeo_list$nexus), nf, "nexus")
  }

  return(invisible(out_path))
}

#' @title Read hygeo
#' @param path character path to folder containing hygeo compatible files.
#' @importFrom utils read.csv
#' @importFrom sf read_sf
#' @export
#'
read_hygeo <- function(path) {
  fs <- list.files(path, full.names = TRUE, recursive = FALSE)

  catchment_file <- fs[grepl("catchment_data", fs)]
  flowpath_file <- fs[grepl("flowpath_data", fs)]
  nexus_file <- fs[grepl("nexus_data", fs)]

  if(length(catchment_file) == 0) {
    catchment_file <-
      flowpath_file <-
      nexus_file <- fs[grepl("hygeo.gpkg", fs)]
  }

  catchment_edge_file <- fs[grepl("catchment_edge_list", fs)]
  waterbody_edge_file <- fs[grepl("waterbody_edge_list", fs)]

  out <- list(catchment = read_data(catchment_file, "catchment"),
              flowpath = read_data(flowpath_file, "flowpath"),
              nexus = read_data(nexus_file, "nexus"),
              catchment_edges = read_edges(catchment_edge_file),
              waterbody_edges = read_edges(waterbody_edge_file))

  class(out) <- "hygeo"

  return(out)
}


read_data <- function(f, layer = NULL) {
  if(grepl(".*gpkg$", f)) {
    read_sf(f, layer)
  } else if(grepl(".*geojson$", f)) {
    read_sf(f)
  }
}

read_edges <- function(f) {
  if(grepl(".*csv$", f)) {
    read.csv(f, stringsAsFactors = FALSE)
  } else if(grepl(".*json$", f)) {
    jsonlite::read_json(f, simplifyVector = TRUE)
  }
}

check_hygeo <- function(hygeo_list) {
  req_names <- c("catchment", "flowpath", "nexus",
                 "catchment_edges", "waterbody_edges")

  if(!methods::is(hygeo_list, "hygeo")) stop("hygeo_list must be class 'hygeo'")
  if(!all(req_names %in% names(hygeo_list))) stop(paste("hygeo_list must contain all of",
                                                        paste(req_names, collapse = ", ")))
  return(invisible(NULL))
}
