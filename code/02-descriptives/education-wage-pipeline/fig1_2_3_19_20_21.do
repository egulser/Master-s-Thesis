
	clear all
	local workdir 	"/Users/evrengulser/Desktop/TUIKDATA/raw/LFS"
	local figdir 	"/Users/evrengulser/Desktop/TUIKDATA/figdir"
	
	cd `workdir'/cleaned

	* Wage gap series
	* use /proj/hole-vol4/march/series/clghsgwg-march-regseries-exp.dta,clear
	use clghsgwg-march-regseries-exp.dta,clear
	desc
	keep year clghsg_all* clphsg_all*
	
	* Adding supplies series
	sort year
	* merge year using /proj/hole-vol4/march/series/effunits-exp-byexp-6308
	merge year using effunits-exp-byexp-0420
	assert _merge==3
	drop _merge
	desc eu_* euexp*
	* drop euexp*
	tab expcat
	keep if expcat==1
	drop expcat
	desc
	
	* Save working series
	label data "March 1963-2008 wage gaps and efficiency units: Experienced-based measures"
	* save /proj/hole-vol4/march/series/march-price-quantity-exp-all,replace
	* use /proj/hole-vol4/march/series/march-price-quantity-exp-all,clear
	
	save march-price-quantity-exp-all,replace
	use march-price-quantity-exp-all,clear
	
	desc
	
	*Different College/HS Wage Diff Series, M&F Combined and Rel Supply
	list year clphsg_all eu_lnclg
	*Trend Terms
	gen t = year-2003
	gen t2 = t*t
	*Post-1992 Trend Shift -- Change in CPS Education Coding
	gen t92 = max(year-2003, 0)
	
	*Trend Regressions for Wage Diff and Relative Supply Terms
	reg clphsg_all t
	predict gapdt,resid
	reg eu_lnclg t
	predict supdt,resid
	label variable gapdt "Detrended Wage Differential"
	label variable supdt "Detrended Relative Supply"
	label variable year " "
	label variable clphsg_all "Observed CLG/HS Gap"
	
	*local yticklabwage .3(.02).5
	
	
	
	* Fig 1: Composition-adjusted college/high-school log weekly wage ratio
	scatter clphsg_all year, c(l) xlabel(2004(2)2020, labsize(small)) xline(2014) ///
	ytick(`yticklabwage', grid) legend(region(lstyle(none)))  ///
	ytitle("Log Wage Gap") ///
	ti("Composition Adjusted College/High-School Log Weekly Wage Ratio, 2004-2020", size(medium)) legend(size(small)) saving("fig1-clp-hsg-gap-6308.gph", replace)
	
	graph export "`figdir'/1.jpg", replace
	graph export "`figdir'/1.eps", replace
	
	
	
	
	* Fig 2: College/high-school relative supply series -- with title
	
	local yticksupply 	-1.3(.1)0
	local ylabsupply 	-1.3(.1)0
	
	scatter eu_lnclg year, c(l) xlabel(2004(2)2020, labsize(small)) xline(2014) ///
	ytick(`yticksupply', grid) legend(pos(1) ring(0) region(lstyle(outline))) ylab(`ylabsupply') ///
	ytitle("Log Relative Supply Index") ti("College/High-School Log Relative Supply, 2004-2020", size(medium)) saving("fig2-relative-supply-index-titled.gph",replace)
	
	graph export "`figdir'/2.jpg", replace
	graph export "`figdir'/2.eps", replace
	
	

	
/* OTHER VARIATIONS OF FIGURES, NOT USED, COMMENTED OUT 
#delimit ;
scatter gapdt supdt year, c(l l) msymbol (oh dh) xlabel(1963(5)2008) yline(0) 
legend(region(lstyle(none))) 
ti("A. Detrended College-High School Wage Differential and Relative Supply, 1963-2008", size(medium))  ytitle("Log Points") ylabel(-.15(.05).15)  legend(size(small))
saving("km-detrended-wagegap.gph", replace);
pause;

* College/high-school relative supply series;
scatter eu_lnclg year, c(l) msymbol (O) xlabel(1963(5)2008) xline(1982) 
legend(region(lstyle(none))) ylab(-.9(.3).3) ytitle("Log Relative Supply Index") ti(" ")
saving("relative-supply-index.gph",replace);

* College/high-school relative supply series, exponentiated;
gen expeu=exp(eu_lnclg);
label var expeu "College/High-School Relative Supply";
scatter expeu year, c(l) msymbol (O) xlabel(1963(5)2008) xline(1982) 
legend(region(lstyle(none))) ylab(.3(.2)1.5) ytitle("Relative Supply") ti("College/High-School Relative Supply, 1963-2008", size(medium))
saving("akk-relative-supply-index-exp.gph",replace);

* College/high-school relative supply series: Experience 0-9 years;
scatter euexp_lnclg_m euexp_lnclg_f eu_lnclg  year, c(l l l) msymbol (O) xlabel(1963(5)2008) xline(1982) 
legend(label(1 "Male 0-9 Yrs Experience") label(2 "Female 0-9 Yrs Experience") label(3 All) region(lstyle(none))) ylab(-.9(.3).9) ytitle("Log Relative Supply Index") ti(" ") 
saving("relative-supply-index-expcat1.gph",replace);

* College/high-school relative supply series -- with title: Experience 0-9 years;
scatter euexp_lnclg_m euexp_lnclg_f eu_lnclg  year, c(l l l) msymbol (O) xlabel(1963(5)2008) xline(1982) 
legend(label(1 "Male 0-9 Yrs Experience") label(2 "Female 0-9 Yrs Experience") label(3 All) region(lstyle(none))) ylab(-.9(.3).9) ytitle("Log Relative Supply Index") ti("College/High-School Log Relative Supply, 1963-2008") saving("relative-supply-index-expcat1-titled.gph",replace);
*/

#delimit;

* 1963-87 Regressions and Predictions ;
reg clphsg_all t eu_lnclg;
predict gap6387;
label variable gap6387 "Katz-Murphy Predicted Wage Gap: 2004-2020 Trend" ;

* Fig 19: Katz-Murphy predictions;
scatter clphsg_all gap6387 year, c(l l) msymbol (th x) xlabel(2004(2)2020, labsize(small)) xline(2014) 
legend(region(lstyle(none))) ylab(.3(.02).5) legend( pos(4) ring(0) region(lstyle(outline))) 

ytitle("Log Wage Gap") ti("Katz-Murphy Prediction Model for the College-High School Wage Gap", size(medium)) legend(size(small))
saving("fig19-km-predicted-series-6387.gph", replace);
pause;

graph export "`figdir'/3.jpg", replace;
graph export "`figdir'/3.eps", replace;



/* OTHER VARIATIONS OF FIGURES, NOT USED, COMMENTED OUT 
*1963-2008 Regressions and Predictions ;
reg clphsg_all t eu_lnclg;
predict kmgap;
label variable kmgap "Predicted Wage Gap" ;

gen expgap=exp(clphsg_all);
gen exppred=exp(kmgap);
label var expgap "Observed Wage Ratio";
label var exppred "Predicted Wage Ratio";

scatter expgap exppred year, c(l l) msymbol (oh dh) xlabel(1963(5)2008) 
legend(region(lstyle(none))) ylab(1.5(0.1)2.0) ytitle("Wage Ratio") ti("Actual and Predicted College/High-School Wage Ratio, 1963-2008", size(medium)) legend(size(small))
saving("akk-km-predicted-series-6308.gph", replace);
pause;

scatter expgap year, c(l ) msymbol (oh) xlabel(1964(3)2009, labsize(small)) xline(1980) 
legend(region(lstyle(none))) ylab(1.5(0.1)2.0) ytitle("Wage Ratio") ti("College/High-School Weekly Wage Ratio, 1963-2008", size(medium)) legend(size(small))
saving("akk-exp-clp-hsg-gap-6308.gph", replace);
pause;


*Full Sample Regressions with Different Trend Models, 1963-2008:
*Wage Gap Measure;
reg clphsg_all t eu_lnclg;
predict gapt;
reg clphsg_all t t2 eu_lnclg;
label variable gapt "Predicted Gap, Linear Trend";
reg clphsg_all t t92 eu_lnclg;
predict gapt92;
label variable gapt92 "Predicted Gap, Trend + Break in 1992";
label variable clphsg_all "Observed CLG/HS Gap";
list year clphsg_all gap6387 gapt gapt92;

* graph clphsg_all gapt92 year, c(ll) xlabel(1963(6)2005) xline(1987,1992)
ti("KM 1963-2008 Prediction, Gap Trend92")
saving("km6308_t92.gph", replace);

scatter clphsg_all gapt92 year, c(l l ) msymbol (oh dh) xlabel(1963(5)2008) xline(1987 1992) 
legend(region(lstyle(none))) ylab(.35(.1).65) ti("Katz Murphy 1963-2008 Predicted Gap: Trend and Break 1992+") ytitle("Log Wage Gap")
saving("km-6308-gap92.gph", replace);
pause;

scatter clphsg_all gap6387 gapt gapt92 year, c(l l l l) msymbol (oh dh t x) xlabel(1963(5)2008) xline(1987 1992) 
legend(region(lstyle(none))) ylab(.35(.1).75) ti("Wage Gap 1963-2008: Actual and Predictions") ytitle("Log Wage Gap")
saving("km-6308-gap-all.gph", replace);

*Predicted Demand Growth with Different Sigmas;
*Gap Measure;
*1963-87 Sigma, Trend Model;
gen sig6387 = 1/.731 ;
gen sig92t = 1/.6308806;
sum sig6387 sig92t;
gen dem6387 = sig6387*clphsg_all + eu_lnclg;
gen dem92t = sig92t*clphsg_all + eu_lnclg;
gen dem2 = 2*clphsg_all + eu_lnclg;
gen dem1 = clphsg_all + eu_lnclg;
gen dem3 = 3*clphsg_all + eu_lnclg;

sort year;
*Normalize Demand to 0 in 1963;
gen ndem92t = dem92t - dem92t[1];
gen ndem1 = dem1 - dem1[1];
gen ndem2 = dem2 - dem2[1];
gen ndem3 = dem3 - dem3[1];
gen ndem6387 = dem6387 - dem6387[1];
label variable ndem1 "sigma = 1";
label variable ndem92t "sigma = 1.58";
label variable ndem2 "sigma = 2";
label variable ndem3 "sigma = 3";
list ndem92t ndem1 ndem2 ndem3 ndem6387;

* graph ndem92t ndem1 ndem2 ndem3 year, c(llll) ti("Implied Demand Growth, 1963-2003")
xlabel(1963(6)2008)
saving("dem6308.gph", replace);

scatter ndem92t ndem1 ndem2 ndem3 year, c(l l l l) msymbol (oh dh t x) xlabel(1963(5)2008) xline(1987 1992) 
legend(region(lstyle(none))) ti("Implied Log Demand Growth, 1963-2008") ytitle("Change in Demand Index Since 1963")
saving("km-implieddemand-6308.gph", replace);

*Relative Demand and Relative Supply Growth Rates for Different Periods;
*1963-71;
*8 Year Growth Rates;
gen dem8 = ndem92t - ndem92t[_n-8];
gen ndem8 = dem8/sig92t;
gen sup8 = eu_lnclg - eu_lnclg[_n-8];
gen nsup8 = sup8/sig92t;
gen dgapt92 = gapt92 - gapt92[_n-8];
gen dgap6387 = gap6387 - gap6387[_n-8];
gen dgapt = gapt - gapt[_n-8];
gen dgap = clphsg_all - clphsg_all[_n-8];
list year dgap ndem8 nsup8 dem8 sup8;
list year dgap dgapt92 dgap6387 dgapt;

*Decadal (10 Year Growth Rates);
gen dem10 = ndem92t - ndem92t[_n-10];
gen ndem10 = dem10/sig92t;
gen sup10 = eu_lnclg - eu_lnclg[_n-10];
gen nsup10 = sup10/sig92t;
gen dgapt92_10 = gapt92 - gapt92[_n-10];
gen dgap6387_10 = gap6387 - gap6387[_n-10];
gen dgapt_10 = gapt - gapt[_n-10];
gen dgap10 = clphsg_all - clphsg_all[_n-10];
list year dgap10 ndem10 nsup10 dem10 sup10;
list year dgap10 dgapt92_10 dgap6387_10 dgapt_10;


*Basic Katz-Murphy Regressions Other Sample Periods:
*1967-2008 -- Drop Supsect 1963-66 Observations;
reg clphsg_all t eu_lnclg if year>1966;
reg clphsg_all t t92 eu_lnclg if year>1966;
*1973-2008 MORG Sample Period;
reg clphsg_all t eu_lnclg if year>1972;
reg clphsg_all t t92 eu_lnclg if year>1972;
*1963-1991  Drop Period After Education Data Changes;
reg clphsg_all t eu_lnclg if year<1992  ;
*1967-1991;
reg clphsg_all t eu_lnclg if year>1966 & year<1992;

* Save plotting data for residual supply/demand plot, and plot;
keep year gapdt supdt;
replace gapdt=gapdt*100;
replace supdt=supdt*100;
label var gapdt "Change in College/High-School Relative Wage (%)";
label var supdt "Change in College/High-School Relative Supply (%)";
compress;
save detrended-p-q-1963-2008, replace;

* Scatter plot;
scatter gapdt supdt, mlabel(year) xline(0) yline(0) 
        ti("Changes in College/High-School Relative Supply and Relative Wages") subtitle("1963 - 2008")
        xscale(reverse) xlabel(-15(5)15, format(%9.0f)) ylabel(-9(3)9, format(%9.0f)) saving(scatter-supply-wages-1963-2008, replace);

* Line graph;        
label var gapdt "Change Relative Wage (%)";
label var supdt "Change Relative Supply (%)";
twoway (connected gapdt year, yaxis(1) xlabel(1963(5)2008) title("Changes in College/High-School Relative Supply and Relative Wages", size(med)) saving(line-supply-wages-1963-2008.gph, replace)) 
       (connected supdt year, yaxis(2) yscale(reverse)) ; 

replace gapdt=gapdt/100;
replace supdt=supdt/100;
*/
       
label var gapdt "Log Change Relative Wage";
label var supdt "Log Change Relative Supply";

* Fig 20: Detrended changes in college/high-school relative supply and wages;
twoway (connected gapdt year, msymbol (th sh) yaxis(1) xlabel(2004(2)2020, labsize(small)) ylabel(-0.12(0.03)0.06, axis(1)) legend( pos(5) ring(0) region(lstyle(outline))) title("Detrended Changes in College/High-School Relative Supply and Relative Wages", size(med)) saving(fig20-line-supply-wages-logs-2004-2020.gph, replace)) 
       (connected supdt year, yaxis(2) ylabel(-0.15(0.05)0.15, axis(2))) ;     
	   
	   graph export "`figdir'/4.jpg", replace;
	   graph export "`figdir'/4.eps", replace;
   	  

* College/high-school relative supply series -- with title: Experience 0-9 years/20-29 years;

* use /proj/hole-vol4/march/series/effunits-exp-byexp-6308, clear;
use effunits-exp-byexp-0420, clear;

keep if expcat==1 | expcat==3;
keep euexp_lnclg_m euexp_lnclg_f euexp_lnclg year expcat;
reshape wide euexp_lnclg_m euexp_lnclg_f euexp_lnclg, i(year) j(expcat) ;

/* VARIATION NOT USED, COMMENTED OUT 
scatter euexp_lnclg1 euexp_lnclg3 year, c(l l l) msymbol (O) xlabel(1964(3)2009, labsize(small)) xline(1982) 
legend(label(1 "0-9 Yrs Experience") label(2 "20-29 Yrs Experience") region(lstyle(none))) ytitle("Log Relative Supply Index") xtitle("Year") ti("College/High-School Log Relative Supply, 1963-2008") saving("relative-supply-index-byexp.gph",replace);
*/

* Fig 3a: College/high-school relative supply series -- with title: Experience 0-9 years;
scatter euexp_lnclg_m1 euexp_lnclg_f1 year, c(l l l l) lcolor(navy maroon) mcolor(navy maroon) msymbol (O) xlabel(2004(2)2020, labsize(small)) xline(2014) 
ylabel(-2(.25).25) legend(label(1 "Male 0-5 Yrs Experience") label(2 "Female 0-5 Yrs Experience")
pos(4) ring(0)
region(lstyle(outline))) ytitle("Log Relative Supply Index") xtitle("Year") ti("College/High-School Log Relative Supply, 2004-2020") saving("fig3a-relative-supply-index-expcat1-bygender.gph",replace);

graph export "`figdir'/5.jpg", replace;
graph export "`figdir'/5.eps", replace;

* Fig 3b: College/high-school relative supply series -- with title: Experience 20-29 years;
scatter euexp_lnclg_m3 euexp_lnclg_f3 year, c(l l l l) lcolor(navy maroon) mcolor(navy maroon) msymbol (O)  xlabel(2004(2)2020, labsize(small)) xline(2014) 
ylabel(-1.4(.25)1.35) legend(label(1 "Male 11-15 Yrs Experience") label(2 "Female 11-15 Yrs Experience") pos(4) ring(0) region(lstyle(outline)))  ytitle("Log Relative Supply Index") xtitle("Year") ti("College/High-School Log Relative Supply, 2004-2020") saving("fig3b-relative-supply-index-expcat3-bygender.gph",replace);

graph export "`figdir'/6.jpg", replace;
graph export "`figdir'/6.eps", replace;



/* College/high-school relative wage series -- with title: Experience 0-9 years/20-29 years;*/

/* use /proj/hole-vol4/march/series/clghsgwg-march-regseries-exp.dta,clear;*/
use clghsgwg-march-regseries-exp.dta,clear;
keep if expcat==1 | expcat==3;

keep clphsg_exp clphsg_exp_m clphsg_exp_f year expcat;
reshape wide clphsg_exp clphsg_exp_m clphsg_exp_f, i(year) j(expcat) ;

/* VARIATION NOT USED, COMMENTED OUT 
scatter clphsg_exp1 clphsg_exp3 year, c(l l l) msymbol (O) xlabel(1964(3)2009, labsize(small)) xline(1982) 
legend(label(1 "0-9 Yrs Experience") label(2 "10-19 Yrs Experience") region(lstyle(none))) ytitle("Log Wage Ratio") xtitle("Year") ti("Log College/High-School Weekly Wage Ratio, 1963-2008") saving("clp-hsg-gap-byexp-6308.gph",replace);
*/

* Fig 21a: log college/high-school weekly wage ratio 0-9 yrs experience;
scatter clphsg_exp_m1 clphsg_exp_f1 year, c(l l l l) lcolor(navy maroon) mcolor(navy maroon) msymbol (O)  xlabel(2004(2)2020, labsize(small)) xline(2014) 
 legend(label(1 "Male 0-9 Yrs Experience")  label(2 "Female 0-9 Yrs Experience")
 
 pos(4) ring(0) region(lstyle(outline)))
 
 ytitle("Log Wage Ratio") xtitle("Year") ti("Log College/High-School Weekly Wage Ratio, 2004-2020") saving("fig21a-clp-hsg-gap-expcat1-bygender-6308.gph",replace);
 
graph export "`figdir'/7.jpg", replace;
graph export "`figdir'/7.eps", replace;

* Fig 21b: log college/high-school weekly wage ratio 20-29 yrs experience;
scatter clphsg_exp_m3 clphsg_exp_f3 year, c(l l l l) lcolor(navy maroon) mcolor(navy maroon) msymbol (O)  xlabel(2004(2)2020, labsize(small)) xline(2014) 
 legend(label(1 "Male 20-29 Yrs Experience")  label(2 "Female 20-29 Yrs Experience") 
 
  pos(4) ring(0) region(lstyle(outline)))  
 
 ytitle("Log Wage Ratio") xtitle("Year") ti("Log College/High-School Weekly Wage Ratio, 2004-2020") saving("fig21b-clp-hsg-gap-expcat3-bygender-6308.gph",replace);
 
graph export "`figdir'/8.jpg", replace; 
graph export "`figdir'/8.eps", replace;
exit;
