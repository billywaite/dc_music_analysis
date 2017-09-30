
library(dplyr)

dirty_wiki_data <- read.csv("artist_background_info.csv", stringsAsFactors = FALSE)

test <- dirty_wiki_data$Genres[3075] # Genres separated by a \
test2 <- dirty_wiki_data$Genres[2] # Genres separated by ,
test3 <- dirty_wiki_data$Genres[18] # Genres separated by [1]

# Split Genres column into main genre and comma split genres
genre_split <- dirty_wiki_data %>%
  separate(Genres, c("main_genre", "split_genres"), 
           sep = ",") %>%
  separate(main_genre, c("main_genre", "split_genres2"),
           sep = "[1]")

genre_split$back_slash <- strsplit(genre_split$main_genre, "[\\\\]|[^[:print:]]",fixed=FALSE)

for (i in 1:nrow(genre_split)) {
  genre_split$main_genre[i] <- genre_split$back_slash[i][[1]][1]
  print(i)
}

# Remove brackets
genre_split$main_genre <- str_replace_all(genre_split$main_genre, "[2]", "")
genre_split$main_genre <- str_replace_all(genre_split$main_genre, "\\[", "")

# Clean leading/lagging whitespace
genre_split$main_genre <- trimws(genre_split$main_genre)


# Store main genre to join to main artist data set
clean_main_genre <- genre_split %>%
  dplyr::select(2:3) %>%
  tbl_df()

write.csv(clean_main_genre, "clean_wiki_genre.csv")