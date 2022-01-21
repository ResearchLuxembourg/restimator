# -----
#
# Check the input file
#
# -----

import datetime
import glob
import os.path

import pandas as pd


EXPECTED_FIRST_DATE_REPORTING = '20200228'
INPUT_DIR = './input'


# Utils ------------------------------------------------------------------------

def load_excel_to_data_frame(path: str) -> pd.DataFrame:
    return pd.read_excel(path).iloc[::-1].reset_index()

def rename_file_to_standard_name(path_old: str, path_new: str) -> None:
    if path_old != path_new:
        old_name = path_old
        new_name = path_new
        os.rename(old_name, new_name)
        print(f"Warning: Input file renamed (original file name: {input_file} to: {new_name})")
    else:
        print("OK: Input already with standard name.")

# Checks -----------------------------------------------------------------------

def check_if_file_exists(path: str) -> None:
    if not os.path.isfile(path):
        raise ValueError(f'Error: file does not exist at "{path}"')

def check_if_file_is_excel(path: str) -> None:
    extension = os.path.splitext(path)[1]
    if extension != ".xlsx":
        raise ValueError(f'Error: incorrect input file format. Expected Excel .xlsx, received other ({extension})')

def check_if_columns_are_present(full_data: pd.DataFrame) -> None:
    if 'report_date' not in full_data.columns:
        raise ValueError('Error: Expected column "report_date" not found')
    if 'new_cases' not in full_data.columns:
        raise ValueError('Error: Expected column "new_cases" not found')
    if 'new_cases_resident' not in full_data.columns:
        raise ValueError('Error: Expected column "new_cases_resident" not found')

def check_new_cases(full_data: pd.DataFrame) -> None:
    for i in range(len(full_data["new_cases"])):
        if type(full_data['new_cases'].iloc[i]) != str and type(full_data['new_cases_resident'].iloc[i]) != str:
            if full_data['new_cases'].iloc[i] < 0 or full_data['new_cases_resident'].iloc[i] < 0:
                raise ValueError('Warning: invalid data entry detected (negative number) at line '+str(len(full_data["new_cases"])- i))
        else:
            raise ValueError('Error: invalid data entry detected (not a number) at line ' + str(len(full_data["new_cases"])- i))

def check_consistency_of_reported_numbers(full_data: pd.DataFrame) -> None:
    for daily_data in range(len(full_data["new_cases"])):
        if full_data['new_cases'].iloc[daily_data] < full_data['new_cases_resident'].iloc[daily_data]:
            raise ValueError('Error: total cases less than resident cases: are there missing data?')

def check_presence_of_last_datapoint(full_data: pd.DataFrame) -> None:
    expected_latest_date_reporting = datetime.datetime.now() - datetime.timedelta(days=1)
    reported_date = full_data['report_date'].iloc[-1].strftime('%Y%m%d')
    expected_date = expected_latest_date_reporting.strftime('%Y%m%d')
    if not reported_date == expected_date:
        raise ValueError(f'Error: missing data point of today (expected {expected_date}, was: {reported_date})')

def check_presence_of_past_data(full_data: pd.DataFrame) -> None:
    start = 0
    for i in range(len(full_data["new_cases"])):
        if full_data['report_date'].iloc[i].strftime('%Y%m%d') == EXPECTED_FIRST_DATE_REPORTING:
            start = 1
    if start == 0:
        the_date = EXPECTED_FIRST_DATE_REPORTING[:4] + "-" + EXPECTED_FIRST_DATE_REPORTING[4:6] + "-" + EXPECTED_FIRST_DATE_REPORTING[6:8]
        raise ValueError(f'Error: data series not complete from beginning ({the_date})')

def check_filename(path: str) -> None:
    # Alert that the date in the file name is not the one of today
    today = datetime.datetime.today().strftime('%Y%m%d')
    expected_name = f'clinical_monitoring_{today}_cleaned_case_and_hospital_data'
    factual_name = os.path.splitext(os.path.basename(input_file))[0]
    if not factual_name == expected_name:
        print(f"Warning: The date in the uploaded file name is not correct and the name is not according to the de facto standard (is '{factual_name}', should be '{expected_name}').")

# All checks ---------------------------------------------------------------------

def run_all_checks_over_the_file(input_file):
    check_if_file_exists(input_file)
    check_if_file_is_excel(input_file)

    full_data = load_excel_to_data_frame(input_file)
    check_if_columns_are_present(full_data)
    check_new_cases(full_data)
    check_consistency_of_reported_numbers(full_data)
    check_presence_of_last_datapoint(full_data)
    check_presence_of_past_data(full_data)


if __name__ == "__main__":
    standard_name = INPUT_DIR + '/input-data.xlsx'
    xlsxFiles = glob.glob(INPUT_DIR + '/*.xlsx')

    if len(xlsxFiles) > 1:
        raise ValueError('There are several input files.')
    else:
        input_file = xlsxFiles[0]
    
    check_filename(input_file)
    rename_file_to_standard_name(input_file, standard_name)
    run_all_checks_over_the_file("input/input-data.xlsx")