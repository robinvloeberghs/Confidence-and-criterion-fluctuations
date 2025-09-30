
###############################
# Fitting individual datasets #
###############################


library(lme4)
library(gtools)
library(parallel)


# Change directory to location of current script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
path_with_criterion <- "./3. hMFC/3.2 Data with criterion fluctuations"


# Load in the functions
source("1.1 Random effects selection - functions.R")


# Get data (.csv with criterion fluctuations)
all_files <- list.files(path = path_with_criterion,pattern = "\\.csv$", full.names = FALSE)
datasets <- tools::file_path_sans_ext(basename(all_files))
#datasets <- datasets[1] # to test with less datasets


# Basic formula to fit
basic_formula = 'conf ~ signevi * absevi * criterion_fluctuations + (1 | subj)'


# Random slopes to add to the basic formula
random_slopes <- c(# only intercept
                   '', 
                   # one main effect
                   '+ absevi', 
                   '+ signevi',
                   '+ criterion_fluctuations',
                   # two main effects
                   '+ absevi + signevi',
                   '+ absevi + criterion_fluctuations',
                   '+ signevi + criterion_fluctuations',
                   # three main effects
                   '+ absevi + signevi + criterion_fluctuations',
                   # one interaction
                   '+ absevi * signevi',
                   '+ absevi * criterion_fluctuations',
                   '+ signevi * criterion_fluctuations',
                   # one interaction with one main effect (that is not in the interaction)
                   '+ absevi * signevi + criterion_fluctuations',
                   '+ absevi * criterion_fluctuations + signevi',
                   '+ signevi * criterion_fluctuations + absevi',
                   # two interactions
                   '+ absevi * signevi + absevi * criterion_fluctuations',
                   '+ absevi * signevi + signevi * criterion_fluctuations',
                   '+ absevi * criterion_fluctuations + signevi * criterion_fluctuations',
                   # three interactions
                   '+ absevi * signevi + absevi * criterion_fluctuations + signevi * criterion_fluctuations',
                   # three way interaction
                   '+ absevi * signevi * criterion_fluctuations')


# Compute mixed models for all datasets -----------------------------------

for (dataset in datasets){

  data <- read.csv(paste(path_with_criterion,'/', 
                                dataset, '.csv', sep = ''))

  # Change sign evidence (-1,+1) into factor
  # Sign evidence results in rank deficient model for Wang, due to three levels (one is almost zero)
  # So let's remove the ambiguous stimulus trials (signevi = 0.001)
  if (dataset == "Wang_2018_with_criterion_fluctuations"){
    data <- data[data$signevi != 0.001,]
  }
  
  data$signevi <- as.factor(data$signevi)
  
  # Change sign for correspondence with SDT criterion(positive indicates right-shifted criterion)
  data$criterion_fluctuations <- -1 * data$criterion_fluctuations 
  
  
  # Setting up parallel computing to run all random effect options -------------------------------------------
  # Create cluster object
  num_cores <- detectCores()
  cl <- makeCluster(num_cores)
  
  # Load required libraries on each worker node (suppress output messages)
  invisible(clusterEvalQ(cl, library(lme4)))
  
  # Export necessary variables and functions to the cluster workers
  clusterExport(cl, varlist = c("build_formula", "basic_formula", "fit_model_and_return_AIC_BIC", "data"))
  
  # Fitting all models in parallel
  results <- parSapply(cl, random_slopes, return_aic_bic)
  
  # Close the nodes
  stopCluster(cl)
  
  
  # Find model with best AIC
  # NA means the model did not converge or had a singular fit
  df_results <- as.data.frame(t(results))
  
  min_aic_value <- min(unlist(df_results$aic), na.rm = TRUE)

  # Gives us the random effect structure with lowest AIC
  min_aic_model <- rownames(df_results)[which.min(df_results$aic)]

  
  # Refit model with lowest AIC to save model object ---------------------------------------------
  
  formula = build_formula(basic_formula, min_aic_model)
  print(paste("Re-fitting best model for: ", dataset))
  flush.console() # Ensure the output is printed during for loop
  print(paste("with following RE: ", min_aic_model))
  flush.console()
  
  # With return_model_only=TRUE function will return the model object instead of AIC
  best_model <- fit_model_and_return_AIC_BIC(formula, data = data, glmer=FALSE, return_model_only=TRUE ) # glmer=True for logistic regression
  
  # Save best_model in Rdata file
  file_name <- paste(dataset,'.Rdata', sep = '')
  file_name <- gsub("_with_criterion_fluctuations", "", file_name) # remove the _with_criterion_fluctuations
  
  save(best_model, file = file_name)
}

