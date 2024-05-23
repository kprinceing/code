 graph twoway (scatter sentiment  application_times if total_applications==4) ///
 (scatter sentiment  application_times if total_applications==5) ///
  (scatter sentiment  application_times if total_applications==6) /// 
   (scatter sentiment  application_times if total_applications==7), /// 
legend(label(1 4) label(2 5) label(3 6) label(4 7))