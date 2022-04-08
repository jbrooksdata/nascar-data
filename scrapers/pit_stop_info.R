library(jsonlite)
library(dplyr)

race_ids <- list("5146","5147","5148","5149","5150","5151","5152")

compile_stops <- data.frame()

for(i in race_ids){
  url_json <- paste0("https://cf.nascar.com/live/feeds/series_1/",i,"/live_feed.json")
  raw_json <- fromJSON(url_json)
  
  df <- raw_json$vehicles
  
  finish <- 1:nrow(raw_json$vehicles$driver)
  
  driver_stops <- data.frame()
  
  for(x in finish){
    
    # bind driver name to each of their pit stops
    indiv_stops <- bind_cols(df$driver$full_name[x],
                             raw_json$run_name,
                             df$pit_stops[x])
    
    # bind number of laps remaining in race - useful for visualization
    add_remlaps <- bind_cols(indiv_stops,(raw_json$laps_in_race - indiv_stops$pit_in_lap_count))
    
    driver_stops <- bind_rows(driver_stops,add_remlaps)
    
    
  }
  
  compile_stops <- bind_rows(compile_stops,driver_stops)
  
}

# rename "..." columns
names(compile_stops)[1] <- "driver"
names(compile_stops)[2] <- "race"
names(compile_stops)[10] <- "laps_remaining"

# gsub to remove special characters from driver names
compile_stops$driver <- gsub("\\s*\\([^\\)]+\\)","",
                             gsub(" #","",
                                  gsub("\\* ","",compile_stops$driver)))

# only show "active" stops - not driver's end of race
delete_zero <- compile_stops[!(compile_stops$pit_stop_duration == 0),]

# drop "position change" - it is all zero
delete_zero <- subset(delete_zero, select = -c(3))