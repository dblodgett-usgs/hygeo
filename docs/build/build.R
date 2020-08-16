dir.create("docs/build/default/", showWarnings = FALSE)
dir.create("docs/build/fine/", showWarnings = FALSE)
dir.create("docs/build/coarse/", showWarnings = FALSE)

rmarkdown::render("vignettes/sugar_creek_refactor.Rmd",
                  params = list(
                    out_path = "..docs/build/default/",
                    split_m = 5000,
                    collapse_m = 1000,
                    gage_tolerance = 25),
                  output_file = "..docs/build/default/index.html")

rmarkdown::render("vignettes/sugar_creek_refactor.Rmd",
                  params = list(
                    out_path = "..docs/build/fine/",
                    split_m = 750,
                    collapse_m = 250,
                    gage_tolerance = 5),
                  output_file = "..docs/build/fine/index.html")

rmarkdown::render("vignettes/sugar_creek_refactor.Rmd",
                  params = list(
                    out_path = "../build/coarse/",
                    split_m = 20000,
                    collapse_m = 3000,
                    gage_tolerance = 25),
                  output_file = "..docs/build/coarse/index.html")

zip("docs/build/coarse.zip", files = "docs/build/coarse/")
zip("docs/build/fine.zip", files = "docs/build/fine/")
zip("docs/build/default.zip", files = "docs/build/default")

unlink("docs/build/coarse/*json")
unlink("docs/build/fine/*json")
unlink("docs/build/default/*json")
