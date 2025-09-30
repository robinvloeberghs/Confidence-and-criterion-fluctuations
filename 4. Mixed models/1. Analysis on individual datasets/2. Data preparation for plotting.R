
###################################################################################
# Data preparation for plotting the estimates of the individual datasets together #
###################################################################################


library(car)
library(lme4)
library(dplyr)

# Change directory to location of current script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Specify all datasets
datasets <- c('Adler_2018_Expt3',
          'Adler_2018_Expt1_taskA',
          'Adler_2018_Expt1_taskB',
          'Denison_2018',
          'Recht_unpub',
          'VanBoxtel_2019_Expt1',
          'VanBoxtel_2019_Expt2',
          'Law_unpub',
          'Yeon_unpub_Exp2',
          'Siedlecka_2021',
          'Shekhar_2021',
          'CalderTravis_unpub',
          'Filevich_unpub',
          'Maniscalco_2017_expt2',
          'Wang_2018')

all_coefs <- data.frame()


for(dataset in datasets){
  print(dataset)
  load(paste(dataset, '.Rdata', sep = ''))

  estimates <- fixef(best_model)
  df_estimates <- data.frame(estimates)
  
  df_estimates$parameter <- rownames(df_estimates)
  df_estimates$dataset <- dataset
  #df_estimates$p_values <- c(NA,Anova(best_model)$'Pr(>Chisq)') # Anova does not give p-value for intercept so we add NA
  df_estimates$p_values <- Anova(best_model, type=3)$'Pr(>Chisq)'
  
  confidence_intervals <- data.frame(confint(best_model,method = 'Wald'))
  confidence_intervals <- confidence_intervals[!grepl("^\\.", rownames(confidence_intervals)), ] # Remove rows starting with a period (variance covariance parameters of random effects)
  confidence_intervals$parameter <- rownames(confidence_intervals)
  
  df_estimates <- merge(df_estimates, confidence_intervals, by = 'parameter')

  all_coefs <- rbind(all_coefs, df_estimates)

}

# Save in .csv file
write.csv(all_coefs, '_all_mixed_models_coefficients.csv')


