Analysis of MSHA Inspections, Violations, and Accident Data
========================================================


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
setwd("~/Code/MSHA/")
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
head(mdat)
```

```
##   MINE_ID              CURRENT_MINE_NAME COAL_METAL_IND CURRENT_MINE_TYPE
## 1 4405782                      Mine No 2              C       Underground
## 2 3605672            BURKHARDT OPERATION              M           Surface
## 3 1800708          SHUFELT SAND & GRAVEL              M           Surface
## 4 3600651 McAvoy Vitrified Brick Company              M           Surface
## 5 3602299                Shamokin Quarry              M           Surface
## 6 3606931                      King No 4              C           Surface
##   CURRENT_MINE_STATUS CURRENT_STATUS_DT CURRENT_CONTROLLER_ID
## 1           Abandoned        01/22/1982                C08906
## 2           Abandoned        07/10/2003                M03183
## 3              Active        11/08/2005                M38422
## 4        Intermittent        09/23/1996                M36062
## 5        Intermittent        02/19/2010                M00271
## 6           Abandoned        05/01/1980                C02389
##                   CURRENT_CONTROLLER_NAME CURRENT_OPERATOR_ID
## 1                            Gibson James              P11985
## 2                               Colas S A              L06066
## 3                        Johnson  Shufelt              L38422
## 4               Thomas B McAvoy III Trust              L36062
## 5 New Enterprise Stone & Lime Company Inc              L00335
## 6                         Owens Harold Jr              P10091
##      CURRENT_OPERATOR_NAME STATE BOM_STATE_CD FIPS_CNTY_CD   FIPS_CNTY_NM
## 1        Simplex Coal Corp    VA           44           27       Buchanan
## 2    I A Construction Corp    PA           36          121        Venango
## 3    Shufelt Sand & Gravel    MD           18           19     Dorchester
## 4     McAvoy Brick Company    PA           36           29        Chester
## 5  Eastern Industries Inc.    PA           36           97 Northumberland
## 6   H Owens Mining Company    PA           36          111       Somerset
##   CONG_DIST_CD COMPANY_TYPE CURRENT_CONTROLLER_BEGIN_DT DISTRICT OFFICE_CD
## 1            9  Corporation                  10/01/1981      C05     C0502
## 2            5  Corporation                  01/01/1950       M2     M2681
## 3            1        Other                  08/01/1984       M2     M2621
## 4            7  Corporation                  01/01/1950       M2     M2621
## 5            6  Corporation                  10/24/2011       M2     M2621
## 6           12        Other                  01/01/1980      C02     C0200
##                  OFFICE_NAME ASSESS_CTRL_NO PRIMARY_SIC_CD
## 1    Vansant VA Field Office                        122200
## 2 Warrendale PA Field Office      000006077         144200
## 3 Wyomissing PA Field Office      000285008         144200
## 4 Wyomissing PA Field Office      000218465         145910
## 5 Wyomissing PA Field Office      000276420         142902
## 6            New-Stanton, PA                        122200
##                    PRIMARY_SIC PRIMARY_SIC_CD_1 PRIMARY_SIC_CD_SFX
## 1            Coal (Bituminous)             1222                  0
## 2 Construction Sand and Gravel             1442                  0
## 3 Construction Sand and Gravel             1442                  0
## 4                 Common Shale             1459                 10
## 5    Crushed, Broken Sandstone             1429                  2
## 6            Coal (Bituminous)             1222                  0
##   SECONDARY_SIC_CD SECONDARY_SIC SECONDARY_SIC_CD_1 SECONDARY_SIC_CD_SFX
## 1               NA                               NA                   NA
## 2               NA                               NA                   NA
## 3               NA                               NA                   NA
## 4               NA                               NA                   NA
## 5               NA                               NA                   NA
## 6               NA                               NA                   NA
##   PRIMARY_CANVASS_CD PRIMARY_CANVASS SECONDARY_CANVASS_CD
## 1                  2            Coal                   NA
## 2                  5   SandAndGravel                   NA
## 3                  5   SandAndGravel                   NA
## 4                  7        Nonmetal                   NA
## 5                  6           Stone                   NA
## 6                  2            Coal                   NA
##   SECONDARY_CANVASS             CURRENT_103I CURRENT_103I_DT
## 1                   Removed From 103I Status      10/01/1981
## 2                      Never Had 103I Status                
## 3                      Never Had 103I Status                
## 4                                                           
## 5                      Never Had 103I Status                
## 6                                                           
##   PORTABLE_OPERATION PORTABLE_FIPS_ST_CD DAYS_PER_WEEK HOURS_PER_SHIFT
## 1                  N                  NA             0              NA
## 2                  N                  NA             5               8
## 3                  N                  NA             5               8
## 4                  N                  NA             5               8
## 5                  N                  NA             5               8
## 6                  N                  NA             0              NA
##   PROD_SHIFTS_PER_DAY MAINT_SHIFTS_PER_DAY NO_EMPLOYEES PART48_TRAINING
## 1                  NA                   NA           11               N
## 2                   1                    0            0               Y
## 3                   1                    0            6               Y
## 4                   1                   NA            1               Y
## 5                   1                    1           12               Y
## 6                  NA                   NA           NA               N
##   LONGITUDE LATITUDE AVG_MINE_HEIGHT MINE_GAS_CATEGORY_CD
## 1     82.06    37.42              31                     
## 2        NA       NA              NA                     
## 3     76.64    39.05              NA                     
## 4     77.19    41.20              NA                     
## 5     76.52    40.78              NA                     
## 6        NA       NA              NA                     
##   METHANE_LIBERATION NO_PRODUCING_PITS NO_NONPRODUCING_PITS
## 1                  0                NA                   NA
## 2                 NA                NA                   NA
## 3                 NA                NA                   NA
## 4                 NA                NA                   NA
## 5                 NA                NA                   NA
## 6                 NA                NA                   NA
##   NO_TAILING_PONDS PILLAR_RECOVERY_USED HIGHWALL_MINER_USED MULTIPLE_PITS
## 1               NA                    N                   N             N
## 2                0                    N                   N             N
## 3                0                    N                   N             N
## 4               NA                    N                   N             N
## 5                0                    N                   N             N
## 6               NA                    N                   N             N
##   MINERS_REP_IND SAFETY_COMMITTEE_IND MILES_FROM_OFFICE
## 1              N                    N                 0
## 2              N                    N                70
## 3              N                    N               160
## 4              N                    N                40
## 5              N                    N               240
## 6              N                    N                 0
##                                                                                                                                                      DIRECTIONS_TO_MINE
## 1                                                                                                                                                                      
## 2                                                                                                                                      Rt 322, 5 miles west of Franklin
## 3                                                                    From Cambridge Route 50 East to Route 16 East, 4 miles.  Cemetary on right, mine entrance on left.
## 4                                                                                                                                                Off Rte 23 McAvoy Lane
## 5 From Reading, PA, Rt. 183 North to Rt. 901 West towards Shamokin, PA.  approx. 15 miles past intersection of Rt. 901 & I-81; company sign on left just before Rt. 61.
## 6                                                                                                                                                                      
##    NEAREST_TOWN
## 1        Hurley
## 2      Franklin
## 3     Secretary
## 4              
## 5 Center Valley
## 6
```

```r
mdat_wv <- subset(mdat, STATE == 'WV' & COAL_METAL_IND == 'C')
```


### Inspections
To periodically rebuild this WV set of records, run `./munge/01-extract-wv.R`

```r
idat <- read.csv("./data/wv_idat.csv")
idat <- merge(idat, mdat_wv[, c("MINE_ID", "CURRENT_MINE_NAME", "CURRENT_CONTROLLER_NAME")])
head(idat)
```

```
##   MINE_ID     X CURRENT_MINE_TYPE EVENT_NO INSPECTION_BEGIN_DT
## 1 4600309 46623       Underground  9839384          04/01/2005
## 2 4600612    61       Underground  9843582          04/01/2005
## 3 4601383  1074       Underground  9843879          04/01/2005
## 4 4601399  1087       Underground  9843660          04/01/2005
## 5 4601672 26504       Underground  9842118          04/01/2005
## 6 4601728 49285       Underground  9842328          04/01/2005
##   INSPECTION_END_DT CONTROLLER_ID           CONTROLLER_NAME OPERATOR_ID
## 1                          C31626               Stanton H F      P31626
## 2                          C00479              Valiunas J K      P00582
## 3                          C00613 Occidental Petroleum Corp      P00737
## 4                          C02197           Walker George F      P02552
## 5                          C00481      Kennie Ray  Childers      P00583
## 6                          C30229          Big Knob Coal Co      P30229
##                  OPERATOR_NAME CAL_YR CAL_QTR FISCAL_YR FISCAL_QTR
## 1      Old Gauley Coal Company     NA       4        NA          1
## 2 Douglas Pocahontas Coal Corp     NA       4        NA          1
## 3    Island Creek Coal Company     NA       4        NA          1
## 4          Ashland Mining Corp     NA       4        NA          1
## 5           K & H Coal Company     NA       4        NA          1
## 6             Big Knob Coal Co     NA       4        NA          1
##   INSPECT_OFFICE_CD ACTIVITY_CODE                            ACTIVITY
## 1             C0400           T02 Office Generated Violation Activity
## 2             C0400           T02 Office Generated Violation Activity
## 3             C0400           T02 Office Generated Violation Activity
## 4             C0400           T02 Office Generated Violation Activity
## 5             C0400           T02 Office Generated Violation Activity
## 6             C0400           T02 Office Generated Violation Activity
##   ACTIVE_SECTIONS IDLE_SECTIONS SHAFT_SLOPE_SINK IMPOUND_CONSTR
## 1               0             0                0              0
## 2               0             0                0              0
## 3               0             0                0              0
## 4               0             0                0              0
## 5               0             0                0              0
## 6               0             0                0              0
##   BLDG_CONSTR_SITES DRAGLINES UNCLASSIFIED_CONSTR CO_RECORDS SURF_UG_MINE
## 1                 0         0                   0          N            N
## 2                 0         0                   0          N            N
## 3                 0         0                   0          N            N
## 4                 0         0                   0          N            N
## 5                 0         0                   0          N            N
## 6                 0         0                   0          N            N
##   SURF_FACILITY_MINE REFUSE_PILES EXPLOSIVE_STORAGE OUTBY_AREAS
## 1                  N            N                 N           N
## 2                  N            N                 N           N
## 3                  N            N                 N           N
## 4                  N            N                 N           N
## 5                  N            N                 N           N
## 6                  N            N                 N           N
##   MAJOR_CONSTR SHAFTS_SLOPES IMPOUNDMENTS MISC_AREA
## 1            N             N            N         N
## 2            N             N            N         N
## 3            N             N            N         N
## 4            N             N            N         N
## 5            N             N            N         N
## 6            N             N            N         N
##                                PROGRAM_AREA SUM.SAMPLE_CNT_AIR.
## 1 Coal--Office Generated Violation Activity                   0
## 2 Coal--Office Generated Violation Activity                   0
## 3 Coal--Office Generated Violation Activity                   0
## 4 Coal--Office Generated Violation Activity                   0
## 5 Coal--Office Generated Violation Activity                   0
## 6 Coal--Office Generated Violation Activity                   0
##   SUM.SAMPLE_CNT_DUSTSPOT. SUM.SAMPLE_CNT_DUSTSURVEY.
## 1                        0                          0
## 2                        0                          0
## 3                        0                          0
## 4                        0                          0
## 5                        0                          0
## 6                        0                          0
##   SUM.SAMPLE_CNT_RESPDUST. SUM.SAMPLE_CNT_NOISE. SUM.SAMPLE_CNT_OTHER.
## 1                        0                     0                     0
## 2                        0                     0                     0
## 3                        0                     0                     0
## 4                        0                     0                     0
## 5                        0                     0                     0
## 6                        0                     0                     0
##   NBR_INSPECTOR SUM.TOTAL_INSP_HOURS. SUM.TOTAL_ON_SITE_HOURS.
## 1             0                     0                        0
## 2             0                     0                        0
## 3             0                     0                        0
## 4             0                     0                        0
## 5             0                     0                        0
## 6             0                     0                        0
##   COAL_METAL_IND SUM.TOTAL_INSP_HRS_SPVR_TRAINEE.
## 1              C                               NA
## 2              C                               NA
## 3              C                               NA
## 4              C                               NA
## 5              C                               NA
## 6              C                               NA
##   SUM.TOTAL_ON_SITE_HRS_SPVR_TRAINEE.     CURRENT_MINE_NAME
## 1                                  NA     Lick Fork No 1 Ug
## 2                                  NA             No 8-Mine
## 3                                  NA       Guyan No 1 Mine
## 4                                  NA Ashland Mine No 11 Ug
## 5                                  NA       K & H Mine No 3
## 6                                  NA             No 2 Mine
##     CURRENT_CONTROLLER_NAME
## 1               Stanton H F
## 2              Valiunas J K
## 3 Occidental Petroleum Corp
## 4           Walker George F
## 5      Kennie Ray  Childers
## 6          Big Knob Coal Co
```


### Accidents

```r
adat <- read.table('./data/msha_source/Accidents.TXT', header=T, sep="|", fill=T, quote="\"",comment.char = "")
# WV is FIPS 54
adat <- subset(adat, FIPS_STATE_CD==54)
adat <- merge(adat, mdat_wv[,c('MINE_ID','CURRENT_MINE_NAME','CURRENT_CONTROLLER_NAME')])
adat$accident.key <- seq(1:nrow(adat))
head(adat)
```

```
##   MINE_ID CONTROLLER_ID   CONTROLLER_NAME OPERATOR_ID        OPERATOR_NAME
## 1 4608870        C15194 Douglas M  Epling      P24500 Legacy Resources LLC
## 2 4608870        C15194 Douglas M  Epling      P24500 Legacy Resources LLC
## 3 4608870        C15194 Douglas M  Epling      P24500 Legacy Resources LLC
## 4 4608870        C15194 Douglas M  Epling      P24500 Legacy Resources LLC
## 5 4608870        C15194 Douglas M  Epling      P24500 Legacy Resources LLC
## 6 4608870        C15194 Douglas M  Epling      P24500 Legacy Resources LLC
##   CONTRACTOR_ID DOCUMENT_NO SUBUNIT_CD                SUBUNIT ACCIDENT_DT
## 1          E879   2.201e+11          3 STRIP, QUARY, OPEN PIT  05/06/2009
## 2                 2.200e+11          3 STRIP, QUARY, OPEN PIT  04/24/2003
## 3                 2.201e+11          3 STRIP, QUARY, OPEN PIT  01/17/2009
## 4           CM9   2.201e+11          3 STRIP, QUARY, OPEN PIT  08/13/2008
## 5                 2.201e+11          3 STRIP, QUARY, OPEN PIT  05/18/2011
## 6                 2.200e+11          3 STRIP, QUARY, OPEN PIT  03/25/2004
##   CAL_YR CAL_QTR FISCAL_YR FISCAL_QTR ACCIDENT_TIME DEGREE_INJURY_CD
## 1   2009       2      2009          3          1045                3
## 2   2003       2      2003          3          1700                3
## 3   2009       1      2009          2           400                6
## 4   2008       3      2008          4          1600                4
## 5   2011       2      2011          3          1030                3
## 6   2004       1      2004          2            15                3
##                    DEGREE_INJURY FIPS_STATE_CD UG_LOCATION_CD
## 1       DAYS AWAY FROM WORK ONLY            54             ? 
## 2       DAYS AWAY FROM WORK ONLY            54             ? 
## 3 NO DYS AWY FRM WRK,NO RSTR ACT            54             ? 
## 4 DYS AWY FRM WRK & RESTRCTD ACT            54             ? 
## 5       DAYS AWAY FROM WORK ONLY            54             ? 
## 6       DAYS AWAY FROM WORK ONLY            54             ? 
##      UG_LOCATION UG_MINING_METHOD_CD UG_MINING_METHOD MINING_EQUIP_CD
## 1 NO VALUE FOUND                  ?    NO VALUE FOUND          ?     
## 2 NO VALUE FOUND                  ?    NO VALUE FOUND          ?     
## 3 NO VALUE FOUND                  ?    NO VALUE FOUND          710000
## 4 NO VALUE FOUND                  ?    NO VALUE FOUND          740100
## 5 NO VALUE FOUND                  ?    NO VALUE FOUND          740100
## 6 NO VALUE FOUND                  ?    NO VALUE FOUND          210300
##                            MINING_EQUIP EQUIP_MFR_CD     EQUIP_MFR_NAME
## 1                        NO VALUE FOUND         ?        NO VALUE FOUND
## 2                        NO VALUE FOUND         ?        NO VALUE FOUND
## 3 Tractor (with or without attachments)         0000       Not Reported
## 4   Dumper, off-highway and underground         0310        Caterpillar
## 5   Dumper, off-highway and underground         0000       Not Reported
## 6                 Machine-mounted drill         0904 Ingersoll-Rand Co.
##   EQUIP_MODEL_NO SHIFT_BEGIN_TIME CLASSIFICATION_CD
## 1              ?              600                18
## 2              ?              700                 9
## 3              ?              300                19
## 4           785C              630                18
## 5              ?              600                12
## 6              ?             1530                18
##                   CLASSIFICATION ACCIDENT_TYPE_CD
## 1         SLIP OR FALL OF PERSON               16
## 2          HANDLING OF MATERIALS               27
## 3 STEPPING OR KNEELING ON OBJECT                1
## 4         SLIP OR FALL OF PERSON               14
## 5                POWERED HAULAGE                2
## 6         SLIP OR FALL OF PERSON               12
##                   ACCIDENT_TYPE NO_INJURIES TOT_EXPER MINE_EXPER JOB_EXPER
## 1      FALL TO LOWER LEVEL, NEC           1       8.0       2.23      18.0
## 2 OVER-EXERTION IN LIFTING OBJS           1        NA       0.17        NA
## 3 STRUCK AGAINST STATIONARY OBJ           1       4.5       4.50       4.5
## 4             FALL FROM LADDERS           1        NA         NA      29.0
## 5  STRUCK AGAINST MOVING OBJECT           1       7.0       4.00       7.0
## 6 FALL FRM MACH, VEHICLE, EQUIP           1        NA       2.21        NA
##   OCCUPATION_CD                 OCCUPATION ACTIVITY_CD
## 1           168 Bulldozer/tractor operator         027
## 2           121                     Welder         028
## 3           168 Bulldozer/tractor operator         023
## 4           104  Mechanic/repairman/helper         039
## 5           176               Truck driver         055
## 6           133  Drill helper/chuck tender         023
##                        ACTIVITY INJURY_SOURCE_CD             INJURY_SOURCE
## 1           HANDLING EXPLOSIVES              117                    GROUND
## 2   HANDLING SUPPLIES/MATERIALS              088 METAL,NEC(PIPE,WIRE,NAIL)
## 3 GET ON/OFF EQUIPMENT/MACHINES              089 BROKEN ROCK,COAL,ORE,WSTE
## 4    MACHINE MAINTENANCE/REPAIR              117                    GROUND
## 5         OPERATE HAULAGE TRUCK              089 BROKEN ROCK,COAL,ORE,WSTE
## 6 GET ON/OFF EQUIPMENT/MACHINES              117                    GROUND
##   NATURE_INJURY_CD             NATURE_INJURY INJ_BODY_PART_CD
## 1              400 UNCLASSIFIED,NOT DETERMED              512
## 2              330   SPRAIN,STRAIN RUPT DISC              420
## 3              220             FRACTURE,CHIP              520
## 4              160 CONTUSN,BRUISE,INTAC SKIN              460
## 5              330   SPRAIN,STRAIN RUPT DISC              420
## 6              330   SPRAIN,STRAIN RUPT DISC              420
##                          INJ_BODY_PART SCHEDULE_CHARGE DAYS_RESTRICT
## 1                         KNEE/PATELLA              NA            NA
## 2 BACK (MUSCLES/SPINE/S-CORD/TAILBONE)              NA            NA
## 3                                ANKLE              NA            NA
## 4                TRUNK, MULTIPLE PARTS              NA           117
## 5 BACK (MUSCLES/SPINE/S-CORD/TAILBONE)              NA            NA
## 6 BACK (MUSCLES/SPINE/S-CORD/TAILBONE)              NA            NA
##   DAYS_LOST TRANS_TERM RETURN_TO_WORK_DT IMMED_NOTIFY_CD IMMED_NOTIFY
## 1        90          N        09/15/2009              13   NOT MARKED
## 2         3          N        04/30/2003              13   NOT MARKED
## 3        NA          N        01/19/2009              13   NOT MARKED
## 4        90          N        03/11/2009              13   NOT MARKED
## 5        12          N        06/03/2011              13   NOT MARKED
## 6       308          N        05/01/2005              13   NOT MARKED
##   INVEST_BEGIN_DT
## 1                
## 2      04/28/2003
## 3                
## 4                
## 5                
## 6                
##                                                                                                                                                                                 NARRATIVE
## 1                                                                          Employee was laying out shot pattern on drill bench. Mine break opened up under feet and the employee fell in.
## 2                                                                                                                           LIFTING CUTTING EDGE FROM D-10 TRACTOR WHILE UNLOADING TRUCK.
## 3                                                   Employee was starting equipment for the beginning of the shift. He climbed down off a dozer, stepped on a rock and twisted his ankle.
## 4 Working on ladder while removing bed pins on 785C. While working with pry bar, lost balance and fell to ground. Working 6-8 feet off ground. Working on restricted duty - no time lost.
## 5              Employee was being loaded in the pit by the end loader when a rock that was getting loaded onto his truck slipped across the load and hit the other side of the truck bed.
## 6                                                                                              DRILL STEEL GOT BROKEN DURING EE'S SHIFT. WHEN EE STEPPED OUT OF DRILL, HE SLIPPED & FELL.
##   CLOSED_DOC_NO COAL_METAL_IND         CURRENT_MINE_NAME
## 1     3.201e+11              C Synergy Surface Mine No 1
## 2     3.200e+11              C Synergy Surface Mine No 1
## 3            NA              C Synergy Surface Mine No 1
## 4     3.201e+11              C Synergy Surface Mine No 1
## 5     3.201e+11              C Synergy Surface Mine No 1
## 6            NA              C Synergy Surface Mine No 1
##   CURRENT_CONTROLLER_NAME accident.key
## 1       Douglas M  Epling            1
## 2       Douglas M  Epling            2
## 3       Douglas M  Epling            3
## 4       Douglas M  Epling            4
## 5       Douglas M  Epling            5
## 6       Douglas M  Epling            6
```


### Violations


```r
vdat <- read.csv("./data/wv_vdat.csv")
vdat <- merge(vdat, mdat_wv[, c("MINE_ID", "CURRENT_MINE_NAME", "CURRENT_CONTROLLER_NAME")])
head(vdat)
```

```
##   MINE_ID     X CURRENT_MINE_TYPE EVENT_NO INSPECTION_BEGIN_DT
## 1 4608870 29413           Surface  4111925          04/11/2006
## 2 4608870 29414           Surface  4098645          04/01/2003
## 3 4608870 29417           Surface  4103570          10/01/2003
## 4 4608870 29418           Surface  4111925          04/11/2006
## 5 4608870 29415           Surface  4111925          04/11/2006
## 6 4608870 29412           Surface  4111925          04/11/2006
##   INSPECTION_END_DT VIOLATION_NO CONTROLLER_ID   CONTROLLER_NAME
## 1        06/13/2006      7244272                                
## 2        06/20/2003      4191617                                
## 3        12/17/2003      4192084        C15194 Douglas M  Epling
## 4        06/13/2006      7247461                                
## 5        06/13/2006      7244271                                
## 6        06/13/2006      7244269                                
##   VIOLATOR_ID          VIOLATOR_NAME VIOLATOR_TYPE_CD
## 1        E879 Hanover Resources, LLC       Contractor
## 2         9NB        Peanut Trucking       Contractor
## 3      P24500   Legacy Resources LLC         Operator
## 4        E879 Hanover Resources, LLC       Contractor
## 5        E879 Hanover Resources, LLC       Contractor
## 6        E879 Hanover Resources, LLC       Contractor
##                   MINE_NAME MINE_TYPE COAL_METAL_IND CONTRACTOR_ID
## 1 Synergy Surface Mine No 1   Surface              C          E879
## 2 Synergy Surface Mine No 1   Surface              C           9NB
## 3 Synergy Surface Mine No 1   Surface              C              
## 4 Synergy Surface Mine No 1   Surface              C          E879
## 5 Synergy Surface Mine No 1   Surface              C          E879
## 6 Synergy Surface Mine No 1   Surface              C          E879
##   VIOLATION_ISSUE_DT VIOLATION_OCCUR_DT CAL_YR CAL_QTR FISCAL_YR
## 1         04/11/2006         04/11/2006   2006       2      2006
## 2         05/29/2003         05/29/2003   2003       2      2003
## 3         11/25/2003         11/25/2003   2003       4      2004
## 4         04/11/2006         04/11/2006   2006       2      2006
## 5         04/11/2006         04/11/2006   2006       2      2006
## 6         04/11/2006         04/11/2006   2006       2      2006
##   FISCAL_QTR VIOLATION_ISSUE_TIME SIG_SUB SECTION_OF_ACT PART_SECTION
## 1          3                 1025       Y                   77.404(a)
## 2          3                 1000       Y                   77.404(a)
## 3          1                 1000       Y                      72.620
## 4          3                 1045       Y                   77.404(a)
## 5          3                 1015       Y                   77.404(a)
## 6          3                 1100       Y                     77.1104
##   SECTION_OF_ACT_1 SECTION_OF_ACT_2 CIT_ORD_SAFE ORIG_TERM_DUE_DT
## 1           104(a)               NA     Citation       04/13/2006
## 2           104(a)               NA     Citation                 
## 3           104(a)               NA     Citation                 
## 4           104(a)               NA     Citation       04/13/2006
## 5           104(a)               NA     Citation       04/13/2006
## 6           104(a)               NA     Citation       04/13/2006
##   ORIG_TERM_DUE_TIME LATEST_TERM_DUE_DT LATEST_TERM_DUE_TIME
## 1                800         04/13/2006                  800
## 2                 NA         05/30/2003                  800
## 3                 NA         11/25/2003                 1200
## 4                900         04/13/2006                  900
## 5                800         04/13/2006                  800
## 6                800         04/13/2006                  800
##   TERMINATION_DT TERMINATION_TIME TERMINATION_TYPE VACATE_DT VACATE_TIME
## 1     04/13/2006              843       Terminated        NA          NA
## 2     05/29/2003             1130       Terminated        NA          NA
## 3     11/25/2003             1015       Terminated        NA          NA
## 4     04/13/2006             1015       Terminated        NA          NA
## 5     04/13/2006              925       Terminated        NA          NA
## 6     04/13/2006              800       Terminated        NA          NA
##   INITIAL_VIOL_NO REPLACED_BY_ORDER_NO LIKELIHOOD INJ_ILLNESS NO_AFFECTED
## 1              NA                      Reasonably    LostDays           1
## 2              NA                      Reasonably    LostDays           1
## 3              NA                      Reasonably    LostDays           2
## 4              NA                      Reasonably    LostDays           1
## 5              NA                      Reasonably    LostDays           1
## 6              NA                      Reasonably    LostDays           2
##      NEGLIGENCE WRITTEN_NOTICE ENFORCEMENT_AREA SPECIAL_ASSESS
## 1 ModNegligence              N           Safety              N
## 2 ModNegligence                          Safety              N
## 3 ModNegligence                          Safety              N
## 4 ModNegligence              N           Safety              N
## 5 ModNegligence              N           Safety              N
## 6 ModNegligence              N           Safety              N
##   PRIMARY_OR_MILL RIGHT_TO_CONF_DT ASMT_GENERATED_IND FINAL_ORDER_ISSUE_DT
## 1              NA               NA                  N           09/03/2006
## 2              NA               NA                  N           10/08/2003
## 3              NA               NA                  N           04/04/2004
## 4              NA               NA                  N           09/03/2006
## 5              NA               NA                  N           09/03/2006
## 6              NA               NA                  N           09/03/2006
##   PROPOSED_PENALTY AMOUNT_DUE AMOUNT_PAID BILL_PRINT_DT LAST_ACTION_CD
## 1              107        107         107    07/20/2006           Paid
## 2               72         72          72    08/19/2003           Paid
## 3              177        177         177    02/19/2004           Paid
## 4              107        107         107    07/20/2006           Paid
## 5              107        107         107    07/20/2006           Paid
## 6              114        114         114    07/20/2006           Paid
##   LAST_ACTION_DT DOCKET_NO DOCKET_STATUS_CD CONTESTED_IND CONTESTED_DT
## 1     08/26/2006                                        N             
## 2     11/29/2004                                        N             
## 3     03/13/2004                                        N             
## 4     08/26/2006                                        N             
## 5     08/26/2006                                        N             
## 6     08/26/2006                                        N             
##   VIOLATOR_VIOLATION_CNT VIOLATOR_INSPECTION_DAY_CNT
## 1                      9                           0
## 2                      2                           0
## 3                      3                          10
## 4                      9                           0
## 5                      9                           0
## 6                      9                           0
##           CURRENT_MINE_NAME CURRENT_CONTROLLER_NAME
## 1 Synergy Surface Mine No 1       Douglas M  Epling
## 2 Synergy Surface Mine No 1       Douglas M  Epling
## 3 Synergy Surface Mine No 1       Douglas M  Epling
## 4 Synergy Surface Mine No 1       Douglas M  Epling
## 5 Synergy Surface Mine No 1       Douglas M  Epling
## 6 Synergy Surface Mine No 1       Douglas M  Epling
```



Reduce mdat_wv to only mines that are not abandoned

```r
mdat_wv <- mdat_wv[grep("Abandoned.*", mdat_wv$CURRENT_MINE_STATUS, invert = TRUE), 
    ]
```

Reduce inspection and violation tables accordingly

```r
idat <- subset(idat, MINE_ID %in% mdat_wv$MINE_ID)
vdat <- subset(vdat, MINE_ID %in% mdat_wv$MINE_ID)
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
calendarHeat(subset(vxday, year(date) == 2011)$date, subset(vxday, year(date) == 
    2011)$vcount)
```

```
## Error: could not find function "calendarHeat"
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

