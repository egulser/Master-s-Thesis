
	
	
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	
	global newdata $project/data/clean
	
	
	
	
	************************************************************************
	* 
	*	(Fortin, Lemieux 2016) 
	*	https://economics.ubc.ca/wp-content/uploads/sites/38/2018/12/pdf_paper-thomas-lemieux-tasks.pdf
	*
	*	This do file estimates the models of Table 1 in Akçomak (2013) and Table 2 in Fortin and Lemieux (2016) 
	*	
	************************************************************************
	
	local occupationcodes 11 12 13 21 22 23 24 31 32 33 34 41 42 51 52 61 62 71 72 73 74 81 82 83 91 92 93		
	
	use $newdata/2004_v3,clear	
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	drop if uweeklywh < 35
	
	assert lswt != 0
	assert lswt != .
		
		
	gen occupation = isco88

	drop if occupation == 61 
	drop if occupation == 62
	drop if occupation == 13
	drop if occupation == 33
	
	drop if rwage == 0
	drop if rwage == .
	
	gen lnwage = log(rwage/uweeklywh)
	
	* Generating deciles
	
	foreach num of numlist  `occupationcodes' {
		_pctile lnwage if occupation == `num', percentiles(10 20 30 40 50 60 70 80 90)
		return list
	
		if `num' == 11 {
			forvalues i = 1/9 {
				gen deciles`i' = r(r`i') if occupation == `num'
			}
		}		
		forvalues i = 1/9 {
			replace deciles`i' = r(r`i') if occupation == `num'
		}
	}
	
		
	gen count = 1	
	collapse (rawsum) lswt count (mean) lnwage deciles* [aw=weight], by(occupation year)
	drop if year != 2004
	drop if lnwage == .
	reshape long deciles, i(occupation) j(j)
	ren deciles deciles2004
	saveold decilesdata_2004 , replace		
	
	* new data
		
	use $newdata/2012_v3, clear	
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	drop if uweeklywh < 35
	assert lswt != 0
	assert lswt != .	
	

	gen occupation = isco88
	drop if emp_status >2	

	drop if occupation == 61 
	drop if occupation == 62 
	drop if occupation == 13
	drop if occupation == 33
	
	drop if rwage == 0
	drop if rwage == .
	
	gen lnwage = log(rwage/uweeklywh)	
	
	
	* Generating deciles
	
	foreach num of numlist  `occupationcodes' {
		_pctile lnwage if occupation == `num', percentiles(10 20 30 40 50 60 70 80 90)
		return list
	
		if `num' == 11 {
			forvalues i = 1/9 {
				gen deciles`i' = r(r`i') if occupation == `num'
			}
		}		
		forvalues i = 1/9 {
			replace deciles`i' = r(r`i') if occupation == `num'
		}
	}
		

	
	gen count = 1	
	collapse (rawsum) lswt count (mean) lnwage deciles* [aw=weight], by(occupation year)
	drop if lnwage == .
	reshape long deciles, i(occupation) j(j)
	ren deciles deciles2012
	saveold deciledata_2012 , replace
			
	merge 1:1 occupation j using decilesdata_2004, keepusing(year deciles2004)
	
	gen difwage = deciles2012-deciles2004
	
	gen deciles2004_sq = deciles2004^2
	
	* estimating simple quadratic regression
	
	reg difwage deciles2004 deciles2004_sq [aw=lswt]
	outreg2 eu_lnclg t using akçomak_polarization.xlsx, ctitle("Quadratic equation") nolabel se bdec(5) tdec(5) replace
	
	local legendop legend(order(3 "Wage difference" 2 "Quadratic fit") cols(1))
	
	set scheme plotplain
	
	*drop if difwage < 0
	*drop if difwage >1
	
	tw 	sc difwage deciles2004, mcolor(%0) 	///
		|| qfit difwage deciles2004 , lstyle(solid) lc(cranberry)		///
		|| sc difwage deciles2004 [aw=lswt] ,  msymbol(circle) color(gs4) msize(0.70) mcolor(%20)  ///
	xtitle("Log hourly real wage 2004") ytitle("Difference in log real hourly wage (2004-2012)") ///
	legend( pos(1) ring(0) cols(2) region(lstyle(outline))) `legendop'
	
	graph export fig/akçomak_2004-2012.pdf, replace
	
	save workingdata, replace
	
	*/
	
	/*
	************************************************************************
	* 
	*	(Fortin, Lemieux 2016) 
	*	https://economics.ubc.ca/wp-content/uploads/sites/38/2018/12/pdf_paper-thomas-lemieux-tasks.pdf
	*
	*	This do file estimates the models of Table 1 in Akçomak (2013) and Table 2 in Fortin and Lemieux (2016) 
	*	
	************************************************************************
	
	local occupationcodes1 11 12 13 21 22 23 24 31 32 33 34 41 42 51 52 71 72 73 74 81 82 83 91 92 93	
	local occupationcodes `occupationcodes1' 14 25 26 35 43 44 53 54 75 94 96
	
	use $newdata/2012_v3,clear	
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	drop if uweeklywh < 35
	
	assert lswt != 0
	assert lswt != .
		
		
	gen occupation = isco08
	
	tab occupation

	drop if occupation == 61 
	drop if occupation == 62
	drop if occupation == 95

	
	drop if rwage == 0
	drop if rwage == .
	
	gen lnwage = log(rwage/uweeklywh)
	
	* Generating deciles
	
	foreach num of numlist  `occupationcodes' {
		_pctile lnwage if occupation == `num', percentiles(10 20 30 40 50 60 70 80 90)
		return list
	
		if `num' == 11 {
			forvalues i = 1/9 {
				gen deciles`i' = r(r`i') if occupation == `num'
			}
		}		
		forvalues i = 1/9 {
			replace deciles`i' = r(r`i') if occupation == `num'
		}
	}
	
		
	gen count = 1	
	collapse (rawsum) lswt count (mean) lnwage deciles* [aw=weight], by(occupation year)
	drop if lnwage == .
	reshape long deciles, i(occupation) j(j)
	ren deciles deciles2012_p2
	saveold decilesdata_2004_p2 , replace		
	
	* new data
		
	use $newdata/2022_v3, clear	
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	drop if uweeklywh < 35
	assert lswt != 0
	assert lswt != .	
	

	gen occupation = isco08
	drop if emp_status >2	

	drop if occupation == 61 
	drop if occupation == 62 
	
	drop if rwage == 0
	drop if rwage == .
	
	gen lnwage = log(rwage/uweeklywh)	
	
	
	* Generating deciles
	
	foreach num of numlist  `occupationcodes' {
		_pctile lnwage if occupation == `num', percentiles(10 20 30 40 50 60 70 80 90)
		return list
	
		if `num' == 11 {
			forvalues i = 1/9 {
				gen deciles`i' = r(r`i') if occupation == `num'
			}
		}		
		forvalues i = 1/9 {
			replace deciles`i' = r(r`i') if occupation == `num'
		}
	}
		

	
	gen count = 1	
	collapse (rawsum) lswt count (mean) lnwage deciles* [aw=weight], by(occupation year)
	drop if lnwage == .
	reshape long deciles, i(occupation) j(j)
	ren deciles deciles2022
	saveold deciledata_2022 , replace
			
	merge 1:1 occupation j using decilesdata_2004_p2, keepusing(year deciles2012)
	
	gen difwage = deciles2022-deciles2012
	

	
	* estimating simple quadratic regression
	
	reg difwage c.deciles2012##c.deciles2012 [aw=lswt]
	*outreg2 eu_lnclg t using akçomak_polarization.xlsx, ctitle("Quadratic equation") nolabel se bdec(5) tdec(5) replace
	
	local legendop legend(order(3 "Wage difference" 2 "Quadratic fit") cols(1))
	
	set scheme plotplain
	
	drop if difwage < 0
	drop if difwage >1
	
	tw 	sc difwage deciles2012, mcolor(%0) 	///
		|| qfit difwage deciles2012 , lstyle(solid) lc(cranberry)		///
		|| sc difwage deciles2012 [aw=lswt] ,  msymbol(circle) color(gs4) msize(0.70) mcolor(%20)  ///
	xtitle("Log hourly real wage 2012") ytitle("Difference in log real hourly wage (2012-2022)") ///
	legend( pos(1) ring(0) cols(2) region(lstyle(outline)))  `legendop'
	
	graph export fig/akçomak_2012-2022.pdf, replace	
	
	*/
	
	use workingdata, clear
	
	tab occupation, gen(occ)
	tab j, gen(quantildummy)
	
	
	forvalues o=1(1)23 {
		gen ocwage`o' = occ`o'*deciles2004
	}
			
	
	global quadratic deciles2004 deciles2004_sq
	
	estimates clear
	
	reg difwage deciles2004 c.deciles2004#c.deciles2004 [aw=lswt]
	
	
		
	* quadratic equation
	reg difwage $quadratic [aw=lswt]
	
	* col1
	eststo model1: reg difwage deciles2004 [aw=lswt]

	
	* col1 curvature
	predict col1resid, residuals
	eststo model1_curv: reg col1resid $quadratic
	
	
	* col2
	eststo model2: qui reg difwage occ* [aw=lswt]

	
	* col2 curvature
	predict col2resid, residuals
	eststo model2_curv: qui reg col2resid $quadratic

		
	* col3 
	eststo model3: qui reg difwage quantildummy* [aw=lswt]

	* col3 curvature
	predict col3resid, residuals
	eststo model3_curv: qui reg col3resid $quadratic

	
	* col4
	eststo model4: qui reg difwage occ* quantildummy* [aw=lswt]

	
	* col4 curvature
	predict col4resid, residuals
	eststo model4_curv: qui reg col4resid $quadratic


	* col5 
	eststo model5: qui reg difwage occ* quantildummy* deciles2004 ocwage* [aw=lswt]

	
	* col5 curvature
	predict col5resid, residuals
	eststo model5_curv: qui reg col5resid $quadratic

	
	* col6
	eststo model6: qui reg difwage occ* deciles2004 ocwage* [aw=lswt]

	
	* col6 curvature
	predict col6resid, residuals
	eststo model6_curv: qui reg col6resid $quadratic

	
	* col7
	eststo model7: qui reg difwage occ* quantildummy* deciles2004 [aw=lswt]

	
	* col7 curvature
	predict col7resid, residuals
	eststo model7_curv: qui reg col7resid $quadratic

	
	
	eststo dir
	
	esttab  	model1 model1_curv model2 model2_curv ///
				model3 model3_curv model4 model4_curv ///
				model5 model5_curv model6 model6_curv ///
				model7 model7_curv  ///
				using table/emprical1_akçomak.csv ,replace unstack label ar2 se ///
				drop (occ* oc*) compress
	
	
	
	
	
	
