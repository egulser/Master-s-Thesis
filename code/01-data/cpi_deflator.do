

	gen cpi = 0	
					
	capture replace cpi =	100		/	 20.59483	 if year == 2000
	capture replace cpi =	100		/    31.79845    if year == 2001
	capture replace cpi =	100		/    46.09634    if year == 2002
	capture replace cpi =	100		/    56.05428    if year == 2003
	capture replace cpi =	100		/    60.87397    if year == 2004
	capture replace cpi =	100		/    65.85295    if year == 2005
	capture replace cpi =	100		/    72.17302    if year == 2006
	capture replace cpi =	100		/    78.49262    if year == 2007
	capture replace cpi =	100		/    86.69049    if year == 2008
	capture replace cpi =	100		/    92.10949    if year == 2009
	capture replace cpi =	100		/    100		 if year == 2010
	capture replace cpi =	100		/    106.4719    if year == 2011
	capture replace cpi =	100		/    115.9389    if year == 2012
	capture replace cpi =	100		/    124.6263    if year == 2013
	capture replace cpi =	100		/    135.6614    if year == 2014
	capture replace cpi =	100		/    146.0678    if year == 2015
	capture replace cpi =	100		/    157.4248    if year == 2016
	capture replace cpi =	100		/    174.9687    if year == 2017
	capture replace cpi =	100		/    203.5454    if year == 2018
	capture replace cpi =	100		/    234.4371    if year == 2019
	capture replace cpi =	100		/    263.2236    if year == 2020
	capture replace cpi =	100		/    314.8062    if year == 2021
	capture replace cpi =	100		/    542.4388    if year == 2022
	
	label variable cpi "Consumer Price Index, 2010 ₺"
	
	assert cpi!=0
