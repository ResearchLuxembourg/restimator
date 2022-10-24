
include("lib/common.jl")

@assert (length(ARGS) == 1) "expects a single filename argument"

filename = ARGS[1]
df = read_one_sheet_xlsx(filename)

start_date = Date("2020-02-24")
discard_dates = 22

# collect data into a vector
@assert start_date <= minimum(df.report_date)
cases_raw = fill(0, Day(maximum(df.report_date) - start_date).value + 1)
for (date, new_cases) in zip(df.report_date, df.new_cases_resident)
    cases_raw[1+Day(date - start_date).value] += new_cases
end

# prepare smoothed cases
using RollingFunctions
smooth_days = 7
cases_smoothed_all = [
    fill(0, smooth_days - 1)
    rollmean(cases_raw, smooth_days)
]

# discard uninteresting data
cases_smoothed = cases_smoothed_all[begin+discard_dates:end]

# prepare data for calculating posteriors
rt_max = 10
rt_samples = rt_max * 100 + 1
rt_range = LinRange(0, rt_max, rt_samples)

using Random, Distributions
Random.seed!(12345)
gamma = 1 ./ (4 .+ 0.2 .* randn(rt_samples))
lam = exp.(gamma .* (rt_range .- 1)) * cases_smoothed[begin:end-1]'
likelihoods = pdf.(Poisson.(lam), round.(cases_smoothed[begin+1:end])')
process_matrix = pdf.(Normal.(rt_range, 0.15), rt_range') #= sigma =#
normalize!(process_matrix, dims = 2)

prior0 = ones(rt_samples)
normalize!(prior0)

posteriors = Matrix{Float64}(undef, rt_samples, length(cases_smoothed))
posteriors[:, 1] = prior0
log_likelihood = 0.0

for current_day = 2:length(cases_smoothed)
    previous_day = current_day - 1
    current_prior = process_matrix * posteriors[:, previous_day]
    numerator = likelihoods[:, previous_day] .* current_prior
    denominator = sum(numerator)
    posteriors[:, current_day] .= numerator ./ denominator
    global log_likelihood += log(denominator)
end

shortest_partial_sum_range(series, s) =
    let sums = cumsum(series)
        argmin(
            (lo, hi)::Tuple -> hi - lo,
            [
                (lo, hi) for lo in eachindex(sums) for
                hi = lo:length(sums) if sums[hi] - (lo > 1 ? sums[lo-1] : 0) >= s
            ],
        )
    end

ranges = [shortest_partial_sum_range(i, 0.5) for i in eachcol(posteriors)]
maxima = findmax.(eachcol(posteriors))

results = rt_max .* [map(last, maxima) map(first, ranges) map(last, ranges)] ./ rt_samples
dates = (start_date + Day(discard_dates)) .+ Day.(eachindex(ranges))

x = DataFrame(
    date = dates,
    Reff_estimate = round.(results[:, 1], digits = 2),
    Reff_50_lo = round.(results[:, 2], digits = 2),
    Reff_50_hi = round.(results[:, 3], digits = 2),
)

CSV.write(outfile("Reff_estimate", "csv"), x)

# Plot Reff for resident's data

using CairoMakie, PlotUtils

f = Figure()
ax = Axis(f[1, 1], title = "Real-time effective Rt for LU")

ticks = filter(d -> day(d) == 1, x.date)
poss = datetime2rata.(x.date)
ax.xticks[] = (datetime2rata.(ticks), Dates.format.(ticks, "yyyy-mm"))
ax.xticklabelrotation = π / 3
ax.xticklabelsize = 12

ylims!(0, maximum(x.Reff_estimate) * 1.04)
band!(poss, x.Reff_50_lo, x.Reff_50_hi; color = "#cccccc")
lines!(poss, x.Reff_estimate; color = "black")
scatter!(
    poss,
    x.Reff_estimate;
    color = x.Reff_estimate,
    markersize = 7,
    colormap = :RdBu,
    colorrange = (2, 0),
    strokewidth = 0.5,
)

save(outfile("Reff_residents", "pdf"), f)
