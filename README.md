# MSHA Data Exploration

An analysis of violations and accidents at WV mines, in hopes of identifying a predictive model for accidents as a function of cited violations or some other factor.

My intention is to document the process by which someone with some fluency in R and understanding of a data set's subject matter, but very little depth of understanding in predictive analytics, might go about using the great tools available to us all today.

The data is from [http://www.msha.gov/OpenGovernmentData/OGIMSHA.asp](http://www.msha.gov/OpenGovernmentData/OGIMSHA.asp)

Tables include:

* Mines
* Inspections
* Violations
* Accidents

### Project Organization

I have built this project as an [RMarkdown](http://www.rstudio.com/ide/docs/r_markdown) document. 

The `/data/msha_source` folder contains the large source files and their definition files. The table of violations is over 500 MB, so for the purposes of this project, I have selected out mines in West Virginia using the `/munge/01-extract-wv-R` script.  

### Updates

*2013-11-21*
The R script I built to count inspections, violations, and accidents inside a moving window was way too slow. I have rebuilt that functionality in python pandas, and it's fast enough that now it's no longer necessary to isolate subsets of the records. 

I may bring the operating day records into R for graphing and modeling.


