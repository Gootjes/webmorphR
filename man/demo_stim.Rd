% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/demo_stim.R
\name{demo_stim}
\alias{demo_stim}
\title{Demo Stimuli}
\usage{
demo_stim(
  dir = c("test", "composite", "london", "smiling", "lisa", "zoom", "rainbow"),
  pattern = NULL,
  ...
)
}
\arguments{
\item{dir}{the directory in extdata to get files from}

\item{pattern}{defaults to all files}

\item{...}{Other arguments to pass on to \code{read_tem()}}
}
\value{
stimlist
}
\description{
A convenience function to get demo stimuli
}
\examples{
demo_stim() \%>\% plot()

}
