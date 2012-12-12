
# Mines
mdat <- read.table('./data/msha_source/Mines.TXT', header=T, sep="|", fill=T, as.is=c(1:59),quote="\"")
mdat_wv <- subset(mdat, STATE == 'WV' & COAL_METAL_IND == 'C')

# Inspections
# to periodically rebuild this WV set of records, run ./munge/01-extract-wv.R
idat <- read.csv("./data/wv_idat.csv")
idat <- merge(idat, mdat_wv[,c('MINE_ID','CURRENT_MINE_NAME','CURRENT_CONTROLLER_NAME')])

# Accidents
adat <- read.table('./data/msha_source/Accidents.TXT', header=T, sep="|", fill=T, quote="\"",comment.char = "")
# WV is FIPS 54
adat <- subset(adat, FIPS_STATE_CD==54)
adat <- merge(adat, mdat_wv[,c('MINE_ID','CURRENT_MINE_NAME','CURRENT_CONTROLLER_NAME')])
adat$accident.key <- seq(1:nrow(adat))


# Violations
vdat <- read.csv("./data/wv_vdat.csv")
vdat <- merge(vdat, mdat_wv[,c('MINE_ID','CURRENT_MINE_NAME','CURRENT_CONTROLLER_NAME')])


# Reduce mdat_wv to only mines that are not abandoned
mdat_wv <- mdat_wv[grep('Abandoned.*',mdat_wv$CURRENT_MINE_STATUS, invert=TRUE),]

#reduce inspection and violation tables accordingly
idat <- subset(idat, MINE_ID %in% mdat_wv$MINE_ID)
vdat <- subset(vdat, MINE_ID %in% mdat_wv$MINE_ID)


# Create a time series by mine and month

# add real dates to the various data.frames
mdat_wv$current.status.dt <- mdy(mdat_wv$CURRENT_STATUS_DT)
idat$inspection.begin.dt <- mdy(idat$INSPECTION_BEGIN_DT)
vdat$violation.occur.dt <- mdy(vdat$VIOLATION_OCCUR_DT)
adat$accident.dt <- mdy(adat$ACCIDENT_DT)

names(adat)
names(idat)
names(vdat)
names(mdat)



# Count all violations by date
vxday <- ddply(vdat, .(violation.occur.dt), nrow)
names(vxday) <- c('date','vcount')
calendarHeat(subset(vxday, year(date)==2011)$date , subset(vxday, year(date)==2011)$vcount)


# Normalize inspections, violations, and accidents into "event" objects
events <- 
  rbind(
  data.frame(event='inspection', MINE_ID = idat$MINE_ID, event.day=idat$inspection.begin.dt, event.key=idat$EVENT_NO)
  ,
  data.frame(event='violation', MINE_ID = vdat$MINE_ID, event.day=vdat$violation.occur.dt,event.key=vdat$EVENT_NO) 
  ,
  data.frame(event='accident', MINE_ID = adat$MINE_ID, event.day=adat$accident.dt, event.key=adat$accident.key) 
  )

# edays, short for event days, is a temporary hack
edays<-cast(events, event.day+MINE_ID~event, value='event.key', fun.aggregate='min')



eventsRR <- subset(edays, MINE_ID == 4601318)

eventsRR$day.decimal <- decimal_date(eventsRR$event.day)

eventsRR$lastinsp <- ifelse(eventsRR$inspection > 0 & eventsRR$inspection < Inf, eventsRR$day.decimal , cummax(ifelse(eventsRR$inspection > 0 & eventsRR$inspection < Inf, eventsRR$day.decimal, 0))) 

eventsRR$lastviol <- ifelse(eventsRR$violation > 0 & eventsRR$violation < Inf, eventsRR$day.decimal , cummax(ifelse(eventsRR$violation > 0 & eventsRR$violation < Inf, eventsRR$day.decimal, 0))) 


eventsRR$lastacc <- ifelse(eventsRR$accident > 0 & eventsRR$accident < Inf, eventsRR$day.decimal , cummax(ifelse(eventsRR$accident > 0 & eventsRR$accident < Inf, eventsRR$day.decimal, 0))) 


eventsRR$sinceinsp <- eventsRR$day.decimal - eventsRR$lastinsp 
eventsRR$sinceviol <- eventsRR$day.decimal - eventsRR$lastviol
eventsRR$sinceacc <- eventsRR$day.decimal - eventsRR$lastacc

eventsRR$year <- floor(eventsRR$day.decimal)

ggplot(subset(eventsRR, year> 2000)) + 
  geom_line(aes(x=day.decimal - year, y=sinceinsp),color='blue') +
#  geom_line(aes(x=day.decimal - year, y=sinceviol),color='black') +
  geom_line(aes(x=day.decimal - year, y=sinceacc),color='red') +
 facet_wrap('year')

















# Count, for every day, the days since an inspection, the days since a violation, and the days since an accident
# Example mine: Robinson Run 4601318

idays <- data.frame(
                MINE_ID = 4601318,
                day=seq(
                from=min(subset(idat, MINE_ID == 4601318)$inspection.begin.dt),
                to=max(subset(idat, MINE_ID == 4601318)$inspection.begin.dt),
                by=86400
                )
              )

idays <- merge(idays, subset(idat, MINE_ID==4601318)[,c('MINE_ID','inspection.begin.dt', 'EVENT_NO')], 
    by.x=c('MINE_ID','day'),
    by.y=c('MINE_ID', 'inspection.begin.dt'),
    all.x=TRUE)

idays$idate <- ifelse(is.na(idays$EVENT_NO),0,decimal_date(idays$day))

idays$yrssince <- decimal_date(idays$day) - cummax(ifelse(!is.na(idays$EVENT_NO),decimal_date(idays$day),0)) 
calendarHeat(
  subset(idays, year(day)==2011)$day , 
  subset(idays, year(day)==2011)$yrssince  
  )


















# Collapse inspections, violations, and accidents into "event" spans

# Summarize inspections by MINE_ID
mine.isum <- ddply(idat, .(MINE_ID), summarize, event='inspection', first.event=min(inspection.begin.dt), last.event=max(inspection.begin.dt), event.span=max(inspection.begin.dt)-min(inspection.begin.dt), event.count=length(inspection.begin.dt))

# Summarize violations by MINE_ID
mine.vsum <- ddply(vdat, .(MINE_ID), summarize, event='violation', first.event=min(violation.occur.dt), last.event=max(violation.occur.dt), event.span=max(violation.occur.dt)-min(violation.occur.dt), event.count=length(violation.occur.dt))

# Summarize accidents by MINE_ID
mine.asum <- ddply(adat, .(MINE_ID), summarize, event='accident',first.event=min(accident.dt), last.event=max(accident.dt), event.span=max(accident.dt)-min(accident.dt), event.count=length(accident.dt))

# Combine all the summaries into an events table
mine.sum <- rbind(mine.vsum,mine.asum,mine.isum)

# Scatterplot of event span vs event count
ggplot(mine.sum) + geom_point(aes(color=event,x=as.numeric(event.span),y=event.count))

# Line plot of event spans
ggplot(mine.sum) +geom_segment(aes(color=event,x=first.event,y=event.count,xend=last.event,yend=event.count))






# Build a time series of days since each event, with zero for days when events happened

# example: mine 4601318
subset(
ddply(mine.sum, .(MINE_ID), summarise, first.entry=min(first.event), last.entry=max(last.event))
, MINE_ID == 4601318
)

all.days <- seq(from=min(mine.sum$first.event),to=max(mine.sum$last.event),by=86400)

# Date sequence example:
#  seq(from=ymd("2000-01-04"), to=ymd("2000-01-07"), by=86400)

vdays <- ddply(head(arrange(mine.vsum, desc(event.count)),7), .(MINE_ID), function(x)
data.frame(
	MINE_ID=x$MINE_ID[1]
	, date=seq(from=min(x$first.event),to=max(x$last.event),by=86400)
	)
)

vdays <- ddply(vdays, .(MINE_ID, date) , function(x) c(last.vi.date=max(subset(vdat, MINE_ID==x$MINE_ID & violation.occur.dt <= x$date)$violation.occur.dt)
	)
)







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



# A high-violation example mine: 4604955

# Cumulative violations in the trailing n quarters
#######  From StackOverflow.com
##       http://stackoverflow.com/questions/8947952/rolling-sum-on-an-unbalanced-time-series
v_mine_qtr <- v_mine_qtr[ order(v_mine_qtr$MINE_ID, v_mine_qtr$YR_QTR) ,]

v_mine_qtr <- ddply(v_mine_qtr, .(MINE_ID), 
    function(datm) adply(datm, 1, 
         function(x) data.frame(v_lag3 =
                                sum(subset(datm, YR_QTR > (x$YR_QTR-12.25) & YR_QTR<x$YR_QTR)$v_count_qtr))))


v_mine_qtr <- ddply(v_mine_qtr, .(MINE_ID), 
    function(datm) adply(datm, 1, 
         function(x) data.frame(v_lag1 =
		                                sum(subset(datm, YR_QTR > (x$YR_QTR-4.25) & YR_QTR<x$YR_QTR)$v_count_qtr))))




# create a new accident degree index that can be summed for all accidents in a quarter
adat$degree_rescale <-   ifelse( adat$DEGREE_INJURY_CD == 2, 2,
       ifelse( adat$DEGREE_INJURY_CD == 1, 3, 1)
       )

a_qtr <- ddply(adat, .(MINE_ID, YR_QTR), summarize, sum(degree_rescale ))
names(a_qtr) <- c('MINE_ID','YR_QTR','qtr_degree')

v_mine_qtr <- merge(v_mine_qtr, a_qtr, all.x=TRUE, by=c('MINE_ID', 'YR_QTR'))

write.csv(v_mine_qtr, "./data/v_mine_qtr.csv")

# plot lagged violation count against accident degree
ggplot(v_mine_qtr, aes(x=v_lag3,y=qtr_degree)) + geom_point()

# without Big Branch
ggplot(subset(v_mine_qtr, qtr_degree<30)) + geom_point( aes(x=v_lag3,y=qtr_degree), color = 'red') + geom_point( aes(x=v_lag1,y=qtr_degree), color = 'black') 



