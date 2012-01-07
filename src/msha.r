# Mines
mdat <- read.table('./data/msha_source/Mines.TXT', header=T, sep="|", fill=T, as.is=c(1:59),quote="")
mdat_wv <- subset(mdat, STATE == 'WV' & COAL_METAL_IND == 'C')

# Inspections
idat <- read.csv("./data/wv_idat.csv")


# Accidents
adat <- read.table('./data/msha_source/Accidents.TXT', header=T, sep="|", fill=T, quote="",comment.char = "")
# WV is FIPS 54
adat <- subset(adat, FIPS_STATE_CD==54)

# Violations
vdat <- read.csv("./data/wv_vdat.csv")

#  mine and operator violation counts

ddply(head(vdat,500), c('VIOLATOR_NAME','MINE_NAME'),summarise, n_violator=length(VIOLATOR_NAME), n_mine=length(MINE_NAME))

ddply(head(vdat,500), "VIOLATOR_NAME", transform, n_violator = length(VIOLATOR_NAME))