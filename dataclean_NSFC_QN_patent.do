*----------------------------------------------------------------------------------------------------*
/*【合并逻辑一：基金数据--姓名+年份 1：1--专利数据】*/
/*【NSFC2013-2022-QN.dta,删除重名的人，变成balanced panel data，合并专利数据】*/
//sdq办公室
cd "F:\基金研究\data\2013--2022面青\stata"
//sdq家
cd "E:\坚果云\基金研究\data\2013--2022面青\stata"
//笔记本
cd "D:\基金研究\data\2013--2022面青\stata"

use  "NSFC2013-2022-QN.dta", clear
//obs3135
/*【删除重名的人】*/
drop dup1 school1 error1 i //之前生成的dup1和school1是在更新申请部门之前的，更新申请部门估后重新计算dup1和school1

bys 姓名: g dup = cond(_N==1,0,_n)
bys 姓名: egen dup1=min(dup)  //==1 代表这个名词出现次数多于一次
bys 姓名: g school=1 if 申请部门估[_n]!=申请部门估[_n+1]&姓名[_n]==姓名[_n+1]
bys 姓名: egen school1=max(school)  //==1代表同一个名字对应的申请部门不同，包括因为缺失而造成的不同
replace school1=0 if school1==.
//不同状态含义（1）没有重复名字出现，dup1==0;(2) 有重复名字出现，但是对应相同部门dup1==1&school1==0；（3）重复的名字对应不同的部门school1==1&dup1==1
tab dup1 school1
/*           |        school1
      dup1 |         0          1 |     Total
-----------+----------------------+----------
         0 |     1,091（名字只出现过一次）          0 |     1,091 
         1 |     1,883 （名字出现过多次，但对应的是同一个学院）       161 |     2,044 
-----------+----------------------+----------
     Total |     2,974        161 |     3,135 
*/
count if dup==0|dup==1  //一共有1850unique name
count if school1==1&dup1==1 //161代表有重复名字出现且对应多个申请部门
tab dup if school1==1&dup1==1  //有53个unique name存在同一个名字对应不用部门
/*        dup |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |         48       29.81       29.81
          2 |         48       29.81       59.63
          3 |         34       21.12       80.75
          4 |         19       11.80       92.55
          5 |          7        4.35       96.89
          6 |          3        1.86       98.76
          7 |          2        1.24      100.00
------------+-----------------------------------
      Total |        161      100.00
*/
drop if dup1==1&school1==1  //161个obs48个名字，每个名词重复的次数不一样
drop dup dup1 school  school1
//obs 2974
/*【变成balanced panel】*/
drop id
replace 申请部门估="未知学院" if 申请部门估==""
egen id=group(姓名 申请部门估)  //因为没有重名的人，为了保留住更多的观测值，将确实的申请部门补上再生成id

count if 年份!=申请年份  //0

tsset id 年份
count if id==.  //0
tsfill, full  //obs18020
tab 年份
order id 姓名 申请部门估 年份 申请年份 申请部门 申请部门1

bysort id: carryforward 姓名 申请部门 申请部门1 申请部门估, replace
gsort id - 年份
bysort id: carryforward 姓名 申请部门 申请部门1 申请部门估, replace

/*【合并专利数据】*/
merge 1:1 姓名 年份 using "F:\基金研究\data\patent2013-2022.dta", generate(_merge_patent)
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        49,805
        from master                    14,552  (_merge_patent==1)
        from using                     35,253  (_merge_patent==2)

    Matched                             3,468  (_merge_patent==3)
    -----------------------------------------
*/
drop if _merge_patent==2

tab 申请部门估 if _merge_patent==3   //申请部门估还是有同学院不用名的情况

save "NSFC2013-2022-QN-patent.dta", replace



*----------------------------------------------------------------------------------------------------*
/*
/*【合并逻辑二：专利数据--姓名 m：1--基金数据（yan's method）】*/

/*【NSFC2013-2022-QN.dta,删除重名的人,只留立项年份变成截面数据，专利数据做为maindata合并】*/
/*【这样的合并结果就用不上其他的申请信息了，只需要立项年份就行】*/


use "NSFC2013-2022.dta", clear
preserve
keep if 资助类别=="青年科学基金项目"  
save "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022-QN2.dta"  //用来test SY的合并
restore


use "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022-QN2.dta", clear 
/*【删除重名的人】*/
drop dup1 school1 error1 i //之前生成的dup1和school1是在更新申请部门之前的，更新申请部门估后重新计算dup1和school1

bys 姓名: g dup = cond(_N==1,0,_n)
bys 姓名: egen dup1=min(dup)  //==1 代表这个名词出现次数多于一次
bys 姓名: g school=1 if 申请部门估[_n]!=申请部门估[_n+1]&姓名[_n]==姓名[_n+1]
bys 姓名: egen school1=max(school)  //==1代表同一个名字对应的申请部门不同，包括因为缺失而造成的不同
replace school1=0 if school1==.
//不同状态含义（1）没有重复名字出现，dup1==0;(2) 有重复名字出现，但是对应相同部门dup1==1&school1==0；（3）重复的名字对应不同的部门school1==1&dup1==1
tab dup1 school1
/*           |        school1
      dup1 |         0          1 |     Total
-----------+----------------------+----------
         0 |     1,091（名字只出现过一次）          0 |     1,091 
         1 |     1,883 （名字出现过多次，但对应的是同一个学院）       161 |     2,044 
-----------+----------------------+----------
     Total |     2,974        161 |     3,135 
*/
count if dup==0|dup==1  //一共有1850unique name
count if school1==1&dup1==1 //161代表有重复名字出现且对应多个申请部门
tab dup if school1==1&dup1==1  //有53个unique name存在同一个名字对应不用部门
/*        dup |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |         48       29.81       29.81
          2 |         48       29.81       59.63
          3 |         34       21.12       80.75
          4 |         19       11.80       92.55
          5 |          7        4.35       96.89
          6 |          3        1.86       98.76
          7 |          2        1.24      100.00
------------+-----------------------------------
      Total |        161      100.00
*/
drop if dup1==1&school1==1  //161个obs48个名字，每个名词重复的次数不一样
drop dup dup1 school  school1
//obs 2974

/*【变成截面数据】*/
/*无法控制申请代码，反馈意见*/
rename 年份 year
g 立项年份=year if lixiang==1
bys id: egen 立项次数=total(!missing(立项年份))
tab 立项次数  //有一个人青年项目立项了两次！！！
drop if 立项次数==2   //删掉了两次青年立项的人
drop 立项次数
bys id: egen fundyear=max(立项年份)
order fundyear, after(申请年份)
drop 立项年份

bys 姓名:g dup = cond(_N==1,0,_n)
tab dup
keep if dup==0|dup==1

keep 姓名 申请部门 fundyear 申请部门估 id
order 姓名 fundyear id 申请部门估  申请部门  

save "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022-QN2.dta", replace


/*【合并专利数据】*/
use "F:\基金研究\data\patent2013-2022.dta"
merge m:1 姓名 using "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022-QN2.dta", generate(_merge_patent)
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        36,094
        from master                    35,253  (_merge_patent==1)
        from using                        841  (_merge_patent==2)

    Matched                             3,468  (_merge_patent==3)
    -----------------------------------------

*/

keep if _merge_patent==3
drop _merge_patent
sort 姓名 年份 
save "F:\基金研究\data\2013--2022面青\stata\NSFC2013-2022-QN2.dta", replace
*/
/*【合并逻辑二vs合并逻辑一：合并逻辑二删除了841个在NSFC-QN但不在专利数据中的人
    合并逻辑一必须把NSFC-QN数据变成平衡面板
    合并逻辑二删除了NSFC-QN中没有专利申请的人，导致结果underestimated
    合并逻辑二每个人的年份不是连续的，计算lags和leads是不准确的
	专利分析需按照合并逻辑一】*/
	