curl http://www.msha.gov/OpenGovernmentData/DataSets/Accidents.zip > ./data/msha_source/Accidents.zip

curl http://www.msha.gov/OpenGovernmentData/DataSets/Inspections.zip > ./data/msha_source/Inspections.zip

curl http://www.msha.gov/OpenGovernmentData/DataSets/Mines.zip > ./data/msha_source/Mines.zip

curl http://www.msha.gov/OpenGovernmentData/DataSets/Violations.zip > ./data/msha_source/Violations.zip

unzip -o ./data/msha_source/Accidents.zip
unzip -o ./data/msha_source/Inspections.zip
unzip -o ./data/msha_source/Mines.zip
unzip -o ./data/msha_source/Violations.zip

# unzip -o AddressOfRecord.zip

# unzip -o MinesProdQuarterly.zip
# unzip -o MinesProdYearly.zip

