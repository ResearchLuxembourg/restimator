#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec 20 09:38:41 2021

@author: daniele.proverbio

Code to monitor the COVID-19 epidemic in Luxembourg and estimate useful
indicators for the Ministry of Health and the Taskforce WP6.

Path to input file at line 186
Path to output file at line 242; to output plot at line 260

"""

# -----
#
# Preliminary settings
#
# -----


# ----- import packages
import pandas as pd
import numpy as np
import datetime as DT
from scipy import stats as sps
from matplotlib import pyplot as plt
from matplotlib import dates as mdates
from matplotlib.dates import date2num
import plot_reff_estimate

# ----- global variables for data analysis
FILTERED_REGION_CODES = ['LU']
state_name = 'LU'
today = DT.datetime.now().strftime("%Y-%m-%d")
idx_start = 22 # Initial condition, over the first wave in March

# ----- some preparation to make sure data are ok
def prepare_cases(cases, cutoff=25):   # prepare data, to get daily cases and smoothing
    new_cases = cases.diff()
    if new_cases.any() < 0:            # raise exception: some day is skipped, or data are input incorrectly
        raise ValueError('Problem with data: negative new cases encountered')

    smoothed = new_cases.rolling(7,
        min_periods=1,
        center=False).mean().round()

    smoothed = smoothed.iloc[idx_start:]
    original = new_cases.loc[smoothed.index]

    return original, smoothed

# ----- getting highest density intervals for the Bayesian inference

def highest_density_interval(pmf, p=.9, debug=False):
    # If we pass a DataFrame, just call this recursively on the columns
    if(isinstance(pmf, pd.DataFrame)):
        return pd.DataFrame([highest_density_interval(pmf[col], p=p) for col in pmf],
                            index=pmf.columns)

    cumsum = np.cumsum(pmf.values)
    total_p = cumsum - cumsum[:, None]    # N x N matrix of total probability mass for each low, high
    lows, highs = (total_p > p).nonzero() # Return all indices with total_p > p
    best = (highs - lows).argmin()        # Find the smallest range (highest density)

    low = pmf.index[lows[best]]
    high = pmf.index[highs[best]]

    return pd.Series([low, high],index=[f'Low_{p*100:.0f}',f'High_{p*100:.0f}'])

# -----  getting posteriors for R_t evaluation

def get_posteriors(sr, date, sigma=0.15):
    # (1) Calculate Lambda (average arrival rate from Poisson process)
    gamma=1/np.random.normal(4, 0.2, len(r_t_range)) # COVID-19 serial interval, with uncertainty
    lam = sr[:-1] * np.exp(gamma[:, None] * (r_t_range[:, None] - 1))

    # (2) Calculate each day's likelihood
    likelihoods = pd.DataFrame(
        data = sps.poisson.pmf(sr[1:], lam),
        index = r_t_range,
        columns = date[1:])

    # (3) Create the Gaussian Matrix
    process_matrix = sps.norm(loc=r_t_range,scale=sigma).pdf(r_t_range[:, None])

    # (3a) Normalize all rows to sum to 1
    process_matrix /= process_matrix.sum(axis=0)

    # (4) Calculate the initial prior
    prior0 = np.ones_like(r_t_range)/len(r_t_range)
    prior0 /= prior0.sum()

    # Create a DataFrame that will hold our posteriors for each day
    # Insert our prior as the first posterior.
    posteriors = pd.DataFrame(index=r_t_range,columns=date,data={date[0]: prior0})

    # Keep track of the sum of the log of the probability of the data for maximum likelihood calculation.
    log_likelihood = 0.0

    # (5) Iteratively apply Bayes' rule
    for previous_day, current_day in zip(date[:-1], date[1:]):

        #(5a) Calculate the new prior
        current_prior = process_matrix @ posteriors[previous_day]

        #(5b) Calculate the numerator of Bayes' Rule: P(k|R_t)P(R_t)
        numerator = likelihoods[current_day] * current_prior

        #(5c) Calcluate the denominator of Bayes' Rule P(k)
        denominator = np.sum(numerator)

        # Execute full Bayes' Rule
        posteriors[current_day] = numerator/denominator

        # Add to the running sum of log likelihoods
        log_likelihood += np.log(denominator)

    return posteriors, log_likelihood

# -----
#
# Input data
#
# -----

while True:
    try:
        path = "input/input-data.xlsx" #  specify path to file
        full_data = pd.read_excel(path, engine='openpyxl').iloc[::-1].reset_index()
        break
    except ValueError:
         print("File name not recognised")

while True:
    try:
        data_df = pd.DataFrame(full_data,
                       columns =['report_date','new_cases','positive_patients_intensive_care','positive_patients_normal_care', 'covid_patients_dead', 'new_cases_resident','tests_done_resident'])
        break
    except ValueError:
        print("Possible typo in columns names")

population_LU = 600000
dates = data_df.iloc[idx_start:].index
dates_detection = date2num(dates.tolist())
if dates_detection[1]>dates_detection[2]:
    raise ValueError('Warning: data are sorted incorrectly')  # In principle, this can be easily solved with a sort function; however, other people read those data in an agreed formmat an it's important to doublecheck


# -----
#
# Analysis
#
# -----

#estimate R_eff for detection

# ----- Prepare data for analysis

cases = data_df.new_cases_resident.cumsum()
original, smoothed = prepare_cases(cases)

#convert into array for easier handling
original_array = original.values
smoothed_array = smoothed.values

# ----- R_eff estimation

R_T_MAX = 10
r_t_range = np.linspace(0, R_T_MAX, R_T_MAX*100+1)

posteriors, log_likelihood = get_posteriors(smoothed_array, dates, sigma=.15)    #optimal sigma already chosen in original Notebook

# Note that this is not the most efficient algorithm, but works fine
hdis = highest_density_interval(posteriors, p=.5)          # confidence bounds, p=50%

most_likely = posteriors.idxmax().rename('Reff-estimate')   # mean R_eff value

result = pd.concat([most_likely, hdis], axis=1)
result = result.set_index(data_df.report_date.iloc[idx_start:])
result.to_csv('output/'+today+'_Reff-estimate.csv')   # decide on a name and specify path !!!



# -----
#
# Plots
#
# -----

# ----- R_eff for residents' data

fig, ax2 = plt.subplots(figsize=(800/72,400/72))
fig.autofmt_xdate(rotation=90)
plot_reff_estimate.plot_rt_residents(result, ax2, state_name, fig)
ax2.set_title(f'Real-time effective $R_t$ for {state_name}')
ax2.xaxis.set_major_locator(mdates.WeekdayLocator())
ax2.xaxis.set_major_formatter(mdates.DateFormatter('%b%d'))

fig.savefig("output/"+today+"_Reff_residents.pdf",bbox_inches = "tight",transparent=True) # decide name and specify path !!!

