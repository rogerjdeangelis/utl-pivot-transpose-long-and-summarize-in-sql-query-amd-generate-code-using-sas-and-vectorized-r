%let pgm=utl-pivot-transpose-long-and-summarize-in-sql-query-amd-generate-code-using-sas-and-vectorized-r;

%sub_submission;

Pivot transpose long  summarize in sql query amd generate code using sas and vectorized r

Stack the sums for each each month adding month abreviation and grouping by exposure and category.

SQL is more flexible than sas proc summary, but is slower. Suppose you want the sum of cubes instead of the sum of squares(USS)
proc summary sum of squares. The having clause helps with condional grouping.

github
https://tinyurl.com/3usff8xz
https://github.com/rogerjdeangelis/utl-pivot-transpose-long-and-summarize-in-sql-query-amd-generate-code-using-sas-and-vectorized-r

sas communities
https://tinyurl.com/52sumwyr
https://communities.sas.com/t5/SAS-Programming/Summing-person-time-from-wide-month-variables-into-long-form/m-p/956845

   SOLUTIONS
     1 sas sql without sql arrays
       ksharpe
       https://communities.sas.com/t5/user/viewprofilepage/user-id/18408
     2 sas with sql arrys and code generation
     3 r same sql as sas r gen code
     4 excel same code as sas and r
     5 No python solution. Python does not support R sqldf

/**************************************************************************************************************************************/
/*                                 |                                                       |                                          */
/*                                 |                                                       |                                          */
/*                                 |                                                       |                                          */
/*                     M M M M M M | 1 SAS SQL WITHOUT SQL ARRAYS                          |     MONTH                                */
/*                  G  O O O O O O | ============================                          | MONTH  NUM   EXP    GRP PTIM             */
/*                  R  N N N N N N |                                                       |                                          */
/*TUDY_ID   EXP     P  1 2 3 4 5 6 | Stack the sums for each each month adding month       | Jan10   1  exposed   a    1              */
/*                                 | abreviation and grouping by exposure and category.    | Jan10   1  exposed   b    1              */
/* S001   exposed   a  1 1 0 0 0 0 |                                                       | Jan10   1  unexpose  c    2              */
/* S001   exposed   a  0 0 1 1 0 0 | proc sql;                                             | Jan10   1  unexpose  d    0              */
/* S001   exposed   a  0 0 0 0 1 0 |   create table want as                                | Feb10   2  exposed   a    1              */
/* S002   exposed   b  1 0 0 0 0 0 |   select 'Jan10' as month,1 as month_num,exp,grp,     | Feb10   2  exposed   b    1              */
/* S002   exposed   b  0 1 1 0 0 0 |   sum(mon1) as ptime from sd1.have group by exp,grp   | Feb10   2  unexpose  c    2              */
/* S002   unexpose  c  0 0 0 1 1 1 |   union all                                           | Feb10   2  unexpose  d    0              */
/* S003   unexpose  c  1 1 1 1 1 1 |   select 'Feb10' as month,2 as month_num,exp,grp      | Mar10   3  exposed   a    1              */
/* S004   unexpose  c  1 1 1 0 0 0 |   ,sum(mon2) as ptime from sd1.have group by exp,grp  | Mar10   3  exposed   b    1              */
/* S004   unexpose  d  0 0 0 1 1 1 |   union all                                           | Mar10   3  unexpose  c    2              */
/*                                 |   select 'Mar10' as month,3 as month_num,exp,grp      | Mar10   3  unexpose  d    0              */
/*                                 |   ,sum(mon3) as ptime from sd1.have group by exp,grp  | Apr10   4  exposed   a    1              */
/* options validvarname=upcase;    |   union all                                           | Apr10   4  exposed   b    0              */
/* libname sd1 "d:/sd1";           |   select 'Apr10' as month,4 as month_num,exp,grp      | Apr10   4  unexpose  c    2              */
/* data sd1.have;                  |   ,sum(mon4) as ptime from sd1.have group by exp,grp  | Apr10   4  unexpose  d    1              */
/* input study_id $ exp $ grp $    |    union all                                          | May10   5  exposed   a    1              */
/*   mon1-mon6;                    |   select 'May10' as month,5 as month_num,exp,grp      | May10   5  exposed   b    0              */
/* cards4;                         |   ,sum(mon5) as ptime from sd1.have group by exp,grp  | May10   5  unexpose  c    2              */
/* S001 exposed a 1 1 0 0 0 0      |   union all                                           | May10   5  unexpose  d    1              */
/* S001 exposed a 0 0 1 1 0 0      |   select 'Jun10' as month,6 as month_num,exp,grp      | Jun10   6  exposed   a    0              */
/* S001 exposed a 0 0 0 0 1 0      |   ,sum(mon6) as ptime from sd1.have group by exp,grp  | Jun10   6  exposed   b    0              */
/* S002 exposed b 1 0 0 0 0 0      | ;quit;                                                | Jun10   6  unexpose  c    2              */
/* S002 exposed b 0 1 1 0 0 0      |                                                       | Jun10   6  unexpose  d    1              */
/* S002 unexposed c 0 0 0 1 1 1    |                                                       |                                          */
/* S003 unexposed c 1 1 1 1 1 1    |                                                       |                                          */
/* S004 unexposed c 1 1 1 0 0 0    |                                                       |                                          */
/* S004 unexposed d 0 0 0 1 1 1    |                                                       |                                          */
/* ;;;;                            |                                                       |                                          */
/* run;quit;                       |                                                       |                                          */
/*                                 |                                                       |                                          */
/*                                 |--------------------------------------------------------                                          */
/*                                 |                                                       |                                          */
/*                                 | 2 SAS WITH SQL ARRYS AND CODE GENERATION              |                                          */
/*                                 | ========================================              |                                          */
/*                                 |                                                       |                                          */
/*                                 | Turn on mpint for generated code                      |                                          */
/*                                 |                                                       |                                          */
/*                                 | %array(_ms,values=1-6);                               |                                          */
/*                                 |                                                       |                                          */
/*                                 | proc sql;                                             |                                          */
/*                                 |   create                                              |                                          */
/*                                 |      table want as                                    |                                          */
/*                                 |      %do_over(_ms,phrase=%str(                        |                                          */
/*                                 |         select                                        |                                          */
/*                                 |            cats(put(?,monname3.),10) as mont          |                                          */
/*                                 |           ,? as month_num,exp                         |                                          */
/*                                 |           ,grp,sum(mon?) as ptime                     |                                          */
/*                                 |         from                                          |                                          */
/*                                 |            sd1.have                                   |                                          */
/*                                 |         group                                         |                                          */
/*                                 |            by exp,grp), between=union all)            |                                          */
/*                                 |   ;quit;                                              |                                          */
/*                                 | ;quit;                                                |                                          */
/*                                 |                                                       |                                          */
/*                                 | Slight edit of log                                    |                                          */
/*                                 |                                                       |                                          */
/*                                 | select cats(put(1,monname3.),10) as month             |                                          */
/*                                 | ,1 as month_num,exp ,grp,sum(mon1) as ptime           |                                          */
/*                                 | from have group by exp,grp union all                  |                                          */
/*                                 | select cats(put(2,monname3.),10) as month             |                                          */
/*                                 | ,2 as month_num,exp ,grp,sum(mon2) as ptime           |                                          */
/*                                 | from have group by exp,grp union all                  |                                          */
/*                                 | select cats(put(3,monname3.),10) as month             |                                          */
/*                                 | ,3 as month_num,exp ,grp,sum(mon3) as ptime           |                                          */
/*                                 | from have group by exp,grp union all                  |                                          */
/*                                 | select cats(put(4,monname3.),10) as month             |                                          */
/*                                 | ,4 as month_num,exp ,grp,sum(mon4) as ptime           |                                          */
/*                                 | from have group by exp,grp union all                  |                                          */
/*                                 | select cats(put(5,monname3.),10) as month             |                                          */
/*                                 | ,5 as month_num,exp ,grp,sum(mon5) as ptime           |                                          */
/*                                 | from have group by exp,grp union all                  |                                          */
/*                                 | select cats(put(6,monname3.),10) as month             |                                          */
/*                                 | ,6 as month_num,exp ,grp,sum(mon6) as ptime           |                                          */
/*                                 | from have group by exp,grp                            |                                          */
/*                                 |                                                       |                                          */
/*                                 |--------------------------------------------------------                                          */
/*                                 |                                                       |                                          */
/*                                 | 3 R SAME SQL AS SAS R GEN CODE                        |                                          */
/*                                 | ==============================                        |                                          */
/*                                 |                                                       |                                          */
/*                                 | proc datasets lib=sd1 nolist nodetails;               |                                          */
/*                                 |  delete want;                                         |                                          */
/*                                 | run;quit;                                             |                                          */
/*                                 |                                                       |                                          */
/*                                 | %utl_rbeginx;                                         |                                          */
/*                                 | parmcards4;                                           |                                          */
/*                                 | library(haven)                                        |                                          */
/*                                 | library(sqldf)                                        |                                          */
/*                                 | source("c:/oto/fn_tosas9x.R")                         |                                          */
/*                                 | have<-read_sas("d:/sd1/have.sas7bdat")                |                                          */
/*                                 | mth<-c("JAN10","FEB10","MAR10"                        |                                          */
/*                                 |  ,"APR10","MAY10","JUN10");                           |                                          */
/*                                 | idx<-c(1,2,3,4,5,6);                                  |                                          */
/*                                 | vrs<-c("MON1","MON2","MON3"                           |                                          */
/*                                 |  ,"MON4","MON5","MON6")                               |                                          */
/*                                 | phrases <- sprintf(                                   |                                          */
/*                                 |   "Select                                             |                                          */
/*                                 |     '%s' as month                                     |                                          */
/*                                 |     ,%d as month_num                                  |                                          */
/*                                 |     ,exp                                              |                                          */
/*                                 |     ,grp                                              |                                          */
/*                                 |     ,sum(%2s) as ptime                                |                                          */
/*                                 |      from have group by exp,grp"                      |                                          */
/*                                 |     ,mth,idx,vrs)                                     |                                          */
/*                                 | phrases <- gsub("\\s+", " ", phrases)                 |                                          */
/*                                 | phrases                                               |                                          */
/*                                 | genquery <- paste(phrases                             |                                          */
/*                                 |   ,collapse = "\n Union All\n")                       |                                          */
/*                                 | genquery                                              |                                          */
/*                                 | want<-sqldf(genquery)                                 |                                          */
/*                                 | want                                                  |                                          */
/*                                 | print(genquery)                                       |                                          */
/*                                 | fn_tosas9x(                                           |                                          */
/*                                 |       inp    = want                                   |                                          */
/*                                 |      ,outlib ="d:/sd1/"                               |                                          */
/*                                 |      ,outdsn ="want"                                  |                                          */
/*                                 |      )                                                |                                          */
/*                                 | ;;;;                                                  |                                          */
/*                                 | %utl_rendx;                                           |                                          */
/*                                 |                                                       |                                          */
/*                                 | proc print data=sd1.want;                             |                                          */
/*                                 | run;quit;                                             |                                          */
/*                                 |                                                       |                                          */
/*                                 | GENERATED QUERY                                       |                                          */
/*                                 | ===============                                       |                                          */
/*                                 |                                                       |                                          */
/*                                 | select 'Jan10' as month,1 as month_num,exp,grp,       |                                          */
/*                                 | sum(mon1) as ptime from sd1.have group by exp,grp     |                                          */
/*                                 | union all                                             |                                          */
/*                                 | select 'Feb10' as month,2 as month_num,exp,grp        |                                          */
/*                                 | ,sum(mon2) as ptime from sd1.have group by exp,grp    |                                          */
/*                                 | union all                                             |                                          */
/*                                 | select 'Mar10' as month,3 as month_num,exp,grp        |                                          */
/*                                 | ,sum(mon3) as ptime from sd1.have group by exp,grp    |                                          */
/*                                 | union all                                             |                                          */
/*                                 | select 'Apr10' as month,4 as month_num,exp,grp        |                                          */
/*                                 | ,sum(mon4) as ptime from sd1.have group by exp,grp    |                                          */
/*                                 |  union all                                            |                                          */
/*                                 | select 'May10' as month,5 as month_num,exp,grp        |                                          */
/*                                 | ,sum(mon5) as ptime from sd1.have group by exp,grp    |                                          */
/*                                 | union all                                             |                                          */
/*                                 | select 'Jun10' as month,6 as month_num,exp,grp        |                                          */
/*                                 | ,sum(mon6) as ptime from sd1.have group by exp,grp    |                                          */
/*                                 |                                                       |                                          */
/*                                 |--------------------------------------------------------------------------------------------------*/
/*                                 |                                                       |                                          */
/*                                 | 4 EXCEL SAME CODE AS SAS AND R                        | ----------------+                        */
/*                                 | ==============================                        | | A1| fx  |MONTH|                        */
/*                                 |                                                       | ------------------------------------+    */
/*                                 | Note this updates an existing excel workbook          | [_] |  A  |  B  |    C    | D |  E  |    */
/*                                 | proc datasets lib=sd1 nolist nodetails;               | ------------------------------------|    */
/*                                 |  delete want;                                         |     |     |MONTH|         |   |     |    */
/*                                 | run;quit;                                             |  1  |MONTH|NUM  |EXP      |GRP|PTIME|    */
/*                                 |                                                       |  -- |-----+-----+---------+---+-----|    */
/*                                 | %utlfkil(d:/xls/wantxl.xlsx);                         |  2  |JAN10| 1   | exposed | a | 1   |    */
/*                                 |                                                       |  -- |-----+-----+---------+---+-----|    */
/*                                 | %utl_rbeginx;                                         |  3  |JAN10| 1   | exposed | b | 1   |    */
/*                                 | parmcards4;                                           |  -- |-----+-----+---------+---+-----|    */
/*                                 | library(openxlsx)                                     |  4  |JAN10| 1   | unexpose| c | 2   |    */
/*                                 | library(sqldf)                                        |  -- |-----+-----+---------+---+-----|    */
/*                                 | library(haven)                                        |  5  |JAN10| 1   | unexpose| d | 0   |    */
/*                                 | have<-read_sas("d:/sd1/have.sas7bdat")                |  -- |-----+-----+---------+---+-----|    */
/*                                 | wb <- createWorkbook()                                |  6  |FEB10| 2   | exposed | a | 1   |    */
/*                                 | addWorksheet(wb, "have")                              |  -- |-----+-----+---------+---+-----|    */
/*                                 | writeData(wb, sheet = "have", x = have)               |  7  |FEB10| 2   | exposed | b | 1   |    */
/*                                 | saveWorkbook(                                         |  -- |-----+-----+---------+---+-----|    */
/*                                 |     wb                                                |  8  |FEB10| 2   | unexpose| c | 2   |    */
/*                                 |    ,"d:/xls/wantxl.xlsx"                              |  -- |-----+-----+---------+---+-----|    */
/*                                 |    ,overwrite=TRUE)                                   |  9  |FEB10| 2   | unexpose| d | 0   |    */
/*                                 | ;;;;                                                  |  -- |-----+-----+---------+---+-----|    */
/*                                 | %utl_rendx;                                           | 10  |MAR10| 3   | exposed | a | 1   |    */
/*                                 |                                                       |  -- |-----+-----+---------+---+-----|    */
/*                                 | %utl_rbeginx;                                         | 11  |MAR10| 3   | exposed | b | 1   |    */
/*                                 | parmcards4;                                           |  -- |-----+-----+---------+---+-----|    */
/*                                 | library(openxlsx)                                     | 12  |MAR10| 3   | unexpose| c | 2   |    */
/*                                 | library(sqldf)                                        |  -- |-----+-----+---------+---+-----|    */
/*                                 | source("c:/oto/fn_tosas9x.R")                         | 13  |MAR10| 3   | unexpose| d | 0   |    */
/*                                 |  wb<-loadWorkbook("d:/xls/wantxl.xlsx")               |  -- |-----+-----+---------+---+-----|    */
/*                                 |  have<-read.xlsx(wb,"have")                           | 14  |APR10| 4   | exposed | a | 1   |    */
/*                                 |  addWorksheet(wb, "want")                             |  -- |-----+-----+---------+---+-----|    */
/*                                 |  mth<-c("JAN10","FEB10","MAR10"                       | 15  |APR10| 4   | exposed | b | 0   |    */
/*                                 |   ,"APR10","MAY10","JUN10");                          |  -- |-----+-----+---------+---+-----|    */
/*                                 |  idx<-c(1,2,3,4,5,6);                                 | 16  |APR10| 4   | unexpose| c | 2   |    */
/*                                 |  vrs<-c("MON1","MON2","MON3"                          |  -- |-----+-----+---------+---+-----|    */
/*                                 |   ,"MON4","MON5","MON6")                              | 17  |APR10| 4   | unexpose| d | 1   |    */
/*                                 |  phrases <- sprintf(                                  |  -- |-----+-----+---------+---+-----|    */
/*                                 |    "Select                                            | 18  |MAY10| 5   | exposed | a | 1   |    */
/*                                 |      '%s' as month                                    |  -- |-----+-----+---------+---+-----|    */
/*                                 |      ,%d as month_num                                 | 19  |MAY10| 5   | exposed | b | 0   |    */
/*                                 |      ,exp                                             |  -- |-----+-----+---------+---+-----|    */
/*                                 |      ,grp                                             | 20  |MAY10| 5   | unexpose| c | 2   |    */
/*                                 |      ,sum(%2s) as ptime                               |  -- |-----+-----+---------+---+-----|    */
/*                                 |       from have group by exp,grp"                     | [WANT]                                   */
/*                                 |      ,mth,idx,vrs)                                    |                                          */
/*                                 |  phrases <- gsub("\\s+", " ", phrases)                |                                          */
/*                                 |  phrases                                              |                                          */
/*                                 |  genquery <- paste(phrases                            |                                          */
/*                                 |    ,collapse = "\n Union All\n")                      |                                          */
/*                                 |  genquery                                             |                                          */
/*                                 |  want<-sqldf(genquery)                                |                                          */
/*                                 |  want                                                 |                                          */
/*                                 |  writeData(wb,sheet="want",x=want)                    |                                          */
/*                                 |  saveWorkbook(                                        |                                          */
/*                                 |      wb                                               |                                          */
/*                                 |     ,"d:/xls/wantxl.xlsx"                             |                                          */
/*                                 |     ,overwrite=TRUE)                                  |                                          */
/*                                 | fn_tosas9x(                                           |                                          */
/*                                 |       inp    = want                                   |                                          */
/*                                 |      ,outlib ="d:/sd1/"                               |                                          */
/*                                 |      ,outdsn ="want"                                  |                                          */
/*                                 |      )                                                |                                          */
/*                                 | ;;;;                                                  |                                          */
/*                                 | %utl_rendx;                                           |                                          */
/*                                 |                                                       |                                          */
/*                                 | proc print data=sd1.want;                             |                                          */
/*                                 | run;quit;                                             |                                          */
/*                                 |                                                       |                                          */
/*                                 | ;;;;                                                  |                                          */
/*                                 | %utl_rendx;                                           |                                          */
/*                                 |                                                       |                                          */
/**************************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
