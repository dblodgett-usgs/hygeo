get_hygeo_temp <- function() {
  temp_path <- file.path(tempdir(check = TRUE), "hygeo")
  unlink(temp_path, recursive = TRUE)
  dir.create(temp_path, recursive = TRUE, showWarnings = FALSE)
  temp_path
}

get_names <- function(x) {
  try(x<- sf::st_drop_geometry(x), silent = TRUE)
  names(x)
}

check_io <- function(hygeo_list, temp_path){
  hygeo_list_read <- read_hygeo(temp_path)

  expect_equal(names(hygeo_list), names(hygeo_list_read))

  expect_equal(lapply(hygeo_list, get_names), lapply(hygeo_list_read, get_names))

  expect_equal(lapply(hygeo_list, nrow), lapply(hygeo_list_read, nrow))

  expect_equal(lapply(hygeo_list, ncol), lapply(hygeo_list_read, ncol))
}
