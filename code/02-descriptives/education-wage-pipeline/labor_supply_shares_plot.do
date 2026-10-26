********************************************************************************
* This file calculates the share of hours worked by different subgroups
* (education, sex) for each year from 1963-2017. It creates figure 2 in the text.
*
* Input files: marchcells6318.dta
* Output files: educ_hour_shares_`sex'_1963.pdf
*
* Requires ado package
* package name:  grc1leg2.pkg
*         from:  http://digital.cgdev.org/doc/stata/MO/Misc/
********************************************************************************

clear all


local workdir  	/Users/evrengulser/Desktop/TUIKDATA
local figdir 	/Users/evrengulser/Desktop/TUIKDATA/figdir
local gphdir  	`workdir'/workdir/gph
local data  	`workdir'/raw/LFS/cleaned

use `data'/lfscells0420, clear
keep year female edcat5 q_lshrsweight
ren q_lshrsweight lswt

local educ1 Below Primary School
local educ2	Primary School
local educ3	High School
local educ4	Vocational High School
local educ5	College

local firstyear 2004
local lastyear 	2020

* Labor supply weight variable: lswt

* Sex dummies
gen male = (1-female)

* Total labor supply
egen total_lswt=sum(lswt), by(year)

* Total labor supply by sex
egen male_lswt=sum(lswt*(female==0)), by(year)
egen female_lswt=sum(lswt*(female==1)), by(year)

* Share of total labor supply by sex
gen sh_male_lswt=male_lswt/total_lswt
gen sh_female_lswt=female_lswt/total_lswt

* Share of total labor supply by education group and sex x education group
foreach ed of numlist 1/5{

  egen ed_`ed'_lswt=sum(lswt*(edcat5==`ed')), by(year)
  gen sh_lswt_ed_`ed'= ed_`ed'_lswt/total_lswt

  foreach sx in male female{
    egen `sx'_`ed'_lswt=sum(lswt*(edcat5==`ed')*(`sx'==1)), by(year)
    gen sh_lswt_`sx'_`ed'=`sx'_`ed'_lswt/`sx'_lswt
  }

}

* Overall Plot
* The gph_`ed' variables contain the the share of labor supply for each education
* category. Here we add them to create the area plot.
gen gph_1=sh_lswt_ed_1
foreach ed of numlist 2/5{
  local prev_ed = `ed'-1
  gen gph_`ed'=sh_lswt_ed_`ed'+gph_`prev_ed'
}

twoway area gph_5 gph_4 gph_3 gph_2 gph_1 year, ///
 color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") ///
 xtitle("") xlabel(`firstyear'(4)`lastyear', labsize(small)) ///
 title("Share of Hours Worked in the TR Economy") ///
 subtitle("by Education Group, `firstyear'-`lastyear'") legend(rows(2) ///
 label(5 `educ1') label(4 `educ2') label(3 `educ3') ///
 label(2 `educ4') label(1 `educ5') ///
 size(medium)) legend(pos(6)) legend(region(lstyle(none))) ///
 graphregion(color(white)) plotregion(color(white)) ///
 saving("`gphdir'/Fig_2c_educ_hour_shares_all_`firstyear'-`lastyear'.gph",replace)



graph export "`figdir'/Fig_2ceduc_hour_shares_all_`firstyear'-`lastyear'.eps", replace




* Males
gen gph_male_1=sh_lswt_male_1
foreach ed of numlist 2/5{
  local prev_ed = `ed'-1
  gen gph_male_`ed'=sh_lswt_male_`ed'+gph_male_`prev_ed'
}

twoway area gph_male_5 gph_male_4 gph_male_3 gph_male_2 gph_male_1 year, ///
color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") xtitle("") ///
xlabel(`firstyear'(4)`lastyear', labsize(small)) title("Share of Hours Worked by Males in the U.S. Economy") ///
 subtitle("by Education Group, 1963-2017") legend(rows(2) ///
 label(5 `educ1') label(4 `educ2') label(3 `educ3') ///
 label(2 `educ4') label(1 `educ5') ///
 size(medium)) legend(pos(6)) ///
 legend(region(lstyle(none))) ///
 graphregion(color(white)) plotregion(color(white)) ///
 saving("`gphdir'/Fig_2a_educ_hour_shares_m_`firstyear'-`lastyear'.gph",replace)

graph export "`figdir'/Fig_2a_educ_hour_shares_m_`firstyear'-`lastyear'.eps", replace


* Females
gen gph_female_1=sh_lswt_female_1
foreach ed of numlist 2/5{
  local prev_ed = `ed'-1
  gen gph_female_`ed'=sh_lswt_female_`ed'+gph_female_`prev_ed'
}

twoway area gph_female_5 gph_female_4 gph_female_3 gph_female_2 gph_female_1 year, ///
color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") xtitle("") ///
xlabel(`firstyear'(4)`lastyear', labsize(small)) ///
title("Share of Hours Worked by Women in the U.S. Economy") ///
subtitle("by Education Group, 1963-2017") legend(rows(2) ///
 label(5 `educ1') label(4 `educ2') label(3 `educ3') ///
 label(2 `educ4') label(1 `educ5') ///
 size(medium)) legend(pos(6)) ///
 legend(region(lstyle(none))) ///
graphregion(color(white)) plotregion(color(white)) ///
saving("`gphdir'/Fig_2b_educ_hour_shares_f_`firstyear'-`lastyear'.gph",replace)

graph export "`figdir'/Fig_2b_educ_hour_shares_f_`firstyear'-`lastyear'.eps", replace


*********************************
* Side by side, males and females
*********************************

* Males
twoway area gph_male_5 gph_male_4 gph_male_3 gph_male_2 gph_male_1 year, ///
color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") xtitle("") ///
xlabel(`firstyear'(4)`lastyear', labsize(small)) title("Men", size(large)) legend(rows(2) ///
label(5 `educ1') label(4 `educ2') label(3 `educ3') ///
label(2 `educ4') label(1 `educ5') ///
 size(medium)) legend(pos(6)) ///
 legend(region(lstyle(none))) ///
graphregion(color(white)) plotregion(color(white)) mcolor(%30) name(g1, replace)



* Females
twoway area gph_female_5 gph_female_4 gph_female_3 gph_female_2 gph_female_1 year, ///
color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") xtitle("") ///
xlabel(`firstyear'(4)`lastyear', labsize(small)) title("Women", size(large)) legend(rows(2) /// 
label(5 `educ1') label(4 `educ2') label(3 `educ3') ///
label(2 `educ4') label(1 `educ5') ///
 size(medium)) legend(pos(6)) ///
 legend(region(lstyle(none))) ///
 graphregion(color(white)) plotregion(color(white)) ///
mcolor(%30) name(g2, replace)

* Combined plot of non-college men and women

grc1leg2 g1 g2, title("Share of Hours Worked by Education and Gender, `firstyear'-`lastyear'", ///
size(large)) subtitle("Adults Ages 16-64", size(large))  ysize(4.5) xsize(8) ///
ring(2) pos(6) legendfrom(g1) graphregion(color(white)) plotregion(color(white)) ///
saving("`gphdir'/Fig_2_educ_hour_shares_mf_`firstyear'-`lastyear'.gph", replace)

graph export "`figdir'/Fig_2_educ_hour_shares_mf_`firstyear'-`lastyear'.eps", replace
