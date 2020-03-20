#' @title get nexuses
#' @param fline sf data.frame NHDPlus Flowlines
#' @importFrom sf st_coordinates st_sf st_crs
#' @importFrom magrittr %>%
#' @importFrom dplyr group_by filter ungroup select
#' @export
get_nexus <- function(fline) {
  nexus <- fline %>%
    st_coordinates() %>%
    as.data.frame() %>%
    group_by(L2) %>%
    filter(row_number() == n()) %>%
    ungroup() %>%
    select(X, Y) %>%
    st_as_sf(coords = c("X", "Y"), crs = st_crs(fline))

  nexus$ID <- fline$COMID

  return(nexus)
}

#' @title get catchment edges
#' @param fline sf data.frame NHDPlus Flowlines
#' @param nexus_prefix character prefix for nexus IDs
#' @param catchment_prefix character prefix for catchment IDs
#' @importFrom dplyr bind_rows select mutate tibble left_join
#' @importFrom sf st_drop_geometry
#' @export
get_catchment_edges <- function(fline,
                                nexus_prefix = "nexus",
                                catchment_prefix = "catchment") {
  bind_rows(

    st_drop_geometry(fline) %>%
      select(ID = COMID, toID = ToNode) %>%
      mutate(ID = paste0(catchment_prefix, ID),
             toID = paste0(nexus_prefix, toID)),

    tibble(ID = unique(fline$ToNode)) %>%
      left_join(select(st_drop_geometry(fline),
                       ID = FromNode, toID = COMID),
                by = "ID") %>%
      mutate(toID = ifelse(is.na(toID), 0, toID)) %>%
      mutate(ID = paste0(nexus_prefix, ID),
             toID = paste0(catchment_prefix, toID))

  )
}

#' @title get waterbody edge list
#' @param catchment_edge_list data.frame as returned by get_catchment_edges
#' @param catchment_prefix character prefix for catchment IDs
#' @param waterbody_prefix character prefix for waterbody IDs
#' @importFrom dplyr mutate
#' @export
get_waterbody_edge_list <- function(catchment_edge_list,
                                    catchment_prefix = "catchment",
                                    waterbody_prefix = "waterbody") {
  mutate(catchment_edge_list,
         ID = gsub(catchment_prefix, waterbody_prefix, ID),
         toID = gsub(catchment_prefix, waterbody_prefix, toID))
}

#' @title get catchment data
#' @param catchment sf data.frame NHDPlus Catchments
#' @param catchment_prefix character prefix for catchment IDs
#' @importFrom dplyr select mutate
#' @export
get_catchment_data <- function(catchment, catchment_prefix = "catchment") {
  select(catchment, ID = FEATUREID, area_sqkm = AreaSqKM) %>%
    mutate(ID = paste0(catchment_prefix, ID))
}

#' @title get_waterbody_data
#' @param fline sf data.frame NHDPlus Flowlines
#' @param waterbody_prefix character prefix for waterbody IDs
#' @importFrom dplyr select mutate
#' @export
get_waterbody_data <- function(fline, waterbody_prefix = "waterbody") {
  select(fline, ID = COMID,
         length_km = LENGTHKM,
         slope_percent = slope,
         main_id = LevelPathI) %>%
    mutate(ID = paste0(waterbody_prefix, ID))
}

#' @title get nexus data
#' @param nexus data.frame as returned by get_nexus
#' @importFrom dplyr select
#' @export
get_nexus_data <- function(nexus) {
  select(nexus, ID)
}
