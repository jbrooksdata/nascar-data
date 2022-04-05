library(jsonlite)
library(dplyr)

race_id <- "5146" # can enter list of race ids here

compile_stats <- data.frame()

for(i in race_id){
  
  laps_json <- paste0("https://cf.nascar.com/cacher/2022/1/",i,"/lap-times.json")
  raw_laps <- fromJSON(laps_json)
  
  misc_json <- paste0("https://cf.nascar.com/live/feeds/series_1/",i,"/live_feed.json")
  raw_misc <- fromJSON(misc_json)
  
  race_name <- raw_misc$run_name
  race_id <- raw_misc$race_id
  
  drivers <- raw_laps$laps
  laps <- drivers$Laps
  
  # max num of drivers per race
  finish <- 1:nrow(drivers)
  
  # remove special characters via nested gsub
  driverlist <- gsub("\\s*\\([^\\)]+\\)","",
                     gsub(" #","",
                          gsub("\\* ","",drivers$FullName)))
  
  # lap times dataframe loop
  timeslist <- data.frame()
  
  for(x in finish){
    
    times <- (as.data.frame(drivers$Laps[x]))[2]
    conv2cols <- as.data.frame(t(times))
    
    # bind_rows instead of rbind to ignore column lengths
    add_race_info <- bind_cols(race_name,race_id,conv2cols)
    timeslist <- bind_rows(timeslist,add_race_info)
  }
  
  lapchart <- bind_cols(driverlist,timeslist)
  rownames(lapchart) <- c(1:nrow(drivers))
  names(lapchart)[1] <- "driver"
  names(lapchart)[2] <- "race"
  names(lapchart)[3] <- "race_id"
  
  compile_stats <- bind_rows(compile_stats,lapchart)
  
  
}