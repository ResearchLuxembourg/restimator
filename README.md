# REstimator -- estimator of R(t) for COVID-19

## Brief explanation of the indicator

and related ones (source: science.lu, "Coronavirus technical terms – explained by scientists from Luxembourg" )

### R0

the “basic reproduction number” at the beginning of epidemic (time "zero"). It represents the average number of cases each infected person will likely cause if no action is taken and the whole population is susceptible. It is disease and variant-specific.

### R_t

as the epidemic evolves and measures are taken, the “reproduction number” might vary in time. Likewise, from the very first value R0, the index evolves in time, tracking the infectious curve. In this regard, R0 is an upper value for R_t.

### R_eff

the “effective reproduction number”, signifying the average number of cases each infected person will likely cause during the epidemic. It evolves in time like R_t, but is scaled according to the true number of susceptible people (while R_t assumes that 100% of the population is susceptible).

R_eff is used as an epidemic “thermometer”: R_eff<1 indicates a decreasing curve of daily infections (sub-linear increase of cumulative cases), R_eff=1 indicates a stable curve (linear increase of cumulative cases), R_eff>1 indicates a growing daily curve (exponential increase of cumulative cases). The higher R_eff, the more pronounced the exponential growth.

## Input

Excel (.xlsx) file with at least the following columns, ordered chronologically (closest to farthest date):

- report_date
- new_cases
- new_cases_resident

## Output

- R_eff, calculated for each day data are available (reported as .csv file and pdf plot)
- R(t), calculated for each day data are available (reported as .csv file)

## How-to

### Automated way

If you place your `.xlsx` input into directory `input`, everything can be run
just by executing `./run_pipeline.sh`.

This requires a Docker image `researchluxembourg/restimator` pulled or built --
you can pull it from the github packages, or build manually from this
repository.

### Install dependencies

You need `julia` installed, preferably a version higher than 1.6.

You can run Julia in the directory of CovidReproductionNumber.jl, using the project environment as:

```sh
cd CovidReproductionNumber.jl
julia --project=.
```

After that, type
```julia
Pkg.instantiate()
```

This should install the necessary Julia packages.

### Run the R estimators

We assume your input is placed in `input/data-20220103.xlsx`. The input excel
file must contain a single sheet with several correctly marked columns. You can
check the suitability of the input file using script `check_input.jl`, as
follows:

```sh
julia --project=. check_input.jl input/data-20220103.xlsx
```

You may get an output like this (or eventually an error with a description of the problem):

```
┌ Warning: Last entry is older than 1 week!
└ @ Main ~/work/CovidReproductionNumber.jl/check_input.jl:36
[ Info: Age of the last entry is 136 days
[ Info: Check finished OK.
```

Reff and Rt analyses may be run as follows:

```sh
julia --project=. estimate_r_eff.jl input/data-20220103.xlsx
julia --project=. estimate_r_t.jl input/data-20220103.xlsx
```

The output should be generated into corresponding files:
```
input/Reff_estimate_data-20220103.xlsx.csv
input/Rt_estimate_data-20220103.xlsx.csv
```

## Credits and contacts

- Research Luxembourg COVID-19 Taskforce WP6, in the person of Alexander Skupin: supervision and coordination. Contact: alexander.skupin@uni.lu.
- [Daniele Proverbio](https://github.com/daniele-proverbio): R_eff code development, website ideation and content creation
- [Atte Aalto](https://github.com/AtteAalto): R_t code development
- [Laurent Heirendt](https://github.com/laurentheirendt), [Jacek Leboida](https://github.com/jLebioda), [Christophe Trefois](https://github.com/trefex) and the LCSB R3 team: docker and website development and deployment

   <img src="logos/unilu.svg" alt="logos" height="100"/>  &nbsp; &nbsp;    <img src="logos/lcsb.svg" alt="logos" height="100"/> &nbsp; &nbsp; <img src="logos/res_lux.png" alt="logos" height="100"/>  


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
