		
		use "/Users/evrengulser/Desktop/TUIKDATA/tempbox/data/lswt-pctile-2004-2020.dta", replace	
		
		cd /Users/evrengulser/Desktop/TUIKDATA/tempbox/data/ineq
		
		
		************** Ücretleri reel yap 	**************
		**************						**************
		**************						**************
		
		
		append using lfs-ineq-data-2005
		append using lfs-ineq-data-2006
		append using lfs-ineq-data-2007
		append using lfs-ineq-data-2008
		append using lfs-ineq-data-2009
		append using lfs-ineq-data-2010
		append using lfs-ineq-data-2011
		append using lfs-ineq-data-2012
		append using lfs-ineq-data-2013
		append using lfs-ineq-data-2014
		append using lfs-ineq-data-2015
		append using lfs-ineq-data-2016
		append using lfs-ineq-data-2017
		append using lfs-ineq-data-2018
		append using lfs-ineq-data-2019
		append using lfs-ineq-data-2020
	
		
		local fy 2004
		local ly 2020

		/* normalize to 2004 median level */
		foreach gen in mf m f {
			sort year
			local temp=tot_ft_`gen'_50[1]
			replace tot_ft_`gen'_50=tot_ft_`gen'_50-`temp'
			local temp=tot_ft_`gen'_10[1]
			replace tot_ft_`gen'_10=tot_ft_`gen'_10-`temp'
			local temp=tot_ft_`gen'_90[1]
			replace tot_ft_`gen'_90=tot_ft_`gen'_90-`temp'
		}    

		#delimit ;	
			
		* Fig 7a: Cumulative Log change in weekly wages, males and females;
		twoway (connected tot_ft_mf_10 tot_ft_mf_50 tot_ft_mf_90 year, xlabel(2004(4)2020, labsize(small)) 
		title("Cumulative Log Change in Real Weekly Earnings at the 90th, 50th and 10th" "Wage Percentiles"
		"1963-2008: Full-Time Full-Year Males and Females", size(medsmall)) 
		msymbol(oh dh) ytitle("Cumulative Log Change in Weekly Wages", 
		size(small)) xtitle("") ytick(0(0.1).5, grid) legend(region(lstyle(none)) 
		label(1 "10th Percentile") label(2 "50th Percentile") label(3 "90th Percentile") )), 
		saving(fig7a-akk-polar-real-mar-mf-905010-1963-2008.gph,replace);		
		#delimit cr
		
	
		#delimit ;		
		* Fig 7b: Cumulative Log change in weekly wages, males ;
		twoway (connected tot_ft_m_10 tot_ft_m_50 tot_ft_m_90 year, xlabel(2004(4)2020, labsize(small)) 
		title("Cumulative Log Change in Real Weekly Earnings at the 90th, 50th and 10th" "Wage Percentiles"
		"1963-2008: Full-Time Full-Year Males", size(medsmall))
		msymbol(oh dh) ytitle("Cumulative Log Change in Weekly Wages", size(small)) 
		xtitle("") ytick(0(0.05)0.6, grid) legend(region(lstyle(none))
		label(1 "10th Percentile") label(2 "50th Percentile") label(3 "90th Percentile") )),
		saving(fig7b-akk-polar-real-mar-m-905010-1963-2008.gph,replace);		
		#delimit cr

		#delimit ;
		* Fig 7c: Cumulative Log change in weekly wages, females;
		twoway (connected tot_ft_f_10 tot_ft_f_50 tot_ft_f_90 year, xlabel(2004(4)2020, labsize(small)) 
		title("Cumulative Log Change in Real Weekly Earnings at the 90th, 50th and 10th" "Wage Percentiles"
		"1963-2008: Full-Time Full-Year Females", size(medsmall)) 
		msymbol(oh dh) ytitle("Cumulative Log Change in Weekly Wages", size(small))
		xtitle("") ytick(0(0.05)0.5, grid) legend(region(lstyle(none)) 
		label(1 "10th Percentile") label(2 "50th Percentile") label(3 "90th Percentile") )), 
		saving(fig7c-akk-polar-real-mar-f-905010-1963-2008.gph,replace);
		#delimit cr
