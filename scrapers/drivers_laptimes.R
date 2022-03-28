library(jsonlite)
library(webshot)
library(data.table)
library(dplyr)
library(tidyr)

# feb 20 daytona 500 - id: 5146
## some laps are missing from source
url_json <- "https://cf.nascar.com/cacher/2022/1/5146/lap-times.json"
raw_json <- fromJSON(url_json)

drivers <- raw_json$laps
laps <- drivers$Laps

# max num of drivers per race
## this will need to be edited for races with < 40
finish <- 1:nrow(drivers)

# create driver list; remove special characters (rookie designation, etc.)
driverlist <- gsub("\\s*\\([^\\)]+\\)","",
              gsub(" #","",
              gsub("\\* ","",drivers$FullName)))

# lap times dataframe loop
timeslist <- data.frame()

for(x in finish){
  
  times <- (as.data.frame(drivers$Laps[x]))[2]
  conv2cols <- as.data.frame(t(times)) # transpose to match driverlist
  
  # bind_rows instead of rbind to ignore column lengths (DNF, laps down, etc.)
  timeslist <- bind_rows(timeslist,conv2cols)
}


lapchart <- bind_cols(driverlist,timeslist)
# rename rows 1:n=drivers in race
rownames(lapchart) <- c(1:nrow(drivers))
# first column will otherwise be a driver's name
names(lapchart)[1] <- "driver"
