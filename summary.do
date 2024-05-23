egen t=sum( author_eid )

egen t2=sum( citations )

egen tpubbf=sum( author_eid ) if grant_t<=0
(1166 missing values generated)

egen tpubaf=sum( author_eid ) if grant_t>0
(3513 missing values generated)

egen tciteaf=sum( citations ) if grant_t>0
(3513 missing values generated)

egen tcitebf=sum( citations ) if grant_t<=0


drop duration
g duration=2023-year
g cite_per_year=citation/duration

egen tciteaf2=sum( cite_per_year ) if grant_t>0

egen tcitebf2=sum( cite_per_year ) if grant_t<=0

egen tcite2=sum(cite_per_year)

g i=1
drop i
sort 申请人 申请部门 year
drop grant
g grant=1 if 立项年份!=0
replace grant=0 if 立项年份==0



cd "F:\基金研究\data\2013--2022面青"
