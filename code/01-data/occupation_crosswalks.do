


	local years 2012 2013 2014 2015 2016 2017 2018 2019 2020
	
	
	local years2 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020
	
	foreach y in `years'{ 
	use `y', clear
 	gen isco08 = occupation 
	replace isco08 = 13 if isco08 == 14  
	replace isco08 = 21 if isco08 == 25
	replace isco08 = 24 if isco08 == 26
	replace isco08 = 31 if isco08 == 35 
	replace isco08 = 41 if inlist(isco08, 43, 44) 
	replace isco08 = 51 if inlist(isco08, 53, 54)
	replace isco08 = 62 if isco08 == 63
	replace isco08 = 74 if isco08 == 75
	replace isco08 = 91 if inlist(isco08, 94, 95, 96)
	
	ren isco08 isco88
	gen occupation08 = occupation
	drop occupation
	ren isco88 occupation
	saveold `y', replace
	}
	
	local years2 2004 2005 2006 2007 2008 2009 2010 2011 

	foreach y in `years2'{ 
	use `y', clear
 	gen occ9_88 = 0 
	replace occ9_88 = 1 if inlist(occupation88, 11, 12, 13)
	replace occ9_88 = 2 if inlist(occupation88, 21, 22, 23, 24)
	replace occ9_88 = 3 if inlist(occupation88, 31, 32, 33, 34)
	replace occ9_88 = 4 if inlist(occupation88, 41, 42)
	replace occ9_88 = 5 if inlist(occupation88, 51, 52)
	replace occ9_88 = 6 if inlist(occupation88, 61, 62)
	replace occ9_88 = 7 if inlist(occupation88, 71, 72, 73, 74)
	replace occ9_88 = 8 if inlist(occupation88, 81, 82, 83)
	replace occ9_88 = 9 if inlist(occupation88, 91, 92, 93)
	
   	quietly label define occ9_88 ///
		1 "Legislators, senior, officials and managers" ///
		2 "Professionals" ///
		3 "Technicians and associate professionals" ///
		4 "Clerks" ///
		5 "Service workers and shop and market sales workers" ///
		6 "Skilled agricultural, and fishery workers" ///
		7 "Craft and related trades workers" ///
		8 "Plant and machine operators and assemblers" ///
		9 "Elemantary occupations"
		
	label values occ9_88 occ9_88
	tab occ9_8
	saveold `y', replace
	compress
	}
   
	local years 2012 2013 2014 2015 2016 2017 2018 2019 2020
	
	foreach y in `years' {
		use `y', clear
 	gen occ9_08 = 0 
	replace occ9_08 = 1 if inlist(occupation08, 11, 12, 13, 14)
	replace occ9_08 = 2 if inlist(occupation08, 21, 22, 23, 24, 25, 26)
	replace occ9_08 = 3 if inlist(occupation08, 31, 32, 33, 34, 35)
	replace occ9_08 = 4 if inlist(occupation08, 41, 42, 43, 44)
	replace occ9_08 = 5 if inlist(occupation08, 51, 52, 53, 54)
	replace occ9_08 = 6 if inlist(occupation08, 61, 62, 63)
	replace occ9_08 = 7 if inlist(occupation08, 71, 72, 73, 74, 75)
	replace occ9_08 = 8 if inlist(occupation08, 81, 82, 83)
	replace occ9_08 = 9 if inlist(occupation08, 91, 92, 93, 94, 95, 96)
	
   	quietly label define occ9_08 ///
		1 "Managers" ///
		2 "Professionals" ///
		3 "Technicians and associate professionals" ///
		4 "Clerical support workers" ///
		5 "Service and sales workers" ///
		6 "Skilled agricultural, forestry and fishery workers" ///
		7 "Craft and related trades workers" ///
		8 "Plant and machine operators and assemblers" ///
		9 "Elemantary occupations"
		
	label values occ9_08 occ9_08
	tab occ9_08
	compress
	saveold `y', replace
	}
	
   	global path_in "/Users/evrengulser/Desktop/TUIKDATA/Evren_data/noremovingobs"
	global path_out "$path_in/new"
	
	cd "$path_in"
	
	foreach y in `years2'{
		use `y', clear
		capture drop occupation if occupation == 62
		save "path_out/`y'", replace
	}


    foreach y in `years2'{ 
    use `y', clear
    drop if occupation == 62
	drop if occupation == 61
	saveold `y', replace
   }
   
   
   	local years 2013 2014 2015 2016 2017 2018 2019 2020
	
	foreach y in `years' {
		use `y',clear
		ren occupation occupation08
		compress
		saveold `y', replace
	}
   
   forval i = 2004(1)2011 {
   	use `i', clear
	ren occupation occupation88
	compress
	saveold	`i', replace
   }
	