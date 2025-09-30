
# Code to merge the csv files with criterion fluctuations for each dataset into one large dataset

library(rstudioapi)

# Set directory to file location
setwd("./individual datasets")

# Open all the csv files and merge them using rbind
open_all_csv_files <- function(directory_path, column_vector) {
  
  # Get list of files in the directory
  files <- list.files(directory_path, full.names = TRUE)
  
  # Filter out only CSV files
  csv_files <- files[grep("\\.csv$", files, ignore.case = TRUE)]
  
  # Create an empty dataframe to store combined data
  combined_data <- data.frame()
  
  # Loop through each CSV file, read it, and assign it to a variable in the global environment
  for (file in csv_files) {
    # Extract the name of the file without extension
    file_name <- sub("\\.csv$", "", basename(file))
    cat("Opening:", file, "\n")
    
    # Read CSV file
    data <- read.csv(file)  # Or use read_csv() if you prefer
    
    data <- data[,column_vector]
    # Assign data to a variable in the global environment
    # assign(file_name, data, envir = .GlobalEnv)
    
    # Combine data with existing dataframe
    combined_data <- rbind(combined_data, data)
  }
  
  # Return the combined dataframe
  return(combined_data)
}


data <- open_all_csv_files(getwd(), 
                           column_vector = c('study','subj', 'resp', 'rt','conf','absevi','signevi','evidence','prevsignevi',
                                             'prevabsevi', 'prevresp', 'prevconf', 'prevsignabsevi', 'prevrespconf',
                                             'criterion_fluctuations'))


# Change subj value because otherwise R will think the same subj is taking part in different studies (multiple subj == 1)
data$subj <- paste0(data$subj, "_", data$study)

write.csv(data, "_all_data_with_criterion_fluctuations.csv", row.names = FALSE)

