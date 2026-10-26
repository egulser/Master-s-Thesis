

	gen gdp = 0
									
	capture replace gdp =	107.009	/	23.3251		if year == 2000
	capture replace gdp =	107.009	/	35.6827		if year == 2001
	capture replace gdp =	107.009	/	49.0904		if year == 2002
	capture replace gdp =	107.009	/	60.5232		if year == 2003
	capture replace gdp =	107.009	/	68.0447		if year == 2004
	capture replace gdp =	107.009	/	72.866		if year == 2005
	capture replace gdp =	107.009	/	79.698		if year == 2006
	capture replace gdp =	107.009	/	84.6391		if year == 2007
	capture replace gdp =	107.009	/	94.8349		if year == 2008
	capture replace gdp =	107.009	/	100			if year == 2009
	capture replace gdp =	107.009	/	107.009		if year == 2010
	capture replace gdp =	107.009	/	115.785		if year == 2011
	capture replace gdp =	107.009	/	124.379		if year == 2012
	capture replace gdp =	107.009	/	132.19		if year == 2013
	capture replace gdp =	107.009	/	141.959		if year == 2014
	capture replace gdp =	107.009	/	153.095		if year == 2015
	capture replace gdp =	107.009	/	165.543		if year == 2016
	capture replace gdp =	107.009	/	183.723		if year == 2017
	capture replace gdp =	107.009	/	213.993		if year == 2018
	capture replace gdp =	107.009	/	243.565		if year == 2019
	capture replace gdp =	107.009	/	279.742		if year == 2020
	capture replace gdp =	107.009	/	360.729		if year == 2021
	
	label variable gdp "GDP Deflator, 2010 ₺"
	
	assert gdp!=0
	




