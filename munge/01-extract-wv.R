

########################################################################

# Read Violations.TXT

# Example of epic data munging to pull the desired records out of a file that's too big to read all at once

# The first batch should include the header row
skip_count <- 250000
start_row <- skip_count + 1

vdat <- read.table('./data/msha_source/Violations.TXT', nrows=skip_count, header=T, sep="|", fill=T, as.is=c(1:55), quote="\"",comment.char = "")
vnames <- names(vdat)

vdat <- merge(mdat_wv[c("MINE_ID","CURRENT_MINE_TYPE")] , vdat )

# The second batch starts where the first left off, then picks up the names from it.
# note that the number of rows skipped includes the header

# Violations.TXT has about 1.5 million rows

while (start_row < 2000000) {
     print(paste("About to scan records ", start_row, " through " , start_row + skip_count))

	vdat_temp <- read.table('./data/msha_source/Violations.TXT', nrows=skip_count, header=F, sep="|", fill=T, as.is=c(1:55), skip = start_row ,quote="",comment.char = "")
	names(vdat_temp) <- vnames
	vdat <- rbind(vdat, merge(mdat_wv[c("MINE_ID","CURRENT_MINE_TYPE")] , vdat_temp ))
	print(paste("Rows collected: " , nrow(vdat)))
#	print(paste("Events ", vdat[last_row,c("EVENT_NO")] , " through " , vdat[nrow(vdat),c("EVENT_NO")]))
	start_row <- start_row + skip_count
#	last_row <- nrow(vdat)
}

write.csv(vdat, "./data/wv_vdat.csv")

########################################################################
# Read Inspections.TXT

skip_count <- 250000
start_row <- skip_count + 1

idat <- read.table('./data/msha_source/Inspections.TXT', nrows=skip_count, header=T, sep="|", fill=T,  quote="\"",comment.char = "")
inames <- names(idat)

idat <- merge(mdat_wv[c("MINE_ID","CURRENT_MINE_TYPE")] , idat )

while (start_row < 2000000) {
     print(paste("About to scan records ", start_row, " through " , start_row + skip_count))

	idat_temp <- read.table('./data/msha_source/Inspections.TXT', nrows=skip_count, header=F, sep="|", fill=T,  skip = start_row ,quote="\"",comment.char = "")
	names(idat_temp) <- inames
	idat <- rbind(idat, merge(mdat_wv[c("MINE_ID","CURRENT_MINE_TYPE")] , idat_temp ))
	print(paste("Rows collected: " , nrow(idat)))
	start_row <- start_row + skip_count
}

write.csv(idat, "./data/wv_idat.csv")


