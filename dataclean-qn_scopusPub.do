//办公室电脑 
cd "C:\Users\Administrator\Nutstore\1\论文发表2013-2020\scopusPub\dta"
//家里电脑
cd "E:\坚果云\论文发表2013-2020\scopusPub\dta"

local file2append: dir "newfolder" files "*.dta"
foreach f of local file2append {
	use "newfolder/`f'", clear
	g name_="`f'"
	g name=subinstr(name_, "_转自csv.xlsx.dta", "", .)
	drop name_
    save "newfolder/`f'", replace
}
//

clear
use "newfolder\baicaiquan_转自CSV.xlsx.dta"
local file2append: dir "newfolder" files "*.dta"
foreach f of local file2append {
    append using `"newfolder/`f'"', force
}
save qn_scopusPub_all.dta, replace

********************************************************************************
use qn_scopusPub_all.dta, clear
order  school2 school3 school4 K L M N O P R z, after(name)
replace school1=School1 if school1==""&School1!=""
drop School1
replace school1=K if school1==""&K!=""
replace school2=L if school1!=""&school2==""&L!=""
replace school3=M if M!=""
drop K L M N O P R z Q
order school1 school2 school3 school4, after(name)
save qn_scopusPub_all.dta, replace




********************************************************************************
/*问题总结
1. 同一个author_eid对应的可能不是同一个人，因此申请部门也不同，按照之前的搜索方式可能会把拼音-申请部门配对错
2. 同一个人可能对应不同的author_eid
3. 有很多人不是山大的，例如文章数量一千多的那个libin
4. 827个没有补全申请部门的，其中有些不是山大的
*/

use qn_scopusPub_all.dta, clear  
g 申请部门估=school1
replace 申请部门估="" if strpos(school1," FOUND")|strpos(school1,"no")|strpos(school1,"TBD")|strpos(school1,"搜出来")|strpos(school1,"查不到")|strpos(school1,"查出来")|strpos(school1,"搜不出来")|strpos(school1,"非山大")
replace 申请部门估="齐鲁医学院" if school1=="Cheeloo College of Medicine"
replace 申请部门估="岩土与结构工程研究中心" if school1=="Geotechnical and Structural Engineering Research Center"
replace 申请部门估="岩土与结构工程研究中心" if school1=="Research Center of Geotechnical and Structural Engineering"
replace 申请部门估="济南市中心医院" if school1=="中心医院"|school1=="市中心医院"|school1=="附属中心医院"|school1=="附属中心医院（济南市中心医院）"
replace 申请部门估="省立医院" if strpos(school1,"省立医院 ")
replace 申请部门估="基础医学院" if strpos(school1,"j基础医学院")
replace 申请部门估="省立第三医院" if strpos(school1,"s省立第三医院")|school1=="山东省立第三医院"
replace 申请部门估="公共卫生学院" if school1=="公共卫生学院 "
replace 申请部门估="机械工程学院" if school1=="机械工程学院 "
replace 申请部门估="软件学院" if school1=="软件学院 "
replace 申请部门估="环境研究院" if school1=="环境研究院 "
replace 申请部门估="齐鲁医学院" if school1=="齐鲁医学院 "
replace 申请部门估="信息科学与工程学院" if school1=="信息科学与工程"|school1=="信息学院"
replace 申请部门估="前沿交叉科学青岛研究院" if school1=="前沿交叉研究院"|school1=="前沿交叉科学院"
replace 申请部门估="化学与化工学院" if school1=="化学学院"|school1=="化学院"|school1=="化工学院"
replace 申请部门估="口腔医学院" if school1=="口腔药学院"
replace 申请部门估="国家糖工程技术研究中心" if school1=="国家糖工程技术研究中心"
replace 申请部门估="中泰金融研究院" if school1=="中泰证券金融研究院"
replace 申请部门估="高等医学研究院" if school1=="医学研究院"
replace 申请部门估="土建与水利学院" if school1=="土木工程学院"
replace 申请部门估="微生物技术国家重点实验室" if school1=="山东大学微生物技术国家重点实验室"|school1=="微生物技术研究所"|school1=="微生物技术研究院"
replace 申请部门估="政治学与公共管理学院" if school1=="山东大学政治学与公共管理学院"
replace 申请部门估="胶体与界面化学教育部重点实验室" if school1=="山东大学胶体与界面化学教育部重点实验室"
replace 申请部门估="岩土与结构工程研究中心" if school1=="岩土工程与结构工程研究中心"
replace 申请部门估="护理与康复学院" if school1=="护理学院"
replace 申请部门估="控制科学与工程学院" if school1=="控制科学与工程"
replace 申请部门估="政治学与公共管理学院" if school1=="政治与公共事务管理学院"
replace 申请部门估="材料科学与工程学院" if school1=="材料与工程学院"|school1=="材料科学与工程"
replace 申请部门估="淄博市中心医院" if school1=="淄博中心医院"
replace 申请部门估="环境科学与工程学院" if school1=="环境工程与科学学院"|school1=="环境科学与工程"
replace 申请部门估="环境研究院" if school1=="环境研究所"
replace 申请部门估="生命科学学院" if school1=="生命科学学院发育生物学研究所"|school1=="生命科学院"
replace 申请部门估="山大二院" if school1=="第二医院"
replace 申请部门估="能源与动力工程学院" if school1=="能源与动力学院"|school1=="能源动力与工程学院"|school1=="能源动力工程学院"
replace 申请部门估="计算机科学与技术学院" if school1=="计算机科学与工程学院"|school1=="计算机科学与技术"|school1=="计算机科学与技术学院系统结构研究所"
replace 申请部门估="医学院" if school1=="中科院系统生物学重点实验室"
replace 申请部门估="化学与环境科学学院" if school1=="化学与环境学院"
replace 申请部门估="基础医学院" if school1=="医学院生物化学与分子生物学系"
replace 申请部门估="岩土与结构工程研究中心" if school1=="地质科学中心"|school1=="岩土工程与结构工程研究中心"|school1=="地质科技中心"
replace 申请部门估="电气工程学院" if school1=="教育学院"
replace 申请部门估="微电子学院" if school1=="材料科学与工程学院（西安大学）"
replace 申请部门估="海洋学院" if school1=="海洋生命学院"
replace 申请部门估="海洋研究院" if school1=="海洋科学与工程学院"
replace 申请部门估="光学高等研究中心" if school1=="激光研究所"
replace 申请部门估="材料液固结构演变与加工教育部重点实验室" if school1=="物理工程学院"
replace 申请部门估="药学院" if school1=="生化工程国家重点实验室"
replace 申请部门估="齐鲁医学院" if school1=="生物工程学院"
replace 申请部门估="微生物技术国家重点实验室" if school1=="生物科学与技术学院"
replace 申请部门估="中泰金融研究院" if school1=="金融研究院"
replace 申请部门估="晶体材料国家重点实验室" if school1=="晶体材料研究所"
replace 申请部门估="热科学与工程研究中心" if school1=="热科学研究中心"
replace 申请部门估="微生物技术国家重点实验室" if school1=="寰敓鐗╂妧鏈浗瀹堕噸鐐瑰疄楠屽"
replace 申请部门估="齐鲁医院" if school1=="榻愰瞾鍖婚櫌"
replace 申请部门估="山东省耳鼻喉科医院" if school1=="榻愰瞾鍖诲闄?"
replace 申请部门估="齐鲁医学院" if school1=="榻愰瞾鍖诲闄?榻愰瞾鍖婚櫌"
replace 申请部门估="信息科学与工程学院" if school1=="淇℃伅绉戝涓庡伐绋嬪闄?"
replace 申请部门估="化学与化工学院" if school1=="鍖栧涓庡寲宸ュ闄?"
replace 申请部门估="土建与水利学院" if school1=="鍦熸湪宸ョ▼瀛﹂櫌"
replace 申请部门估="文化遗产研究院" if school1=="鏂囧寲閬椾骇鐮旂┒闄?"
replace 申请部门估="晶体材料国家重点实验室" if school1=="鏅朵綋鏉愭枡鍥藉閲嶇偣瀹為獙瀹?"
replace 申请部门估="化学与化工学院" if school1=="鏅朵綋鏉愭枡鍥藉閲嶇偣瀹為獙瀹?鍖栧涓庡寲宸ュ闄?"
replace 申请部门估="化学与化工学院" if school1=="鏅朵綋鏉愭枡鍥藉閲嶇偣瀹為獙瀹?鍖栧闄?"
replace 申请部门估="材料科学与工程学院" if school1=="鏉愭枡绉戝涓庡伐绋嬪闄?"
replace 申请部门估="环境科学与工程学院" if school1=="鐜绉戝涓庡伐绋嬪闄?"
replace 申请部门估="电气工程学院" if school1=="鐢垫皵宸ョ▼瀛﹂櫌"
replace 申请部门估="省立医院" if school1=="鐪佺珛鍖婚櫌"
replace 申请部门估="岩土与结构工程研究中心" if school1=="岩土工程中心"
replace 申请部门估="附属儿童医院" if school1=="齐鲁儿童医院"
save qn_scopusPub_all.dta, replace

********************************************************************************

use "E:\坚果云\论文发表2013-2020\scopusPub\dta\qn_scopusPub_all.dta", clear  //【青年项目申请人发表原始数据】
//识别同名不同人？不能drop没有申请部门估的obs,因为这些人有可能在NSFC里，例如bai某某



   
   
   
   
   
   
   
cap drop 年份
g 年份=substr(coverDate, -4, .)
tab 年份
destring 年份, replace
count if 年份==.  //全部是csv里多出来的无效行, 删除
drop if 年份==.


g i=1
collapse (sum) num_pub_=i, by(申请部门估 name 年份)

//reshape成name-申请部门估的格式再与NSFC合并
preserve
count if 申请部门估=="" 
keep if 申请部门估=="" 
save "E:\坚果云\论文发表2013-2020\scopusPub\dta\qn_scopusPub_numPub_3.dta"  //将申请部门估缺失的数据单独匹配
restore
drop if 申请部门估=="" 

g n=_n
tostring n, replace
replace 申请部门估=n if 申请部门估=="" //1310obs 将缺失的申请部门估用随机编码补充，在reshape wide
drop n

reshape wide num_pub_, i(name 申请部门估) j(年份)
save "E:\坚果云\论文发表2013-2020\scopusPub\dta\qn_scopusPub_numPub.dta", replace


bys name 申请部门估: g dup = cond(_N==1,0,_n) 
tab dup  //name 申请部门估 可以用来唯一的识别一个人
drop dup

use "E:\坚果云\论文发表2013-2020\scopusPub\dta\qn_scopusPub_numPub.dta", clear
bys name: g dup = cond(_N==1,0,_n) 
tab dup
bys name: egen maxdup=max(dup)
tab maxdup

preserve 
keep if maxdup==0
save "E:\坚果云\论文发表2013-2020\scopusPub\dta\qn_scopusPub_numPub_1.dta"
restore


preserve 
keep if maxdup!=0
save "E:\坚果云\论文发表2013-2020\scopusPub\dta\qn_scopusPub_numPub_2.dta"
restore
















/*
tab 申请部门估
g i=1
collapse (sum) tt=i, by(申请部门估)
drop tt




//827个unique author_eid没有申请部门
bys author_eid: g dup=cond(_N==1,0,_n) if 申请部门估==""
replace 申请部门估="岩土与结构工程研究中心" if author_eid=="55233375800"
replace 申请部门估="高等医学研究院" if author_eid=="56478001600"
replace 申请部门估="高等医学研究院" if author_eid=="57961417800" //author_eid有问题，同一个人可能对应两个id
replace 申请部门估="体育学院" if author_eid=="57323354000"
replace 申请部门估="电气工程学院" if author_eid=="56013448000"
replace 申请部门估="机械工程学院" if author_eid=="57778359200"
replace 申请部门估="济南市中心医院" if author_eid=="57196108646"
replace 申请部门估="计算机科学与技术学院" if author_eid=="57196111518"
replace 申请部门估="齐鲁医学院" if author_eid=="57196109487"
replace 申请部门估="齐鲁医学院" if author_eid=="57192961646"
replace 申请部门估="材料科学与工程学院" if author_eid=="57192961646" //另一篇挂的是齐鲁医学院，还有挂研究院的

replace 申请部门估="" if author_eid==""

replace 申请部门估="中科大" if author_eid=="57208419476"






//以下都没检查
replace 申请部门估="计算机科学与技术学院" if strpos(school1,"TBD")&author_eid=="57199899346"
replace 申请部门估="电气工程学院" if school1=="TBD"&doi=="10.1109/ICPRE.2017.8390630"
replace 申请部门估="" if school1=="TBD"&doi=="10.1109/SNPD.2007.81"
replace 申请部门估="药学院" if strpos(author_eid,"56612690800")
replace 申请部门估="电气工程学院" if author_eid=="57189874262"
replace 申请部门估="口腔医学院" if author_eid=="55675670800"  //只有最新的一篇是山大的，前面的文章有首都医科大和UBC的


replace 申请部门估="前沿交叉科学青岛研究院" if author_eid=="57212831316" //Institute of Space Sciences
replace 申请部门估="前沿交叉科学青岛研究院" if author_eid=="57217831436"   //Institute of Space Sciences
replace 申请部门估="前沿交叉科学青岛研究院" if author_eid=="57218507180"   //Institute of Space Sciences
replace 申请部门估="千佛山医院" if author_eid=="57215891120"   //Institute of Space Sciences
replace 申请部门估="公共卫生学院" if author_eid=="57192992362"   //Institute of Space Sciences
replace 申请部门估="材料液固结构演变与加工教育部重点实验室" if author_eid=="57200051457"  




replace 申请部门估="" if author_eid=="57210932388"  //非山大
replace 申请部门估="" if author_eid=="57200969632"  //只有一篇文章是山大，其他都是河海大学
replace 申请部门估="" if author_eid=="57204713484"  //山东医学院的


/*【qn_scopusPub.dta数据问题】
//有一些人不是山大的，或者有一些发表不是山大的
strpos(affilname,"Shandong University")==0
  //先在山大再去别的学校 vs 在别的学校再来上大：计算的论文发表数据是不同的
  //author_eid==57200969632只有一篇文章是山大的，其他都是别校
  //author_eid==57192539327, chenhui不是山大的，但是合作者是。
  //是不是只要文章有一个作者单位是山大的，所有作者和他们各自对应的发表都会出现在这组数据里？？？
  
  
//有多个山大的affiliation，如学院&研究院&实验室
  //authorid=57189874262的不同文章对应有两个单位：电气工程学院，电网智能化调度与控制教育部重点实验室
  //authorid==56013448000无意中搜到网站，显示他的单位是电网智能化调度与控制教育部重点实验室和电气工程学院
  不知道应该算哪个，先按照学院算单位
  http://www.jianchen.org/publications.html
  //岩土工程与结构工程研究中心&土建与水利学院不知道是什么关系，不确定是平行单位还是上下级单位

  
//识别中文发表
strpos(doi,"cnki")
//有多author_names里并不包含对应文件的姓名, 如name=="lili"&strpos(author_names,"Li, Li")==0
//同一个authorid虽然名字一样，好像不是同一个人如57192992362
//微电子学院==集成电路学院
//有些名字是【姓名格式】，有些是【名姓格式】

*/









*********************************************************************************************************
cd "C:\Users\Administrator\Nutstore\1\论文发表2013-2020\ms_scopusPub"
clear
use "dta\"
local file2append: dir "dta" files "*.dta"
foreach f of local file2append {
    append using `"C:\Users\Administrator\Nutstore\1\论文发表2013-2020\ms_scopusPub\dta/`f'"', force
}
save final_appended_files, replace
