/*clear
import excel "F:\基金研究\data\山东大学专利汇总（申请日为20130101至20221031期间）已修改.xlsx", sheet("Sheet1") firstrow
drop ttnames
egen ttnames=rowmiss(name1-name35)
g ttnames_=35-ttnames


clear
import excel "C:\Users\Administrator\Desktop\工作簿3.xlsx", sheet("Sheet1") firstrow allstring clear
reshape long name, i(order) j(number)
sort name order
g i=1
collapse (sum) tt=i, by(name)
*/

***专利申请与授予数据：包括申请成功和失败的***
local project_path "/Users/yansong/Dropbox/nutstore_files/基金研究"
import excel "`project_path'/data/山东大学专利汇总（申请日为20130101至20221031期间）已修改.xlsx", sheet("Sheet1") firstrow allstring clear


** 检查license是否重复
sort license
bys license: g dup = cond(_N==1,0,_n)
tab dup
/*       dup |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     14,592       70.42       70.42
          1 |      3,064       14.79       85.21
          2 |      3,064       14.79      100.00
------------+-----------------------------------
      Total |     20,720      100.00
*/

** 这里 grant_year 的missing value 是否可以从其他变量infer?
gen grant_year = substr(grant_date, 1, 4)
gen app_year = substr(app_date, 1, 4)


/* tab type if dup!=0
tab grant_year if dup!=0
tab app_year if dup!=0 */

* 这部分代码目的?
count if dup==1&strpos(license,"A")&strpos(license,"B")  //1488  同一个专利号分AB两个版本
count if dup==1&strpos(license,"A")&!strpos(license,"B")  //1216 同一个专利号出现两次
count if dup==1&!strpos(license,"A")&strpos(license,"B")  //0
count if dup==1&!strpos(license,"A")&!strpos(license,"B")  //360  均为实用新型与外观设计
count if type=="实用新型"|type=="外观设计"   //2716  实用新型与外观设计结尾为U和S
 
g lastletter=substr(license,-1,1)
tab lastletter
bys license lastletter: g dup2 = cond(_N==1,0,_n)  if dup!=0
tab dup2 //重复的专利号没有AB版本的分别
drop lastletter dup2


tab country  //multiple countries
/*若是申请国外专利，则申请人名字为英文*/
tab type
/*        type |      Freq.     Percent        Cum.
-------------+-----------------------------------
        发明 |     18,004       86.89       86.89
    外观设计 |         70        0.34       87.23
    实用新型 |      2,646       12.77      100.00
-------------+-----------------------------------
       Total |     20,720      100.00
*/
tab owner  //同一个专利可以多方联合持有

tab app_date
* g app_year=substr(app_date,1,4)
tab app_year
*g grant_year=substr(grant_date,1,4)
tab authorized if grant_year==""  //所有无授权日期的都是未授权的
tab authorized if grant_year!=""  //所有有授权日期的都是曾经授权的
//通过是否有授权日期确定该专利申请是否获得授权


** 这里目的是? 如果不需要的话可以删除或者标注掉
g shouquan1=1 if authorized=="是"
g shouquan2=1 if grant_date!=""
count if shouquan1!=shouquan2
g shouquan3=1 if strpos(license,"B")
drop shouquan1 shouquan2 shouquan3


****************************************
/*生成数据为每人名+每申请年申请的三种类型专利数量，及最终获得授权的专利数量*/
//takeing the same name as the same person

//assumption: prob of having the same name is independent from the prob of patent application？ 这句什么意思

drop if dup==2  //删除重复录入的专利

keep order license app_year grant_year type name1-name35
reshape long name, i(order) j(n)
order name, last
drop if name==""
sort name app_year grant_year
tab grant_year

* 这里replace的值是给没有授权的专利?
replace grant_year="9999" if grant_year=="" 
sort name license

g i=1

gen year = 



* 这里为何要 reshape, collapse, 再reshape? 能否简洁表达? 
original code
* 目的: 
collapse (sum)  number=i, by(name app_year type grant_year)
order name app_year type grant_year
reshape wide number, i(name app_year type) j(grant_year) string


* ??
egen tt_applied=rowtotal(number2013-number9999)
egen tt_granted=rowtotal(number2013-number2022)
drop number*

tab type
replace type="1" if type=="发明"
replace type="2" if type=="外观设计"
replace type="3" if type=="实用新型"

reshape wide tt_applied tt_granted, i(name app_year) j(type) string
count if tt_applied1==.
count if tt_granted1==.

/*
drop dup
bys name app_year: g dup = cond(_N==1,0,_n)
tab dup
*/

rename name 申请人
rename app_year year
destring year, replace
tab year


bys 申请人 year: g dup = cond(_N==1,0,_n)
tab dup  //no repeat time within panel
rename 申请人 姓名
rename year 年份
drop dup 

save "`project_path'/data/patent2013-2022.dta", replace














