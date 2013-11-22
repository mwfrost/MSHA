

import pandas as pd
import numpy as np
import os

os.chdir('/Users/mfrost/Code/MSHA')

mines = pd.read_table('data/msha_source/Mines.txt', sep='|' , parse_dates=['CURRENT_CONTROLLER_BEGIN_DT'])

mines_index = mines.set_index(['STATE','MINE_ID','CURRENT_MINE_STATUS','CURRENT_STATUS_DT','CURRENT_CONTROLLER_ID','CURRENT_CONTROLLER_NAME','CURRENT_OPERATOR_ID','CURRENT_OPERATOR_NAME'])


accidents = pd.read_table('data/msha_source/Accidents.txt', sep='|',parse_dates=['ACCIDENT_DT','INVEST_BEGIN_DT'])

accidents_index = accidents.set_index(['MINE_ID','CAL_YR','CAL_QTR','ACCIDENT_DT','CONTROLLER_ID','CONTROLLER_NAME','OPERATOR_ID','OPERATOR_NAME'])



inspections = pd.read_table('data/msha_source/Inspections.txt', sep='|', parse_dates=['INSPECTION_BEGIN_DT','INSPECTION_END_DT'])
inspections.reindex()

violations = pd.read_table('data/msha_source/Violations.txt', sep='|', parse_dates=['VIOLATION_ISSUE_DT','VIOLATION_OCCUR_DT','INSPECTION_BEGIN_DT','INSPECTION_END_DT','CONTESTED_DT'])
violations.reindex()

# example of the pandas data frame syntax:
accidents.loc[1:10,['MINE_ID','ACCIDENT_DT']]

# fill non-accident dates
accidents.resample("1D", fill_method="0")





wv_mine_ids = mines['MINE_ID'][mines['BOM_STATE_CD'] == 46]
wv_mines = mines[:][mines['BOM_STATE_CD'] == 46]
wv_mines.to_csv('data/wv_mines.csv',index='FALSE')

wv_violations = violations[:][violations['MINE_ID'].isin(wv_mine_ids)]
wv_violations.to_csv('data/wv_violations.csv',index='FALSE')

wv_inspections = inspections[:][inspections['MINE_ID'].isin(wv_mine_ids)]
wv_inspections.to_csv('data/wv_inspections.csv',index='FALSE')

wv_accidents = accidents[:][accidents['MINE_ID'].isin(wv_mine_ids)]
wv_accidents.to_csv('data/wv_accidents.csv',index='FALSE')


# Aggregation tasks:
# - build a list of operating days for each mine
# - given a mine, a date, and a trailing window, return the number of violations, 
#   accidents, fatalities, and inspections that the window contains.
# - integrate available production data


# Operating days per mine
# and trailing event counts can be done together now?

#  From http://stackoverflow.com/questions/15489011/python-time-series-alignment-and-to-date-functions
def i_counter(grouped):
    se = grouped.set_index('INSPECTION_BEGIN_DT')['EVENT_NO']
    # se is the time series of inspection dates restricted to a single MINE_ID
    se = se.resample("D")
    df = pd.DataFrame({'event_no':se, 'i90':pd.rolling_count(se, 90), 'i30':pd.rolling_count(se, 30)})
    return df

# Test:
df_test = inspections[:][inspections['MINE_ID'].isin([4601318, 4601456])].groupby('MINE_ID').apply(i_counter)
df_test.tail(10)

# Run all the inspections:
i_days = inspections.groupby('MINE_ID').apply(i_counter)
i_days.tail(10)


# Accidents
def a_counter(grouped):
    se = grouped.set_index('ACCIDENT_DT')['DOCUMENT_NO']
    # se is the time series of accident dates restricted to a single MINE_ID
    se = se.resample("D")
    df = pd.DataFrame({'document_no':se, 'a90':pd.rolling_count(se, 90), 'a30':pd.rolling_count(se, 30)})
    # TODO: include a sum of injury counts by day
    return df

# Test:
df_test = accidents[:][accidents['MINE_ID'].isin([4601318, 4601456])].groupby('MINE_ID').apply(a_counter)
df_test.tail(10)

# Run all the accidents:
a_days = accidents.groupby('MINE_ID').apply(a_counter)
a_days.tail(10)

# Merge accidents to inspections
ia_days = pd.merge(i_days, a_days, how='left', left_index= True , right_index= True)





