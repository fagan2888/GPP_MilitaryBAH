/*Cleaning*/
use ${location}/output_data/bah_preclean_full.dta, clear
foreach v of varlist v* {
	tab year if `v' == . 
}

drop if id == "" & city == "" & zip == . & year == 2016

assert v29 == . 
drop v29
assert v30 == . 
drop v30

order zip year w, after(city)
order v26 v27 v28, after(v25)

forvalues year = 1998/2016 { 
	if `year' < 2000 { 	
		local i = `year' - 1900
		
	}
	if `year' >= 2000 {
		local i = `year' - 2000
		local i: di %02.0f `i'
	}
	assert _mergecity`i' == . if year != `year' & year != .
	assert _mergezip`i' == . if year != `year' & year != . 
}

foreach v of varlist v* {
	tab year if `v' == . 
}

/*I think the additional observations here in v26-v28 are coming from repetitions, so 
I delete these vars*/
assert v28 == v27 
assert v27 == v28
assert v26 == v27
assert v25 == v26 if v26 != . 
drop v26-v28

drop _merge*

save ${location}/output_data/bah_clean_full.dta, replace
