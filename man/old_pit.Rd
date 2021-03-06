% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/old_pit.R
\name{old_pit}
\alias{old_pit}
\title{Collates data from readers in old format (<V5.0)}
\usage{
old_pit(data, test_tags = NULL, print_to_file = FALSE, time_zone = NULL)
}
\arguments{
\item{data}{filepath of the working directory containing data in old format}

\item{test_tags}{concatenated list of PIT codes used for testing antenna performance}

\item{print_to_file}{export metadata to working directory}

\item{time_zone}{time zone where data were collected, default is time zone of user’s computer}
}
\value{
List of data frames consisting of detection records, event records, non-detection and non-event records, duplicated detections, error records, and a character vector of unique readers.
}
\description{
Function collates data located in the working directory that were collected from readers with a firmware version earlier than 5.0 (April 2014). Users must define the working directory where the PIT files are located. If data is being collated from old and new formats, the user must separate working directories containing old and new data.
}
\details{
Data files must be in the format ‘pit_reader_mm_dd_yyyy.txt’. Note that pit_reader is the unique name of the PIT reader and that mm, dd and yyyy must be separated by underscores. If .txt is not at the end of each file, the user must enter .txt manually to each file prior to uploading the data. Users can use the \code{print_to_file} argument to export metadata to the working directory to confirm that data collation was performed correctly. Users can choose to specify the time zone where data were collected. Default for \code{time_zone} is the time zone of the user’s computer.
}
\examples{
#define working directory
old <- "./Old PIT Data/"

#no test tags, no metadata to print to working directory, data were collected in the time zone "America/Vancouver"
old_pit(data = old, test_tags = NULL, print_to_file = FALSE, time_zone = "America/Vancouver")
}
