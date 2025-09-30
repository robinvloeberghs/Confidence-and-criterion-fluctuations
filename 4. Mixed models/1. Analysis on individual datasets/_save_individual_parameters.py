# -*- coding: utf-8 -*-
"""
Created on Fri Nov  8 15:53:22 2024

@author: u0141056
"""

import jax.numpy as jnp
import matplotlib.pyplot as plt
import dill
import os
import pandas as pd


dirs = ['Adler_2018_Expt3',
 'Adler_2018_Expt1_taskA',
 'Adler_2018_Expt1_taskB',
 'Denison_2018',
 'Recht_unpub',
 'VanBoxtel_2019_Expt1',
 'VanBoxtel_2019_Expt2',
 'Law_unpub',
 'Yeon_unpub_Exp2',
 'Siedlecka_2021',
 'Shekhar_2021',
 'CalderTravis_unpub',
 'Filevich_unpub',
 'Maniscalco_2017_expt2',
 'Wang_2018']
        

basepath = 'C:/Users/u0141056/OneDrive - KU Leuven/PhD/PROJECTS/Confidence and hMFC/Analysis/3. hMFC/3.3 Dil files/3.3.3 Fixed alpha and beta, no mean-centering'


all_intercept = []
all_evidence = []
all_prevsignevi = []
all_prevabsevi = []
all_prevsignabsevi = []
all_prevresp = []
all_prevconf = []
all_prevrespconf = []
all_study = []
all_subject = []


for data_dir in dirs:
    
    print(data_dir)

    dilfile = data_dir + '.dil' 
    dilpath = basepath + '/' + dilfile
    
    g = globals()
    with open(dilpath,'rb') as file:
        list_of_variable_names = dill.load(file)  # Get the names of stored objects
        for variable_name in list_of_variable_names:
            g[variable_name] = dill.load(file)    # Get the objects themselves
    
    # variables to add in .csv
    all_intercept.append(jnp.mean(posterior_samples_w[burn_in:,:,0], axis=0))
    all_evidence.append(jnp.mean(posterior_samples_w[burn_in:,:,1], axis=0))
    all_prevsignevi.append(jnp.mean(posterior_samples_w[burn_in:,:,2], axis=0))
    all_prevabsevi.append(jnp.mean(posterior_samples_w[burn_in:,:,3], axis=0))
    all_prevsignabsevi.append(jnp.mean(posterior_samples_w[burn_in:,:,4], axis=0))
    all_prevresp.append(jnp.mean(posterior_samples_w[burn_in:,:,5], axis=0))
    all_prevconf.append(jnp.mean(posterior_samples_w[burn_in:,:,6], axis=0))
    all_prevrespconf.append(jnp.mean(posterior_samples_w[burn_in:,:,7], axis=0))
    
    all_study.extend([data_dir] * num_subjects)
    all_subject.extend(list(range(0, num_subjects)))



all_intercept = jnp.concatenate(all_intercept)
all_evidence = jnp.concatenate(all_evidence)
all_prevsignevi = jnp.concatenate(all_prevsignevi)
all_prevabsevi = jnp.concatenate(all_prevabsevi)
all_prevsignabsevi = jnp.concatenate(all_prevsignabsevi)
all_prevresp = jnp.concatenate(all_prevresp)
all_prevconf = jnp.concatenate(all_prevconf)
all_prevrespconf = jnp.concatenate(all_prevrespconf)



df_individual_parameters = pd.DataFrame({
    'study': all_study,
    'subject': all_subject,
    'intercept': all_intercept,
    'evidence': all_evidence,
    'prevsignevi': all_prevsignevi,
    'prevabsevi': all_prevabsevi,
    'prevsignabsevi': all_prevsignabsevi,
    'prevresp': all_prevresp,
    'prevconf': all_prevconf,
    'prevrespconf': all_prevrespconf
})


df_individual_parameters.to_csv('C:/Users/u0141056/OneDrive - KU Leuven/PhD/PROJECTS/Confidence and hMFC/Analysis/4. Mixed models/1. Analysis on individual datasets/_per_subject_parameters.csv', index=False)





