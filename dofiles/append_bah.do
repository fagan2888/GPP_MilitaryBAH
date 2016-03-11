/*This program appends together data from the military BAH reports 
(1999-2016).*/
clear *
macro drop _all
cap log close 



*Paths*
if "`c(os)'" == "Unix" {
   global root = "/san/RDS/Work/fif/b1ked01/Paul"

}
else if "`c(os)'" == "Windows" {
   global root = "//rb/b1/NYRESAN/RDS/Work/fif/b1ked01/Paul"
}

sysdir set PERSONAL "$root/ados"

global location = "$root/military"
log using ${location}/documentation/append_bah, replace
log off
forvalues year = 1998/2016 { 
	if `year' < 2000 { 
		local i = `year' - 1900 
	}
	else if `year' >= 2000 { 
		local i = `year' - 2000
		local i: di %02.0f `i'
	}
	foreach var in w wo { 
		local j = "`var'"
		import delimited ${location}/input_data/txt/`year'BAH/bah`var'`i'.txt, delimiter(comma) clear
		local y = 0 
		foreach var of varlist v* { 
			local ++y 
		}
		*assert "`y'" == "25" *1999 data breaks this assert--I delete the additional columns later on--ask me about this
		di "`y'"
		if `year' == 1999 { 
			drop v26 - v28
		}
		if "`j'" == "w" { 
			gen w = 1
		}
		else if "`j'" == "wo" { 
			gen w = 0 
		}
		rename v1 id
		if "`j'" == "w" { 
			save ${location}/tmp/tmp_w.dta, replace
		}
		if "`j'" == "wo"  {
			append using ${location}/tmp/tmp_w.dta
			gen year = `year'
			save ${location}/output_data/bah_preclean_`i'.dta, replace
		}
	di `year'
	}
}
log on
forvalues year = 1998/2016 { 
	if `year' < 2000 { 
		local i = `year' - 1900 
	}
	else if `year' >= 2000 { 
		local i = `year' - 2000
		local i: di %02.0f `i'
	}
	import delimited ${location}/input_data/txt/`year'BAH/sorted_zipmha`i'.txt, delimiter(space) clear
	cap drop v3
	rename v2 id
	rename v1 zip
	di `year'
	joinby id using ${location}/output_data/bah_preclean_`i'.dta, _merge(_mergezip`i')
	save ${location}/output_data/bah_preclean_`i'.dta, replace
	
	import delimited ${location}/input_data/txt/`year'BAH/mhanames`i'.txt, delimiter(";") clear
	cap drop v3
	rename v1 id
	rename v2 city
	di `year'
	joinby id using ${location}/output_data/bah_preclean_`i'.dta, _merge(_mergecity`i')
	save ${location}/output_data/bah_preclean_`i'.dta, replace

}
log off
translate ${location}/documentation/append_bah.smcl ${location}/documentation/append_bah.pdf
use ${location}/output_data/bah_preclean_98.dta, clear
forvalues year = 1999/2016 { 
	if `year' < 2000 { 
		local i = `year' - 1900 
	}
	else if `year' >= 2000 { 
		local i = `year' - 2000
		local i: di %02.0f `i'
	}
	append using ${location}/output_data/bah_preclean_`i'.dta
	save ${location}/output_data/bah_preclean_full.dta, replace
} 
	

