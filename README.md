# CovidReproductionNumber.jl

## Install dependencies

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

## Run the R estimators

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
