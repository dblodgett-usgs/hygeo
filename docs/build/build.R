dir.create("docs/build/default/", showWarnings = FALSE)
dir.create("docs/build/fine/", showWarnings = FALSE)
dir.create("docs/build/coarse/", showWarnings = FALSE)
dir.create("docs/build/nhdp/", showWarnings = FALSE)

rmarkdown::render("vignettes/sugar_creek_refactor.Rmd",
                  params = list(
                    out_path = "../docs/build/default/",
                    split_m = 5000,
                    collapse_m = 1000,
                    gage_tolerance = 25),
                  output_file = "../docs/build/default/index.html")

rmarkdown::render("vignettes/sugar_creek_refactor.Rmd",
                  params = list(
                    out_path = "../docs/build/fine/",
                    split_m = 750,
                    collapse_m = 250,
                    gage_tolerance = 5),
                  output_file = "../docs/build/fine/index.html")

rmarkdown::render("vignettes/sugar_creek_refactor.Rmd",
                  params = list(
                    out_path = "../docs/build/coarse/",
                    split_m = 20000,
                    collapse_m = 3000,
                    gage_tolerance = 25),
                  output_file = "../docs/build/coarse/index.html")

rmarkdown::render("vignettes/sugar_creek_refactor.Rmd",
                  params = list(
                    out_path = "../docs/build/nhdp/",
                    split_m = 200000,
                    collapse_m = 1,
                    gage_tolerance = 100),
                  output_file = "../docs/build/nhdp/index.html")

setwd("docs/build")
zip::zip("coarse.zip",
         files = list.files("coarse/", full.names = TRUE, pattern = "*json"))
zip::zip("fine.zip",
         files = list.files("fine", full.names = TRUE, pattern = "*json"))
zip::zip("default.zip",
         files = list.files("default", full.names = TRUE, pattern = "*json"))
zip::zip("nhdp.zip",
         files = list.files("nhdp", full.names = TRUE, pattern = "*json"))
setwd("../../")
