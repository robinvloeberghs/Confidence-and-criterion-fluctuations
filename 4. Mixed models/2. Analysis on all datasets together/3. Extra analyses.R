
# Individual differences in AR(1) parameters and their relation with confidence

library(lme4)
library(car)
library(rsq)
library(gtools)
library(lmerTest)
library(effects)

# Load in data
data <- read.csv("./3. hMFC/3.4 Data with a and sigma_sq/_all_data_with_a_sigmasq.csv")

a <- aggregate(data$a, by=list(data$study), FUN = function(x) c(mean = mean(x), sd = sd(x), min = min(x), max = max(x) ))
sigmasq <- aggregate(data$sigmasq, by=list(data$study), FUN = function(x) c(mean = mean(x), sd = sd(x), min = min(x), max = max(x) ))
mu_x <- aggregate(data$mu_x, by=list(data$study), FUN = function(x) c(mean = mean(x), sd = sd(x), min = min(x), max = max(x) ))

df_summary  <- data.frame(unique(data$study),round(a$x,2),round(sigmasq$x,2),round(mu_x$x,2))


# Standardize predictors
data$a_scaled <- scale(data$a)
data$sigmasq_scaled <- scale(data$sigmasq)
data$mu_x_scaled <- scale(data$mu_x)

data$sd_criterion_fluctuations_scaled <- scale(data$sd_criterion_fluctuations)

cor.test(data$a, data$sigmasq)

# Confidence variability and hMFC parameters
m1 <- lmer(sd_conf ~  a_scaled * sigmasq_scaled + (1|study), data = data)
m2 <- lmer(sd_conf ~  a_scaled * sigmasq_scaled  + (1 + a_scaled|study), data = data)
m3 <- lmer(sd_conf ~  a_scaled * sigmasq_scaled  + (1 + sigmasq_scaled|study), data = data) # singular fit
m4 <- lmer(sd_conf ~  a_scaled * sigmasq_scaled  + (1 + a_scaled + sigmasq_scaled|study), data = data) # singular fit
m5 <- lmer(sd_conf ~  a_scaled * sigmasq_scaled  + (1 + a_scaled * sigmasq_scaled|study), data = data) # singular fit

anova(m1,m2)

# m1 is winning model
summary(m1)
anova(m1)
vif(m1)

mm1 <- lmer(sd_conf ~  a_scaled * sigmasq_scaled + mu_x_scaled + (1|study), data = data)
summary(mm1)
anova(mm1)
vif(mm1)


# Criterion fluctuations variability and hMFC parameters (sanity check)
m_check <- lmer(sd_criterion_fluctuations ~  a_scaled * sigmasq_scaled + (1 |study), data = data)  
summary(m_check)
anova(m_check)
vif(m_check)


# Alternative model with the standard deviation of fluctuations instead of hMFC parameters 
mm1 <- lmer(sd_conf ~ sd_criterion_fluctuations_scaled + (1 |study), data = data)  
mm2 <- lmer(sd_conf ~ sd_criterion_fluctuations_scaled + (1 + sd_criterion_fluctuations_scaled |study), data = data) # singular fit

# mm1 is winner (only model without singular fit)
summary(mm1)
anova(mm1)


# Study for which we don't find the crucial interaction between stimulus direction and criterion:
# Maniscalo_2017_expt2

data$study <- as.factor(data$study)

# Maniscalco_2017_expt2 as reference
data$study <- relevel(data$study, ref = "Maniscalco_2017_expt2")

mmm1 <- lm(data=data,sd_criterion_fluctuations ~ 1 + study)
summary(mmm1)

mmm2 <- lm(data=data,a ~ 1 + study)
summary(mmm2) # many studies having significantly lower a compared to Maniscalco_2017_expt2

mmm3 <- lm(data=data,sigmasq ~ 1 + study)
summary(mmm3)

mmm4 <- lm(data=data,sd_conf ~ 1 + study)
summary(mmm4)





# studies with continuous report or 6-point scales have the lowest sd, whereas 2 or 4 point scale the highest
# so mm4 do not make a lot of sense
sd_conf_per_study <- aggregate(data$sd_conf, by=list(data$study), mean)
sd_conf_per_study[rev(order(sd_conf_per_study$x)),]

