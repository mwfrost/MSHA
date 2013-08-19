# Parse the definition files and build CREATE statements for inserting new MySQL tables

library(RCurl)
library(plyr)



build.create <- function(desc.url, tbl.name, tbl.dir='./data/msha_source/'){
  tbl.desc.str <- getURL(desc.url)
  tbl.path <- paste(tbl.dir, tbl.name, '.txt', sep='')
  tbl.desc <- read.table(url, sep="|", header=TRUE, as.is=TRUE, quote='"')
  tbl.desc$COLUMN_NAME <- gsub("^\\s+|\\s+$", "", tbl.desc$COLUMN_NAME) 
  
  clauses <- ddply(tbl.desc, .(COLUMN_NAME), function(x) c(fieldclause=paste(x$COLUMN_NAME, ' ' ,x$DATA_TYPE, '(',x$DATA_LENGTH,')',sep='')))
  
  # Remapping Oracle data types to MySQL per http://docs.oracle.com/cd/B10501_01/win.920/a97249/ch3.htm#1026907
  # Change all VARCHAR2s to VARCHARs
  clauses$fieldclause <- gsub('VARCHAR2','VARCHAR', clauses$fieldclause)
  clauses$fieldclause <- gsub('NUMBER','NUMERIC', clauses$fieldclause)
  clauses$fieldclause <- gsub('DATE\\(10\\)','DATE', clauses$fieldclause)
  
  # Reorder the columns so they match the order of fields in the actual table
  header.row <- read.table(tbl.path, header=T, sep="|", fill=T,quote="\"", nrows=1)
  clauses$COLUMN_NAME <- factor(clauses$COLUMN_NAME, names(header.row))
  clauses <- arrange(clauses, COLUMN_NAME)
  paste('CREATE TABLE', tbl.name, '(', paste(clauses$fieldclause, collapse=',') , ');')
}


desc.url <- 'http://www.msha.gov/OpenGovernmentData/DataSets/Mines_Definition_File.txt'
tbl.name <- 'Mines'
tbl.dir <- './data/msha_source/'
build.create(desc.url, tbl.name, tbl.dir)

# CREATE TABLE Mines ( MINE_ID VARCHAR(7),CURRENT_MINE_NAME VARCHAR(50),COAL_METAL_IND VARCHAR(1),CURRENT_MINE_TYPE VARCHAR(20),CURRENT_MINE_STATUS VARCHAR(50),CURRENT_STATUS_DT DATE,CURRENT_CONTROLLER_ID VARCHAR(7),CURRENT_CONTROLLER_NAME VARCHAR(72),CURRENT_OPERATOR_ID VARCHAR(7),CURRENT_OPERATOR_NAME VARCHAR(60),STATE VARCHAR(2),BOM_STATE_CD VARCHAR(2),FIPS_CNTY_CD VARCHAR(3),FIPS_CNTY_NM VARCHAR(80),CONG_DIST_CD VARCHAR(2),COMPANY_TYPE VARCHAR(80),CURRENT_CONTROLLER_BEGIN_DT DATE,DISTRICT VARCHAR(3),OFFICE_CD VARCHAR(5),OFFICE_NAME VARCHAR(80),ASSESS_CTRL_NO VARCHAR(20),PRIMARY_SIC_CD VARCHAR(6),PRIMARY_SIC VARCHAR(80),PRIMARY_SIC_CD_1 VARCHAR(4),PRIMARY_SIC_CD_SFX VARCHAR(2),SECONDARY_SIC_CD VARCHAR(6),SECONDARY_SIC VARCHAR(80),SECONDARY_SIC_CD_1 VARCHAR(4),SECONDARY_SIC_CD_SFX VARCHAR(2),PRIMARY_CANVASS_CD VARCHAR(20),PRIMARY_CANVASS VARCHAR(20),SECONDARY_CANVASS_CD VARCHAR(20),SECONDARY_CANVASS VARCHAR(20),CURRENT_103I VARCHAR(80),CURRENT_103I_DT DATE,PORTABLE_OPERATION VARCHAR(1),PORTABLE_FIPS_ST_CD VARCHAR(2),DAYS_PER_WEEK NUMERIC(2),HOURS_PER_SHIFT NUMERIC(2),PROD_SHIFTS_PER_DAY NUMERIC(3),MAINT_SHIFTS_PER_DAY NUMERIC(3),NO_EMPLOYEES NUMERIC(5),PART48_TRAINING VARCHAR(1),LONGITUDE VARCHAR(10),LATITUDE VARCHAR(9),AVG_MINE_HEIGHT NUMERIC(5),MINE_GAS_CATEGORY_CD VARCHAR(20),METHANE_LIBERATION NUMERIC(9),NO_PRODUCING_PITS NUMERIC(3),NO_NONPRODUCING_PITS NUMERIC(5),NO_TAILING_PONDS NUMERIC(3),PILLAR_RECOVERY_USED VARCHAR(1),HIGHWALL_MINER_USED VARCHAR(1),MULTIPLE_PITS VARCHAR(1),MINERS_REP_IND VARCHAR(1),SAFETY_COMMITTEE_IND VARCHAR(1),MILES_FROM_OFFICE NUMERIC(5),DIRECTIONS_TO_MINE VARCHAR(300),NEAREST_TOWN VARCHAR(30) );

# LOAD DATA LOCAL INFILE './Mines.txt' INTO TABLE Mines FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;


desc.url <- 'http://www.msha.gov/OpenGovernmentData/DataSets/Accidents_Definition_File.txt'
tbl.name <- 'Accidents'
tbl.dir <- './data/msha_source/'
build.create(desc.url, tbl.name, tbl.dir)

# The Accidents table unzips to 'Accident.txt' rather than 'Accidents.txt'
# rename it in the data folder:
# sudo mv Accident.txt Accidents.txt

# sudo mysql
# use msha

# LOAD DATA LOCAL INFILE './Accidents.txt' INTO TABLE Accidents FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;


desc.url <- 'http://www.msha.gov/OpenGovernmentData/DataSets/Inspections_Definition_File.txt'
tbl.name <- 'Inspections'
tbl.dir <- './data/msha_source/'
build.create(desc.url, tbl.name, tbl.dir)

# LOAD DATA LOCAL INFILE './Inspections.txt' INTO TABLE Inspections FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;

# This doesn't actually work. Date fields need to be converted with specific STR_TO_DATE(@col,'%m/%d/%Y') commands