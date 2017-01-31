### module 11 Exercise 1 ###

# Load the httr and jsonlite libraries for accessing data

install.packages("httr")
install.packages("jsonlite")
library(httr)
library(jsonlite)


## For these questions, look at the API documentation to identify the appropriate endpoint and information.
## Then send GET() request to fetch the data, then extract the answer to the question


# For what years does the API have statistical data?
response <- GET("http://data.unhcr.org/api/stats/time_series_years.json")

body <- content(response, "text")

years <- fromJSON(body)

years

# What is the "country code" for the "Syrian Arab Republic"?

response <- GET("http://data.unhcr.org/api/countries/list.json")

countries <- fromJSON(content(response, "text"))

countries %>% filter(name_en == "Syrian Arab Republic") %>% select(country_code)

# How many persons of concern from Syria applied for residence in the USA in 2013?
# Hint: you'll need to use a query parameter
# Use the `str()` function to print the data of interest
# See http://www.unhcr.org/en-us/who-we-help.html for details on these terms


query.params <- list(country_of_residence = "USA", country_of_origin = "SYR", year = 2013)

response <- GET("http://data.unhcr.org/api/stats/persons_of_concern.json?", query = query.params)

usa.persons <- fromJSON(content(response, "text"))

str(usa.persons)
## And this was only 2013...


# How many *refugees* from Syria settled the USA in all years in the data set (2000 through 2013)?
# Hint: check out the "time series" end points

query.params <- list(country_of_residence = "USA", country_of_origin = "SYR", population_type_code = "RF")

response <- GET("http://data.unhcr.org/api/stats/time_series_all_years.json?", query = query.params)

refugees <- fromJSON(content(response, "text"))

refugees <- refugees %>% select(year, usa = value)

View(refugees)


# Use the `plot()` function to plot the year vs. the value.
# Add `type="o"` as a parameter to draw a line

plot(refugees, type="o")

# Pick one other country in the world (e.g., Turkey).
# How many *refugees* from Syria settled in that country in all years in the data set (2000 through 2013)?
# Is it more or less than the USA? (Hint: join the tables and add a new column!)
# Hint: To compare the values, you'll need to convert the data (which is a string) to a number; try using `as.numeric()`

q.par <- list(country_of_residence = "TUR", country_of_origin = "SYR", population_type_code = "RF" )

response <- GET("http://data.unhcr.org/api/stats/time_series_all_years.json?", query = q.par)

refugees.tur <- fromJSON(content(response, "text"))

refugees.tur <- select(refugees.tur, year, tur = value)

View(refugees.tur)

us.vs.turk <- left_join(refugees, refugees.tur)


us.vs.turk <- us.vs.turk %>% mutate(difference = as.numeric(usa) > as.numeric(tur))
View(us.vs.turk)

## Bonus (not in solution):
# How many of the refugees in 2013 were children (between 0 and 4 years old)?

q.par <- list(year = 2013)

response <- GET("http://data.unhcr.org/api/stats/demographics.json?", query = q.par)

body <- fromJSON(content(response, "text"))

body <- select(body, year, female_0_4, male_0_4)

sum.children <- sum(as.numeric(body$female_0_4), na.rm = TRUE) + sum(as.numeric(body$male_0_4) , na.rm = TRUE)

sum.total <- sum(as.numeric(body$total_value), na.rm = TRUE)

paste0("Out of ", sum.total, " refugees, there were ", sum.children, " children 0-4 years old")

View(body)


## Extra practice (but less interesting results)
# How many total people applied for asylum in the USA in 2013?
# - You'll need to filter out NA values; try using `is.na()`
# - To calculate a sum, you'll need to convert the data (which is a string) to a number; try using `as.numeric()`

q.par <- list(year = 2013, country_of_asylum = "USA")

response <- GET("http://data.unhcr.org/api/stats/asylum_seekers.json", query = q.par)

body <- fromJSON(content(response, "text"))

body %>% select(applied_during_year) %>% filter(is.na(applied_during_year) == FALSE) %>% 
summarize(sum = sum(as.numeric(applied_during_year)))


## Also note that asylum seekers are not refugees
