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

