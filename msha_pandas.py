

import pandas as pd
import numpy as np
import dateutil
import os

os.chdir('/Users/mfrost/Code/MSHA')

mines = pd.read_table('data/msha_source/Mines.txt', sep='|' , parse_dates=['CURRENT_CONTROLLER_BEGIN_DT'])
mines_index = mines.set_index(['STATE','MINE_ID','CURRENT_MINE_STATUS','CURRENT_STATUS_DT','CURRENT_CONTROLLER_ID','CURRENT_CONTROLLER_NAME','CURRENT_OPERATOR_ID','CURRENT_OPERATOR_NAME'])


accidents = pd.read_table('data/msha_source/Accidents.txt', sep='|',parse_dates=['ACCIDENT_DT','INVEST_BEGIN_DT'])
accidents_index = accidents.set_index(['MINE_ID','CAL_YR','CAL_QTR','ACCIDENT_DT','CONTROLLER_ID','CONTROLLER_NAME','OPERATOR_ID','OPERATOR_NAME'])

inspections = pd.read_table('data/msha_source/Inspections.txt', sep='|', parse_dates=['INSPECTION_BEGIN_DT','INSPECTION_END_DT'])
inspections_index = inspections.set_index(['EVENT_NO','MINE_ID','CAL_YR','CAL_QTR','INSPECTION_BEGIN_DT','INSPECTION_END_DT','CONTROLLER_ID','CONTROLLER_NAME','OPERATOR_ID','OPERATOR_NAME','ACTIVITY_CODE','PROGRAM_AREA','COAL_METAL_IND'])

violations = pd.read_table('data/msha_source/Violations.txt', sep='|', parse_dates=['VIOLATION_ISSUE_DT','VIOLATION_OCCUR_DT','INSPECTION_BEGIN_DT','INSPECTION_END_DT','CONTESTED_DT'])
violations_index =  violations.set_index(['VIOLATION_NO','EVENT_NO','MINE_ID','CAL_YR','CAL_QTR','INSPECTION_BEGIN_DT','INSPECTION_END_DT','CONTROLLER_ID','CONTROLLER_NAME','MINE_TYPE','COAL_METAL_IND','VIOLATION_OCCUR_DT','VIOLATION_ISSUE_DT','SIG_SUB','LIKELIHOOD','INJ_ILLNESS','NO_AFFECTED','NEGLIGENCE'])
# For unknown reasons, the VIOLATION_DT field isn't being parsed as a date
violations['VIOLATION_OCCUR_DT']=violations['VIOLATION_OCCUR_DT'].apply(dateutil.parser.parse)


# Full Data Loading Complete

# Filter to just a state of interest
sub_state = 46
mine_ids = mines['MINE_ID'][mines['BOM_STATE_CD'] == sub_state]
mines = mines[:][mines['BOM_STATE_CD'] == sub_state]

mines.to_csv('data/wv_mines.csv',index='FALSE')

violations = violations[:][violations['MINE_ID'].isin(mine_ids)]
violations.to_csv('data/wv_violations.csv',index='FALSE')

inspections = inspections[:][inspections['MINE_ID'].isin(mine_ids)]
inspections.to_csv('data/wv_inspections.csv',index='FALSE')

accidents = accidents[:][accidents['MINE_ID'].isin(mine_ids)]
accidents.to_csv('data/wv_accidents.csv',index='FALSE')

# Filtering complete

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

# The MINE_ID and dates are now in a MultiIndex, and can't be 
# queried as columns
# Use the .xs() function to select a cross-section
i_days.xs(4601318).tail(20)

# Accidents
def a_counter(grouped):
    se = grouped.set_index('ACCIDENT_DT')['DEGREE_INJURY_CD']
    # se is the time series of accident dates restricted to a single MINE_ID
    se = se.resample("D")
    df = pd.DataFrame({'degree_injury_cd':se, 'a90':pd.rolling_count(se, 90), 'a30':pd.rolling_count(se, 30)})
    # TODO: include a sum of injury counts by day
    return df

# Test:
df_test = accidents[:][accidents['MINE_ID'].isin([4601318, 4601456])].groupby('MINE_ID').apply(a_counter)
df_test.tail(10)

# Run all the accidents:
a_days = accidents.groupby('MINE_ID').apply(a_counter)
a_days.tail(10)






# Violations
violations.VIOLATION_NO = violations.VIOLATION_NO.convert_objects(convert_numeric=True)

# to find a date: 
violations[:][(violations['VIOLATION_OCCUR_DT']=='20130819') & (violations['MINE_ID']==4601456)]
violations['VIOLATION_NO'][(violations['VIOLATION_OCCUR_DT']=='20130819') & (violations['MINE_ID']==4601456)]
v_test=violations[:][violations['MINE_ID'].isin([4601318, 94601456])]


grouped = violations.groupby(['MINE_ID','VIOLATION_OCCUR_DT'])
v_days=grouped['VIOLATION_NO'].agg({'vcount':np.size})
v_days.reset_index(level=[0], inplace=True)

# Resample and fill non-violation days
def _sum(x):
    if len(x) == 0: return 0
    else: return sum(x)

v_days = v_days.groupby(['MINE_ID']).resample('D',how=_sum)
del v_days['MINE_ID']

v30 = v_days.apply(lambda x: pd.rolling_sum(x,30,min_periods=1))
v30.columns = ['v30']
v90 = v_days.apply(lambda x: pd.rolling_sum(x,90,min_periods=1))
v90.columns = ['v90']

v_days['v30'] = v30.v30
v_days['v90'] = v90.v90

v_days.head(30)

# Merge accidents to inspections and violations

# First, rename all the index keys
i_days.index.names = ['MINE_ID','OP_DT']
a_days.index.names = ['MINE_ID','OP_DT']
v_days.index.names = ['MINE_ID','OP_DT']

ia_days = pd.merge(i_days, a_days, how='left', left_index= True , right_index= True)
iav_days = pd.merge(ia_days, v_days, how='left', left_index=True, right_index=True)
# with the entire US data set, it processed 63,252,285 records in between 3 and 5 hours


iav_days.to_csv('data/iav_days.csv',index='FALSE')

# TODO: Convert objects to R

r_dataframe = com.convert_to_r_dataframe(iav_days)



