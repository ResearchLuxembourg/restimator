
using XLSX, DataFrames, Dates, CSV

macro throw(t, args...)
    esc(:(throw($t($(args...)))))
end

function read_one_sheet_xlsx(fn)
    xls = XLSX.readxlsx(fn)

    sheets = XLSX.sheetnames(xls)

    length(sheets)== 1 || @throw DomainError length(sheets) "unexpected number of sheets"

    return DataFrame(XLSX.gettable(xls[sheets[1]])...)
end

normalize!(x; sum_args...) = x ./= sum(x; sum_args...)
