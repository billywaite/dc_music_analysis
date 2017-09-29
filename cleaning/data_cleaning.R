
library(dplyr)
library(tidyr)
library(lubridate)
library(stringi)


####################################################################
#                       Clean Songkick data                        #
####################################################################

# Join all of the data sets from Songkick first
file_names <- list.files(pattern="*.csv")
concerts <- do.call(rbind,lapply(file_names, read.csv))

# Convert to tbl
concerts <- tbl_df(concerts)

# Convert data types
concerts$headliner <- as.character(concerts$headliner)
concerts$support <- as.character(concerts$support)

# Split support column into headliner and support artists
concerts2 <- concerts %>%
  select(venue, support, date) %>%
  separate(support, c("headliner", "support"), 
           sep = ",")

# Remove new lines from headliner & support columns
concerts2$headliner <- str_replace_all(concerts2$headliner, "\n", "")
concerts2$support <- str_replace_all(concerts2$support, "\n", "")

# Split day of the week from the main date column
concerts2 <- concerts2 %>%
  separate(date, c("weekday", "date"), sep = "day")

# Add the y you just removed back to the day of the week
concerts2$weekday <- paste(concerts2$weekday, "day", sep ="")
# Remove whitespace
concerts2$weekday <- str_replace_all(concerts2$weekday, " ", "")
# Remove new line
concerts2$weekday <- str_replace_all(concerts2$weekday, "\n", "")
# Convert to factor for analysis
concerts2$weekday <- as.factor(concerts2$weekday)

# Need to remove extra text before converting to date - example pattern <89><db><d2>

# Extract year
concerts2$year <- stri_extract_last_regex(concerts2$date, "\\d{4}")
# Remove extra text
concerts2$date <- gsub("\\d{4}.*", "", concerts2$date)
# Add the year back to the date column
concerts2$date <- paste(concerts2$date, concerts2$year)
# Convert to date
concerts2$date <- dmy(concerts2$date)

# Remove the extra year column
clean_songkick <- concerts2 %>%
  select(1:5)

####################################################################
# Clean u Hall Data - This was scraped directly from their website #
####################################################################

# Load data from uhall (different structure because scraped direct from their website)
uhall <- read.csv("uhall.csv")

# Convert to tbl
uhall <- tbl_df(uhall)

# Convert headliner, support, ticket_price, time to character strings
uhall$headliner <- as.character(uhall$headliner)
uhall$support <- as.character(uhall$support)
uhall$ticket_price <- as.character(uhall$ticket_price)
uhall$time <- as.character(uhall$time)

# Split columns and remove extra columns
uhall2 <- uhall %>%
  separate(date, c("date", "remove"), sep = "-") %>%
  separate(date, c("weekday", "date"), sep = "day") %>%
  select(1:5, 7:8)

# Join the year column into the date column
uhall2$date <- paste(uhall2$date, uhall2$year)

# Convert to date
uhall2$date <- mdy(uhall2$date)

# Add the text you removed
uhall2$weekday <- paste(uhall2$weekday, "day", sep ="")
uhall2$weekday <- as.factor(uhall2$weekday)

# Remove unnecessary year column
clean_uhall <- uhall2 %>%
  select(1:2, 4:7)

# Add column for venue
clean_uhall$venue <- "U Street Music Hall"

# Move venue to the front of the dataframe
clean_uhall <- clean_uhall %>% 
  select(venue, everything())

####################################################################
#                 Join data together for export                    #
####################################################################

# Add empty columns prior to join
clean_songkick$time <- ""
clean_songkick$ticket_price <- ""

# Bind uhall dataframe into the songkick data frame
all_concerts <- rbind(clean_songkick, clean_uhall)

# Export data for quick look in Tableau
write.csv(all_concerts, "all_concert_data.csv")


############################################################################
#      Cleaning headliner column for use in API queries                    #
############################################################################

# Load data
concerts <- read.csv("all_concert_data.csv", stringsAsFactors = FALSE)
concerts <- tbl_df(concerts)

# Clean leading/lagging whitespace
concerts$headliner <- trimws(concerts$headliner)
concerts$support <- trimws(concerts$support)

# Remove remove everything between parentheses 
concerts$headliner <- gsub("\\s*\\([^\\)]+\\)","",as.character(concerts$headliner))

# Remove strings from artist names
concerts$headliner <- str_replace_all(concerts$headliner, "DJ Set", "")
concerts$headliner <- str_replace_all(concerts$headliner, "Fall Residency", "")
concerts$headliner <- str_replace_all(concerts$headliner, "- LIVE", "")
concerts$headliner <- str_replace_all(concerts$headliner, "- SHOW IS CANCELLED", "")
concerts$headliner <- str_replace_all(concerts$headliner, "CANCELLED -", "")
concerts$headliner <- str_replace_all(concerts$headliner, "SOLD OUT!", "")
concerts$headliner <- str_replace_all(concerts$headliner, "CANCELLED", "")

# Filter out festivals
clean_headliner <- function(string, df) {
  
  df$festival <- grepl(string, df$headliner)
  festivals <- df %>% filter(festival == TRUE)
  
  x <- paste0("Removed ", nrow(festivals), " rows that contained the string: ", string)

  df <- df %>%
    filter(festival != TRUE) %>%
    dplyr::select(1:8)
  
  return(df)
}

festival_strings <- c("Festival", "FESTIVAL", "festival", "FESTiVAL", "Jazz Fest", "Roamfest", "ROAMfest", "Labor Day Fest", "FreeFest",
                      "Jazz Fest", "Free Fest", "Breakin Even Fest", "OMG Music Fest", "Hippiefest", "Reggae Fest", "GRILLFEST")

for (i in 1:length(festival_strings)) {
  concerts <- clean_headliner(festival_strings[i], concerts)
  print(festival_strings[i])
}

write.csv(concerts, "clean_headliners.csv")


















