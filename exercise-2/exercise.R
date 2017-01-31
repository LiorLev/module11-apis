### module 11 Exercise 2 ###

# Load the httr and jsonlite libraries for accessing data


# Create a `base.uri` variable that holds the base uri. You wil then paste endpoints to this base.

base.uri <- "https://api.spotify.com"

## As you may have noticed, it often takes multiple queries to retrieve the desired information.
## This is a perfect situation in which writing a function will allow you to better structure your
## code, and give a name to a repeated task!


# Define a function `TopTrackSearch` that takes in an artist name as an argument,
# and returns the top 10 tracks (in the US) by that artist

TopTrackSearch <- function(artist){
  
  resource <- "/v1/search"
  uri = paste0(base.uri, resource)
  query.params <- list(q = artist, type = "artist")
  
  response <- GET(uri, query = query.params)
  
  
  artist.info <- fromJSON(content(response, "text"))
  artist.id <- artist.info$artists$items$id[1]

  # Get albums
  resource <- paste0("/v1/artists/",artist.id,"/top-tracks")
  uri = paste0(base.uri, resource)
  query.params <- list(country="US")
  response <- GET(uri, query = query.params)
  
  top.tracks <- fromJSON(content(response, "text"))
  
 
  return(top.tracks$tracks)
  
}


# What are the top 10 tracks by Beyonce?

top.tracks <- TopTrackSearch('Beyonce')

# Use the `flatten` function to flatten the data.frame -- note what differs!

top <- flatten(top.tracks)
View(top)

# Use the `save()` function to save the flattened data frame to a file `beyonce.Rdata`

save(top, file = "beyonce.Rdata")

# Use your `dplyr` functions to get the number of the songs that appear on each album

num.album <- top %>% group_by(album.name) %>% summarize(n = n()) %>% arrange(-n)
num.album

### Bonus ###
# Write a function that allows you to specify a search type (artist, album, etc.), and a string,
# that returns the album/artist/etc. page of interest

SpotifySearch <- function(type, string) {
  
  resource <- "/v1/search"
  uri <- paste0(base.uri, resource)
  query.params <- list(q = string, type = type)
  
  response <- GET(uri, query = query.params)
  
  return(flatten(fromJSON(content(response,"text"))))
}

# Search albums with the word "Sermon"
SpotifySearch('album', 'Sermon')
