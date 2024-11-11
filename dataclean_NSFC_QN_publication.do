/* //sdq办公室
cd "F:\基金研究\data\2013--2022面青\stata"
//sdq家
cd "E:\坚果云\基金研究\data\2013--2022面青\stata"
//笔记本
cd "D:\基金研究\data\2013--2022面青\stata" */



use  "NSFC2013-2022-QN.dta", clear   // 3135: 姓名-申请部门估-申请年份
*sort name 申请部门估 年份
*bys name 申请部门估 年份: g dup = cond(_N==1,0,_n) 
*tab dup //name 申请部门估可以唯一识别一个人
keep 姓名  年份  Senti lixiang 申请部门估 申请人 weihai name
order 姓名 申请人 name  申请部门估 weihai

/*将NSFC数据reshape wide*/
g shenqing=1
reshape wide Senti lixiang shenqing , i(姓名 申请人 name 申请部门估 weihai) j(年份)  //1904: 姓名-申请部门估
bys name 申请部门估: g dup = cond(_N==1,0,_n) 
tab dup  //王朋-生命科学学院 & 王鹏-生命科学学院 的 name-申请部门估重复了, 删除
drop if dup!=0    //1902: 姓名-申请部门估
drop dup //【NSFC2013-2022-QN.dta reshape wide之后从3153obs变成1902obs】

bys name: g dup = cond(_N==1,0,_n) 
/*
tab dup

        dup |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,728       90.85       90.85
          1 |         78        4.10       94.95
          2 |         78        4.10       99.05
          3 |         14        0.74       99.79
          4 |          2        0.11       99.89
          5 |          1        0.05       99.95
          6 |          1        0.05      100.00
------------+-----------------------------------
      Total |      1,902      100.00

*/


/*【1. NSFC与scopusPub_numPub用name+申请部门估1：1合并】*/
merge 1:1 name 申请部门估 using "E:\坚果云\论文发表2013-2020\scopusPub\dta\qn_scopusPub_numPub.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,011
        from master                     1,021  (_merge==1)
        from using                      1,990  (_merge==2)

    Matched                               881  (_merge==3)
    -----------------------------------------
*/
drop if _merge==2


preserve
keep if _merge==3
save "NSFC2013-2022-QN-matched1.dta" //881
restore


preserve 
keep if _merge==1&dup==0
save "NSFC2013-2022-QN-temp1.dta" //937
restore

preserve 
keep if _merge==1&dup!=0
save "NSFC2013-2022-QN-temp2.dta"
restore

/*【2. 上一步没有匹配的且name不重复的NSFC与scopusPub_numPub_1用name 1：1合并*/
use "NSFC2013-2022-QN-temp1.dta", clear
merge 1:1 name using "E:\坚果云\论文发表2013-2020\scopusPub\dta\qn_scopusPub_numPub_1.dta"
tab _merge

/*
   Result                      Number of obs
    -----------------------------------------
    Not matched                         1,317
        from master                       771  (_merge==1)
        from using                        546  (_merge==2)

    Matched                               166  (_merge==3)
    -----------------------------------------

*/

preserve
keep if _merge==3
save "NSFC2013-2022-QN-matched2.dta" //166
restore

preserve
keep if _merge==1
save "NSFC2013-2022-QN-temp3.dta" //166
restore



