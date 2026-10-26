	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project
	
	use $project/data/clean/2004_v3 ,clear
	
	append using $project/data/clean/2008_v3
	append using $project/data/clean/2012_v3
	append using $project/data/clean/2016_v3
	append using $project/data/clean/2022_v3
	drop if age_int == 11

	tab age_group year [aw=weight]

	tab exp year 
	
	gen worker_numberfirm = s32a if year == 2004
	replace worker_numberfirm = s37a if year == 2008 | year == 2012
	replace worker_numberfirm = calisan_sayi_hh if year == 2016 | year == 2022
	
	tab worker_numberfirm year
	
	
	gen addit_job = s51 if year == 2004
	replace addit_job = s58 if year == 2008 
	replace addit_job = s52 if year == 2012
	replace addit_job = ekis_durum if year == 2016
	tab addit_job year
	
	gen addit_job_2022 = 2 if year == 2022 & is_sayi == 1
	tab  addit_job_2022	
	replace  addit_job_2022 = 1 if year == 2022 & is_sayi == 2
	replace  addit_job_2022 = 1 if year == 2022 & is_sayi == 3
	tab  addit_job_2022 year
	replace addit_job = addit_job_2022 if year == 2022
	
	tab addit_job year [aw=weight] , col
	
	
	gen type_workplace = s30 if year == 2004
	replace type_workplace = s35 if year == 2008 | year == 2012
	replace type_workplace = isyeri_durum if year == 2016 | year == 2022
	
	tab type_workplace year
	recode type_workplace (5=4) (6=5) if year == 2004
	tab type_workplace if year ==2004
	
	tab worker_numberfirm 	year 	[aw=weight], col
	tab type_workplace 		year 	[aw=weight], col
	tab addit_job 			year 	[aw=weight], col

	tab age_int year [aw=weight], col
	
	gen int age_int_new = age_int
	
	recode age_int_new (2=1) (3=2) (4=2) (5=3) (6=3) (7=4) (8=4) (9=5) (10=5)
	tab age_int_new year [aw=weight], col
	
	tab worker_numberfirm 	year 	[aw=weight], col
	tab type_workplace 		year 	[aw=weight], col
	tab addit_job 			year 	[aw=weight], col
	tab age_int_new 		year 	[aw=weight], col	
	
	
	
	recode worker_numberfirm (3=2) (4=3) if year == 2004	
	recode worker_numberfirm (3=2) (4=3) (5=3) (6=3) if year == 2008 | year == 2012
	recode worker_numberfirm (3=2) (4=3) (5=4) if year == 2016 
	recode worker_numberfirm (3=2) (4=3) (5=3) (6=4) if year == 2022
	
	tab worker_numberfirm year [aw=weight], col
	