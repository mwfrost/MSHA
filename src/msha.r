# Mines
mdat <- read.table('./data/msha_source/Mines.TXT', header=T, sep="|", fill=T, as.is=c(1:59),quote="")
mdat_wv <- subset(mdat, STATE == 'WV' & COAL_METAL_IND == 'C')

# Inspections
idat <- read.csv("./data/wv_idat.csv")
idat <- merge(idat, mdat_wv[,c('MINE_ID','CURRENT_MINE_NAME','CURRENT_CONTROLLER_NAME')])

# Accidents
adat <- read.table('./data/msha_source/Accidents.TXT', header=T, sep="|", fill=T, quote="",comment.char = "")
# WV is FIPS 54
adat <- subset(adat, FIPS_STATE_CD==54)
adat <- merge(adat, mdat_wv[,c('MINE_ID','CURRENT_MINE_NAME','CURRENT_CONTROLLER_NAME')])


# Violations
vdat <- read.csv("./data/wv_vdat.csv")
vdat <- merge(vdat, mdat_wv[,c('MINE_ID','CURRENT_MINE_NAME','CURRENT_CONTROLLER_NAME')])


#  mine and operator violation counts

ddply(head(vdat,500), c('VIOLATOR_NAME','MINE_NAME'),summarise, n_violator=length(VIOLATOR_NAME), n_mine=length(MINE_NAME))
ddply(head(vdat,500), "VIOLATOR_NAME", transform, n_violator = length(VIOLATOR_NAME))

# Calculate simple annual totals by operator
v_op_yr <-cast(vdat, VIOLATOR_NAME~CAL_YR, value='VIOLATION_NO', length)
i_op_yr <-cast(idat, OPERATOR_NAME~CAL_YR, length)
a_op_yr <-cast(adat, OPERATOR_NAME~CAL_YR, length)

# For each mine and calendar year quarter, calculate the number of violations in the trailing n years
vdat$YR_QTR <- vdat$CAL_YR + vdat$CAL_QTR/4

v_mine_qtr <- ddply(vdat, .(MINE_ID,MINE_NAME,VIOLATOR_NAME,YR_QTR), "nrow")
names(v_mine_qtr) <- gsub("nrow","v_count_qtr",names(v_mine_qtr))

# Use cumsum to calculate the number of violations in a prioud of trailing years trail_n
trail_n <- 2
ddply()


