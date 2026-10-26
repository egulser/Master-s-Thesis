	
	clear all
	
	/*
	
	Efficiency units hesaplarken source kodlar iş gücünü hemen hemen eşit iki
	parçaya bölüyor.
	
	egen hr_clg = sum(q_lshrsweight*((edcat==4 | edcat==5) + 0.5*(edcat==3))),by(year)
	egen hr_hsg = sum(q_lshrsweight*((edcat==1 | edcat==2) + 0.5*(edcat==3))),by(year)
	
	Ben College graduate kategorisini sadece edcat5=5
	non-college kategorisini ise Edcat=4,3,2,1 olarak belirledim.
	
	(16.04.2023)	
	
	*/
	
	
	
	local 	workdir "/Users/evrengulser/Desktop/TUIKDATA/raw/LFS"	
	cd 		`workdir'/cleaned	
	use 	lfscells0420, clear
	drop 	_merge
	
	keep if exp>=0 & exp<=48
	
	gen 	expcat = 1
	replace expcat = 2 if exp>=6  & exp<=10
	replace expcat = 3 if exp>=11 & exp<=15
	replace expcat = 4 if exp>=16 & exp<=20
	replace expcat = 5 if exp>=21 & exp<=48 
	
	label var expcat "experience groups (0-5, 6-10, 11-15, 16-20, 21-48)"
	label define expcat 1 "0-5" 2 "6-10" 3 "11-15" 4 "16-20" 5 "21-48"
	label values expcat expcat

	* Calculate average relative wage by cell over time period
	* Efficiency units translation: Base is Primary School Grad Male with 10 years of potential experience in each year
	
	
	
	egen refwage3 	= max(rwinc*(female==0)*(edcat==3)*(exp==10)), by(year)
	egen refwage4 	= max(rwinc*(female==0)*(edcat==4)*(exp==10)), by(year)
	egen refwage 	= rowmean(refwage3 refwage4) // labor suplpy weight ile ağirliklandirilacak
	
		
	gen  relwage 	= rwinc/refwage
	tab  year, 		  summ(relwage)
	egen celleu		= mean(relwage), by(edcat5 female exp)
	tab  year, 		  summ(celleu)
	
	* Overall (not by experience group)
	
	egen tot_euwt 	= sum(celleu*q_lshrsweight),by(year)
	egen tot_euwt_m = sum(celleu*q_lshrsweight*(1-female)),by(year)
	egen tot_euwt_f = sum(celleu*q_lshrsweight*female),by(year)

	gen sh_euwt		= celleu*q_lshrsweight/tot_euwt
	gen sh_euwt_m	= celleu*q_lshrsweight/tot_euwt_m*(female==0)
	gen sh_euwt_f	= celleu*q_lshrsweight/tot_euwt_f*female

	table year, stat(mean sh_euwt) stat(mean sh_euwt_m) stat(mean sh_euwt_f)

	egen eu_shclg 	= sum(sh_euwt*			(edcat==5)), 				by(year)
	egen eu_shclg_m = sum(sh_euwt_m*		(female==0)	* (edcat==5)), 	by(year)
	egen eu_shclg_f = sum(sh_euwt_f*female*	(edcat==5)), 				by(year)
	
	gen eu_lnclg	= ln(eu_shclg	/(1-eu_shclg))
	gen eu_lnclg_m	= ln(eu_shclg_m	/(1-eu_shclg_m))
	gen eu_lnclg_f	= ln(eu_shclg_f	/(1-eu_shclg_f))
	drop tot_* sh_*

	table year, stat(mean eu_shclg)  stat(mean eu_shclg_m) stat(mean eu_shclg_f)
	table year, stat(mean eu_lnclg)  stat(mean eu_lnclg_m) stat(mean eu_lnclg_f)

	label var eu_shclg 		"Eff units CLP supply share: All"
	label var eu_shclg_m 	"Eff units CLP supply share: M"
	label var eu_shclg_f 	"Eff units CLP supply share: F"
	
	label var eu_lnclg 		"Eff units Ln CLG/NON-CLG supply: All"
	label var eu_lnclg_m 	"Eff units Ln CLG/NON-CLG supply: M"
	label var eu_lnclg_f 	"Eff units Ln CLG/NON-CLG supply: F"
	label var year 			"MORG year"

	* Also tabulate total hours by CLG and HSG equivalents
	* Chad Jones asked for this on 9/29/2004 - might as well keep the info
	* Added hours by experience group (D. Autor, 2/7/2014)
	
	egen hr_clg 		= sum(q_lshrsweight*			(edcat==5)),									by(year)
	egen hr_clg_m 		= sum(q_lshrsweight*(female==0)*(edcat==5)),									by(year)
	egen hr_clg_f 		= sum(q_lshrsweight*female*		(edcat==5)),									by(year)
		
	egen hr_hsg 		= sum(q_lshrsweight*			((edcat==1|edcat==2)|(edcat==3)|edcat==4)),	by(year)
	egen hr_hsg_m 		= sum(q_lshrsweight*(female==0)*((edcat==1|edcat==2)|(edcat==3)|edcat==4)),	by(year)
	egen hr_hsg_f 		= sum(q_lshrsweight*female*		((edcat==1|edcat==2)|(edcat==3)|edcat==4)),	by(year)
	
	egen hr_clg_exp 	= sum(q_lshrsweight*			 (edcat==5)),	by(year expcat)
	egen hr_clg_exp_m 	= sum(q_lshrsweight*(female==0)* (edcat==5)),	by(year expcat)
	egen hr_clg_exp_f 	= sum(q_lshrsweight*female*		 (edcat==5)),	by(year expcat)
	
	egen hr_hsg_exp 	= sum(q_lshrsweight*			((edcat==1|edcat==2)|(edcat==3)|edcat==4)),	by(year expcat)
	egen hr_hsg_exp_m 	= sum(q_lshrsweight*(female==0)*((edcat==1|edcat==2)|(edcat==3)|edcat==4)),	by(year expcat)
	egen hr_hsg_exp_f 	= sum(q_lshrsweight*female*		((edcat==1|edcat==2)|(edcat==3)|edcat==4)),	by(year expcat)
	
	table year, stat(mean hr_clg) stat(mean hr_clg_m) stat(mean hr_clg_f)
	table year, stat(mean hr_hsg) stat(mean hr_hsg_m) stat(mean hr_hsg_f)
	
	label var hr_clg 		"Hours labor supply CLP: All"
	label var hr_clg_m 		"Hours labor supply CLP: M"
	label var hr_clg_f 		"Hours labor supply CLP: F"
		
	label var hr_hsg 		"Hours labor supply HSG: All"
	label var hr_hsg_m 		"Hours labor supply HSG: M"
	label var hr_hsg_f 		"Hours labor supply HSG: F"
	
	label var hr_clg_exp 	"Hours labor supply CLP by exper: All"
	label var hr_clg_exp_m 	"Hours labor supply CLP by exper: M"
	label var hr_clg_exp_f 	"Hours labor supply CLP by exper: F"
	
	label var hr_hsg_exp 	"Hours labor supply HSG by exper: All"
	label var hr_hsg_exp_m 	"Hours labor supply HSG by exper: M"
	label var hr_hsg_exp_f 	"Hours labor supply HSG by exper: F"

	* By experience group
	egen tot_euwt 		= sum(celleu*q_lshrsweight),by(year expcat)
	egen tot_euwt_m 	= sum(celleu*q_lshrsweight*(1-female)),by(year expcat)
	egen tot_euwt_f 	= sum(celleu*q_lshrsweight*female),by(year expcat)
	
	gen sh_euwt			= celleu*q_lshrsweight/tot_euwt
	gen sh_euwt_m		= celleu*q_lshrsweight/tot_euwt_m*(female==0)
	gen sh_euwt_f		= celleu*q_lshrsweight/tot_euwt_f*female
	
	table year, stat(mean sh_euwt) stat(mean sh_euwt_m) stat(mean sh_euwt_f)
	
	egen euexp_shclg 	= sum(sh_euwt*					(edcat==5)),	by(year expcat)
	egen euexp_shclg_m 	= sum(sh_euwt_m*(female==0)*	(edcat==5)), by(year expcat)
	egen euexp_shclg_f 	= sum(sh_euwt_f*female*			(edcat==5)), by(year expcat)
	
	gen euexp_lnclg		= ln(euexp_shclg	/(1-euexp_shclg))
	gen euexp_lnclg_m	= ln(euexp_shclg_m	/(1-euexp_shclg_m))
	gen euexp_lnclg_f	= ln(euexp_shclg_f	/(1-euexp_shclg_f))
	
	table year, stat(mean euexp_shclg) stat(mean euexp_shclg_m) stat(mean euexp_shclg_f)
	table year, stat(mean euexp_lnclg) stat(mean euexp_lnclg_m) stat(mean euexp_lnclg_f)
	
	label var euexp_shclg "Eff by exper units CLP supply share: All"
	label var euexp_shclg_m "Eff by exper units CLP supply share: M"
	label var euexp_shclg_f "Eff by exper units CLP supply share: F"
	
	label var euexp_lnclg "Eff by exper units Ln CLG/NON-CLG supply: All"
	label var euexp_lnclg_m "Eff by exper units Ln CLG/NON-CLG supply: M"
	label var euexp_lnclg_f "Eff by exper units Ln CLG/NON-CLG supply: F"
	label var year "MORG year"
	
	
	keep year expcat euexp_lnclg* euexp_shclg* eu_lnclg* eu_shclg* hr_*
	quietly bysort year expcat: keep if _n==1
	sort year expcat
	save effunits-exp-byexp-0420,replace


