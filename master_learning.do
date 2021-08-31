capture cd U:\fdz1153

* Master File of the project "FDZ 1153"
* users: Gregor Jarosch, Ezra Oberfield, Esteban Rossi-Hansberg

version 13
clear all
set more off, permanently
set linesize 255 // max linesize
*set linesize 120 // max linesize for internal use
adopath ++ prog

// construction of individual data
*do "$prog/1_additional_vars.do" 			// IAB code to construct additional variables and sample from dataset
*do "$prog/2_gen_cr_sect.do" 	   			// IAB code  to turn dataset into monthly panel
*do "$prog/3_macroind.do" 		   			// Add macroeconomic variables
do "$prog/3a_industry.do"					// Add district variables (using BHP dataset)
*do "$prog/4_data_annual.do" 	  			// Turn monthly panel into annual panel

// construction of coworker data and summary stats
*do "$prog/5_coworkers_panel_a.do"						// Construct coworker groups and construct quality proxies at the worker and coworker level
*do "$prog/5_coworkers_panel_b2.do"						// Constructs worker death/exit instrument
do "$prog/5_coworkers_panel_b.do"						// Constructs Summary Stats (How many peer groups, size distribution, wage distribution,..)
do "$prog/5_coworkers_panel_c.do"						// Construct coworker groups and construct quality proxies at the worker and coworker level

// reduced form results
do "$prog/6_regression_analysis_reghdfe_panel_new.do"	// Run regressions
*do "$prog/7_IV.do"										// "death" IV

// structural results
*do "$prog/8_estimation_a_sample.do"				// Constructing baseline sample for structural estimation
*do "$prog/8_estimation_b_basic.do"					// Estimating a paramtric learning function I -- basic case
*do "$prog/8_estimation_b2_basic_curv.do"			// Adjust the previous file to allow for size-dependent learning. Also compares estimated Z from previous files with PV income in data
*do "$prog/8_estimation_c_multiplicative.do"		// Estimating a paramtric learning function II -- piece-wise linear case. the file also runs two different exercises with the estimated model
*do "$prog/8_estimation_d_yo2.do"					// Estimating a paramtric learning function III -- age-specific (young-old) case, re-assign age






