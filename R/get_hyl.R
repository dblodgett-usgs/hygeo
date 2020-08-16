#' get hydrologic location
#' @description given a set of points with a known mainstem, calculates which incremental
#' flowpath feature each point is on including a measure along the feature.
#' 100 measure is the top, 0 measure is the bottom.
#' @param hyl a set of hydrologic location geometry with an identifier in the first column,
#' the mainstem id in the seccond column, and an sf_column in the third.
#' @param waterbody the waterbody table of an hygeo object.
#' @importFrom nhdplusTools get_flowline_index
#' @importFrom dplyr bind_rows select rename mutate bind_cols left_join
#' @importFrom sf st_sf
#' @return sf data.frame
#' @export
#'
get_hydrologic_locaton <- function(hyl, waterbody) {

  if(st_crs(hyl) != st_crs(waterbody)) stop("crs must be equal")

  waterbody <- waterbody %>%
    rename(COMID = .data$ID) %>%
    mutate(REACHCODE = .data$COMID,
           FromMeas = 0, ToMeas = 100)

  lps <- unique(waterbody$main_id)
  lps <- lps[lps %in% hyl$main_id]

  lapply(lps,
         link_by_path,
         waterbody = waterbody,
         hyl = hyl) %>%
    bind_rows() %>%
    select(-.data$REACHCODE) %>%
    rename(ID = .data$COMID, measure = .data$REACH_meas)
}

link_by_path <- function(lp, hyl, waterbody, radius = 1000) {
  if(nrow(hyl) == 0) browser()

  waterbody <- waterbody[waterbody$main_id == lp, ]

  hyl <- hyl[hyl$main_id == lp, ]

  indexes <- left_join(data.frame(id = seq_len(nrow(hyl))),
                       nhdplusTools::get_flowline_index(waterbody, hyl, search_radius = radius),
                       by = "id")
  indexes <- select(indexes, -id)

  st_sf(bind_cols(hyl[, 1],
                  indexes))
}

