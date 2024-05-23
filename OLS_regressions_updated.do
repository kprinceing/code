


cd "/Users/yansong/Nutstore Files/基金研究/data/2013--2022面青"
global output "/Users/yansong/Nutstore Files/基金研究/tables"


** NSFC Youth grant 
set more off
use qn_reg_type1.dta,clear 

* Generate cumulative publications 
	egen id = group(申请人 申请部门)
	tab id if _merge=="left_only"  //all missing 
	drop if id == .
	xtset id year

	sort id year
	by id: gen pub_lag1 = author_eid[_n-1]
	by id: gen pub_lag2 = author_eid[_n-2]
	by id: gen pub_lead1 = author_eid[_n+1]
	by id: gen pub_lead2 = author_eid[_n+2]
	by id: gen pub_lead3 = author_eid[_n+3]
	by id: gen pub_lead4 = author_eid[_n+4]
	by id: gen pub_lead5 = author_eid[_n+5]
	by id: gen pub_lead6 = author_eid[_n+6]

	gen pub_next2 = pub_lead1+pub_lead2
	gen pub_next3 = pub_lead1+pub_lead2+pub_lead3
	gen pub_next4 = pub_lead1+pub_lead2+pub_lead3+pub_lead4
	gen pub_next5 = pub_lead1+pub_lead2+pub_lead3+pub_lead4+pub_lead5
	gen pub_next6 = pub_lead1+pub_lead2+pub_lead3+pub_lead4+pub_lead5+pub_lead6

	bysort id (year) : gen cum_pubs = sum(pub_lag1)


* OLS estimates 
	estimates clear 

	local y pub_next5
	foreach i of varlist `y' {
		quietly{
		eststo: reg  `i'  after_grant
		estadd local Author_FE = " ", replace
		estadd local Controls = " ", replace
		eststo: areg  `i' after_grant, absorb(author_name)
		estadd local Author_FE = " ", replace
		estadd local Controls = "Y", replace
		eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)
		estadd local Author_FE = "Y", replace
		estadd local Controls = "Y", replace
		}
	}
	esttab, keep(after_grant ) star(* 0.10 ** 0.05 *** 0.01) se r2

	esttab est1 est2 est3 using "$output/ols_main.tex", ///
	keep(after_grant) ///
    prehead("\begin{table}[htbp]\centering \\  \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \\ \caption{OLS estimates of the impact of NSFC funding on research outcomes} \\ \begin{tabular}{l*{3}{c}} \toprule") ///
	posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel A: NSFC Youth grant}} \\\\[-1ex]") ///
	fragment ///
	stats(Author_FE Controls r2 N, labels("Author_FE" "Controls"  R-squared "N. of cases")) b(%8.3f) se(%8.3f) replace
	eststo clear

** NSFC Senior grant 
set more off
use ms_reg_type1_coded.dta,clear 

* Generate cumulative publications 
	egen id = group(申请人 申请部门)
	tab id if _merge=="left_only"  //all missing 
	drop if id == .
	duplicates drop id year,force
	xtset id year

	sort id year
	by id: gen pub_lag1 = author_eid[_n-1]
	by id: gen pub_lag2 = author_eid[_n-2]
	by id: gen pub_lead1 = author_eid[_n+1]
	by id: gen pub_lead2 = author_eid[_n+2]
	by id: gen pub_lead3 = author_eid[_n+3]
	by id: gen pub_lead4 = author_eid[_n+4]
	by id: gen pub_lead5 = author_eid[_n+5]
	by id: gen pub_lead6 = author_eid[_n+6]


	gen pub_next2 = pub_lead1+pub_lead2
	gen pub_next3 = pub_lead1+pub_lead2+pub_lead3
	gen pub_next4 = pub_lead1+pub_lead2+pub_lead3+pub_lead4
	gen pub_next5 = pub_lead1+pub_lead2+pub_lead3+pub_lead4+pub_lead5
	gen pub_next6 = pub_lead1+pub_lead2+pub_lead3+pub_lead4+pub_lead5+pub_lead6

	bysort id (year) : gen cum_pubs = sum(pub_lag1)

* OLS estimates 

	local y pub_next5
	foreach i of varlist `y' {
		quietly{
		eststo: reg  `i'  after_grant
		estadd local Author_FE = " ", replace
		estadd local Controls = " ", replace
		eststo: areg  `i' after_grant, absorb(author_name)
		estadd local Author_FE = " ", replace
		estadd local Controls = "Y", replace
		eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)
		estadd local Author_FE = "Y", replace
		estadd local Controls = "Y", replace
		}
	}
	esttab, keep(after_grant ) star(* 0.10 ** 0.05 *** 0.01) stats(Author_FE Controls r2 N) se 


	esttab est1 est2 est3 using "$output/ols_main.tex", ///
	keep(after_grant ) ///
   	posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: NSFC Senior Grant}} \\\\[-1ex]") ///
	fragment ///
	append ///
	r2 b(%8.3f) se(%8.3f) stats(Author_FE Controls r2 N, labels("Author_FE" "Controls"  R-squared "N. of cases")) nomtitles nonumbers  ///
	prefoot("\hline") ///
	postfoot("\bottomrule \multicolumn{5}{l}{\footnotesize Standard errors in parentheses}\\\multicolumn{3}{l}{\footnotesize \sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)}\\ \end{tabular} \\ \end{table}")

	