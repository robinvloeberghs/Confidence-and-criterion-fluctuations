
#######################################################################
# Plotting mixed model results when fitted to each individual parameter #
#######################################################################

library(ggplot2)
library(gtools)
library(patchwork)
library(viridis)
library(tidyverse)


# Change directory to location of current script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# Contains the estimates, p values, and upper and lower value of 95% confidence intervals
all_coefs <- read.csv('_all_mixed_models_coefficients.csv')
all_coefs <- all_coefs[,-1] # remove first column


# Plot all predictors and 95% CI
ggplot(all_coefs, aes(x = parameter, y = estimates, col = dataset)) +
  geom_hline(yintercept = 0, color = '#CCCCCC', linewidth = 1) +
  geom_point(size = 3, position = position_jitter(width = 0.15), alpha = 0.4) +
  labs(title = "Estimates mixed models",
       x = "Predictor",
       y = "Value") +
  theme_classic() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.title = element_blank(),
    legend.text = element_text(size = 10)
  )


# Plot estimates and 95% CI
# with estimate added from mixed model over all datasets

# For two-way interaction
#all_coefs <- rbind(all_coefs, data.frame(parameter = 'signevi1:criterion_fluctuations', estimates = -4.295e-02, dataset = 'Total', p_values = 0.0001, X2.5.. = -0.045964131, X97.5.. = -3.994291e-02))

# For three-way interaction
all_coefs <- rbind(all_coefs, data.frame(parameter = 'signevi1:absevi:criterion_fluctuations', estimates = -3.207e-02, dataset = 'Total', p_values = 0.0001, X2.5.. = -0.037725615, X97.5.. = -2.640728e-02))


all_coefs$p_significance <- ifelse(all_coefs$p_value < 0.001, "***", ifelse(all_coefs$p_value < 0.01, "**", ifelse(all_coefs$p_value < 0.05, "*", "")))

# Sort alphabetically with Total as last
desired_order <- rev(c(sort(unique(all_coefs[all_coefs$dataset != 'Total',]$dataset), decreasing = FALSE),'Total'))

#subset_coefs <- all_coefs[all_coefs$parameter %in% c('signevi1:criterion_fluctuations'),]
subset_coefs <- all_coefs[all_coefs$parameter %in% c('signevi1:absevi:criterion_fluctuations'),]

subset_coefs$dataset <- factor(subset_coefs$dataset, levels = desired_order)

# Change names
levels(subset_coefs$dataset) <- rev(c(
  'Adler & Ma (2018, experiment 1A)',
  'Adler & Ma (2018, experiment 1B)',
  'Adler & Ma (2018, experiment 3)',
  'Calder-Travis et al. (unpublished)',
  'Denison et al. (2018)',
  'Filevich & Fandakova (unpublished)',
  'Law & Lee (unpublished)',
  'Maniscalco et al. (2017, experiment 2)',
  'Recht et al. (unpublished)',
  'Shekhar & Rahnev (2021, experiment 3)',
  'Siedlecka et al. (2021)',
  'Orchard & Van Boxtel (2019) Exp 1',
  'Orchard & Van Boxtel (2019) Exp 2',
  'Wang et al. (2018)',
  'Yeon et al. (unpublished, experiment 2)',
  'Total'
))


size_multiplier <- 1.5

ggplot(subset_coefs, aes(y = dataset, x = estimates, col = dataset)) +
  geom_vline(xintercept = 0, color = '#CCCCCC', linewidth = 1 * size_multiplier) +
  geom_point(size = 2.5 * size_multiplier) +  # Adjust width for wider spacing , color = "#21918C"
  geom_errorbarh(aes(xmin = X2.5.., xmax = X97.5..), height = 0.2, linewidth = 0.4 * size_multiplier) +
  labs(x = "Stimulus direction * Stimulus strength * Criterion",
       y = "Dataset") +
  scale_color_viridis_d(option="C", end=.8) +
  geom_text(aes(label = paste(p_significance)), vjust = -0.15, position = position_dodge(width = 0.2), size = 3.5 * size_multiplier) +
  theme_classic() +
  theme(
    axis.text = element_text(size = 13), 
    axis.title = element_text(size = 14), 
    legend.title = element_text(size = 18),  
    legend.text = element_text(size = 15),
    strip.text.x = element_text(size = 18), 
    legend.position = "none"
  )

ggsave("all_individual_datasets_estimates_threeway_interaction.png", dpi=600)



