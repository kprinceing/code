 ****** Macbook path *local project_path "/Users/yansong/Nutstore Files/基金研究"****** iMac pathlocal project_path "/Users/yansong/Dropbox/nutstore_files/基金研究"cd "`project_path'/data/2013_2022面青"clearimport delimited "qn_reg_type1.csv", encoding(UTF-8)save qn_reg_type1.dta,replaceclearimport delimited "qn_reg_type1_coded.csv", encoding(UTF-8)save qn_reg_type1_coded.dta,replaceclearimport delimited "qn_reg_type2.csv", encoding(UTF-8)save qn_reg_type2.dta,replaceclearimport delimited "qn_reg_type3.csv", encoding(UTF-8)save qn_reg_type3.dta,replace***************************************************************************************************************************  Regressions without sentimentlocal project_path "/Users/yansong/Dropbox/nutstore_files/基金研究"cd "`project_path'/data/2013_2022面青"set more offuse qn_reg_type1.dta,clear 	egen id = group(申请人 申请部门)	tab id if _merge=="left_only"  //all missing 	drop if id == .	xtset id year	sort id year	by id: gen pub_lag1 = author_eid[_n-1]	by id: gen pub_lag2 = author_eid[_n-2]	by id: gen pub_lead1 = author_eid[_n+1]	by id: gen pub_lead2 = author_eid[_n+2]	by id: gen pub_lead3 = author_eid[_n+3]	by id: gen pub_lead4 = author_eid[_n+4]	by id: gen pub_lead5 = author_eid[_n+5]	by id: gen pub_lead6 = author_eid[_n+6]	gen pub_next2 = pub_lead1+pub_lead2	gen pub_next3 = pub_lead1+pub_lead2+pub_lead3	gen pub_next4 = pub_lead1+pub_lead2+pub_lead3+pub_lead4	gen pub_next5 = pub_lead1+pub_lead2+pub_lead3+pub_lead4+pub_lead5	gen pub_next6 = pub_lead1+pub_lead2+pub_lead3+pub_lead4+pub_lead5+pub_lead6	bysort id (year) : gen cum_pubs = sum(pub_lag1)********************************** Impacts on publications (per year)	local y author_eid pub_lead1 pub_lead2 pub_lead3 pub_lead4 pub_lead5 pub_lead6 	foreach i of varlist `y' {		estimates clear		quietly{			eststo: reg  `i'  after_grant /* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */			eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)  /* cluster(author_name) */ 		}		esttab, keep(after_grant ) ///			star(* 0.10 ** 0.05 *** 0.01) se r2	}* Impacts on publications (per year) plot	estimates clear	local y author_eid pub_lead1 pub_lead2 pub_lead3 pub_lead4 pub_lead5 pub_lead6 	foreach i of varlist `y' {		quietly{	/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */	 */		eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)  /* cluster(author_name) */ 		}		}	esttab, keep(after_grant ) ///			star(* 0.10 ** 0.05 *** 0.01) se r2	coefplot est*, keep(after_grant) ///			levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///		label(6 "Year 3") label(8 "Year 4") label(10 "Year 5"))		********************************** Impacts on publications (cumulative sum)	local y author_eid pub_next2 pub_next3 pub_next4 pub_next5 pub_next6 	foreach i of varlist `y' {		estimates clear		quietly{			eststo: reg  `i'  after_grant /* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */			eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)  /* cluster(author_name) */ 		}		esttab, keep(after_grant ) ///			star(* 0.10 ** 0.05 *** 0.01) se r2	}********************************** Impacts on publications (cumulative sum) plot	estimates clear	local y author_eid pub_next2 pub_next3 pub_next4 pub_next5 	foreach i of varlist `y' {		quietly{	/* 		eststo: reg  `i'  after_grant /* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t/* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t cum_pubs /* cluster(申请部门) */			eststo: reg  `i'  after_grant grant_t cum_pubs i.year /* cluster(申请部门) */	 */		eststo: areg  `i' after_grant grant_t cum_pubs i.year, absorb(author_name)  /* cluster(author_name) */ 		}		esttab, keep(after_grant ) ///			star(* 0.10 ** 0.05 *** 0.01) se r2	}	grstyle init 	grstyle set horizontal // set tick labels horizontal	grstyle set compact // overall design compact	grstyle set size small: subheading axis_title // subtitle and axis title set to small	grstyle set size vsmall: small_body // margin around notes	grstyle set legend 6, nobox //legend position on 6 o'clock, removes box	grstyle set linewidth thin: major_grid // set grid line thickness to thin	grstyle set linewidth thin: tick // set tick thickness to thin	grstyle set linewidth thin: axisline // set axislines thickness to thin	grstyle set linewidth vthin: xyline // reference line at 0	grstyle set color economist, order(10 1 8 2 3 4 5 6 7 9 11 12 13 14 15)	grstyle color background white // set overall background to white	grstyle set color black*.7: tick tick_label // set tick and tick label color	/* coefplot est*, keep(after_grant)	///		xtitle("Cumulative publications") ///		levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///		label(6 "Year 3") label(8 "Year 4") label(10 "Year 5"))	 */	coefplot est*, keep(after_grant)	///		xtitle("论文累计发表数量") ///		coeflabels(after_grant = "基金资助后") ///		levels(95) legend(label(2 "前一年") label(4 "前二年") ///		label(6 "前三年") label(8 "前四年") label(10 "前五年"))				graph export "`project_path'/graph_updated/OLS_main.png", ///		width(600)height(450) replace	********************************************************************************************  by 学部 regressionslocal project_path "/Users/yansong/Dropbox/nutstore_files/基金研究"cd "`project_path'/data/2013_2022面青"set more offuse qn_reg_type1_coded.dta,clear 	egen id = group(申请人 申请部门)	drop if id == .	duplicates drop id year, force	xtset id year	sort id year	by id: gen pub_lag1 = author_eid[_n-1]	by id: gen pub_lag2 = author_eid[_n-2]	by id: gen pub_lead1 = author_eid[_n+1]	by id: gen pub_lead2 = author_eid[_n+2]	by id: gen pub_lead3 = author_eid[_n+3]	by id: gen pub_lead4 = author_eid[_n+4]	by id: gen pub_lead5 = author_eid[_n+5]	by id: gen pub_lead6 = author_eid[_n+6]	gen pub_next2 = pub_lead1+pub_lead2	gen pub_next3 = pub_lead1+pub_lead2+pub_lead3	gen pub_next4 = pub_lead1+pub_lead2+pub_lead3+pub_lead4	gen pub_next5 = pub_lead1+pub_lead2+pub_lead3+pub_lead4+pub_lead5	bysort id (year) : gen cum_pubs = sum(pub_lag1)*********************************************	* Impacts on publications by research area 	/* A.数理科学部 B.化学科学部 C.生命科学部 D.地球科学部	   E.工程与材料科学部 F.信息科学部 G.管理科学部 */	local y  author_eid pub_next2  pub_next3 pub_next4 pub_next5	foreach i of varlist `y' {		estimates clear		local code A B C D E F G 		foreach n_code of local code { 			display("`n_code'")			quietly: eststo: areg  `i' after_grant  ///			grant_t cum_pubs i.year, absorb(author_name) ///			,if  nsfc_code == "`n_code'"				}		esttab, keep(after_grant ) ///		star(* 0.10 ** 0.05 *** 0.01) se r2	}  *table nsfc_code, c(mean pub_next2) format(%9.3f)********************************************** Impacts on publications by research area  (plot)	/* A.数理科学部 B.化学科学部 C.生命科学部 D.地球科学部	   E.工程与材料科学部 F.信息科学部 G.管理科学部 */	estimates clear	local y  author_eid pub_next2  pub_next3 pub_next4 pub_next5	local counter = 0 	foreach i of varlist `y' {		local code A B C D E F G 		foreach n_code of local code { 			display("`n_code'")			quietly:  areg  `i' after_grant  ///			grant_t cum_pubs i.year, absorb(author_name) ///			,if  nsfc_code == "`n_code'"				local est_name = "`n_code'" + "`counter'"			estimates store `est_name'			local counter = `counter' +1			}	}  	grstyle init 	grstyle set horizontal // set tick labels horizontal	grstyle set compact // overall design compact	grstyle set size small: subheading axis_title // subtitle and axis title set to small	grstyle set size vsmall: small_body // margin around notes	grstyle set legend 6, nobox //legend position on 6 o'clock, removes box	grstyle set linewidth thin: major_grid // set grid line thickness to thin	grstyle set linewidth thin: tick // set tick thickness to thin	grstyle set linewidth thin: axisline // set axislines thickness to thin	grstyle set linewidth vthin: xyline // reference line at 0	grstyle set color economist, order(10 1 8 2 3 4 5 6 7 9 11 12 13 14 15)	grstyle color background white // set overall background to white	grstyle set color black*.7: tick tick_label // set tick and tick label color	/* grstyle set color black*.08: plotregion plotregion_line //set plot area background	color	grstyle set color White: axisline major_grid // set axis and grid line color	grstyle set color black*.7: small_body // set note color	grstyle set color white*.08, opacity(0): pbarline // graph bar outline transparent	 */		coefplot A*, bylabel(数学) || B*, bylabel(化学) || ///				 C*, bylabel(生命科学) || D* , bylabel(地球科学) || ///				 E*, bylabel(工程与材料) || F*, bylabel(信息科学) || ///				 G*, bylabel(管理科学) ||, ///				 xtitle("论文累计发表数量") ///				 levels(95) keep(after_grant) ///			 	 coeflabels(after_grant = "基金资助后") ///				 legend(label(2 "前一年") label(4 "前二年") ///				 label(6 "前三年") label(8 "前四年") label(10 "前五年"))			graph export "`project_path'/graph_updated/OLS_by_field.png", ///		width(600)height(450) replace************************************************ Impacts on number of coauthors	table nsfc_code, c(mean coauthors) format(%9.3f)	table nsfc_code, c(mean unique_coauthors) format(%9.3f)	local y  unique_coauthors	preserve 	drop if coauthors>=14	estimates clear	foreach i of varlist `y' {		local code A B C D E F G 		foreach n_code of local code { 			display("`n_code'")			quietly: eststo: areg  `i' after_grant  ///			grant_t cum_pubs i.year, absorb(author_name)  		 ///			, if  nsfc_code == "`n_code'"		}		esttab, keep(after_grant ) ///		star(* 0.10 ** 0.05 *** 0.01) se r2	}  	restore	/* coefplot est*, levels(95) keep(after_grant) ///	xtitle("Number of coauthors per year") ///	legend(label(2 "Math") label(4 "Chem") ///				 label(6 "Life Sci") label(8 "Geo Sci") label(10 "Engineering") ///				label(12 "Info Sci") label(14 "Management"))  */	coefplot est*, levels(95) keep(after_grant) ///		xtitle("每年合作者人数") ///		coeflabels(after_grant = "基金资助后") ///		legend(label(2 "数理") label(4 "化学") ///		 label(6 "生命科学") label(8 "地球科学") label(10 "工程与材料") ///				label(12 "信息科学") label(14 "管理科学")) 				graph export "`project_path'/graph_updated/OLS_coauthors.png", ///		width(600)height(450) replace**********************************************************************************************local project_path "/Users/yansong/Dropbox/nutstore_files/基金研究"cd "`project_path'/data/2013_2022面青"* Regressions with sentimentset more offuse qn_reg_type2.dta,clear 	egen id = group(申请人 申请部门)	drop if id == .	xtset id year 	sort id year	by id: gen pub_lag1 = author_eid[_n-1]	bysort id (year) : gen cum_pubs = sum(pub_lag1)	drop below_cutoff	gen below_cutoff = senti<0.5**************** Rolling sum with 1-5 periods*****************estimates clear*local y rolling_sum rolling_sum3 rolling_sum4 rolling_sum5estimates clearset matsize 2000local y author_eid rolling_sum rolling_sum3 rolling_sum4 rolling_sum5 /* citations */foreach i of varlist `y' {		*eststo: areg `i' after_grant  i.year, absorb(author_name) 	*eststo: areg `i' after_grant cum_pubs i.year , absorb(author_name) 	*eststo: areg `i' after_grant cum_pubs i.year if senti!=., absorb(author_name) 	*eststo: areg `i' after_grant cum_pubs  senti senti_squared i.year, absorb(author_name) 	quietly : eststo: ivregress 2sls  `i' cum_pubs grant_t i.year i.id ///	(after_grant = senti senti_squared below_cutoff), first	*eststo: xtivreg `i'  i.year (after_grant = senti senti_squared ), fe}esttab, keep(after_grant /*   senti senti_squared */) ///	star(* 0.10 ** 0.05 *** 0.01) se r2 /* coefplot est*, keep(after_grant)	///	xtitle("Cumulative publications") ///	levels(95) legend(label(2 "Year 1") label(4 "Year 2") ///	label(6 "Year 3") label(8 "Year 4") label(10 "Year 5"))	 */coefplot est*, keep(after_grant)	///	xtitle("累计论文发表数量") ///	levels(95) coeflabels(after_grant = "基金资助后") ///	legend(label(2 "前一年") label(4 "前二年") ///	label(6 "前三年") label(8 "前四年") label(10 "前五年"))	graph export "`project_path'/graph_updated/IV_main.png", ///	width(600)height(450) replace*reg after_grant cum_pubs senti senti_squared below_cutoff i.year**************** Citations ****************quietly: eststo: ivregress 2sls citations cum_pubs grant_t i.year i.id ///	(after_grant = senti senti_squared below_cutoff), firstesttab, keep(after_grant /*   senti senti_squared */) ///	star(* 0.10 ** 0.05 *** 0.01) se r2 	*********************************************************************************************** Regressions with journal quality local project_path "/Users/yansong/Dropbox/nutstore_files/基金研究"cd "`project_path'/data/2013_2022面青"set more offuse qn_reg_type3.dta,clear 	gen after_grant = year>立项年份	gen grant_t  = year-立项年份	gen other =  counter - j_group1 - j_group2 - j_group3 - j_group4	egen id = group(申请人 申请部门)	drop if id == .	duplicates drop id year, force	xtset id year	sort id year*********************************************************************************************** Publications in Q1-Q4estimates clearlocal index counter j_group1 j_group2 j_group3 j_group4 otherforeach i of local index {	preserve 	by id: gen pub_lag1 = `i'[_n-1]	by id: gen pub_lag2 = `i'[_n-2]	by id: gen pub_lead1 = `i'[_n+1]	by id: gen pub_lead2 = `i'[_n+2]	by id: gen pub_lead3 = `i'[_n+3]	by id: gen pub_lead4 = `i'[_n+4]	by id: gen pub_lead5 = `i'[_n+5]	by id: gen pub_lead6 = `i'[_n+6]	gen pub_next2 = pub_lead1+pub_lead2	gen pub_next3 = pub_lead1+pub_lead2+pub_lead3	gen pub_next4 = pub_lead1+pub_lead2+pub_lead3+pub_lead4	gen pub_next5 = pub_lead1+pub_lead2+pub_lead3+pub_lead4+pub_lead5	gen pub_next6 = pub_lead1+pub_lead2+pub_lead3+pub_lead4+pub_lead5+pub_lead6	bysort id (year) : gen cum_pubs = sum(pub_lag1)	*********************************	* Impacts on publications (per year)	local y pub_next2	foreach i of varlist `y' {		quietly{			eststo: areg  `i' after_grant grant_t cum_pubs i.year, ///							  absorb(author_name)  /* cluster(author_name) */ 		}	}	restore}	esttab, keep(after_grant ) star(* 0.10 ** 0.05 *** 0.01) se r2	/* coefplot est*, keep(after_grant)	///	xtitle("Cumulative publications two years after funded") ///	levels(95) legend(label(2 "Total") label(4 "JCR Q1") ///	label(6 "JCR Q2") label(8 "JCR Q3") label(10 "JCR Q4") label(12 "Not in JCR")   ) */	coefplot est*, keep(after_grant)	///	xtitle("基金资助后两年内论文发表数量") ///	coeflabels(after_grant = "基金资助后") ///	levels(95) legend(label(2 "总数") label(4 "JCR Q1") ///	label(6 "JCR Q2") label(8 "JCR Q3") label(10 "JCR Q4") label(12 "未被JCR收录")   )		graph export "`project_path'/graph_updated/OLS_JCR.png", ///	width(600)height(450) replace