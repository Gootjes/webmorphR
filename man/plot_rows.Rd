% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.R
\name{plot_rows}
\alias{plot_rows}
\title{Plot in rows}
\usage{
plot_rows(..., top_label = FALSE)
}
\arguments{
\item{...}{stimlists (optionally named) and any arguments to pass on to \code{\link{label}}}

\item{top_label}{whether to plot row labels above the row or inside}
}
\value{
stimlist with plot
}
\description{
Plot in rows
}
\examples{
up <- demo_stim()
inv <- rotate(up, 180)
plot_rows(upright = up, inverted = inv)
plot_rows(upright = up, inverted = inv, color = "dodgerblue", top_label = TRUE)
}
