
		
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	
	use $project/data/clean/2004_v3 ,clear
	
	gen lswt = uweeklywh * weight
	
	
	local minwage2004 (303+318)/2
	local minwage2008 (481+503)/2
	local minwage2012 (701+739)/2
	local minwage2016 1404
	local minwage2022 (5500+4253)/2
	local skillproxy 	wage
	local skillproxy2 	wage/uweeklywh
	local skillproxy3 	educat5	
	local skillproxy4	wage_v2/uweeklywh
	
	local stat1 mean
	local stat2 median

	
	su wage_v2 if wage_v2 != 0
	su rwage if rwage != 0
	
	
	drop if wage_v2 < `minwage2004' * 0.75
	su rwage if rwage != 0
	
	* Compute the hours-weighted mean log wage in each occupation
	* gen lwage = log(`skillproxy2')
	
	* drop if occupation == 61 // excluding agriculture
	* drop if occupation == 62 // excluding agriculture
	
	collapse (count) num_obs = lswt (`stat2') wage (sum) lswt [pw = weight] , by(isco88 year)
	drop if isco88 == .
	
	* Make sure there's at least 50 observations for each occupation
	drop if num_obs <=50
	assert num_obs >= 50
	drop num_obs

	tempfile lswt2004
	save "`lswt2004'.dta", replace
	
	

	/*
	
	
	local y = 2004
	use `y',clear
	collapse (sum) lswt, by(occupation year)
	ren occupation occ08 
	sort occ08
	tempfile lswt`y'
	save "`lswt`y''.dta", replace
	
	use "/Users/evrengulser/Downloads/Tasks/out/isco08_tasks.dta", clear

	merge m:m occ08 using "`lswt`y''.dta" 
	
	tab _merge
	drop if _merge < 3
	drop _merge
	
	order year isco08 occ08 lswt 
	
	*/


	use "/Users/evrengulser/Downloads/Tasks/output2004/isco88.dta", clear
	gen int isco88_1 = isco88 /100
	
	collapse (mean) t*, by(isco88_1)
	
	ren isco88_1 isco88
	
	merge 1:1 isco88 using "`lswt2004'.dta"
	
	drop if _merge != 3
	
	drop _merge
	
	
		/* Non-routine cognitive: Analytical */
	/* 
	
	4.A.2.a.4 Analyzing data/information
	4.A.2.b.2 Thinking creatively
	4.A.4.a.1 Interpreting information for others 
	
	*/

	#delimit;
	egen nr_cog_anal=rowtotal(t_4A2a4 t_4A2b2 t_4A4a1); 
	
	/* Non-routine cognitive: Interpersonal */
	/*
	
	4.A.4.a.4 Establishing and maintaining personal relationships
	4.A.4.b.4 Guiding, directing and motivating subordinates 
	4.A.4.b.5 Coaching/developing others
	
	*/
	
	egen nr_cog_pers=rowtotal(t_4A4a4 t_4A4b4 t_4A4b5);
	
	/* Routine cognitive */
	/*
	
	4.C.3.b.7 Importance of repeating the same tasks
	4.C.3.b.4 Importance of being exact or accurate
	4.C.3.b.8 Structured v. Unstructured work (reverse)
	
	*/
	
	egen r_cog=rowtotal(t_4C3b7 t_4C3b4 t_4C3b8_rev);
	
	/* Routine manual */
	/*
	
	4.C.3.d.3 Pace determined by speed of equipment
	4.A.3.a.3 Controlling machines and processes 
	4.C.2.d.1.i Spend time making repetitive motions 
	
	*/
	
	
	egen r_man=rowtotal(t_4C3d3 t_4A3a3 t_4C2d1i);
	
	/* Non-routine manual: phys. adaptability */
	/*
	
	4.A.3.a.4 Operating vehicles, mechanized devices, or equipment
	4.C.2.d.1.g Spend time using hands to handle, control or feel objects, tools or controls
	1.A.2.a.2 Manual dexterity
	1.A.1.f.1 Spatial orientation
	
	*/
	
	egen nr_man_phys=rowtotal(t_4A3a4 t_4C2d1g t_1A2a2 t_1A1f1);
	
	/* Non-routine manual: interpersonal adaptability */
	/* 
	2.B.1.a Social Perceptiveness*/
	

	egen nr_man_pers=rowtotal(t_2B1a); 
	replace nr_man_pers=. if t_2B1a==.;
	
	#delimit cr
		
	drop t_*

	/*
	foreach task of varlist nr_cog_anal-nr_man_pers {
		summ `task' [aw=lswt]
		replace `task'=[`task'-r(mean)]/r(sd)
		summ `task' 
	}
	*/
	
	replace nr_cog_anal = nr_cog_anal/3
	replace nr_cog_pers = nr_cog_pers/3
	replace r_cog 		= r_cog/3
	replace r_man 		= r_man/3
	replace nr_man_phys = nr_man_phys/4

	
	gsort -nr_cog_anal
	gen abstract	= (nr_cog_anal + nr_cog_pers)/2
	gen manual 		= nr_man_phys 
	
	drop nr_cog*
	drop nr_man*
	
	foreach task of varlist r_cog r_man abstract manual {
		summ `task' [aw=lswt]
		replace `task'=[`task'-r(mean)]/r(sd)
		summ `task' 
	}
	
	gsort -manual

	order isco88 abstract r_cog r_man manual
	
	gen occ_r_cog 		= 0
	gen occ_abstract	= 0
	gen occ_r_man 		= 0
	gen occ_manual 		= 0	
	
	
	foreach var of varlist abstract-manual {
		forval i = 1/24 {
			if `var'>=abstract in `i' {
				if `var'>=manual in `i' {
					if `var'>=r_man in `i' {
						if `var'>=r_cog in `i' {
							replace occ_`var' = 1 in `i'
						}
					}	
				}
			}
		}
	}
	
	gen occtask = occ_abstract + 2*occ_r_cog + 3*occ_r_man + 4*occ_manual
	keep isco88 occtask
	
	tempfile iscotask
	saveold "`iscotask'.dta", replace

	
	/*
	
	gen occ_abstract 	= 0
	gen occ_r_cog		= 0
	gen occ_r_man		= 0
	gen occ_manual		= 0
	
	forvalues i = 1/25 {
		foreach task1 of varlist abstract-manual {
			foreach task2 of varlist abstract-manual {
				replace occ_`task1' = (`task1'>`task2')
		}
	}
	*/
	
	
	/*
	tw 	bar abstract isco88 || bar r_cog isco88 ///
		|| bar r_man isco88 || bar manual isco88, mlabel(isco88)
	*/
	/*
	gen occtask = 1 in 1
	replace occtask = 1 if isco88 == 23
	replace occtask = 1 if isco88 == 22
	replace occtask = 1 if isco88 == 24
	replace occtask = 1 if isco88 == 11
	replace occtask = 1 if isco88 == 12
	replace occtask = 1 if isco88 == 31
	replace occtask = 1 if isco88 == 13
	replace occtask = 1 if isco88 == 21
	replace occtask = 1 if isco88 == 34
	replace occtask = 1 if isco88 == 32
	replace occtask = 1 if isco88 == 51
	replace occtask = 1 if isco88 == 52
	
	replace occtask = 2 if isco88 == 42
	replace occtask = 2 if isco88 == 41

	replace occtask = 3 if isco88 == 74
	replace occtask = 3 if isco88 == 82
	replace occtask = 3 if isco88 == 81	
	replace occtask = 3 if isco88 == 73
	
	replace occtask = 4 if isco88 == 83	
	replace occtask = 4 if isco88 == 91
	replace occtask = 4 if isco88 == 61
	replace occtask = 4 if isco88 == 92	
	replace occtask = 4 if isco88 == 71
	replace occtask = 4 if isco88 == 72	
	replace occtask = 4 if isco88 == 93
	*/
	
	
	
	
	foreach num of numlist 2004(4)2016 2022 {
		use $project/data/clean/`num'_v3 ,clear
			
		gen 	ind_broad = 0
		replace ind_broad = 1 if inlist(sector, 1, 2, 3)
		replace ind_broad = 2 if inlist(sector, 5, 6, 7, 8, 9)
		replace ind_broad = 3 if inlist(sector, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33)
		replace ind_broad = 4 if  inlist(sector, 35)
		replace ind_broad = 5 if  inlist(sector, 36, 37, 38, 39)
		replace ind_broad = 6 if  inlist(sector, 41, 42, 43)
		replace ind_broad = 7 if  inlist(sector, 45, 46, 47)
		replace ind_broad = 8 if  inlist(sector, 49, 50, 51, 52, 53)
		replace ind_broad = 9 if  inlist(sector, 55, 56)
		replace ind_broad = 10 if inlist(sector, 58, 59, 60, 61, 62, 63)
		replace ind_broad = 11 if inlist(sector, 64, 65, 66)
		replace ind_broad = 12 if inlist(sector, 68)
		replace ind_broad = 13 if inlist(sector, 69, 70, 71, 72, 73, 74, 75)
		replace ind_broad = 14 if inlist(sector, 77, 78, 79, 80, 81, 82)
		replace ind_broad = 15 if inlist(sector, 84)
		replace ind_broad = 16 if inlist(sector, 85)
		replace ind_broad = 17 if inlist(sector, 86, 87, 88)
		replace ind_broad = 18 if inlist(sector, 90, 91, 92, 93)
		replace ind_broad = 19 if inlist(sector, 94, 95, 96)
		replace ind_broad = 20 if inlist(sector, 97, 98)
		replace ind_broad = 21 if inlist(sector, 99)
		tab ind_broad
		drop if ind_broad == 0
		
		gen 	ind_broad_4 = .
		replace ind_broad_4	= 1 if ind_broad == 1
		replace ind_broad_4	= 2 if inrange(ind_broad, 2, 5)
		replace ind_broad_4	= 3 if ind_broad == 6
		replace ind_broad_4	= 4 if inrange(ind_broad, 7, 21)
		
		quietly label define ind_broad_4 ///
		1 "Agriculture" ///
		2 "Manufacturing" ///
		3 "Construction" ///
		4 "Services" 
		
		label values ind_broad_4 ind_broad_4
		tab ind_broad_4	
		
		gen lswt = uweeklywh * wage
		
		saveold $project/data/clean/`num'_v4, replace
	
    }

	
	
	foreach y of numlist 2004(4)2012 {
		use $project/data/clean/`y'_v4, clear
		drop if wage_v2 < `minwage`y'' * 0.75
		gen occupation = isco88
		drop if occupation == .
		collapse (sum) lswt (mean) uweeklywh rwage, by(year ind_broad_4 occupation)
		tempfile emp`y'
		saveold "`emp`y''.dta", replace
	}
	
	* Combine across years
	
	foreach y of numlist 2004(4)2012 {
		if `y' == 2004 {
			use "`emp`y''.dta"
		}
		else {
			append using "`emp`y''.dta"
		}
	}
	
	
	/* Collapse into occ cells */
	
	*keep if ind_broad_4 == 2
	gen isco88 = occupation
	
	/*
	
qui{	
	gen occtask = 1 in 1
	replace occtask = 1 if isco88 == 23
	replace occtask = 1 if isco88 == 22
	replace occtask = 1 if isco88 == 24
	replace occtask = 1 if isco88 == 11
	replace occtask = 1 if isco88 == 12
	replace occtask = 1 if isco88 == 31
	replace occtask = 1 if isco88 == 13
	replace occtask = 1 if isco88 == 21
	replace occtask = 1 if isco88 == 34
	replace occtask = 1 if isco88 == 32
	replace occtask = 1 if isco88 == 51
	replace occtask = 1 if isco88 == 52
	
	replace occtask = 2 if isco88 == 42
	replace occtask = 2 if isco88 == 41

	replace occtask = 3 if isco88 == 74
	replace occtask = 3 if isco88 == 82
	replace occtask = 3 if isco88 == 81	
	replace occtask = 3 if isco88 == 73
	
	replace occtask = 4 if isco88 == 83	
	replace occtask = 4 if isco88 == 91
	replace occtask = 4 if isco88 == 61
	replace occtask = 4 if isco88 == 92	
	replace occtask = 4 if isco88 == 71
	replace occtask = 4 if isco88 == 72	
	replace occtask = 4 if isco88 == 93		
}	
	*/
	

	
	tempfile workingdata 
	saveold "`workingdata'.dta", replace	
	merge m:1 isco88 using "`iscotask'.dta"
	
	
	forval sector = 2(2)4 {
		use "`workingdata'.dta", clear
		merge m:1 isco88 using "`iscotask'.dta"
		
		keep if ind_broad_4 == `sector'  

		if `sector' == 2 {
			local ind "Manufacturing"
		}
		
		if `sector' == 4{
			local ind "Services"
		}
			
		drop if occtask == .	
		collapse (rawsum) lswt , by(year occtask)	
		drop if occtask == .	
		*gen rweeklywage = rwage/uweeklywh

		* Calculate employment share */
		bys year: egen tot_emp=total(lswt)
		gen sh_emp=lswt/tot_emp
		
		drop lswt tot_emp
		
		/* Reshape */

		reshape wide sh_emp, i(year) j(occtask)
		
		label var sh_emp1 "Abstract" 
		label var sh_emp2 "Routine cognitive"
		label var sh_emp3 "Routine manual"
		label var sh_emp4 "Manual"

		local lw thick
		local lc black
		/* Plot sh_emp*/ 

		twoway 	line sh_emp* year,  lpattern(l -  dash_dot dot) ///
				lw(`lw' `lw' `lw' `lw') lc(`lc' `lc' `lc' `lc') ///
				xlabel(2004(4)2012) ///
				xtitle("Year") ytitle("Employement Share") ///
				title("`ind'", ///
				size(medium)) ylabel(0(.1).7) legend( pos(6) ring(1) rows(1)  ///
				region(lstyle(outline)))  ytick(0(.1).7, grid)	saving(task`ind'.gph, replace)
	}
	
	
		use "`workingdata'.dta", clear
		merge m:1 isco88 using "`iscotask'.dta"
		
		keep if ind_broad_4 == 2 | ind_broad_4 == 4 
		
		local ind Economy
			
		drop if occtask == .	
		collapse (rawsum) lswt , by(year occtask)	
		drop if occtask == .	

		* Calculate employment share */
		bys year: egen tot_emp=total(lswt)
		gen sh_emp=lswt/tot_emp
		
		drop lswt tot_emp
		
		/* Reshape */

		reshape wide sh_emp, i(year) j(occtask)
		
		label var sh_emp1 "Abstract" 
		label var sh_emp2 "Routine cognitive"
		label var sh_emp3 "Routine manual"
		label var sh_emp4 "Manual"

		local lw thick
		local lc black
		/* Plot sh_emp*/ 

		twoway 	line sh_emp* year,  lpattern(l -  dash_dot dot) ///
				lw(`lw' `lw' `lw' `lw') lc(`lc' `lc' `lc' `lc') ///
				xlabel(2004(4)2012) ///
				xtitle("Year") ytitle("Employement Share") ///
				title("`ind'", ///
				size(medium)) ylabel(0(.1).7) legend( pos(6) ring(1) rows(1)  ///
				region(lstyle(outline)))  ytick(0(.1).7, grid)	saving(task`ind'.gph, replace)
	
		grc1leg taskEconomy.gph taskManufacturing.gph taskServices.gph, rows(1) ///
		imargin(0 0 0) ycommon xcommon legendfrom(taskServices.gph)
		
		graph export $project/fig/fonseca5.pdf ,replace
		
						
	/*
	graph export `figdir'/3/ind_broad_4_share-growth.eps, replace
	graph export `figdir'/3/ind_broad_4_share-growth.pdf, replace	
	
	
	
	* saveold `path_out'/tempdata2004.dta, replace
	
	