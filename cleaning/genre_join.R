
# Load data to combine into one set of artists
wiki_genres <- read.csv("clean_wiki_genre.csv", stringsAsFactors = FALSE)
mg_api_genres <- read.csv("music_graph_api_data3.csv", stringsAsFactors = FALSE)

wiki_genres <- wiki_genres %>% dplyr::select(artist, main_genre)

mg_api_genres <- mg_api_genres %>%
  dplyr::select(headliner, genre) %>%
  rename(artist = headliner,
         main_genre = genre)

combined_genres <- bind_rows(wiki_genres, mg_api_genres)

combined_genres <- tbl_df(combined_genres)

clean_combined_genres <- combined_genres %>%
  filter(!is.na(main_genre))

# Load concert data
concerts <- read.csv("clean_headliners.csv", stringsAsFactors = FALSE)

# Join genre, filter out headliners without genre for visualizations
concerts <- concerts %>%
  tbl_df() %>%
  dplyr::select(venue, headliner, weekday, date) %>%
  left_join(clean_combined_genres, by = c("headliner" = "artist")) %>%
  filter(!is.na(main_genre))

concerts$main_genre <- as.factor(concerts$main_genre)

concerts$main_genre <- tolower(concerts$main_genre)

# Write to CSV to find and replace genres
write.csv(concerts, "main_genre_cleaning.csv")

### Genre Groupings ###
# blues
# classical/opera
# country (bluegrass)
# electronic (house, electronica)
# folk (americana, folk rock, indie folk)
# jazz
# reggae
# rock (indie rock, alternative rock, punk rock)
# alternative/indie
# Hip Hop
# pop (indie pop)
# rorld (latin)
# soul/r&b
# comedy/spoken word

# Read the csv back in
main_genre <- read.csv("main_genre_cleaning.csv", stringsAsFactors = FALSE)
main_genre <- tbl_df(main_genre)

# Using the same column from concerts, Create a new column for sub-genre
# If main-genre is equal to one of the main genre groupings you decided upon, then null, otherwhise it's a sub-genre
# Will also have to export to clean up some of the messier genres that didn't get cleaned before
# Load back in when clean

# Load the data that you exported for main genre, and join the main genre column back in so you have both main and sub genre

concerts_summary <- main_genre %>%
  group_by(main_genre) %>%
  summarize(sum = n())

write.csv(concerts_summary, "genre_visualization_summary.csv")
