# Coded by George.RA.Hancock 08/01/2026


#....................................................................................................................................
#----Setup----
#....................................................................................................................................
#....................................................................................................................................



#Load R packages.
#...................................
#Make sure these are all installed.


library(dplyr)
library(slider)

#Set working directory to source
#...................................
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


# Root directory
root_dir <- "stimuli_new"

# Find all flight_data.csv files
csv_files <- list.files(
  path = root_dir,
  pattern = "flight_data\\.csv$",
  recursive = TRUE,
  full.names = TRUE
)

# Read and combine all files
all_flights <- do.call(
  rbind,
  lapply(csv_files, function(file) {
    
    # Split path into components
    path_parts <- strsplit(file, .Platform$file.sep)[[1]]
    
    # Extract folder names
    butterfly <- path_parts[length(path_parts) - 2]
    path_id   <- path_parts[length(path_parts) - 1]
    
    # Read CSV and add identifiers
    df <- read.csv(file, stringsAsFactors = FALSE)
    df$butterfly <- butterfly
    df$PathID <- path_id
    
    df
  })
)

# Result
all_flights
all_flights$pathNumber <- as.integer(all_flights$PathID)
all_flights$frame = floor(all_flights$frame/4)+1




library(dplyr)
library(slider)

fps <- 240
window_ms <- 300
window_frames <- ceiling(fps * window_ms / 1000)  # 72 frames

all_flights_2 <- all_flights %>%
  arrange(butterfly, pathNumber, frame) %>%
  group_by(butterfly, pathNumber) %>%
  mutate(
    # Global mean heading per path
    mean_heading_path = mean(heading_deg, na.rm = TRUE),
    
    # Difference from global mean
    heading_diff_from_mean = heading_deg - mean_heading_path,
    
    # Rolling mean and SD of previous 300ms (72 frames)
    rolling_mean_300ms = slide_dbl(
      heading_deg,
      .before = window_frames,
      .after = -1,
      .f = function(x) if(length(x) == 0) 0 else mean(x, na.rm = TRUE)
    ),
    rolling_sd_300ms = slide_dbl(
      heading_deg,
      .before = window_frames,
      .after = -1,
      .f = function(x) if(length(x) == 0) 0 else sd(x, na.rm = TRUE)
    ),
    
    # Difference from value 300ms ago (or 0 if not enough history)
    heading_diff_300ms = heading_deg - lag(heading_deg, n = window_frames, default = 0),
    x_diff_300ms = x - lag(x, n = window_frames, default = 0),
    y_diff_300ms = y - lag(y, n = window_frames, default = 0)
  ) %>%
  ungroup()

head(all_flights_2)



write.csv(all_flights_2, "flightPaths.csv", row.names = FALSE)