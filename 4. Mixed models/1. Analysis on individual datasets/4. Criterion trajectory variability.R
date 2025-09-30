
#######################################################
# Investigating variability of criterion trajectories #
#######################################################

library(lme4)

# Change directory to location of current script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
path_with_criterion <- "./3. hMFC/3.2 Data with criterion fluctuations/individual datasets"

# Get data (.csv with criterion fluctuations)
all_files <- list.files(path = path_with_criterion,pattern = "\\.csv$", full.names = FALSE)
datasets <- tools::file_path_sans_ext(basename(all_files))


sd_criterion <- c()
subj <- c()
study <- c()

for (dataset in datasets){
  
  data <- read.csv(paste(path_with_criterion,'/', dataset, '.csv', sep = ''))
  sd <- aggregate(data$criterion_fluctuations, by=list(data$subj), FUN=sd)
  sd_criterion <- c(sd_criterion, sd$x)
  subj <- c(subj,unique(data$subj))
  study <- c(study, rep(dataset, length(unique(data$subj))))
}

df_sd <- data.frame(study, subj, sd_criterion)


model <- lm(data=df_sd,
              'sd_criterion ~ 1 + study')
summary(model)
