
library(rvest)
library(httr) 

library(dplyr)
library(tidyr)
library(stringr)

# Load data
concerts <- read.csv("all_concert_data.csv", stringsAsFactors = FALSE)
concerts <- tbl_df(concerts)

# Clean leading/lagging whitespace
concerts$headliner <- trimws(concerts$headliner)

# Create df of every artist
headliners <- data_frame(concerts$headliner)
headliners <- headliners %>%
  rename(artist = `concerts$headliner`) %>%
  distinct()

# Start with just the headliner for now, you'll have to come back and clean the support + headliners more throughly
supporters <- concerts$support

# Generate a URL for each artist
headliners$query <- str_replace_all(headliners$artist, " ", "_")
headliners$url <- paste0("https://en.wikipedia.org/wiki/", headliners$query)

headliner_subset <- headliners[1:10, ]

# Create empty data frame to store concert data
all_artists <- data.frame(artist = character(),
                          Genres = character(), 
                          Labels = as.character(),
                          stringsAsFactors=FALSE)

scrape_wiki <- function(url){
  
  r <- GET(url, user_agent("Mozilla/5.0"))
  
  if (status_code(r) >= 300)
    return(NA_character_)
  
  tryCatch(
  r %>%
    read_html() %>%
    html_nodes(".vcard") %>% 
    html_table(), 
  error = function(e){NA}    # a function that returns NA regardless of what it's passed
  )
}

for(i in 1:nrow(headliners)) {
  
  print(headliners$artist[i])
  
  wiki_tables  <- scrape_wiki(headliners$url[i])
  
  if (!is.na(wiki_tables) && length(wiki_tables) > 0) {
    
    artist_background <- wiki_tables[[1]]
    
    tryCatch(
      colnames(artist_background) <- c("first_col", "second_col"),
      error = function(e){NA}
    )
    
    index <- which(artist_background$first_col == "Background information")
    
    last_index <- nrow(artist_background)
    
    if (length(index) > 0) {
      artist_background <- artist_background[sum(index + 1):last_index, ]
      
      artist_background <- artist_background %>%
        filter(second_col != "") %>%
        spread(first_col, second_col)
      
      artist_background$artist <- headliners$artist[i]
      
      # Print number to make sure the script is still working
      print(i)
      
      # Bind individual concert df to the main concerts data frame
      all_artists <- full_join(all_artists, artist_background)
    } else {
      print("Not a musician's wiki page")
    }
  } else {
    print("Bad URL")
  }
}

# Remove columns w/ bad data
export_df <- all_artists %>%
  select(1:7, 9:17)

write.csv(export_df, "artist_background_info.csv")

