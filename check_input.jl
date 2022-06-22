
include("lib/common.jl")


## Initial checks on input file
# Single input provided
@assert (length(ARGS)==1) "Error: Expects a single filename argument"

# Input file exists
@assert (isfile(ARGS[1])) "Error: File does not exists"

# Input file is Excel 
@assert (split(ARGS[1], ".")[end] == "xlsx") "Error: Incorrect input file format. Expected Excel .xlsx, received another"

# Check file name
today = Dates.format(Dates.today(), "yyyymmdd")
current_name = basename(ARGS[1])
expected_name = string("clinical_monitoring_",today,"_cleaned_case_and_hospital_data.xlsx")
@assert (current_name == expected_name) "Warning: The date in the uploaded file name is not correct and the name is not according to the de facto standard (is '$current_name', should be '$expected_name')."

# Rename file  
standard_name = "/input-data.xlsx"
if standard_name != basename(ARGS[1])
    mv(input, string(dirname(ARGS[1]),standard_name))
end


## Read input file
df = read_one_sheet_xlsx(string(dirname(ARGS[1]),standard_name))

## check if all columns are present
required_props = [
    :report_date,
    :new_cases,
    :new_cases_resident,
]

for p in required_props
    @assert (p in propertynames(df)) "Error: Column $p must be present in data"
end

## check if new cases are okay
for col in [:new_cases, :new_cases_resident]
    @assert all(typeof.(df[:,col]) .== Int64) "Error: Data in $col must be integer numbers"
    @assert all(df[:,col] .>= 0) "Error: New cases in $col must not be negative"
end

@assert all(df.new_cases .>= df.new_cases_resident) "Error: Total cases should be greater than resident cases: are there missing data?"

## check the dates
first_report, last_report = extrema(df.report_date)

# Check that the first date considered in database is consistent 
@assert (first_report == Date("2020-02-24")) "Warning: Reports should start from 2020-02-24. Is the data corrupted?"

# Check presence of last datapoint
last_entry = Dates.today() - Day(1)
@assert (last_report == last_entry) "Error: Missing data point of today (expected $last_entry, was: $last_report)"

since_last_entry = Dates.today() - last_report 
@assert (since_last_entry < Week(1)) "Warning: Last entry is older than 1 week"

# check date continuity
expected_dates = [first_report+Day(i) for i = 0:Day(last_report-first_report).value]
@assert expected_dates == sort(df.report_date) "Error: Data series not complete from beginning"

@info "Check finished OK."
