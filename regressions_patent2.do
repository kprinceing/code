防误触快捷键
*
*----------------------------------------------------------------------------------------------------*
use "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022-QN2.dta",clear
rename 年份 year
drop id
replace 申请部门估="未知学院" if 申请部门估==""
egen id=group(姓名 申请部门估)  //因为没有重名的人，为了保留住更多的观测值，将确实的申请部门补上再生成id

xtset id year  //id=group(姓名 申请部门估)
**#
//由于没有重名的，所有（姓名-年份）内申请部门估都是一样的
local tt tt_applied1 tt_granted1 tt_applied2 tt_granted2 tt_applied3 tt_granted3
foreach i of varlist `tt' {
    replace `i'=0 if `i'==.
}

g grant_t=year-fundyear
order fundyear grant_t, after(year)
replace grant_t=0 if fundyear==.

g after_grant=1 if grant_t>0
replace after_grant=0 if grant<=0
order after_grant, after(grant_t)


/*【1】---------------type1 patent application---------------*/
sort id year
by id: gen ptapplied1_lag1 = tt_applied1[_n-1]
by id: gen ptapplied1_lag2 = tt_applied1[_n-2]
by id: gen ptapplied1_lead1 = tt_applied1[_n+1]
by id: gen ptapplied1_lead2 = tt_applied1[_n+2]
by id: gen ptapplied1_lead3 = tt_applied1[_n+3]
by id: gen ptapplied1_lead4 = tt_applied1[_n+4]
by id: gen ptapplied1_lead5 = tt_applied1[_n+5]
by id: gen ptapplied1_lead6 = tt_applied1[_n+6]


gen ptapplied1_next2 = ptapplied1_lead1+ptapplied1_lead2
gen ptapplied1_next3 = ptapplied1_lead1+ptapplied1_lead2+ptapplied1_lead3
gen ptapplied1_next4 = ptapplied1_lead1+ptapplied1_lead2+ptapplied1_lead3+ptapplied1_lead4
gen ptapplied1_next5 = ptapplied1_lead1+ptapplied1_lead2+ptapplied1_lead3+ptapplied1_lead4+ptapplied1_lead5
gen ptapplied1_next6 = ptapplied1_lead1+ptapplied1_lead2+ptapplied1_lead3+ptapplied1_lead4+ptapplied1_lead5+ptapplied1_lead6

bysort id (year) : gen cum_ptapplied1 = sum(ptapplied1_lag1)




*********************************
* Impacts on type1 patent application (cumulative sum)

local y tt_applied1 ptapplied1_next2 ptapplied1_next3 ptapplied1_next4 ptapplied1_next5 ptapplied1_next6
foreach i of varlist `y' {
	estimates clear
	quietly{
		/*eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
		*/
		eststo: areg  `i' after_grant grant_t cum_ptapplied1 i.year, absorb(姓名)  /* cluster(author_name) */ 
	}
	esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
}


*********************************
* Impacts on type1 patent application (cumulative sum) plot
estimates clear
local y ptapplied1_lead1 ptapplied1_next2 ptapplied1_next3 ptapplied1_next4 ptapplied1_next5 ptapplied1_next6
foreach i of varlist `y' {
	quietly{
/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
 */		eststo: areg  `i' after_grant grant_t cum_ptapplied1 i.year, absorb(姓名)  /* cluster(author_name) */ 
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

/* coefplot est*, keep(after_grant)	///
	xtitle("Cumulative publications") ///
	levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///
	label(6 "Year 3") label(8 "Year 4") label(10 "Year 5"))	 */

coefplot est*, keep(after_grant)	///
	xtitle("专利累计申请数量") ///
	coeflabels(after_grant = "基金资助后") ///
	levels(95) legend(label(2 "一年内") label(4 "两年内") ///
	label(6 "三年内") label(8 "四年内") label(10 "五年内") label(12 "六年内"))			

/*	levels(95) legend(label(2 "前一年") label(4 "前二年") ///
	label(6 "前三年") label(8 "前四年") label(10 "前五年"))		*/	
graph export "F:\基金研究\graph_patent\ols_type1_patent_application_2.png", as(png) name("Graph") width(600)height(450) replace


/*【2】---------------type1 patent granted---------------*/
sort id year
by id: gen ptgranted1_lag1 = tt_granted1[_n-1]
by id: gen ptgranted1_lag2 = tt_granted1[_n-2]
by id: gen ptgranted1_lead1 = tt_granted1[_n+1]
by id: gen ptgranted1_lead2 = tt_granted1[_n+2]
by id: gen ptgranted1_lead3 = tt_granted1[_n+3]
by id: gen ptgranted1_lead4 = tt_granted1[_n+4]
by id: gen ptgranted1_lead5 = tt_granted1[_n+5]
by id: gen ptgranted1_lead6 = tt_granted1[_n+6]


gen ptgranted1_next2 = ptgranted1_lead1+ptgranted1_lead2
gen ptgranted1_next3 = ptgranted1_lead1+ptgranted1_lead2+ptgranted1_lead3
gen ptgranted1_next4 = ptgranted1_lead1+ptgranted1_lead2+ptgranted1_lead3+ptgranted1_lead4
gen ptgranted1_next5 = ptgranted1_lead1+ptgranted1_lead2+ptgranted1_lead3+ptgranted1_lead4+ptgranted1_lead5
gen ptgranted1_next6 = ptgranted1_lead1+ptgranted1_lead2+ptgranted1_lead3+ptgranted1_lead4+ptgranted1_lead5+ptgranted1_lead6

bysort id (year) : gen cum_ptgranted1 = sum(ptgranted1_lag1)



*********************************
* Impacts on type1 patent granted (cumulative sum)
local y ptgranted1_lead1 ptgranted1_next2 ptgranted1_next3 ptgranted1_next4 ptgranted1_next5 ptgranted1_next6
foreach i of varlist `y' {
	estimates clear
	quietly{
		/*eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
		*/
		eststo: areg  `i' after_grant grant_t cum_ptapplied1 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
	}
	esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
}


*********************************
* Impacts on type1 patent grantred (cumulative sum) plot
estimates clear
local y ptgranted1_lead1 ptgranted1_next2   ptgranted1_next3 ptgranted1_next4 ptgranted1_next5 ptgranted1_next6

foreach i of varlist `y' {
	quietly{
/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
 */		
        eststo: areg  `i' after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		*eststo: areg  `i' after_grant grant_t  ptapplied1_next2 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 

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

/* coefplot est*, keep(after_grant)	///
	xtitle("Cumulative publications") ///
	levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///
	label(6 "Year 3") label(8 "Year 4") label(10 "Year 5"))	 */

coefplot est*, keep(after_grant)	///
	xtitle("专利累计授权数量") ///
	coeflabels(after_grant = "基金资助后") ///
	levels(95) legend(label(2 "一年内") label(4 "两年内") ///
	label(6 "三年内") label(8 "四年内") label(10 "五年内") label(12 "六年内"))			

/*	levels(95) legend(label(2 "前一年") label(4 "前二年") ///
	label(6 "前三年") label(8 "前四年") label(10 "前五年"))		*/	
graph export "F:\基金研究\graph_patent\ols_type1_patent_granted_2.png", as(png) name("Graph") width(600)height(450) replace


