
* 2014-2021
	
	global project "/Users/evrengulser/Desktop/TUIKDATA"
	
	local data   "$project/raw/LFS/raw_v1"
	local out 	 "$project/raw/LFS/raw_v2"
	
	
	cd "`data'"
	
	
		forvalues y = 2014/2021 {
			
		use `y'lfs, clear
		
		gen unitno 				= birimno
		gen wage				= gelir_gecenay_k  // monthly wage
		gen uweeklywh 			= esas_hafsaat_genel 
		gen educ 				= okul_biten_k 
		gen occupation08 		= isco08_esas_k 
		gen industry 			= nace2_esas_k 
		gen age 				= yas	
		gen age_group 			= yas_k 
		gen year				= referans_yil 
		gen weight				= agirlik_katsayisi 
		gen employment_status 	= isteki_durum_k 
		gen employment_type 	= calisma_sekli
		gen literacy 			= okur_yazar
		gen employment 			= calisma // referans haftasi için
		gen permanency 			= is_sureklilik 

		gen tenure_baseyear 	= is_baslama_yil  // refereans yilina göre
		
		gen female 				= 0		
		replace female 			= 1 if cinsiyet == 2
		save "`out'/`y'", replace
	}


	* 2000 ve 2001 için income verisi yokus
	
	forvalues y = 2002/2003 {
		use `y'lfs, clear
		
		*permanency değişkeni yok
		quietly {
		
			destring, dpcomma replace
			
			gen unitno  			= formno //
			gen wage 				= s32c //
			gen uweeklywh 			= s27a //
			gen educ 				= s9 //
			gen occupation68 		= s22kod // ISCO 68 
			gen industry 			= s16kod // ISIC, Rev 3 	
			gen year 				= `y'	//
			gen employment_status 	= s23 //
			gen employment_type 	= s46 
			gen literacy			= s8 //
			gen employment 			= s12 // 
			gen tenure_baseyear 	= s32yil //  	
			gen female 				= 0		//
			replace female 			= 1 if s3 == 2 //
			save "`out'/`y'", replace
		}	
	}	
	

	
	local y = 2004
	use `y'lfs, clear 	
	gen unitno  			= formno
	gen wage 				= s69 
	gen uweeklywh 			= s54a
	gen educ 				= s10
	gen occupation88 		= s33kod 
	gen industry 			= s28kodr2 	
	gen age 				= s6
	gen age_group			= s6_grup
	gen year 				= `y'	
	gen weight 				= faktor 
	gen employment_status 	= s34 
	gen employment_type 	= s40 
	gen literacy			= s9
	gen employment 			= s21 	// referans haftasi için	
	gen permanency 			= s42	
	gen tenure_baseyear 	= s38a  // refereans yilina göre			
	gen female 				= 0		
	replace female 			= 1 if s3 == 2
	save "`out'/`y'", replace

	*2005-2006-2007-2008

	forvalues y = 2005/2008 {
		use `y'lfs, clear
		
		gen unitno  			= formno
		gen wage 				= s78 
		gen uweeklywh 			= s61a
		gen educ 				= s14 //**
		gen occupation88 		= s38kod 
		gen industry 			= s33kodr2 	
		gen age 				= s6
		gen age_group			= s6_grup
		gen year 				= `y'	
		gen weight 				= faktor 
		gen employment_status 	= s39 
		gen employment_type 	= s46 
		gen literacy			= s13
		gen employment 			= s26 // referans haftasi için	
		gen permanency 			= s49
		gen tenure_baseyear 	= s44a  // refereans yilina göre		
		gen female 				= 0		
		replace female 			= 1 if s3 == 2
		save "`out'/`y'", replace
	}
	

	*2013 = 2011 = 2010
	*2009'da s33kodr2 industry
	
	local y = 2009
	use `y'lfs, clear 	
	gen unitno  			= formno
	gen wage 				= s69 
	gen uweeklywh 			= s55a
	gen educ 				= s13
	gen occupation08 		= s38kod 
	gen industry 			= s33kodr2 	
	gen age 				= s6
	gen age_group			= s6_grup
	gen year 				= `y'	
	gen weight 				= faktor 
	gen employment_status 	= s39 
	gen employment_type 	= s45 
	gen literacy			= s14
	gen employment 			= s26 	// referans haftasi için	
	gen permanency 			= s48	
	gen tenure_baseyear 	= s43a  // refereans yilina göre			
	gen female 				= 0		
	replace female 			= 1 if s3 == 2
	save "`out'/`y'", replace
	
	local y = 2010
	use `y'lfs, clear 	
	gen unitno  			= formno
	gen wage 				= s69 
	gen uweeklywh 			= s55a
	gen educ 				= s13
	gen occupation08 		= s38kod 
	gen industry 			= s33kod 	
	gen age 				= s6
	gen age_group			= s6_grup
	gen year 				= `y'	
	gen weight 				= faktor 
	gen employment_status 	= s39 
	gen employment_type 	= s45 
	gen literacy			= s14
	gen employment 			= s26 	// referans haftasi için	
	gen permanency 			= s48	
	gen tenure_baseyear 	= s43a  // refereans yilina göre			
	gen female 				= 0		
	replace female 			= 1 if s3 == 2
	save "`out'/`y'", replace
	
	local y = 2011
	use `y'lfs, clear 	
	gen unitno  			= formno
	gen wage 				= s69 
	gen uweeklywh 			= s55a
	gen educ 				= s13
	gen occupation08 		= s38kod 
	gen industry 			= s33kod 	
	gen age 				= s6
	gen age_group			= s6_grup
	gen year 				= `y'	
	gen weight 				= faktor 
	gen employment_status 	= s39 
	gen employment_type 	= s45 
	gen literacy			= s14
	gen employment 			= s26 	// referans haftasi için	
	gen permanency 			= s48	
	gen tenure_baseyear 	= s43a  // refereans yilina göre			
	gen female 				= 0		
	replace female 			= 1 if s3 == 2
	save "`out'/`y'", replace
				
	local y = 2012
	use `y'lfs, clear			
	gen unitno  			= formno
	gen wage 				= s69 
	gen uweeklywh 			= s55a
	gen educ 				= s13
	gen occupation08 		= s38kod08
	gen occupation88		= s38kod88	
	gen industry 			= s33kod 	
	gen age 				= s6
	gen age_group			= s6_grup
	gen year 				= `y'	
	gen weight 				= faktor 
	gen employment_status 	= s39 
	gen employment_type 	= s45 
	gen literacy			= s14
	gen employment 			= s26 // referans haftasi için	
	gen permanency 			= s48			
	gen tenure_baseyear 	= s43a  // refereans yilina göre		
	gen female 				= 0		
	replace female 			= 1 if s3 == 2
	save "`out'/`y'", replace
	
	local y = 2013
	use `y'lfs, clear 	
	gen unitno  			= formno
	gen wage 				= s69 
	gen uweeklywh 			= s55a
	gen educ 				= s13
	gen occupation08 		= s38kod 
	gen industry 			= s33kod 	
	gen age 				= s6
	gen age_group			= s6_grup
	gen year 				= `y'	
	gen weight 				= faktor 
	gen employment_status 	= s39 
	gen employment_type 	= s45 
	gen literacy			= s14
	gen employment 			= s26 	// referans haftasi için	
	gen permanency 			= s48	
	gen tenure_baseyear 	= s43a  // refereans yilina göre			
	gen female 				= 0		
	replace female 			= 1 if s3 == 2
	save "`out'/`y'", replace
	
	cd "`out'"
	
	forvalues y = 2004/2021 {
			use `y', clear
			keep unitno wage uweeklywh educ	occupation* industry age_group age year weight employment* literacy permanency tenure_baseyear female 
			save "`out'/`y'", replace
		}
		
	forvalues y = 2002/2003 {	
			use `y', clear
			keep unitno wage uweeklywh educ	occupation* industry age_group age year weight employment* literacy  tenure_baseyear female 
			save "`out'/`y'", replace
		
	}

	
