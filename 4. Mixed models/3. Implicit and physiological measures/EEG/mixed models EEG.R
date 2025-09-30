
library(effects)
library(rstudioapi)
library(dplyr)
library(ggplot2)
library(Hmisc)
library(lme4)
library(car)
library(lmerTest)


curdir <- dirname(getSourceEditorContext()$path)
setwd(curdir)

# Load data ---------------------------------------------------------------
data <- read.csv("./4. Mixed models/3. Implicit and physiological measures/EEG/Boldtetal_ERPs_hddm_with_criterion_fluctuations.csv")


# Change sign for correspondence with SDT criterion -----------------------
data$criterion_fluctuations <- -1 * data$criterion_fluctuations
data$stimulus <- as.factor(data$stimulus)


# Sanity checks -----------------------------------------------------------
# Response 
m_resp <- glmer(formula = 'resp ~ 
                         stimulus + (1| sub)', data = data, 
                family = binomial,
                control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))
summary(m_resp)
Anova(m_resp, type=3)
plot(effect('stimulus', m_resp))


# Confidence
m_cj0 <- lmer(formula = 'cj ~ 
                        stimulus * criterion_fluctuations + (1| sub)', data = data, 
             control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_cj1 <- lmer(formula = 'cj ~ 
                        stimulus * criterion_fluctuations + (1 + stimulus| sub)', data = data, 
              control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_cj2 <- lmer(formula = 'cj ~ 
                        stimulus * criterion_fluctuations + (1 + criterion_fluctuations| sub)', data = data, 
              control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_cj3 <- lmer(formula = 'cj ~ 
                        stimulus * criterion_fluctuations + (1 + stimulus + criterion_fluctuations| sub)', data = data, 
              control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_cj4 <- lmer(formula = 'cj ~ 
                        stimulus * criterion_fluctuations + (1 + stimulus * criterion_fluctuations| sub)', data = data, 
              control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

AIC(m_cj0, m_cj1, m_cj2, m_cj3, m_cj4) # m_cj4 has lowest AIC


vif(m_cj4)
summary(m_cj4)
anova(m_cj4)


# Predicting Pe -----------------------------------------------------------
# With criterion fluctuations 
m_pe0 <- lmer(formula = 'PEpz ~ 
                        stimulus * criterion_fluctuations + (1| sub)', data = data, 
          control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe1 <- lmer(formula = 'PEpz ~ 
                        stimulus * criterion_fluctuations + (1 + stimulus| sub)', data = data, 
              control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe2 <- lmer(formula = 'PEpz ~ 
                        stimulus * criterion_fluctuations + (1 + criterion_fluctuations| sub)', data = data, 
              control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe3 <- lmer(formula = 'PEpz ~ 
                        stimulus * criterion_fluctuations + (1 + stimulus + criterion_fluctuations| sub)', data = data, 
              control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe4 <- lmer(formula = 'PEpz ~ 
                        stimulus * criterion_fluctuations + (1 + stimulus * criterion_fluctuations| sub)', data = data, 
              control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

AIC(m_pe0, m_pe1, m_pe2, m_pe3, m_pe4) # m_pe1 has lowest AIC

vif(m_pe1)
summary(m_pe1)
anova(m_pe1)
plot(effect('stimulus:criterion_fluctuations', m_pe1))


# Without criterion fluctuations
m_pe_no_crit0 <- lmer(formula = 'PEpz ~ 
                                 stimulus + (1| sub)', data = data, 
                      control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe_no_crit1 <- lmer(formula = 'PEpz ~ 
                                 stimulus + (1 + stimulus| sub)', data = data, 
                      control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

AIC(m_pe_no_crit0, m_pe_no_crit1) # m_pe_no_crit1 has lowest AIC


# Compare model with and without criterion fluctuations -------------------
anova(m_pe_no_crit1, m_pe1) # model with criterion clearly wins



# Session permutation method; Harris (2021) -------------------------------
# Create another null model by switching criterion fluctuations across subjects
set.seed(123)

# In order to shuffle all subjects within a dataset need the same length, so we truncate
data_truncated <- data.frame()
all_criterion_estimates_dataset_shuffled <- c()

min_trials <- min(table(data$sub)) # minimum number of trials over all subjects from data

position <- 1 # for position in list below
criterion_estimates_dataset <- list()
for (sub in unique(data$sub)){
  # save truncated data
  truncated_data <- data[data$sub==sub,][1:min_trials,]
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


# Random effects selection
m_pe_trunc0 <- lmer(formula = 'PEpz ~ 
                              stimulus * shuffled_criterion_fluctuations + (1 | sub)', data = data_truncated, 
                   control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe_trunc1 <- lmer(formula = 'PEpz ~ 
                              stimulus * shuffled_criterion_fluctuations + (1 + stimulus| sub)', data = data_truncated, 
                    control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe_trunc2 <- lmer(formula = 'PEpz ~ 
                              stimulus * shuffled_criterion_fluctuations + (1 + shuffled_criterion_fluctuations| sub)', data = data_truncated, 
                    control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe_trunc3 <- lmer(formula = 'PEpz ~ 
                              stimulus * shuffled_criterion_fluctuations + (1 + stimulus + shuffled_criterion_fluctuations| sub)', data = data_truncated, 
                    control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe_trunc4 <- lmer(formula = 'PEpz ~ 
                              stimulus * shuffled_criterion_fluctuations + (1 + stimulus * shuffled_criterion_fluctuations| sub)', data = data_truncated, 
                    control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

AIC(m_pe_trunc0, m_pe_trunc1, m_pe_trunc2, m_pe_trunc3, m_pe_trunc4) # m_pe_trunc3 has lowest AIC

vif(m_pe_trunc3)
summary(m_pe_trunc3)
anova(m_pe_trunc3)


# Compare original with shuffled criterion fluctuations -------------------
# Refit models with original fluctuations but truncated (otherwise we can't do model selection)

m_pe_trunc_original0 <- lmer(formula = 'PEpz ~ 
                              stimulus * criterion_fluctuations + (1 | sub)', data = data_truncated, 
                        control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe_trunc_original1 <- lmer(formula = 'PEpz ~ 
                              stimulus * criterion_fluctuations + (1 + stimulus| sub)', data = data_truncated, 
                        control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe_trunc_original2 <- lmer(formula = 'PEpz ~ 
                              stimulus * criterion_fluctuations + (1 + criterion_fluctuations| sub)', data = data_truncated, 
                        control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe_trunc_original3 <- lmer(formula = 'PEpz ~ 
                              stimulus * criterion_fluctuations + (1 + stimulus + criterion_fluctuations| sub)', data = data_truncated, 
                        control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

m_pe_trunc_original4 <- lmer(formula = 'PEpz ~ 
                              stimulus * criterion_fluctuations + (1 + stimulus * criterion_fluctuations| sub)', data = data_truncated, 
                        control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))

AIC(m_pe_trunc_original0, m_pe_trunc_original1, m_pe_trunc_original2, m_pe_trunc_original3, m_pe_trunc_original4) # m_pe_trunc_original4 has lowest AIC

anova(m_pe_trunc_original4, m_pe_trunc3) # model with original criterion wins


# Save workspace image
save.image(file = "mixed_models EEG.RData")






# Plotting ----------------------------------------------------------------

# Create bins for criterion fluctuations
data$binned_criterion <- cut2(data$criterion_fluctuations, g = 5, levels.mean = TRUE) # 5 bins
data$binned_criterion <- as.numeric(as.character(data$binned_criterion))
data$binned_criterion <- as.factor(round(data$binned_criterion, 1))


# Calculate mean PE for each subject
data_pe <- data %>%
  group_by(sub, binned_criterion, stimulus, .groups = 'keep') %>% 
  dplyr::summarise(mean_pe1 = mean(PEpz), sum_obs = n()) %>%
  ungroup()

# Calculate mean PE and standard error over all subjects
data_pe <- data_pe %>% 
  group_by(binned_criterion, stimulus, .groups = 'keep') %>% 
  dplyr::summarise(mean_pe = mean(mean_pe1), sum_obs = sum(sum_obs), se = sd(mean_pe1)/sqrt(length(unique(data$sub)))) %>% # make standard error
  ungroup()


offset = 0.1

# plot mean PE
ggplot(mapping = aes(x = binned_criterion, y = mean_pe, group = stimulus, color = stimulus), data = data_pe) +
  geom_errorbar(aes(ymin = mean_pe - se, ymax = mean_pe + se), width = 0, position = position_dodge(width = offset), linewidth = 0.7) +
  geom_line(linewidth = 1.5, aes(group = stimulus, color = stimulus), position = position_dodge(width = offset)) +
  geom_point(size = 2.5, position = position_dodge(width = offset)) +
  scale_color_manual(values = c("#5084C4", "orange"), name = "Stimulus direction") +
  xlab('Criterion') +
  ylab('Pe amplitude (µV)') +
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
    legend.position = "right"
  )

ggsave("pe_crit_legend.png", bg='transparent', dpi=600)

