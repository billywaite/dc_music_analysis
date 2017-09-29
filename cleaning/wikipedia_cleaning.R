

dirty_data <- read.csv("artist_background_info.csv")

players %>% 
  # Find all players who do not appear in Salaries
  anti_join(Salaries) %>%
  # Count them
  count()