
# Load libraries
library(rvest)
library(dplyr)
library(stringr)
library(purrr)

# Function to generate the url of every page of historical concerts by venue
generate_songkick_urls <- function(venue, year_founded, current_year = 2017) {
  
  # Generate url for the 1st page of results from songkick for each year
  urls_by_year <- map(year_founded:current_year, function(x) {
    paste0("http://www.songkick.com/search?page=1&query=", venue, "+", x)
  })
  
  # Scrape the pagination on the 1st page of results to determine the # of pages by year
  pagination <- urls_by_year %>%
    map(read_html) %>%
    map(html_nodes, ".pagination") %>%
    map(html_text)
  
  # Get index of the word "Next" which falls at the end of the pagination string
  next_index <- regexpr("Next", pagination)
  
  # Subset pagination strings using the index from above, convert to numeric
  pages_by_year <- as.numeric(substr(pagination, next_index-3, next_index-2))
  
  # Create the urls for each page of results by year
  all_pages_urls <- c("")
  
  for (i in 1:length(urls_by_year)) {
    
    # Store the year
    year <- substr(urls_by_year[i], nchar(urls_by_year[i]) - 3, nchar(urls_by_year[i]))
    
    urls <- map(1:pages_by_year[i], function(x) { 
      paste0("http://www.songkick.com/search?page=", x, "&query=", venue, "+", year
      )})
    
    all_pages_urls <- c(all_pages_urls, urls)
    
  }
  
  # Remove the empty string at index 1
  all_pages_urls <- all_pages_urls[2:length(all_pages_urls)]
}

###############################################################################################
# Call the function and store the list of urls by year - Replace the venue search term and year
x <- generate_songkick_urls("Birchmere+Alexandria", 1998)
###############################################################################################

  # Create empty data frame to store concert data
  concerts <- data.frame(headliner = character(),
                         support = character(), 
                         date = as.character(),
                         stringsAsFactors=FALSE)
  
  # Loop through every page of every year
  for (j in 1:length(x)) {
    
    # Store the current url from the list of pages by year above
    url_for_scraping <- x[[j]]
    
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

# Write initial results to CSV
write.csv(concerts, "birchmere.csv")

