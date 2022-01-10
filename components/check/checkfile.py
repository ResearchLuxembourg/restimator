# -----
#
# Check the input file
#
# -----

import pandas as pd
import os.path
from datetime import date

def checkfile(inputfile, idx_start):
    
    check = True
    
    # check that file exists
    if not os.path.isfile(inputfile):
        check = False
        raise ValueError('Error: file does not exist')
  
    # check it's and Excel file
    if os.path.splitext(inputfile)[1] != ".xlsx":
        check = False
        raise ValueError('Error: incorrect input file format. Expected Excel .xlsx, received other')
        
    # check that the name is correct
    expected_name = 'clinical_monitoring_'+str(date.today())+'_cleaned_case_and_hospital_data'
    if os.path.splitext(os.path.basename(inputfile))[0] != expected_name:
        check = False
        raise ValueError('Error: file name incorrect. Expected "clinical_monitoring_DATEOFTODAY_cleaned_case_and_hospital_data.xlsx"') 
        
    # check that the necessary columns are present
    full_data = pd.read_excel(inputfile).iloc[::-1].reset_index()
    if 'report_date' not in full_data.columns:
        check = False
        raise ValueError('Error: Expected column "report_date" not found')         
    if 'new_cases' not in full_data.columns:
        check = False
        raise ValueError('Error: Expected column "new_cases" not found')        
    if 'new_cases_resident' not in full_data.columns:
        check = False
        raise ValueError('Error: Expected column "new_cases_resident" not found') 
    
    # check that new cases are actually positive numbers
    if full_data['new_cases'].iloc[idx_start:].all().isnumeric() and full_data['new_cases_resident'].iloc[idx_start:].all().isnumeric():
        if full_data['new_cases'].iloc[idx_start:].any() < 0 or full_data['new_cases_resident'].iloc[idx_start:].any() < 0:
            check = False
            raise ValueError('Warning: invalid data entry detected (negative number)') 
    else:
        check = False
        raise ValueError('Error: invali data entry detected (not a number)') 
        
    # check consistency of reported numbers
    for daily_data in range(len(full_data["new_cases"])):
        if full_data['new_cases'].iloc[daily_data] < full_data['new_cases_resident'].iloc[daily_data]:
            check = False
            raise ValueError('Warning: total cases less than resident cases: are there missing data?') 

    # rename file 
    old_name = inputfile
    new_name = 'input/input-data.xlsx'
    os.rename(old_name, new_name)
    
    return check
        


