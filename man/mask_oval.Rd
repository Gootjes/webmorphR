% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mask_oval.R
\name{mask_oval}
\alias{mask_oval}
\title{Apply an oval mask to images}
\usage{
mask_oval(stimuli, bounds = NULL, fill = wm_opts("fill"), each = TRUE)
}
\arguments{
\item{stimuli}{list of class stimlist}

\item{bounds}{bounds (t, r, b, l) of oval, calculated from templates if NULL}

\item{fill}{background color for mask}

\item{each}{whether to calculate a mask for each image (default) or just one}
}
\value{
stimlist with cropped tems and/or images
}
\description{
Superimpose an oval mask on a set of images. If the images have templates and bounds = NULL, the maxiumum and minimum x and y coordinates for each image will be calculated (or the overall max and min if each = FALSE) and an oval with those dimensions and position will be placed over the face.
}
\details{
If bounds are set to a list of top, right, bottom and left boundaries, these will be used instead of the boundaries derived from templates.
}
\examples{
omask1 <- demo_stim() \%>\% mask_oval(fill = "hotpink")

# remove external points
omask2 <- demo_stim() \%>\%
  subset_tem(features("face")) \%>\%
  crop_tem(25) \%>\%
  mask_oval()

# set bounds manually
omask3 <- demo_stim() \%>\%
  mask_oval(bounds = list(t= 70, r = 120, b = 70, l = 120))
}
