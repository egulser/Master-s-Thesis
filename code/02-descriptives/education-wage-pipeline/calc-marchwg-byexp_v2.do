

	clear
	local workdir "/Users/evrengulser/Desktop/TUIKDATA/raw/LFS"
	cd `workdir'/cleaned

	local x 5
	local y 4
	local z 3
	local p 2
	
	* set trace on
	
	
	* Loop over each gender
	foreach i in m f mf {
		
			local x 5
			local y 4
			local z 3
			local p 2

		*********************************************************
		*  Calculate weighted wage series
		*********************************************************
		
		use pred-wg-0420, clear
		
		* Gender exclusions
		if "`i'"=="m" keep if female==0
		if "`i'"=="f" keep if female==1
 
		* Overall high school   <-- in source code
		* Overall primary school
		
		egen v1=sum(rplnwkw*avlswt*(edcat5==`z' | edcat5==`y')), by(year)
		egen v2=sum(avlswt*(edcat5==`z' | edcat5==`y')), by(year)
		gen hsgwg=v1/v2
		drop v1 v2
			
		* Overall college-plus  <-- in source code
		* Overall high school ( high school - vocational high school)
		
		egen v1=sum(rplnwkw*avlswt*(edcat5==`x')), by(year)
		egen v2=sum(avlswt*(edcat5==`x')), by(year)
		gen clpwg=v1/v2
		drop v1 v2
		
		* Overall just college

		egen v1=sum(rplnwkw*avlswt*(edcat5==`p')), by(year)
		egen v2=sum(avlswt*(edcat5==`p')), by(year)
		gen clgwg=v1/v2
		drop v1 v2		
		
		
		* By experience high school  <-- in source code
		* By experience primary school
		
		egen v1=sum(rplnwkw*avlswt*(edcat5==`z' | edcat5==`y')), by(year expcat)
		egen v2=sum(rplnwkw*avlswt*(edcat5==`z' | edcat5==`y')), by(year expcat)
		gen exphsgwg=v1/v2
		drop v1 v2		
		
		* By experience college-plus <-- in source code
		* Overall high school ( high school - vocational high school)
		
		egen v1=sum(rplnwkw*avlswt*(edcat5==`x')), by(year expcat)
		egen v2=sum(avlswt*(edcat5==`x')), by(year expcat)
		gen expclpwg=v1/v2
		drop v1 v2		
		
		* By experience just college
		
		egen v1=sum(rplnwkw*avlswt*(edcat5==`p')), by(year expcat)
		egen v2=sum(avlswt*(edcat5==`p')), by(year expcat)
		gen expclgwg=v1/v2
		drop v1 v2				
		
		gen  clphsg_all = clpwg - hsgwg
		gen  clghsg_all = clgwg - hsgwg
		
		gen  clphsg_exp = expclpwg - exphsgwg
		gen  clghsg_exp = expclgwg - exphsgwg
		
		label var clphsg_all "COLLEGE-PLUS/HSG all"
		label var clghsg_all "COLLEGE-GRAD/HSG all"

		label var clphsg_exp "COLLEGE-PLUS/HSG by experience"
		label var clghsg_exp "COLLEGE-GRAD/HSG by experience"
		
		*** Organize/save
		bysort year expcat: keep if _n==1
		keep year expcat clphsg_* clghsg_*
		sort year expcat
		
		desc
		list year clp*
		list year clg*

		if "`i'"!="mf" {
			rename clphsg_all clphsg_all_`i'
			rename clghsg_all clghsg_all_`i'
			rename clphsg_exp clphsg_exp_`i'
			rename clghsg_exp clghsg_exp_`i'
			save ../tmp/clghsgwg-march-regseries-exp-`i',replace
		}

		if "`i'"=="mf" {
			merge year expcat using ../tmp/clghsgwg-march-regseries-exp-m
			assert _merge==3
			drop _merge
			sort year expcat
			merge year expcat using ../tmp/clghsgwg-march-regseries-exp-f
			assert _merge==3
			drop _merge
			sort year expcat
			label data "March CLG/HSG wage series overall and by experience and gender using Handbook approach, average March wts 1963-2013"

		save ../cleaned/clghsgwg-march-regseries-exp,replace
		rm ../tmp/clghsgwg-march-regseries-exp-m.dta
		rm ../tmp/clghsgwg-march-regseries-exp-f.dta

		}
	}





