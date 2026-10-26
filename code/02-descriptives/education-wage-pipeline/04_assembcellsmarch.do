# delimit ;


	clear all;
	
	* set trace on;
	
	local workdir "/Users/evrengulser/Desktop/TUIKDATA/raw/LFS/precollapse";	
	cd `workdir';


	local baseyear 2004;
	
	use ../tmp/lfscells-`baseyear';		
	
	forvalues y = 2005/2020 {;
		append using ../tmp/lfscells-`y';
	};	
	
	
	gen lnrwinc = ln(rwinc);
	label variable lnrwinc "Log of mean real weekly earnings, 2010₺";
	gen lnrhinc = ln(rhinc);
	label variable lnrhinc "Log of mean real FT wage, 2010₺";
	
	label var rlnwinc "Mean of log real weekly earnings";
	label var rlnhinc "Mean of log real wage";
	
	/*label var exp "Potential years of experience (max(age-educomp-6,0))"*/
	label var exp "Experience";
	label var q_obs "Total number of observations";
	label var q_weight "Sum of LFS weights for all observations";
	
	label var _merge "Merge will be equal to 2 when there is a cell for which there were only obs WITHOUT earnings/wage data";
	
	save ../tmp/lfscells0420, replace;
	
# delimit cr	
	
	