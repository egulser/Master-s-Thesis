		
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	
	use $project/data/clean/2004_v3 ,clear
	

	
	capture gen lswt = uweeklywh * weight	
	
	local minwage2004 (303+318)/2
	local minwage2008 (481+503)/2
	local minwage2012 (701+739)/2	
	
	local skillproxy 	wage
	local skillproxy2 	wage/uweeklywh
	local skillproxy3 	educat5	
	
	local stat1 mean
	local stat2 median
	/*
	if year == 2004 {
	drop if wage < (`minwage2004' * 0.75) 
	}
	if year == 2012 {
	drop if wage < (`minwage2012' * 0.75)
	}
	*/
	drop if parttime
	tab isco88 [aw=weight]
	drop if isco88 == 33 | isco88 == 62 | isco88 == 61 | isco88 == 13 
	
	
	drop if wage == 0
	drop if wage == .
	tab isco88 year [aw=lswt]
	
	
	
	/*
	local ind ind_broad_4		
	gen 	ind_broad_4 = 0
	replace ind_broad_4	= 1 if inrange(sector, 1,3)
	replace ind_broad_4	= 2 if inrange(sector, 5, 39)
	replace ind_broad_4	= 3 if inrange(sector, 41, 43)
	replace ind_broad_4	= 4 if inrange(sector, 45, 99)
	assert ind_broad_4 != 0
	*/
	/*
	gen ind_broad_2 = 0
	replace ind_broad_2 = 1 if ind_broad_4 == 2
	replace ind_broad_2 = 2 if ind_broad_4 == 4
	drop if ind_broad_2 == 0
	*/
	
	* drop if ind_broad_4 == 1 
	* drop if ind_broad_4 == 3
	
	tempfile lswtuncollapsed
	saveold "`lswtuncollapsed'.dta", replace
	
	collapse (count) num_obs = lswt (`stat2') rwage (rawsum) lswt , by(isco88 year)
	drop if isco88 == .
	
	* Make sure there's at least 50 observations for each occupation
	/*
	drop if num_obs <=50
	assert num_obs >= 50
	drop num_obs
	*/

	save lswt2004.dta, replace

	use "/Users/evrengulser/Downloads/Tasks/output2004/isco88.dta", clear
	gen int isco88_1 = isco88 /100
	
	collapse (mean) t*, by(isco88_1)
	
	ren isco88_1 isco88
	
	*merge m:m isco88 using "`lswtuncollapsed'.dta"
	
	merge 1:1 isco88 using lswt2004.dta
	
	drop if _merge != 3
	
	drop _merge
	
	do do/task_construct.do

	egen tot_emp=total(lswt)
	gen sh_emp=lswt/tot_emp*100		
	
	
	
	saveold tasks2004 ,replace
************************************************
************************************************	
************************************************
************************************************	
	*drop lswt tot_emp

	
	use $project/data/clean/2012_v3 ,clear
	
	capture gen lswt = uweeklywh * weight	
	
	local minwage2004 (303+318)/2
	local minwage2008 (481+503)/2
	local minwage2012 (701+739)/2	
	
	local skillproxy 	wage
	local skillproxy2 	wage/uweeklywh
	local skillproxy3 	educat5	
	
	local stat1 mean
	local stat2 median
	
	/*
	
	if year == 2004 {
	drop if wage < (`minwage2004' * 0.75) 
	}
	if year == 2012 {
	drop if wage < (`minwage2012' * 0.75)
	}
	*/
	drop if parttime
	tab isco88 [aw=weight]
	drop if isco88 == 33 | isco88 == 62 | isco88 == 61 | isco88 == 13 
	
	drop if wage == 0
	drop if wage == .
	tab isco88 year [aw=lswt]
	
	tab isco88 year [aw=lswt], col
	
	/*
	local ind ind_broad_4		
	gen 	ind_broad_4 = 0
	replace ind_broad_4	= 1 if inrange(sector, 1,3)
	replace ind_broad_4	= 2 if inrange(sector, 5, 39)
	replace ind_broad_4	= 3 if inrange(sector, 41, 43)
	replace ind_broad_4	= 4 if inrange(sector, 45, 99)
	assert ind_broad_4 != 0
	*/
	/*
	gen ind_broad_2 = 0
	replace ind_broad_2 = 1 if ind_broad_4 == 2
	replace ind_broad_2 = 2 if ind_broad_4 == 4
	drop if ind_broad_2 == 0
	*/
	
	* drop if ind_broad_4 == 1 
	* drop if ind_broad_4 == 3
	
	tempfile lswtuncollapsed2012
	saveold "`lswtuncollapsed2012'.dta", replace
	
	collapse (count) num_obs = lswt (`stat2') rwage (rawsum) lswt , by(isco88 year)
	drop if isco88 == .
	
	* Make sure there's at least 50 observations for each occupation
	/*
	drop if num_obs <=50
	assert num_obs >= 50
	drop num_obs
	*/

	save lswt2012.dta, replace

	use "/Users/evrengulser/Downloads/Tasks/output2012/isco88.dta", clear
	gen int isco88_1 = isco88 /100
	
	collapse (mean) t*, by(isco88_1)
	
	ren isco88_1 isco88
	
	*merge m:m isco88 using "`lswtuncollapsed'.dta"
	
	merge 1:1 isco88 using lswt2012.dta
	
	drop if _merge != 3
	
	drop _merge
	
	do do/task_construct.do

	egen tot_emp=total(lswt)
	gen sh_emp=lswt/tot_emp*100		
	
	append using tasks2004
	
	saveold tasks2012, replace
	
	
	********* 
	********* ÇOK ÖNEMLi ||
	*********
	
	set scheme plotplain
	
	tw sc  	nr_cog_anal rwage , mlabel(isco88)   							///
	|| qfitci nr_cog_anal rwage [aw=lswt] , by(year, leg(off) note(""))  	/// 
	ciplot(rline) clp(solid) alpattern(shortdash)  							///
	saving(nr_cog_anal.gph, replace) ytitle(Non-routine cognitive analytical) xtitle("") 
	
			
	tw sc  	nr_cog_pers rwage , mlabel(isco88) 					///
	|| qfitci nr_cog_pers rwage, by(year, leg(off) note(""))  	///
	ciplot(rline) clp(solid) alpattern(shortdash)  				///
	saving(nr_cog_pers.gph, replace)	ytitle(Non-routine cognitive personal) xtitle("")
	
	tw sc  	r_cog rwage , mlabel(isco88) 						///
	|| qfitci r_cog rwage, by(year, leg(off) note(""))  		///
	ciplot(rline) clp(solid) alpattern(shortdash)  				///
	saving(r_cog.gph, replace)	ytitle(Routine cognitive) xtitle("")
						
	tw sc  	r_man rwage , mlabel(isco88) 						///
	|| qfitci r_man rwage, by(year, leg(off) note(""))  		///
	ciplot(rline) clp(solid) alpattern(shortdash)  				///
	saving(r_man.gph, replace)ytitle(Routine manual) xtitle("")
		
	tw sc  	nr_man_phys rwage , mlabel(isco88) 					///
	|| qfitci nr_man_phys rwage, by(year, leg(off) note(""))  	///
	ciplot(rline) clp(solid) alpattern(shortdash)  				///
	saving(nr_man_phys.gph, replace) ytitle(Non-routine manual physical) 	xtitle("")
		
	tw sc  	nr_man_pers rwage , mlabel(isco88) 					///
	|| qfitci nr_man_pers rwage, by(year, leg(off) note(""))  	///
	ciplot(rline) clp(solid) alpattern(shortdash)  				///
	saving(nr_man_pers.gph, replace)	ytitle(Non-routine manual personal)	xtitle("")
	
	graph combine nr_cog_anal.gph nr_cog_pers.gph r_cog.gph r_man.gph nr_man_phys.gph nr_man_pers.gph, cols(2)

	graph export $project/fig/alltasks_rwage_2004_2012.pdf, replace
	
	
	*drop lswt tot_emp
	
	foreach var in nr_cog_anal nr_cog_pers {
		qui sum `var'
		replace `var' = (`var' - `r(min)') / (`r(max)'-`r(min)')

	}
	
	
	
	
/*	
	
	
	* Occupation task links using tagging occupations based on their highest task value
	
	gen occ_nr_cog_anal  	= 0
	gen occ_nr_cog_pers  	= 0
	gen occ_r_cog  			= 0	
	gen occ_r_man 	 		= 0
	gen occ_nr_man_phys 	= 0
	gen occ_nr_man_pers 	= 0
	
		
	foreach var of varlist nr_cog_anal-nr_man_pers {
		forval i = 1/23 {
			if `var'>=nr_cog_anal in `i' {
				if `var'>=nr_cog_pers in `i' {
					if `var'>=r_man in `i' {
						if `var'>=r_cog in `i' {
							if `var'>=nr_man_phys in `i' {
								if `var'>=nr_man_pers in `i' {
									replace occ_`var' = 1 in `i'
								}
							}	
						}
					}	
				}
			}
		}
	}
	
	gen occtask = occ_nr_cog_anal + 2*occ_nr_cog_pers + 3*occ_r_cog + 4*occ_r_man + 5*occ_nr_man_phys + 6*occ_nr_man_pers
	
	/*
	
	egen tot_emp=total(lswt)
	gen sh_emp=lswt/tot_emp*100		
	*drop lswt tot_emp
	
	collapse (rawsum) sh_emp , by(occtask)
	
	/*
	replace sh_emp= sh_emp*100
	order sh_emp isco88 occtask
	
	egen tot_emp_task = total(sh_emp), by(occtask)
	order tot_emp_task*
	
	collapse (mean) tot_emp_task , by(occtas)
	*/

	keep isco88 occtask lswt sh_emp
	tempfile iscotask
	saveold iscotask.dta ,replace
	
	*/
	
	keep year isco88 occtask
	sort isco88 
	saveold iscotask.dta ,replace
	

	