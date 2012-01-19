
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
adat$YR_QTR <- adat$CAL_YR + adat$CAL_QTR/4

# TODO: add severity of violation to this as a weight factor
v_mine_qtr <- ddply(vdat, .(MINE_ID,MINE_NAME,VIOLATOR_NAME,YR_QTR), "nrow")
names(v_mine_qtr) <- gsub("nrow","v_count_qtr",names(v_mine_qtr))

# Use cumsum to calculate the number of violations in a period of trailing years trail_n
v_mine_qtr <- v_mine_qtr[ order(v_mine_qtr$MINE_ID, v_mine_qtr$YR_QTR) ,]

#example mine: 4604955
trail_n <- 4

# Annual rolling mean of quarterly violation count
# ddply(v_mine_qtr[v_mine_qtr$MINE_ID==4604955,],"MINE_ID",function(x) data.frame(x, yr_vs=rollmean(x$v_count_qtr,trail_n,na.pad=TRUE,align="right")))

# Cumulative violations in the trailing year
v_mine_qtr <- ddply(v_mine_qtr,"MINE_ID",function(x) data.frame(x, yr_vs=rollapply(x$v_count_qtr,width=trail_n,FUN=sum,fill=NA,by=1,align="right")))

# calculate the sum of the inverse of the degrees of all accidentes per quarter per mine
a_qtr <- ddply(adat, .(MINE_ID, YR_QTR), summarize, sum(1/DEGREE_INJURY_CD))
names(a_qtr) <- c('MINE_ID','YR_QTR','qtr_degree')

a_qtr <- subset(a_qtr, qtr_degree < Inf)


v_mine_qtr <- merge(v_mine_qtr, a_qtr, all.x=TRUE, by=c('MINE_ID', 'YR_QTR'))

write.csv(v_mine_qtr, "./data/v_mine_qtr")

# plot violation count against accident degree
ggplot(v_mine_qtr, aes(x=v_count_qtr,y=qtr_degree)) + geom_point()

