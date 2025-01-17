## set default options for wm_opts:
.onLoad <- function(libname, pkgname) {
  op <- options()
  op.webmorph <- list(
    webmorph.connection = stdin(),
    webmorph.plot = TRUE,
    webmorph.verbose = TRUE,
    webmorph.dpi = 300,
    webmorph.line.color = "blue",
    webmorph.pt.color = "green",
    webmorph.fill = "white",
    webmorph.server = "https://webmorph.org",
    webmorph.plot = "magick",
    webmorph.plot.maxwidth = 10000,
    webmorph.plot.maxheight = 10000
  )
  toset <- !(names(op.webmorph) %in% names(op))
  if(any(toset)) options(op.webmorph[toset])

  invisible()
}

.onAttach <- function(libname, pkgname) {
  paste(
    "\n************",
    "Welcome to webmorphR. For support and examples visit:",
    "https://debruine.github.io/webmorphR/",
    #"If this package is useful, please cite it:",
    #paste0("http://doi.org/", utils::citation("webmorphR")$doi),
    "************\n",
    sep = "\n"
  ) %>% packageStartupMessage()
}
