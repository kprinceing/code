

***************************************************************************   

/* Python代码:

-1. 搜索作者发表数据
	- Scopus.ipynb
	    + 在scopus上，从青年基金申请数据搜索每个申请人的 author_eid
	    + 在scopus上，依据每个author_eid下载其论文

-2. 建构模型，给评审意见打分
	- senti_model_qn.ipynb
    + 输出文件: qn_senti.csv 

	- senti_model_ms.ipynb
	    + 输出文件: ms_senti.csv     

-3. 匹配自科申请数据，个人论文发表数据
	- qn_merge.ipynb
    + 输出文件 qn_reg_type1.csv ,qn_reg_type1_coded.csv
	+ qn_reg_type3.csv  包括期刊分类
	
	ms_merge.ipynb
	+ ms_reg_type1_coded.csv 
	

4.匹配自科申请数据，个人论文发表数据，和模型预测的情感数据
- qn_senti_pub.ipynb
    + 
    + 转换成回归所用格式
    + 输出文件 qn_reg_type2.csv 

 - ms_senti_pub.ipynb
    + 把自科申请数据，个人论文发表数据，和模型预测的情感数据匹配起来
    + 转换成回归所用格式
    + 输出文件 ms_reg_type2.csv 



*/
***************************************************************************   

/* Stata代码:
*/

cd "/Users/yansong/Nutstore Files/基金研究/code"

************************scopusPub(青年)数据转格式 ************************
run import_scopuspub.do
/*
- data location： 坚果云\论文发表2013-2020\scopusPub
    + 将文件夹中青年项目论文发表导入STATA
*/

************************合成JCR分区************************
run import_JCR.do
/*
- data location： 坚果云\基金研究\data\期刊分区
    + 将JCR文件导入STATA
	+ 输出文件 JCR2022 ... JCR2014
	+ 合并文件，获得每本杂志在2014-2022年间的平均JCR分区
	+ 输出文件 JCR2014-2022average.dta
*/


************************NSFC申请立项数据清理************************
*data location: 坚果云\基金研究\data\2013--2022面青\stata
//NSFC申请+senti+立项-->分成青年和面上--> 变成balanced panel -->合并专利数据

run dataclean_NSFC.do


************************  Merge to get publication quality ************************
run merge_journal.do 
/*
- data location: 坚果云\基金研究\data\2013--2022面青\scopusPub_New\dta
    + 将scopusPub_New文件夹中每个人发表期刊合并
	+ 输出文件 all_author_pubjournal.dta（青年项目）
	+ 与JCR2022合并，获得SDUer发表期刊分区信息
	+ 输出文件 journal_quality.dta
	+ 同时整理出SDU曾发期刊列表
	+ 输出文件 qn_scopus_journal_list.xls
*/


************************  Regression ************************

run regresssions.do


************************  专利部分代码 ************************


local project_path "/Users/yansong/Dropbox/nutstore_files/基金研究"
local code_path "`project_path'/code"
cd "`code_path'"

**************************************************  
* 生成 NSFC2013-2022-QN
* data location:  "/data/2013_2022面青/NSFC2013-2022-QN.dta"
run dataclean_NSFC.do

**************************************************  
*data location:  "/data/patent2013-2022.dta"
*生成数据为每人名+每申请年申请的三种类型专利数量，及最终获得授权的专利数量
run dataclean_patent.do

**************************************************  
* 合并基金数据和专利数据,用于回归分析
*data location:  "/data/2013_2022面青/NSFC2013-2022-QN-patent.dta"
run dataclean_NSFC_QN_patent.do 


**************************************************  
* 回归分析
* 使用数据: "/data/2013_2022面青/NSFC2013-2022-QN-patent.dta"
* results output: "graph_patent/"

run regressions_patent.do 







