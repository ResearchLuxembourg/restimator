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

- Missing daily data: the program needs a data entry for each day.
- Typos in the input file (in particular, relate to the input columns labels).
- Flipped data reporting order: make sure that line 1 contains the most recent data value, line 2 the one from yesterday, and so on until the farthest one. The order should not be inverted.
- Retrospectively changed data. To provide consistent results, the program needs initial conditions: the data history should not be altered.

[add additional info depending on the FAQ collected during daily practice]

## How to run the pipeline

The pipeline can be run using any of the following `make` commands:

| Command       | Purpose                                               |
|---------------|-------------------------------------------------------|
| make build    | build the pipeline                                    |
| make run      | run the pipeline                                      |
| make reff     | run the partial pipeline to generate `R_eff` (Python) |
| make rt       | run the partial pipeline to generate `R_t` (Matlab)   |
| make clean    | clean generated assets                                |
| make all      | clean first, then build and run the full pipeline     |

Alternatively, if [Docker Compose](https://docs.docker.com/compose/) is available, you can run the pipeline using:

```bash
docker compose up
```

## Credits and contacts

- Research Luxembourg COVID-19 Taskforce WP6, in the person of Alexander Skupin: supervision and coordination. Contact: alexander.skupin@uni.lu.
- Daniele Proverbio: R_eff code development, website ideation and content creation
- [Atte if we include his code]
- [credits to R3 team for website development and deployment]
- [UniLu/LCSB: website hosting and maintenance?]

For raised warnings and errors, check the readme section first, for basic troubleshooting.
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

