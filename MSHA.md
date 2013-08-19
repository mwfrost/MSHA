Analysis of MSHA Inspections, Violations, and Accident Data
========================================================

_An open and ongoing analysis of the data provided by the [US Mine Safety & Health Administration](http://www.msha.gov/OpenGovernmentData/OGIMSHA.asp). See [github.com/mwfrost/MSHA](https://github.com/mwfrost/MSHA) for details._


```r
require(reshape)
```

```
## Loading required package: reshape
```

```
## Loading required package: plyr
```

```
## Attaching package: 'reshape'
```

```
## The following object(s) are masked from 'package:plyr':
## 
## rename, round_any
```

```r
require(plyr)
require(ggplot2)
```

```
## Loading required package: ggplot2
```

```r
require(lubridate)
```

```
## Loading required package: lubridate
```

```
## Attaching package: 'lubridate'
```

```
## The following object(s) are masked from 'package:reshape':
## 
## stamp
```

```r
require(xtable)
```

```
## Loading required package: xtable
```

```r
require(scales)
```

```
## Loading required package: scales
```

```r
setwd("~/Code/MSHA/")
source("./lib/calendarHeat.r")
```

## Load Data

### Load Mine Data

```r
mdat <- read.table('./data/msha_source/Mines.TXT', header=T, sep="|", fill=T, as.is=c(1:59),quote="\"")
```

```
## Warning: invalid input found on input connection
## './data/msha_source/Mines.TXT'
```

```r
t(head(mdat,3))
```

```
##                             1                         
## MINE_ID                     "4405782"                 
## CURRENT_MINE_NAME           "Mine No 2"               
## COAL_METAL_IND              "C"                       
## CURRENT_MINE_TYPE           "Underground"             
## CURRENT_MINE_STATUS         "Abandoned"               
## CURRENT_STATUS_DT           "01/22/1982"              
## CURRENT_CONTROLLER_ID       "C08906"                  
## CURRENT_CONTROLLER_NAME     "Gibson James"            
## CURRENT_OPERATOR_ID         "P11985"                  
## CURRENT_OPERATOR_NAME       "Simplex Coal Corp"       
## STATE                       "VA"                      
## BOM_STATE_CD                "44"                      
## FIPS_CNTY_CD                " 27"                     
## FIPS_CNTY_NM                "Buchanan"                
## CONG_DIST_CD                "9"                       
## COMPANY_TYPE                "Corporation"             
## CURRENT_CONTROLLER_BEGIN_DT "10/01/1981"              
## DISTRICT                    "C05"                     
## OFFICE_CD                   "C0502"                   
## OFFICE_NAME                 "Vansant VA Field Office" 
## ASSESS_CTRL_NO              ""                        
## PRIMARY_SIC_CD              "122200"                  
## PRIMARY_SIC                 "Coal (Bituminous)"       
## PRIMARY_SIC_CD_1            "1222"                    
## PRIMARY_SIC_CD_SFX          "0"                       
## SECONDARY_SIC_CD            NA                        
## SECONDARY_SIC               ""                        
## SECONDARY_SIC_CD_1          NA                        
## SECONDARY_SIC_CD_SFX        NA                        
## PRIMARY_CANVASS_CD          "2"                       
## PRIMARY_CANVASS             "Coal"                    
## SECONDARY_CANVASS_CD        NA                        
## SECONDARY_CANVASS           ""                        
## CURRENT_103I                "Removed From 103I Status"
## CURRENT_103I_DT             "10/01/1981"              
## PORTABLE_OPERATION          "N"                       
## PORTABLE_FIPS_ST_CD         NA                        
## DAYS_PER_WEEK               "0"                       
## HOURS_PER_SHIFT             NA                        
## PROD_SHIFTS_PER_DAY         NA                        
## MAINT_SHIFTS_PER_DAY        NA                        
## NO_EMPLOYEES                "11"                      
## PART48_TRAINING             "N"                       
## LONGITUDE                   "82.06"                   
## LATITUDE                    "37.42"                   
## AVG_MINE_HEIGHT             "31"                      
## MINE_GAS_CATEGORY_CD        ""                        
## METHANE_LIBERATION          " 0"                      
## NO_PRODUCING_PITS           NA                        
## NO_NONPRODUCING_PITS        NA                        
## NO_TAILING_PONDS            NA                        
## PILLAR_RECOVERY_USED        "N"                       
## HIGHWALL_MINER_USED         "N"                       
## MULTIPLE_PITS               "N"                       
## MINERS_REP_IND              "N"                       
## SAFETY_COMMITTEE_IND        "N"                       
## MILES_FROM_OFFICE           "  0"                     
## DIRECTIONS_TO_MINE          ""                        
## NEAREST_TOWN                "Hurley"                  
##                             2                                 
## MINE_ID                     "3605672"                         
## CURRENT_MINE_NAME           "BURKHARDT OPERATION"             
## COAL_METAL_IND              "M"                               
## CURRENT_MINE_TYPE           "Surface"                         
## CURRENT_MINE_STATUS         "Abandoned"                       
## CURRENT_STATUS_DT           "07/10/2003"                      
## CURRENT_CONTROLLER_ID       "M03183"                          
## CURRENT_CONTROLLER_NAME     "Colas S A"                       
## CURRENT_OPERATOR_ID         "L06066"                          
## CURRENT_OPERATOR_NAME       "I A Construction Corp"           
## STATE                       "PA"                              
## BOM_STATE_CD                "36"                              
## FIPS_CNTY_CD                "121"                             
## FIPS_CNTY_NM                "Venango"                         
## CONG_DIST_CD                "5"                               
## COMPANY_TYPE                "Corporation"                     
## CURRENT_CONTROLLER_BEGIN_DT "01/01/1950"                      
## DISTRICT                    "M2"                              
## OFFICE_CD                   "M2681"                           
## OFFICE_NAME                 "Warrendale PA Field Office"      
## ASSESS_CTRL_NO              "000006077"                       
## PRIMARY_SIC_CD              "144200"                          
## PRIMARY_SIC                 "Construction Sand and Gravel"    
## PRIMARY_SIC_CD_1            "1442"                            
## PRIMARY_SIC_CD_SFX          "0"                               
## SECONDARY_SIC_CD            NA                                
## SECONDARY_SIC               ""                                
## SECONDARY_SIC_CD_1          NA                                
## SECONDARY_SIC_CD_SFX        NA                                
## PRIMARY_CANVASS_CD          "5"                               
## PRIMARY_CANVASS             "SandAndGravel"                   
## SECONDARY_CANVASS_CD        NA                                
## SECONDARY_CANVASS           ""                                
## CURRENT_103I                "Never Had 103I Status"           
## CURRENT_103I_DT             ""                                
## PORTABLE_OPERATION          "N"                               
## PORTABLE_FIPS_ST_CD         NA                                
## DAYS_PER_WEEK               "5"                               
## HOURS_PER_SHIFT             " 8"                              
## PROD_SHIFTS_PER_DAY         " 1"                              
## MAINT_SHIFTS_PER_DAY        " 0"                              
## NO_EMPLOYEES                " 0"                              
## PART48_TRAINING             "Y"                               
## LONGITUDE                   NA                                
## LATITUDE                    NA                                
## AVG_MINE_HEIGHT             NA                                
## MINE_GAS_CATEGORY_CD        ""                                
## METHANE_LIBERATION          NA                                
## NO_PRODUCING_PITS           NA                                
## NO_NONPRODUCING_PITS        NA                                
## NO_TAILING_PONDS            " 0"                              
## PILLAR_RECOVERY_USED        "N"                               
## HIGHWALL_MINER_USED         "N"                               
## MULTIPLE_PITS               "N"                               
## MINERS_REP_IND              "N"                               
## SAFETY_COMMITTEE_IND        "N"                               
## MILES_FROM_OFFICE           " 70"                             
## DIRECTIONS_TO_MINE          "Rt 322, 5 miles west of Franklin"
## NEAREST_TOWN                "Franklin"                        
##                             3                                                                                                   
## MINE_ID                     "1800708"                                                                                           
## CURRENT_MINE_NAME           "SHUFELT SAND & GRAVEL"                                                                             
## COAL_METAL_IND              "M"                                                                                                 
## CURRENT_MINE_TYPE           "Surface"                                                                                           
## CURRENT_MINE_STATUS         "Active"                                                                                            
## CURRENT_STATUS_DT           "11/08/2005"                                                                                        
## CURRENT_CONTROLLER_ID       "M38422"                                                                                            
## CURRENT_CONTROLLER_NAME     "Johnson  Shufelt"                                                                                  
## CURRENT_OPERATOR_ID         "L38422"                                                                                            
## CURRENT_OPERATOR_NAME       "Shufelt Sand & Gravel"                                                                             
## STATE                       "MD"                                                                                                
## BOM_STATE_CD                "18"                                                                                                
## FIPS_CNTY_CD                " 19"                                                                                               
## FIPS_CNTY_NM                "Dorchester"                                                                                        
## CONG_DIST_CD                "1"                                                                                                 
## COMPANY_TYPE                "Other"                                                                                             
## CURRENT_CONTROLLER_BEGIN_DT "08/01/1984"                                                                                        
## DISTRICT                    "M2"                                                                                                
## OFFICE_CD                   "M2621"                                                                                             
## OFFICE_NAME                 "Wyomissing PA Field Office"                                                                        
## ASSESS_CTRL_NO              "000285008"                                                                                         
## PRIMARY_SIC_CD              "144200"                                                                                            
## PRIMARY_SIC                 "Construction Sand and Gravel"                                                                      
## PRIMARY_SIC_CD_1            "1442"                                                                                              
## PRIMARY_SIC_CD_SFX          "0"                                                                                                 
## SECONDARY_SIC_CD            NA                                                                                                  
## SECONDARY_SIC               ""                                                                                                  
## SECONDARY_SIC_CD_1          NA                                                                                                  
## SECONDARY_SIC_CD_SFX        NA                                                                                                  
## PRIMARY_CANVASS_CD          "5"                                                                                                 
## PRIMARY_CANVASS             "SandAndGravel"                                                                                     
## SECONDARY_CANVASS_CD        NA                                                                                                  
## SECONDARY_CANVASS           ""                                                                                                  
## CURRENT_103I                "Never Had 103I Status"                                                                             
## CURRENT_103I_DT             ""                                                                                                  
## PORTABLE_OPERATION          "N"                                                                                                 
## PORTABLE_FIPS_ST_CD         NA                                                                                                  
## DAYS_PER_WEEK               "5"                                                                                                 
## HOURS_PER_SHIFT             " 8"                                                                                                
## PROD_SHIFTS_PER_DAY         " 1"                                                                                                
## MAINT_SHIFTS_PER_DAY        " 0"                                                                                                
## NO_EMPLOYEES                " 6"                                                                                                
## PART48_TRAINING             "Y"                                                                                                 
## LONGITUDE                   "76.64"                                                                                             
## LATITUDE                    "39.05"                                                                                             
## AVG_MINE_HEIGHT             NA                                                                                                  
## MINE_GAS_CATEGORY_CD        ""                                                                                                  
## METHANE_LIBERATION          NA                                                                                                  
## NO_PRODUCING_PITS           NA                                                                                                  
## NO_NONPRODUCING_PITS        NA                                                                                                  
## NO_TAILING_PONDS            " 0"                                                                                                
## PILLAR_RECOVERY_USED        "N"                                                                                                 
## HIGHWALL_MINER_USED         "N"                                                                                                 
## MULTIPLE_PITS               "N"                                                                                                 
## MINERS_REP_IND              "N"                                                                                                 
## SAFETY_COMMITTEE_IND        "N"                                                                                                 
## MILES_FROM_OFFICE           "160"                                                                                               
## DIRECTIONS_TO_MINE          "From Cambridge Route 50 East to Route 16 East, 4 miles.  Cemetary on right, mine entrance on left."
## NEAREST_TOWN                "Secretary"
```

```r
mdat_wv <- subset(mdat, STATE == 'WV' & COAL_METAL_IND == 'C')
```


### Inspections
To periodically rebuild this WV set of records, run `./01-extract-wv.R`

```r
idat <- read.csv("./data/wv_idat.csv")
idat <- merge(idat, mdat_wv[, c("MINE_ID", "CURRENT_MINE_NAME", "CURRENT_CONTROLLER_NAME")])
t(head(idat, 3))
```

```
##                                     1                                          
## MINE_ID                             "4600309"                                  
## X                                   "46623"                                    
## CURRENT_MINE_TYPE                   "Underground"                              
## EVENT_NO                            "9839384"                                  
## INSPECTION_BEGIN_DT                 "04/01/2005"                               
## INSPECTION_END_DT                   ""                                         
## CONTROLLER_ID                       "C31626"                                   
## CONTROLLER_NAME                     "Stanton H F"                              
## OPERATOR_ID                         "P31626"                                   
## OPERATOR_NAME                       "Old Gauley Coal Company"                  
## CAL_YR                              NA                                         
## CAL_QTR                             "4"                                        
## FISCAL_YR                           NA                                         
## FISCAL_QTR                          "1"                                        
## INSPECT_OFFICE_CD                   "C0400"                                    
## ACTIVITY_CODE                       "T02"                                      
## ACTIVITY                            "Office Generated Violation Activity"      
## ACTIVE_SECTIONS                     "0"                                        
## IDLE_SECTIONS                       "0"                                        
## SHAFT_SLOPE_SINK                    "0"                                        
## IMPOUND_CONSTR                      "0"                                        
## BLDG_CONSTR_SITES                   "0"                                        
## DRAGLINES                           "0"                                        
## UNCLASSIFIED_CONSTR                 "0"                                        
## CO_RECORDS                          "N"                                        
## SURF_UG_MINE                        "N"                                        
## SURF_FACILITY_MINE                  "N"                                        
## REFUSE_PILES                        "N"                                        
## EXPLOSIVE_STORAGE                   "N"                                        
## OUTBY_AREAS                         "N"                                        
## MAJOR_CONSTR                        "N"                                        
## SHAFTS_SLOPES                       "N"                                        
## IMPOUNDMENTS                        "N"                                        
## MISC_AREA                           "N"                                        
## PROGRAM_AREA                        "Coal--Office Generated Violation Activity"
## SUM.SAMPLE_CNT_AIR.                 "0"                                        
## SUM.SAMPLE_CNT_DUSTSPOT.            "0"                                        
## SUM.SAMPLE_CNT_DUSTSURVEY.          "0"                                        
## SUM.SAMPLE_CNT_RESPDUST.            "0"                                        
## SUM.SAMPLE_CNT_NOISE.               "0"                                        
## SUM.SAMPLE_CNT_OTHER.               "0"                                        
## NBR_INSPECTOR                       "0"                                        
## SUM.TOTAL_INSP_HOURS.               "0"                                        
## SUM.TOTAL_ON_SITE_HOURS.            "0"                                        
## COAL_METAL_IND                      "C"                                        
## SUM.TOTAL_INSP_HRS_SPVR_TRAINEE.    NA                                         
## SUM.TOTAL_ON_SITE_HRS_SPVR_TRAINEE. NA                                         
## CURRENT_MINE_NAME                   "Lick Fork No 1 Ug"                        
## CURRENT_CONTROLLER_NAME             "Stanton H F"                              
##                                     2                                          
## MINE_ID                             "4600612"                                  
## X                                   "   61"                                    
## CURRENT_MINE_TYPE                   "Underground"                              
## EVENT_NO                            "9843582"                                  
## INSPECTION_BEGIN_DT                 "04/01/2005"                               
## INSPECTION_END_DT                   ""                                         
## CONTROLLER_ID                       "C00479"                                   
## CONTROLLER_NAME                     "Valiunas J K"                             
## OPERATOR_ID                         "P00582"                                   
## OPERATOR_NAME                       "Douglas Pocahontas Coal Corp"             
## CAL_YR                              NA                                         
## CAL_QTR                             "4"                                        
## FISCAL_YR                           NA                                         
## FISCAL_QTR                          "1"                                        
## INSPECT_OFFICE_CD                   "C0400"                                    
## ACTIVITY_CODE                       "T02"                                      
## ACTIVITY                            "Office Generated Violation Activity"      
## ACTIVE_SECTIONS                     "0"                                        
## IDLE_SECTIONS                       "0"                                        
## SHAFT_SLOPE_SINK                    "0"                                        
## IMPOUND_CONSTR                      "0"                                        
## BLDG_CONSTR_SITES                   "0"                                        
## DRAGLINES                           "0"                                        
## UNCLASSIFIED_CONSTR                 "0"                                        
## CO_RECORDS                          "N"                                        
## SURF_UG_MINE                        "N"                                        
## SURF_FACILITY_MINE                  "N"                                        
## REFUSE_PILES                        "N"                                        
## EXPLOSIVE_STORAGE                   "N"                                        
## OUTBY_AREAS                         "N"                                        
## MAJOR_CONSTR                        "N"                                        
## SHAFTS_SLOPES                       "N"                                        
## IMPOUNDMENTS                        "N"                                        
## MISC_AREA                           "N"                                        
## PROGRAM_AREA                        "Coal--Office Generated Violation Activity"
## SUM.SAMPLE_CNT_AIR.                 "0"                                        
## SUM.SAMPLE_CNT_DUSTSPOT.            "0"                                        
## SUM.SAMPLE_CNT_DUSTSURVEY.          "0"                                        
## SUM.SAMPLE_CNT_RESPDUST.            "0"                                        
## SUM.SAMPLE_CNT_NOISE.               "0"                                        
## SUM.SAMPLE_CNT_OTHER.               "0"                                        
## NBR_INSPECTOR                       "0"                                        
## SUM.TOTAL_INSP_HOURS.               "0"                                        
## SUM.TOTAL_ON_SITE_HOURS.            "0"                                        
## COAL_METAL_IND                      "C"                                        
## SUM.TOTAL_INSP_HRS_SPVR_TRAINEE.    NA                                         
## SUM.TOTAL_ON_SITE_HRS_SPVR_TRAINEE. NA                                         
## CURRENT_MINE_NAME                   "No 8-Mine"                                
## CURRENT_CONTROLLER_NAME             "Valiunas J K"                             
##                                     3                                          
## MINE_ID                             "4601383"                                  
## X                                   " 1074"                                    
## CURRENT_MINE_TYPE                   "Underground"                              
## EVENT_NO                            "9843879"                                  
## INSPECTION_BEGIN_DT                 "04/01/2005"                               
## INSPECTION_END_DT                   ""                                         
## CONTROLLER_ID                       "C00613"                                   
## CONTROLLER_NAME                     "Occidental Petroleum Corp"                
## OPERATOR_ID                         "P00737"                                   
## OPERATOR_NAME                       "Island Creek Coal Company"                
## CAL_YR                              NA                                         
## CAL_QTR                             "4"                                        
## FISCAL_YR                           NA                                         
## FISCAL_QTR                          "1"                                        
## INSPECT_OFFICE_CD                   "C0400"                                    
## ACTIVITY_CODE                       "T02"                                      
## ACTIVITY                            "Office Generated Violation Activity"      
## ACTIVE_SECTIONS                     "0"                                        
## IDLE_SECTIONS                       "0"                                        
## SHAFT_SLOPE_SINK                    "0"                                        
## IMPOUND_CONSTR                      "0"                                        
## BLDG_CONSTR_SITES                   "0"                                        
## DRAGLINES                           "0"                                        
## UNCLASSIFIED_CONSTR                 "0"                                        
## CO_RECORDS                          "N"                                        
## SURF_UG_MINE                        "N"                                        
## SURF_FACILITY_MINE                  "N"                                        
## REFUSE_PILES                        "N"                                        
## EXPLOSIVE_STORAGE                   "N"                                        
## OUTBY_AREAS                         "N"                                        
## MAJOR_CONSTR                        "N"                                        
## SHAFTS_SLOPES                       "N"                                        
## IMPOUNDMENTS                        "N"                                        
## MISC_AREA                           "N"                                        
## PROGRAM_AREA                        "Coal--Office Generated Violation Activity"
## SUM.SAMPLE_CNT_AIR.                 "0"                                        
## SUM.SAMPLE_CNT_DUSTSPOT.            "0"                                        
## SUM.SAMPLE_CNT_DUSTSURVEY.          "0"                                        
## SUM.SAMPLE_CNT_RESPDUST.            "0"                                        
## SUM.SAMPLE_CNT_NOISE.               "0"                                        
## SUM.SAMPLE_CNT_OTHER.               "0"                                        
## NBR_INSPECTOR                       "0"                                        
## SUM.TOTAL_INSP_HOURS.               "0"                                        
## SUM.TOTAL_ON_SITE_HOURS.            "0"                                        
## COAL_METAL_IND                      "C"                                        
## SUM.TOTAL_INSP_HRS_SPVR_TRAINEE.    NA                                         
## SUM.TOTAL_ON_SITE_HRS_SPVR_TRAINEE. NA                                         
## CURRENT_MINE_NAME                   "Guyan No 1 Mine"                          
## CURRENT_CONTROLLER_NAME             "Occidental Petroleum Corp"
```


### Accidents

```r
adat <- read.table('./data/msha_source/Accidents.TXT', header=T, sep="|", fill=T, quote="\"",comment.char = "")
# WV is FIPS 54
adat <- subset(adat, FIPS_STATE_CD==54)
adat <- merge(adat, mdat_wv[,c('MINE_ID','CURRENT_MINE_NAME','CURRENT_CONTROLLER_NAME')])
adat$accident.key <- seq(1:nrow(adat))
t(head(adat,3))
```

```
##                         1                                                                                                               
## MINE_ID                 "4608870"                                                                                                       
## CONTROLLER_ID           "C15194"                                                                                                        
## CONTROLLER_NAME         "Douglas M  Epling"                                                                                             
## OPERATOR_ID             "P24500"                                                                                                        
## OPERATOR_NAME           "Legacy Resources LLC"                                                                                          
## CONTRACTOR_ID           "E879"                                                                                                          
## DOCUMENT_NO             "2.201e+11"                                                                                                     
## SUBUNIT_CD              "3"                                                                                                             
## SUBUNIT                 "STRIP, QUARY, OPEN PIT"                                                                                        
## ACCIDENT_DT             "05/06/2009"                                                                                                    
## CAL_YR                  "2009"                                                                                                          
## CAL_QTR                 "2"                                                                                                             
## FISCAL_YR               "2009"                                                                                                          
## FISCAL_QTR              "3"                                                                                                             
## ACCIDENT_TIME           "1045"                                                                                                          
## DEGREE_INJURY_CD        "3"                                                                                                             
## DEGREE_INJURY           "DAYS AWAY FROM WORK ONLY"                                                                                      
## FIPS_STATE_CD           "54"                                                                                                            
## UG_LOCATION_CD          "? "                                                                                                            
## UG_LOCATION             "NO VALUE FOUND"                                                                                                
## UG_MINING_METHOD_CD     "? "                                                                                                            
## UG_MINING_METHOD        "NO VALUE FOUND"                                                                                                
## MINING_EQUIP_CD         "?     "                                                                                                        
## MINING_EQUIP            "NO VALUE FOUND"                                                                                                
## EQUIP_MFR_CD            "?   "                                                                                                          
## EQUIP_MFR_NAME          "NO VALUE FOUND"                                                                                                
## EQUIP_MODEL_NO          "?"                                                                                                             
## SHIFT_BEGIN_TIME        "600"                                                                                                           
## CLASSIFICATION_CD       "18"                                                                                                            
## CLASSIFICATION          "SLIP OR FALL OF PERSON"                                                                                        
## ACCIDENT_TYPE_CD        "16"                                                                                                            
## ACCIDENT_TYPE           "FALL TO LOWER LEVEL, NEC"                                                                                      
## NO_INJURIES             "1"                                                                                                             
## TOT_EXPER               "8.0"                                                                                                           
## MINE_EXPER              "2.23"                                                                                                          
## JOB_EXPER               "18.0"                                                                                                          
## OCCUPATION_CD           "168"                                                                                                           
## OCCUPATION              "Bulldozer/tractor operator"                                                                                    
## ACTIVITY_CD             "027"                                                                                                           
## ACTIVITY                "HANDLING EXPLOSIVES"                                                                                           
## INJURY_SOURCE_CD        "117"                                                                                                           
## INJURY_SOURCE           "GROUND"                                                                                                        
## NATURE_INJURY_CD        "400"                                                                                                           
## NATURE_INJURY           "UNCLASSIFIED,NOT DETERMED"                                                                                     
## INJ_BODY_PART_CD        "512"                                                                                                           
## INJ_BODY_PART           "KNEE/PATELLA"                                                                                                  
## SCHEDULE_CHARGE         NA                                                                                                              
## DAYS_RESTRICT           NA                                                                                                              
## DAYS_LOST               "90"                                                                                                            
## TRANS_TERM              "N"                                                                                                             
## RETURN_TO_WORK_DT       "09/15/2009"                                                                                                    
## IMMED_NOTIFY_CD         "13"                                                                                                            
## IMMED_NOTIFY            "NOT MARKED"                                                                                                    
## INVEST_BEGIN_DT         ""                                                                                                              
## NARRATIVE               "Employee was laying out shot pattern on drill bench. Mine break opened up under feet and the employee fell in."
## CLOSED_DOC_NO           "3.201e+11"                                                                                                     
## COAL_METAL_IND          "C"                                                                                                             
## CURRENT_MINE_NAME       "Synergy Surface Mine No 1"                                                                                     
## CURRENT_CONTROLLER_NAME "Douglas M  Epling"                                                                                             
## accident.key            "1"                                                                                                             
##                         2                                                              
## MINE_ID                 "4608870"                                                      
## CONTROLLER_ID           "C15194"                                                       
## CONTROLLER_NAME         "Douglas M  Epling"                                            
## OPERATOR_ID             "P24500"                                                       
## OPERATOR_NAME           "Legacy Resources LLC"                                         
## CONTRACTOR_ID           ""                                                             
## DOCUMENT_NO             "2.200e+11"                                                    
## SUBUNIT_CD              "3"                                                            
## SUBUNIT                 "STRIP, QUARY, OPEN PIT"                                       
## ACCIDENT_DT             "04/24/2003"                                                   
## CAL_YR                  "2003"                                                         
## CAL_QTR                 "2"                                                            
## FISCAL_YR               "2003"                                                         
## FISCAL_QTR              "3"                                                            
## ACCIDENT_TIME           "1700"                                                         
## DEGREE_INJURY_CD        "3"                                                            
## DEGREE_INJURY           "DAYS AWAY FROM WORK ONLY"                                     
## FIPS_STATE_CD           "54"                                                           
## UG_LOCATION_CD          "? "                                                           
## UG_LOCATION             "NO VALUE FOUND"                                               
## UG_MINING_METHOD_CD     "? "                                                           
## UG_MINING_METHOD        "NO VALUE FOUND"                                               
## MINING_EQUIP_CD         "?     "                                                       
## MINING_EQUIP            "NO VALUE FOUND"                                               
## EQUIP_MFR_CD            "?   "                                                         
## EQUIP_MFR_NAME          "NO VALUE FOUND"                                               
## EQUIP_MODEL_NO          "?"                                                            
## SHIFT_BEGIN_TIME        "700"                                                          
## CLASSIFICATION_CD       " 9"                                                           
## CLASSIFICATION          "HANDLING OF MATERIALS"                                        
## ACCIDENT_TYPE_CD        "27"                                                           
## ACCIDENT_TYPE           "OVER-EXERTION IN LIFTING OBJS"                                
## NO_INJURIES             "1"                                                            
## TOT_EXPER               NA                                                             
## MINE_EXPER              "0.17"                                                         
## JOB_EXPER               NA                                                             
## OCCUPATION_CD           "121"                                                          
## OCCUPATION              "Welder"                                                       
## ACTIVITY_CD             "028"                                                          
## ACTIVITY                "HANDLING SUPPLIES/MATERIALS"                                  
## INJURY_SOURCE_CD        "088"                                                          
## INJURY_SOURCE           "METAL,NEC(PIPE,WIRE,NAIL)"                                    
## NATURE_INJURY_CD        "330"                                                          
## NATURE_INJURY           "SPRAIN,STRAIN RUPT DISC"                                      
## INJ_BODY_PART_CD        "420"                                                          
## INJ_BODY_PART           "BACK (MUSCLES/SPINE/S-CORD/TAILBONE)"                         
## SCHEDULE_CHARGE         NA                                                             
## DAYS_RESTRICT           NA                                                             
## DAYS_LOST               " 3"                                                           
## TRANS_TERM              "N"                                                            
## RETURN_TO_WORK_DT       "04/30/2003"                                                   
## IMMED_NOTIFY_CD         "13"                                                           
## IMMED_NOTIFY            "NOT MARKED"                                                   
## INVEST_BEGIN_DT         "04/28/2003"                                                   
## NARRATIVE               "LIFTING CUTTING EDGE FROM D-10 TRACTOR WHILE UNLOADING TRUCK."
## CLOSED_DOC_NO           "3.200e+11"                                                    
## COAL_METAL_IND          "C"                                                            
## CURRENT_MINE_NAME       "Synergy Surface Mine No 1"                                    
## CURRENT_CONTROLLER_NAME "Douglas M  Epling"                                            
## accident.key            "2"                                                            
##                         3                                                                                                                                      
## MINE_ID                 "4608870"                                                                                                                              
## CONTROLLER_ID           "C15194"                                                                                                                               
## CONTROLLER_NAME         "Douglas M  Epling"                                                                                                                    
## OPERATOR_ID             "P24500"                                                                                                                               
## OPERATOR_NAME           "Legacy Resources LLC"                                                                                                                 
## CONTRACTOR_ID           ""                                                                                                                                     
## DOCUMENT_NO             "2.201e+11"                                                                                                                            
## SUBUNIT_CD              "3"                                                                                                                                    
## SUBUNIT                 "STRIP, QUARY, OPEN PIT"                                                                                                               
## ACCIDENT_DT             "01/17/2009"                                                                                                                           
## CAL_YR                  "2009"                                                                                                                                 
## CAL_QTR                 "1"                                                                                                                                    
## FISCAL_YR               "2009"                                                                                                                                 
## FISCAL_QTR              "2"                                                                                                                                    
## ACCIDENT_TIME           " 400"                                                                                                                                 
## DEGREE_INJURY_CD        "6"                                                                                                                                    
## DEGREE_INJURY           "NO DYS AWY FRM WRK,NO RSTR ACT"                                                                                                       
## FIPS_STATE_CD           "54"                                                                                                                                   
## UG_LOCATION_CD          "? "                                                                                                                                   
## UG_LOCATION             "NO VALUE FOUND"                                                                                                                       
## UG_MINING_METHOD_CD     "? "                                                                                                                                   
## UG_MINING_METHOD        "NO VALUE FOUND"                                                                                                                       
## MINING_EQUIP_CD         "710000"                                                                                                                               
## MINING_EQUIP            "Tractor (with or without attachments)"                                                                                                
## EQUIP_MFR_CD            "0000"                                                                                                                                 
## EQUIP_MFR_NAME          "Not Reported"                                                                                                                         
## EQUIP_MODEL_NO          "?"                                                                                                                                    
## SHIFT_BEGIN_TIME        "300"                                                                                                                                  
## CLASSIFICATION_CD       "19"                                                                                                                                   
## CLASSIFICATION          "STEPPING OR KNEELING ON OBJECT"                                                                                                       
## ACCIDENT_TYPE_CD        " 1"                                                                                                                                   
## ACCIDENT_TYPE           "STRUCK AGAINST STATIONARY OBJ"                                                                                                        
## NO_INJURIES             "1"                                                                                                                                    
## TOT_EXPER               "4.5"                                                                                                                                  
## MINE_EXPER              "4.50"                                                                                                                                 
## JOB_EXPER               " 4.5"                                                                                                                                 
## OCCUPATION_CD           "168"                                                                                                                                  
## OCCUPATION              "Bulldozer/tractor operator"                                                                                                           
## ACTIVITY_CD             "023"                                                                                                                                  
## ACTIVITY                "GET ON/OFF EQUIPMENT/MACHINES"                                                                                                        
## INJURY_SOURCE_CD        "089"                                                                                                                                  
## INJURY_SOURCE           "BROKEN ROCK,COAL,ORE,WSTE"                                                                                                            
## NATURE_INJURY_CD        "220"                                                                                                                                  
## NATURE_INJURY           "FRACTURE,CHIP"                                                                                                                        
## INJ_BODY_PART_CD        "520"                                                                                                                                  
## INJ_BODY_PART           "ANKLE"                                                                                                                                
## SCHEDULE_CHARGE         NA                                                                                                                                     
## DAYS_RESTRICT           NA                                                                                                                                     
## DAYS_LOST               NA                                                                                                                                     
## TRANS_TERM              "N"                                                                                                                                    
## RETURN_TO_WORK_DT       "01/19/2009"                                                                                                                           
## IMMED_NOTIFY_CD         "13"                                                                                                                                   
## IMMED_NOTIFY            "NOT MARKED"                                                                                                                           
## INVEST_BEGIN_DT         ""                                                                                                                                     
## NARRATIVE               "Employee was starting equipment for the beginning of the shift. He climbed down off a dozer, stepped on a rock and twisted his ankle."
## CLOSED_DOC_NO           NA                                                                                                                                     
## COAL_METAL_IND          "C"                                                                                                                                    
## CURRENT_MINE_NAME       "Synergy Surface Mine No 1"                                                                                                            
## CURRENT_CONTROLLER_NAME "Douglas M  Epling"                                                                                                                    
## accident.key            "3"
```


### Violations


```r
vdat <- read.csv("./data/wv_vdat.csv")
vdat <- merge(vdat, mdat_wv[, c("MINE_ID", "CURRENT_MINE_NAME", "CURRENT_CONTROLLER_NAME")])
t(head(vdat, 3))
```

```
##                             1                          
## MINE_ID                     "4608870"                  
## X                           "29413"                    
## CURRENT_MINE_TYPE           "Surface"                  
## EVENT_NO                    "4111925"                  
## INSPECTION_BEGIN_DT         "04/11/2006"               
## INSPECTION_END_DT           "06/13/2006"               
## VIOLATION_NO                "7244272"                  
## CONTROLLER_ID               ""                         
## CONTROLLER_NAME             ""                         
## VIOLATOR_ID                 "E879"                     
## VIOLATOR_NAME               "Hanover Resources, LLC"   
## VIOLATOR_TYPE_CD            "Contractor"               
## MINE_NAME                   "Synergy Surface Mine No 1"
## MINE_TYPE                   "Surface"                  
## COAL_METAL_IND              "C"                        
## CONTRACTOR_ID               "E879"                     
## VIOLATION_ISSUE_DT          "04/11/2006"               
## VIOLATION_OCCUR_DT          "04/11/2006"               
## CAL_YR                      "2006"                     
## CAL_QTR                     "2"                        
## FISCAL_YR                   "2006"                     
## FISCAL_QTR                  "3"                        
## VIOLATION_ISSUE_TIME        "1025"                     
## SIG_SUB                     "Y"                        
## SECTION_OF_ACT              ""                         
## PART_SECTION                "77.404(a)"                
## SECTION_OF_ACT_1            "104(a)"                   
## SECTION_OF_ACT_2            NA                         
## CIT_ORD_SAFE                "Citation"                 
## ORIG_TERM_DUE_DT            "04/13/2006"               
## ORIG_TERM_DUE_TIME          "800"                      
## LATEST_TERM_DUE_DT          "04/13/2006"               
## LATEST_TERM_DUE_TIME        " 800"                     
## TERMINATION_DT              "04/13/2006"               
## TERMINATION_TIME            " 843"                     
## TERMINATION_TYPE            "Terminated"               
## VACATE_DT                   NA                         
## VACATE_TIME                 NA                         
## INITIAL_VIOL_NO             NA                         
## REPLACED_BY_ORDER_NO        ""                         
## LIKELIHOOD                  "Reasonably"               
## INJ_ILLNESS                 "LostDays"                 
## NO_AFFECTED                 "1"                        
## NEGLIGENCE                  "ModNegligence"            
## WRITTEN_NOTICE              "N"                        
## ENFORCEMENT_AREA            "Safety"                   
## SPECIAL_ASSESS              "N"                        
## PRIMARY_OR_MILL             NA                         
## RIGHT_TO_CONF_DT            NA                         
## ASMT_GENERATED_IND          "N"                        
## FINAL_ORDER_ISSUE_DT        "09/03/2006"               
## PROPOSED_PENALTY            "107"                      
## AMOUNT_DUE                  "107"                      
## AMOUNT_PAID                 "107"                      
## BILL_PRINT_DT               "07/20/2006"               
## LAST_ACTION_CD              "Paid"                     
## LAST_ACTION_DT              "08/26/2006"               
## DOCKET_NO                   ""                         
## DOCKET_STATUS_CD            ""                         
## CONTESTED_IND               "N"                        
## CONTESTED_DT                ""                         
## VIOLATOR_VIOLATION_CNT      "9"                        
## VIOLATOR_INSPECTION_DAY_CNT " 0"                       
## CURRENT_MINE_NAME           "Synergy Surface Mine No 1"
## CURRENT_CONTROLLER_NAME     "Douglas M  Epling"        
##                             2                          
## MINE_ID                     "4608870"                  
## X                           "29414"                    
## CURRENT_MINE_TYPE           "Surface"                  
## EVENT_NO                    "4098645"                  
## INSPECTION_BEGIN_DT         "04/01/2003"               
## INSPECTION_END_DT           "06/20/2003"               
## VIOLATION_NO                "4191617"                  
## CONTROLLER_ID               ""                         
## CONTROLLER_NAME             ""                         
## VIOLATOR_ID                 "9NB"                      
## VIOLATOR_NAME               "Peanut Trucking"          
## VIOLATOR_TYPE_CD            "Contractor"               
## MINE_NAME                   "Synergy Surface Mine No 1"
## MINE_TYPE                   "Surface"                  
## COAL_METAL_IND              "C"                        
## CONTRACTOR_ID               "9NB"                      
## VIOLATION_ISSUE_DT          "05/29/2003"               
## VIOLATION_OCCUR_DT          "05/29/2003"               
## CAL_YR                      "2003"                     
## CAL_QTR                     "2"                        
## FISCAL_YR                   "2003"                     
## FISCAL_QTR                  "3"                        
## VIOLATION_ISSUE_TIME        "1000"                     
## SIG_SUB                     "Y"                        
## SECTION_OF_ACT              ""                         
## PART_SECTION                "77.404(a)"                
## SECTION_OF_ACT_1            "104(a)"                   
## SECTION_OF_ACT_2            NA                         
## CIT_ORD_SAFE                "Citation"                 
## ORIG_TERM_DUE_DT            ""                         
## ORIG_TERM_DUE_TIME          NA                         
## LATEST_TERM_DUE_DT          "05/30/2003"               
## LATEST_TERM_DUE_TIME        " 800"                     
## TERMINATION_DT              "05/29/2003"               
## TERMINATION_TIME            "1130"                     
## TERMINATION_TYPE            "Terminated"               
## VACATE_DT                   NA                         
## VACATE_TIME                 NA                         
## INITIAL_VIOL_NO             NA                         
## REPLACED_BY_ORDER_NO        ""                         
## LIKELIHOOD                  "Reasonably"               
## INJ_ILLNESS                 "LostDays"                 
## NO_AFFECTED                 "1"                        
## NEGLIGENCE                  "ModNegligence"            
## WRITTEN_NOTICE              ""                         
## ENFORCEMENT_AREA            "Safety"                   
## SPECIAL_ASSESS              "N"                        
## PRIMARY_OR_MILL             NA                         
## RIGHT_TO_CONF_DT            NA                         
## ASMT_GENERATED_IND          "N"                        
## FINAL_ORDER_ISSUE_DT        "10/08/2003"               
## PROPOSED_PENALTY            " 72"                      
## AMOUNT_DUE                  " 72"                      
## AMOUNT_PAID                 " 72"                      
## BILL_PRINT_DT               "08/19/2003"               
## LAST_ACTION_CD              "Paid"                     
## LAST_ACTION_DT              "11/29/2004"               
## DOCKET_NO                   ""                         
## DOCKET_STATUS_CD            ""                         
## CONTESTED_IND               "N"                        
## CONTESTED_DT                ""                         
## VIOLATOR_VIOLATION_CNT      "2"                        
## VIOLATOR_INSPECTION_DAY_CNT " 0"                       
## CURRENT_MINE_NAME           "Synergy Surface Mine No 1"
## CURRENT_CONTROLLER_NAME     "Douglas M  Epling"        
##                             3                          
## MINE_ID                     "4608870"                  
## X                           "29417"                    
## CURRENT_MINE_TYPE           "Surface"                  
## EVENT_NO                    "4103570"                  
## INSPECTION_BEGIN_DT         "10/01/2003"               
## INSPECTION_END_DT           "12/17/2003"               
## VIOLATION_NO                "4192084"                  
## CONTROLLER_ID               "C15194"                   
## CONTROLLER_NAME             "Douglas M  Epling"        
## VIOLATOR_ID                 "P24500"                   
## VIOLATOR_NAME               "Legacy Resources LLC"     
## VIOLATOR_TYPE_CD            "Operator"                 
## MINE_NAME                   "Synergy Surface Mine No 1"
## MINE_TYPE                   "Surface"                  
## COAL_METAL_IND              "C"                        
## CONTRACTOR_ID               ""                         
## VIOLATION_ISSUE_DT          "11/25/2003"               
## VIOLATION_OCCUR_DT          "11/25/2003"               
## CAL_YR                      "2003"                     
## CAL_QTR                     "4"                        
## FISCAL_YR                   "2004"                     
## FISCAL_QTR                  "1"                        
## VIOLATION_ISSUE_TIME        "1000"                     
## SIG_SUB                     "Y"                        
## SECTION_OF_ACT              ""                         
## PART_SECTION                "72.620"                   
## SECTION_OF_ACT_1            "104(a)"                   
## SECTION_OF_ACT_2            NA                         
## CIT_ORD_SAFE                "Citation"                 
## ORIG_TERM_DUE_DT            ""                         
## ORIG_TERM_DUE_TIME          NA                         
## LATEST_TERM_DUE_DT          "11/25/2003"               
## LATEST_TERM_DUE_TIME        "1200"                     
## TERMINATION_DT              "11/25/2003"               
## TERMINATION_TIME            "1015"                     
## TERMINATION_TYPE            "Terminated"               
## VACATE_DT                   NA                         
## VACATE_TIME                 NA                         
## INITIAL_VIOL_NO             NA                         
## REPLACED_BY_ORDER_NO        ""                         
## LIKELIHOOD                  "Reasonably"               
## INJ_ILLNESS                 "LostDays"                 
## NO_AFFECTED                 "2"                        
## NEGLIGENCE                  "ModNegligence"            
## WRITTEN_NOTICE              ""                         
## ENFORCEMENT_AREA            "Safety"                   
## SPECIAL_ASSESS              "N"                        
## PRIMARY_OR_MILL             NA                         
## RIGHT_TO_CONF_DT            NA                         
## ASMT_GENERATED_IND          "N"                        
## FINAL_ORDER_ISSUE_DT        "04/04/2004"               
## PROPOSED_PENALTY            "177"                      
## AMOUNT_DUE                  "177"                      
## AMOUNT_PAID                 "177"                      
## BILL_PRINT_DT               "02/19/2004"               
## LAST_ACTION_CD              "Paid"                     
## LAST_ACTION_DT              "03/13/2004"               
## DOCKET_NO                   ""                         
## DOCKET_STATUS_CD            ""                         
## CONTESTED_IND               "N"                        
## CONTESTED_DT                ""                         
## VIOLATOR_VIOLATION_CNT      "3"                        
## VIOLATOR_INSPECTION_DAY_CNT "10"                       
## CURRENT_MINE_NAME           "Synergy Surface Mine No 1"
## CURRENT_CONTROLLER_NAME     "Douglas M  Epling"
```



Reduce mdat_wv to only mines that are not abandoned

```r
mdat_wv <- mdat_wv[grep("Abandoned.*", mdat_wv$CURRENT_MINE_STATUS, invert = TRUE), 
    ]
nrow(mdat_wv)
```

```
## [1] 5
```

Reduce inspection and violation tables accordingly

```r
idat <- subset(idat, MINE_ID %in% mdat_wv$MINE_ID)
vdat <- subset(vdat, MINE_ID %in% mdat_wv$MINE_ID)
nrow(idat)
```

```
## [1] 78
```

```r
nrow(vdat)
```

```
## [1] 30
```

## Create a time series by mine and month

Add real dates to the various data.frames


```r

mdat_wv$current.status.dt <- mdy(mdat_wv$CURRENT_STATUS_DT)
```

```
## 5 parsed with %m/%d/%Y
```

```r
idat$inspection.begin.dt <- mdy(idat$INSPECTION_BEGIN_DT)
```

```
## 78 parsed with %m/%d/%Y
```

```r
vdat$violation.occur.dt <- mdy(vdat$VIOLATION_OCCUR_DT)
```

```
## 30 parsed with %m/%d/%Y
```

```r
adat$accident.dt <- mdy(adat$ACCIDENT_DT)
```

```
## 44 parsed with %m/%d/%Y
```

```r

names(adat)
```

```
##  [1] "MINE_ID"                 "CONTROLLER_ID"          
##  [3] "CONTROLLER_NAME"         "OPERATOR_ID"            
##  [5] "OPERATOR_NAME"           "CONTRACTOR_ID"          
##  [7] "DOCUMENT_NO"             "SUBUNIT_CD"             
##  [9] "SUBUNIT"                 "ACCIDENT_DT"            
## [11] "CAL_YR"                  "CAL_QTR"                
## [13] "FISCAL_YR"               "FISCAL_QTR"             
## [15] "ACCIDENT_TIME"           "DEGREE_INJURY_CD"       
## [17] "DEGREE_INJURY"           "FIPS_STATE_CD"          
## [19] "UG_LOCATION_CD"          "UG_LOCATION"            
## [21] "UG_MINING_METHOD_CD"     "UG_MINING_METHOD"       
## [23] "MINING_EQUIP_CD"         "MINING_EQUIP"           
## [25] "EQUIP_MFR_CD"            "EQUIP_MFR_NAME"         
## [27] "EQUIP_MODEL_NO"          "SHIFT_BEGIN_TIME"       
## [29] "CLASSIFICATION_CD"       "CLASSIFICATION"         
## [31] "ACCIDENT_TYPE_CD"        "ACCIDENT_TYPE"          
## [33] "NO_INJURIES"             "TOT_EXPER"              
## [35] "MINE_EXPER"              "JOB_EXPER"              
## [37] "OCCUPATION_CD"           "OCCUPATION"             
## [39] "ACTIVITY_CD"             "ACTIVITY"               
## [41] "INJURY_SOURCE_CD"        "INJURY_SOURCE"          
## [43] "NATURE_INJURY_CD"        "NATURE_INJURY"          
## [45] "INJ_BODY_PART_CD"        "INJ_BODY_PART"          
## [47] "SCHEDULE_CHARGE"         "DAYS_RESTRICT"          
## [49] "DAYS_LOST"               "TRANS_TERM"             
## [51] "RETURN_TO_WORK_DT"       "IMMED_NOTIFY_CD"        
## [53] "IMMED_NOTIFY"            "INVEST_BEGIN_DT"        
## [55] "NARRATIVE"               "CLOSED_DOC_NO"          
## [57] "COAL_METAL_IND"          "CURRENT_MINE_NAME"      
## [59] "CURRENT_CONTROLLER_NAME" "accident.key"           
## [61] "accident.dt"
```

```r
names(idat)
```

```
##  [1] "MINE_ID"                            
##  [2] "X"                                  
##  [3] "CURRENT_MINE_TYPE"                  
##  [4] "EVENT_NO"                           
##  [5] "INSPECTION_BEGIN_DT"                
##  [6] "INSPECTION_END_DT"                  
##  [7] "CONTROLLER_ID"                      
##  [8] "CONTROLLER_NAME"                    
##  [9] "OPERATOR_ID"                        
## [10] "OPERATOR_NAME"                      
## [11] "CAL_YR"                             
## [12] "CAL_QTR"                            
## [13] "FISCAL_YR"                          
## [14] "FISCAL_QTR"                         
## [15] "INSPECT_OFFICE_CD"                  
## [16] "ACTIVITY_CODE"                      
## [17] "ACTIVITY"                           
## [18] "ACTIVE_SECTIONS"                    
## [19] "IDLE_SECTIONS"                      
## [20] "SHAFT_SLOPE_SINK"                   
## [21] "IMPOUND_CONSTR"                     
## [22] "BLDG_CONSTR_SITES"                  
## [23] "DRAGLINES"                          
## [24] "UNCLASSIFIED_CONSTR"                
## [25] "CO_RECORDS"                         
## [26] "SURF_UG_MINE"                       
## [27] "SURF_FACILITY_MINE"                 
## [28] "REFUSE_PILES"                       
## [29] "EXPLOSIVE_STORAGE"                  
## [30] "OUTBY_AREAS"                        
## [31] "MAJOR_CONSTR"                       
## [32] "SHAFTS_SLOPES"                      
## [33] "IMPOUNDMENTS"                       
## [34] "MISC_AREA"                          
## [35] "PROGRAM_AREA"                       
## [36] "SUM.SAMPLE_CNT_AIR."                
## [37] "SUM.SAMPLE_CNT_DUSTSPOT."           
## [38] "SUM.SAMPLE_CNT_DUSTSURVEY."         
## [39] "SUM.SAMPLE_CNT_RESPDUST."           
## [40] "SUM.SAMPLE_CNT_NOISE."              
## [41] "SUM.SAMPLE_CNT_OTHER."              
## [42] "NBR_INSPECTOR"                      
## [43] "SUM.TOTAL_INSP_HOURS."              
## [44] "SUM.TOTAL_ON_SITE_HOURS."           
## [45] "COAL_METAL_IND"                     
## [46] "SUM.TOTAL_INSP_HRS_SPVR_TRAINEE."   
## [47] "SUM.TOTAL_ON_SITE_HRS_SPVR_TRAINEE."
## [48] "CURRENT_MINE_NAME"                  
## [49] "CURRENT_CONTROLLER_NAME"            
## [50] "inspection.begin.dt"
```

```r
names(vdat)
```

```
##  [1] "MINE_ID"                     "X"                          
##  [3] "CURRENT_MINE_TYPE"           "EVENT_NO"                   
##  [5] "INSPECTION_BEGIN_DT"         "INSPECTION_END_DT"          
##  [7] "VIOLATION_NO"                "CONTROLLER_ID"              
##  [9] "CONTROLLER_NAME"             "VIOLATOR_ID"                
## [11] "VIOLATOR_NAME"               "VIOLATOR_TYPE_CD"           
## [13] "MINE_NAME"                   "MINE_TYPE"                  
## [15] "COAL_METAL_IND"              "CONTRACTOR_ID"              
## [17] "VIOLATION_ISSUE_DT"          "VIOLATION_OCCUR_DT"         
## [19] "CAL_YR"                      "CAL_QTR"                    
## [21] "FISCAL_YR"                   "FISCAL_QTR"                 
## [23] "VIOLATION_ISSUE_TIME"        "SIG_SUB"                    
## [25] "SECTION_OF_ACT"              "PART_SECTION"               
## [27] "SECTION_OF_ACT_1"            "SECTION_OF_ACT_2"           
## [29] "CIT_ORD_SAFE"                "ORIG_TERM_DUE_DT"           
## [31] "ORIG_TERM_DUE_TIME"          "LATEST_TERM_DUE_DT"         
## [33] "LATEST_TERM_DUE_TIME"        "TERMINATION_DT"             
## [35] "TERMINATION_TIME"            "TERMINATION_TYPE"           
## [37] "VACATE_DT"                   "VACATE_TIME"                
## [39] "INITIAL_VIOL_NO"             "REPLACED_BY_ORDER_NO"       
## [41] "LIKELIHOOD"                  "INJ_ILLNESS"                
## [43] "NO_AFFECTED"                 "NEGLIGENCE"                 
## [45] "WRITTEN_NOTICE"              "ENFORCEMENT_AREA"           
## [47] "SPECIAL_ASSESS"              "PRIMARY_OR_MILL"            
## [49] "RIGHT_TO_CONF_DT"            "ASMT_GENERATED_IND"         
## [51] "FINAL_ORDER_ISSUE_DT"        "PROPOSED_PENALTY"           
## [53] "AMOUNT_DUE"                  "AMOUNT_PAID"                
## [55] "BILL_PRINT_DT"               "LAST_ACTION_CD"             
## [57] "LAST_ACTION_DT"              "DOCKET_NO"                  
## [59] "DOCKET_STATUS_CD"            "CONTESTED_IND"              
## [61] "CONTESTED_DT"                "VIOLATOR_VIOLATION_CNT"     
## [63] "VIOLATOR_INSPECTION_DAY_CNT" "CURRENT_MINE_NAME"          
## [65] "CURRENT_CONTROLLER_NAME"     "violation.occur.dt"
```

```r
names(mdat)
```

```
##  [1] "MINE_ID"                     "CURRENT_MINE_NAME"          
##  [3] "COAL_METAL_IND"              "CURRENT_MINE_TYPE"          
##  [5] "CURRENT_MINE_STATUS"         "CURRENT_STATUS_DT"          
##  [7] "CURRENT_CONTROLLER_ID"       "CURRENT_CONTROLLER_NAME"    
##  [9] "CURRENT_OPERATOR_ID"         "CURRENT_OPERATOR_NAME"      
## [11] "STATE"                       "BOM_STATE_CD"               
## [13] "FIPS_CNTY_CD"                "FIPS_CNTY_NM"               
## [15] "CONG_DIST_CD"                "COMPANY_TYPE"               
## [17] "CURRENT_CONTROLLER_BEGIN_DT" "DISTRICT"                   
## [19] "OFFICE_CD"                   "OFFICE_NAME"                
## [21] "ASSESS_CTRL_NO"              "PRIMARY_SIC_CD"             
## [23] "PRIMARY_SIC"                 "PRIMARY_SIC_CD_1"           
## [25] "PRIMARY_SIC_CD_SFX"          "SECONDARY_SIC_CD"           
## [27] "SECONDARY_SIC"               "SECONDARY_SIC_CD_1"         
## [29] "SECONDARY_SIC_CD_SFX"        "PRIMARY_CANVASS_CD"         
## [31] "PRIMARY_CANVASS"             "SECONDARY_CANVASS_CD"       
## [33] "SECONDARY_CANVASS"           "CURRENT_103I"               
## [35] "CURRENT_103I_DT"             "PORTABLE_OPERATION"         
## [37] "PORTABLE_FIPS_ST_CD"         "DAYS_PER_WEEK"              
## [39] "HOURS_PER_SHIFT"             "PROD_SHIFTS_PER_DAY"        
## [41] "MAINT_SHIFTS_PER_DAY"        "NO_EMPLOYEES"               
## [43] "PART48_TRAINING"             "LONGITUDE"                  
## [45] "LATITUDE"                    "AVG_MINE_HEIGHT"            
## [47] "MINE_GAS_CATEGORY_CD"        "METHANE_LIBERATION"         
## [49] "NO_PRODUCING_PITS"           "NO_NONPRODUCING_PITS"       
## [51] "NO_TAILING_PONDS"            "PILLAR_RECOVERY_USED"       
## [53] "HIGHWALL_MINER_USED"         "MULTIPLE_PITS"              
## [55] "MINERS_REP_IND"              "SAFETY_COMMITTEE_IND"       
## [57] "MILES_FROM_OFFICE"           "DIRECTIONS_TO_MINE"         
## [59] "NEAREST_TOWN"
```


Count violations by day.


```r
vxday <- ddply(vdat, .(violation.occur.dt), nrow)
names(vxday) <- c("date", "vcount")
```


Make a calendar heat map


```r
calendarHeat(subset(vxday, year(date) == 2011)$date, subset(vxday, year(date) == 
    2011)$vcount)
```

```
## Loading required package: lattice
```

```
## Loading required package: grid
```

```
## Loading required package: chron
```

```
## Attaching package: 'chron'
```

```
## The following object(s) are masked from 'package:lubridate':
## 
## days, hours, minutes, seconds, years
```

```
## Warning: the condition has length > 1 and only the first element will be
## used
```

```
## Warning: no non-missing arguments to min; returning Inf
```

```
## Error: character string is not in a standard unambiguous format
```



Normalize inspections, violations, and accidents into "event" objects


```r
events <- rbind(data.frame(event = "inspection", MINE_ID = idat$MINE_ID, event.day = idat$inspection.begin.dt, 
    event.key = idat$EVENT_NO), data.frame(event = "violation", MINE_ID = vdat$MINE_ID, 
    event.day = vdat$violation.occur.dt, event.key = vdat$EVENT_NO), data.frame(event = "accident", 
    MINE_ID = adat$MINE_ID, event.day = adat$accident.dt, event.key = adat$accident.key))
```

edays, short for event days, is a temporary hack



```r
edays <- cast(events, event.day + MINE_ID ~ event, value = "event.key", fun.aggregate = "min")



eventsRR <- subset(edays, MINE_ID == 4601318)

eventsRR$day.decimal <- decimal_date(eventsRR$event.day)
```

```
## Error: missing value where TRUE/FALSE needed
```

```r

eventsRR$lastinsp <- ifelse(eventsRR$inspection > 0 & eventsRR$inspection < 
    Inf, eventsRR$day.decimal, cummax(ifelse(eventsRR$inspection > 0 & eventsRR$inspection < 
    Inf, eventsRR$day.decimal, 0)))

eventsRR$lastviol <- ifelse(eventsRR$violation > 0 & eventsRR$violation < Inf, 
    eventsRR$day.decimal, cummax(ifelse(eventsRR$violation > 0 & eventsRR$violation < 
        Inf, eventsRR$day.decimal, 0)))


eventsRR$lastacc <- ifelse(eventsRR$accident > 0 & eventsRR$accident < Inf, 
    eventsRR$day.decimal, cummax(ifelse(eventsRR$accident > 0 & eventsRR$accident < 
        Inf, eventsRR$day.decimal, 0)))


eventsRR$sinceinsp <- eventsRR$day.decimal - eventsRR$lastinsp
eventsRR$sinceviol <- eventsRR$day.decimal - eventsRR$lastviol
eventsRR$sinceacc <- eventsRR$day.decimal - eventsRR$lastacc

eventsRR$year <- floor(eventsRR$day.decimal)
```

```
## Error: Non-numeric argument to mathematical function
```

```r

ggplot(subset(eventsRR, year > 2000)) + geom_line(aes(x = day.decimal - year, 
    y = sinceinsp), color = "blue") + # geom_line(aes(x=day.decimal - year, y=sinceviol),color='black') +
geom_line(aes(x = day.decimal - year, y = sinceacc), color = "red") + facet_wrap("year")
```

```
## Error: comparison (6) is possible only for atomic and list types
```

