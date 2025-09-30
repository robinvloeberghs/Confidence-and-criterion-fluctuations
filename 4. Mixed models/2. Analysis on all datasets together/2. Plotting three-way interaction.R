
library(effects)
library(rstudioapi)
library(dplyr)
library(ggplot2)
library(Hmisc)
library(lme4)


curdir <- dirname(getSourceEditorContext()$path)
setwd(curdir)


# Load data and best model from selection procedure
load("mixed_model_over_all_datasets.RData")

data <- read.csv("./3. hMFC/3.2 Data with criterion fluctuations/_all_data_with_criterion_fluctuations.csv")


# Add RT to data
temp <- read.csv("./2. Preprocessed data/_all_preprocessed_data_merged.csv")
rt <- temp$rt 
data <- cbind(data,rt)
data$accuracy <- ifelse((data$resp == 1 & data$signevi== 1) | (data$resp == 0 & data$signevi== -1), 1, 0)


# Change sign for correspondence with SDT criterion(positive indicates right-shifted criterion)
data$criterion_fluctuations <- -1 * data$criterion_fluctuations

# Change sign evidence (-1,+1) into factor
# Sign evidence results in rank deficient model for Wang, due to three levels (one is almost zero)
# So let's remove the ambiguous stimulus trials (signevi = 0.001)
data <- data[data$signevi != 0.001,]

# Create bins for criterion fluctuations
data$binned_criterion <- cut2(data$criterion_fluctuations, g = 5, levels.mean = TRUE) # 5 bins
data$binned_criterion <- as.numeric(as.character(data$binned_criterion))
data$binned_absevi <- cut2(data$absevi, g=3, levels.mean = TRUE)
data$binned_absevi <- as.numeric(as.character(data$binned_absevi))


data$binned_criterion <- as.factor(round(data$binned_criterion, 2))

# Change scale absevi for plotting
data[data$signevi == -1, 'binned_absevi'] <- data[data$signevi == -1, 'binned_absevi']*-1


# Calculate mean confidence for each subject
data_conf <- data %>%
  group_by(subj, binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_conf1 = mean(conf), sum_obs = n()) %>%
  ungroup()

# Calculate mean confidence and standard error over all subjects
data_conf <- data_conf %>% 
  group_by(binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_conf = mean(mean_conf1), sum_obs = sum(sum_obs), se = sd(mean_conf1)/sqrt(length(unique(data$subj)))) %>% # make standard error
  ungroup()


# Calculate mean response for each subject
data_resp <- data %>%
  group_by(subj, binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_resp1 = mean(resp), sum_obs = n()) %>%
  ungroup()

# Calculate mean response and standard error over all subjects
data_resp <- data_resp %>% 
  group_by(binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_resp = mean(mean_resp1), sum_obs = sum(sum_obs), se = sd(mean_resp1)/sqrt(length(unique(data$subj)))) %>% # make standard error
  ungroup()

temp_data_rt <- data[data$rt < 5,]
# Calculate mean rt for each subject
data_rt <- temp_data_rt %>%
  group_by(subj, binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_rt1 = mean(rt), sum_obs = n()) %>%
  ungroup()

# Calculate mean rt and standard error over all subjects
data_rt <- data_rt %>% 
  group_by(binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_rt = mean(mean_rt1, na.rm=T), sum_obs = sum(sum_obs), se = sd(mean_rt1, na.rm=T)/sqrt(length(unique(data$subj)))) %>% # make standard error
  ungroup()

data_rt <- data_rt[-length(data_rt$binned_criterion),] # remove last element because NA


# Calculate mean accuracy for each subject
data_acc <- data %>%
  group_by(subj, binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_acc1 = mean(accuracy), sum_obs = n()) %>%
  ungroup()

# Calculate mean accuracy and standard error over all subjects
data_acc <- data_acc %>% 
  group_by(binned_criterion, binned_absevi, signevi, .groups = 'keep') %>% 
  summarise(mean_acc = mean(mean_acc1, na.rm=T), sum_obs = sum(sum_obs), se = sd(mean_acc1)/sqrt(length(unique(data$subj)))) %>% # make standard error
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
  facet_wrap(~signevi, labeller = labeller(signevi = facet_labs), scales = "free_x")+
  scale_colour_viridis_d(direction = 1, begin=0, end=.9, name = 'Criterion state') +
  xlab('Signed stimulus strength') +
  ylab('Confidence') +
  #ylim(0.2, 0.75) +
  theme_classic(base_size = 12 * size_for_poster) +
  theme(
    axis.text = element_text(size = 13), 
    axis.title = element_text(size = 14), 
    legend.title = element_text(size = 18),  
    legend.text = element_text(size = 15),
    strip.text.x = element_text(size = 18), 
    legend.position = "none"
  )

ggsave("all_datasets_confidence_criterion.png", dpi=600)

# plot mean response
ggplot(mapping = aes(x = binned_absevi, y = mean_resp, group = binned_criterion, color = binned_criterion), data = data_resp) +
  geom_errorbar(aes(ymin = mean_resp - se, ymax = mean_resp + se), width = 0, position = position_dodge(width = offset), linewidth = 0.7 * size_for_poster) +
  geom_line(linewidth = 1.5 * size_for_poster, aes(group = binned_criterion, color = binned_criterion), position = position_dodge(width = offset)) +
  geom_point(size = 2.5 * size_for_poster, position = position_dodge(width = offset)) +
  facet_wrap(~signevi, labeller = labeller(signevi = facet_labs), scales = "free_x")+
  scale_colour_viridis_d(direction = 1, name = 'Criterion state') +
  xlab('Evidence strength') +
  ylab('P(Right response)') +
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

ggsave("all_datasets_confidence_response.png", dpi=600)


# plot mean rt
hist(data$rt)
temp_data_rt$log_rt <- log(temp_data_rt$rt)
hist(temp_data_rt$log_rt)

m_rt <- lmer(log_rt ~ signevi*absevi*criterion_fluctuations + (1 | study/subj), data = temp_data_rt)
summary(m_rt)
anova(m_rt, type=3)

ggplot(mapping = aes(x = binned_absevi, y = mean_rt, group = binned_criterion, color = binned_criterion), data = data_rt) +
  geom_errorbar(aes(ymin = mean_rt - se, ymax = mean_rt + se), width = 0, position = position_dodge(width = offset), linewidth = 0.7 * size_for_poster) +
  geom_line(linewidth = 1.5 * size_for_poster, aes(group = binned_criterion, color = binned_criterion), position = position_dodge(width = offset)) +
  geom_point(size = 2.5 * size_for_poster, position = position_dodge(width = offset)) +
  facet_wrap(~signevi, labeller = labeller(signevi = facet_labs), scales = "free_x")+
  scale_colour_viridis_d(direction = 1, begin=0, end=.9, name = 'Criterion state') +
  xlab('Signed stimulus strength') +
  ylab('RT(sec)') +
  #ylim(0.2, 0.75) +
  theme_classic(base_size = 12 * size_for_poster) +
  theme(
    axis.text = element_text(size = 13), 
    axis.title = element_text(size = 14), 
    legend.title = element_text(size = 18),  
    legend.text = element_text(size = 15),
    strip.text.x = element_text(size = 18), 
    legend.position = "none"
  )

ggsave("all_datasets_confidence_rt.png", dpi=600)



# plot mean acc
ggplot(mapping = aes(x = binned_absevi, y = mean_acc, group = binned_criterion, color = binned_criterion), data = data_acc) +
  geom_errorbar(aes(ymin = mean_acc - se, ymax = mean_acc + se), width = 0, position = position_dodge(width = offset), linewidth = 0.7 * size_for_poster) +
  geom_line(linewidth = 1.5 * size_for_poster, aes(group = binned_criterion, color = binned_criterion), position = position_dodge(width = offset)) +
  geom_point(size = 2.5 * size_for_poster, position = position_dodge(width = offset)) +
  facet_wrap(~signevi, labeller = labeller(signevi = facet_labs), scales = "free_x")+
  scale_colour_viridis_d(direction = 1, name = 'Criterion state') +
  xlab('Evidence strength') +
  ylab('Accuracy') +
  #ylim(0.2, 0.75) +
  theme_classic(base_size = 12 * size_for_poster) +
  theme(
    axis.text = element_text(size = 15 * size_for_poster), 
    axis.title = element_text(size = 18 * size_for_poster), 
    legend.title = element_text(size = 18 * size_for_poster),  
    legend.text = element_text(size = 15 * size_for_poster),
    strip.text.x = element_text(size = 18 * size_for_poster), 
    plot.title = element_text(size = 24 * size_for_poster, face = 'bold', hjust = 0),
    legend.position = "none"
  )

ggsave("all_datasets_confidence_acc.png", dpi=600)
