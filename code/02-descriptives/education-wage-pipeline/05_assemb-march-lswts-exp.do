

	clear
	local workdir "/Users/evrengulser/Desktop/TUIKDATA/raw/LFS/precollapse"	
	cd `workdir'
	
	use ../tmp/lfscells0420, clear
	keep q_lshrsweight exp edcat5 year female
	
	* Aggregate to experience categories: 5, 15, 25, 35, 45
	drop if exp > 48
	gen byte expcat=.
	replace expcat=1 if exp>= 0 & exp<= 5
	replace expcat=2 if exp>= 6 & exp<=10
	replace expcat=3 if exp>=11 & exp<=15
	replace expcat=4 if exp>=16 & exp<=20
	replace expcat=5 if exp>=21 & exp<=48
	tab exp, summ(expcat)
	
	egen lswt=sum(q_lshrsweight), by(expcat edcat5 female year)
	quietly bysort year female edcat5 expcat: keep if _n==1
	drop q_lshrsweight exp
	
	label var expcat "1: 0-9(5), 2:10-19(15), 3:20-29(25), 4:30-39(35) 5:40-48(45)"
	label define expcat 1 "5" 2 "15" 3 "25" 4 "35" 5 "45"
	label values expcat expcat 
	label var lswt "Summ of hours x weeks x weight" 
	sort year edcat5 expcat female 
	label data "March labor supply by grouped experience levels"
	save ../tmp/lfs-lswts-exp,replace
	desc


