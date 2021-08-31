* File of the Project "1153" (Jarosch, Oberfield, and Rossi-Hansberg): 6_regression_analysis
* Runs a Host of Regressions to Evaluate Coworker Learning for Different Team Defintions

**************************************************************************************************
* NOTE: We run the regressions quietly and then print all the table in tex format at the end,
*		that's where you can see the # of observations used in the regressions reported.
*************************************************************************************************

clear
set more off
cap log close

log using "$log/6_regression_analysis_panel.log", replace

set more off, permanently
set linesize 255 // max linesize
*quietly{


local cut "1 2"

local fake=0 // set this to 1 for the file to run with the test data set provided by the IAB

foreach g of local cut{

	if `g'==1{
		use "$data/coworkers_f.dta", clear // firm teams

	}
	if `g'==2{
		use "$data/coworkers_fo.dta", clear //firm-occupation teams
		noisily display "Now Team Definition 2"
	}


	label var lfe_2 "$\bar{w}$"


	display "****************************************************************************************"
	display "* 1) Run main specification: n-years ahead on distance to team quality and fixed effects "
	display "****************************************************************************************"
	
	eststo clear
	eststo: quietly reghdfe lwf1 lfe_2 lavw if wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)


	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lfe_2 lavw if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_main_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab
	eststo clear

	display _newline
	display "****************************************************************************************"
	display "* 2) Gap to up and gap to down separately "
	display "****************************************************************************************"

	eststo clear
	eststo: quietly reghdfe lwf1 lwh lwl lavw if wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh lwl lavw if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_updown_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab
	eststo clear
	
	display _newline
	display "****************************************************************************************"
	display "* 2) Gap to up and gap to down separately  -- again, but with multiple lags (backward-looking fixed effect)"
	display "****************************************************************************************"

	eststo clear
	eststo: reghdfe lwf1 lwh lwl lavw L.lavw L2.lavw L3.lavw L4.lavw L5.lavw if wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5"
	if `fake'==0{
	foreach d of local dur{
	eststo: reghdfe lwf`d' lwh lwl lavw L.lavw L2.lavw L3.lavw L4.lavw L5.lavw if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_updown_lag_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw L.lavw L2.lavw L3.lavw L4.lavw L5.lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
	}

	if `fake'==1{
	foreach d of local dur{
	eststo: reghdfe lwf`d' lwh lwl lavw if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_updown_lag_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
	}
	
	esttab
	eststo clear
		
	**********************************************************
	** Splitting Sample into Before and After Hartz IV Reforms
	**********************************************************
	
	eststo hartz1: quietly reghdfe lwf1 lwh lwl lavw if wg1_extr==0 & calyr<2005, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo hartz2: quietly reghdfe lwf1 lwh lwl lavw if wg1_extr==0 & calyr>2004, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5"
	foreach d of local dur{
	eststo hartz1_`d':	quietly reghdfe lwf`d' lwh lwl lavw if wg`d'_extr==0 & calyr<2005, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo hartz2_`d':	quietly reghdfe lwf`d' lwh lwl lavw if wg`d'_extr==0 & calyr>2004, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab hartz1 hartz1_2 hartz1_3 hartz1_5  using "$log/results_updown_hartz_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab hartz2 hartz2_2 hartz2_3 hartz2_5  using "$log/results_updown_hartz2_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	
	esttab hartz1 hartz1_2 hartz1_3 hartz1_5 
	esttab hartz2 hartz2_2 hartz2_3 hartz2_5 
	eststo clear
	
	display "****************************************************************************************"
	display "* 2d) Movers
	display "****************************************************************************************"
	
	* movers that are no longer at the same firm next in `d' years (1), in 1 year (2-4), with unemployment spell (3), with mass layoff unemployment spell (4)

	if `fake'==1{
		eststo switch1_1: quietly reghdfe lwf1 lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		eststo switch2_1: quietly reghdfe lwf1 lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		eststo switch3_1: quietly reghdfe lwf1 lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		eststo switch4_1: quietly reghdfe lwf1 lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
}
	else if `fake'==0{
		eststo switch1_1: quietly reghdfe lwf1 lwh lwl lavw if samefirm_1==0 & wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		eststo switch2_1: quietly reghdfe lwf1 lwh lwl lavw if samefirm_1==0 & wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		eststo switch3_1: quietly reghdfe lwf1 lwh lwl lavw if samefirm_1==0 & jobloss==1 & wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		eststo switch4_1: quietly reghdfe lwf1 lwh lwl lavw if samefirm_1==0 & jobloss==1 & masslo==1 & wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
}
			local dur "2 3 5 10"

		foreach d of local dur{
		if `fake'==1{
			eststo switch1_`d': quietly reghdfe lwf`d' lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
			eststo switch2_`d': quietly reghdfe lwf`d' lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
			eststo switch3_`d': quietly reghdfe lwf`d' lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
			eststo switch4_`d': quietly reghdfe lwf`d' lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
	else if `fake'==0{
			eststo switch1_`d': quietly reghdfe lwf`d' lwh lwl lavw if samefirm_`d'==0 & wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
			eststo switch2_`d': quietly reghdfe lwf`d' lwh lwl lavw if samefirm_1==0 & wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
			eststo switch3_`d': quietly reghdfe lwf`d' lwh lwl lavw if samefirm_1==0 & jobloss==1 & wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
			eststo switch4_`d': quietly reghdfe lwf`d' lwh lwl lavw if samefirm_1==0 & jobloss==1 & masslo==1 & wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
		}

		esttab switch1_1 switch1_2 switch1_3 switch1_5 switch1_10 using "$log/results_switcher_asym_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
		mgroups("Horizon in years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		nonumbers mtitles("1" "2" "3" "5" "10")

		esttab switch2_1 switch2_2 switch2_3 switch2_5 switch2_10 using "$log/results_switcher_asym_II_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
		mgroups("Horizon in years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		nonumbers mtitles("1" "2" "3" "5" "10")

		esttab switch3_1 switch3_2 switch3_3 switch3_5 switch3_10 using "$log/results_switcher_asym_III_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
		mgroups("Horizon in years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		nonumbers mtitles("1" "2" "3" "5" "10")

		esttab switch4_1 switch4_2 switch4_3 switch4_5 switch4_10 using "$log/results_switcher_asym_IV_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
		mgroups("Horizon in years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		nonumbers mtitles("1" "2" "3" "5" "10")

		esttab switch1_1 switch1_2 switch1_3 switch1_5 switch1_10
		esttab switch2_1 switch2_2 switch2_3 switch2_5 switch2_10
		esttab switch3_1 switch3_2 switch3_3 switch3_5 switch3_10
		esttab switch4_1 switch4_2 switch4_3 switch4_5 switch4_10
		eststo clear

display _newline
display "****************************************************************************************"
display "* XX) Baseline Regression by Pctl
display "****************************************************************************************"

	drop wpct
	xtile spct = teamsize if lwf3!=. & lwh!=. & lwl!=. & lavw!=. & wg3_extr==0 , nquantiles(10)
	xtile wpct = avw if lwf3!=. & lwh!=. & lwl!=. & lavw!=. & wg3_extr==0 , nquantiles(10)
	xtile tpct = tage_job_yearly if lwf3!=. & lwh!=. & lwl!=. & lavw!=. & wg3_extr==0 , nquantiles(10)
	xtile apct = age if lwf3!=. & lwh!=. & lwl!=. & lavw!=. & wg3_extr==0 , nquantiles(10)


local dur "1 2 3 4 5 6 7 8 9 10"
foreach d of local dur{
		if `fake'==0{
		eststo : quietly reghdfe lwf3 lwh lwl lavw if  spct==`d' & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
		else if `fake'==1{
		eststo : quietly reghdfe lwf3 lwh lwl lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
		}

	esttab using "$log/results_sdec_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumbers mlabels("1" "2" "3" "4" "5" "6" "7" "8" "9" "10") ///
	mgroups("Decile of the Size Distribution", pattern(1 )  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///

	esttab
	eststo clear

local dur "1 2 3 4 5 6 7 8 9 10"
foreach d of local dur{
		if `fake'==0{
		eststo : quietly reghdfe lwf3 lwh lwl lavw if  wpct==`d' & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
		else if `fake'==1{
		eststo : quietly reghdfe lwf3 lwh lwl lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
		}

	esttab using "$log/results_wdec_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumbers mlabels("1" "2" "3" "4" "5" "6" "7" "8" "9" "10") ///
	mgroups("Decile of the Wage Distribution", pattern(1 )  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///

	esttab
	eststo clear



local dur "1 2 3 4 5 6 7 8 9 10"
foreach d of local dur{
		if `fake'==0{
		eststo : quietly reghdfe lwf3 lwh lwl lavw if  apct==`d' & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
			else if `fake'==1{
		eststo : quietly reghdfe lwf3 lwh lwl lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
		}

	esttab using "$log/results_adec_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumbers mlabels("1" "2" "3" "4" "5" "6" "7" "8" "9" "10") ///
	mgroups("Decile of the Age Distribution", pattern(1 )  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///

	esttab
	eststo clear

	local dur "1 2 3 4 5 6 7 8 9 10"
foreach d of local dur{
		if `fake'==0{
		eststo : quietly reghdfe lwf3 lwh lwl lavw if  tpct==`d' & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
			else if `fake'==1{
		eststo : quietly reghdfe lwf3 lwh lwl lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}
		}

	esttab using "$log/results_tdec_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumbers mlabels("1" "2" "3" "4" "5" "6" "7" "8" "9" "10") ///
	mgroups("Decile of the Tenure Distribution", pattern(1 )  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///

	esttab
	eststo clear



display _newline
display "****************************************************************************************"
display "* XX) Baseline on Bin-Weights (tables for the more flexible specification in section 2.2.4)
display "****************************************************************************************"


			drop pdf1 // just to uniformly select the omitted category
			if `fake'==0{
			quietly reghdfe lwf3 pdf* lavw if teamsize>9 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
			}
			else if `fake'==1{
			quietly reghdfe lwf3 pdf* lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
			}
			matrix bet=e(b)
			matrix vari=e(V)
			mat define var = vecdiag(vari)
			mat sd =var
			forval j = 1/`= colsof(var)' {
			mat sd[1, `j'] = sqrt(var[1, `j'])
			}
			mat up = bet+sd*invttail(e(df_r),.025)
			mat down = bet-sd*invttail(e(df_r),.025)
			mat define obs = `e(N)'


			matrix Results_Nonparam = [up \ bet \ down]
			matrix rownames Results_Nonparam = "Conf_Up" "Coeff_Est" "Conf_Down"

	noi display "Team Def: `g'; Min Teamsize: `n'; Horizon: `d'; Clustered: `c'"
	noi display "Scalar Before Table Displays Number of Observations in Regression behind Table"
	noi mat list obs

	noi mat list Results_Nonparam

	local dur "1 2 3 5 10"
	foreach d of local dur{
	if `fake'==0{
	eststo : quietly reghdfe lwf`d' pdf* lavw if teamsize>9 & wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	else if `fake'==1{
	eststo : quietly reghdfe lwf`d' pdf* lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	}
	esttab using "$log/results_bins_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumber ///
	mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  mtitles("1" "2" "3" "5" "10")

	esttab
	eststo clear

	if `fake'==0{
	eststo : quietly reghdfe lwf3 pdf* lavw if teamsize>9 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw if teamsize>9 & frac_below<.5 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw if teamsize>9 & frac_below>=.5 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw if teamsize>9 & wpct==2 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw if teamsize>9 & wpct==4 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw if teamsize>9 & wpct==7 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw if teamsize>9 & wpct==9 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
}
	else if `fake'==1{
	eststo : quietly reghdfe lwf3 pdf* lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	eststo : quietly reghdfe lwf3 pdf* lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}

	esttab using "$log/results_bins_II_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumber ///
	mtitles("All" "Above Team-Median" "Below Team-Median" "2nd Pct." "4th Pct." "7th Pct." "9th Pct.")

	esttab
	eststo clear
	

display "****************************************************************************************"
display "* Controlling for Firm Level Growth (in terms of wage bill and employment this year and last two previous years)
display "****************************************************************************************"

	eststo clear
	eststo: quietly reghdfe lwf1 lwh lwl lavw empgrowth empgrowth2 empgrowth3 if wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 "
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh lwl lavw empgrowth empgrowth2 empgrowth3  if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_updown_growth1_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw emp*) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
	
	esttab
	eststo clear
	
	eststo: quietly reghdfe lwf1 lwh lwl lavw wbgrowth wbgrowth2 wbgrowth3 if wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 "
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh lwl lavw wbgrowth wbgrowth2 wbgrowth3  if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_updown_growth2_`g'.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw wb*) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
	
	esttab
	eststo clear

if `g'==1{

display "****************************************************************************************"
display "* Workers and Managers (where we weight the RHS by respective group size)
display "****************************************************************************************"

/* does this, separately for workers, managers, everyone (LHS). does this for above only, above-below, everyone (RHS). most of this block not used, so commented out
** everyone on worker manager above 
	eststo clear
	eststo: quietly reghdfe lwf1 lwh_wrkr_w2 lwh_mngr_w2 lavw if wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh_wrkr_w2 lwh_mngr_w2 lavw if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr1_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab
	eststo clear
** worker on worker manager above	
	eststo: quietly reghdfe lwf1 lwh_wrkr_w2 lwh_mngr_w2 lavw if wg1_extr==0 & wrkr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh_wrkr_w2 lwh_mngr_w2 lavw if wg`d'_extr==0 & wrkr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr2_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab
	eststo clear
** manager on worker manager above	
	if `fake'==0{
	eststo: quietly reghdfe lwf1 lwh_wrkr_w2 lwh_mngr_w2 lavw if wg1_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh_wrkr_w2 lwh_mngr_w2 lavw if wg`d'_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr3_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab
	eststo clear
	}
	else if `fake'==1{
	eststo: quietly reghdfe lwf1 lwh_wrkr_w2 lwh_mngr_w2 lavw if wg1_extr==0 & wrkr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh_wrkr_w2 lwh_mngr_w2 lavw if wg`d'_extr==0 & wrkr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr3_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab
	eststo clear
	}
*/	
	** everyone on worker manager 	
	eststo: quietly reghdfe lwf1 lw_wrkr_w lw_mngr_w lavw if wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lw_wrkr_w lw_mngr_w lavw if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr4_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab
	
	eststo clear
/*
** worker on worker manager 	
	eststo: quietly reghdfe lwf1 lw_wrkr_w lw_mngr_w lavw if wg1_extr==0 & wrkr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lw_wrkr_w lw_mngr_w lavw if wg`d'_extr==0 & wrkr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr5_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab
	
	eststo clear
** manager on worker manager
	eststo: quietly reghdfe lwf1 lw_wrkr_w lw_mngr_w lavw if wg1_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lw_wrkr_w lw_mngr_w lavw if wg`d'_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr6_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
	
	esttab
	eststo clear

	
	** everyone on worker manager above below
	if `fake'==0{
	eststo: quietly reghdfe lwf1 lwh_wrkr_w2 lwh_mngr_w2 lwl_wrkr_w2 lwl_mngr_w2 lavw if wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh_wrkr_w2 lwh_mngr_w2 lwl_wrkr_w2 lwl_mngr_w2 lavw if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr7_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")

	esttab
	
	eststo clear
	}
	else if `fake'==1{
	eststo: quietly reghdfe lwf1 lw_wrkr_w lw_mngr_w lavw if wg1_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lw_wrkr_w lw_mngr_w lavw if wg`d'_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr7_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
	
	
	esttab
	eststo clear
	}
	** worker on worker manager above below
	if `fake'==0{
	eststo: quietly reghdfe lwf1 lwh_wrkr_w2 lwh_mngr_w2 lwl_wrkr_w2 lwl_mngr_w2 lavw if wg1_extr==0 & wrkr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh_wrkr_w2 lwh_mngr_w2 lwl_wrkr_w2 lwl_mngr_w2 lavw if wg`d'_extr==0 & wrkr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr8_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
    
	esttab
	
	eststo clear
	}
	
	else if `fake'==1{
	eststo: quietly reghdfe lwf1 lw_wrkr_w lw_mngr_w lavw if wg1_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lw_wrkr_w lw_mngr_w lavw if wg`d'_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr8_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
	
	
	esttab
	eststo clear
	}
	** manager on worker manager above below
	if `fake'==0{
	eststo: quietly reghdfe lwf1 lwh_wrkr_w2 lwh_mngr_w2 lwl_wrkr_w2 lwl_mngr_w2 lavw if wg1_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lwh_wrkr_w2 lwh_mngr_w2 lwl_wrkr_w2 lwl_mngr_w2 lavw if wg`d'_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr9_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
	
	esttab
	eststo clear
	
	}
	else if `fake'==1{
	eststo: quietly reghdfe lwf1 lw_wrkr_w lw_mngr_w lavw if wg1_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

	local dur "2 3 5 10"
	foreach d of local dur{

	eststo:	quietly reghdfe lwf`d' lw_wrkr_w lw_mngr_w lavw if wg`d'_extr==0 & mngr==1, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
	}
	esttab using "$log/results_mngr9_w.tex", 	replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
    mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nonumbers mtitles("1" "2" "3" "5" "10")
	
	
	esttab
	eststo clear
	}
	}
	eststo clear
	
*/
}
display _newline
display "****************************************************************************************"
display "* Robustness: Apprenticeships, Unionization, and Censoring
display "****************************************************************************************"


* Unionization
eststo: quietly reghdfe lwf3 lwh lwl lavw if calyr==2000 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr) //benchmark
eststo: quietly reghdfe lwf3 lwh lwl lavw if h44proz>9 & calyr==2000 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr) //pays more than 10% above collective bargaining agreement (on averae)
if `fake'==0{
eststo: quietly reghdfe lwf3 lwh lwl lavw if h42==3 & h43==2 & calyr==2000 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr) // does not have a collective agreement and does not benchmark wages with one
}
if `fake'==1{
eststo: quietly reghdfe lwf3 lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr) // does not have a collective agreement and does not benchmark wages with one
}
esttab using "$log/results_union_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumber ///
mtitles("All 2000" ">10% CB" "No CB, No Benchmarking")

esttab
eststo clear

* Apprentices
eststo: quietly reghdfe lwf3 lwh lwl lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
if `fake'==0{
eststo: quietly reghdfe lwf3 lwh lwl lavw if apprent`g'==0 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
}
else if `fake'==1{
eststo: quietly reghdfe lwf3 lwh lwl lavw, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
}
esttab using "$log/results_apprent_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumber ///
mtitles("Baseline" "Teams w/o Apprentices")

	esttab
	eststo clear

* Top Coding

eststo: quietly reghdfe lwf3 lwh lwl lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
if `fake'==0{
eststo: quietly reghdfe lwf3 lwh lwl lavw if top_code`g'==0 & wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
}
else if `fake'==1{
eststo: quietly reghdfe lwf3 lwh lwl lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
}

esttab using "$log/results_cens_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumber ///
mtitles("Baseline" "Teams w/o Top Coded Wages")

	esttab
	eststo clear


display _newline
display "****************************************************************************************"
display "* Various FE for Robustness Table
display "****************************************************************************************"

egen estoccyr=group(betnr beruf calyr)
egen occyr=group(beruf calyr)
egen estyr=group(betnr calyr)
gen lwd=lwh-lwl

eststo: quietly reghdfe lwf3 lwd lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

if `g'==1{
eststo: quietly reghdfe lwf3 lwd lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr betnr) cluster(betnr)	//baseline
eststo: quietly reghdfe lwf3 lwd lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr estyr) cluster(betnr)	//Team FE
eststo: quietly reghdfe lwf3 lwd lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr occyr) cluster(betnr)	//Occupation x Year
}
if `g'==2{
eststo: quietly reghdfe lwf3 lwd lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr estocc) cluster(betnr)
eststo: quietly reghdfe lwf3 lwd lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr estoccyr) cluster(betnr)
eststo: quietly reghdfe lwf3 lwd lavw if wg3_extr==0, absorb(age_bin ten_bin frau beruf bild calyr occyr) cluster(betnr)
}

esttab using "$log/results_fe_`g'.tex",replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast  nonumber ///
mtitles("Baseline" "Est / Est x Occ FE" "Team-Year" "Occ x Yr" )

esttab
eststo clear


if `g'==2{
display _newline
display "****************************************************************************************"
display " Same Occupation vs Other Occupation (Tabel VI)
display "****************************************************************************************"

		eststo: quietly reghdfe lwf1 lwh1 lwl1 lwh3 lwl3 lavw if wg1_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)

		local dur "2 3 5 10"
		foreach d of local dur{

		eststo: quietly reghdfe lwf`d' lwh1 lwl1 lwh3 lwl3 lavw if wg`d'_extr==0, absorb(age_bin ten_bin frau beruf bild calyr) cluster(betnr)
		}

		esttab using "$log/results_updowng3_`g'.tex", replace se scalars("r2_within Within \(R^{2}\") label b(a2) drop(lavw) booktabs compress obslast ///
		mgroups("Horizon in Years", pattern(1)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		nonumbers mtitles("1" "2" "3" "5" "10")

		esttab
		eststo clear
}

}
*}


    display "*****************************************************"
	display "PRINT ALL TABLES INTO THE LOG FILE"
	display "*****************************************************"

	forval kk=1/2{


	display _newline
	display "main_`kk'"
	display _newline
	type "$log/results_main_`kk'.tex"

	display _newline
	display "updown_`kk'"
	display _newline
	type "$log/results_updown_`kk'.tex"
	
	display _newline
	display "switcher_asym_`kk'"
	display _newline
	type "$log/results_switcher_asym_`kk'.tex"

	display _newline
	display "switcher_asym_II_`kk'"
	display _newline
	type "$log/results_switcher_asym_II_`kk'.tex"

	display _newline
	display "switcher_asym_III_`kk'"
	display _newline
	type "$log/results_switcher_asym_III_`kk'.tex"

	display _newline
	display "switcher_asym_IV_`kk'"
	display _newline
	type "$log/results_switcher_asym_IV_`kk'.tex"

	display _newline
	display "sdec_`kk'"
	display _newline
	type "$log/results_sdec_`kk'.tex"

	display _newline
	display "wdec_`kk'"
	display _newline
	type "$log/results_wdec_`kk'.tex"

	display _newline
	display "adec_`kk'"
	display _newline
	type "$log/results_adec_`kk'.tex"

	display _newline
	display "tdec_`kk'"
	display _newline
	type "$log/results_tdec_`kk'.tex"

	display _newline
	display "bins_`kk'"
	display _newline
	type "$log/results_bins_`kk'.tex"

	display _newline
	display "bins_II_`kk'"
	display _newline
	type "$log/results_bins_II_`kk'.tex"

	display _newline
	display "union_`kk'"
	display _newline
	type "$log/results_union_`kk'.tex"

	display _newline
	display "apprent_`kk'"
	display _newline
	type "$log/results_apprent_`kk'.tex"

	display _newline
	display "cens_`kk'"
	display _newline
	type "$log/results_cens_`kk'.tex"

	display _newline
	display "fe_`kk'"
	display _newline
	type "$log/results_fe_`kk'.tex"

	
	display _newline
	display "updown_growth1_`kk'"
	display _newline
	type "$log/results_updown_growth1_`kk'.tex"

	display _newline
	display "updown_growth2_`kk'"
	display _newline
	type "$log/results_updown_growth2_`kk'.tex"
	
	display _newline
	display "updown_lag_`kk'"
	display _newline
	type "$log/results_updown_lag_`kk'.tex"

	display _newline
	display "hartz_`kk'"
	display _newline
	type "$log/results_updown_hartz_`kk'.tex"
	
	display _newline
	display "hartz2_`kk'"
	display _newline
	type "$log/results_updown_hartz2_`kk'.tex"
	
	}

	display "mngr_4_w"
	display _newline
	type "$log/results_mngr4_w.tex"
	
	display _newline
	display "updowng3_2"
	display _newline
	type "$log/results_updowng3_2.tex"












