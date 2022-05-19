
include("lib/common.jl")

@assert (length(ARGS)==1) "expects a single filename argument"

df = read_one_sheet_xlsx(ARGS[1])

# check if all columns are present
required_props = [
    :report_date,
    :new_cases,
    :new_cases_resident,
]

for p in required_props
    @assert (p in propertynames(df)) "Column $p must be present in data"
end

# check if new cases are okay
for col in [:new_cases, :new_cases_resident]
    @assert all(typeof.(df[:,col]) .== Int64) "Data in $col must be integer numbers"
    @assert all(df[:,col] .>= 0) "New cases in $col must not be negative"
end

@assert all(df.new_cases .>= df.new_cases_resident) "Total cases should be greater than resident cases (data are missing?)"

# check the dates
first_report, last_report = extrema(df.report_date)

#TODO there was 28 in the python script but I got data with 24, is that right?
@assert (first_report == Date("2020-02-24")) "Reports must start at an expected date. Is the data corrupted?"

since_last_entry = Dates.today() - last_report
@assert (since_last_entry >= Day(0)) "Last entry must not be in the future!"

since_last_entry < Week(1) || @warn "Last entry is older than 1 week!"

@info "Age of the last entry is $since_last_entry"

# check date continuity
expected_dates = [first_report+Day(i) for i = 0:Day(last_report-first_report).value]
@assert expected_dates == sort(df.report_date) "Some days are missing!"

@info "Check finished OK."
