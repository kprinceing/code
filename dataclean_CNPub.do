foreach i of numlist 1/8{
clear
import excel "E:\坚果云\基金研究\data\山东大学知网数据\original\导出结果_`i'.xlsx", sheet("Sheet1") firstrow
save "E:\坚果云\基金研究\data\山东大学知网数据\导出结果_`i'.dta", replace
}
//

use   "E:\坚果云\基金研究\data\山东大学知网数据\导出结果_1.dta"
foreach i of numlist 2/7{
    append using "E:\坚果云\基金研究\data\山东大学知网数据\导出结果_`i'.dta", force
}


g year=substr(发表日期,1,4)
tab year
replace year="2023" if year=="07ap"
g i=1
save "E:\坚果云\基金研究\data\山东大学知网数据\CNPub.dta"
//

use "E:\坚果云\基金研究\data\山东大学知网数据\CNPub.dta", clear
sort 姓名拼音 作者 单位知网提取 year
collapse (sum) num_pub=i num_citation=citingTimes, by(姓名拼音 作者 单位知网提取)
save "E:\坚果云\基金研究\data\山东大学知网数据\CNPub_collapse_by_author.dta"
//姓名拼音中有异常值，如数字、字符、空格的，均改为 【姓拼音空格名拼音格式】
//检查同作者不同单位的人，是否是因为同一单位不同名称而导致；若是，则按照山大官网上的名称改成一致。
  //如安丽：所有年份加一起一共有七个单位，经过识别应该均为济南市中心医院
//将全部作者名拆分成合作者1、合作者2、合作者3...等，计算每年unique的合作者人数  
  
  

*collapse (sum) num_pub=i num_citation=citingTimes, by(姓名拼音 作者 单位知网提取 year 来源类型)

/*
//1. 将变量名称改成对应之前的变量名称
rename 作者 申请人
rename 姓名拼音 author_name
rename 单位知网提取 school1
rename 申请部门客户提供 申请部门NSFC
论文会议标题 
全部作者名 
全部作者学校原始 
全部作者学校修正 
是否能分得清作者和单位 
发表日期 
citingTimes 
期刊 
会议 
会议时间 
会议地点 
来源类型