
library(httr)
library(dplyr)

##################################################################
#                       Test the API                             #
##################################################################

# Working artist query - Response 200 = success
# Response 429 = to many requests
source("music_graph_api_credentials.R")

test_url <- paste0("http://api.musicgraph.com/api/v2/artist/search?api_key=", key, "&name=Danny+Brown")

# Call API
test_data <- GET(test_url, user_agent("Mozilla/5.0"))

# Store content
test_content <- content(test_data)

# Store status message
t_status <- test_content$status$message

t_country_origin <- test_content$data[[1]]$country_of_origin

t_genre <- test_content$data[[1]]$main_genre

t_gender <- test_content$data[[1]]$gender

t_spotify_id <- ntest_content$data[[1]]$spotify_id

##################################################################
#                    Get the data set                            #
##################################################################

# Load scraped wikipedia data
wikipedia_df <- read.csv("artist_background_info.csv", stringsAsFactors = FALSE)

# Select artists that have genre
headliners_w_genre <- wikipedia_df %>%
  dplyr::select(artist, Genres) %>%
  filter(!is.na(Genres)) %>%
  dplyr::select(artist)

# Load scraped concert data
concert_data <- read.csv("clean_headliners.csv", stringsAsFactors = FALSE)

# Trim whitespace
concert_data$headliner <- trimws(concert_data$headliner)

# Select only headliners, filter out artists that have genre from the wikipedia data set
artists_wOut_genre <- concert_data %>%
  dplyr::select(headliner) %>%
  distinct() %>%
  anti_join(headliners_w_genre, by = c("headliner" = "artist"))

artists_wOut_genre <- tbl_df(artists_wOut_genre)

##################################################################
#                       Call the API                             #
##################################################################

# Generate a URL for each artist
artists_wOut_genre$query <- str_replace_all(artists_wOut_genre$headliner, " ", "+")
artists_wOut_genre$url <- paste0("http://api.musicgraph.com/api/v2/artist/search?api_key=", key1, "&name=", artists_wOut_genre$query)

# Can only do 15 calls/min at 5k/month

api_df1 <- artists_wOut_genre[1:4750, ]
api_df2 <- artists_wOut_genre[4750:9154, ]

api_df2$url <- paste0("http://api.musicgraph.com/api/v2/artist/search?api_key=", key2, "&name=", api_df2$query)

# test set
test_df <- api_df1[1:5, ]

# Empty data frame to bind to
headliners <- data.frame(headliner = character(),
                         country_origin = character(), 
                         genre = as.character(),
                         gender = as.character(),
                         spotify_id = as.character(),
                         stringsAsFactors=FALSE)

for (i in 1:nrow(api_df2)) {
  
  # Call the API
  api_data <- GET(api_df2$url[i], user_agent("Mozilla/5.0"))
  # Store the content
  api_data <- content(api_data)
  
  if (api_data$pagination$count > 0) {
    
    # Store country of origin, genre, gender, spotify id
    api_country_origin <- if (!is.null(api_data$data[[1]]$country_of_origin)) {
      api_data$data[[1]]$country_of_origin
    } else {
      NA
    }
    
    api_genre <- if (!is.null(api_data$data[[1]]$main_genre)) {
      api_data$data[[1]]$main_genre
    } else {
      NA
    }
    
    api_gender <- if (!is.null(api_data$data[[1]]$gender)) {
      api_data$data[[1]]$gender
    } else {
      NA
    }
    
    api_spotify_id <- if (!is.null(api_data$data[[1]]$spotify_id)) {
      api_data$data[[1]]$spotify_id
    } else {
      NA
    }
    
    # Create one row data frame out of scraped concert data
    individual_df <- data.frame(headliner = api_df2$headliner[i],
                                country_origin = api_country_origin,
                                genre = api_genre,
                                gender = api_gender,
                                spotify_id = api_spotify_id)
    
    # Bind individual concert df to the main concerts data frame
    headliners <- bind_rows(headliners, individual_df)
    
    
    # Check to make sure script is running
    print(api_data$status$message)
    print(i)
    
  } else {
    print("Couldn't find data for this artist")
  }
  
  # Sleep for 4 seconds to avoid rate-call limit
  Sys.sleep(4.5)
  
}

write.csv(headliners, "music_graph_api_data.csv")




