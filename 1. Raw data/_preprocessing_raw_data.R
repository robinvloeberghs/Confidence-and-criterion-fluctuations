
#############################################################
# Pre-processing of studies with a manipulation of evidence #
#############################################################

library(dplyr)
library(scales)
library(plyr)
library(Hmisc)

# Set the working directory to the source file location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Create function to read multiple csv files at once
open_dfs <- function(df_name) {
  
  file <- paste0("data_", df_name, ".csv")
  df <- read.csv2(file, sep = ',') # read csv file
  df$study <- df_name # add study column  
  assign(df_name, df, envir = .GlobalEnv)
  
}

# To do the pre-processing, studies are grouped based on stimulus type



# 1 - Studies that used Gabors -------------------------------------------------
# Studies with Gabor patches
dfs <- c('Adler_2018_Expt1','Adler_2018_Expt3','Denison_2018','Filevich_unpub', 'Maniscalco_2017_expt2','Recht_unpub','Shekhar_2021')

# Apply function
invisible(lapply(dfs, open_dfs)) # invisible is so that we don't print every df

# In this experiment they had two tasks, since we will analyze them separately create two different dataframes
Adler_2018_Expt1_taskA <- Adler_2018_Expt1[Adler_2018_Expt1$Task == 'A',]
Adler_2018_Expt1_taskB <- Adler_2018_Expt1[Adler_2018_Expt1$Task == 'B',]

# Also renaming study column
Adler_2018_Expt1_taskA$study <- 'Adler_2018_Expt1_taskA'
Adler_2018_Expt1_taskB$study <- 'Adler_2018_Expt1_taskB'

# For some studies, we have difficulty instead of abs_ev. In these cases, we have to revert the scale so that a higher number means less difficulty:
# Rescale between .01 and 1 (not 0 because lowest level still contains some stimulus information)
for (df_name in c('Adler_2018_Expt1_taskA', 'Adler_2018_Expt1_taskB', 'Adler_2018_Expt3', 'Denison_2018')){
  assign(df_name, within(get(df_name), absevi <- (abs(as.numeric(Orientation)) * rescale(as.numeric(Difficulty), to= c(1,0.01)))))
  assign(df_name, within(get(df_name), absevi <- rescale(absevi, to = c(0.01, 1))))
}

Filevich_unpub$absevi <- rescale(as.numeric(Filevich_unpub$Difficulty), to = c(0.01, 1))

# For the other studies, I'm renaming their abs_ev measure to absevi
Maniscalco_2017_expt2 <- Maniscalco_2017_expt2 %>% dplyr::rename(absevi = Contrast)
Shekhar_2021 <- Shekhar_2021 %>% dplyr::rename(absevi = Contrast)
Recht_unpub <- Recht_unpub %>% dplyr::mutate(absevi = revalue(Validity, c('V' = 1, 'I' = 0.01))) # for Recht, revaluing 'V' (valid cue) to 1 (high abs evi) and 'I' (invalid cue) to 0 (low abs evi)
rm(Adler_2018_Expt1) # remove because split up into task A and B

# Rename RT_dec as RT_decConf for easy merge later
Filevich_unpub <- Filevich_unpub %>% dplyr::rename(RT_decConf = RT_dec)
Maniscalco_2017_expt2 <- Maniscalco_2017_expt2 %>% dplyr::rename(RT_decConf = RT_dec)
Recht_unpub <- Recht_unpub %>% dplyr::rename(RT_decConf = RT_dec)

df_lst <- Filter(function(x) is(x, "data.frame"), mget(ls())) # gets all dfs in workspace and adds them to a list

# Clears workspace except for our list of dfs
rm(list=setdiff(ls(), c("df_lst", "open_dfs")))



# 2 - Random dot motion --------------------------------------------------------
# Studies with random dot motion
dfs <- c('Law_unpub','VanBoxtel_2019_Expt1','VanBoxtel_2019_Expt2','Yeon_unpub_Exp2')

invisible(lapply(dfs, open_dfs))

# Remove calibration trials and practice blocks
Law_unpub <- Law_unpub[Law_unpub$isCalibTrial == 0,]
Yeon_unpub_Exp2 <- Yeon_unpub_Exp2[Yeon_unpub_Exp2$Training == 0,]

# Revert difficulty
VanBoxtel_2019_Expt1$absevi <- rescale(as.numeric(VanBoxtel_2019_Expt1$NoiseLevel_Deg),to = c(1, 0.01)) 
VanBoxtel_2019_Expt2$absevi <- rescale(as.numeric(VanBoxtel_2019_Expt2$NoiseLevel_Deg),to = c(1, 0.01))

# Rename difficulty
Law_unpub <- Law_unpub %>% dplyr::rename(absevi = coh_level)
Yeon_unpub_Exp2 <- Yeon_unpub_Exp2 %>% dplyr::rename(absevi = Coherence)

# Rename RT_dec as RT_decConf for easy merge later
Yeon_unpub_Exp2 <- Yeon_unpub_Exp2 %>% dplyr::rename(RT_decConf = RT_dec)

# add these dataframes to list
df_lst <- c(df_lst, Filter(function(x) is(x, "data.frame"), mget(ls())))

# clear workspace except for our list of dfs
rm(list=setdiff(ls(), c("df_lst", "open_dfs")))

# 3 - Others -------------------------------------------------------------------

dfs <- c('CalderTravis_unpub', 'Siedlecka_2021', 'Wang_2018')

invisible(lapply(dfs, open_dfs))

# recode responses in Siedlecka
Siedlecka_2021[Siedlecka_2021$Condition == 1,]$Response <- revalue(Siedlecka_2021[Siedlecka_2021$Condition == 1,]$Response, c('1.0' = -1, 'NaN' = 1))
Siedlecka_2021[Siedlecka_2021$Condition == 2,]$Response <- revalue(Siedlecka_2021[Siedlecka_2021$Condition == 2,]$Response, c('1.0' = 1, 'NaN' = -1))

# absevi
Siedlecka_2021$absevi <- abs(Siedlecka_2021$L_dots - Siedlecka_2021$R_dots) # making absolute dot diff the absevi
CalderTravis_unpub$absevi <- abs(CalderTravis_unpub$Dot_diff)

# for Wang et al, stimuli and absevi were together
Wang_2018$absevi <- abs(Wang_2018$Stimulus - 4)
Wang_2018 <- Wang_2018 %>%
  mutate(Stimulus = case_when(
    Stimulus < 4 ~ -1,
    Stimulus == 4 ~ 0,
    Stimulus > 4 ~ 1
  ))

# in Siedlecka_2021 reporting a mistake was coded as NaN, we will recode it as 0 (the lowest level of confidence)
Siedlecka_2021$Confidence <- revalue(Siedlecka_2021$Confidence, c('NaN' = '0.01'))

# Rename RT_dec as RT_decConf for easy merge later
CalderTravis_unpub <- CalderTravis_unpub %>% dplyr::rename(RT_decConf = RT_dec)
Siedlecka_2021 <- Siedlecka_2021 %>% dplyr::rename(RT_decConf = RT_dec)
Wang_2018 <- Wang_2018 %>% dplyr::rename(RT_decConf = RT_dec)

df_lst <- c(df_lst, Filter(function(x) is(x, "data.frame"), mget(ls())))

rm(list=setdiff(ls(), c("df_lst", "open_dfs")))



################################################################################
# Merge data -------------------------------------------------------------------
################################################################################

# merge data so we can do the rest of the operations at once
data <- ldply(df_lst, data.frame, .id = 'study')

rm(df_lst)

data <- data[,c('study', 'Subj_idx','Stimulus','Response','RT_decConf','Confidence', 'absevi')]

# rename cols
data <- data %>%
  dplyr::rename(subj = Subj_idx,
         resp = Response,
         conf = Confidence,
         rt = RT_decConf)

# check str
str(data)

# turn into numeric
data[c('resp','conf','absevi')] <- sapply(data[c('resp','conf','absevi')], as.numeric)

colSums(is.na(data))

# rm NAs
data <- data[complete.cases(data),]

# change stimuli to go from -1 to 1
conv <- function(col){
  # (Wang_2018 has 3 values (happy, neutral, fear -> -1,0,1) but it will be ok when running this function)
  col = as.numeric(col) # just in case
  col = mapvalues(col, from = c(min(col),max(col)), to = c(-1, 1))
  return(col)
}

data <- data %>% 
  group_by(study) %>%
  dplyr::mutate(signevi = conv(Stimulus),
                resp = conv(resp),
                absevi = rescale(absevi, to = c(0.01,1)),
                conf = rescale(conf, to = c(0.01,1)))



# for 0, we will use this value (only matters for 'Wang_2018, is the perfect ambiguous stimulus)
data[data$signevi == 0,]$signevi = 0.001 

data$evidence <- data$signevi * data$absevi

# create lagged variables
data <- data %>%
  group_by(study, subj) %>%
  dplyr::mutate(
    prevsignevi = Lag(signevi),
    prevabsevi = Lag(absevi),
    prevresp = Lag(resp),
    prevconf = Lag(conf)
  )%>%
  slice(-1) # delete first row of each group (because they're NAs)

data$prevsignabsevi <- data$prevsignevi * data$prevabsevi
data$prevrespconf <- data$prevresp * data$prevconf
data$resp <- revalue(as.factor(data$resp), c('1' = '1', '-1' = '0'))

data <- data[,c('study', 'subj', 'resp','rt', 'evidence', 'absevi', 'signevi', 'prevsignevi', 'prevabsevi', 'prevsignabsevi',
                'prevresp','prevconf','conf','prevrespconf')]

data[c('resp','prevsignevi','prevresp')] <- lapply(data[c('resp','prevsignevi','prevresp')], factor)


# Exclusion criteria
# Remove subjects that 1) perform at chance, 2) give same confidence rating for more than 90% of the trials
data$accuracy <- ifelse((data$resp == 1 & data$signevi == 1) | (data$resp == 0 & data$signevi == -1), 1, 0)
data$rt <- as.numeric(data$rt) 

subject_id <- c()
dataset_id <- c()
mean_accuracy <- c()
p_value <- c()
proportion_same_conf <- c()

for (dataset in unique(data$study)){
  
  df <- data[data$study == dataset,]
  
  for (subj in unique(df$subj)){
    
    freq_conf <- as.data.frame(table(df$conf[df$subj==subj]))
    prop_same_conf <- max(freq_conf$Freq)/sum(freq_conf$Freq) # divide frequency of most given rating by total frequency
    outcome_binom <- binom.test(sum(df$accuracy[df$subj==subj]), length(df$accuracy[df$subj==subj]), p = 0.5, alternative = c("greater"))
    
    subject_id <- c(subject_id, subj)
    dataset_id <- c(dataset_id, dataset)
    mean_accuracy <- c(mean_accuracy, mean(df$accuracy[df$subj==subj]))
    p_value <- c(p_value, outcome_binom$p.value)
    proportion_same_conf <- c(proportion_same_conf,prop_same_conf)
  }
}

chance_performance <- ifelse(p_value <= .05, FALSE, TRUE)
too_little_variability_conf <- ifelse(proportion_same_conf > .9, TRUE, FALSE)

df_exclusion <- data.frame(subject_id,dataset_id,mean_accuracy,p_value,chance_performance,proportion_same_conf,too_little_variability_conf)

subj_to_remove <- df_exclusion[df_exclusion$chance_performance==TRUE | df_exclusion$too_little_variability_conf==TRUE,]

for (dataset in unique(subj_to_remove$dataset_id)){
  for (subj in subj_to_remove$subject_id[subj_to_remove$dataset_id==dataset]){
    data <- data[!(data$study == dataset & data$subj == subj),]
  }
}


# Before writing data, we need to eliminate certain subjects from certain studies,
# Fits to these subjects resulted in extreme criterion estimates (absolute value > 10)
# Because of the hierarchical nature of hmfc these extreme fits may influence 
# fits from other subjects as well so we'll remove them.

# Yeon_unpub_Exp2 (extreme sigmasq and criterion values)
data <- data[!(data$study == 'Yeon_unpub_Exp2' & data$subj %in% c(7,21,27)),]

# Law_unpub (extreme sigmasq and criterion values)
data <- data[!(data$study == 'Law_unpub' & data$subj == 9),]

# VanBoxtel_2019_Expt1 (extreme sigmasq and criterion values)
data <- data[!(data$study == 'VanBoxtel_2019_Expt1' & data$subj == 38),]

# VanBoxtel_2019_Expt2 (extreme sigmasq and criterion values)
data <- data[!(data$study == 'VanBoxtel_2019_Expt2' & data$subj == 18),]


# write data
# directory where it will store data:
dir_path <- '../2. Preprocessed data'

if (!dir.exists(dir_path)) {
  dir.create(dir_path, recursive = TRUE)
}

write.csv(data, file.path(dir_path, "_all_preprocessed_data_merged.csv"))

# Also writing each study separately, as that is how we will need them to fit hMFC
for (study in unique(data$study)) {
  study_data <- data[data$study == study,]
  
  # Write CSV directly to dir_path without creating a separate folder
  write.csv(study_data, file = file.path(dir_path, paste0(study, '.csv')))
}
