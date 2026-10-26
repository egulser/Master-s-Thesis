	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	use $project/data/clean/2004_v3 ,clear
	append using $project/data/clean/2008_v3
	append using $project/data/clean/2012_v3
	append using $project/data/clean/2016_v3
	append using $project/data/clean/2022_v3


qui {
	foreach y of numlist 2004(4)2016 2022 {
	
	use $project/data/clean/`y'_v3 ,clear
	
	capture gen lswt = uweeklywh * weight	
	
	local minwage2004 (303+318)/2
	local minwage2008 (481+503)/2
	local minwage2012 (701+739)/2	
	local minwage2016 1300
	local minwage2022 (4253+5500)/2
	
	
	local skillproxy 	wage
	local skillproxy2 	wage/uweeklywh
	local skillproxy3 	educat5	
	
	local stat1 mean
	local stat2 median
	/*
	foreach y of numlist 2004(4)2016 2022 {
		drop if wage < (`minwage`y'' *0.75)
	}
	*/
	if year == 2004 {
		replace wage = wage/10^6
	drop if wage < (`minwage2004' * 0.75) 
	}
	
	if year == 2008 {
	drop if wage < (`minwage2008' * 0.75) 
	}
	
	if year == 2012 {
	drop if wage < (`minwage2012' * 0.75)
	}
	
	if year == 2016 {
	drop if wage < (`minwage2016' * 0.75)
	}
	
	if year == 2022 {
	drop if wage < (`minwage2022' * 0.75)
	}	
	
	drop if parttime
	
	if year == 2004 | year == 2008 | year == 2012 {
		drop if isco88 == 33 | isco88 == 62 | isco88 == 61 | isco88 == 13 
	}
	
	if year == 2016 | year == 2022 {
		drop if isco08 == 33 | isco08 == 62 | isco08 == 61 | isco08 == 13 
	}
	
	
	noi tab year
	
	local ind ind_broad_4		
	gen 	ind_broad_4 = 0
	replace ind_broad_4	= 1 if inrange(sector, 1,3)
	replace ind_broad_4	= 2 if inrange(sector, 5, 39)
	replace ind_broad_4	= 3 if inrange(sector, 41, 43)
	replace ind_broad_4	= 4 if inrange(sector, 45, 99)
	drop if ind_broad_4  == 0
	assert ind_broad_4 != 0
	
	tab isco88 year [aw=lswt], col
	
	saveold $project/data/clean/`y'_v6, replace
	
	}
}
