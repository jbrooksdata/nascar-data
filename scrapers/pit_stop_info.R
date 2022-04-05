# feb 20 daytona 500 - id: 5146
## some laps are missing from source
library(jsonlite)
library(dplyr)

url_json <- "https://cf.nascar.com/live/feeds/series_1/5146/live_feed.json"
raw_json <- fromJSON(url_json)

df <- raw_json$vehicles

finish <- 1:nrow(raw_json$vehicles$driver)

driver_stops <- data.frame()

for(x in finish){
  
  indiv_stops <- bind_cols(df$driver$full_name[x],df$pit_stops[x])
  
  driver_stops <- bind_rows(driver_stops,indiv_stops)
  
  
}

names(driver_stops)[1] <- "driver"

driver_stops$driver <- gsub("\\s*\\([^\\)]+\\)","",
                       gsub(" #","",
                       gsub("\\* ","",driver_stops$driver)))

# only show "active" stops - not driver's end of race
delete_zero <- driver_stops[!(driver_stops$pit_stop_duration == 0),]

# drop "position change" - it is all zero
delete_zero <- subset(delete_zero, select = -c(2))