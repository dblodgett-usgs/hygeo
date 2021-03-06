% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions.R
\name{get_nhd_crosswalk}
\alias{get_nhd_crosswalk}
\title{Get NHD Crosswalk}
\usage{
get_nhd_crosswalk(
  x,
  catchment_prefix = "catchment_",
  network_order = NULL,
  sites = data.frame(local_id = character(0), site_no = character(0))
)
}
\arguments{
\item{x}{sf data.frame output from reconcile_collapsed_flowlines() function}

\item{catchment_prefix}{character prefix to be appended to local_id output.}

\item{network_order}{data.frame COMID and Hydroseq attributes allowing
upstream downstream sorting.}

\item{sites}{data.frame local_id and site_no for sites that should be added
to the output list. Only used if network_order is not NULL}
}
\value{
If network_order is supplied, a list format is returned, if
network_order is NULL, a basic crosswalk table is returned.
}
\description{
Get NHD Crosswalk
}
