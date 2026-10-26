
clear all




local workdir 	/Users/evrengulser/Desktop/TUIKDATA/workdir/lfs
local figdir 	/Users/evrengulser/Desktop/TUIKDATA/figdir/lfs
local gphdir    /Users/evrengulser/Desktop/TUIKDATA/workdir/gph

local edu1 "Below Primary School"
local edu2 "Primary School Graduate"
local edu3 "High School Graduate"
local edu4 "Voch High School Graduate"
local edu5 "College Graduate (2-6 years)"

local firstyear 2004
local lastyear  2020 

cd `workdir'


* use /Users/evrengulser/Desktop/TUIKDATA/raw/LFS/tmp/lfscells0420, clear
use /Users/evrengulser/Desktop/TUIKDATA/raw/LFS/tmp/lfs-lswts-exp.dta, clear

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
 color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") xtitle("") ///
 xlabel(2004(4)2020, labsize(small))  title("Share of Hours Worked in the TR Economy") ///
 subtitle("by Education Group, `firstyear'-`lastyear'") legend(rows(2) ///
 label(5 `edu1') label(4 `edu2') label(3 `edu3') label(2 `edu4') label(1 `edu5') ///
 size(small)) legend(style(zyx2)) legend(region(lstyle(none))) ///
 graphregion(color(white)) plotregion(color(white)) ///
 saving("`gphdir'/Fig_2c_educ_hour_shares_all_`firstyear'-`lastyear'.gph",replace)

graph export "`figdir'/Fig_2ceduc_hour_shares_all_`firstyear'-`lastyear'.pdf", replace

* Males
gen gph_male_1=sh_lswt_male_1
foreach ed of numlist 2/5{
  local prev_ed = `ed'-1
  gen gph_male_`ed'=sh_lswt_male_`ed'+gph_male_`prev_ed'
}

twoway area gph_male_5 gph_male_4 gph_male_3 gph_male_2 gph_male_1 year, ///
color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") xtitle("") ///
xlabel(2004(4)2020, labsize(small)) title("Share of Hours Worked by Males in the TR Economy") ///
 subtitle("by Education Group, `firstyear'-`lastyear'") legend(rows(2) /// 
 label(5 `edu1') label(4 `edu2') label(3 `edu3') label(2 `edu4') label(1 `edu5') /// 
 size(small)) legend(style(zyx2)) legend(region(lstyle(none))) ///
 graphregion(color(white)) plotregion(color(white)) ///
 saving("`gphdir'/Fig_2a_educ_hour_shares_m_`firstyear'-`lastyear'.gph",replace)

graph export "`figdir'/Fig_2a_educ_hour_shares_m_`firstyear'-`lastyear'.pdf", replace

* Females
gen gph_female_1=sh_lswt_female_1
foreach ed of numlist 2/5{
  local prev_ed = `ed'-1
  gen gph_female_`ed'=sh_lswt_female_`ed'+gph_female_`prev_ed'
}

twoway area gph_female_5 gph_female_4 gph_female_3 gph_female_2 gph_female_1 year, ///
color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") xtitle("") ///
xlabel(2004(4)2020, labsize(small)) title("Share of Hours Worked by Women in the TR Economy") ///
 subtitle("by Education Group, `firstyear'-`lastyear'") legend(rows(2) ///
 label(5 `edu1') label(4 `edu2') label(3 `edu3') label(2 `edu4') label(1 `edu5') /// 
 size(small)) legend(style(zyx2)) legend(region(lstyle(none))) ///
 graphregion(color(white)) plotregion(color(white)) ///
 saving("`gphdir'/Fig_2b_educ_hour_shares_f_`firstyear'-`lastyear'.gph",replace)
graph export "`figdir'/Fig_2b_educ_hour_shares_f_`firstyear'-`lastyear'.pdf", replace

*********************************
* Side by side, males and females
*********************************

* Males
twoway area gph_male_5 gph_male_4 gph_male_3 gph_male_2 gph_male_1 year, 		///
color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") xtitle("") ///
xlabel(2004(4)2020, labsize(small)) title("Men", size(large)) legend(rows(2)	///
label(5 `edu1') label(4 `edu2') label(3 `edu3') label(2 `edu4') label(1 `edu5') /// 
size(small)) legend(style(zyx2)) legend(region(lstyle(none))) ///
graphregion(color(white)) plotregion(color(white)) mcolor(%30) name(g1, replace)


* Females
twoway area gph_female_5 gph_female_4 gph_female_3 gph_female_2 gph_female_1 year, ///
color("189 0 38" "240 59 32" "253 141 60" "254 178 76" "254 217 118") xtitle("")  ///
xlabel(2004(4)2020, labsize(small)) title("Women", size(large)) legend(rows(2) ///
 label(5 `edu1') label(4 `edu2') label(3 `edu3') label(2 `edu4') label(1 `edu5') /// 
size(small)) legend(style(zyx2)) ///
legend(region(lstyle(none))) graphregion(color(white)) plotregion(color(white)) ///
mcolor(%30) name(g2, replace)

* Combined plot of non-college men and women

grc1leg2 g1 g2, title("Share of Hours Worked by Education and Gender, 1963 - 2017", ///
size(large)) subtitle("Adults Ages 16-64", size(large))  ysize(4.5) xsize(8) ///
ring(2) pos(6) legendfrom(g1) graphregion(color(white)) plotregion(color(white)) ///
saving("`gphdir'/Fig_2_educ_hour_shares_mf_2004-2020.gph", replace)

graph export "`figdir'/Fig_2_educ_hour_shares_mf_1-2004-2017.pdf", replace
