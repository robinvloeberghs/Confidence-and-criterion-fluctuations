library(effects)
library(rstudioapi)
library(dplyr)
library(ggplot2)
library(Hmisc)


curdir <- dirname(getSourceEditorContext()$path)
setwd(curdir)


# Load data and best model from selection procedure
load("Shekhar_2021.RData")
data <- read.csv("./3. hMFC/3.2 Data with criterion fluctuations/Shekhar_2021_with_criterion_fluctuations.csv")

# Change sign to make consistent with SDT interpretation (positive value = right-shifted criterion)
data$criterion_fluctuations <- -1 * data$criterion_fluctuations

# Create bins for criterion fluctuations
data$binned_criterion <- cut2(data$criterion_fluctuations, g = 5, levels.mean = TRUE) # 5 bins
data$binned_criterion <- as.numeric(as.character(data$binned_criterion))


# Change scale absevi for plotting
data[data$signevi == -1, 'absevi'] <- data[data$signevi == -1, 'absevi']*-1


# Calculate mean confidence for each subject
data_conf <- data %>%
  group_by(subj, binned_criterion, absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_conf1 = mean(conf), sum_obs = n()) %>%
  ungroup()

# Calculate mean confidence and standard error over all subjects
data_conf <- data_conf %>% 
  group_by(binned_criterion, absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_conf = mean(mean_conf1), sum_obs = sum(sum_obs), se = sd(mean_conf1)/sqrt(length(unique(data$subj)))) %>% # make standard error
  ungroup()

# Calculate mean response for each subject
data_resp <- data %>%
  group_by(subj, binned_criterion, absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_resp1 = mean(resp), sum_obs = n()) %>%
  ungroup()

# Calculate mean response and standard error over all subjects
data_resp <- data_resp %>% 
  group_by(binned_criterion, absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_resp = mean(mean_resp1), sum_obs = sum(sum_obs), se = sd(mean_resp1)/sqrt(length(unique(data$subj)))) %>% # make standard error
  ungroup()


# Calculate mean confidence for each subject WITHOUT criterion fluctuations
data_conf_no_cf <- data %>%
  group_by(subj, absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_conf1 = mean(conf), sum_obs = n()) %>%
  ungroup()

# Calculate mean confidence and standard error over all subjects WITHOUT criterion fluctuations
data_conf_no_cf <- data_conf_no_cf %>% 
  group_by(absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_conf = mean(mean_conf1), sum_obs = sum(sum_obs), se = sd(mean_conf1)/sqrt(length(unique(data$subj)))) %>% # make standard error
  ungroup()

# Plotting
size_for_poster <- 1

facet_labs <- c("Left", "Right")
names(facet_labs) <- c('-1','1')

offset = 0.0

ggplot(mapping = aes(x = absevi, y = mean_conf, group = binned_criterion, 
                          color = binned_criterion), data = data_conf) +
  geom_errorbar(aes(ymin = mean_conf - se, ymax = mean_conf + se), width = 0, position = position_dodge(width = offset), linewidth = 0.7 * size_for_poster) +
  geom_line(linewidth = 1.5 * size_for_poster, aes(group = binned_criterion, color = binned_criterion), position = position_dodge(width = offset)) +
  geom_point(size = 2.5 * size_for_poster, position = position_dodge(width = offset)) +
  facet_wrap(~signevi, labeller = labeller(signevi = facet_labs), scales = "free_x") +
  scale_colour_viridis_c(direction = 1,begin=0, end=.9, name = 'Criterion state', alpha=1) +
  xlab('Stimulus') +
  ylab('Confidence') +
  ylim(0.3, 0.68) +
  theme_classic(base_size = 12 * size_for_poster) +
  theme(
    axis.text = element_text(size = 10 * size_for_poster), 
    axis.title = element_text(size = 18 * size_for_poster), 
    legend.title = element_text(size = 18 * size_for_poster),  
    legend.text = element_text(size = 15 * size_for_poster),
    strip.text.x = element_text(size = 18 * size_for_poster), 
    plot.title = element_text(size = 24 * size_for_poster, face = 'bold', hjust = 0),
    #legend.position = "none"
  )

ggsave("Shekhar_confidence_criterion_withlegend.png", dpi=600)

ggplot(mapping = aes(x = absevi, y = mean_conf), data = data_conf_no_cf) +
  geom_errorbar(aes(ymin = mean_conf - se, ymax = mean_conf + se), width = 0, position = position_dodge(width = offset), linewidth = 0.7 * size_for_poster) +
  geom_line(linewidth = 1.5 * size_for_poster, aes(group = 1), position = position_dodge(width = offset)) +
  geom_point(size = 2.5 * size_for_poster, position = position_dodge(width = offset)) +
  facet_wrap(~signevi, labeller = labeller(signevi = facet_labs), scales = "free_x") +
  scale_colour_viridis_c(direction = 1,begin=0, end=.9, name = 'Criterion state', alpha=1) +
  xlab('Stimulus') +
  ylab('Confidence') +
  ylim(0.3, 0.68) +
  theme_classic(base_size = 12 * size_for_poster) +
  theme(
    axis.text = element_text(size = 10 * size_for_poster), 
    axis.title = element_text(size = 18 * size_for_poster), 
    legend.title = element_text(size = 18 * size_for_poster),  
    legend.text = element_text(size = 15 * size_for_poster),
    strip.text.x = element_text(size = 18 * size_for_poster), 
    plot.title = element_text(size = 24 * size_for_poster, face = 'bold', hjust = 0)
  )

ggsave("Shekhar_confidence.png", dpi=600)


# plot mean response
ggplot(mapping = aes(x = absevi, y = mean_resp, group = binned_criterion, color = binned_criterion), data = data_resp) +
  geom_errorbar(aes(ymin = mean_resp - se, ymax = mean_resp + se), width = 0, position = position_dodge(width = offset), linewidth = .2 * size_for_poster) +
  geom_line(linewidth = 1.5 * size_for_poster, aes(group = binned_criterion, color = binned_criterion), position = position_dodge(width = offset)) +
  geom_point(size = 2.5 * size_for_poster, position = position_dodge(width = offset)) +
  facet_wrap(~signevi, labeller = labeller(signevi = facet_labs), scales = "free_x")+
  scale_colour_viridis_c(direction = 1,begin=0, end=.9, name = 'Criterion state', alpha=1) +
  xlab('Stimulus') +
  ylab('P(Right response)') +
  #ylim(0.2, 0.75) +
  theme_classic(base_size = 12 * size_for_poster) +
  theme(
    axis.text = element_text(size = 10 * size_for_poster), 
    axis.title = element_text(size = 18 * size_for_poster), 
    legend.title = element_text(size = 18 * size_for_poster),  
    legend.text = element_text(size = 15 * size_for_poster),
    strip.text.x = element_text(size = 18 * size_for_poster), 
    plot.title = element_text(size = 24 * size_for_poster, face = 'bold', hjust = 0)
  )

ggsave("Shekhar_criterion_response.emf", dpi=600)
