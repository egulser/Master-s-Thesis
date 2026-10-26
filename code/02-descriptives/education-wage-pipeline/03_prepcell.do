	#delimit ;
	
		
	clear all;
	
	* set trace on;
	
	local workdir "/Users/evrengulser/Desktop/TUIKDATA/raw/LFS/precollapse";	
	cd `workdir';
	
	
	forvalues year = 2004/2020 {;
	
	* local year = 2011;
			
	use `year', clear;
	
	gen ft = (emp_type == 1);
	gen exp = tenure;
	
	gen winc_ws = wage/4.33;
	label var winc_ws "weekly wage of wage and salary workers";
	
	gen hinc_ws = winc_ws/uweeklywh;
	label var hinc_ws "hourly wage of wage and salary workers";
	
	* Generate some earnings variables;
	
	/* for monthly wages */

	gen rminc 		= (wage * gdp);
	label variable rminc "Real weekly wage (2010₺)";
	
	gen lnminc		=ln(wage);
	label variable lnminc "Log of monthly wage";
	
	gen rlnminc 	=lnminc + ln(gdp);
	label variable rlnminc "Log of real monthly wage (2010₺)";
	
	/* for weekly wages */
	
	gen rwinc 		=((wage/4.33) * gdp);
	label variable rwinc "Real weekly wage (2010₺)";
	
	gen lnwinc		=ln(wage/4.33);
	label variable lnwinc "Log of weekly wage";
	
	gen rlnwinc 	=lnwinc + ln(gdp);
	label variable rlnwinc "Log of real weekly wage (2010₺)";	
	
	/* for hourly wages */
	
	gen rhinc 		=(wage_hourly * gdp);
	label variable rhinc "Real hourly wage (2010₺)";
	
	gen lnhinc		=ln(wage_hourly);
	label variable lnhinc "Log of hourly wage";
	
	gen rlnhinc 	=lnhinc + ln(gdp);
	label variable rlnhinc "Log of real hourly wage (2010₺)";
	
	**** Generate some count variables;
	
	gen q_obs = 1;
	label variable q_obs "Number of observations";
	
	gen q_weight = weight;
	label variable q_weight "Earnings weight";
	
	* gen q_lsweight = weight * monthsworkedly;
	* label variable q_lsweight "Earnings weight times months last year";
	
	gen q_lshrsweight = weight * /* monthsworkedly */ uweeklywh;
	label variable q_lshrsweight "Earnings weight times hours last year";		
	
	**** Generate some price variables;	
	
	save ../tmp/precollapse`year'.dta, replace;
	
	**** Collapse the dataset down to year by edu by experience by gender cells;
	
	collapse (sum) q_obs q_weight q_lshrsweight, by(year edcat5 exp female);
	
	sort year edcat5 exp female;
	
	save ../tmp/lfscells`year'.dta, replace;
	
	use ../tmp/precollapse`year'.dta;
	
	collapse (mean) rwinc rlnwinc rhinc rlnhinc [aweight=weight], by(year edcat5 exp female);
	
	sort year edcat5 exp female;
	
	merge year edcat5 exp female using ../tmp/lfscells`year'.dta;
	
	save ../tmp/lfscells-`year'.dta, replace;
	
	* !rm marchcells`year'.dta;
	
	};
		
