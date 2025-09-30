
library(effects)
library(rstudioapi)
library(dplyr)
library(ggplot2)
library(Hmisc)
library(lme4)
library(car)
library(lmerTest)
library(gtools)
library(parallel)
library(tidyverse)


curdir <- dirname(getSourceEditorContext()$path)
setwd(curdir)

# Load in the functions
source("./4. Mixed models/1. Analysis on individual datasets/1.1 Random effects selection - functions.R")

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


# Load data ---------------------------------------------------------------
data <- read.csv("C:/Users/u0141056/OneDrive - KU Leuven/PhD/PROJECTS/Confidence and hMFC/Analysis/4. Mixed models/3. Implicit and physiological measures/Pupil size and RT/2ifc_data_allsj_with_criterion_fluctuations.csv")


# Change sign for correspondence with SDT criterion -----------------------
data$criterion_fluctuations <- -1 * data$criterion_fluctuations


# Create stimulus direction and stimulus strength -------------------------
data$stimulus_direction <- as.factor(sign(data$motionstrength))
data$stimulus_strength <- abs(data$motionstrength)


# Sanity checks -----------------------------------------------------------
# Response 
m_resp <- glmer(formula = 'resp ~ 
                         stimulus_direction * stimulus_strength + (1| subjnr)', data = data, 
                family = binomial,
                control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))
summary(m_resp)
Anova(m_resp, type=3)


# PREDICTING RT -----------------------------------------------------------

# WITH FLUCTUATIONS
# Basic formula to fit
basic_formula_rt = 'rtNorm ~ stimulus_direction * stimulus_strength * criterion_fluctuations + (1 | subjnr)'

# Random slopes to add to the basic formula
random_slopes_rt <- c(# only intercept
                      '',
                      # one main effect
                      '+ stimulus_strength',
                      '+ stimulus_direction',
                      '+ criterion_fluctuations',
                      # two main effects
                      '+ stimulus_strength + stimulus_direction',
                      '+ stimulus_strength + criterion_fluctuations',
                      '+ stimulus_direction + criterion_fluctuations',
                      # three main effects
                      '+ stimulus_strength + stimulus_direction + criterion_fluctuations',
                      # one interaction
                      '+ stimulus_strength * stimulus_direction',
                      '+ stimulus_strength * criterion_fluctuations',
                      '+ stimulus_direction * criterion_fluctuations',
                      # one interaction with one main effect (that is not in the interaction)
                      '+ stimulus_strength * stimulus_direction + criterion_fluctuations',
                      '+ stimulus_strength * criterion_fluctuations + stimulus_direction',
                      '+ stimulus_direction * criterion_fluctuations + stimulus_strength',
                      # two interactions
                      '+ stimulus_strength * stimulus_direction + stimulus_strength * criterion_fluctuations',
                      '+ stimulus_strength * stimulus_direction + stimulus_direction * criterion_fluctuations',
                      '+ stimulus_strength * criterion_fluctuations + stimulus_direction * criterion_fluctuations',
                      # three interactions
                      '+ stimulus_strength * stimulus_direction + stimulus_strength * criterion_fluctuations + stimulus_direction * criterion_fluctuations',
                      # three way interaction
                      '+ stimulus_strength * stimulus_direction * criterion_fluctuations')

# Fit all models in parallel
model_rt <- return_best_model(basic_formula_rt, random_slopes_rt, data)

vif(model_rt)
summary(model_rt)
anova(model_rt)

m_rt_vif <- lmer(formula = 'rtNorm ~ stimulus_direction * stimulus_strength +
                                      stimulus_direction * criterion_fluctuations +
                                      stimulus_strength * criterion_fluctuations + (1| subjnr)', data = data, 
                  control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

vif(m_rt_vif)
summary(m_rt_vif)
anova(m_rt_vif)

# WITHOUT FLUCTUATIONS
basic_formula_rt_no_fluctuations = 'rtNorm ~ stimulus_direction * stimulus_strength + (1 | subjnr)'

# Random slopes to add to the basic formula
random_slopes_rt_no_fluctuations <- c(# only intercept
                                      '', 
                                      # one main effect
                                      '+ stimulus_strength',
                                      '+ stimulus_direction',
                                      # two main effects
                                      '+ stimulus_strength + stimulus_direction',
                                      # interaction
                                      '+ stimulus_strength * stimulus_direction')

# Fit all models in parallel
model_rt_no_fluctuations <- return_best_model(basic_formula_rt_no_fluctuations, random_slopes_rt_no_fluctuations, data)

vif(model_rt_no_fluctuations)
summary(model_rt_no_fluctuations)
anova(model_rt_no_fluctuations)


# Compare model with and without criterion fluctuations -------------------
comparison_with_without <- anova(model_rt_no_fluctuations, model_rt) # model with criterion clearly wins



# Session permutation method; Harris (2021) -------------------------------
# Create another null model by switching criterion fluctuations across subjects
set.seed(1111)

# In order to shuffle all subjects within a dataset need the same length, so we truncate
data_truncated <- data.frame()
all_criterion_estimates_dataset_shuffled <- c()

min_trials <- min(table(data$subjnr)) # minimum number of trials over all subjects from data

position <- 1 # for position in list below
criterion_estimates_dataset <- list()
for (subjnr in unique(data$subjnr)){
  # save truncated data
  truncated_data <- data[data$subjnr==subjnr,][1:min_trials,]
  data_truncated <- rbind(data_truncated,truncated_data) 
  
  # add truncated criterion estimates to list
  criterion_estimates_dataset[position] <- list(truncated_data$criterion_fluctuations)
  
  position <- position + 1
}

# shuffle criterion trajectories over subjects (keeping per-subject trajectory the same!)
criterion_estimates_dataset_shuffled <- sample(criterion_estimates_dataset)
all_criterion_estimates_dataset_shuffled <- c(all_criterion_estimates_dataset_shuffled,criterion_estimates_dataset_shuffled)


shuffled_criterion_fluctuations <- unlist(all_criterion_estimates_dataset_shuffled,recursive=F)
data_truncated <- cbind(data_truncated,shuffled_criterion_fluctuations)


# WITH FLUCTUATIONS (shuffled)

basic_formula_rt_shuffled = 'rtNorm ~ stimulus_direction * stimulus_strength * shuffled_criterion_fluctuations + (1 | subjnr)'

# Random slopes to add to the basic formula
random_slopes_rt_shuffled <- c(# only intercept
                                '',
                              # one main effect
                              '+ stimulus_strength',
                              '+ stimulus_direction',
                              '+ shuffled_criterion_fluctuations',
                              # two main effects
                              '+ stimulus_strength + stimulus_direction',
                              '+ stimulus_strength + shuffled_criterion_fluctuations',
                              '+ stimulus_direction + shuffled_criterion_fluctuations',
                              # three main effects
                              '+ stimulus_strength + stimulus_direction + shuffled_criterion_fluctuations',
                              # one interaction
                              '+ stimulus_strength * stimulus_direction',
                              '+ stimulus_strength * shuffled_criterion_fluctuations',
                              '+ stimulus_direction * shuffled_criterion_fluctuations',
                              # one interaction with one main effect (that is not in the interaction)
                              '+ stimulus_strength * stimulus_direction + shuffled_criterion_fluctuations',
                              '+ stimulus_strength * shuffled_criterion_fluctuations + stimulus_direction',
                              '+ stimulus_direction * shuffled_criterion_fluctuations + stimulus_strength',
                              # two interactions
                              '+ stimulus_strength * stimulus_direction + stimulus_strength * shuffled_criterion_fluctuations',
                              '+ stimulus_strength * stimulus_direction + stimulus_direction * shuffled_criterion_fluctuations',
                              '+ stimulus_strength * shuffled_criterion_fluctuations + stimulus_direction * shuffled_criterion_fluctuations',
                              # three interactions
                              '+ stimulus_strength * stimulus_direction + stimulus_strength * shuffled_criterion_fluctuations + stimulus_direction * shuffled_criterion_fluctuations',
                              # three way interaction
                              '+ stimulus_strength * stimulus_direction * shuffled_criterion_fluctuations')

model_rt_shuffled <- return_best_model(basic_formula_rt_shuffled, random_slopes_rt_shuffled, data_truncated)

vif(model_rt_shuffled)
summary(model_rt_shuffled)
anova(model_rt_shuffled)


# WITH FLUCTUATIONS (original)
model_rt_original <- return_best_model(basic_formula_rt, random_slopes_rt, data_truncated)

vif(model_rt_original)
summary(model_rt_original)
anova(model_rt_original)



# Compare shuffled vs original
comparison_with_without_truncated <- anova(model_rt_shuffled,model_rt_original)


# Save workspace image
save.image(file = "mixed_models_RT.RData")






# Plotting ----------------------------------------------------------------

# Create bins for criterion fluctuations
data$binned_criterion <- cut2(data$criterion_fluctuations, g = 5, levels.mean = TRUE) # 5 bins
data$binned_criterion <- as.numeric(as.character(data$binned_criterion))
data$binned_criterion <- as.factor(round(data$binned_criterion, 1))

data$binned_stimulus_strength <- cut2(data$stimulus_strength, g=3, levels.mean = TRUE)
data$binned_stimulus_strength <- as.numeric(as.character(data$binned_stimulus_strength))

# Calculate mean rt for each subject
data_rt <- data %>%
  group_by(subjnr, binned_criterion, stimulus_direction, .groups = 'keep') %>% 
  dplyr::summarise(mean_rt1 = mean(rtNorm), sum_obs = n()) %>%
  ungroup()

# Calculate mean rt and standard error over all subjects
data_rt <- data_rt %>% 
  group_by(binned_criterion, stimulus_direction, .groups = 'keep') %>% 
  dplyr::summarise(mean_rt = mean(mean_rt1, na.rm=T), sum_obs = sum(sum_obs), se = sd(mean_rt1, na.rm=T)/sqrt(length(unique(data$subj)))) %>% # make standard error
  ungroup()


offset = 0.1


# plot mean rt
ggplot(mapping = aes(x = binned_criterion, y = mean_rt, group = stimulus_direction, color = stimulus_direction), data = data_rt) +
  geom_errorbar(aes(ymin = mean_rt - se, ymax = mean_rt + se), width = 0, position = position_dodge(width = offset), linewidth = 0.7) +
  geom_line(linewidth = 1.5, aes(group = stimulus_direction, color = stimulus_direction), position = position_dodge(width = offset)) +
  geom_point(size = 2.5, position = position_dodge(width = offset)) +
  scale_color_manual(values = c("#5084C4", "orange"), name = "Stimulus direction") +
  xlab('Criterion') +
  ylab('Normalized RT') +
  #ylim(0.2, 0.75) +
  theme_classic(base_size = 12) +
  theme(
    panel.background = element_rect(fill='transparent'),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    axis.text = element_text(size = 17), 
    axis.title = element_text(size = 20), 
    legend.title = element_text(size = 18),  
    legend.text = element_text(size = 15),
    strip.text.x = element_text(size = 18), 
    legend.position = "none"
  )

ggsave("rt_crit.png", bg='transparent', dpi=600)