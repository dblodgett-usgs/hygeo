.data <- NULL

#' @title get nexuses
#' @param fline sf data.frame NHDPlus Flowlines or hyRefactor output.
#' @param nexus_prefix character prefix for nexus IDs
#' @importFrom sf st_coordinates st_as_sf st_crs
#' @importFrom magrittr %>%
#' @importFrom dplyr group_by filter ungroup select n row_number rename
#' @export
get_nexus <- function(fline, nexus_prefix = "nexus_") {
  nexus <- fline %>%
    st_coordinates() %>%
    as.data.frame()

  if("L2" %in% names(nexus)) {
    nexus <- rename(nexus, GG = .data$L2)
  } else {
    nexus <- rename(nexus, GG = .data$L1)
  }

  fline <- check_nexus(fline)

  nexus <- nexus %>%
    group_by(.data$GG) %>%
    filter(row_number() == n()) %>%
    ungroup() %>%
    select(.data$X, .data$Y) %>%
    st_as_sf(coords = c("X", "Y"), crs = st_crs(fline))

  nexus$ID <- paste0(nexus_prefix, fline$to_nID)

  if(length(unique(nexus$ID)) < nrow(nexus)) {
    nexus <- group_by(nexus, .data$ID) %>%
      filter(row_number() == 1) %>%
      ungroup()
  }

  return(nexus)
}

check_nexus <- function(fline) {
  if("FromNode" %in% names(fline)) {
    fline <- rename(fline, from_nID = .data$FromNode)
  } else if(!"from_nID" %in% names(fline)) {
    fline$from_nID <- fline$ID
  }

  if("ToNode" %in% names(fline)) {
    fline <- rename(fline, to_nID = .data$ToNode)
  } else if(!"to_nID" %in% names(fline)) {
    fline <- left_join(fline,
                       select(st_drop_geometry(fline), .data$ID, to_nID = .data$from_nID),
                       by = c("toID" = "ID"))
  }

  fline

}

#' @title get catchment edges
#' @param fline sf data.frame NHDPlus Flowlines or hyRefactor output.
#' @param nexus_prefix character prefix for nexus IDs
#' @param catchment_prefix character prefix for catchment IDs
#' @importFrom dplyr bind_rows select mutate tibble left_join
#' @importFrom sf st_drop_geometry
#' @export
get_catchment_edges <- function(fline,
                                nexus_prefix = "nexus_",
                                catchment_prefix = "catchment_") {

  if("COMID" %in% names(fline)) fline <- rename(fline, ID = .data$COMID)

  fline <- check_nexus(fline)

  bind_rows(

    st_drop_geometry(fline) %>%
      select(ID = .data$ID, toID = .data$to_nID) %>%
      mutate(ID = paste0(catchment_prefix, .data$ID),
             toID = paste0(nexus_prefix, .data$toID)),

    tibble(ID = unique(fline$to_nID)) %>%
      left_join(select(st_drop_geometry(fline),
                       ID = .data$from_nID, toID = .data$ID),
                by = "ID") %>%
      mutate(toID = ifelse(is.na(.data$toID), 0, .data$toID)) %>%
      mutate(ID = paste0(nexus_prefix, .data$ID),
             toID = paste0(catchment_prefix, .data$toID))

  )
}

#' @title get waterbody edge list
#' @description Takes flowlines from either NHDPlus or hyRefactor and returns
#' dendritic waterbody topology. This maps onto the HY_Features waterbody class
#' and downstream waterbody associations.
#' See: https://docs.opengeospatial.org/is/14-111r6/14-111r6.html#_the_hydrographic_network_model
#' @param fline sf data.frame NHDPlus Flowlines or hyRefactor output.
#' @param waterbody_prefix character prefix for waterbody IDs
#' @importFrom dplyr mutate filter
#' @importFrom nhdplusTools prepare_nhdplus
#' @export
get_waterbody_edge_list <- function(fline,
                                    waterbody_prefix = "waterbody_") {
  if("COMID" %in% names(fline) && !"toCOMID" %in% names(fline)) {
    fline <- prepare_nhdplus(fline, 0, 0, 0, FALSE, warn = FALSE) %>%
      select(ID = .data$COMID, toID = .data$toCOMID)
  } else {
    try(fline <- st_drop_geometry(fline), silent = TRUE)
  }

  fline %>%
    select(.data$ID, .data$toID) %>%
    mutate(toID = ifelse(is.na(.data$toID), 0, .data$toID)) %>%
    mutate(ID = paste0(waterbody_prefix, .data$ID),
           toID = paste0(waterbody_prefix, .data$toID))
}

#' @title get catchment data
#' @param catchment sf data.frame NHDPlus Catchments or hyRefactor output.
#' @param catchment_edge_list data.frame edge list of connections
#' to/from catchments
#' @param catchment_prefix character prefix for catchment IDs
#' @importFrom dplyr select mutate left_join
#' @export
get_catchment_data <- function(catchment, catchment_edge_list,
                               catchment_prefix = "catchment_") {
  if("FEATUREID" %in% names(catchment)) catchment <- rename(catchment, ID = .data$FEATUREID, area_sqkm = .data$AreaSqKM)

  if(!"area_sqkm" %in% names(catchment)) stop("must supply area as AreaSqKM or area_sqkm")

  catchment <- select(catchment, ID = .data$ID, area_sqkm = .data$area_sqkm) %>%
    mutate(ID = paste0(catchment_prefix, .data$ID)) %>%
    left_join(catchment_edge_list, by = "ID")
}

#' @title get_waterbody_data
#' @param fline sf data.frame NHDPlus Flowlines or hyRefactor output.
#' @param waterbody_edge_list data.frame edge list of connections
#' to/from waterbodies
#' @param waterbody_prefix character prefix for waterbody IDs
#' @importFrom dplyr select mutate left_join
#' @export
get_waterbody_data <- function(fline, waterbody_edge_list,
                               waterbody_prefix = "waterbody_") {

  if("COMID" %in% names(fline)) fline <- rename(fline, ID = .data$COMID,
                                                LevelPathID = .data$LevelPathI)

  select(fline, ID = .data$ID,
         length_km = .data$LENGTHKM,
         slope_percent = .data$slope,
         main_id = .data$LevelPathID) %>%
    mutate(ID = paste0(waterbody_prefix, .data$ID)) %>%
    left_join(waterbody_edge_list, by = "ID")
}

#' @title get nexus data
#' @param nexus data.frame as returned by get_nexus
#' @param catchment_edge_list data.frame edge list of connections
#' to/from catchments
#' @param waterbody_edge_list data.frame edge list of connections
#' to/from waterbodies
#' @importFrom dplyr select
#' @export
get_nexus_data <- function(nexus, catchment_edge_list, waterbody_edge_list) {
  select(nexus, .data$ID) %>%
    left_join(rbind(catchment_edge_list, waterbody_edge_list), by = "ID")
}
