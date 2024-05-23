 
cd "/Users/yansong/Nutstore Files/基金研究/data/2013--2022面青"

clear
import delimited "ms_reg_type1_coded.csv", encoding(UTF-8)
save ms_reg_type1_coded.dta,replace



clear
import delimited "ms_reg_type2.csv", encoding(UTF-8)
save ms_reg_type2.dta,replace


******************   OLS Main results  ************************************************************************

set more off
use ms_reg_type1_coded.dta,clear 

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

*********************************
* Impacts on publications (per year)

	local y author_eid pub_lead1 pub_lead2 pub_lead3 pub_lead4 pub_lead5 pub_lead6 
	foreach i of varlist `y' {
		estimates clear
		quietly{
			eststo: reg  `i'  after_grant /* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
			eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)  /* cluster(author_name) */ 
		}
		esttab, keep(after_grant ) ///
			star(* 0.10 ** 0.05 *** 0.01) se r2
	}

* Impacts on publications (per year) plot
	estimates clear
	local y author_eid pub_lead1 pub_lead2 pub_lead3 pub_lead4 pub_lead5 pub_lead6 
	foreach i of varlist `y' {
		quietly{
	/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
	 */		eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)  /* cluster(author_name) */ 
		}	
	}
	esttab, keep(after_grant ) ///
			star(* 0.10 ** 0.05 *** 0.01) se r2
	coefplot est*, keep(after_grant) ///
			levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///
		label(6 "Year 3") label(8 "Year 4") label(10 "Year 5"))		
*********************************
* Impacts on publications (cumulative sum)

	local y author_eid pub_next2 pub_next3 pub_next4 pub_next5 pub_next6 
	foreach i of varlist `y' {
		estimates clear
		quietly{
			eststo: reg  `i'  after_grant /* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
			eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)  /* cluster(author_name) */ 
		}
		esttab, keep(after_grant ) ///
			star(* 0.10 ** 0.05 *** 0.01) se r2
	}

*********************************
* Impacts on publications (cumulative sum) plot
	estimates clear
	local y author_eid pub_next2 pub_next3 pub_next4 pub_next5 pub_next6
	foreach i of varlist `y' {
		quietly{
	/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
			eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
	 */		eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)  /* cluster(author_name) */ 
		}
		esttab, keep(after_grant ) ///
			star(* 0.10 ** 0.05 *** 0.01) se r2
	}
	grstyle init 
	grstyle set horizontal // set tick labels horizontal
	grstyle set compact // overall design compact
	grstyle set size small: subheading axis_title // subtitle and axis title set to small
	grstyle set size vsmall: small_body // margin around notes
	grstyle set legend 6, nobox //legend position on 6 o'clock, removes box
	grstyle set linewidth thin: major_grid // set grid line thickness to thin
	grstyle set linewidth thin: tick // set tick thickness to thin
	grstyle set linewidth thin: axisline // set axislines thickness to thin
	grstyle set linewidth vthin: xyline // reference line at 0

	grstyle set color economist, order(10 1 8 2 3 4 5 6 7 9 11 12 13 14 15)
	grstyle color background white // set overall background to white
	grstyle set color black*.7: tick tick_label // set tick and tick label color
 */
/* coefplot est*, keep(after_grant)	///
	xtitle("Cumulative publications") ///
	levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///
	label(6 "Year 3") label(8 "Year 4") label(10 "Year 5"))	*/

	coefplot est*, keep(after_grant)	///
		xtitle("论文累计发表数量") ///
		coeflabels(after_grant = "基金资助后") ///
		levels(95) legend(label(2 "前一年") label(4 "前二年") ///
		label(6 "前三年") label(8 "前四年") label(10 "前五年")	label(12 "前六年"))	

	graph export "/Users/yansong/Nutstore Files/基金研究/graph_updated/ms_OLS_main.png", ///
	width(600)height(450) replace



******************   OLS Main results by NSFC code ************************************************************************


set more off
use ms_reg_type1_coded.dta,clear 

	egen id = group(申请人 申请部门)
	drop if id == .
	duplicates drop id year, force
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

	bysort id (year) : gen cum_pubs = sum(pub_lag1)

*********************************************
* Impacts on publications by research area 
/* A.数理科学部 B.化学科学部 C.生命科学部 D.地球科学部
   E.工程与材料科学部 F.信息科学部 G.管理科学部 */
	local y  author_eid pub_next2  pub_next3 pub_next4 pub_next5
	foreach i of varlist `y' {
		estimates clear
		local code A B C D E F G 
		foreach n_code of local code { 
			display("`n_code'")
			quietly: eststo: areg  `i' after_grant  ///
			grant_t cum_pubs i.year, absorb(author_name) ///
			,if  nsfc_code == "`n_code'"		
		}
		esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
	}  

*table nsfc_code, c(mean pub_next2) format(%9.3f)

*********************************************
* Impacts on publications by research area  (plot)
/* A.数理科学部 B.化学科学部 C.生命科学部 D.地球科学部
   E.工程与材料科学部 F.信息科学部 G.管理科学部 */
estimates clear
local y  author_eid pub_next2  pub_next3 pub_next4 pub_next5
local counter = 0 
foreach i of varlist `y' {
	local code A B C D E F G 
	foreach n_code of local code { 
		display("`n_code'")
		quietly:  areg  `i' after_grant  ///
		grant_t cum_pubs i.year, absorb(author_name) ///
		,if  nsfc_code == "`n_code'"	
		local est_name = "`n_code'" + "`counter'"
		estimates store `est_name'
		local counter = `counter' +1	
	}
}  
grstyle init 
grstyle set horizontal // set tick labels horizontal
grstyle set compact // overall design compact
grstyle set size small: subheading axis_title // subtitle and axis title set to small
grstyle set size vsmall: small_body // margin around notes
grstyle set legend 6, nobox //legend position on 6 o'clock, removes box
grstyle set linewidth thin: major_grid // set grid line thickness to thin
grstyle set linewidth thin: tick // set tick thickness to thin
grstyle set linewidth thin: axisline // set axislines thickness to thin
grstyle set linewidth vthin: xyline // reference line at 0

grstyle set color economist, order(10 1 8 2 3 4 5 6 7 9 11 12 13 14 15)
grstyle color background white // set overall background to white
grstyle set color black*.7: tick tick_label // set tick and tick label color
/* grstyle set color black*.08: plotregion plotregion_line //set plot area background
color
grstyle set color White: axisline major_grid // set axis and grid line color
grstyle set color black*.7: small_body // set note color
grstyle set color white*.08, opacity(0): pbarline // graph bar outline transparent

 */
	coefplot A*, bylabel(数学) || B*, bylabel(化学) || ///
			 C*, bylabel(生命科学) || D* , bylabel(地球科学) || ///
			 E*, bylabel(工程与材料) || F*, bylabel(信息科学) || ///
			 G*, bylabel(管理科学) ||, ///
			 xtitle("论文累计发表数量") ///
			 levels(95) keep(after_grant) ///
		 	 coeflabels(after_grant = "基金资助后") ///
			 legend(label(2 "前一年") label(4 "前二年") ///
			 label(6 "前三年") label(8 "前四年") label(10 "前五年"))		

graph export "/Users/yansong/Nutstore Files/基金研究/graph_updated/ms_OLS_by_field.png", ///
	width(600)height(450) replace


**********************************************************************************************
* Regressions with sentiment
set more off
use ms_reg_type2.dta,clear 

egen id = group(申请人 申请部门)
drop if id == .
xtset id year 

sort id year
by id: gen pub_lag1 = author_eid[_n-1]
bysort id (year) : gen cum_pubs = sum(pub_lag1)


drop below_cutoff
gen below_cutoff = senti<0.5

**************** Rolling sum with 1-5 periods****************
*estimates clear
*local y rolling_sum rolling_sum3 rolling_sum4 rolling_sum5
estimates clear
set matsize 2000
local y author_eid rolling_sum rolling_sum3 rolling_sum4 rolling_sum5 /* citations */
foreach i of varlist `y' {
	
	*eststo: areg `i' after_grant  i.year, absorb(author_name) 
	*eststo: areg `i' after_grant cum_pubs i.year , absorb(author_name) 
	*eststo: areg `i' after_grant cum_pubs i.year if senti!=., absorb(author_name) 
	*eststo: areg `i' after_grant cum_pubs  senti senti_squared i.year, absorb(author_name) 
	quietly : eststo: ivregress 2sls  `i' cum_pubs grant_t i.year i.id ///
	(after_grant = senti senti_squared below_cutoff), first
	*eststo: xtivreg `i'  i.year (after_grant = senti senti_squared ), fe
}
esttab, keep(after_grant /*   senti senti_squared */) ///
	star(* 0.10 ** 0.05 *** 0.01) se r2 

/* coefplot est*, keep(after_grant)	///
	xtitle("Cumulative publications") ///
	levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///
	label(6 "Year 3") label(8 "Year 4") label(10 "Year 5"))	 */

coefplot est*, keep(after_grant)	///
	xtitle("累计论文发表数量") ///
	levels(95) coeflabels(after_grant = "基金资助后") ///
	legend(label(2 "前一年") label(4 "前二年") ///
	label(6 "前三年") label(8 "前四年") /* label(10 "前五年"))	 */

graph export "/Users/yansong/Nutstore Files/基金研究/graph_updated/IV_main.png", ///
	width(600)height(450) replace

*reg after_grant cum_pubs senti senti_squared below_cutoff i.year

**************** Citations ****************
quietly: eststo: ivregress 2sls citations cum_pubs grant_t i.year i.id ///
	(after_grant = senti senti_squared below_cutoff), first
esttab, keep(after_grant /*   senti senti_squared */) ///
	star(* 0.10 ** 0.05 *** 0.01) se r2 	



** test
est clear
local y author_eid rolling_sum rolling_sum3 rolling_sum4 rolling_sum5 /* citations */
foreach i of varlist `y' {
	
	*eststo: areg `i' after_grant  i.year, absorb(author_name) 
	*eststo: areg `i' after_grant cum_pubs i.year , absorb(author_name) 
	*eststo: areg `i' after_grant cum_pubs i.year if senti!=., absorb(author_name) 
	*eststo: areg `i' after_grant cum_pubs  senti senti_squared i.year, absorb(author_name) 
	quietly : eststo: areg `i' after_grant grant_t cum_pubs i.year if senti!=., absorb(author_name) 
	}
esttab, keep(after_grant /*   senti senti_squared */) ///
	star(* 0.10 ** 0.05 *** 0.01) se r2 


