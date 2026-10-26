
	capture log close
	log using silc_clean, replace text
	
	//  program:    _name_.do
	//  task:
	//  project:
	//  author:     _who_ \ _date_
	
	//  #0
	//  program setup
	
	version 17.0
	clear all
	set linesize 80
	macro drop _all
	
	local date
	local tag "\ _name_.do jsl `date'"
	
	//  #1
	//  Generating new variables 
	
	//  #2
	//  Dropping observations to obtain a clean dataset
	
	//	#3 
	// 	Creating labels for vars
	
	
	* NOTES:
					****************** fi010 emp_status *********************
					*														*
					*	1- Full-time  2- Part-time  3- İş arıyor			* 			
					*	4- Eğitim devam 5- Emekli 6- Mevsimlik çalışıyor	*
					*	7- Yaşlı, engelli veya çalışamaz halde 				*	
					*	8- Ev işleri ile meşgul 9- Diğer					*
					*														*
					*********************************************************
				

	* Codes start here 	
	
	global workdir 	/Users/evrengulser/Desktop/TUIKDATA/raw/LFS/data_10.04
	
	local cpidir 	../../../dofiles

	cd $workdir
	
		
	forvalues y = 2004/2020 {
		
		use `y' ,clear	
		
		
**# Bookmark #1 Generating new variables
				

		gen school 					= educ	// 0- okur yazar değil, 10 - doktora	
		gen emp_status 				= employment_status 
		gen emp_type 				= employment_type 		

		drop if tenure 		> 2500
		replace tenure 		= year-tenure 		// total worked years
		
		gen wage_hourly 	= wage	/(uweeklywh*4.33) // following (Bakis and Polat, 2015)
			
		gen female 			= 0
		replace female 		= 1 if sex == 2
				
**# Bookmark #2 Downsizing dataset

		* Trimming the first and last percentile
		
		drop if wage == 0 | wage == .
		
		xtile ptile = wage, nq(100)
		drop if ptile == 1 | ptile == 100 
		drop ptile
		
			
			gen age_interval = .
			replace age_interval = 4   if inrange(age, 15, 19)
			replace age_interval = 5   if inrange(age, 20, 24)
			replace age_interval = 6   if inrange(age, 25, 29)
			replace age_interval = 7   if inrange(age, 30, 34)
			replace age_interval = 8   if inrange(age, 35, 39)
			replace age_interval = 9   if inrange(age, 40, 44)
			replace age_interval = 10  if inrange(age, 45, 49)
			replace age_interval = 11  if inrange(age, 50, 54)
			replace age_interval = 12  if inrange(age, 55, 59)
			replace age_interval = 13  if inrange(age, 60, 64)
			
			replace age = max(age_interval-3,1)			
			
		
				
		gen age_1 =    (age==1) + (age==2 )
		gen age_2 = 2*((age==3) + (age==4 )) 
		gen age_3 = 3*((age==5) + (age==6 )) 
		gen age_4 = 4*((age==7) + (age==8 )) 
		gen age_5 = 5*((age==9) + (age==10))
		
		gen age_10 = age_1 + age_2 + age_3 + age_4 + age_5
		
		drop age_1 age_2 age_3 age_4 age_5
		
		ren age_10 age_5
		
		*gen age_10 = age
		*replace age_10 = age==
		
		drop if emp_status		> 2 // full time waged workers
		
		*drop self employed and other type of workers
		drop if emp_type		> 2 // waged employees
		
		*drop workers working less than 35 hours *(Skills, tasks, and techonologies)
		drop if uweeklywh	 	< 8 
		drop if uweeklywh 		> 84
		
		*drop temporary workers
		drop if permanency 		> 2
				
		save ../temp_clean/`y', replace
		
	}
	
	cd ../temp_clean
		
		
		forval y = 2004/2009 {
				use `y', clear					
				recode school (0=1) (3=2) (4=3) (5=4) (6=5) 	
				label define school 1 "NOSCL" 2 "PRIM" 3 "HIGH" 4 "VOCHIGH" 5 "UNIV" 
				label values school school
				tab school
				save `y', replace
				
		}
		
		forvalues y = 2010/2013 {				
				use `y', clear
				recode school (0=1) (3=2) (4=3) (5=4) (6=5) 
				label define school 1 "NOSCL" 2 "PRIM" 3 "HIGH" 4 "VOCHIGH" 5 "UNIV"  
				label values school school 
				disp `y'
				tab school 
				save `y', replace
			}	
			
			
			forvalues y = 2014/2020 {				
				use `y',clear				
				recode school (0=1) (3=2) (4=3) (5=4) (6=5) (7=5)
				label define school 1 "NOSCL" 2 "PRIM" 3 "HIGH" 4 "VOCHIGH" 5 "UNIV"  
				label values school school 
				disp `y'
				tab school
				save `y', replace
			}
			
		
	
		forvalues y = 2004/2020 {
			use `y', clear
			ren school edcat5
			
			gen noschl 		= 0 
			replace noschl 	= 1 if (edcat5 == 1)
			
			gen prim 		= 0
			replace prim   = 1 if (edcat5 == 2)
			
			gen high 		= 0
			replace high 	= 1 if (edcat5 == 3)
			
			gen voch 		= 0
			replace voch	= 1 if (edcat5 == 4)
			
			gen univ 		= 0
			replace univ	= 1 if (edcat5 == 5)
					
			* create 10 age categories
			
			label define age 	1 "15-19" 2 "20-24" 3 "25-29" 4 "30-34" 5 "35-39" ///
								6 "40-44" 7 "45-49" 8 "50-54" 9 "55-59" 10 "60-64"
			label values age age
			
			ren age age_10
			
			labe define age_5 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64"
			label values age_5 age_5
			
			
			label var female 			"0 = male, 1= female"
			label var age_10 			"ages between 15-64, 10 categories"
			label var age_5 			"ages between 15-64, 5 categories"
			label var edcat5    		"Education levels with 5 categories"
			label var uweeklywh 		"Usual weekly working hours"
			label var wage 				"wage income in the previous month"
			
			save `y', replace
		}	

		
		local cpidir /Users/evrengulser/Desktop/TUIKDATA/dofiles
										
		* dropping old variables
		
		forvalues y = 2004/2020 {
			use `y', clear
		
			keep 	year weight marital_status edcat5 emp_status  ///
					emp_type occupation* industry uweeklywh permanency tenure ///
					female age* noschl prim high voch univ wage*
						
			do `cpidir'/cpi.do
			do `cpidir'/gdp.do
						
			save `y', replace		
		}
								
		forvalues y = 2004/2020 {
			use `y', clear
			
			if `y' == 2004	{
				replace wage = wage/10^6
				replace wage_hourly = wage_hourly/10^6
			}
			
		save ../precollapse/`y', replace		
		}
		
		exit			
					
		***************************************			
		/* Codes below moved to another do file 			
		
		* Data for full time permanent wage workers
		
		* Generate some earnings variables;

		gen rminc 		= (wage * gdp)
		label variable rminc "Real weekly wage (2010₺)"
		
		gen lnminc		=ln(wage)
		label variable lnminc "Log of monthly wage"
		
		gen rlnminc 	=lnminc + ln(gdp)
		label variable rlnminc "Log of real monthly wage (2010₺)"
		
		**************************************
		
		gen rwinc 		=((wage/4.33) * gdp)
		label variable rwinc "Real weekly wage (2010₺)"
		
		gen lnwinc		=ln(wage/4.33)
		label variable lnwinc "Log of weekly wage"
		
		gen rlnwinc 	=lnwinc + ln(gdp)
		label variable rlnwinc "Log of real weekly wage (2010₺)"	
		
		**************************************
		
		gen rhinc 		=(wage_hourly * gdp)
		label variable rhinc "Real hourly wage (2010₺)"
		
		gen lnhinc		=ln(wage_hourly)
		label variable lnhinc "Log of hourly wage"
		
		gen rlnhinc 	=lnhinc + ln(gdp)
		label variable rlnhinc "Log of real hourly wage (2010₺)"
		
		**** Generate some count variables;
		
		gen q_obs = 1
		label variable q_obs "Number of observations"
		
		gen q_weight = weight
		label variable q_weight "Earnings weight"
		
		*gen q_lsweight = weight * monthsworkedly
		*label variable q_lsweight "Earnings weight times months last year"
		
		gen q_lshrsweight = weight * /* monthsworkedly */ uweeklywh
		label variable q_lshrsweight "Earnings weight times hours last year"		
		
		drop if tenure == .
									 		
		save ../precollapse/`y', replace		
								
	}
	
		exit

		**** Collapse the dataset down to year by edu by experience by gender cells
		
	cd ../precollapse
		
		forvalues y = 2004/2020 {
			
			use `y', clear
		
			collapse (sum) q_obs q_weight q_lshrsweight , by(year edcat5 exp female)
			
			sort year edcat5 exp female
		
			save ../cells/cells`y'.dta, replace
		
			* use /tmp/precollapsemarch`1'.dta
			use `y', clear
			
			collapse (mean) rminc rlnminc rwinc rlnwinc rhinc rlnhinc [aweight=weight], by(year edcat5 exp female)
			
			sort year edcat5 exp female
			
			merge m:m year edcat5 exp female using ../cells/cells`y'.dta
			
			* save ../intermed/marchcells-`1'.dta, replace
			save ../cells/cells`y'.dta, replace
		}	
		
		cd /Users/evrengulser/Desktop/TUIKDATA/raw/LFS/cells
				
		use cells2004, clear
		
		forvalues y = 2005/2020 {
			append using cells`y'						
		}
	
	
	drop _merge
	gen lswt = q_lshrsweight			
	label var lswt "Summ of hours x weight" 
	sort year edcat5 exp female 
	
	* Calculate fixed weights
	egen t1=sum(lswt),by(year)
	gen normlswt=lswt/t1
	egen avlswt=mean(normlswt),by(edcat5 female exp)
	drop t1
	
	label var lswt "Labor supply in cell"
	label var normlswt "Labor supply share in cell/year"
	label var avlswt "Average labor supply share in cell over 1963 - 2008"
	
	save ../cells-04-20, replace	

			
	
		codebook

		log close
		exit
	
