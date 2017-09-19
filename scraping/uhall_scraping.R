

# Load libraries
library(rvest)
library(dplyr)

# Create empty data frame to store concert data
concerts <- data.frame(headliner = character(),
                       support = character(), 
                       date = as.character(),
                       time = as.character(),
                       ticket_price = as.character(),
                       stringsAsFactors=FALSE)

# Create vector to store all page urls from uhall website
pages <- c("http://www.ustreetmusichall.com/past-events/")

# Loop to create the rest of the page of concerts urls and store in the pages vector
for (i in 2:11) {
  pages <- c(pages, paste0("http://www.ustreetmusichall.com/past-events/page/", i))
}

# Loop to scrape the html from each of the uhall pages of concerts
scraped_pages <- lapply(pages, read_html)

# Create vector to store url of every concert
all_urls <- c("")

# Loop to scrape the urls for each concert in each page of concerts
for (j in 1:11) {
    urls_by_page <- scraped_pages[[j]] %>%
    html_nodes(".past-events .list-view-item .url") %>%
    html_attr('href')
    
    all_urls <- c(all_urls, urls_by_page)
}

# Temp
test <- all_urls[2:2164]

# Loop through every concert url to scrape data and store in a dataframe
for (k in 1:2163) {
  
  # Create full concert page url
  url <- paste0("http://www.ustreetmusichall.com", test[k])
  
  # Scrape the html from the individual arist event page
  page <- read_html(url)
  
  # Store headliner artist name
  headliner <- page %>%
    html_nodes(".headliners") %>%
    html_text() %>%
    paste0("")
  
  # Store support artists name(s)
  support <- page %>%
    html_nodes(".supports") %>%
    html_text() %>%
    paste0("")
  
  # Store date
  date <- page %>%
    html_nodes(".dates") %>%
    html_text() %>%
    paste0("")
  
  # Store time
  time <- page %>%
    html_nodes(".times") %>%
    html_text() %>%
    paste0("")
  
  # Store ticket price
  price <- page %>%
    html_nodes(".price-range") %>%
    html_text() %>%
    paste0("")
  
  # Create one row data frame out of scraped concert data
  individual_df <- data.frame(headliner = headliner,
                              support = support,
                              date = date,
                              time = time,
                              ticket_price = price)
  
  # Print number to make sure the script is still working
  print(k)
  
  # Bind individual concert df to the main concerts data frame
  concerts <- bind_rows(concerts, individual_df)
}

# Write initial results to CSV
write.csv(concerts, "uhall.csv")


