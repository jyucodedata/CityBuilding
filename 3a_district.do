* File of the Learning Project (Mike) - 3a_district.do
* Content: 	Construct summary stats for establishment using BHP dataset (district, size, ...)
*			4) Construct on ind level:


cd /Users/jingeyu/Downloads/Learning/LIAB_lm_9314_v1_test
* Using LIAB test data "Test data LIAB longitudinal model (1993-2014)" (https://fdz.iab.de/en/data-archive/liab.aspx)
clear
set more off
cap log close
//log using "$/3a_district.log", replace



// Working with BHP side of linked employer-employee data (BHP & Persons data are integrated in later files)
use "LIAB_lm_9314_v1_bhp_basis_v1.dta", clear



// Relabeling for translation (German to English)
label variable betnr "Non-system Company Number"
label variable jahr "Year"
*label variable w73_3 "WZ73 3-stellar"
label variable w73_3_gen "Completed by Extrapolation w73_3"
label variable group_w73_3 "Type of Completion w73_3"
*label variable w93_3 "WZ93 3-Steller"
*label variable w93_5 "WZ93 5-Steller"
label variable w93_3_gen "Completed by Extrapolation w93_3"
label variable group_w93_3 "Type of Completion w93_3"
*label variable w03_3 ""
*label variable w03_5 ""
*label variable w08_3 ""
*label variable w08_5 ""
label variable grd_dat "First Appearance"
label variable grd_jahr "Year of First Appearance of the Establishment ID"
label variable lzt_dat "Last Appearance"
label variable lzt_jahr "Year of the Last Occurrence of the Establishment ID"
label variable az_ges "Total Number of Employees"
label variable az_vz "Number of Full-time Employees (Normal Employees & Others)"
label variable az_gf "Number of Marginally Employed"
label variable te_imp_mw "Mean value imp. Gross Daily Wage Full-time Employees"
label variable ao_kreis "Place of Work - District"
label variable ao_bula "Place of Work - State"



// Data Inspection
xtset betnr jahr
sort betnr jahr
xtsum te_imp_mw //mean wages sd between and within



// Coding Districts (strings to numeric)





// Aggregating to Districts

	**************************************************************************************
	*District Definition: when workers are in the same distrct (1) and when they're in the same district and occupation (2)
	**************************************************************************************

	if `g'==1{
		egen team`g'=group(ao_kreis calyr) // call a team 1 if working in the same district
		drop if team`g'==.
		}

	if `g'==2{
		egen team`g'=group(ao_kreis beruf calyr) // call a team 2 if working in the same district and occup
		drop if team`g'==.
	}

	keep if pnlcase==1 & calyr>1998 & calyr<2010 // we have all the workers that worked during 1999 and 2009 at a panel case establishment
	tsset persnr calyr



// Computing Summary Stats (Wages & District - ao_kreis (te_imp_mw if using only BHP data))

	***********************************************
	*** Key Variables for Regressions: Log of Mean Peer Wage and Wages Going Forward
	***********************************************

	* District Size
	bys team`g': gen districtsize=_N
	label var districtsize "District size"
	gen dtsize=log(districtsize)
	label var dtsize "Log Size"

	* Average District Wage
	bys team`g': egen wage_t=mean(avw)
	label var wage_t "Mean district wage"

	*Leave Out Mean (Take out the Own Effect from Team Mean Wage)
	gen fe_2=((wage_t*teamsize)-avw)/(teamsize-1)

	*Construct variable that captures distance to team`g' average quality
	gen fe_2_l=log(fe_2)-log(avw)
	label var fe_2_l "Gap to team quality"

	
	
	
	
***********************************************
// 6_regression_analysis (Mike)
	// Using "Districts" - ao_kreis - How do new skilled workers impact wages?
		// "Learning in Coworkers" (Econometrica, 2021) - Equation (1)
			// Ask: How do new skilled entrants in the neighborhood/area in t-1, t-2, etc. affect:
			// p.8 specification, dynamics, wage differences in same area
	// Addressing sorting - "Spatial Wage Disparities: Sorting Matters!" (Journal of Urban Economics, 2008) - Equation (8)
