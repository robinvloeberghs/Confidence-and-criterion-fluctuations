library(plyr)
library(lme4)
library(car)
library(utils)


# Creates a formula for the model based on a given random_slope
build_formula = function(basic_formula, random_slopes){
  
  # Find the 1 from random intercept and split the formula based on it
  formula_parts = unlist(strsplit(basic_formula, "(?<=1)", perl=TRUE)) 
  
  # Create formula by adding random slope
  formula = as.formula(paste(formula_parts[1], random_slopes, formula_parts[2])) 

  return(formula)
}


# Fits model and returns AIC/BIC (or model with return_model_only=TRUE)
fit_model_and_return_AIC_BIC <- function(formula, data, glmer=FALSE, return_model_only=FALSE){
  
  result <- data.frame(matrix(NA, ncol=2, nrow=1)); names(result) <- c("aic","bic") 
  
  tryCatch({ # makes sure that if model does not converge or has singular fit AIC and BIC will become NA
    if (glmer == FALSE){
      model <- lmer(formula = formula, data = data, 
                    control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))
    } else if (glmer == TRUE){
      model <- glmer(formula = formula, family = binomial, data = data, 
                     control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))
    }
    
    result$aic <- AIC(model)
    result$bic <- BIC(model)
    
    if (return_model_only == TRUE){
      result <- model
    }
  },
  message = function(msg) {
    NULL # makes sure that function continues running (without breaking the for loop over datasets)
  },
  warning = function(w) {
    NULL
  },
  error = function(e) {
    NULL
  })
  
  return(result)
}


# Function that creates formula, fits model, and returns AIC and BIC
# Is needed for the parallel computing
return_aic_bic <- function(random_effect){
  
  formula <- build_formula(basic_formula, random_effect)
  aic_bic <- fit_model_and_return_AIC_BIC(formula, data = data, glmer = FALSE)
  
  return(aic_bic)
}

