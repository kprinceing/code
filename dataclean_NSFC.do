



********************** NSFC申请数据 ***********************

local project_path "/Users/yansong/Dropbox/nutstore_files/基金研究"
local raw_data_path "`project_path'/data/2013_2022面青/stata"
local code_path "`project_path'/code"

cd "`raw_data_path'"

foreach i of numlist 2013/2022{
    import excel "y`i'.xlsx", sheet("申请") firstrow clear 
    g 申请年份=`i'
    save "y`i'_application.dta", replace
}


********************** 处理NSFC申请数据 ***********************
use "y2013_application.dta", clear
    foreach i of numlist 2014/2022{
        append using "y`i'_application.dta"
    }
    drop 申请人 申请单位 依托单位

    replace 申请部门=院系所 if 申请部门==""&院系所!=""
    rename 院系所 申请院系所


************    Q1 ************
quietly{
    bys 姓名: g dup = cond(_N==1,0,_n)
    bys 姓名: egen dup1=min(dup)  //==1 代表这个名词出现次数多于一次
    bys 姓名: g school=1 if (申请部门[_n]!=申请部门[_n+1]) & (姓名[_n]==姓名[_n+1])
    bys 姓名: egen school1=max(school)  //==1代表同一个名字对应的申请部门不同，包括因为缺失而造成的不同
    replace school1=0 if school1==.

    *count if school1==1&dup1==1 //2125代表有重复名字出现且对应多个申请部门
    *tab dup if school1==1&dup1==1  //有499个unique name存在同一个名字对应不用部门
    *count if dup==0|dup==1  //一共有3274unique name
    //正常的状态是（1）没有重复名字出现，dup1==0;(2) 有重复名字出现，但是对应相同部门dup==1&school1==0
    //school1==1&dup1==1也不全是有误的，只要同一个名字对应的申请部门没有缺失，就没有误差

    bys 姓名: g error=1 if school1==1&dup1==1&申请部门==""
    bys 姓名: egen error1=max(error)
    replace error1=0 if error1==.
    count if school1==1&dup1==1&error1==1 //1824个同一名字对应不同申请部门且申请部门有确实信息的
    drop dup school error
}


    rename 金额 申请经费万元
    rename 项目起止年月 申请项目起止年月
    rename 反馈评议意见 申请反馈评议意见
    g 年份=申请年份

save "application2013-2022.dta", replace


********************** NSFC立项数据 ********************* 
clear 
foreach i of numlist 2013/2020{
    import excel "y`i'.xlsx", sheet("立项") firstrow clear 
    g year=`i'
    save "y`i'_funded.dta", replace
}


foreach i of numlist 2021{
    import excel "y`i'.xlsx", sheet("立项") firstrow clear 
    g year=`i'
    tostring 批准经费万元, replace
    save "y`i'_funded.dta", replace
}

foreach i of numlist 2022{
    import excel "y2022.xlsx", sheet("立项") firstrow allstring clear
    g year=`i'
    save "y`i'_funded.dta", replace
}


use "y2013_funded.dta", clear
    foreach i of numlist 2014/2022{
    append using "y`i'_funded.dta"

}
    rename year 获得立项年份
    g 年份=获得立项年份 /// ????

/*************    Q2   ************
    replace 项目起止年月="2023-01/2023-12" if 申请年份==2022&strpos(结题日期,"2023")
    replace 项目起止年月="2023-01/2024-12" if 申请年份==2022&strpos(结题日期,"2024")
    replace 项目起止年月="2023-01/2025-12" if 申请年份==2022&strpos(结题日期,"2025")
    replace 项目起止年月="2023-01/2026-12" if 申请年份==2022&strpos(结题日期,"2026") */
    
    drop 开始日期 结题日期 依托单位

    save "funded2013-2022.dta", replace

********************** 处理NSFC立项数据 ***********************


use "funded2013-2022.dta", clear


    keep 姓名 项目名称 年份 反馈评议意见 资助类别 申请代码 项目起止年月

    g 无评审意见=1 if 反馈评议意见==""
    replace 无评审意见=0 if 反馈评议意见!=""

    drop 无评审意见

    rename 反馈评议意见 立项反馈评议意见
    rename 项目起止年月 立项项目起止年月
    rename 申请代码 立项申请代码
    rename 资助类别 立项资助类别

save "funded2013-2022_1.dta", replace


*********************** 合并青年项目评分与面上项目评分**********************
use "ms_senti.dta", clear
    append using "qn_senti.dta"

    bys 姓名 项目名称 年份: g xx= cond(_N==1,0,_n)
    tab xx 
    drop if xx!=0
    drop xx

save "all_senti.dta", replace


********************** 合并 NSFC申请数据, senti数据, 立项数据
use "application2013-2022.dta", clear
/*     bys 姓名 项目名称 年份: g xx= cond(_N==1,0,_n)
    tab xx
    tab 姓名 if xx!=0 
    *drop xx  */


*************    Q3   ************
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


********************** Q4 **********************

    * NSFC申请数据 合并 senti数据
    * Senti 数据怎么这么少，只有4000多条

    duplicates drop 姓名 项目名称 年份,force 
    merge 1:1 姓名 项目名称 年份  using "all_senti.dta"
    rename _merge _merge_senti


* NSFC申请数据+senti数据 合并 NSFC立项数据*
    merge 1:1 姓名 项目名称 年份  using "funded2013-2022_1.dta"

********************** Q5 **********************
    drop if _merge==2   //有524个人在立项数据里，但不在申请数据里
    rename _merge _merge_lixiang

********************** Q6 **********************
    g lixiang=1 if _merge_lixiang==3
    replace lixiang=0 if _merge_lixiang==1

    destring 立项,replace
    count if 立项!=lixiang&立项!=.

    tab 立项 if 立项!=lixiang
    //有一个立项==1但是是masteronly，sentiment数据里有处理错误
    

    g 代码1=substr(申请代码,1,1)
    g 代码2=substr(申请代码,1,3)
    g 代码3="数学" if 代码1=="A"
    replace 代码3="化学" if 代码1=="B"
    replace 代码3="生命" if 代码1=="C"
    replace 代码3="地球" if 代码1=="D"
    replace 代码3="工程材料" if 代码1=="E"
    replace 代码3="信息" if 代码1=="F"
    replace 代码3="管理" if 代码1=="G"
    replace 代码3="医学" if 代码1=="H"


save "NSFC2013-2022.dta", replace

***********************补上缺失的申请部门***********************
use "NSFC2013-2022.dta", clear

********************** Q7 **********************
run "`code_path'/处理NSFC申请部门问题.do"

    egen id = group(姓名 申请部门估)  //59missing, 因为没有申请部门信息  
    bys id 年份: g dup = cond(_N==1,0,_n)  //repeated time values within panel, 这里的id没有更正申请部门估==missing的观测值
    bys id 年份: egen numapp_peryear=max(dup)
    replace numapp_peryear=.  if id==.

    bys id: g dup = cond(_N==1,0,_n) 
    bys id: egen numapp_tt=max(dup)
    replace numapp_tt=. if id==.

    merge 1:1 项目名称 年份 using "`project_path'/data/2013--2022面青/nsfc_py.dta"  
    drop 项目名称raw _merge 

save "NSFC2013-2022.dta", replace


************************拆分成QN和MS************************

* 有51个人他们在同一年即申请了青年又申请了面上，年份重复导致无法与其他数据一对一合并
use "NSFC2013-2022.dta", clear
   
    tab 资助类别
    preserve
    keep if 资助类别=="青年科学基金项目"  //有八组资助类别和项目类型不一样，如果用项目类型来筛可能会有几个obs不一样
    save "NSFC2013-2022-QN.dta", replace
    restore

    /*
    preserve
    keep if 资助类别=="青年科学基金项目"  
    save "NSFC2013-2022-QN2.dta"  //用来test SY的合并
    restore
    */

    preserve
    keep if 资助类别=="面上项目"
    save "NSFC2013-2022-MS.dta", replace
    restore

