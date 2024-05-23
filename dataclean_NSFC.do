防误触快捷键
*NSFC2013-2022申请与立项合并删除了524个不在申请信息里的立项数据
*NSFC2013-2022申请数据删掉了7个项目类别！=资助类别的数据
*NSFC-QN 删除了161个有重名的数据
*
*----------------------------------------------------------------------------------------------------*
/*【导入NSFC申请数据】*/
foreach i of numlist 2013/2022{
import excel "F:\基金研究\data\2013--2022面青\stata\y`i'.xlsx", sheet("申请") firstrow clear 
g year=`i'
save "F:\基金研究\data\2013--2022面青\stata\y`i'_application.dta", replace
}

use "F:\基金研究\data\2013--2022面青\stata\y2013_application.dta", clear
foreach i of numlist 2014/2022{
append using "F:\基金研究\data\2013--2022面青\stata\y`i'_application.dta"
rename year 申请年份
}
tab 申请单位 //均为山大
tab 依托单位 //均为山大
drop 申请单位 依托单位

count if 姓名!=申请人 //29个：姓名和申请人是一样的，但是stata把他们识别成不一样的。这些都是英文的，有三个是拼音
drop 申请人

tab 申请年份 if 申请部门=="" //13、14年缺失申请部门的特别多
count if 申请部门!=院系所
tab 申请年份 if 申请部门!=院系所&院系所!="" //2022年有41个院系所！=申请部分的
rename 申请部门 申请部门1
g 申请部门=申请部门1
replace 申请部门=院系所 if 申请部门==""&院系所!=""
rename 院系所 申请院系所


count if 项目类型!=资助类别 //有八个人的项目类型和资助类别不一样， which is odd

count if 项目名称!=项目名称2&项目名称!=""&项目名称2!="" //180个不同。按道理同一年的本子两个名字不应该不同


order 姓名 申请年份 项目名称 资助类别 申请部门
sort 姓名 申请年份 项目名称

bys 姓名: g dup = cond(_N==1,0,_n)
bys 姓名: egen dup1=min(dup)  //==1 代表这个名词出现次数多于一次
bys 姓名: g school=1 if 申请部门[_n]!=申请部门[_n+1]&姓名[_n]==姓名[_n+1]
bys 姓名: egen school1=max(school)  //==1代表同一个名字对应的申请部门不同，包括因为缺失而造成的不同
replace school1=0 if school1==.
count if school1==1&dup1==1 //2125代表有重复名字出现且对应多个申请部门
tab dup if school1==1&dup1==1  //有499个unique name存在同一个名字对应不用部门
count if dup==0|dup==1  //一共有3274unique name
//正常的状态是（1）没有重复名字出现，dup1==0;(2) 有重复名字出现，但是对应相同部门dup==1&school1==0
tab dup1 school1
/*
           |        school1
      dup1 |         0          1 |     Total
-----------+----------------------+----------
         0 |     1,267          0 |     1,267 
         1 |     4,504      2,125 |     6,629 
-----------+----------------------+----------
     Total |     5,771      2,125 |     7,896 

*/
//school1==1&dup1==1也不全是有误的，只要同一个名字对应的申请部门没有缺失，就没有误差
order 姓名 申请部门 dup1 school1
bys 姓名: g error=1 if school1==1&dup1==1&申请部门==""
bys 姓名: egen error1=max(error)
replace error1=0 if error1==.
count if school1==1&dup1==1&error1==1 //1824个同一名字对应不同申请部门且申请部门有确实信息的

drop dup school error
rename 金额 申请经费万元
rename 项目起止年月 申请项目起止年月
rename 反馈评议意见 申请反馈评议意见
g 年份=申请年份

save "F:\基金研究\data\2013--2022面青\stata\application2013-2022.dta", replace


*----------------------------------------------------------------------------------------------------*
/*【导入NSFC立项数据】*/
foreach i of numlist 2013/2020{
import excel "F:\基金研究\data\2013--2022面青\stata\y`i'.xlsx", sheet("立项") firstrow clear 
g year=`i'
save "F:\基金研究\data\2013--2022面青\stata\y`i'_funded.dta", replace
}


foreach i of numlist 2021{
import excel "F:\基金研究\data\2013--2022面青\stata\y`i'.xlsx", sheet("立项") firstrow clear 
g year=`i'
tostring 批准经费万元, replace
save "F:\基金研究\data\2013--2022面青\stata\y`i'_funded.dta", replace
}

foreach i of numlist 2022{
import excel "F:\基金研究\data\2013--2022面青\stata\y2022.xlsx", sheet("立项") firstrow allstring clear
g year=`i'
save "F:\基金研究\data\2013--2022面青\stata\y`i'_funded.dta", replace
}


use "F:\基金研究\data\2013--2022面青\stata\y2013_funded.dta", clear
foreach i of numlist 2014/2022{
append using "F:\基金研究\data\2013--2022面青\stata\y`i'_funded.dta"

}
rename year 获得立项年份
order 姓名 项目名称 资助类别 申请代码
tab 依托单位 //均为山大
drop 依托单位

tab 开始日期
tab 结题日期
replace 项目起止年月="2023-01/2023-12" if 申请年份==2022&strpos(结题日期,"2023")
replace 项目起止年月="2023-01/2024-12" if 申请年份==2022&strpos(结题日期,"2024")
replace 项目起止年月="2023-01/2025-12" if 申请年份==2022&strpos(结题日期,"2025")
replace 项目起止年月="2023-01/2026-12" if 申请年份==2022&strpos(结题日期,"2026")
drop 开始日期 结题日期

g 年份=获得立项年份
save "F:\基金研究\data\2013--2022面青\stata\funded2013-2022.dta", replace
use "F:\基金研究\data\2013--2022面青\stata\funded2013-2022.dta", clear
//姓名 项目名称 资助类别 申请代码 年份
//批准经费万元 项目起止年月 反馈评议意见 获得立项年份 院系所
//2593个立项
bys 姓名 项目名称: g dup = cond(_N==1,0,_n)
tab dup  //每一个项目立项都是unique的
drop dup
keep 姓名 项目名称 年份 反馈评议意见 资助类别 申请代码 项目起止年月
count if 反馈评议意见==""  //471 这些都是立项数据里没有反馈意见的，原始数据的录入为N/A
g 无评审意见=1 if 反馈评议意见==""
replace 无评审意见=0 if 反馈评议意见!=""
tab 无评审意见
drop 无评审意见
rename 反馈评议意见 立项反馈评议意见
rename 项目起止年月 立项项目起止年月
rename 申请代码 立项申请代码
rename 资助类别 立项资助类别
save "F:\基金研究\data\2013--2022面青\stata\funded2013-2022-(1).dta", replace


*----------------------------------------------------------------------------------------------------*
/*【合并青年项目评分与面上项目评分】*/
use "F:\基金研究\data\2013--2022面青\stata\ms_senti.dta", clear
append using "F:\基金研究\data\2013--2022面青\stata\qn_senti.dta"
//2014-2020
bys 姓名 项目名称 年份: g xx= cond(_N==1,0,_n)
tab xx
tab 姓名 if xx!=0
drop if xx!=0
drop xx

save "F:\基金研究\data\2013--2022面青\stata\all_senti.dta", replace


*----------------------------------------------------------------------------------------------------*
/*
use "F:\基金研究\data\2013--2022面青\stata\application2013-2022.dta", clear
bys 姓名 项目名称 年份: g xx= cond(_N==1,0,_n)
tab xx
tab 姓名 if xx!=0
preserve
keep if xx!=0&资助类别!=项目类型
save "F:\基金研究\data\2013--2022面青\stata\application2013-2022-dropped(1).dta", replace
//完整的“申请数据”用主数据append dropped(1)
restore 
drop if xx!=0&资助类别!=项目类型
drop xx
merge 1:1 姓名 项目名称 年份  using "F:\基金研究\data\2013--2022面青\stata\funded2013-2022-(1).dta"
/*
   Result                           # of obs.
    -----------------------------------------
    not matched                         6,360
        from master                     5,828  (_merge==1)
        from using                        532  (_merge==2)  //随便搜了几个姓名+项目名称，都在masterfile里

    matched                             2,061  (_merge==3)
    -----------------------------------------
*/
tab _merge if 无评审意见==1  //立项数据里所有没有反馈意见的人都不在申请数据中
tab 年份 if 无评审意见==1  
tab 年份 if _merge==2

sort 姓名 项目名称 年份
//手动搜索该姓名-项目名称-年份是否获得立项
bys 姓名: g usingonly=1 if _merge==2
bys 姓名: egen useonly=max(usingonly)

count if _merge==2&无评审意见==0
count if useonly==1&无评审意见==0
*/
/*-----------------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------------------*/
/*【NSFC申请数据->合并senti数据+立项数据】*/
use "F:\基金研究\data\2013--2022面青\stata\application2013-2022.dta", clear
bys 姓名 项目名称 年份: g xx= cond(_N==1,0,_n)
tab xx
/*
        xx |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      7,882       99.82       99.82
          1 |          7        0.09       99.91
          2 |          7        0.09      100.00
------------+-----------------------------------
      Total |      7,896      100.00
*/
tab 姓名 if xx!=0
drop xx

bys 姓名 申请部门: g xx= cond(_N==1,0,_n)  //检查英文或者拼音录入的同名是不是被系统认定成同名，有一些因为原始文件输入时有格式或者字体差别，stata会无法识别相同的名字
/*【计划】合并之后检查问题，更正姓名误差，然后删除_merge==2,在重新匹配*/
// ALEXANDER DEGELING在申请数据里有两个四个录入，但是在算dup的时候有一个名字没有被算进去
replace 姓名="ALEXANDER DEGELING" if 姓名=="ALEXANDER DEGELING"  
replace 姓名="LIU YI" if 姓名=="LIU YI"
replace 姓名="Timo Pitknen" if 姓名=="Timo Pitknen"
replace 姓名="Tsona Tchinda Narcisse" if 姓名=="Tsona Tchinda Narcisse"   //改成using data里的名字
//以上这几个名字出现了多次，一模一样的，但是有一个名字和另外几个个没算在一起
replace 姓名="Abdelwahid MELLOUKI" if 姓名=="Abdelwahid MELLOUKI"   //改成using data里的名字
replace 姓名="Bagrat Mailyan" if 姓名=="Bagrat Mailyan"   //改成using data里的名字
replace 姓名="Hartmut Günter Dr. Herrmann" if 姓名=="Hartmut Günter Dr. Herrmann"   //改成using data里的名字
replace 姓名="Jeongwoo Lee" if 姓名=="Jeongwoo Lee"   //改成using data里的名字
replace 姓名="Motoharu Nowada" if 姓名=="Motoharu Nowada"   //改成using data里的名字
replace 姓名="Rolf Müller" if 姓名=="Rolf Müller"  
replace 姓名="Tsona Tchinda Narcisse" if 姓名=="Tsona Tchinda Narcisse"   //改成using data里的名字
drop xx
bys 姓名 申请部门: g xx= cond(_N==1,0,_n)  
drop xx


bys 姓名 项目名称 年份: g xx= cond(_N==1,0,_n)
tab xx
tab 姓名 if xx!=0 &资助类别!=项目类型
/*
preserve
keep if xx!=0&资助类别!=项目类型
save "F:\基金研究\data\2013--2022面青\stata\application2013-2022-dropped(1).dta", replace
//完整的“申请数据”用主数据append dropped(1)
restore 
*/
drop if xx!=0&资助类别!=项目类型  //删掉了7个
drop xx

/*【NSFC申请数据 合并 senti数据】*/
merge 1:1 姓名 项目名称 年份  using "F:\基金研究\data\2013--2022面青\stata\all_senti.dta"
/*    Result                           # of obs.
    -----------------------------------------
    not matched                         3,032
        from master                     3,032  (_merge==1)
        from using                          0  (_merge==2)

    matched                             4,857  (_merge==3)
    -----------------------------------------

*/
 tab 年份 if _merge==1
/*
       年份 |      Freq.     Percent        Cum.
------------+-----------------------------------
       2013 |        621       20.48       20.48
	   count if 年份==2013
       2014 |          5        0.16       20.65
       2015 |         10        0.33       20.98
       2016 |         15        0.49       21.47
       2017 |          4        0.13       21.60
       2018 |          8        0.26       21.87
       2019 |          4        0.13       22.00
       2020 |          3        0.10       22.10
       2021 |      1,176       38.79       60.88
       2022 |      1,186       39.12      100.00
------------+-----------------------------------
      Total |      3,032      100.00
*/


tab 姓名 if _merge==1&年份>2013&年份<2021
rename _merge _merge_senti

/*【NSFC申请数据+senti数据 合并 NSFC立项数据】*/
merge 1:1 姓名 项目名称 年份  using "F:\基金研究\data\2013--2022面青\stata\funded2013-2022-(1).dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         6,344
        from master                     5,820  (_merge==1)
        from using                        524  (_merge==2)

    matched                             2,069  (_merge==3)
    -----------------------------------------
preserve
keep if _merge==2
keep 姓名 项目名称 年份 立项资助类别 立项申请代码 立项项目起止年月 立项反馈评议意见 _merge
save "F:\基金研究\data\2013--2022面青\stata\funded_not_in_application.dta"
restore	
*/

drop if _merge==2   //有524个人在立项数据里，但不在申请数据里
/*
replace 申请年份=年份 if _merge==2
replace 资助类别=立项资助类别 if _merge==2
replace 申请代码=立项申请代码 if _merge==2
*/
rename _merge _merge_lixiang

g lixiang=1 if _merge_lixiang==3
replace lixiang=0 if _merge_lixiang==1
destring 立项,replace
count if 立项!=lixiang&立项!=.
tab 立项 if 立项!=lixiang
//有一个立项==1但是是masteronly，sentiment数据里有处理错误
g i=1

g 代码1=substr(申请代码,1,1)
g 代码2=substr(申请代码,1,3)
tab 代码1
tab 代码2

g 代码3="数学" if 代码1=="A"
replace 代码3="化学" if 代码1=="B"
replace 代码3="生命" if 代码1=="C"
replace 代码3="地球" if 代码1=="D"
replace 代码3="工程材料" if 代码1=="E"
replace 代码3="信息" if 代码1=="F"
replace 代码3="管理" if 代码1=="G"
replace 代码3="医学" if 代码1=="H"

/*line 207*/

count if 资助类别==""
count if 代码1==""

save "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022.dta", replace

*----------------------------------------------------------------------------------------------------*
/*【补上缺失的申请部门】】*/
clear
//sdq办公室
cd "F:\基金研究\data\2013--2022面青\stata"
//sdq家
cd "E:\坚果云\基金研究\data\2013--2022面青\stata"
//笔记本
cd "D:\基金研究\data\2013--2022面青\stata"

use "NSFC2013-2022.dta", clear
cd "F:\基金研究\code"
cd "E:\坚果云\基金研究\code"
cd "D:\基金研究\code"
run 处理NSFC申请部门问题.do
/*
preserve
collapse (sum) tt=i, by(申请部门估)
//对申请单位为实验室、研究所、研究中心、研究院的人进行再一次筛查，有些人既在正常系所，也在实验室
tab 申请部门估
restore 
*/

egen id = group(姓名 申请部门估)  //59missing, 因为没有申请部门信息  
bys id 年份: g dup = cond(_N==1,0,_n)  //repeated time values within panel, 这里的id没有更正申请部门估==missing的观测值
bys id 年份: egen numapp_peryear=max(dup)
replace numapp_peryear=.  if id==.
tab numapp_peryear  //有48人同年申请两次，有的是同类型项目，有的是青年和面上
drop dup numapp_peryear

bys id: g dup = cond(_N==1,0,_n) 
bys id: egen numapp_tt=max(dup)
replace numapp_tt=. if id==.
tab numapp_tt  //17%的人只申请过一次，大部分都是会重复申请的
drop dup numapp_tt



merge 1:1 项目名称 年份 using "E:\坚果云\基金研究\data\2013--2022面青\nsfc_py.dta"  
/*
 Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             7,889  (_merge==3)
    -----------------------------------------
*/
//NSFC中有七组重复两次的申请，应该是同一年即申请了青年也申请了面上，master file重复的这些已经删除了
drop 项目名称raw _merge 
save "NSFC2013-2022.dta", replace


*----------------------------------------------------------------------------------------------------*
**#
/*【拆分成QN和MS:因为有51个人他们在同一年即申请了青年又申请了面上，年份重复导致无法与其他数据一对一合并】*/
use "NSFC2013-2022.dta", clear
tab 资助类别
/*
                资助类别 |      Freq.     Percent        Cum.
-------------------------+-----------------------------------
        青年科学基金项目 |      3,135       39.74       39.74
                面上项目 |      4,754       60.26      100.00
-------------------------+-----------------------------------
                   Total |      7,889      100.00
*/
preserve
keep if 资助类别=="青年科学基金项目"  //有八组资助类别和项目类型不一样，如果用项目类型来筛可能会有几个obs不一样
save "NSFC2013-2022-QN.dta", replace
restore

/*
preserve
keep if 资助类别=="青年科学基金项目"  
save "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022-QN2.dta"  //用来test SY的合并
restore
*/

preserve
keep if 资助类别=="面上项目"
save "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022-MS.dta", replace
restore




*----------------------------------------------------------------------------------------------------*
/*【NSFC2013-2022-MS.dta,删除重名的人，变成balanced panel data，合并专利数据】*/
。。。



























/*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/
/* old old code
use "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022.dta"
collapse (sum) number=i, by(年份 资助类别 lixiang) 
reshape wide number, i(年份 资助类别) j(lixiang)
rename number0 fail
rename number1 funded
g total= fail+funded
g rfund=funded/total
sort 资助类别  年份 
bys 资助类别: g tot_growth=(total[_n]-total[_n-1])/total[_n-1]
sum total if 资助类别=="青年科学基金项目"

graph bar (asis) total,  over(年份, lab(angle(45) labsize(tiny))) over(资助类别)
graph export "F:\基金研究\graph\分类别-申请量.png", as(png) replace


  /// if strpos(资助类别,"青年"
ti("青年：申请量") 

tw (line total 年份 if strpos(资助类别,"青年")) (line total 年份 if strpos(资助类别,"面上")), ///
legend(label(1 "青年") label(2 "面上")) ti("申请量")

tw (line rfund 年份 if strpos(资助类别,"青年")) (line rfund 年份 if strpos(资助类别,"面上")), ///
legend(label(1 "青年") label(2 "面上")) ti("资助率")
graph export "F:\基金研究\graph\分类别-资助率.png", as(png) replace
*tw (lfit rfund 年份 if strpos(资助类别,"青年")) (lfit rfund 年份 if strpos(资助类别,"面上")), ///
*legend(label(1 "青年") label(2 "面上")) ti("资助率")


tw (line tot_growth 年份 if strpos(资助类别,"青年")) (line tot_growth 年份 if strpos(资助类别,"面上")), ///
legend(label(1 "青年") label(2 "面上")) ti("申请量增长率")
graph export "F:\基金研究\graph\分类别-申请量增长率.png", as(png) replace

/*-----------------------------------------------------------------------------------*/

//use "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022.dta"
collapse (sum) number=i, by(年份 资助类别 代码1 lixiang) 
order 年份 资助类别 代码1 lixiang
reshape wide number, i(年份 资助类别 代码1) j(lixiang)
count if number0==.
count if number1==.


rename number0 fail
rename number1 funded
replace funded=0 if funded==.
g total=fail+funded
g rfail=fail/total
g rfund=funded/total
sort 资助类别 代码1 年份 
order 资助类别 代码1 年份 
bys 资助类别 代码1: g tot_growth=(total[_n]-total[_n-1])/total[_n-1]



graph bar (asis) total if strpos(资助类别,"青年"), over(年份, lab(angle(45) labsize(tiny)) ) over(代码3)  ///
ti("青年：申请量") 
graph export "F:\基金研究\graph\青年-代码-申请量.png", as(png) replace

graph bar (asis) tot_growth if strpos(资助类别,"青年"), over(年份, lab(angle(45) labsize(tiny)) ) over(代码3)  ///
ti("青年：申请量变化率") 
graph export "F:\基金研究\graph\青年-代码-申请量变化率.png", as(png) replace

graph bar (asis) total if strpos(资助类别,"面上"), over(年份, lab(angle(45) labsize(tiny)) ) over(代码3)  ///
ti("面上：申请量") 
graph export "F:\基金研究\graph\面上-代码-申请量.png", as(png) replace

graph bar (asis) tot_growth if strpos(资助类别,"面上"), over(年份, lab(angle(45) labsize(tiny)) ) over(代码3)  ///
ti("面上：申请量变化率") 
graph export "F:\基金研究\graph\面上-代码-申请量变化率.png", as(png) replace


graph bar (asis) rfund if strpos(资助类别,"青年"), over(年份, lab(angle(45) labsize(tiny)) ) over(代码3)  ///
ti("青年：资助率") 
graph export "F:\基金研究\graph\青年-代码-资助率.png", as(png) replace

graph bar (asis) rfund if strpos(资助类别,"面上"), over(年份, lab(angle(45) labsize(tiny)) ) over(代码3)  ///
ti("面上：资助率") 
graph export "F:\基金研究\graph\面上-代码-资助率.png", as(png) replace




/*
twoway (line total 年份 if strpos(代码1,"A")) (line total 年份 if strpos(代码1,"B"))   ///
(line total 年份 if strpos(代码1,"C")) (line total 年份 if strpos(代码1,"D"))   ///
(line total 年份 if strpos(代码1,"E")) (line total 年份 if strpos(代码1,"F"))   ///
(line total 年份 if strpos(代码1,"G")) (line total 年份 if strpos(代码1,"H"))   ///
if strpos(资助类别,"青年") , legend(label(1 "数学") label(2 "化学") label(3 "生命") label(4 "地球")  ///
label(5 "工程与材料") label(6 "信息") label(7 "管理") label(8 "医学"))   


twoway (lfit rfund 年份 if strpos(资助类别,"青年")) (scatter rfund 年份 if strpos(资助类别,"青年")), ti("QN")
graph export "F:\基金研究\graph\qn-lixiang.png", as(png) replace

twoway (lfit rfund 年份 if strpos(资助类别,"面上")) (scatter rfund 年份 if strpos(资助类别,"面上")), ti("MS")
graph export "F:\基金研究\graph\ms-lixiang.png", as(png) replace

twoway (lfit rfund 年份 if strpos(资助类别,"青年")) (lfit rfund 年份 if strpos(资助类别,"面上")), legend(label(1 "QN") label(2 "MS")) 
graph export "F:\基金研究\graph\qn-ms-lixiang-lfit.png", as(png) replace
*/

/*-----------------------------------------------------------------*/

/*-----------------------------------------------------------------*/
{/*不是全样本，第一次申请相关的数据是不完整的，无法讨论第一次申请相关数据

//先跑line 167-207
collapse (sum) number=i if dup1==0, by(年份 资助类别 lixiang)   //只看第一次申请的人
// dup1==0一定是没有同名同姓的人 dup1==1不代表这个人不是第一次申请，而是有重名
order 年份 资助类别 lixiang
reshape wide number, i(年份 资助类别) j(lixiang)
rename number0 notfunded
rename number1 funded
g totapp=notfunded+funded
sort 资助类别 年份

twoway (line totapp 年份 if strpos(资助类别,"青年")) (scatter totapp 年份 if strpos(资助类别,"青年"))  ///
(line totapp 年份 if strpos(资助类别,"面上")) (scatter totapp 年份 if strpos(资助类别,"面上")) , legend(label(1 "QN") label(3 "MS")) ti("First time")
graph export "F:\基金研究\graph\qn-ms-totapp-firsttime.png", as(png) replace

g rfund=funded/totapp
twoway (lfit rfund 年份 if strpos(资助类别,"青年")) (scatter rfund 年份 if strpos(资助类别,"青年")), ti("QN first time")
graph export "F:\基金研究\graph\qn-lixiang-firsttime.png", as(png) replace

twoway (lfit rfund 年份 if strpos(资助类别,"面上")) (scatter rfund 年份 if strpos(资助类别,"面上")), ti("MS first time")
graph export "F:\基金研究\graph\ms-lixiang-firsttime.png", as(png) replace

twoway (lfit rfund 年份 if strpos(资助类别,"青年")) (lfit rfund 年份 if strpos(资助类别,"面上")), legend(label(1 "QN") label(2 "MS")) ti("First time")
graph export "F:\基金研究\graph\qn-ms-lixiang-first-lfit.png", as(png) replace

/*-----------------------------------------------------------------*//

//先跑line 167-207
//【line346】
order error1, after(school1)
//可用人名+申请部门的类型：error==0
//1. 名字只出现一次的人dup1==0,
//2. 名词出现多次对同一学院的人，排除同一学院有重名的人，这类人可以认定为同一人 dup1==1&school1==0
//3. 名字出现多次且对应不同学院的人，只要同一个名字对应的学院信息没有缺失，即可认定为同一人 dup1==1&school1==1&error==0
//
tab dup1 school1 if error1==0
drop if error1==1
sort 申请部门 姓名 申请年份 资助类别
order 申请部门 姓名 资助类别 申请年份  lixiang

sort 申请部门 姓名  资助类别 申请年份
bys 申请部门 姓名 资助类别: g first = cond(_N==1,0,_n)
g first_=1 if first==0|first==1
replace first_=0 if first>1
tab first_
//第一次申请为first==0|1
/*
     first_ |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      2,753       45.39       45.39
          1 |      3,312       54.61      100.00
------------+-----------------------------------
      Total |      6,065      100.00

*/
order first_, after(申请年份)

collapse (sum) number=i, by(年份 资助类别 first_ lixiang)   //只看第一次申请的人
order 年份 资助类别 first_ lixiang
reshape wide number, i(年份 资助类别 first_) j(lixiang)
rename number0 fail
rename number1 succ
reshape wide fail succ, i(年份 资助类别 ) j(first)

rename *1 *_1st
rename *0 *_mul
rename 年份 year
rename 资助类别 type
replace fail_mul=0 if fail_mul==.
replace succ_mul=0 if succ_mul==.

egen total=rowtotal(fail_mul-succ_1st)
g r_succ_mul=succ_mul/total
g r_succ_1st=succ_1st/total

g total_mul=fail_mul+succ_mul
g total_1st=fail_1st+succ_1st
//【line 395】

tw (line total_mul year) (line total_1st year) if strpos(type,"青年")&year>2014
tw (line total_mul year) (line total_1st year) if strpos(type,"面上")&year>2014
tw (line total year if strpos(type,"青年")&year>2014) (line total year if strpos(type,"面上")&year>2014)
tw (line total_1st year if strpos(type,"青年")&year>2014) (line total_1st year if strpos(type,"面上")&year>2014)
tw (line total_mul year if strpos(type,"青年")&year>2014) (line total_mul year if strpos(type,"面上")&year>2014)

tw (line total_1st year if strpos(type,"青年")&year>2014, col(red) lp(longdash)) (line total_mul year if strpos(type,"青年")&year>2014, col(red) lp(dash_dot)) ///
(line total_1st year if strpos(type,"面上")&year>2014, col(blue) lp(longdash)) (line total_mul year if strpos(type,"面上")&year>2014, col(blue) lp(dash_dot)) ///
(line total year if strpos(type,"青年")&year>2014, col(red) lp(solid)) (line total year if strpos(type,"面上")&year>2014, col(blue) lp(solid)), ///
legend(label(1 "QN_first") label(2 "QN_mul") label(3 "MS_first") label(4 "MS_mul")  label(5 "QN_TOTAL") label(6 "MS_TOTAL")) ti("申请")
graph export "F:\基金研究\graph\MS_QN_shenqing.png", as(png) replace


tw (line r_succ_1st year if strpos(type,"青年")&year>2014, col(red) lp(longdash)) (line r_succ_mul year if strpos(type,"青年")&year>2014, col(red) lp(dash_dot)) ///
(line r_succ_1st year if strpos(type,"面上")&year>2014, col(blue) lp(longdash)) (line r_succ_mul year if strpos(type,"面上")&year>2014, col(blue) lp(dash_dot)), ///
legend(label(1 "QN_first") label(2 "QN_mul") label(3 "MS_first") label(4 "MS_mul")  label(5 "QN_TOTAL") label(6 "MS_TOTAL")) ti("立项比例")
graph export "F:\基金研究\graph\MS_QN_lixiang.png", as(png) replace

/*-----------------------------------------------------------------*//
//先跑line 167-207; line 346-395
order error1, after(school1)
//可用人名+申请部门的类型：error==0
//1. 名字只出现一次的人dup1==0,
//2. 名词出现多次对同一学院的人，排除同一学院有重名的人，这类人可以认定为同一人 dup1==1&school1==0
//3. 名字出现多次且对应不同学院的人，只要同一个名字对应的学院信息没有缺失，即可认定为同一人 dup1==1&school1==1&error==0
//
tab dup1 school1 if error1==0
drop if error1==1
sort 申请部门 姓名 申请年份 资助类别
order 申请部门 姓名 资助类别 申请年份  lixiang

sort 申请部门 姓名  资助类别 申请年份
bys 申请部门 姓名 资助类别: g first = cond(_N==1,0,_n)
g first_=1 if first==0|first==1
replace first_=0 if first>1
tab first_
//第一次申请为first==0|1
/*
     first_ |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      2,753       45.39       45.39
          1 |      3,312       54.61      100.00
------------+-----------------------------------
      Total |      6,065      100.00

*/
order first_, after(申请年份)

bys 申请部门 姓名 资助类别: egen times=max(first)
replace times=1 if times==0
order times, after(first)

g order=first
replace order=1 if first==0
order order, after(times)
tab order

g lxorder=order*lixiang  //


sum times if strpos(资助类别,"青年")
tab  lxorder if strpos(资助类别,"青年")  //还要再加一个变量去识别unique申请人
/*
    lxorder |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,979       71.21       71.21
          1 |        537       19.32       90.54
          2 |        163        5.87       96.40
          3 |         70        2.52       98.92
          4 |         25        0.90       99.82
          5 |          4        0.14       99.96
          6 |          1        0.04      100.00
------------+-----------------------------------
      Total |      2,779      100.00
*/ 2779包括重复多次申请的同一人

tab times if strpos(资助类别,"青年") & first_==1  // 1747个unique的人申请了青年项目的人
/* 
      times |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,100       62.97       62.97
          2 |        391       22.38       85.35
          3 |        174        9.96       95.31
          4 |         52        2.98       98.28
          5 |         18        1.03       99.31
          6 |          8        0.46       99.77
          7 |          3        0.17       99.94
          8 |          1        0.06      100.00
------------+-----------------------------------
      Total |      1,747      100.00
*/

tab order if strpos(资助类别,"青年")&lixiang==1  //获得立项的人里，67%第一次申请就获得了立项
//这个不对，我要看所有人里，第一次申请获得立项的人的比例，而不是获得立项的人里，有那些人是第一次申请就获得的。
/*
      order |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        537       67.13       67.13
          2 |        163       20.38       87.50
          3 |         70        8.75       96.25
          4 |         25        3.13       99.38
          5 |          4        0.50       99.88
          6 |          1        0.13      100.00
------------+-----------------------------------
      Total |        800      100.00
*/

sum times if strpos(资助类别,"面上") & first_==1
tab times if strpos(资助类别,"面上") & first_==1  //1565个unique的人申请了面上项目
/*
      times |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        672       42.94       42.94
          2 |        417       26.65       69.58
          3 |        254       16.23       85.81
          4 |        130        8.31       94.12
          5 |         62        3.96       98.08
          6 |         22        1.41       99.49
          7 |          8        0.51      100.00
------------+-----------------------------------
      Total |      1,565      100.00

*/

tab order if strpos(资助类别,"面上")&lixiang==1  //获得立项的人里，67%的人第一次申请就获得了立项
/*
      order |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        406       47.71       47.71
          2 |        227       26.67       74.38
          3 |        137       16.10       90.48
          4 |         59        6.93       97.41
          5 |         16        1.88       99.29
          6 |          5        0.59       99.88
          7 |          1        0.12      100.00
------------+-----------------------------------
      Total |        851      100.00

*/

tab  lxorder if strpos(资助类别,"面上")  //还要再加一个变量去识别unique申请人
/*
    lxorder |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      2,435       74.10       74.10
          1 |        406       12.36       86.46
          2 |        227        6.91       93.37
          3 |        137        4.17       97.53
          4 |         59        1.80       99.33
          5 |         16        0.49       99.82
          6 |          5        0.15       99.97
          7 |          1        0.03      100.00
------------+-----------------------------------
      Total |      3,286      100.00
*/

/*
变量注释
order: 同一个人申请面上或青年的次数顺序
first: 同一个人第一次申请面上或第一次申请青年
times: 同一人一共申请了几次面上，几次青年
lixiang：对应的一次面上或青年申请是否立项
lxorder: 是否获得立项、以及第几次申请获得立项
*/
不是全样本，第一次申请相关的数据是不完整的
*/
}
/*-----------------------------------------------------------------*//


