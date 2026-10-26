
			
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	use $project/data/clean/2004_v3 ,clear
	
	/*
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	
	assert lswt != 0
	assert lswt != .
	*/
	drop if isco88 == 61 
	drop if isco88 == 62 
	
	
	
	drop if (wage == 0 | wage == .)
	*drop if emp_status > 2
	
	gen hrw = wage/uweeklywh
	
	cap gen lswt = uweeklywh * weight
	
	collapse (median) hrw (rawsum) lswt [aw=weight], by(isco88)
	
	drop if isco88 == .
	
	tempfile lswt2004
	saveold "`lswt2004'.dta", replace
	
	use "/Users/evrengulser/Downloads/Tasks/output2004/isco88.dta", clear
	gen int isco88_1 = isco88 /100
	
	collapse (mean) t*, by(isco88_1)
	
	ren isco88_1 isco88
	
	merge 1:1 isco88 using "`lswt2004'.dta"
	
	#delimit;
	egen nr_cog_anal=rowtotal(t_4A2a4 t_4A2b2 t_4A4a1); 	
	egen nr_cog_pers=rowtotal(t_4A4a4 t_4A4b4 t_4A4b5);	
	egen r_cog=rowtotal(t_4C3b7 t_4C3b4 t_4C3b8_rev);
	egen r_man=rowtotal(t_4C3d3 t_4A3a3 t_4C2d1i);	
	egen nr_man_phys=rowtotal(t_4A3a4 t_4C2d1g t_1A2a2 t_1A1f1);	
	egen nr_man_pers=rowtotal(t_2B1a); 
	replace nr_man_pers=. if t_2B1a==.;	
	#delimit cr		
	drop t_*	
	
	
	
	gen abstract = (nr_cog_anal+nr_cog_pers)/2
	gen routine = (r_cog+r_man)/2
	gen manual = (nr_man_phys+nr_man_pers)/2	

	gen RTI = ln(routine) - ln(abstract) - ln(manual)

	foreach task of varlist nr_cog_anal-RTI {
		summ `task' [aw=lswt]
		replace `task'=[`task'-r(mean)]/r(sd)
		}

	drop _merge	
	order RTI	
	gsort -RTI

	gen lwage = log(hrw)
	order lwage
	
	ren lwage occ_mn_wg
	ren lswt occ_wt



	* Cannot include occs with missing RTI
	assert RTI!=.
	* Assign weights
	sort occ_mn_wg
	summ occ_wt
	egen yrwt=sum(occ_wt)
	gen sharewt=occ_wt/yrwt
	summ occ_wt sharewt

	sort occ_mn_wg
	gen runwt=sum(sharewt)
	gen cumwt=runwt
	replace cumwt=cumwt*100
	summ cumwt

	local occs = _N
	gen left=cumwt[_n-1]
	gen right=cumwt
	replace left=0 in 1
	gen margwt=right-left

	quietly {
	forvalues perc=1(1)100 {

	  gen p`perc'=0
	  forvalues occrank=1(1)`occs' {

		** Four cases
		* 1. Right overlap
		if right[`occrank']>`perc'-1 & right[`occrank']<=`perc' & left[`occrank']<`perc'-1 {
		  replace p`perc'= right-(`perc'-1) in `occrank'
		}

		* 2. Left overlap
		if left[`occrank']>=`perc'-1 & left[`occrank']<`perc' & right[`occrank']> `perc'{
		  replace p`perc'= `perc'-left in `occrank'
		}

		* 3. Full overlap
		if left[`occrank'] <`perc'-1 & right[`occrank']>= `perc' {
		  replace p`perc'= 1 in `occrank'
		}

		* 4. Full underlap (including exact match)
		if left[`occrank'] >= `perc'-1 & right[`occrank'] <= `perc' {
		  replace p`perc'= right-left in `occrank'
		}
	  }
	}
	}

	/*
	  The matrix we now need is psh by occ1990dd
	  We multiply these shares by occupation shares of employment to get
	  the total share in each percentile bin
	  This share is 1 percent in 1980 by construction
	  * Obtain total of shares by percentile
	*/
		

	forvalues perc=1(1)100 {
	  gen psh`perc'=p`perc'/margwt
	  egen empsh`perc'=sum(psh`perc'*margwt)
	}

	gsort -RTI
	order RTI

	gen t = _n
	
	

	gen R33_3a = (t<=9)

	order R33_3a
	gen year = 2004
	
	summ psh* empsh*
	keep isco88 psh1-psh100 R33_3a year
	sort isco88

	* Calculate weighted mean of R33_3a
	forvalues perc=1(1)100 {
		capture drop percwt
		egen percwt=sum(psh`perc')
		* RTI measures that apply to all workers
		foreach v in R33_3a {
			egen perc_`v'_`perc' = sum(psh`perc'*`v'/percwt)
		}
	}

	keep if _n==1
	drop psh* empsh* R*
	desc , f
	reshape long perc_R33_3a_, i(year) j(pctile)
	rename perc_R33_3a_ perc_R33a

	label var perc_R33a "Routine Occupation Share 2004"
	sort pctile
	label data "RSH by Percentile in 2004"
	save RTI-bypctile-2004, replace
	

	
	desc
	summ

	********************************************************************************************************
	** Make plots
	********************************************************************************************************


	set scheme plotplain
	lowess perc_R33a pctile, gen(pdr33) bwidth(.3) 
	keep pdr33 pctile
	merge 1:1 pctile using RTI-bypctile-2012
	drop _merge
	merge 1:1 pctile using RTI-bypctile-2022, nogen
	*drop if pdr33 <0
	
	foreach var of varlist pdr33 pdr33_2022 {
		replace `var' = . if `var' < 0
	}
	
	
	label var pdr33 "Routine Occupation Share"
	
	tw 	line pdr33 pctile, connect(l) lpattern(solid)  msymbol(sh) msymbol(d) msize(vsmall) ///
	||	line pdr33_2022 pctile, connect(l)  lpattern(longdash_dot) msymbol(sh) msymbol(d) msize(vsmall) ///
	legend(  label (1 "2004") label (2 "2022") pos(1) ring(0) rows(3) region(lstyle(outline))) ///
	connect(-) title("", size(medium)) xtitle("Skill Percentile (Ranked by Each Year's Occupational Mean Wage)") ytitle("")  /*ylabel(0(0.10)0.8)*/ l1title("Routine Occupation Share") saving(gph/RTI-byskill-2004.gph, replace) scale(1.5)
	
	graph export fig/routine_occ_share_2004-2022_27august.pdf, replace
	graph export fig/routine_occ_share_2004-2022_27august.png, replace
	
	/*
	
	graph combine gph/RTI-byskill-2004.gph gph/RTI-byskill-2012.gph
	
	* tw scatter pdr33 pctile, connect(l) lpattern(solid) msymbol(sh) msymbol(d) msize(vsmall) /* title("Routine Task Intensity by Occupational Skill Percentile", size(medium)) */ xtitle("Skill Percentile (Ranked by 1980 Occupational Mean Wage)") ytitle("")  ylabel(0(0.10)0.7) l1title("Routine Occupation Share") saving(../gph/RTI-byskill-1980-czall-notitle.gph, replace)
	/*

	clear

	log close
