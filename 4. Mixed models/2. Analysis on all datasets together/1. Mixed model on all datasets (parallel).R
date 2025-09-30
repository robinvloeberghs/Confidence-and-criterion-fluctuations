
library(lme4)
library(car)
library(optimx)
library(rstudioapi)
library(lmerTest)
library(gtools)
library(parallel)
library(Hmisc)
library(tidyverse)


curdir <- dirname(getSourceEditorContext()$path)
setwd(curdir)


# Load in the functions and data
source("./4. Mixed models/1. Analysis on individual datasets/1.1 Random effects selection - functions.R")

data <- read.csv("./3. hMFC/3.2 Data with criterion fluctuations/_all_data_with_criterion_fluctuations.csv")

load("mixed_model_over_all_datasets.RData")


# load("model_no_fluctuations.RData")
# load("model_with_fluctuations.RData")
# load("model_with_original_fluctuations_truncated.RData")
# load("model_with_shuffled_fluctuations_truncated.Rdata")


# Data preparation --------------------------------------------------------

# Change sign for correspondence with SDT criterion(positive indicates right-shifted criterion)
data$criterion_fluctuations <- -1 * data$criterion_fluctuations 

# Change sign evidence (-1,+1) into factor
# Sign evidence results in rank deficient model for Wang, due to three levels (one is almost zero)
# So let's remove the ambiguous stimulus trials (signevi = 0.001)
data <- data[data$signevi != 0.001,]
data$signevi <- as.factor(data$signevi)



# Function for fitting mixed models in parallel ---------------------------
# All possible random effect structures are fitted in parallel
# Function below return the model with the lowest AIC

return_best_model <- function(basic_formula, random_slopes, data){
  
  # Create cluster object
  num_cores <- detectCores()
  cl <- makeCluster(num_cores)
  
  # Load required libraries on each worker node (suppress output messages)
  invisible(clusterEvalQ(cl, library(lme4)))
  
  # Export necessary variables and functions to the cluster workers
  clusterExport(cl, varlist = c("build_formula", "basic_formula", "fit_model_and_return_AIC_BIC", "data"),envir = environment())
  
  # Fitting all models in parallel
  results <- parSapply(cl, random_slopes, return_aic_bic)
  
  # Close the nodes
  stopCluster(cl)
  
  # Find model with best AIC (NA means the model did not converge or had a singular fit)
  df_results <- as.data.frame(t(results))
  min_aic_value <- min(unlist(df_results$aic), na.rm = TRUE)
  
  # Gives us the random effect structure with lowest AIC
  min_aic_model <- rownames(df_results)[which.min(df_results$aic)]
  formula = build_formula(basic_formula, min_aic_model)
  
  # Return model 
  best_model <- fit_model_and_return_AIC_BIC(formula, data=data, glmer=FALSE, return_model_only=TRUE)
  
  return (best_model)
}



# COMPARISON MODEL WITH AND WITHOUT CRITERION FLUCTUATIONS ----------------

# Model without criterion fluctuations -------------------------------------------------

# Basic formula to fit
basic_formula_no_fluctuations = 'conf ~ signevi * absevi + (1 | study/subj)'

# Random slopes to add to the basic formula
random_slopes_no_fluctuations <- c( '', 
                                    '+ signevi',
                                    '+ absevi',
                                    '+ signevi + absevi',
                                    '+ signevi * absevi')

# Fit all models in parallel
model_no_fluctuations <- return_best_model(basic_formula_no_fluctuations, random_slopes_no_fluctuations, data)

vif(model_no_fluctuations)
summary(model_no_fluctuations)
anova(model_no_fluctuations)



# Model with criterion fluctuations ---------------------------------------

# Basic formula to fit
basic_formula_with_fluctuations = 'conf ~ signevi * absevi * criterion_fluctuations + (1 | study/subj)'

# Random slopes to add to the basic formula
random_slopes_with_fluctuations <- c(# only intercept
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

# Fit all models in parallel
model_with_fluctuations <- return_best_model(basic_formula_with_fluctuations, random_slopes_with_fluctuations, data)

vif(model_with_fluctuations)
summary(model_with_fluctuations)
anova(model_with_fluctuations)
confint(model_with_fluctuations,method = 'Wald')



# Compare model with and without criterion fluctuations -------------------
comparison <- anova(model_no_fluctuations, model_with_fluctuations)
comparison


# COMPARISON MODEL WITH ORIGINAL AND SHUFFLED CRITERION FLUCTUATIONS ------

# Session permutation method; Harris (2021) -------------------------------
# Create another null model by switching criterion fluctuations across subjects
set.seed(0)

# In order to shuffle all subjects within a dataset need the same length, so we truncate
data_truncated <- data.frame()
all_criterion_estimates_dataset_shuffled <- c()

for (study in unique(data$study)){
  print(study)
  subset <- data[data$study==study,]
  min_trials <- min(table(subset$subj)) # minimum number of trials over all subjects from subset
  
  position <- 1 # for position in list below
  criterion_estimates_dataset <- list()
  for (subj in unique(subset$subj)){
      # save truncated subset
      truncated_subset <- subset[subset$subj==subj,][1:min_trials,]
      data_truncated <- rbind(data_truncated,truncated_subset) 
      
      # add truncated criterion estimates to list
      criterion_estimates_dataset[position] <- list(truncated_subset$criterion_fluctuations)

      position <- position + 1
  }
  # shuffle criterion trajectories over subjects (keeping per-subject trajectory the same!)
  criterion_estimates_dataset_shuffled <- sample(criterion_estimates_dataset)
  all_criterion_estimates_dataset_shuffled <- c(all_criterion_estimates_dataset_shuffled,criterion_estimates_dataset_shuffled)
}

shuffled_criterion_fluctuations <- unlist(all_criterion_estimates_dataset_shuffled,recursive=F)
data_truncated <- cbind(data_truncated,shuffled_criterion_fluctuations)



# Model with shuffled criterion fluctuations (on truncated dataset) -------

# Basic formula to fit
basic_formula_with_shuffled_fluctuations = 'conf ~ signevi * absevi * shuffled_criterion_fluctuations + (1 | study/subj)'

# Random slopes to add to the basic formula
random_slopes_with_shuffled_fluctuations <- c(# only intercept
                    '', 
                    # one main effect
                    '+ absevi', 
                    '+ signevi',
                    '+ shuffled_criterion_fluctuations',
                    # two main effects
                    '+ absevi + signevi',
                    '+ absevi + shuffled_criterion_fluctuations',
                    '+ signevi + shuffled_criterion_fluctuations',
                    # three main effects
                    '+ absevi + signevi + shuffled_criterion_fluctuations',
                    # one interaction
                    '+ absevi * signevi',
                    '+ absevi * shuffled_criterion_fluctuations',
                    '+ signevi * shuffled_criterion_fluctuations',
                    # one interaction with one main effect (that is not in the interaction)
                    '+ absevi * signevi + shuffled_criterion_fluctuations',
                    '+ absevi * shuffled_criterion_fluctuations + signevi',
                    '+ signevi * shuffled_criterion_fluctuations + absevi',
                    # two interactions
                    '+ absevi * signevi + absevi * shuffled_criterion_fluctuations',
                    '+ absevi * signevi + signevi * shuffled_criterion_fluctuations',
                    '+ absevi * shuffled_criterion_fluctuations + signevi * shuffled_criterion_fluctuations',
                    # three interactions
                    '+ absevi * signevi + absevi * shuffled_criterion_fluctuations + signevi * shuffled_criterion_fluctuations',
                    # three way interaction
                    '+ absevi * signevi * shuffled_criterion_fluctuations')

# Fit all models in parallel (ON TRUNCATED DATASET)
model_with_shuffled_fluctuations_truncated <- return_best_model(basic_formula_with_shuffled_fluctuations, random_slopes_with_shuffled_fluctuations, data_truncated)

vif(model_with_shuffled_fluctuations_truncated)
summary(model_with_shuffled_fluctuations_truncated)
anova(model_with_shuffled_fluctuations_truncated)


# Model with ORIGINAL criterion fluctuations (on truncated dataset) -------
# Model with original and shuffled fluctuations have to be estimated on the same 
# truncated dataset in order to compare them

# Fit all models in parallel (ON TRUNCATED DATASET)
model_with_original_fluctuations_truncated <- return_best_model(basic_formula_with_fluctuations, random_slopes_with_fluctuations, data_truncated)

vif(model_with_original_fluctuations_truncated)
summary(model_with_original_fluctuations_truncated)
anova(model_with_original_fluctuations_truncated)



# Compare model shuffled and original criterion fluctuations -------------------
comparison_shuffled <- anova(model_with_shuffled_fluctuations_truncated, model_with_original_fluctuations_truncated)
comparison_shuffled

# Save work space image
save.image(file = "mixed_model_over_all_datasets.RData")






# Create bins for criterion fluctuations FOR TRUNCATED 

data_truncated$binned_criterion <- cut2(data_truncated$shuffled_criterion_fluctuations, g = 5, levels.mean = TRUE) # 5 bins
data_truncated$binned_criterion <- as.numeric(as.character(data_truncated$binned_criterion))
data_truncated$binned_absevi <- cut2(data_truncated$absevi, g=3, levels.mean = TRUE)
data_truncated$binned_absevi <- as.numeric(as.character(data_truncated$binned_absevi))

data_truncated <- data_truncated[data_truncated$signevi != 0.001,]
data_truncated$binned_criterion <- as.factor(round(data_truncated$binned_criterion, 2))
data_truncated[data_truncated$signevi == -1, 'binned_absevi'] <- data_truncated[data_truncated$signevi == -1, 'binned_absevi']*-1


# Calculate mean confidence for each subject
data_conf <- data_truncated %>%
  group_by(subj, binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_conf1 = mean(conf), sum_obs = n()) %>%
  ungroup()

# Calculate mean confidence and standard error over all subjects
data_conf <- data_conf %>% 
  group_by(binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_conf = mean(mean_conf1), sum_obs = sum(sum_obs), se = sd(mean_conf1)/sqrt(length(unique(data$subj)))) %>% # make standard error
  ungroup()



facet_labs <- c("Left", "Right")
names(facet_labs) <- c('-1','1')

offset = 0.01

# to change the size (used in some presentations)
size_for_poster <- 1


# plot mean confidence
ggplot(mapping = aes(x = binned_absevi, y = mean_conf, group = binned_criterion, color = binned_criterion), data = data_conf) +
  geom_errorbar(aes(ymin = mean_conf - se, ymax = mean_conf + se), width = 0, position = position_dodge(width = offset), linewidth = 0.7 * size_for_poster) +
  geom_line(linewidth = 1.5 * size_for_poster, aes(group = binned_criterion, color = binned_criterion), position = position_dodge(width = offset)) +
  geom_point(size = 2.5 * size_for_poster, position = position_dodge(width = offset)) +
  #facet_wrap(~signevi, labeller = labeller(signevi = facet_labs), scales = "free_x")+
  scale_colour_viridis_d(direction = 1, name = 'Criterion state') +
  xlab('Evidence strength') +
  ylab('Confidence') +
  #ylim(0.2, 0.75) +
  theme_classic(base_size = 12 * size_for_poster) +
  theme(
    axis.text = element_text(size = 15 * size_for_poster), 
    axis.title = element_text(size = 18 * size_for_poster), 
    legend.title = element_text(size = 18 * size_for_poster),  
    legend.text = element_text(size = 15 * size_for_poster),
    strip.text.x = element_text(size = 18 * size_for_poster), 
    plot.title = element_text(size = 24 * size_for_poster, face = 'bold', hjust = 0)
  )

