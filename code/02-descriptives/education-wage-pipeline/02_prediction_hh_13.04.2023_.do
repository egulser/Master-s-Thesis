	#delimit ;
	
	capture log close;
	set logtype smcl;
	
	cd /Users/evrengulser/Desktop/TUIKDATA/raw/LFS/precollapse;
	
	
	log using ../log/predict-lfswg-regs-exp-allyears,replace;
	
	* Predict -wg-regs-exp.do for LFS
	
	clear all;
	
	local firstyear 2004;
	local lastyear 	2020;
	
	forvalues year = `firstyear'/`lastyear' 
	{;
		
		disp `year'; 
				
		use `year', clear;		
		
		gen winc_ws = wage/4.33;
		label var winc_ws "weekly wage of wage and salary workers";
		
		gen hinc_ws = winc_ws/uweeklywh;
		label var hinc_ws "hourly wage of wage and salary workers";
		
	
		
		xtile 	ptile = winc_ws , nq(100);
		gen flag = (ptile == 1 | ptile == 100);
		drop if flag == 1;
		
		

		ren edcat5 schoolcat5;
		
		assert hinc_ws==. if winc_ws==.;
		assert winc_ws==. if hinc_ws==.;
		drop if winc_ws==.;
		gen lnwinc=ln(winc_ws);
		gen lnhinc=ln(hinc_ws);
		
		gen fulltime =0;
		replace fulltime = 1 if emp_type == 1;
		gen wgt = weight;
				
		/* 	Create experience categories */
		/* 	Experience categoreis are modified in order to incerase observations in each category */
		
		gen exp = tenure;
		drop if exp>48;
	
		forval x=5(10)45
		{;
			gen exp`x'=0;
		};
		replace exp5 =  2 if  exp>=0  & exp<= 5;
		replace exp15 = 7 if  exp>=6  & exp<=10;
		replace exp25 = 13 if exp>=11 & exp<=15;
		replace exp35 = 17 if exp>=16 & exp<=20;
		replace exp45 = 30 if exp>=21 & exp<=48;
		
		* experience ortalamalarini hesapla *
		
		assert exp5 + exp15 + exp25 + exp35 + exp45 <= 45;
		
		/* 	experience education interactions (by David Autor's education categories) ; */
		
		gen edhsd 		= noschl;
		gen edhsg		= prim;
		gen edsmc		= high;
		gen edclg		= voch;
		gen edgtc		= univ;
		
		rename 	exp exp1;
		gen 	exp2 = (exp1^2)/100;
		gen 	exp3 = (exp1^3)/1000;
		gen 	exp4 = (exp1^4)/10000;
		
		gen e1edhsd = exp1*edhsd;
		gen e1edsmc = exp1*edsmc;
		gen e1edclg = exp1*(edclg|edgtc);
		
		gen e2edhsd = exp2*edhsd;
		gen e2edsmc = exp2*edsmc;
		gen e2edclg = exp2*(edclg|edgtc);
		
		gen e3edhsd = exp3*edhsd;
		gen e3edsmc = exp3*edsmc;
		gen e3edclg = exp3*(edclg|edgtc);
		
		gen e4edhsd = exp4*edhsd;
		gen e4edsmc = exp4*edsmc;
		gen e4edclg = exp4*(edclg|edgtc);
				
		* Gender interactions with experience, part-time;
		gen byte pt = !fulltime;
		
		gen fexp1 = female*exp1;
		gen fexp2 = female*exp2;
		gen fexp3 = female*exp3;
		gen fexp4 = female*exp4;
		
		gen byte fpt = female*pt;
				
		for any edhsd edhsg edsmc edclg edgtc: summ winc_ws if X==1 [aw=wgt];
		
		************************************************************************;
		** Predict wages -- Weekly-Hourly, Without any trimming ****************;
		************************************************************************;
				
		* Male & Female regression for ln wweekly wage;
		
		disp `year';
		
		regress lnwinc 	edhsd edsmc edclg edgtc
						exp1 exp2 exp3 exp4 e1* e2* e3* e4*
						[aw=wgt]; 
					
					
		/* Predict values for weekly wage; */
		
		predict plnwinc, xb;
		gen pwinc = exp(plnwinc);
		
		
		* Male & Female regression for ln wweekly wage;
		
		regress lnhinc 	edhsd edsmc edclg edgtc
						exp1 exp2 exp3 exp4 e1* e2* e3* e4*
						[aw=wgt];
						
		/* Predict values for hourly wage; */
		
		predict plnhinc, xb;
		gen phinc = exp(plnhinc);
		
		/* Regenerating varibles */
		
		ren schoolcat5 edcat5;
		gen expcat = exp5 + exp15 + exp25 + exp35 + exp45;
				
		/* Collapse predicted weekly and hourly income by education & gender & experience categories */
		
		collapse (mean) pwinc phinc [aw=weight], by(year female expcat edcat5);
		sort female edcat5 expcat;
		sum;
		assert _N==50;
		
		save ../tmp/predwg-`year', replace;
	};
	
	use ../tmp/predwg-2004,clear;
	
	forval y = 2005/2020 
	{;
		append using ../tmp/predwg-`y';
	};
	
	exit;













