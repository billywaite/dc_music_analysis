
# Load libraries
library(rvest)
library(dplyr)
library(stringr)

# Create empty data frame to store concert data
concerts <- data.frame(headliner = character(),
                       support = character(), 
                       date = as.character(),
                       stringsAsFactors=FALSE)

# Build vector of venue queries - just start with 9:30 club
venue_queries <- c("9%3A30+club")
# maybe it makes sense to create a list or dF with the venue query and the years so we can map

# Generate url for the 1st page of results from songkick that queries by year
pages <- map(1996:2017, function(x) {
  paste0("http://www.songkick.com/search?page=1&query=9%3A30+club+", x)
})

# Scrape the list of 1st page results to determine the # of pages by year
pagination <- pages %>%
  map(read_html) %>%
  map(html_nodes, ".pagination") %>%
  map(html_text)

# Get index of the word "Next" which falls at the end of the pagination string
next_index <- regexpr("Next", pagination)

# Subset pagination strings using the index from above, convert to numeric
pages_by_year <- as.numeric(substr(pagination, next_index-3, next_index-2))

# Create the urls for each page of results by year
all_pages_urls <- c("")

for (i in 1:length(pages)) {
  
  # Store the year
  year <- substr(pages[i], nchar(pages[i]) - 3, nchar(pages[i]))
  
  urls <- map(1:pages_by_year[i], function(x) { 
            paste0("http://www.songkick.com/search?page=", x, "&query=9%3A30+club+", year
            )})
  
  all_pages_urls <- c(all_pages_urls, urls)
  
}

# Remove the empty string at index 1
all_pages_urls <- all_pages_urls[2:length(all_pages_urls)]

# Loop through every page of every year
for (j in 130:length(all_pages_urls)) {

  # Store the current url from the list of pages by year above
  url_for_scraping <- all_pages_urls[[j]]

  headliner <- url_for_scraping %>%
    read_html() %>%
    html_nodes(".event .summary strong") %>%
    html_text() %>%
    paste0("")

  support_artists <- url_for_scraping %>%
   read_html() %>%
   html_nodes(".event .summary") %>%
   html_text() %>%
   paste0("")

  concert_date <- url_for_scraping %>%
   read_html() %>%
   html_nodes(".date strong") %>%
   html_text() %>%
   paste0("")
  
  # Store the data frame scraped from the current url
  individual_df = data.frame(headliner = headliner, 
                             support = support_artists, 
                             date = concert_date)
  
  # Print number to make sure the script is still working
  print(j)
  
  # Bind individual concert df to the main concerts data frame
  concerts <- bind_rows(concerts, individual_df)
  
}

# Remove OHIG, the headliner has 9:30 in the name
concerts <- concerts %>% filter(headliner != "OHIG")

# Write initial results to CSV
write.csv(concerts, "930.csv")



