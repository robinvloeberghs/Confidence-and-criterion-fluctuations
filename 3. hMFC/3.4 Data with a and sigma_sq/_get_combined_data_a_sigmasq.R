
# Set directory to file location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

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


# Now we do the same for the data with a and sigmasq
data <- open_all_csv_files(getwd(), column_vector = c('study','subj','mean_conf','sd_conf', 'sd_criterion_fluctuations', 'a', 'sigmasq', 'mu_x'))

data$subj <- paste0(data$subj, "_", data$study)

write.csv(data, "_all_data_with_a_sigmasq.csv", row.names = FALSE)
