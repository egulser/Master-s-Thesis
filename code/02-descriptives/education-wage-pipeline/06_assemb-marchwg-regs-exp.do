

	clear all
	
	local workdir "/Users/evrengulser/Desktop/TUIKDATA/raw/LFS/precollapse"	
	cd `workdir'
	
	local gdp2000 =	107.009	/	23.3251		
	local gdp2001 =	107.009	/	35.6827		
	local gdp2002 =	107.009	/	49.0904		
	local gdp2003 =	107.009	/	60.5232		
	local gdp2004 =	107.009	/	68.0447		
	local gdp2005 =	107.009	/	72.866		
	local gdp2006 =	107.009	/	79.698		
	local gdp2007 =	107.009	/	84.6391		
	local gdp2008 =	107.009	/	94.8349		
	local gdp2009 =	107.009	/	100			
	local gdp2010 =	107.009	/	107.009		
	local gdp2011 =	107.009	/	115.785		
	local gdp2012 =	107.009	/	124.379		
	local gdp2013 =	107.009	/	132.19		
	local gdp2014 =	107.009	/	141.959		
	local gdp2015 =	107.009	/	153.095		
	local gdp2016 =	107.009	/	165.543		
	local gdp2017 =	107.009	/	183.723		
	local gdp2018 =	107.009	/	213.993		
	local gdp2019 =	107.009	/	243.565		
	local gdp2020 =	107.009	/	279.742		
	local gdp2021 =	107.009	/	360.729		
		

	use ../tmp/predwg-2004, clear
	
	forvalues y = 2005/2020 {
	append using ../tmp/predwg-`y'
	}
	
	* local gdpdir "/Users/evrengulser/Desktop/TUIKDATA/dofiles

	* Rename and label vars
	tab edcat5
	recode expcat 2=1 7=2 13=3 17=4 30=5
	
	gen gdp = 0
	forval y = 2004/2020 {
		replace gdp = `gdp`y'' if year == `y'
	}
	
	* Add in March employment shares for 1963 - 2008
	sort year edcat5 expcat female
	merge year edcat5 expcat female using ../tmp/lfs-lswts-exp
	assert _merge==3
	drop _merge
	
	* Calculate fixed weights
	egen t1=sum(lswt),by(year)
	gen normlswt=lswt/t1
	egen avlswt=mean(normlswt),by(edcat5 female expcat)
	drop t1
	
	gen plnwkw = ln(pwinc)
	gen plnhrw = ln(phinc)
	
	label var lswt "Labor supply in cell"
	label var normlswt "Labor supply share in cell/year"
	label var avlswt "Average labor supply share in cell over 2004 - 2020"
	label var plnhrw "Pred ln hr wg"
	label var plnwkw "Pred ln wk wg"
	table year, stat(mean lswt) stat( sd lswt)
	table year, stat(mean normlswt) stat(sd normlswt) stat(mean avlswt) stat(sd avlswt)	
	
	gen rplnhrw = plnhrw + ln(gdp)
	gen rplnwkw = plnwkw + ln(gdp)
	label var rplnhrw "Real pred ln hr wg"
	label var rplnwkw "Real pred ln wk wg"
	
	label drop _all
	label define expcat 1 "5 years" 2 "15 years" 3 "25 years" 4 "35 years" 5 "45 years"
	label values expcat expcat
	label var expcat "Experience categories"
	tab expcat
	label var female "1=F, 0=M"
	label var edcat5 "Education cats (5)"
	
	aorder
	order year female edcat5 expcat rplnwkw rplnhrw plnwkw plnhrw gdp avlswt normlswt lswt
	summ
	desc
	
	label data "LFS pred wgs 2004-2020: By Year/gender/ed/experience"
	
	save ../tmp/pred-wg-0420,replace
	* save ../series/pred-marwg-6313,replace
	
	tab year [aw=avlswt], summ(plnwkw)
	tab year [aw=avlswt], summ(plnhrw)
	
	tab year [aw=avlswt], summ(rplnwkw)
	tab year [aw=avlswt], summ(rplnhrw)
	

