		
	* graph box wage_w if wage_w<20, over(occ1)
		
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	
	local figdir $project/fig/shift_share
	
	global figsdir `figdir'
	
	use $project/data/clean/2004_v3 ,clear	
	
	append using $project/data/clean/2012_v3
	append using $project/data/clean/2022_v3
	
	tempfile y2004 y2012 y2022 collapsed
			
	tab emp_status
	
	drop if isco88 == 33 | isco88 == 62 | isco88 == 61 | isco88 == 13 
	drop if isco88 == 92
	
	drop if isco08 == 61 | isco08 == 62 | isco08 == 63
	
	drop if wage == 0 | wage == .
	
	gen lswt 	= uweeklywh * weight 	if wage != 0	
	gen wage_w 	= wage/uweeklywh 		if wage != 0	
	
	gen minyear = 2004
	gen midyear = 2012
	gen maxyear = 2022
	
	gen lswt04 = lswt if year == 2004
	gen lswt12 = lswt if year == 2012
	gen lswt22 = lswt if year == 2022
	
	drop if occ1 == .
	
	collapse (sum) lswt04 lswt12 lswt22 (mean) minyear midyear maxyear, by(occ1 nace)	
	
	saveold `collapsed', replace
	
	/*CALCULATING PERCENTAGE POINT CHANGE IN EMPLOYMENT SHARE*/
	
	local fy 12
	local ly 22
	
	
	keep lswt`fy' lswt`ly' occ1 nace
		
	collapse (sum) lswt`fy' lswt`ly', by(occ1)
		
	gen emp`fy' = lswt`fy'
	gen emp`ly' = lswt`ly'
	
	egen totemp`fy'=sum(emp`fy')
	egen totemp`ly'=sum(emp`ly')
	bysort occ: gen empshare`fy'=emp`fy'/totemp`fy'*100
	bysort occ: gen empshare`ly'=emp`ly'/totemp`ly'*100
	bysort occ: gen dempshare=empshare`ly'-empshare`fy'
	
	keep occ1 empshare`fy' empshare`ly'
	gen dempshare=empshare`ly'-empshare`fy'
	gen es`fy'=empshare`fy'/100
	gen es`ly'=empshare`ly'/100
	keep occ es`fy' es`ly' demp 
	order occ es`fy' es`ly' demp
	list
	sort occ
	* save $path_out\T1_col1&2_pooled, replace
	
	
	/*GETTING SHARES AND CHANGES OVER TIME*/	
	
	use `collapsed', clear
	
	keep occ1 nace lswt`fy' lswt`ly'
	
	bysort occ1: egen EI`fy'=sum(lswt`fy')
	bysort occ1: egen EI`ly'=sum(lswt`ly')

	egen E`fy'=sum(lswt`fy')
	egen E`ly'=sum(lswt`ly')
	
	gen SI`fy'=EI`fy'/E`fy'
	gen SI`ly'=EI`ly'/E`ly'
	
	gen DSI=SI`ly'-SI`fy'
	
	bysort nace: egen EN`fy'=sum(lswt`fy')
	bysort nace: egen EN`ly'=sum(lswt`ly')
	
	gen SIN`fy' = lswt`fy'/EN`fy'
	gen SIN`ly' = lswt`ly'/EN`ly'
	
	gen SN`fy'=EN`fy'/E`fy'
	gen SN`ly'=EN`ly'/E`ly'
	
	/*DECOMPOSITION*/
	gen withinN=(SIN`ly'-SIN`fy')*SN`ly'
	
	gen betweenN=(SN`ly'-SN`fy')*SIN`ly'
	
	bysort occ1: egen within=sum(withinN)
	
	bysort occ1: egen between=sum(betweenN)
	
	gen zero=DSI-within-between

	/*SHIFT-SHARE ANALYSIS*/
	keep DSI SI`fy' within between zero occ1 
	
	collapse (mean) SI`fy' DSI within between zero, by(occ)
	sort occ
	replace within=within*100
	replace between=between*100
	replace DSI=DSI*100
	
	*Note: reported are within and between
	*SI93 and DSI are also generated in point 1 of this dofile.
	
	drop if occ1 == .	
	
	gen zero_2= DSI-within-between
	
	list
	keep occ DSI within between
	sort occ1	
	
	set scheme plotplain
	
	/*
	
	label define occ1   1 "Managers" 	2 "Professionals" 3 "Technicicans" ///
						4 "Clerks"		5 "Sales and Services" 7 "Craft and Related Trade" ///
						8 "Operators" 	9 "Elementary"
						
	label values occ1 occ1					
	*/
	
	graph hbar within between , over(occ1) stack title("20`fy'-20`ly'") ///
	saving(`figdir'/`fy'_`ly'.gph, replace)  ///
	legend( order( 1 "Within" 2 "Between") pos(6) ring(1) rows(1)) ylabel(-8(2)6) ///
	bar(1,  fintensity(inten100))

	
	
	graph export $project/fig/shift_share/`fy'_`ly'.png ,replace

	cd $figsdir
	
	grc1leg 04_12.gph 12_22.gph 04_22.gph, rows(1) ///
	imargin(0 0 0) iscale(1) legendfrom(04_22.gph)  ycommon ring(1) 
	
	graph export $project/fig/shift_share/allperiods.png , replace
	
	gen dsi_2 = within + between
	
	gen ds_dif = DSI - dsi_2
	
	gen year = `fy'`ly'
	
	/*
	
	///
	ysize(5) xsize(9.0) name(grc_graphs_employmentshare, replace) 			///
	saving(grc_graphs, replace) pos(6) span l1title("Employment Share")

	gr draw grc_graphs_employmentshare,  ysize(2.6) xsize(5) 
	

	
	graph export $project/fig/fonseca5_v4.pdf, replace
		