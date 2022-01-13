# Estimator for COVID-19 R(t)

## Input

Excel (.xlsx) file with at least the following columns, ordered chronologically (closest to farthest date):

- report_date
- new_cases
- new_cases_resident

## Output

- R_eff, calculated for each day data are available (reported as .csv file and pdf plot)
- R(t), calculated for each day data are available (reported as .csv file)

## Brief explanation of the indicator

and related ones (source: science.lu, "Coronavirus technical terms – explained by scientists from Luxembourg" )

### R0

the “basic reproduction number” at the beginning of epidemic (time "zero"). It represents the average number of cases each infected person will likely cause if no action is taken and the whole population is susceptible. It is disease and variant-specific.

### R_t

as the epidemic evolves and measures are taken, the “reproduction number” might vary in time. Likewise, from the very first value R0, the index evolves in time, tracking the infectious curve. In this regard, R0 is an upper value for R_t.

### R_eff

the “effective reproduction number”, signifying the average number of cases each infected person will likely cause during the epidemic. It evolves in time like R_t, but is scaled according to the true number of susceptible people (while R_t assumes that 100% of the population is susceptible).

R_eff is used as an epidemic “thermometer”: R_eff<1 indicates a decreasing curve of daily infections (sub-linear increase of cumulative cases), R_eff=1 indicates a stable curve (linear increase of cumulative cases), R_eff>1 indicates a growing daily curve (exponential increase of cumulative cases). The higher R_eff, the more pronounced the exponential growth.

## Estimation of R_eff and R_t

### R_eff

R_eff is estimated from the data following a Bayesian inference algorithm. In a nutshell, it estimates the most likely R_eff that could cause k cases today, given k' cases in the past.

The algorithm returns a most likely value and its associated 50% credible interval (where there is the highest confidence that the true value might lie).

The present implementation builds upon a former implementation from the [rtcovidlive project](https://github.com/rtcovidlive/).

### R_t

R_t is estimated by running a Kalmar filter estimator with a nonlinear SIR-based model as kernel. The code was entirely built in-house.

## Potential sources of code errors
The pipeline might raise errors in case the initial check on data quality is not satisfied. For basic troubleshooting, refer to this section.

- File does not exist: error in loading the input file.
- Incorrect file format: expected format is Excel .xlsx.
- Incorrect file name: the _de facto_ agreed file naming is "clinical_monitoring_'+DATEOFTODAY[yyyymmdd]+_cleaned_case_and_hospital_data".
- Missing daily data: the program needs a data entry for each day, as a positive integer.
- Typos in the input file (in particular, related to the input columns labels) or missing input column: expected input columns are "report date", "new_cases", "new_cases_resident".
- Inconsistency: daily cases for residents should be less or equal to total new daily cases.
- Retrospectively changed data. To provide consistent results, the program needs initial conditions: the data history should not be altered, starting from 2020-02-28.
- Last datapoint missing (relative to the latest detection date of 'yesterday').


## How to run the pipeline


### MATLAB license

The license for MATLAB must be downloaded from [Mathworks](https://mathworks.com) after activation of the hostid of the container.

The hostid is displayed after running the pipeline for the first time (see instructions below).

Once the license (`license.lic`) is available locally, the following environment variable as to be set:

```bash
export MATLAB_LICENSE=<location of license file>
```

Then, the pipeline can be run. Please note that each time the container is built, the hostid changes, and so is the license.
Also, the hostid may differ between different builts of the container.

### Docker Compose (preferred)

If [Docker Compose](https://docs.docker.com/compose/) is available, you can run the `rt` pipeline using:

```bash
docker compose run rt
```

Similarly, you can run the `reff` pipeline using:

```bash
docker compose run reff
```

The full pipeline can be run using:

```bash
docker compose up
```

### Makefile

The pipeline can be run using any of the following `make` commands:

| Command         | Purpose                                               |
|-----------------|-------------------------------------------------------|
| make all        | clean first, then build and run the full pipeline     |
| make build      | build the pipeline                                    |
| make build_reff | build the `R_eff` pipeline                            |
| make build_rt   | build the `R_t` pipeline                              |
| make run        | run the pipeline                                      |
| make reff       | run the partial pipeline to generate `R_eff` (Python) |
| make rt         | run the partial pipeline to generate `R_t` (Matlab)   |
| make clean      | clean generated assets                                |

## Credits and contacts

- Research Luxembourg COVID-19 Taskforce WP6, in the person of Alexander Skupin: supervision and coordination. Contact: alexander.skupin@uni.lu.
- [Daniele Proverbio](https://github.com/daniele-proverbio): R_eff code development, website ideation and content creation
- [Atte Aalto](https://github.com/AtteAalto): R_t code development
- [Laurent Heirendt](https://github.com/laurentheirendt), [Jacek Leboida](https://github.com/jLebioda), [Christophe Trefois](https://github.com/trefex) and the LCSB R3 team: docker and website development and deployment

   <img src="docs/logos.png" alt="logos" width="350"/>  


For basic troubleshooting of raised warnings and errors, check the readme section first.
If the problem persist, please contact the developers.

> Copyright 2020-2022 Luxembourg Centre for Systems Biomedicine
>
> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
> http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.
