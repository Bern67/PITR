\name{oregon_rfid}
\alias{oregon_rfid}
\docType{data}
\title{Dataset to illustrate the PITR functions}
\description{Example dataset from a multi reader with two antennas that can be used to illustrate the PITR functions, \code{\link{det_eff}}, \code{\link{direction}}, \code{\link{direction_total}} and \code{\link{first_last}}. Note that this dataset can be restructured through the function \code{\link{array_config}}.}
\format{Data frame contains 798 detections on the following 12 variables.

  \describe{
\item{\code{reader}}{a character vector of PIT readers}
\item{\code{antenna}}{a numeric vector of the antenna number}
\item{\code{det_type}}{a character vector of the detection record}
\item{\code{date}}{a character vector of date}
\item{\code{time}}{a character vector of time}
\item{\code{date_time}}{date and time in POSIXct format}
\item{\code{time_zone}}{time zone where data were collected}
\item{\code{dur}}{a character vector of the duration of the detection}
\item{\code{tag_type}}{a character vector of the tag type}
\item{\code{tag_code}}{a character vector of the tag codes}
\item{\code{consec_det}}{a character vector of the number of consecutive detections}
\item{\code{no_empt_scan_prior}}{a character vector of the number of empty scans}
  }
}
\examples{
#load test dataset containing detections from a multi reader with two antennas
oregon_rfid <- new_pit(data = "oregon_rfid", test_tags = NULL, print_to_file = FALSE, time_zone = "America/Vancouver")

det_eff(data = oregon_rfid, resolution = "month", direction = "up")
direction(data = oregon_rfid)
direction_total(data = oregon_rfid, resolution = "year", start_date = "2015-11-11 10:30:00")
first_last(data = oregon_rfid, resolution = "month", start_date = "2015-10-15 08:00:00")
}
\keyword{datasets}
