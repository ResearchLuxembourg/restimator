
include("lib/common.jl")


#
# Initial checks on what the input file looks like
#

# Single input provided
@assert (length(ARGS) == 1) "Error: Expects a single filename argument"

# Input file exists
@assert (isfile(ARGS[1])) "Error: File does not exists"

# Input file is Excel 
@assert (split(ARGS[1], ".")[end] == "xlsx") "Error: Incorrect input file format. Expected Excel .xlsx, received another"

# Check file name
today = Dates.today()
today_str = Dates.format(today, "yyyymmdd")
current_name = basename(ARGS[1])
expected_name = "clinical_monitoring_$(today_str)_cleaned_case_and_hospital_data.xlsx"
current_name == expected_name || @warn "Either the date in the uploaded file name is not correct or the name is not following the accepted systematization (got '$current_name', should be '$expected_name')."


#
# Check basic properties
#

# Read the input file
df = read_one_sheet_xlsx(ARGS[1])

# Check if all columns are present
required_props = [:report_date, :new_cases, :new_cases_resident]

for p in required_props
    @assert (p in propertynames(df)) "Error: Column $p must be present in data"
end

# check if new cases are okay
for col in [:new_cases, :new_cases_resident]
    @assert all(typeof.(df[:, col]) .== Int64) "Error: Data in $col must be integer numbers"
    @assert all(df[:, col] .>= 0) "Error: New cases in $col must not be negative"
end

@assert all(df.new_cases .>= df.new_cases_resident) "Error: Total cases should be greater than resident cases: are there missing data?"

#
# Check the dates in the file
#

first_report, last_report = extrema(df.report_date)
expected_first_report = Date("2020-02-24")

# Check that the first date considered in database is consistent 
#@assert (first_report == Date("2020-02-24")) "Warning: Reports should start from 2020-02-24. Is the data corrupted?"
# ...we replaced this with "dates outside" check below.

# Check presence of last datapoint
last_entry = today - Day(1)
@assert last_report == last_entry "Error: Missing data point of today (expected $last_entry, was: $last_report)"

# This served as a warning but it now completely deprecated by the above.
#since_last_entry = today - last_report
#@assert (since_last_entry < Week(1)) "Error: Last entry is older than 1 week"

# Check date continuity
date_counts =
    Dict([(expected_first_report + Day(i) => 0) for i = 0:Day(last_entry - expected_first_report).value])
dates_outside = Set{Date}()
for d in df.report_date
    if haskey(date_counts, d)
        date_counts[d] += 1
    else
        push!(dates_outside, d)
    end
end
dates_outside = collect(dates_outside)
dates_missing = [d for (d, v) = date_counts if v == 0]
dates_duplicate = [d for (d, v) = date_counts if v > 1]

function clamp!(x)
    length(x) <= 5 || resize!(x, 5)
end

clamp!(dates_outside)
clamp!(dates_missing)
clamp!(dates_duplicate)

printdates(x) = join(x, ", ")

@assert isempty(dates_outside) "Error: dates outside the expected interval: $(printdates(dates_outside))"
@assert isempty(dates_missing) "Error: expected dates missing: $(printdates(dates_missing))"
@assert isempty(dates_duplicate) "Error: duplicate entries for dates: $(printdates(dates_duplicate))"

@info "Check finished OK."
