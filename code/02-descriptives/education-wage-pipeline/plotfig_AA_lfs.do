/*

********************************************************************************
* This file plots composition adjusted wages by education from 1963-2017 for
* males and females. It creates Figure 1 in the paper.
*
* Input files: pred-marwg-6318.dta
* Output files: comp-adj-lnwgs-`sex'-1963-2018.gph
* 
* Requires ado package
* package name:  grc1leg2.pkg
*         from:  http://digital.cgdev.org/doc/stata/MO/Misc/
********************************************************************************


# delimit ;
set more 1;

local workdir "/Users/evrengulser/Desktop/JOB/Papers_with_replication_files/Work_of_the_past_work_of_the_future/rep_files";
local figdir = "`workdir'/fig";
local data = "`workdir'/dta";

capture log close;
set logtype text;

log using "`workdir'/log/fig-plot-wage-changes",text replace;
pause on;


***************;
* Plots       *;
***************;

* First plot log wages*
cd "`workdir'/do";
use "../dta/pred-marwg-6317.dta", clear;
desc;


*/

	
	clear all
	
	global project /Users/evrengulser/Desktop/TUIKDATA/raw/LFS
	cd $project
	
	local workdir 	"/Users/evrengulser/Desktop/TUIKDATA/workdir/lfs"
	local figdir 	"/Users/evrengulser/Desktop/TUIKDATA/figdir/lfs"
	
	
	local by 04
	local ly 20
	
	use $project/tmp/pred-wg-`by'`ly', clear
	
	*gen rlnwinc = ln(exp(rlnminc)/4.33)

	local educ1 noschl 		
	local educ2	primsch 		
	local educ3 highsc 
	local educ4 vochighschl  
	local educ5 univschl
	
	local label1 Below Primary School
	local label2 Primary School Graduate
	local label3 High School Graduate
	local label4 Vocational High School Graduate
	local label5 College Graduate

	/*
	local wage1 rwage_month
	local wage2 lnrwage_month
	local wage3 rwage_week
	local wage4 lnrwage_week
	local wage5 rwage_hour
	local wage6 lnrwage_hour
	*/
	local wage1 rplnwkw
	local wage2 rplnhrw
	local wage3 plnwkw
	local wage4 plnhrw
	
	local `wage2' rplnwkw
		
	local baseyear 2004
	local lastyear 2020
	
	local excyear1 2025 // purposefully chosen wrong years
	local excyear2 2026	// purposefully chosen wrong years
				
	# delimit ;
	
	forval x=0/1
	{;
		forval y=1/5
		{;
			forval yr=`baseyear'/`lastyear'
			{;
				if `yr' != `excyear1' & `yr' != `excyear2'
				{;
					summ rplnwkw [aw=avlswt] if female==`x' & edcat5==`y' & year==`yr';
					if `yr'==`baseyear' gen ln_mn_wg_`x'_`y'=r(mean) if year==`yr';
					if `yr'!=`baseyear' replace ln_mn_wg_`x'_`y'=r(mean) if year==`yr';
				};
				
			};
		
		if `y'==1 label var ln_mn_wg_`x'_`y' "`educ1'";
		if `y'==2 label var ln_mn_wg_`x'_`y' "`educ2'";
		if `y'==3 label var ln_mn_wg_`x'_`y' "`educ3'";
		if `y'==4 label var ln_mn_wg_`x'_`y' "`educ4'";
		if `y'==5 label var ln_mn_wg_`x'_`y' "`educ5'";
		};
	};
	
	bys year: keep if _n==1;
	
	/* Normalize to one in 2002 : create relative wages */
	sort year;
	foreach var of varlist ln_mn_wg*
	{;
		local x=`var'[_n==1];
		replace `var'=`var'-`x';
	};
	
	/*
	
	twoway c ln_mn_wg_0_1 ln_mn_wg_0_2 ln_mn_wg_0_3 ln_mn_wg_0_4 
				ln_mn_wg_0_5 year, 
				lwidth(thick thick thick thick thick thick thick thick )
				lcolor("202 0 32" "244 165 130" gs10 "146 197 222" "5 113 176" plb1 plr1 plg1) 
				xtitle("") xlabel(`baseyear' (4) `lastyear', labsize(small))
				yscale(range(0 .6)) ylabel(0(.1).6, format(%9.1f) angle(horizontal) 
				nogrid) ytick(0(.1).6) yline(0 .1 .2 .3 .4 .5 .6,
				lpattern(dash) lcolor(gs15)) title("Log Mean Wages, Men")
				legend(rows(2) 
				label(1 `label1') 
				label(2 `label2') 
				label(3 `label3') 
				label(4 `label4') 
				label(5 `label5') 
				size(small)) 
				saving("`workdir'/gph/Fig_1a_comp-adj-lnwgs-educ5-m-`baseyear'-`lastyear'.gph",replace);
				graph export "`figdir'/Fig_1a_comp-adj-lnwgseduc5-m-`baseyear'-`lastyear'.pdf", replace;	
				
				
	*/			
				
				* Figure 4a;

			twoway connected ln_mn_wg_0_1 ln_mn_wg_0_2 ln_mn_wg_0_3 ln_mn_wg_0_4 ln_mn_wg_0_5 
			year, xlabel(2004(4)2020)  ytick(0(0.05)0.8, grid) 
			title("Real, Composition-Adjusted Log Weekly Wages for Full-Time Full-Year Workers" "`baseyear'-`lastyear' Males", size(med))
			ytitle("Composition-Adjusted Real Log Weekly Wages",  size(small)) xtitle("Year", size(small)) msymbol(O S D T X)
			saving(`workdir'/AA_fig4a-comp-adj-lnwgs-m-`baseyear'-`lastyear'.gph, replace);
			graph export "`figdir'/AA_fig4a-comp-adj-lnwgs-m-`baseyear'-`lastyear'.eps", replace;	
			
				* Figure 4b;
			
			twoway connected ln_mn_wg_1_1 ln_mn_wg_1_2 ln_mn_wg_1_3 ln_mn_wg_1_4 ln_mn_wg_1_5 ///
			year, xlabel(2004(4)2020) ytick(0(0.05)0.8, grid) 
			title("Real, Composition-Adjusted Log Weekly Wages for Full-Time Full-Year Workers" "`baseyear'-`lastyear' Females", size(med))
			ytitle("Composition-Adjusted Real Log Weekly Wages", size(small)) xtitle("Year", size(small)) msymbol(O S D T X)
			saving(`workdir'/AA_fig4b-comp-adj-lnwgs-f-`baseyear'-`lastyear'.gph, replace);
			graph export "`figdir'/AA_fig4b-comp-adj-lnwgs-f-`baseyear'-`lastyear'.eps", replace;	
	
	/*
	
			*saving(fig4b-comp-adj-lnwgs-f-1963-2008.gph, replace);    
			
	/*		
				
	twoway line ln_mn_wg_1_1 ln_mn_wg_1_2 ln_mn_wg_1_3 ln_mn_wg_1_4 
				ln_mn_wg_1_5 year, 
				lwidth(thick thick thick thick thick thick thick thick )				
				lcolor("202 0 32" "244 165 130" gs10 "146 197 222" "5 113 176" plb1 plr1 plg1) 
				xtitle("") xlabel(`baseyear' (4) `lastyear', labsize(small))
				yscale(range(0 .6)) ylabel(0(.1).6, format(%9.1f) angle(horizontal) 
				nogrid) ytick(0(.1).6) yline(0 .1 .2 .3 .4 .5 .6,
				lpattern(dash) lcolor(gs15)) title("Log Mean Wages, Women")
				legend(rows(2) 
				label(1 `label1') 
				label(2 `label2') 
				label(3 `label3') 
				label(4 `label4') 
				label(5 `label5') 
				size(small))
				saving("`workdir'/gph/Fig_1b_comp-adj-lnwgs-educ5-f-`baseyear'-`lastyear'.gph",replace);
				graph export "`figdir'/Fig_1b_comp-adj-lnwgs-educ5-f-`baseyear'-`lastyear'.pdf", replace;			
	
	
	grc1leg2 "`workdir'/gph/Fig_1a_comp-adj-lnwgs-educ5-m-`baseyear'-`lastyear'.gph" 
	"`workdir'/gph/Fig_1b_comp-adj-lnwgs-educ5-f-`baseyear'-`lastyear'.gph", 
	rows(1) legendfrom(	"`workdir'/gph/Fig_1b_comp-adj-lnwgs-educ5-f-`baseyear'-`lastyear'.gph") 
	saving("`workdir'/gph/Fig_1_comp-adj-lnwgs-educ5-f-`baseyear'-`lastyear'.gph",replace);
	graph display, ysize(8) xsize(12);
	graph export "`figdir'/Fig_1_comp-adj-lnwgs-educ5-mf-`baseyear'-`lastyear'.pdf", replace;
	
	
	capture log close;

