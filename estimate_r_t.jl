
include("lib/common.jl")

using Statistics

@assert (length(ARGS) == 1) "expects a single filename argument"

filename = ARGS[1]
df = read_one_sheet_xlsx(filename)

start_date = Date("2020-02-28")

df = df[sortperm(df.report_date), :]
df = df[df.report_date.>=start_date, :]

Y = Int.(df.new_cases_resident)
dates = df.report_date

# apply quirks
quirks = [
    ("2020-07-14", +40),
    ("2020-07-15", -40),
    ("2020-07-27", +50),
    ("2020-07-28", -50),
    ("2021-01-18", +40),
    ("2021-01-19", -40),
    ("2021-03-27", -20),
    ("2021-03-28", +20),
    ("2021-11-01", +120),
    ("2021-11-02", +120),
    ("2021-11-03", -240),
]

Y[indexin(Date.(first.(quirks)), dates)] .+= last.(quirks)

# compensate for weekday variability
C_sun = 0.3
C_sat = 0.6
weekday_effects = [1, 1, 1, 1, 1, C_sat, C_sun]

rate_in_week(date) =
    Y_at[date] / mean(getindex.(Ref(Y_at), date .+ Day.(1:7) .- Dates.dayofweek(date)))

Y_at = Dict(dates .=> Y) # lookup
C = [
    if date < Date("2020-06-01")
        weekday_effects[Dates.dayofweek(date)] / 3.0 #dark number 1
    else
        mean(rate_in_week.(date .- Week.(1:4))) / 1.5 #dark number 2
    end for date in df.report_date
]

# apply C quirks
extra_sundays = [
    "2020-04-13",
    "2020-05-21",
    "2020-06-01",
    "2020-06-23",
    "2020-12-25",
    "2020-12-26",
    "2021-01-02",
    "2021-05-13",
    "2021-06-23",
    "2021-12-25",
    "2021-12-26",
    "2021-12-27",
    "2022-01-01",
    "2022-01-02",
    "2022-04-18",
    "2022-05-26",
    "2022-06-06",
    "2022-06-23",
    "2022-11-01",
    "2022-12-25",
    "2022-12-26",
    "2022-12-27",
]

fix_C(date_string, val) = begin
    idx = first(indexin([Date(date_string)], dates))
    isnothing(idx) || (C[idx] = val)
end

fix_C.(extra_sundays, C_sun)

fix_C("2021-05-01", C_sat)

fix_C("2020-12-27", 1.21 * C_sun - 0.21)
fix_C("2021-01-01", 1.21 * C_sun - 0.21)
fix_C("2021-05-24", 1.21 * C_sun - 0.21)

fix_C("2021-04-05", 1.3 * C_sun - 0.3)

# simulation parameters
μ = 0.25 # I -> R transition rate
β = μ / 2 # S -> I initial rate
β_var = 0.15^2

N = 500_000 # effective population
initial_infected = 100
initial_infected_var = 250

# measurement error variance
Ysm = [
    mean(Y[begin:begin+1])
    (Y[begin:end-2] + 2 * Y[begin+1:end-1] + Y[begin+2:end]) ./ 4
    mean(Y[end-1:end])
]

R = (Ysm ./ 25) .^ 2 .* (C[1] ./ C) .^ 2 .+ 1

# model error term to scale up the Langevin covariance
CC = 4^2

# number of detected cases today depends linearly on the true number of new cases today
C0 = [-1, 0, 1, 0]

# output vectors
Yest = zeros(length(Y))
β_err = zeros(length(Y))

# 4 state variables: S(t), I(t), S(t-1), β(t)
X = zeros(4, length(Y) + 1)
X[:, 1] = [N - initial_infected, initial_infected, N - initial_infected + 1, β]

# initial state error covariance
P = [
    initial_infected_var*[1 -1 1; -1 1 -1; 1 -1 1] zeros(3)
    zeros(1, 3) β_var
]

# run a kalman filter
@time for D in eachindex(Y)
    prev = view(X, :, D)
    current = view(X, :, D + 1)

    # variance of β change
    Qβ = D <= 30 ? 0.05^2 : 0.005^2

    # predict this day
    predicted_new = prev[4] * prev[2] * prev[1] / N
    predicted = [
        prev[1] - predicted_new
        (prev[2] + predicted_new) / (1 + μ)
        prev[1]
        prev[4]
    ]

    # compute the jacobian of the dynamics function
    Jf = [
        1-prev[4]*prev[2]/N -prev[4]*prev[1]/N 0 -prev[1]*prev[2]/N
        prev[4]*prev[2]/N (1+prev[4]*prev[1]/N)/(1+μ) 0 prev[1]*prev[2]/N
        1 0 0 0
        0 0 0 1
    ]

    # covariance of the process noise, assuming Langevin-type stochastics
    Q = [
        CC*prev[4]*prev[1]*prev[2]/N -CC*prev[4]*prev[1]*prev[2]/N 0 0
        -CC*prev[4]*prev[1]*prev[2]/N CC*(prev[4]*prev[1]*prev[2]/N+μ*prev[2]) 0 0
        0 0 0 0
        0 0 0 Qβ
    ]

    # prediction error covariance
    Ppred = Jf * P * Jf' + Q

    # measurement covariance
    S = C[D]^2 .* (C0' * Ppred * C0) + R[D]

    # output the predicted number of daily new cases
    Yest[D] = C[D] * C0' * predicted

    # kalman update step
    current .= predicted + (Ppred .* C[D]) * C0 * (Y[D] - Yest[D]) ./ S

    # update the covariance
    P .= Ppred - C[D]^2 / S * Ppred * C0 * C0' * Ppred

    # output the predicted variance of β-estimate
    β_err[D] = P[4, 4]
end

CSV.write(
    joinpath(dirname(filename), "Rt_estimate_$(basename(filename)).csv"),
    DataFrame(
        date = dates,
        Rt_estimate = X[4, begin+1:end] ./ μ,
        standard_deviation = sqrt.(β_err) ./ μ,
    )[
        19:end,
        :,
    ],
)
