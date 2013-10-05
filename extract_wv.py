

import pandas as pd
import numpy as np
import os

os.chdir('/Users/mfrost/Code/MSHA')

mines = pd.read_table('data/msha_source/Mines.txt', sep='|')
mines.reindex()

accidents = pd.read_table('data/msha_source/Accidents.txt', sep='|', parse_dates=['ACCIDENT_DT','INVEST_BEGIN_DT'])
accidents.reindex()


inspections = pd.read_table('data/msha_source/Inspections.txt', sep='|', parse_dates=['INSPECTION_BEGIN_DT','INSPECTION_END_DT'])
inspections.reindex()

violations = pd.read_table('data/msha_source/Violations.txt', sep='|', parse_dates=['VIOLATION_ISSUE_DT','VIOLATION_OCCUR_DT','INSPECTION_BEGIN_DT','INSPECTION_END_DT','CONTESTED_DT'])
violations.reindex()

wv_mine_ids = mines['MINE_ID'][mines['BOM_STATE_CD'] == 46]
wv_mines = mines[:][mines['BOM_STATE_CD'] == 46]
wv_mines.to_csv('data/wv_mines.csv',index='FALSE')

wv_violations = violations[:][violations['MINE_ID'].isin(wv_mine_ids)]
wv_violations.to_csv('data/wv_violations.csv',index='FALSE')

wv_inspections = inspections[:][inspections['MINE_ID'].isin(wv_mine_ids)]
wv_inspections.to_csv('data/wv_inspections.csv',index='FALSE')

wv_accidents = accidents[:][accidents['MINE_ID'].isin(wv_mine_ids)]
wv_accidents.to_csv('data/wv_accidents.csv',index='FALSE')

