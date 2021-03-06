#' @title Restructure the configuration of arrays
#'
#' @description Function allows users to combine unique readers into an array, split readers with multiple antennas into single readers, and rename an antenna on one reader or one array. Use of this function allows users to manage data for further analysis using \code{\link{det_eff}}, \code{\link{direction}}, \code{\link{direction_total}}, and \code{\link{first_last}} functions.
#' @param data telemetry dataset created using \code{\link{old_pit}} or \code{\link{new_pit}} function
#' @param configuration either \code{combine}, \code{split} or \code{rename_antennas}
#' @param array_name name of array
#' @param r1 name of reader 1
#' @param r2 name of reader 2
#' @param r3 name of reader 3
#' @param r4 name of reader 4
#' @param reader_name name of reader to split
#' @param new_reader_1_antennas specific antennas to be grouped into reader 1
#' @param ao1 old antenna 1
#' @param ao2 old antenna 2
#' @param ao3 old antenna 3
#' @param ao4 old antenna 4
#' @param an1 new antenna 1
#' @param an2 new antenna 2
#' @param an3 new antenna 3
#' @param an4 new antenna 4
#' @return Updated dataset for further analysis using \code{\link{det_eff}}, \code{\link{direction}}, \code{\link{direction_total}} and \code{\link{first_last}} functions.
#' @details Function is dependent on what the user defines in the \code{configuration} argument. Argument \code{split} is used to split multi readers into two or more single readers to allow the combination of single readers into a user-specified array (see Example 1). Argument \code{combine} is used to combine up to four single readers into one array (see Example 2). If a user wants to combine a multi reader with another reader (either a multi or single reader), the user first must split the multi reader into two or more single readers and then combine them together into an array. Argument \code{new_reader_1_antennas} is used to define the antennas to group into reader 1. All other antennas are grouped into reader 2. Argument \code{rename_antennas} is used to either rename antennas part of an array (if \code{array_name} is specified) or antennas part of a reader (if \code{reader_name} is specified) (see Example 3). Users can rename up to four antennas for one reader or one array. Arguments with the prefix ‘ao’ correspond to the old (or current) antenna numbering scheme, whereas arguments with the prefix ‘an’ correspond to the new antenna numbering scheme. Old antennas must be specified in order within the \code{array_config} function. Depending on the setup of the study, the user may have to run the \code{array_config} function several times. Note that use of arguments \code{combine}, \code{split} and \code{rename_antennas} must be iterative (see Examples).
#' @examples
#' #load test dataset containing detections from a multi reader with two antennas
#' oregon_rfid <- new_pit(data = "oregon_rfid", test_tags = NULL, print_to_file = FALSE, time_zone = "America/Vancouver")
#'
#' #Example 1: split a multi reader with two antennas into two single readers
#' #users can split multi readers with two or more antennas into two or more single readers that can later be combined into user-defined arrays
#' split <- array_config(data = oregon_rfid, configuration = "split", reader_name = "dam", new_reader_1_antennas = "1")
#'
#' #Example 2: combine two single readers into an array called fishway
#' #users can combine two or more single readers (using a raw or split dataset) into arrays
#' #if there is an existing dataset with two or more readers (multi or single readers or a combination), the user can start by combining the readers into arrays
#' combine <- array_config(data = split, configuration = "combine", array_name = "fishway", r1 = "dam_1", r2 = "dam_2")
#'
#' #Example 3: rename the two antennas
#' rename_one <- array_config(data = combine, configuration = "rename_antennas", array_name = "fishway", ao1 = "1", an1 = "3")
#' rename_two <- array_config(data = rename_one, configuration = "rename_antennas", array_name = "fishway", ao1 = "2", an1 = "4")
#' @export

array_config <- function (data, configuration, array_name=NULL, r1=NULL, r2=NULL, r3=NULL, r4=NULL,
                          reader_name=NULL, new_reader_1_antennas=NULL,
                          ao1=NULL, ao2=NULL, ao3=NULL, ao4=NULL, an1=NULL, an2=NULL, an3=NULL, an4=NULL) {

  # Combine up to four readers with single antennas into one array.
  # The readers should be inputed in order so that the new antenna numbers 1,2,3,4 are in order of downstream to upstream

  if (is.null(configuration)) stop("Error: configuration must be specified")

  if (configuration == "combine") {

    if (is.null(array_name)) stop("Error: array_name must be specified")

    if (!is.null(array_name)) {

      # Select data that comes from readers you want to combine
      rd <- filter(data, reader %in% c(r1,r2,r3,r4))
      # Select all other data to merge back in later
      rr <- filter(data, !(reader %in% c(r1,r2,r3,r4)))

      # Assign new antenna numbers based on readers (r1, r2, r3 and r4 get antenna 3"s 1,2,3 and 4 respectively)

      # If r1 exists, give new antenna number 1 (so it would be antenna 1 on "new PIT array")
      if (!is.null(r1)) {
        x1 <- which(rd$reader == r1)
        rd$antenna[x1] <- 1
      }

      # If r2 exists, give new antenna number 2 (so it would be antenna 2 on "new PIT array")
      if (!is.null(r2)) {
        x2 <- which(rd$reader == r2)
        rd$antenna[x2] <- 2
      }


      # If r3 exists, give new antenna number 3 (so it would be antenna 3 on "new PIT array")
      if (!is.null(r3)) {
        x3 <- which(rd$reader == r3)
        rd$antenna[x3] <- 3
      }

      # If r4 exists, give new antenna number 4 (so it would be antenna 4 on "new PIT array")
      if (!is.null(r4)) {
        x4 <- which(rd$reader == r4)
        rd$antenna[x4] <- 4
      }

      # All get new array name (becasue it is being combinerd into one PIT array)
      rd$array <- array_name

      # The array name of the rest of the data is defaulted to the reader name
      # Unless the function has already been run through and an array column has been created, in which case the array column is left as is
      if ("array" %in% names(rr)) rr$array<-rr$array else rr$array<-rr$reader

      nc <- rbind(rd,rr)

      # Reorder columns
      nc <- select(nc,array,reader,antenna,det_type,date,time,date_time,time_zone,dur,tag_type,tag_code,consec_det,no_empt_scan_prior)

      array_summary(nc)

      return(nc)

    }
  }

  if (configuration == "split") {

    if (is.null(reader_name)) stop("Error: reader name must be specified")

    if (!is.null(reader_name)) {

      if(is.null(new_reader_1_antennas)) stop("Error: Must specify which antenna(s) will become part of the new reader 1")

      # Select data that comes from reader you want to split in two
      rd <- filter(data,reader == reader_name)
      # Select all other data to merge back in later
      rr <- filter(data, reader != reader_name)

      # Assign new reader names based on antenna specifications (ao1,a02,and a03 get "reader"_1; all others get get "reader"_2)
      if (!is.null(new_reader_1_antennas)) {
        rd$reader <- ifelse(rd$antenna == new_reader_1_antennas, paste(reader_name,"1",sep="_"), paste(reader_name,"2",sep="_"))
      }

      # Create an array column if one doesn't exist, if the array column does exist then default to it here
      if ("array" %in% names(rr)) rr$array<-rr$array else rr$array<-rr$reader
      if ("array" %in% names(rd)) rd$array<-rd$array else rd$array<-rd$reader

      nc<- rbind(rd,rr)

      array_summary(nc)

      nc <- select(nc,array,reader,antenna,det_type,date,time,date_time,time_zone,dur,tag_type,tag_code,consec_det,no_empt_scan_prior)

      return(nc)
    }
  }

  if (configuration == "rename_antennas") {

    if (!is.null(reader_name) & !is.null(array_name)) stop("Error: Only specify one array or one reader with antennas to rename")

    if (is.null(reader_name) & is.null(array_name)) stop("Error: Must specify a reader or array with antennas to rename")


    if (!is.null(reader_name)) {

      # Select data that comes from reader you want to reconfig antennas for
      rd <- filter(data, reader == reader_name)

      # Select all other data to merge back in later
      rr <- filter(data, reader != reader_name)

      #Assign new antenna numbers based on number entries (ao1-> an1, ao2-> an2, ao3 -> an3, a04 -> an4)

      # For now we will only allow one reader at a time to be renamed
      if(!is.null(ao2)) stop("Only one antenna can be renamed per function call")
      if(!is.null(ao3)) stop("Only one antenna can be renamed per function call")
      if(!is.null(ao4)) stop("Only one antenna can be renamed per function call")

      # If ao1 exists, give new antenna number an1
      if (!is.null(ao1)) {
        df1 <- rd
        if(ao1 == "NA") {
          x1 <- which(is.na(df1$antenna))
          df1$antenna[x1] <- an1
        } else {
          x1 <- which(df1$antenna == ao1)
          df1$antenna[x1] <- an1
        }
      }

      # # If ao2 exists, give new antenna number an2
      # if (!is.null(ao2)) {
      #   df2 <- rd
      #   x2 <- which(df2$antenna == ao2)
      #   df2$antenna[x2] <- an2
      # }
      #
      # # If ao3 exists, give new antenna number an3
      # if (!is.null(ao3)) {
      #   df3 <- rd
      #   x3 <- which(df3$antenna == ao3)
      #   df3$antenna[x3] <- an3
      # }
      #
      # #If ao4 exists, give new antenna number an4
      # if (!is.null(ao4)) {
      #   df4 <- rd
      #   x4 <- which(df4$antenna == ao4)
      #   df4$antenna[x4] <- an4
      # }

      # Combine the data frames
      rd <- df1
      # if (exists("df2")) rd <- rbind(df1,df2)
      # if (exists("df3")) rd <- rbind(df1,df2,df3)
      # if (exists("df4")) rd <- rbind(df1,df2,df3,df4)

      # Create an array column if one doesn't exist, if the array column does exist then default to it here
      if ("array" %in% names(rr)) rr$array<-rr$array else rr$array<-rr$reader
      if ("array" %in% names(rd)) rd$array<-rd$array else rd$array<-rd$reader

      nc<- rbind(rd,rr)

      array_summary(nc)

      return(nc)
    }

    if (!is.null(array_name)) {

      if(!"array" %in% names(data)) stop("Error: No arrays column exists")

      # Select data that comes from reader you want to reconfig antennas for
      rd <- filter(data, array == array_name)

      # Select all other data to merge back in later
      rr <- filter(data, array != array_name)

      # For now we will only allow one reader at a time to be renamed
      if(!is.null(ao2)) stop("Only one antenna can be renamed per function call")
      if(!is.null(ao3)) stop("Only one antenna can be renamed per function call")
      if(!is.null(ao4)) stop("Only one antenna can be renamed per function call")

      #Assign new antenna numbers based on number entries (ao1-> an1, ao2-> an2, ao3 -> an3, a04 -> an4)

      # If ao1 exists, give new antenna number an1
      if (!is.null(ao1)) {
        df1 <- rd
        if(ao1 == "NA") {
          x1 <- which(is.na(df1$antenna))
          df1$antenna[x1] <- an1
        } else {
          x1 <- which(df1$antenna == ao1)
          df1$antenna[x1] <- an1
        }
      }

      # # If ao2 exists, give new antenna number an2
      # if (!is.null(ao2)) {
      #   df2 <- rd
      #   x2 <- which(df2$antenna == ao2)
      #   df2$antenna[x2] <- an2
      # }
      #
      # # If ao3 exists, give new antenna number an3
      # if (!is.null(ao3)) {
      #   df3 <- rd
      #   x3 <- which(df3$antenna == ao3)
      #   df3$antenna[x3] <- an3
      # }
      #
      # #If ao4 exists, give new antenna number an4
      # if (!is.null(ao4)) {
      #   df4 <- rd
      #   x4 <- which(df4$antenna == ao4)
      #   df4$antenna[x4] <- an4
      # }

      # Combine the data frames
      rd <- df1
      # if (exists("df2")) rd <- rbind(df1,df2)
      # if (exists("df3")) rd <- rbind(df1,df2,df3)
      # if (exists("df4")) rd <- rbind(df1,df2,df3,df4)

      # Create an array column if one doesn't exist, if the array column does exist then default to it here
      if ("array" %in% names(rr)) rr$array<-rr$array else rr$array<-rr$reader
      if ("array" %in% names(rd)) rd$array<-rd$array else rd$array<-rd$reader

      nc<- rbind(rd,rr)

      array_summary(nc)

      return(nc)
    }
  }
}

array_summary <- function(x) {
  x1 <- select(x,array,reader,antenna)
  x2 <- unique(x1)
  print("Summary of current array, reader, and antenna configuration:")
  print(x2)
}
