	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	
	/*
	use $project/data/clean/2004_v3 ,clear
	append using $project/data/clean/2008_v3
	append using $project/data/clean/2012_v3
	append using $project/data/clean/2016_v3
	append using $project/data/clean/2022_v3
	*/
	
	* Prep 2012 and 2022 samples
	use $project/data/clean/2004_v3 ,clear
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	
	assert lswt != 0
	assert lswt != .

		
	egen occsh_2004=sum(lswt),by(occ1)
	egen t=sum(lswt)
	replace occsh_2004=occsh_2004/t
	keep occ1 occsh_2004
	quietly by occ1, sort: keep if _n==1
	save occ-shares-2004_v2,replace
		
	use $project/data/clean/2022_v3 ,clear
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if wage == 0 
	drop if wage == .
		
	drop if lswt == 0
	assert lswt != 0	
	assert lswt != .

	egen occsh_2022=sum(lswt),by(occ1)
	egen t=sum(lswt)
	replace occsh_2022=occsh_2022/t
	keep occ1 occsh_2022
	quietly by occ1, sort: keep if _n==1
	save occ-shares-2022_v2, replace
	
	* Prepare 1980 sample
	use $project/data/clean/2004_v3 ,clear
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	
	assert lswt != 0
	assert lswt != .
	
	gen hrw = wage/uweeklywh
	
	egen occ_mdwg = median(hrw), by(occ1)
	
	keep occ1 lswt occ_mdwg
	rename occ_mdwg occ_mdwg2004
	egen avlswt2004=mean(lswt),	by(occ1)
	egen occsh_2004=sum(lswt),	by(occ1)
	egen t=sum(lswt)
	replace occsh_2004=occsh_2004/t

	* Merge in 1990 occ shares
	sort occ1
	merge m:1 occ1 using occ-shares-2022_v2
	drop _merge


	/*
	* Merge in 2000 occ shares
	sort isco08
	merge occ_pbm using occ-shares-2000
	drop _merge
	*/
	
	count if occsh_2004==.
	
	*mvencode occsh_2022, mv(0)
	* Must drop occupation if no employment in this occupation in 1980 since no base value
	drop if occsh_2004==.

	* Calculate percentiles by occupation
	sort occ_mdwg2004
	egen tot = sum(avlswt2004)
	gen rank = sum(avlswt2004)
	gen arank = (rank + rank[_n-1])/2
	replace arank = rank/2 if arank==.
	gen prank = 100*(arank/tot)
	gen perc = int(prank)
	replace perc = perc + 1
	egen gwt = sum(avlswt2004),by(perc)
	gen ewt = avlswt2004/gwt

	*Proportional Growth by Occupation
	gen doccsh0422 = (occsh_2022 - occsh_2004)/occsh_2004
	* gen doccsh8090 = (occsh_1990 - occsh_1980)/occsh_1980

	*Average Proportional Emp Growth by Occupation in Each Percentile
	*Same as Employment Share Change (in Percentage Points) since Each is 1 Percent to Start
	egen pdesh_0422 = sum(ewt*doccsh0422),by(perc)
	* egen pdesh_8090 = sum(ewt*doccsh8090),by(perc)
	* gen pdesh_9000 = pdesh_8000 - pdesh_8090
	sort perc occ_mdwg2004

	replace pdesh_0422=pdesh_0422
	* replace pdesh_8000=pdesh_8000
	* replace pdesh_9000=pdesh_9000

	quietly by perc: gen first = _n==1
	keep if first==1
	sort perc
	list perc pdesh_0422 // pdesh_9000 pdesh_8000

	save occ-shares-0422-byperc,replace

	*rm occ-shares-2012.dta
	*rm occ-shares-2022.dta


	************************************
	* Figure 3
	************************************
	clear
	set mem 5m

	use occ-shares-0422-byperc,clear
	label var perc "Occupation's Percentile in 2004 Wage Distribution"

	lowess pdesh_0422 perc , gen(predsh0422) bwidth(.3) ytick(-0.5(0.5)1.5, grid) ///
	ytitle("Observed change in employment shares") ///
	saving($project/low-demp-medwage-raw-1222.gph ,replace)
	graph export $project/fig/lowes0422.pdf, replace
	*lowess pdesh_8000 perc, gen(predsh8000) bwidth(.8) saving(low-demp-medwage-raw-8000.gph,replace)
	*lowess pdesh_9000 perc, gen(predsh9000) bwidth(.8) saving(low-demp-medwage-raw-9000.gph,replace)
	
	label var predsh0422 "2004-2022"
	set scheme plotplain
	* local patterns pattern1 
	tw spike	predsh0422 perc,  lw(medium) ///
		|| qfit predsh0422 perc, lcolor(red) lpattern(solid) ///
				 mcolor(blue) 	ylabel(-0.3(0.2)0.9) ///
				 legend( pos(4) ring(0) region(lstyle(outline)))  ///
				l1title("100 x Change in Employment Share", size(medsmall)) ytitle("") 	///
				xtitle("Occupation's Percentile in 2004 Wage Distributions", 	///
				size(medsmall)) name(pattern64, replace) scale(1.5)
				
			graph export fig/polargraph0422.pdf, replace
			graph export fig/polargraph0422.png, replace
				
	/*			
	
	merge m:1 perc using firstperiod.dta
	
	order isco08 occ*
	sort occ_mdwg2004
	drop if occsh_2004 == .
	* Calculate percentiles by occupation
	drop tot rank arank perc gwt ewt prank
	
	sort occ_mdwg2004
	egen tot = sum(avlswt2004)
	gen rank = sum(avlswt2004)
	gen arank = (rank + rank[_n-1])/2
	replace arank = rank/2 if arank==.
	gen prank = 100*(arank/tot)
	gen perc = int(prank)
	replace perc = perc + 1
	egen gwt = sum(avlswt2004),by(perc)
	gen ewt = avlswt2004/gwt
	
	
	gen doccsh0422 = (occsh_2022-occsh_2004)/occsh_2004
	
	egen pdesh_0422 = sum(ewt*doccsh0422),by(perc)
	
	sort perc occ_mdwg2004
	replace pdesh_0422=pdesh_0422	
	
	drop first
	quietly by perc: gen first = _n==1
	keep if first==1
	sort perc
	list perc pdesh_0422 // pdesh_9000 pdesh_8000
	
	save occ-shares-0422-byperc ,replace
	clear
	
	use occ-shares-0422-byperc,clear
	label var perc "Occupation's Percentile in 2004 Wage Distribution"
	
	lowess pdesh_0422 perc , gen(predsh0422) bwidth(.3) ///
	ytitle("Observed change in employment shares") ///
	saving($project/low-demp-medwage-raw-0422.gph ,replace)

	

	label var predsh1222 "2012-2022"
	* label var predsh8090 "1980-1990"
	* label var predsh9000 "1990-2000"
	
	*tw l pdesh_1222 per
	
			tw parea 	predsh0422 perc, pattern(pattern6) color(navy%80) lw(vvvthin) ///
						mcolor(black) lw(vvvthin vvvthin)	///
						legend( pos(4) ring(0) region(lstyle(outline)))  ///
						l1title("100 x Change in Employment Share", size(medsmall)) ytitle("") 	///
						xtitle("Occupation's Percentile in 2004 and 2012 Wage Distributions", 	///
						size(medsmall)) name(pattern64, replace)
						
						graph export fig/pattern64.pdf, replace	
	
	
	
			tw parea 	predsh0422 perc, pattern(pattern6) color(navy%80) lw(vvvthin) ///
						mcolor(black) lw(vvvthin vvvthin)	///
						legend( pos(4) ring(0) region(lstyle(outline)))  ///
						l1title("100 x Change in Employment Share", size(medsmall)) ytitle("") 	///
						xtitle("Occupation's Percentile in 2004 and 2012 Wage Distributions", 	///
						size(medsmall)) name(pattern64, replace)
						
						graph export fig/pattern64.pdf, replace
	
	
	* local patterns pattern1 
			tw parea 	predsh1222 perc, pattern(pattern6) color(navy%80) lw(vvvthin) ///
			|| parea 	predsh0412 perc, pattern(pattern9) color(maroon%80) lw(vvvthin) ///
						 mcolor(black) lw(vvvthin vvvthin)	///
						 legend( pos(4) ring(0) region(lstyle(outline)))  ///
						l1title("100 x Change in Employment Share", size(medsmall)) ytitle("") 	///
						xtitle("Occupation's Percentile in 2004 and 2012 Wage Distributions", 	///
						size(medsmall)) name(pattern64, replace)
						
						
			* local patterns pattern1 
			tw area	predsh1222 perc,  color(grayscale3%50) lw(vvvthin) ///
			|| area	predsh0412 perc,  color(grayscale15%50) lw(vvvthin) ///
						 mcolor(black) lw(vvvthin vvvthin)	///
						 legend( pos(4) ring(0) region(lstyle(outline)))  ///
						l1title("100 x Change in Employment Share", size(medsmall)) ytitle("") 	///
						xtitle("Occupation's Percentile in 2004 and 2012 Wage Distributions", 	///
						size(medsmall)) name(pattern64, replace)				
						
						graph export fig/pattern64.pdf, replace
	
	forval y = 1/10{

	tw parea 	predsh1222 predsh0412 perc, yline(0, lwidth(thin) lcolor(red)) color(grayscale7%70 grayscale3%70) ///
				/*msymbol(s d) lpattern(l -)*/   pattern(pattern7) pattern(pattern`y') mcolor(black) lw(vvvthin vvvthin)	///
				l1title("100 x Change in Employment Share", size(medsmall)) ytitle("") 	///
				xtitle("Occupation's Percentile in 2004 and 2012 Wage Distributions", 	///
				/*pos(4) ring(0) region(lstyle(outline)))*/ ///
				size(medsmall)) name(pattern`y', replace) saving(akk-polar-fig3-empbyoccwage.gph, replace)
				graph export fig/pattern`y'.pdf, replace
}
	/*			
				/*mcolor(black black)*/ /*msize(vsmall small)*/  /*ylabel(-0.15(.05)0.2) */
	* Do a version for AER P&P that has no heading
	tw  scatter predsh8090 predsh9000 perc, connect(l l) msymbol(i dh) msize(vsmall small)  ylabel(-0.15(.05)0.2) l1title("100 x Change in Employment Share", size(medsmall)) ytitle("") xtitle("Occupation's Percentile in 1980 Wage Distribution", size(medsmall)) /*t1title("Figure 3. Smoothed Changes in Employment by Occupation 1980-2000", size(medsmall)) */ saving(pp-akk-polar-fig3-empbyoccwage.gph, replace)


	log close
