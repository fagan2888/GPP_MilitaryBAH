/*This program appends together data from the military demographics reports 
(2003-2014).*/

clear *
macro drop _all
cap log close 

import excel ../input_data/cleaned/demographics_2003.xlsx, firstrow clear

local vars base branch zip nmc miles_to_nmc sponsors_tot dependents_tot personnel_tot year state

keep `vars'

save ../output_data/demographics_preclean.dta, replace

forvalues i = 4/14 { 
	local j: di %02.0f `i'
	import excel ../input_data/cleaned/demographics_20`j'.xlsx, ///
		firstrow clear
	keep `vars'
	append using ../output_data/demographics_preclean.dta
	save ../output_data/demographics_preclean.dta, replace
}

use ../output_data/demographics_preclean.dta, clear

replace base = upper(base)
foreach var in base nmc { 
	replace `var' = subinstr(`var',",","",.)
	replace `var' = subinstr(`var',".","",.)
	replace `var' = subinstr(`var',"/","",.)
}
split(nmc), gen(metro)
foreach var of varlist metro* { 
	replace `var' = "" if inlist(`var',"DC","MO","PA","TX","FL","IA") | ///
		inlist(`var',"AL","VA")
}
egen nmc_clean = concat(metro*), punct(" ")
order nmc nmc_clean
drop metro*

foreach var in base nmc nmc_clean branch { 
	replace `var' = trim(`var')
}

drop if base == "" 
replace branch = "Navy" if base == "NAVAL SECURITY STATION"

assert zip == . & miles_to_nmc == . & branch == "" if base == "OTHER"

/*I have no idea what branch "PHOENIX AGS" and "KUMA DEF COMM CTR" belong to...I've 
looked on Google, but it hasn't helped. I can look into these if necessary, but these two
bases don't appear in the full sample.*/

assert zip != . & miles_to_nmc != . & branch != "" ///
	if base != "OTHER" & base != "UNITED STATES OTHER" & base != "PHOENIX AGS" & base != "KUMA DEF COMM CTR"

strgroup base, gen(base_clean) threshold(0.1) force
sort base_clean base

/*check results of string-matching by hand (4 close matches); hand-verify and replace*/
list base_clean if base != base[_n-1] & base_clean == base_clean[_n-1]
list if inlist(base_clean,15,93,165,201)

replace base = base[_n-1] if base_clean == base_clean[_n-1]
drop base_clean

save ../output_data/demographics_clean.dta, replace
