% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/blank.R
\name{blank}
\alias{blank}
\title{Make blank images}
\usage{
blank(n = 1, width = 100, height = 100, color = "white", names = "img")
}
\arguments{
\item{n}{the number of images to return}

\item{width}{width of the images}

\item{height}{height of the images}

\item{color}{background colour of the images}

\item{names}{names of the images}
}
\value{
stimlist with labelled images
}
\description{
Make blank images
}
\examples{
blank(5, 100, 300, color = rainbow(5))
}
