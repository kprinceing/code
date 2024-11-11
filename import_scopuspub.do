
//发表文章及affiliation
set more off
cd "/Users/yansong/Nutstore Files/论文发表2013-2020/scopusPub" 

clear
local files: dir "/Users/yansong/Nutstore Files/论文发表2013-2020/scopusPub"  files "*.xlsx"

/* cd "C:\Users\Administrator\Nutstore\1\论文发表2013-2020\scopusPub"
local files: dir "C:\Users\Administrator\Nutstore\1\论文发表2013-2020\scopusPub"  files "*.xlsx"
 */
 
foreach file in `files'{
             clear
             import excel `file',  firstrow allstring
             
			 capture confirm var school, exact
             if c(rc) == 0 { // VARIABLE  FOUND
             rename school school1
             }
				 
             capture confirm var school1, exact
             if c(rc) == 111 { // VARIABLE NOT FOUND
             gen school1 = ""
             }
			 
			 
	save `file'.dta, replace		 
 } 
 











