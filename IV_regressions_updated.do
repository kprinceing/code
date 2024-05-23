* IV Regressions

cd "/Users/yansong/Nutstore Files/基金研究/data/2013--2022面青"
global output "/Users/yansong/Nutstore Files/基金研究/tables"

** Youth grant
set more off
use qn_reg_type2.dta,clear 

* Generate variables
	egen id = group(申请人 申请部门)
	drop if id == .
	xtset id year 

	sort id year
	by id: gen pub_lag1 = author_eid[_n-1]
	bysort id (year) : gen cum_pubs = sum(pub_lag1)

	drop below_cutoff
	gen below_cutoff = senti<0.5


	gen senti_cubic  = senti*senti_squared

	estimates clear
	set matsize 2000
	local y rolling_sum5
	foreach i of varlist `y' {
	quietly{		
/* 		regress after_grant cum_pubs grant_t  i.year i.id senti senti_squared below_cutoff 
		est store first */


		eststo: reg `i' after_grant cum_pubs grant_t i.year i.id senti senti_squared 
		eststo: ivregress 2sls  `i' cum_pubs grant_t i.year i.id senti senti_squared  ///
		(after_grant = below_cutoff), first
		}
	}
	esttab, keep(after_grant /*   senti senti_squared */) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2 
