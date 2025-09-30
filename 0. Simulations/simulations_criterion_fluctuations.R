
# Generate data with(out) criterion fluctuations

library(rstudioapi)
library(ggplot2)
library(car)
library(dplyr)
library(effects)
library(lmerTest)
library(Hmisc)


rm(list=ls())

curdir <- dirname(getSourceEditorContext()$path)
setwd(curdir)

set.seed(2025)

with_crit_fluct   = T # whether or not to implement criterion fluctuations (for sanity checks)
ntrials           = 6000
ar_coef           = .9995
crit_variation    = .05 # sigma in AR(1) for criterion fluctuations


# Generate empty data frame
df <- data.frame(matrix(NA,ncol=7,nrow=ntrials));names(df) <- c("resp","decision_variable","stimulus","stimulus_direction","stimulus_strength","crit","cj")

# Generate (internal) decision variables from normal distributions
stimulus_levels = c(-3,-2,-1,1,2,3)
df$decision_variable <- c(rnorm(ntrials/6,stimulus_levels[1]),rnorm(ntrials/6,stimulus_levels[2]),rnorm(ntrials/6,stimulus_levels[3]),rnorm(ntrials/6,stimulus_levels[4]),rnorm(ntrials/6,stimulus_levels[5]),rnorm(ntrials/6,stimulus_levels[6]))

# Generate stimulus variables
df$stimulus <- rep(stimulus_levels, each=ntrials/6)
df$stimulus_direction <- sign(df$stimulus)
df$stimulus_strength <- abs(df$stimulus)


# Shuffle all trials so that there's no stimulus dependencies
df <- df[sample(1:ntrials),]


# Generate (fluctuating) criterion
df$crit <- 0 # initial value (0 = unbiased)


if(with_crit_fluct){
  for (j in 2:ntrials){
    df$crit[j] <- ar_coef * df$crit[j-1] + rnorm(1,0,crit_variation) #AR(1) model
  }
}

plot(df$crit)

# Generate responses by comparing decision variable to (fluctuating) criterion
df$resp <- ifelse(df$decision_variable<df$crit,0,1)
df$cj <- abs(df$crit-df$decision_variable)


# Regression model
m <- lm(cj~ stimulus_direction*stimulus_strength*crit,df)
vif(m)
summary(m)
anova(m)


# Create bins for plotting
df$binned_criterion <- cut2(df$crit, g = 5, levels.mean = TRUE) # 5 bins
df$binned_criterion <- as.numeric(as.character(df$binned_criterion))

df_conf <- df %>%
  group_by(binned_criterion, stimulus_strength, stimulus_direction, .groups = 'keep') %>% 
  summarise(mean_conf = mean(cj), sum_obs = n()) %>%
  ungroup()

# Change scale absevi for plotting
df_conf[df_conf$stimulus_direction == -1, 'stimulus_strength'] <- df_conf[df_conf$stimulus_direction == -1, 'stimulus_strength']*-1


# Plotting

facet_labs <- c("Left", "Right")
names(facet_labs) <- c('-1','1')
offset = 0.0



ggplot(mapping = aes(x = stimulus_strength, y = mean_conf, group = binned_criterion, 
                     color = binned_criterion), data = df_conf) +
  geom_line(linewidth = 1.5, aes(group = binned_criterion, color = binned_criterion), position = position_dodge(width = offset)) +
  geom_point(size = 2.5, position = position_dodge(width = offset)) +
  facet_wrap(~stimulus_direction, labeller = labeller(stimulus_direction = facet_labs), scales = "free_x") +
  scale_colour_viridis_c(direction = 1,begin=0, end=.9, name = 'Criterion state', alpha=1) +
  xlab('Stimulus (a.u.)') +
  ylab('Confidence (a.u.)') +
  theme_classic(base_size = 12) +
  theme(
    #legend.position="none",
    axis.text = element_text(size = 15),
    axis.title = element_text(size = 18),
    legend.title = element_text(size = 18),
    legend.text = element_text(size = 15),
    strip.text.x = element_text(size = 18),
    plot.title = element_text(size = 24, face = 'bold', hjust = 0)
  )

ggsave("simulated_confidence_pattern.emf", dpi=600)

