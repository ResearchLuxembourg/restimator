# -----
#
# Check the input file
#
# -----

import pandas as pd
import os.path
import datetime as DT
from datetime import datetime
import glob

def checkfile(inputfile):

    # check that file exists
    if not os.path.isfile(inputfile):
        raise ValueError('Error: file does not exist')

    # check it's and Excel file
    if os.path.splitext(inputfile)[1] != ".xlsx":
        raise ValueError('Error: incorrect input file format. Expected Excel .xlsx, received other')

    # check that the necessary columns are present
    full_data = pd.read_excel(inputfile).iloc[::-1].reset_index()
    if 'report_date' not in full_data.columns:
        raise ValueError('Error: Expected column "report_date" not found')
    if 'new_cases' not in full_data.columns:
        raise ValueError('Error: Expected column "new_cases" not found')
    if 'new_cases_resident' not in full_data.columns:
        raise ValueError('Error: Expected column "new_cases_resident" not found')

    # check that new cases are actually positive integer numbers
    for i in range(len(full_data["new_cases"])):
        if type(full_data['new_cases'].iloc[i]) != str and type(full_data['new_cases_resident'].iloc[i]) != str:
            if full_data['new_cases'].iloc[i] < 0 or full_data['new_cases_resident'].iloc[i] < 0:
                raise ValueError('Warning: invalid data entry detected (negative number) at line '+str(len(full_data["new_cases"])- i))
        else:
            raise ValueError('Error: invalid data entry detected (not a number) at line ' + str(len(full_data["new_cases"])- i))

    # check consistency of reported numbers
    for daily_data in range(len(full_data["new_cases"])):
        if full_data['new_cases'].iloc[daily_data] < full_data['new_cases_resident'].iloc[daily_data]:
            raise ValueError('Error: total cases less than resident cases: are there missing data?')

    # check that the last datapoint is present
    expected_latest_date_reporting = datetime.now() - DT.timedelta(days=1)
    if not full_data['report_date'].iloc[-1].strftime('%Y%m%d') == expected_latest_date_reporting.strftime('%Y%m%d'):
        raise ValueError('Error: missing data point of today')

    # check that past data are present, from 2020-02-28
    expected_first_date_reporting = '20200228'
    start = 0
    for i in range(len(full_data["new_cases"])):
        if full_data['report_date'].iloc[i].strftime('%Y%m%d') == expected_first_date_reporting:
            start = 1
    if start == 0:
        raise ValueError('Error: data series not complete from beginning (2022-02-28)')

input_dir = './input'
standard_name = input_dir + '/input-data.xlsx'
xlsxFiles = glob.glob(input_dir + '/*.xlsx')

if len(xlsxFiles) > 1:
    raise ValueError('There are several input files.')
else:
    inputfile = xlsxFiles[0]
    # alert that the date in the file name is not the one of today
    expected_name = 'clinical_monitoring_'+str(datetime.today().strftime('%Y%m%d') )+'_cleaned_case_and_hospital_data'
    if not os.path.splitext(os.path.basename(inputfile))[0] == expected_name:
        print("Warning: The date in the uploaded file name is not correct and the name is not according to the de facto standard.")

    # rename the input file
    if inputfile != standard_name:
        old_name = inputfile
        new_name = standard_name
        os.rename(old_name, new_name)
        print("Warning: Input file renamed (original file name: " + inputfile + ")")
    else:
        print("Warning: Input already with standard name.")

# call checkfile function
checkfile("input/input-data.xlsx")