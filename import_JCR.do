/*
clear
import excel "F:\基金研究\data\期刊分区\JCR-2022.-Q1-Q4-by-categories.xlsx", sheet("Sheet1") firstrow allstring
drop if journal_name==""
g q1=1 if strpos(category,"Q1")
g q2=1 if strpos(category,"Q2")
g q3=1 if strpos(category,"Q3")
g q4=1 if strpos(category,"Q4")
egen q=rowtotal(q1-q4)
tab q
rename * *_2022
rename journal_name_2022 journal_name
rename if_2022_2022 if_2022

replace journal_name=proper(journal_name)
save "F:\基金研究\data\期刊分区\JCR2022.dta", replace
*/

local project_path "/Users/yansong/Nutstore Files/基金研究/data"
local input_path "`project_path'/期刊分区"
local output_path "`project_path'/2013--2022面青"

cd "`input_path'"

clear
import excel "JCR-2022.-Q1-Q4-by-categories.xlsx", sheet("Sheet1") firstrow allstring
drop if journal_name==""
rename if_2022 IF
keep journal_name issn IF category
g year=2022

* 首字母大写杂志名称
gen xx = proper(journal_name)
drop journal_name
rename xx journal_name 

* 定义分区
gen journal_q = substr(category,-3,2)

gen journal_group = .
replace journal_group = 1 if  journal_q =="Q1"
replace journal_group = 2 if  journal_q =="Q2"
replace journal_group = 3 if  journal_q =="Q3"
replace journal_group = 4 if  journal_q =="Q4"
tab journal_group, gen(j_group)

cd "`output_path'"
save "JCR2022.dta", replace


******************************************************************************************************************************************
clear
import excel "F:\基金研究\data\期刊分区\JCR-2021.-Q1-Q4-by-categories.xlsx", sheet("Science citation index expanded") firstrow allstring
keep JournalName ISSN IF IFExcludingSelfCitations Quartiles 
rename JournalName journal_name
rename ISSN issn
rename IFExcludingSelfCitations if_noself
rename Quartiles category
save "F:\基金研究\data\期刊分区\JCR2021_scie.dta", replace

clear
import excel "F:\基金研究\data\期刊分区\JCR-2021.-Q1-Q4-by-categories.xlsx", sheet("Social science citation index") firstrow allstring
keep JournalName ISSN IF IFExcludingSelfCitations Quartiles 
rename JournalName journal_name
rename ISSN issn
rename IFExcludingSelfCitations if_noself
rename Quartiles category
save "F:\基金研究\data\期刊分区\JCR2021_ssci.dta", replace

use "F:\基金研究\data\期刊分区\JCR2021_ssci.dta"
append using "F:\基金研究\data\期刊分区\JCR2021_scie.dta"
g year=2021
replace journal_name=proper(journal_name)
tab year 
save "F:\基金研究\data\期刊分区\JCR2021.dta", replace

******************************************************************************************************************************************
foreach i of numlist 1/4{
import excel "F:\基金研究\data\期刊分区\JCR-2020.xls", sheet("JCR-Q`i'") firstrow allstring clear
keep FullJournalTitle ISSN JournalImpactFactor ImpactFactorwithoutJournalSe 
rename FullJournalTitle journal_name
rename ISSN issn
rename JournalImpactFactor IF
rename ImpactFactorwithoutJournalSe if_noself
g quartile="Q`i'"
g year=2020
replace journal_name=proper(journal_name)
save "F:\基金研究\data\期刊分区\JCR2020_Q`i'.dta", replace

}
use "F:\基金研究\data\期刊分区\JCR2020_Q1.dta"
foreach i of numlist 2/4{
append using "F:\基金研究\data\期刊分区\JCR2020_Q`i'.dta"
}
tab quartile
save "F:\基金研究\data\期刊分区\JCR2020.dta", replace

******************************************************************************************************************************************
foreach i of numlist 1/4{
import excel "F:\基金研究\data\期刊分区\JCR-2019.xls", sheet("JCR-Q`i'") firstrow allstring clear
keep FullJournalTitle ISSN JournalImpactFactor ImpactFactorwithoutJournalSe 
rename FullJournalTitle journal_name
rename ISSN issn
rename JournalImpactFactor IF
rename ImpactFactorwithoutJournalSe if_noself
g quartile="Q`i'"
g year=2019
replace journal_name=proper(journal_name)
save "F:\基金研究\data\期刊分区\JCR2019_Q`i'.dta",replace

}
use "F:\基金研究\data\期刊分区\JCR2019_Q1.dta"
foreach i of numlist 2/4{
append using "F:\基金研究\data\期刊分区\JCR2019_Q`i'.dta"
}
tab quartile
tab year
save "F:\基金研究\data\期刊分区\JCR2019.dta"


******************************************************************************************************************************************
foreach i of numlist 1/4{
import excel "F:\基金研究\data\期刊分区\JCR-2018.xls", sheet("JCR-Q`i'") firstrow allstring clear
keep FullJournalTitle ISSN IF ImpactFactorwithoutJournalSe 
rename FullJournalTitle journal_name
rename ISSN issn
rename ImpactFactorwithoutJournalSe if_noself
g quartile="Q`i'"
g year=2018
replace journal_name=proper(journal_name)
save "F:\基金研究\data\期刊分区\JCR2018_Q`i'.dta"

}
use "F:\基金研究\data\期刊分区\JCR2018_Q1.dta"
foreach i of numlist 2/4{
append using "F:\基金研究\data\期刊分区\JCR2018_Q`i'.dta"
}
tab quartile
tab year
save "F:\基金研究\data\期刊分区\JCR2018.dta"

******************************************************************************************************************************************
foreach i of numlist 1/4{
import excel "F:\基金研究\data\期刊分区\JCR-2017.xlsx", sheet("JCR-Q`i'") firstrow allstring clear
keep FullJournalTitle ISSN IF ImpactFactorwithoutJournalSe 
rename FullJournalTitle journal_name
rename ISSN issn
rename ImpactFactorwithoutJournalSe if_noself
g quartile="Q`i'"
g year=2017
replace journal_name=proper(journal_name)
save "F:\基金研究\data\期刊分区\JCR2017_Q`i'.dta"

}
use "F:\基金研究\data\期刊分区\JCR2017_Q1.dta"
foreach i of numlist 2/4{
append using "F:\基金研究\data\期刊分区\JCR2017_Q`i'.dta"
}
tab quartile
tab year
save "F:\基金研究\data\期刊分区\JCR2017.dta"
******************************************************************************************************************************************
foreach i of numlist 1/4{
import excel "F:\基金研究\data\期刊分区\JCR-2016.xlsx", sheet("JCR-Q`i'") firstrow allstring clear
keep FullJournalTitle ISSN IF ImpactFactorwithoutJournalSe 
rename FullJournalTitle journal_name
rename ISSN issn
rename ImpactFactorwithoutJournalSe if_noself
g quartile="Q`i'"
g year=2016
replace journal_name=proper(journal_name)
save "F:\基金研究\data\期刊分区\JCR2016_Q`i'.dta"

}
use "F:\基金研究\data\期刊分区\JCR2016_Q1.dta"
foreach i of numlist 2/4{
append using "F:\基金研究\data\期刊分区\JCR2016_Q`i'.dta"
}
tab quartile
tab year
save "F:\基金研究\data\期刊分区\JCR2016.dta"
******************************************************************************************************************************************
foreach i of numlist 1/4{
import excel "F:\基金研究\data\期刊分区\JCR-2015.xlsx", sheet("JCR-Q`i'") firstrow allstring clear
keep FullJournalTitle Issn IF  
rename FullJournalTitle journal_name
rename Issn issn
g quartile="Q`i'"
g year=2015
replace journal_name=proper(journal_name)
save "F:\基金研究\data\期刊分区\JCR2015_Q`i'.dta"

}
use "F:\基金研究\data\期刊分区\JCR2015_Q1.dta"
foreach i of numlist 2/4{
append using "F:\基金研究\data\期刊分区\JCR2015_Q`i'.dta"
}
tab quartile
tab year
save "F:\基金研究\data\期刊分区\JCR2015.dta"

******************************************************************************************************************************************
foreach i of numlist 1/4{
import excel "F:\基金研究\data\期刊分区\JCR-2014.xlsx", sheet("JCR-Q`i'") firstrow allstring clear
keep FullJournalTitle Issn IF  
rename FullJournalTitle journal_name
rename Issn issn
g quartile="Q`i'"
g year=2014
replace journal_name=proper(journal_name)
save "F:\基金研究\data\期刊分区\JCR2014_Q`i'.dta"

}
use "F:\基金研究\data\期刊分区\JCR2014_Q1.dta"
foreach i of numlist 2/4{
append using "F:\基金研究\data\期刊分区\JCR2014_Q`i'.dta"
}
tab quartile
tab year
save "F:\基金研究\data\期刊分区\JCR2014.dta"
******************************************************************************************************************************************
use "F:\基金研究\data\期刊分区\JCR2014.dta", clear
foreach i of numlist 2015/2022{
append using "F:\基金研究\data\期刊分区\JCR`i'.dta"
}
order journal_name year
sort journal_name year
tab year if quartile!=""  //2014-2020是quartile，2021-2022是category
tab year if category!=""  //2014-2020是quartile，2021-2022是category
tab year if if_noself!=""  //2016-2021有if without self-citation
//其他变量都是每年
foreach i of numlist 1/4{
g q`i'=1 if strpos(category,"Q`i'")|quartile=="Q`i'"
}
tab quartile if q1==1
//【ERROR】用category定义分区，一个杂志在不同学科下面可能定义成不用分区；但用quartile定义分区就一个杂志就只可能有一个分区
egen q=rowtotal(q1-q4)
tab q
tab year if q>1  //只有在用category定义分区的时候才有可能出现一本杂志属于多种分区
drop if journal_name==""
save "F:\基金研究\data\期刊分区\JCR2014-2022.dta"
sort journal_name year
drop q1_
bys journal_name: egen Q1=mean(q1)
tab Q1
bys journal_name: egen Q2=mean(q2)
bys journal_name: egen Q3=mean(q3)
bys journal_name: egen Q4=mean(q4)

gen byte notnumeric = real(IF)==. /*makes indicator for obs w/o numeric values*/
tab notnumeric /*==1 where nonnumeric characters*/
list IF if notnumeric==1 /*will show which have nonnumeric*/
replace IF="." if notnumeric==1
destring IF if_noself Q1 Q2 Q3 Q4, replace
collapse (mean) IF if_noself Q1 Q2 Q3 Q4, by(journal_name issn)
//24017本杂志
save "F:\基金研究\data\期刊分区\JCR2014-2022average.dta"
