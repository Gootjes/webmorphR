% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/info.R
\name{get_info}
\alias{get_info}
\title{Get Information}
\usage{
get_info(stimuli, ..., .rownames = "id")
}
\arguments{
\item{stimuli}{list of class stimlist}

\item{...}{column names to return}

\item{.rownames}{whether to return a table with no rownames (NULL), rownames from the list item names (NA), or as a new column (the column name as a string)}
}
\value{
a data frame or vector of the info
}
\description{
Get Information
}
\examples{
stimuli <- demo_stim() \%>\%
  add_info(project = "test", gender = c("F", "M"))

get_info(stimuli)
get_info(stimuli, "gender")
}
