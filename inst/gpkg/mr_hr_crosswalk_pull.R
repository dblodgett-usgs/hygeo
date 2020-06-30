# Leaving the code used to derive the hr_NHDPlusFlowline layer in sugar creek gpkg
# matched <- readr::read_csv("../../HU12_NHD/out/report/matched.csv")
#
# src_gpkg <- system.file("gpkg/sugar_creek_fort_mill.gpkg", package = "hygeo")
#
# fline <- nhdplusTools::align_nhdplus_names(sf::read_sf(src_gpkg, "NHDFlowline_Network"))
#
# comids <- nhdplusTools::get_UT(fline, 9731454)
#
# fline <- dplyr::filter(fline, COMID %in% comids)
#
# all_lps <- unique(fline$LevelPathI)
#
# matched <- dplyr::filter(matched, mr_LevelPathI %in% all_lps)
#
# hr <- nhdplusTools::get_hr_data("~/Documents/Data/hr/03/0305.gdb/", layer = "NHDFlowline")
#
# hr_sub <- dplyr::filter(hr, COMID %in% matched$member_NHDPlusID)
#
# mapview::mapview(fline, lwd = 3, color = "blue") + mapview::mapview(hr_sub, lwd = 1.5, color = "red")
#
# hr_sub <- dplyr::left_join(hr_sub, dplyr::select(matched, COMID = member_NHDPlusID, mr_LevelPathI), by = "COMID")
#
# sf::write_sf(hr_sub, "inst/gpkg/sugar_creek_fort_mill.gpkg", "hr_NHDPlusFlowline")
