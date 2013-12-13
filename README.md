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

*2013-12-08*
`msha_pandas.py` is now doing the work of calcuating daily statistics. It exports a csv file that `MSHA_post_pandas.Rmd` processes.

*2013-12-13*
Even using pandas for data prep was not enough to keep R happy. I rewrote the nested MINE_ID & VIOLATION_OCCUR_DT indexes, and added a logit analysis in pandas. The next step is to approach it not as a regression problem with trailing events as independent variables, but as a survival analysis problem.




