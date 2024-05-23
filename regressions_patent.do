防误触快捷键
*删除记录dataclean_NSFC.do
*NSFC2013-2022-QN.dta删除了有两次青年项目立项的人
*
*----------------------------------------------------------------------------------------------------*
clear
use "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022-QN.dta"
rename 年份 year
xtset id year  //id=group(姓名 申请部门估)
**#
//由于没有重名的，所有（姓名-年份）内申请部门估都是一样的
local tt tt_applied1 tt_granted1 tt_applied2 tt_granted2 tt_applied3 tt_granted3
foreach i of varlist `tt' {
    replace `i'=0 if `i'==.
}

g 立项年份=year if lixiang==1
bys id: egen 立项次数=total(!missing(立项年份))
tab 立项次数  //有一个人青年项目立项了两次！！！
drop if 立项次数==2   //删掉了两次青年立项的人
drop 立项次数
bys id: egen fundyear=max(立项年份)
order fundyear, after(lixiang)
drop 立项年份

g grant_t=year-fundyear
order grant_t, after(fundyear)
replace grant_t=0 if fundyear==.

g after_grant=1 if grant_t>0
order after_grant, after(grant_t)
replace after_grant=0 if grant<=0

g tt_applied=tt_applied1+tt_applied2+tt_applied3
g tt_granted=tt_granted1+tt_granted2+tt_granted3

encode 申请部门估, g(school)
order school, after(申请部门估)

/*【0】---------------overall patent application and grant---------------*/
sort id year
******
by id: gen ptapplied_lag1 = tt_applied[_n-1]
by id: gen ptapplied_lag2 = tt_applied[_n-2]
by id: gen ptapplied_lead1 = tt_applied[_n+1]
by id: gen ptapplied_lead2 = tt_applied[_n+2]
by id: gen ptapplied_lead3 = tt_applied[_n+3]
by id: gen ptapplied_lead4 = tt_applied[_n+4]
by id: gen ptapplied_lead5 = tt_applied[_n+5]
by id: gen ptapplied_lead6 = tt_applied[_n+6]
***
by id: gen ptgranted_lag1 = tt_granted[_n-1]
by id: gen ptgranted_lag2 = tt_granted[_n-2]
by id: gen ptgranted_lead1 = tt_granted[_n+1]
by id: gen ptgranted_lead2 = tt_granted[_n+2]
by id: gen ptgranted_lead3 = tt_granted[_n+3]
by id: gen ptgranted_lead4 = tt_granted[_n+4]
by id: gen ptgranted_lead5 = tt_granted[_n+5]
by id: gen ptgranted_lead6 = tt_granted[_n+6]
******
gen ptapplied_next2 = ptapplied_lead1+ptapplied_lead2
gen ptapplied_next3 = ptapplied_lead1+ptapplied_lead2+ptapplied_lead3
gen ptapplied_next4 = ptapplied_lead1+ptapplied_lead2+ptapplied_lead3+ptapplied_lead4
gen ptapplied_next5 = ptapplied_lead1+ptapplied_lead2+ptapplied_lead3+ptapplied_lead4+ptapplied_lead5
gen ptapplied_next6 = ptapplied_lead1+ptapplied_lead2+ptapplied_lead3+ptapplied_lead4+ptapplied_lead5+ptapplied_lead6
***
gen ptgranted_next2 = ptgranted_lead1+ptgranted_lead2
gen ptgranted_next3 = ptgranted_lead1+ptgranted_lead2+ptgranted_lead3
gen ptgranted_next4 = ptgranted_lead1+ptgranted_lead2+ptgranted_lead3+ptgranted_lead4
gen ptgranted_next5 = ptgranted_lead1+ptgranted_lead2+ptgranted_lead3+ptgranted_lead4+ptgranted_lead5
gen ptgranted_next6 = ptgranted_lead1+ptgranted_lead2+ptgranted_lead3+ptgranted_lead4+ptgranted_lead5+ptgranted_lead6
******
gen grant_rate_next1=ptgranted_lead1/ptapplied_lead1
gen grant_rate_next2=ptgranted_next2/ptapplied_next2
gen grant_rate_next3=ptgranted_next3/ptapplied_next3
gen grant_rate_next4=ptgranted_next4/ptapplied_next4
gen grant_rate_next5=ptgranted_next5/ptapplied_next5
gen grant_rate_next6=ptgranted_next6/ptapplied_next6

/*
replace grant_rate_next1=0 if ptapplied_lead1==0
foreach i of numlist 2/6{
replace grant_rate_next`i'=0 if ptapplied_next`i'==0
}
*/

bysort id (year) : gen cum_ptapplied = sum(ptapplied_lag1)
bysort id (year) : gen cum_ptgranted = sum(ptgranted_lag1)
bysort id (year) : gen cum_grant_rate = cum_ptgranted/cum_ptapplied
*replace cum_grant_rate=0 if cum_ptapplied==0



*********************************
* Impacts on 【overall】 patent application (cumulative sum) plot
sum ptapplied_lead1  //0.75
sum ptapplied_next2  //1.55
sum ptapplied_next3  //2.33
estimates clear
local y ptapplied_lead1 ptapplied_next2 ptapplied_next3 ptapplied_next4 ptapplied_next5 
foreach i of varlist `y' {
	quietly{
/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
 */		
  		eststo: areg  `i' after_grant grant_t cum_ptapplied  i.year, absorb(姓名)  /* cluster(author_name) */ 
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
	xtitle("全部专利累计申请数量") ///
	coeflabels(after_grant = "基金资助后") ///
	levels(95) legend(label(2 "一年内") label(4 "两年内") ///
	label(6 "三年内") label(8 "四年内") label(10 "五年内"))			

/*	levels(95) legend(label(2 "前一年") label(4 "前二年") ///
	label(6 "前三年") label(8 "前四年") label(10 "前五年"))		*/	
graph export "F:\基金研究\graph_patent\ols_overall_patent_application.png", as(png) name("Graph") width(600)height(450) replace


*********************************
* Impacts on 【overall】 patent grant rate (cumulative sum) plot
estimates clear
local y grant_rate_next1 grant_rate_next2 grant_rate_next3 grant_rate_next4 grant_rate_next5 
foreach i of varlist `y' {
	quietly{
/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
 */		eststo: areg  `i' after_grant grant_t cum_grant_rate i.year, absorb(姓名)  /* cluster(author_name) */ 
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
	xtitle("全部专利累计授权率") ///
	coeflabels(after_grant = "基金资助后") ///
	levels(90) legend(label(2 "一年内") label(4 "两年内") ///
	label(6 "三年内") label(8 "四年内") label(10 "五年内"))			

/*	levels(95) legend(label(2 "前一年") label(4 "前二年") ///
	label(6 "前三年") label(8 "前四年") label(10 "前五年"))		*/	
graph export "F:\基金研究\graph_patent\ols_overall_patent_grantrate.png", as(png) name("Graph") width(600)height(450) replace

*********************************
sum ptgranted_lead1  //0.45
sum ptgranted_next2  //0.96
sum ptgranted_next3  //1.49
* Impacts on 【overall】 patent grant number (cumulative sum) plot
estimates clear
	quietly{
	eststo: areg  ptgranted_lead1 after_grant grant_t cum_ptgranted cum_ptapplied i.year /*if ptapplied_lead1!=0*/, absorb(姓名)  /* cluster(author_name) */ 
	eststo: areg  ptgranted_next2 after_grant grant_t cum_ptgranted cum_ptapplied i.year /*if ptgranted_next2!=0*/, absorb(姓名)  /* cluster(author_name) */ 
	eststo: areg  ptgranted_next3 after_grant grant_t cum_ptgranted cum_ptapplied i.year /*if ptgranted_next3!=0*/, absorb(姓名)  /* cluster(author_name) */ 
	eststo: areg  ptgranted_next4 after_grant grant_t cum_ptgranted cum_ptapplied i.year /*if ptgranted_next4!=0*/, absorb(姓名)  /* cluster(author_name) */ 
	eststo: areg  ptgranted_next5 after_grant grant_t cum_ptgranted cum_ptapplied i.year /*if ptgranted_next5!=0*/, absorb(姓名)  /* cluster(author_name) */ 
	*eststo: areg  ptgranted_next6 after_grant grant_t ptapplied_next6 i.year, absorb(姓名)  /* cluster(author_name) */ 
}
	esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
		
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
	xtitle("全部专利累计授权数量(unconditioanl)") ///
	coeflabels(after_grant = "基金资助后") ///
	levels(90) legend(label(2 "一年内") label(4 "两年内") ///
	label(6 "三年内") label(8 "四年内") label(10 "五年内"))			

/*	levels(95) legend(label(2 "前一年") label(4 "前二年") ///
	label(6 "前三年") label(8 "前四年") label(10 "前五年"))		*/	
graph export "F:\基金研究\graph_patent\ols_overall_patent_grant.png", as(png) name("Graph") width(600)height(450) replace
*/

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
/*
* Impacts on type1 patent application (per year)

local y tt_applied1 ptapplied1_lead1 ptapplied1_lead2 ptapplied1_lead3 ptapplied1_lead4 ptapplied1_lead5 ptapplied1_lead6
foreach i of varlist `y' {
	estimates clear
	quietly{
		/*eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_ptapplied1 /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_ptapplied1 i.year /* cluster(申请部门) */
		*/
		eststo: areg  `i' after_grant grant_t cum_ptapplied1 i.year, absorb(姓名)  /* cluster(author_name) */ 
	}
	esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
}

* Impacts on type1 patent application (per year) plot
estimates clear
local y  ptapplied1_lead1 ptapplied1_lead2 ptapplied1_lead3 ptapplied1_lead4 ptapplied1_lead5
foreach i of varlist `y' {
	quietly{
/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_ptapplied1 /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_ptapplied1 i.year /* cluster(申请部门) */
 */		eststo: areg  `i' after_grant grant_t cum_ptapplied1 i.year, absorb(姓名)  /* cluster(author_name) */ 
	}	
}
esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
coefplot est*, keep(after_grant) ///
		levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///
	label(6 "Year 3") label(8 "Year 4") label(10 "Year 5"))		
*/

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
sum ptapplied1_lead1  //0.67
sum ptapplied1_next2  //1.38
sum ptapplied1_next3  //2.08

estimates clear
local y ptapplied1_lead1 ptapplied1_next2 ptapplied1_next3 ptapplied1_next4 ptapplied1_next5 
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
	xtitle("发明专利累计申请数量") ///
	coeflabels(after_grant = "基金资助后") ///
	levels(95) legend(label(2 "一年内") label(4 "两年内") ///
	label(6 "三年内") label(8 "四年内") label(10 "五年内"))			

/*	levels(95) legend(label(2 "前一年") label(4 "前二年") ///
	label(6 "前三年") label(8 "前四年") label(10 "前五年"))		*/	
graph export "F:\基金研究\graph_patent\ols_type1_patent_application.png", as(png) name("Graph") width(600)height(450) replace



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
/*
* Impacts on type1 patent granted (per year)

local y ptgranted1_lead1 ptgranted1_lead2 ptgranted1_lead3 ptgranted1_lead4 ptgranted1_lead5 ptgranted1_lead6
foreach i of varlist `y' {
	estimates clear
	quietly{
		/*eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_ptapplied1 /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_ptapplied1 i.year /* cluster(申请部门) */
		*/
		eststo: areg  `i' after_grant grant_t /*cum_ptapplied1*/ cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
	}
	esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
}
ptgranted1_lead2 ptgranted1_lead3 ptgranted1_lead4 ptgranted1_lead5 ptgranted1_lead6
* Impacts on type1 patent granted (per year) plot
estimates clear
local y ptgranted1_lead1 
foreach i of varlist `y' {
	quietly{
/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_ptapplied1 /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_ptapplied1 i.year /* cluster(申请部门) */
 */		eststo: areg  `i' after_grant grant_t cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
	}	
}
esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
coefplot est*, keep(after_grant) ///
		levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///
	label(6 "Year 3") label(8 "Year 4") label(10 "Year 5") label(12 "Year 6"))		

*/
*********************************
* Impacts on type1 patent granted (cumulative sum)
estimates clear
local y ptgranted1_lead1 ptgranted1_next2 ptgranted1_next3 ptgranted1_next4 ptgranted1_next5 
foreach i of varlist `y' {
	
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

ptgranted1_lead1 ptgranted1_next3 ptgranted1_next4 ptgranted1_next5 


*********************************
* Impacts on type1 patent granted numbers (cumulative sum) plot
global past   cum_ptapplied1 cum_ptgranted1
*cum_grant_rate
estimates clear
local y  ptgranted1_next2 
	quietly{
		eststo: areg  ptgranted1_lead1 after_grant grant_t  /*ptapplied1_lead1*/  $past i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg  ptgranted1_next2 after_grant grant_t  /*ptapplied1_next2*/  $past i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg  ptgranted1_next3 after_grant grant_t  /*ptapplied1_next3*/  $past i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg  ptgranted1_next4 after_grant grant_t  /*ptapplied1_next4*/  $past i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg  ptgranted1_next5 after_grant grant_t  /*ptapplied1_next5*/  $past i.year, absorb(姓名)  /* cluster(author_name) */ 
		*eststo: areg  ptgranted1_next6 after_grant grant_t  /*ptapplied1_next6*/ /*cum_ptgranted1*/ cum_ptapplied1 i.year, absorb(姓名)  /* cluster(author_name) */ 

	}
	esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
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
	xtitle("发明专利累计授权数量(unconditional)") ///
	coeflabels(after_grant = "基金资助后") ///
	levels(95) legend(label(2 "一年内") label(4 "两年内") ///
	label(6 "三年内") label(8 "四年内") label(10 "五年内") label(12 "六年内"))			

/*	levels(95) legend(label(2 "前一年") label(4 "前二年") ///
	label(6 "前三年") label(8 "前四年") label(10 "前五年"))		*/	
graph export "F:\基金研究\graph_patent\ols_type1_patent_granted.png", as(png) name("Graph") width(600)height(450) replace






/*【3】---------------type1 patent granted rate---------------*/

/*
//single year rate
g grant1_rate_lead1=ptgranted1_lead1/ptapplied1_lead1
g grant1_rate_lead2=ptgranted1_lead2/ptapplied1_lead2
g grant1_rate_lead3=ptgranted1_lead3/ptapplied1_lead3
g grant1_rate_lead4=ptgranted1_lead4/ptapplied1_lead4
g grant1_rate_lead5=ptgranted1_lead5/ptapplied1_lead5
g grant1_rate_lead6=ptgranted1_lead6/ptapplied1_lead6

*********************************
* Impacts on type1 patent granted rate (cumulative sum) plot
estimates clear
local y grant1_rate_lead1 grant1_rate_lead2 grant1_rate_lead3 grant1_rate_lead4 grant1_rate_lead5 grant1_rate_lead6
foreach i of varlist `y' {
	quietly{
/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
 */		eststo: areg  `i' after_grant grant_t cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
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
	xtitle("专利累计授权概率") ///
	coeflabels(after_grant = "基金资助后") ///
	levels(95) legend(label(2 "一年内") label(4 "两年内") ///
	label(6 "三年内") label(8 "四年内") label(10 "五年内") label(12 "六年内"))			
*/
	
*****************************************
//cumulative rate
g grant1_rate_next1=ptgranted1_lead1/ptapplied1_lead1
g grant1_rate_next2=ptgranted1_next2/ptapplied1_next2
g grant1_rate_next3=ptgranted1_next3/ptapplied1_next3
g grant1_rate_next4=ptgranted1_next4/ptapplied1_next4
g grant1_rate_next5=ptgranted1_next5/ptapplied1_next5
g grant1_rate_next6=ptgranted1_next6/ptapplied1_next6


*********************************
* Impacts on type1 patent granted rate (cumulative sum) plot
estimates clear
local y grant1_rate_next1 grant1_rate_next2 grant1_rate_next3 grant1_rate_next4 grant1_rate_next5
foreach i of varlist `y' {
	quietly{
/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */
		eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */
 */		eststo: areg  `i' after_grant grant_t cum_grant_rate i.year, absorb(姓名)  /* cluster(author_name) */ 
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
	xtitle("发明专利累计授权率") ///
	coeflabels(after_grant = "基金资助后") ///
	levels(95) legend(label(2 "一年内") label(4 "两年内") ///
	label(6 "三年内") label(8 "四年内") label(10 "五年内"))			

/*	levels(95) legend(label(2 "前一年") label(4 "前二年") ///
	label(6 "前三年") label(8 "前四年") label(10 "前五年"))		*/	
*graph export "F:\基金研究\graph_patent\ols_type1_patent_granted.png", as(png) name("Graph") width(600)height(450) replace

graph export "F:\基金研究\graph_patent\ols_type1_patent_grantrate.png", as(png) name("Graph") width(600)height(450) replace





/*estimates clear
	quietly{
        eststo: areg ptgranted1_lead1  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg ptgranted1_lead1  after_grant grant_t  ptapplied1_lead1 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 

        eststo: areg ptgranted1_next2  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg ptgranted1_next2  after_grant grant_t  ptapplied1_next2 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */
		
        eststo: areg ptgranted1_next3  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg ptgranted1_next3  after_grant grant_t  ptapplied1_next3 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		
        eststo: areg ptgranted1_next4  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg ptgranted1_next4  after_grant grant_t  ptapplied1_next4 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		
        eststo: areg ptgranted1_next5  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg ptgranted1_next5  after_grant grant_t  ptapplied1_next5 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		
        eststo: areg ptgranted1_next6  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg ptgranted1_next6  after_grant grant_t  ptapplied1_next6 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
				
	}
	esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
		
		

estimates clear
	quietly{
 		eststo: areg grant1_rate_next1  after_grant grant_t   i.year, absorb(姓名)  /* cluster(author_name) */ 	    
 		eststo: areg grant1_rate_next1  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next1  after_grant grant_t cum_ptapplied1 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		
		eststo: areg grant1_rate_next2  after_grant grant_t   i.year, absorb(姓名)  /* cluster(author_name) */ 
		eststo: areg grant1_rate_next2  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next2  after_grant grant_t cum_ptapplied1 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		
 		eststo: areg grant1_rate_next3  after_grant grant_t   i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next3  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next3  after_grant grant_t cum_ptapplied1 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
	}
	esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2
		
estimates clear
	quietly{
		
 		eststo: areg grant1_rate_next4  after_grant grant_t   i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next4  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next4  after_grant grant_t cum_ptapplied1 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		
 		eststo: areg grant1_rate_next5  after_grant grant_t   i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next5  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next5  after_grant grant_t cum_ptapplied1 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		
 		eststo: areg grant1_rate_next6  after_grant grant_t   i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next6  after_grant grant_t  cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
 		eststo: areg grant1_rate_next6  after_grant grant_t cum_ptapplied1 cum_ptgranted1 i.year, absorb(姓名)  /* cluster(author_name) */ 
		

	}
	esttab, keep(after_grant ) ///
		star(* 0.10 ** 0.05 *** 0.01) se r2*/






