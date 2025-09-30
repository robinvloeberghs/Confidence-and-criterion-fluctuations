library(lme4)
library(car)
library(lmerTest)
library(rstudioapi)

curdir <- dirname(getSourceEditorContext()$path)
setwd(curdir)

df <- read.csv("./_all_preprocessed_data_merged.csv")

conf_absevi <- c()
conf_accuracy <- c()
resp_evidence <- c()

for (i in unique(df$study)){
  temp <- subset(df,study==i)
  
  m1 <- lmer(conf ~ absevi+accuracy+(1|subj),data = temp)
  coef1 <- summary(m1)
  conf_absevi <- c(conf_absevi,coef1$coefficients[2,1])
  conf_accuracy <- c(conf_accuracy,coef1$coefficients[3,1])
  
  m2 <- glmer(resp ~ evidence+(1|subj),data = temp, family='binomial')
  coef2 <- summary(m2)
  resp_evidence <- c(resp_evidence,coef2$coefficients[2,1])
  
}

# Save work space image
save.image(file = "sanity_checks.RData")

# For CalderTravis no relation between confidence and absolute evidence
# However, the only information in the raw data is the dot difference so we cannot use anything else