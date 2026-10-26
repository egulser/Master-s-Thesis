**# Bookmark #1
		
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	
	use $project/data/clean/2004_v3 ,clear
	
	append using $project/data/clean/2012_v3
	
	tempfile year2
	
	gen lswt  = uweeklywh * weight
	
	collapse (mean) rwage (rawsum) lswt [aw=weight] , by(isco88 year)
	
	drop if rwage ==.
	drop if rwage ==0
	*drop if isco88 == 13 
	drop if isco88 == 61
	drop if isco88 == 62
	drop if isco88 == 92
	
	tab isco88 year
	sort year
	
	preserve 
	
	drop if year == 2004
	gen year2012 = year
	gen lswt2012 = lswt
	gen rwage2012 = rwage
	
	saveold `year2', replace
	
	restore
	
	drop if year == 2012
	merge 1:1 isco88 using `year2'
	
	gen lswt2004 = lswt 
	
	egen tot_emp_2004 = total(lswt2004)
	gen sh_2004 = lswt2004/tot_emp_2004*100	
	drop lswt2004 tot_emp_2004
	
	egen tot_emp_2012 = total(lswt2012)
	gen sh_2012 = lswt2012/tot_emp_2012*100	
	drop  lswt2012 tot_emp_2012	
		
	gen logrw2004 = log(rwage)
	gen logrw2004_sq = (log(rwage))^2
	gen logdif_wage_p1 = log(rwage2012)-log(rwage)

	drop _merge
	
	merge 1:1 isco88 using "/Users/evrengulser/Desktop/TUIKDATA/27july/tasks2004.dta"	
	drop if _merge != 3
	drop _merge
	
	merge 1:1 isco88 using "/Users/evrengulser/Desktop/TUIKDATA/27july/rti_piaac_isco88.dta"
	drop if _merge != 3
	
	drop if sh_emp 	== .
	drop if num_obs == .

	gen rti  = ((r_cog+r_man)/2) - ((nr_cog_anal+nr_cog_pers)/2) - ((nr_man_pers+nr_man_phys)/2)
	
	gen abstract  	= isco88_mean_abs
	gen routine  	= isco88_mean_rou
	gen manual  	= isco88_mean_man
	
	gen rti_piaac = routine - abstract - manual
	
	gen rwage2004 = rwage
	replace sh_2012 = sh_emp
	
	gen logdif_emp_p1 = log(sh_2012)-log(sh_2004) 
	

	
	replace logdif_emp_p1 = -0.32503864 if isco88 	== 11
	replace logdif_emp_p1 =	0.42211631  if isco88	== 12
	replace logdif_emp_p1 =	0.40116364  if isco88	== 21
	replace logdif_emp_p1 =	0.57850295  if isco88	== 22
	replace logdif_emp_p1 =	0.03258796  if isco88	== 23
	replace logdif_emp_p1 =	0.06707459  if isco88	== 24
	replace logdif_emp_p1 =	0.16905235  if isco88	== 31
	replace logdif_emp_p1 =	-0.0942999  if isco88	== 32
	replace logdif_emp_p1 =	0.13763621  if isco88	== 34
	replace logdif_emp_p1 =	0.08162061  if isco88	== 41
	replace logdif_emp_p1 =	0.22985920  if isco88	== 42
	replace logdif_emp_p1 =	0.09121507  if isco88	== 51
	replace logdif_emp_p1 =	0.08938678  if isco88	== 52
	replace logdif_emp_p1 =	-0.1901652  if isco88	== 71
	replace logdif_emp_p1 =	-0.1161811  if isco88	== 72
	replace logdif_emp_p1 =	-0.3063510  if isco88	== 73
	replace logdif_emp_p1 =	-0.3358708  if isco88	== 74
	replace logdif_emp_p1 =	-0.1190105  if isco88	== 81
	replace logdif_emp_p1 =	-0.0427488  if isco88	== 82
	replace logdif_emp_p1 =	-0.1031357  if isco88	== 83
	replace logdif_emp_p1 =	0.03304290  if isco88	== 91
	replace logdif_emp_p1 =	0.30613630  if isco88	== 93
	
	estimates clear
	
	saveold tempfiles/period1 , replace
	
	eststo ap_emp_p1_rti_onet: reg logdif_emp_p1 rti  			[aw=lswt]	
	eststo ap_wag_p1_rti_onet: reg logdif_wage_p1 rti  			[aw=lswt]	
	
	eststo ap_emp_p1_rti_piaac:	reg logdif_emp_p1 rti_piaac  		[aw=lswt]	
	eststo ap_wag_p1_rti_piaac:	reg logdif_wage_p1 rti_piaac  		[aw=lswt]		
	
	eststo mod1: reg logdif_emp_p1 logrw2004 logrw2004_sq 		[aw=lswt]	
	eststo mod3: reg logdif_wage_p1  logrw2004 logrw2004_sq 	[aw=lswt]
	
	eststo mod1_rti: reg logdif_emp_p1 	 c.rti##c.rti 	[aw=lswt]	
	eststo mod3_rti: reg logdif_wage_p1  c.rti##c.rti 	[aw=lswt]	

	
	eststo mod1_rti_p: reg logdif_emp_p1 	 	c.rti_piaac##c.rti_piaac 	[aw=lswt]	
	eststo mod3_rti_p: reg logdif_wage_p1  		c.rti_piaac##c.rti_piaac 	[aw=lswt]	
	
	global rtis rti rti_piaac abstract-manual
	
	
	foreach task of varlist $rtis {
		summ `task' [aw=lswt]
		replace `task'=[`task'-r(min)]/(r(max)-r(min))
		
	}
	
	global legendopt1 legend( order(1 "Median Spline (O*NET RTI)" 2 "Median Spline (PIAAC RTI)") pos(1) ring(0) rows(2) region(lstyle(outline))) 
	
	
	
	tw dropline logdif_emp_p1 logrw2004, mlabel(isco88) ///
	|| mspline logdif_emp_p1 logrw2004 ,$legendopt name(g2, replace) title("Qfit empchange-wage")
	
	tw dropline logdif_emp_p1 rti, mlabel(isco88) ///
	|| mspline logdif_emp_p1 rti ,$legendopt name(g3, replace) title("rti_O*NET")
	
	tw dropline logdif_emp_p1 rti_piaac, mlabel(isco88) ///
	|| mspline logdif_emp_p1 rti_piaac ,$legendopt name(g4, replace) title("rti_piaac")
	
	tw qfit logdif_emp_p1 rti || mspline logdif_emp_p1 rti, name(g5, replace) title("rti")
	
	tw dropline logdif_emp_p1 rti, mlabel(isco88) mc(red) lc(cranberry)	 	///
	|| dropline logdif_emp_p1 rti_piaac, mlabel(isco88) mc(black) lc(black) lp(dash)		///
	|| qfit logdif_emp_p1  rti, lp(solid) lc(cranberry)						 	///
	|| qfit logdif_emp_p1  rti_piaac , lp(dash) $legendopt lc(black)
	
	
**# Bookmark #2

	tw mspline logdif_emp_p1  rti, lp(solid) lc(black)				///
	|| mspline logdif_emp_p1  rti_piaac , lp(dash) $legendopt1 lc(black) yline(0, lp(solid)) ///
	ytitle("Employment change") xtitle("Routine Task Intensity") saving(rtip1_emp.gph, replace) ///
	name(g1, replace) xlabel(0(0.2)1)
	
	graph export fig/rti1.pdf, replace

	tw dropline logdif_wage_p1  rti, lp(solid) lc(black)				///
	|| dropline logdif_wage_p1  rti_piaac , lp(dash) $legendopt1 lc(black) yline(0, lp(solid)) 

	
	tw mspline logdif_wage_p1  rti, lp(solid) lc(black)				///
	|| mspline logdif_wage_p1  rti_piaac , lp(dash) $legendopt1 lc(black) yline(0, lp(solid)) ///
	name(g2, replace) ytitle("Change in log real wage") xtitle("Routine Task Intensity") saving(rtip1_wage.gph, replace)
	
	
	tw mspline logdif_wage_p1  rti, lp(solid) lc(black)				///
	|| mspline logdif_wage_p1  rti_piaac, lp(dash) $legendopt1 lc(black) yline(0, lp(solid)) ///
	name(g2, replace) ytitle("Change in log real wage") xtitle("Routine Task Intensity") saving(rtip1_wage.gph, replace)	
	
	gen p = _n
	
	tempfile p1
	
	saveold `p1', replace
	
	
	graph export fig/rti2.pdf, replace
	
	
	
	tw dropline logdif_emp_p1 rti_piaac, mlabel(isco88) ///
	|| mspline logdif_emp_p1 rti_piaac ,$legendopt name(g4, replace) ytitle("Employment Change")

	
	
	*pwcorr nr_cog_anal-nr_man_pers rti* rwage2004 rwage2012 logdif_*, sig

	*exit	
	************************************************************************
	************************************************************************
	************************************************************************	
	************************************************************************
	
		
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	
	use $project/data/clean/2012_v3 ,clear
	
	append using $project/data/clean/2022_v3
	
	
	tempfile year2
	
	gen lswt  = uweeklywh * weight
	gen t = _n
	
	collapse (count) t (mean) rwage (rawsum) lswt [aw=weight] , by(isco08 year)
	drop if rwage ==.
	drop if isco08 ==.
	
	drop if rwage ==.
	drop if rwage ==0
	
	drop if isco08 == 61
	drop if isco08 == 62

	tab isco08 year
	sort year
	
		
	preserve 
	
	drop if year == 2012
	gen year2022 = year
	gen lswt2022 = lswt
	gen rwage2022 = rwage
	
	saveold `year2', replace
	
	restore
	
	drop if year == 2022
	
	
	merge 1:1 isco08 using `year2'
	
	drop if isco08 ==.
	drop if year2022 ==.
	
	gen lswt2012= lswt 
	
	egen tot_emp_2012 = total(lswt2012)
	gen sh_2012 = lswt2012/tot_emp_2012*100	
	drop lswt2012 tot_emp_2012
	
	egen tot_emp_2022 = total(lswt2022)
	gen sh_2022 = lswt2022/tot_emp_2022*100	
	drop  tot_emp_2022	
	
	ren rwage rwage2012
	
	gen logrw2012 = log(rwage2012)
	gen logrw2012_sq = (log(rwage2012))^2
	gen logdif_wage_p2 = log(rwage2022)-log(rwage2012)	
	
	drop _merge
	
	merge 1:1 isco08 using "/Users/evrengulser/Desktop/TUIKDATA/27july/tasks2012.dta"	
	drop if _merge !=3
	drop _merge
	merge 1:1 isco08 using "/Users/evrengulser/Desktop/TUIKDATA/27july/isco08_piaac.dta"	
	drop if _merge !=3
	drop _merge
	pwcorr nr_cog_anal-manual
	
	drop if t == .
	drop if num_obs == .
	
	global legendopt legend( order(1 2) pos(5) ring(0) rows(2) region(lstyle(outline))) 

	gen rti  = ((r_cog+r_man)/2) - ((nr_cog_anal+nr_cog_pers)/2) - ((nr_man_pers+nr_man_phys)/2)
	
	gen logdif_emp_p2 = log(sh_2022)-log(sh_2012)
	
	gen rti_piaac = routine - abstract - manual
		

	
	reg logdif_wage_p2  nr_cog_anal-nr_man_pers 				[aw=lswt]
	
	
	reg logdif_wage_p2 c.rti##c.rti 							[aw=lswt]
	reg logdif_emp_p2 c.rti##c.rti  							[aw=lswt]
	
	reg logdif_wage_p2 c.rti_piaac##c.rti_piaac 				[aw=lswt]
	reg logdif_emp_p2 c.rti_piaac##c.rti_piaac  				[aw=lswt]
	
	reg logdif_wage_p2 abstract-manual 							[aw=lswt]
	reg logdif_emp_p2  abstract-manual 	 						[aw=lswt]
	
	tw dropline  logdif_emp_p2  abstract, mlabel(isco08) ///
	|| dropline  logdif_emp_p2  routine 				///
	|| dropline  logdif_emp_p2  manual	 
	
	set scheme plotplain
	
	global fitplot mspline
	
	global rtis rti rti_piaac abstract-manual
	
	
	foreach task of varlist $rtis {
		summ `task' [aw=lswt]
		replace `task'=[`task'-r(min)]/(r(max)-r(min))
		
	}
	
	
	
	replace logdif_emp_p2 =	-0.0903389 if isco08 == 12
	replace logdif_emp_p2 =	0.21607368 if isco08 == 13
	replace logdif_emp_p2 =	0.36101133 if isco08 == 21
	replace logdif_emp_p2 =	0.47459656 if isco08 == 22
	replace logdif_emp_p2 =	0.1410875  if isco08 == 23
	replace logdif_emp_p2 =	0.41533041 if isco08 == 24
	replace logdif_emp_p2 =	0.25731042 if isco08 == 26
	replace logdif_emp_p2 =	0.27069187 if isco08 == 31
	replace logdif_emp_p2 =	-0.1443539 if isco08 == 33
	replace logdif_emp_p2 =	0.28122735 if isco08 == 34
	replace logdif_emp_p2 =	-0.0043757 if isco08 == 41
	replace logdif_emp_p2 =	0.16619498 if isco08 == 42
	replace logdif_emp_p2 =	0.2161347  if isco08 == 43
	replace logdif_emp_p2 =	-0.2060383 if isco08 == 44
	replace logdif_emp_p2 =	-0.1290029 if isco08 == 51
	replace logdif_emp_p2 =	-0.0002020 if isco08 == 52
	replace logdif_emp_p2 =	1.1817683  if isco08 == 53
	replace logdif_emp_p2 =	-0.0329447 if isco08 == 54
	replace logdif_emp_p2 =	-0.3276473 if isco08 == 71
	replace logdif_emp_p2 =	-0.1230065 if isco08 == 72
	replace logdif_emp_p2 =	-0.2059177 if isco08 == 73
	replace logdif_emp_p2 =	-0.2288770 if isco08 == 74
	replace logdif_emp_p2 =	-0.1818689 if isco08 == 75
	replace logdif_emp_p2 =	-0.1242751 if isco08 == 81
	replace logdif_emp_p2 =	-0.0253211 if isco08 == 82
	replace logdif_emp_p2 =	-0.1010300 if isco08 == 83
	replace logdif_emp_p2 =	0.12278678 if isco08 == 91
	replace logdif_emp_p2 =	-0.4375548 if isco08 == 92
	replace logdif_emp_p2 =	-0.1255364 if isco08 == 93
	replace logdif_emp_p2 =	0.18670896 if isco08 == 94
	replace logdif_emp_p2 =	0.08976866 if isco08 == 96	
	
	*EXCLUSION
	
	drop if isco08 == 95
	
	*polariztion grafiğinden alinan log employment change verileri için:
	
	*drop if isco08 == 53
	
	drop if isco08 == 92
	drop if isco08 == 53
	drop if isco08 == 11
	

	eststo mod2: reg logdif_emp_p2 	logrw2012 logrw2012_sq 		[aw=lswt]
	
	eststo mod4: reg logdif_wage_p2  logrw2012 logrw2012_sq 	[aw=lswt]	
	
	
	esttab  	mod1 mod2 mod3 mod4 ///
				using $project/table/table6_polarization.csv , ///
	b(%12.2f)	p(%12.2f) replace /* title (`title') */  label ar2 r2 ///
				/*star(* .10 ** .05 *** .01)*/  varwidth(15)  compress	
	
	
	eststo mod2_rti: reg logdif_emp_p2  c.rti##c.rti  							[aw=lswt]
	eststo mod4_rti: reg logdif_wage_p2 c.rti##c.rti 							[aw=lswt]
	
	eststo mod2_rti_p: reg logdif_emp_p2  c.rti_piaac##c.rti_piaac  				[aw=lswt]
	eststo mod4_rti_p: reg logdif_wage_p2 c.rti_piaac##c.rti_piaac 				[aw=lswt]
	
	est dir
	
	
	esttab  	mod1_rti mod2_rti mod3_rti mod4_rti ///
				using $project/table/table6_polarization_rti.csv , ///
	b(%12.2f)	p(%12.2f) replace /* title (`title') */  label ar2 r2 ///
				/*star(* .10 ** .05 *** .01)*/  varwidth(15)  compress	
				
	esttab  	mod1_rti_p mod2_rti_p mod3_rti_p mod4_rti_p ///
				using $project/table/table6_polarization_rti_piaac.csv , ///
	b(%12.2f)	p(%12.2f) replace /* title (`title') */  label ar2 r2 ///
				/*star(* .10 ** .05 *** .01)*/  varwidth(15)  compress	
	
	
	
	global legendopt1 legend( order(1 "Median Spline 2012-2022" 2 "Median Spline 2004-2012") pos(1) ring(0) rows(2) region(lstyle(outline))) 
	
	reg logdif_emp_p2 rti  				[aw=lswt]	
	reg logdif_wage_p2 rti  			[aw=lswt]	
	
	reg logdif_emp_p2 rti_piaac  		[aw=lswt]	
	reg logdif_wage_p2 rti_piaac  		[aw=lswt]	

	
	eststo ap_emp_p2_rti_onet: reg logdif_emp_p2 rti  				[aw=lswt]	
	eststo ap_wag_p2_rti_onet: reg logdif_wage_p2 rti  				[aw=lswt]	
	
	eststo ap_emp_p2_rti_piaac:	reg logdif_emp_p2 rti_piaac  		[aw=lswt]	
	eststo ap_wag_p2_rti_piaac:	reg logdif_wage_p2 rti_piaac  		[aw=lswt]	
	
	esttab  	ap_emp_p1_rti_onet ap_emp_p2_rti_onet ///
				ap_wag_p1_rti_onet ap_wag_p2_rti_onet ///
				ap_emp_p1_rti_piaac ap_emp_p2_rti_piaac ///
				ap_wag_p1_rti_piaac ap_wag_p2_rti_piaac ///
				using $project/table/table_appendix_polarization_rti.csv , ///
	b(%12.2f)	 replace /* title (`title') */  label ar2 r2 ///
				/*star(* .10 ** .05 *** .01)*/  varwidth(15)  compress		
	
	
	gen rti_p2 = rti
	drop rti
	gen p = _n
	
	merge 1:m p using `p1', nogen
	
	
	tw mspline logdif_emp_p2  rti_p2, lp(dash) lc(gr6) lw(m thick) ///
	|| mspline logdif_emp_p1  rti, lp(solid) lc(black) lw(m thick) $legendopt1 ytitle("Change in log employment share") xtitle("Routine task intensity") yline(0, lp(solid) lc(cranberry)) ///
	scale(1.3) ylabel(,angle(horizontal) labsize(medium small) format(%3.1f)) ///
	xlabel(,labsize(medium small))
	
	graph export fig/rtiemp.pdf, replace
	
	tw mspline logdif_wage_p2  rti_p2, lp(dash) lc(gr6) lw(m thick) ///
	|| mspline logdif_wage_p1  rti, lp(solid) lc(black) lw(m thick) $legendopt1 ytitle("Change in log real wage") xtitle("Routine task intensity") yline(0, lp(solid) lc(cranberry))	///
	scale(1.3) ylabel(,angle(horizontal) labsize(medium small) format(%3.1f)) ///
	xlabel(,labsize(medium small))
	
	graph export fig/rtiwage.pdf, replace

**# Bookmark #3
	
	tw mspline logdif_emp_p2  rti, lp(solid) lc(black)				///
	|| mspline logdif_emp_p2  rti_piaac , lp(dash) $legendopt1 lc(black) yline(0, lp(solid)) ///
	ytitle("Employment change") xtitle("Routine Task Intensity") xlabel(0(0.2)1) saving(rtip2_emp.gph, replace)
	
	graph export fig/rti3.pdf, replace
	
	tw mspline logdif_wage_p2  rti, lp(solid) lc(black)				///
	|| mspline logdif_wage_p2  rti_piaac , lp(dash) $legendopt1 lc(black) yline(0, lp(solid)) 

	tw mspline logdif_wage_p2  rti, lp(solid) lc(black)				///
	|| mspline logdif_wage_p2  rti_piaac , lp(dash) $legendopt1 lc(black) yline(0, lp(solid)) ///
	name(g2, replace) ytitle("Change in log real wage") xtitle("Routine Task Intensity")saving(rtip2_wage.gph, replace)
	
	graph export fig/rti4.pdf, replace
	
	
	grc1leg rtip1_emp.gph rtip1_wage.gph rtip2_emp.gph rtip2_wage.gph ///
	, rows(2) ///
	imargin(0 0 0)  iscale(1) legendfrom(rtip1_emp.gph)  ysize(10) xsize(9.0) name(grc_graphs_wage, replace) saving(grc_graphs_wage, replace) pos(6) span /// 
	ycommon xcommon //l1title("Change in employment Share")
	
	graph combine rtip1_emp.gph rtip2_emp.gph, ///
	rows(2) title("Employment Change") xcommon ycommon saving(g1.gph, replace)
	
	graph combine rtip1_wage.gph rtip2_wage.gph, ///
	rows(2) title("Wage Change") xcommon ycommon saving(g2.gph, replace)
	
	graph combine g1.gph g2.gph, col(2)
	
	
	grc1leg g1.gph g2.gph ///
	, rows(2) ///
	imargin(0 0 0)  iscale(1) legendfrom(g1.gph)  ysize(10) xsize(9.0) name(grc_graphs_wage, replace) saving(grc_graphs_wage, replace) pos(6) span 	
	
	
	
	tw dropline logdif_emp_p2 logrw2012, mlabel(isco08) ///
	|| mspline logdif_emp_p2 logrw2012 ,$legendopt name(g1_p2, replace)
	
	tw dropline logdif_emp_p2 rti_piaac, mlabel(isco08) ///
	|| mspline logdif_emp_p2 rti_piaac , ///
	|| qfit logdif_emp_p2 rti_piaac , ///
	$legendopt name(g2_p2, replace) title("Relationship Between Employment Change and RTI (PIAAC)")
	
	tw dropline logdif_emp_p2 rti, mlabel(isco08) ///
	|| mspline logdif_emp_p2 rti ,$legendopt name(g3_p2, replace) ///
	title("Relationship Between Employment Change and RTI (O*NET)")
	
	
	tw qfit logdif_emp_p2 rti_piaac , mlabel(isco08) || mspline logdif_emp_p2 rti_piaac ,lc(cranberry) name(g4_p2, replace)
	
	
	tw dropline logdif_wage_p2 rti_piaac, mlabel(isco08) || mspline logdif_wage_p2 rti_piaac ,$legendopt name(g5_p2, replace)
	tw dropline logdif_wage_p2 rti, mlabel(isco08) || mspline logdif_wage_p2 rti ,$legendopt name(g6_p2, replace)
	
	
	
	global yline yline(0, lp(solid) lc(maroon))
	global plottype spike
	
	
	
	tw $plottype  logdif_emp_p2  abstract, mlabel(isco08) ///
	|| $fitplot  logdif_emp_p2  abstract  , name(g1, replace) $legendopt lc(red) lp(l) ytitle(Log Change in Employment) xtitle(Abstract) saving(emp_abs_p2.gph, replace) $yline 

	
	tw $plottype  logdif_emp_p2  routine, mlabel(isco08)	///
	|| $fitplot  logdif_emp_p2  routine, name(g2, replace) $legendopt lc(red) lp(l) ytitle(Log Change in Employment) xtitle(Routine) saving(emp_rou_p2.gph, replace) $yline
	
	tw $plottype  logdif_emp_p2  manual	 ///
	|| $fitplot  logdif_emp_p2  manual, name(g3, replace) $legendopt lc(red) lp(l) ytitle(Log Change in Employment) xtitle(Manual) saving(emp_man_p2.gph, replace) $yline
	
	
	tw $plottype  logdif_wage_p2  abstract, mlabel(isco08) ///
	|| $fitplot  logdif_wage_p2  abstract, name(g4, replace) $legendopt lc(red) lp(l) ytitle(Change in Log Wage) xtitle(Abstract) saving(wage_abs_p2.gph, replace) $yline
	
	tw $plottype  logdif_wage_p2  routine 	///
	|| $fitplot  logdif_wage_p2  routine, name(g5, replace) $legendopt lc(red) lp(l) ytitle(Change in Log Wage) xtitle(Routine) saving(wage_rou_p2.gph, replace) $yline
	
	tw $plottype  logdif_wage_p2  manual ///
	|| $fitplot  logdif_wage_p2  manual, name(g6, replace) $legendopt lc(red) lp(l) ytitle(Change in Log Wage) xtitle(Manual) saving(wage_man_p2.gph, replace) $yline
	
	tw $plottype logdif_emp_p2 rti_piaac ,mlabel(isco08) mc(maroon)  || mspline logdif_emp_p2 rti_piaac,  name(asd1, replace) lc(cranberry) $legendopt $yline
	
	tw $plottype logdif_emp_p2 rti ,mlabel(isco08) mc(maroon)  || mspline logdif_emp_p2 rti,  name(asd3, replace) lc(cranberry) $legendopt $yline
	
	tw $plottype logdif_wage_p2 rti_piaac , mlabel(isco08) mc(maroon) || mspline logdif_wage_p2 rti_piaac, lc(cranberry) name(asd2, replace) $legendopt $yline
	
	
	grc1leg emp_abs_p2.gph wage_abs_p2.gph ///
			emp_rou_p2.gph wage_rou_p2.gph  ///
			emp_man_p2.gph wage_man_p2.gph, cols(2) imargin(0 0 0)  iscale(0.7) legendfrom(emp_abs_p2.gph) 	
			
	
	/*
	
	grc1leg taskEconomy_wage.gph taskManufacturing_wage.gph taskServices_wage.gph, rows(1) ///
	imargin(0 0 0)  iscale(1) legendfrom(taskServices_wage.gph)  ysize(5) xsize(9.0) name(grc_graphs_wage, replace) saving(grc_graphs_wage, replace) pos(6) span	l1title("Log Real Hourly Wage")
	
	
	
	exit
		
	pwcorr nr_cog_anal-nr_man_pers rti* rwage2012 rwage2022 logdif_*, sig
