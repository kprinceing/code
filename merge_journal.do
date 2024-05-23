**************************************************************************************** 
//发表的期刊
/*  clear 
cd "F:\基金研究\data\2013--2022面青\scopusPub_New"
local files: dir "F:\基金研究\data\2013--2022面青\scopusPub_New" files "*.csv"
foreach file in `files'{
             clear
             import delimited `file'
  
             
    save `file'.dta, replace         
 } 
 //move to "F:\基金研究\data\2013--2022面青\scopusPub_New\dta"

cd "F:\基金研究\data\2013--2022面青\scopusPub_New\dta"
local files: dir "F:\基金研究\data\2013--2022面青\scopusPub_New\dta" files "*.dta"
clear
use "F:\基金研究\data\2013--2022面青\scopusPub_New\dta\BaiCaiquan.csv.dta", clear

foreach file in `files'{
             append using `file', force
 } 
//58668obs
save "F:\基金研究\data\2013--2022面青\scopusPub_New\dta\all_author_pubjournal.dta" 
move to 坚果云\基金研究\data\2013--2022面青文件夹里
 */


cd "/Users/yansong/Nutstore Files/基金研究/data/2013--2022面青"
*use all_author_pubjournal,clear 
use JCR2022.dta,clear
gen xx = proper(journal_name)
drop journal_name
rename xx journal_name 
save JCR2022.dta,replace


cd "/Users/yansong/Nutstore Files/基金研究/data/2013--2022面青"
use all_author_pubjournal.dta, clear
capture drop _merge
/* g pubyear=substr(coverdate,1,4)
tab pubyear
rename publicationname journal_name */


merge m:1 journal_name using "JCR2022.dta"
tab _merge
drop _merge 
save journal_quality.dta,replace


**********************************************************************
//摘出scopuspub青年数据里发表的杂志

use "基金研究\data\2013--2022面青\all_author_pubjournal.dta"
keep journal_name
bys journal_name: g dup = cond(_N==1,0,_n)
keep if dup==0|dup==1
drop dup
save "D:\基金研究\data\2013--2022面青\qn_scopus_journal_list.dta" 
export excel using "D:\基金研究\data\2013--2022面青\qn_scopus_journal_list.xls"















