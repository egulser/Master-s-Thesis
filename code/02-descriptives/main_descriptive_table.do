



	drop if employment_status != 1
	drop if employment_type != 1
	
	gen tenuredelta = year - tenure
	
	label variable tenuredelta "-7993 if unknown"
	
	mean tenuredelta  [aw=weight], over(sex)
	
	tab educ sex [aw=weight], col nofreq
	
	tab age_group sex [aw=weight], col nofreq
	
	tab marital_status sex [aw=weight], col nofreq
	
	tab state_private  sex [aw=weight], col nofreq
	
	tab additional_job sex [aw=weight], col nofreq
	
	tab occ9_08 sex [aw=weight], col nofreq
	
	tab firm_size  sex [aw=weight], col nofreq
	
	fre industry [aw=weight]
	
	fre educ sex [aw=weight]
	
		forvalues y = 2004(1)2008 {
		
		use `y', clear
		
		*drop if permanency !=1
		*drop if employment_status == 3 |  employment_status == 4 | employment_status == 5
		*drop if employment_type != 1
		
		drop if durum !=1
		
		display "educat5 `y'"
		tab educat5 sex [aw=weight], col nofreq
		
	}
	
	
	forvalues y = 2009(1)2020 {
	
		use `y', clear
		
		*drop if permanency !=1
		*drop if employment_status != 1
		*drop if employment_type != 1
		
		drop if durum !=1
		
		display "educat5 `y'"
		tab educat5 sex [aw=weight], col nofreq
		
	}
	
		2.12.2022
	
		*Permanency variable is only reported if the worker is a wage or salaried or casual employee.
		
		*Bütün yillar için tenuredelta değişkeni yaratildi. 2004-2007 arasi unknown için 9999 kaydedilmiş. labela bu durum yazildi.
		
		*Labor status of the household member (DURUM) değişkeni ile belirlenen Unemployed veya non in the labor force olanlar çikarailara raw3'e kaydedildi. 
		
		
		
		forvalues y = 2008(1)2019 {
			use `y', clear
			gen tenuredelta = year - tenure	
			saveold `y', replace
		}
	
		forvalues y = 2004(1)2020 {
		use `y', clear
		
		drop if durum != 1
		
saveold "/Users/evrengulser/Desktop/TUIKDATA/data/raw/3/`y'", replace	
	}
	
	
	gen male = 0

	replace male if sex==1


	replace male=1 if sex==1


	en female==0

	gen female=0

	replace female=1 if sex==2

	table educat5 [aw=weight] , statistic(percent male female) nototal
	
	
	