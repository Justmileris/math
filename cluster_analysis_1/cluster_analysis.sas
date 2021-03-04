Title 'JM, Cluster analysis';

libname analize "/home/data/";

options papersize = A4;
options orientation = portrait;
options nodate;

ODS PDF FILE = "/home/data/rezultatai_1.pdf" startpage = never;
ODS RTF FILE = "/home/data/rezultatai_1.rtf" startpage = never;

ods graphics on ;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROC IMPORT OUT = analize.dataA1 DATAFILE = "/home/data/dataA1.xls" DBMS = XLS REPLACE;
	SHEET = "dataA1";
	GETNAMES = YES;
RUN;

DATA analize.dataA1;
	SET analize.dataA1;
	IF(id > 76 AND id < 101)
	THEN delete;
RUN;

Title3 'Pradiniai duomenys';
PROC PRINT DATA=analize.dataA1;
RUN;

PROC MEANS DATA=analize.dataA1 MAXDEC=2 ;
VAR x y;
Title3 'Aprasomoji statistika';
RUN;

PROC SGPLOT DATA=analize.dataA1;
SCATTER Y=y X=x ;
Title3 'Tasku sklaidos diagrama';
RUN;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* Hierarchical clustering */

Title3 'Hierarchinis centroidu metodas';

PROC CLUSTER DATA=analize.dataA1 METHOD=centroid OUT=tree
PLOTS=all
SIMPLE RMSSTD RSQUARE NONORM NOEIGEN PSEUDO CCC;
VAR Y X;
ID id;
run;

PROC TREE DATA=tree OUT=clus4 NCLUSTERS=4;
ID id;
COPY y x;

PROC SORT DATA=clus4; 
BY cluster;

PROC SGPLOT DATA=clus4;
SCATTER Y=y X=x / GROUP=cluster;
Title3 'Klasterines analizes rezultatai';
RUN;

PROC PRINT;
BY cluster;
VAR id x y;
RUN;

PROC MEANS DATA=clus4 N MEAN STD fw=8;
CLASS cluster;
VAR x y;
Title3 'Klasteriu aprasomoji statistika';
RUN;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* K-means clustering */

Title3 'K-vidurkiu metodas - FASTCLUS procedura';
RUN;
PROC FASTCLUS DATA=analize.dataA1
RADIUS=0
REPLACE=full
MAXCLUSTERS=4 MAXITER=20 LIST DISTANCE
MEAN=rez_mean OUTSTAT=rez_stat OUT=rez_out;
ID id;
VAR x y;
RUN;

PROC PRINT DATA=rez_mean;
RUN;
PROC PRINT DATA=rez_stat;
RUN;
PROC PRINT DATA=rez_out;
RUN;
PROC SGPLOT DATA=rez_out;
SCATTER Y=y X=x / GROUP=cluster;
RUN;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROC IMPORT OUT = analize.dataA2 DATAFILE = "/home/data/dataA2.xls" DBMS = XLS REPLACE;
	SHEET = "dataA2";
	GETNAMES = YES;
RUN;

DATA analize.dataA2;
	SET analize.dataA2;
	IF(id > 76 AND id < 101)
	THEN delete;
RUN;

Title3 'Pradiniai duomenys';
PROC PRINT DATA=analize.dataA2;
RUN;

PROC MEANS DATA=analize.dataA2 MAXDEC=2 ;
VAR x y;
Title3 'Aprasomoji statistika';
RUN;

PROC SGPLOT DATA=analize.dataA2;
SCATTER Y=y X=x ;
Title3 'Tasku sklaidos diagrama';
RUN;

/* Density-based clustering */
proc cluster data=analize.dataA2 outtree=tree
plot all
method=twostage k=5
simple rmsstd rsquare nonorm noeigen pseudo ccc;
var x y;
run;

title3 'Two-Stage Density Linkage rezultatai';
proc tree data=tree out=ClustdataA2 nclusters=3;
copy x y;
run;
proc sort data=ClustdataA2;
by cluster;
run;
proc sgplot data=ClustdataA2;
scatter y=y x=x / group=cluster;
run;

proc print;
by cluster;
var x y;
run;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

Title3 'K-vidurkiu metodas - FASTCLUS procedura';
RUN;
PROC FASTCLUS DATA=analize.dataA2
RADIUS=0
REPLACE=full
MAXCLUSTERS=3 MAXITER=20 LIST DISTANCE
MEAN=rez_mean OUTSTAT=rez_stat OUT=rez_out;
ID id;
VAR x y;
RUN;

PROC PRINT DATA=rez_mean;
RUN;
PROC PRINT DATA=rez_stat;
RUN;
PROC PRINT DATA=rez_out;
RUN;
PROC SGPLOT DATA=rez_out;
SCATTER Y=y X=x / GROUP=cluster;
RUN;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROC IMPORT OUT = analize.dataA3 DATAFILE = "/home/data/dataA3.xls" DBMS = XLS REPLACE;
	SHEET = "dataA3";
	GETNAMES = YES;
RUN;

DATA analize.dataA3;
	SET analize.dataA3;
	IF(id > 76 AND id < 101)
	THEN delete;
RUN;

Title2 'dataA3 data set';
Title3 'Pradiniai duomenys';
PROC PRINT DATA=analize.dataA3;
RUN;

PROC MEANS DATA=analize.dataA3 MAXDEC=2 ;
VAR x y;
Title3 'Aprasomoji statistika';
RUN;

PROC SGPLOT DATA=analize.dataA3;
SCATTER Y=y X=x ;
Title3 'Tasku sklaidos diagrama';
RUN;

proc cluster data=analize.dataA3 method=average out=tree
plots=all
simple rmsstd rsquare nonorm noeigen pseudo ccc;
var y x;
id id;
Title3 'Average linkage cluster analysis';
run;

proc tree data=tree out=clus8 nclusters=2;
id id;
copy y x;

proc sort data=clus8 ;
by cluster;

proc sgplot data=clus8 ;
scatter y=y x=x / group=cluster;
title3 'Rezultatai';
run;

proc print;
by cluster;
var id x y;
run;

PROC MEANS DATA=clus8 N MEAN STD fw=8;
class cluster;
VAR x y;
title3 'Klasteriu aprasomoji statistika';
run;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

Title3 'K-vidurkiu metodas - FASTCLUS procedura';
RUN;
PROC FASTCLUS DATA=analize.dataA3
RADIUS=0
REPLACE=full
MAXCLUSTERS=2 MAXITER=20 LIST DISTANCE
MEAN=rez_mean OUTSTAT=rez_stat OUT=rez_out;
ID id;
VAR x y;
RUN;

PROC PRINT DATA=rez_mean;
RUN;
PROC PRINT DATA=rez_stat;
RUN;
PROC PRINT DATA=rez_out;
RUN;
PROC SGPLOT DATA=rez_out;
SCATTER Y=y X=x / GROUP=cluster;
RUN;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROC IMPORT OUT = analize.dataA4 DATAFILE = "/home/data/dataA4.xls" DBMS = XLS REPLACE;
	SHEET = "dataA4";
	GETNAMES = YES;
RUN;

DATA analize.dataA4;
	SET analize.dataA4;
	IF(id > 76 AND id < 101)
	THEN delete;
RUN;

Title2 'dataA4 data set';
Title3 'Pradiniai duomenys';
PROC PRINT DATA=analize.dataA4;
RUN;

PROC MEANS DATA=analize.dataA4 MAXDEC=2 ;
VAR x y;
Title3 'Aprasomoji statistika';
RUN;

PROC SGPLOT DATA=analize.dataA4;
SCATTER Y=y X=x ;
Title3 'Tasku sklaidos diagrama';
RUN;

proc cluster data=analize.dataA4 method=complete out=tree
plots=all
simple rmsstd rsquare nonorm noeigen pseudo ccc;
var Y X;
id id;
run;

proc tree data=tree out=clus9 nclusters=8;
id id;
copy y x;

proc sort data=clus9 ;
by cluster;

proc sgplot data=clus9 ;
scatter y=y x=x / group=cluster;
title3 'Rezultatai';
run;

proc print;
by cluster;
var id x y;
run;

PROC MEANS DATA=clus9 N MEAN STD fw=8;
class cluster;
VAR x y;
title3 'Klasteriu aprasomoji statistika';
run;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

Title3 'K-vidurkiu metodas - FASTCLUS procedura';
RUN;
PROC FASTCLUS DATA=analize.dataA4
RADIUS=0
REPLACE=full
MAXCLUSTERS=8 MAXITER=20 LIST DISTANCE
MEAN=rez_mean OUTSTAT=rez_stat OUT=rez_out;
ID id;
VAR x y;
RUN;

PROC PRINT DATA=rez_mean;
RUN;
PROC PRINT DATA=rez_stat;
RUN;
PROC PRINT DATA=rez_out;
RUN;
PROC SGPLOT DATA=rez_out;
SCATTER Y=y X=x / GROUP=cluster;
RUN;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROC IMPORT OUT = analize.dataA5 DATAFILE = "/home/data/dataA5.xls" DBMS = XLS REPLACE;
	SHEET = "dataA5";
	GETNAMES = YES;
RUN;

DATA analize.dataA5;
	SET analize.dataA5;
	IF(id > 76 AND id < 101)
	THEN delete;
RUN;

Title2 'dataA5 data set';
Title3 'Pradiniai duomenys';
PROC PRINT DATA=analize.dataA5;
RUN;

PROC MEANS DATA=analize.dataA5 MAXDEC=2 ;
VAR x y;
Title3 'Aprasomoji statistika';
RUN;

PROC SGPLOT DATA=analize.dataA5;
SCATTER Y=y X=x ;
Title3 'Tasku sklaidos diagrama';
RUN;

Title3 'Hierarchinis centroidu metodas';
PROC CLUSTER DATA=analize.dataA5 METHOD=centroid OUT=tree
PLOTS=all
SIMPLE RMSSTD RSQUARE NONORM NOEIGEN PSEUDO CCC;
VAR Y X;
ID id;
run;

PROC TREE DATA=tree OUT=clusOut NCLUSTERS=22;
ID id;
COPY y x;

PROC SORT DATA=clusOut; 
BY cluster;

PROC SGPLOT DATA=clusOut;
SCATTER Y=y X=x / GROUP=cluster;
Title3 'Klasterines analizes rezultatai';
RUN;

PROC PRINT;
BY cluster;
VAR id x y;
RUN;

PROC MEANS DATA=clusOut N MEAN STD fw=8;
CLASS cluster;
VAR x y;
Title3 'Klasteriu aprasomoji statistika';
RUN;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

Title3 'K-vidurkiu metodas - FASTCLUS procedura';
RUN;
PROC FASTCLUS DATA=analize.dataA5
RADIUS=0
REPLACE=full
MAXCLUSTERS=22 MAXITER=20 LIST DISTANCE
MEAN=rez_mean OUTSTAT=rez_stat OUT=rez_out;
ID id;
VAR x y;
RUN;

PROC PRINT DATA=rez_mean;
RUN;
PROC PRINT DATA=rez_stat;
RUN;
PROC PRINT DATA=rez_out;
RUN;
PROC SGPLOT DATA=rez_out;
SCATTER Y=y X=x / GROUP=cluster;
RUN;


/*#######################################################################################*/
/*#######################################################################################*/
/*#######################################################################################*/
/*#######################################################################################*/
/*#######################################################################################*/


Title 'JM, Cluster analysis';
libname analize "/home/data/";

options papersize = A4;
options orientation = portrait;
options nodate;

ODS PDF FILE = "/home/data/rezultatai_2.pdf" startpage = never;
ODS RTF FILE = "/home/data/rezultatai_2.rtf" startpage = never;

ods graphics on ;

data task2data;
set '/home/data/hb2ca.sas7bdat';
run;

DATA task2data;
	SET task2data;
	IF(id = 43 OR id = 83 OR id = 93)
	THEN delete;
RUN;

Title2 'Data2';
proc print data=task2data;
run;

proc corr data=task2data pearson;
var x6 x8 x12 x15 x18;
title2 'Koreliacine analize.';
run;
proc stdize data=task2data method=range
out=duom2;
var x6 x8 x12 x15 x18;
run;
proc print data=duom2;
run;

proc cluster data=duom2 method=centroid out=tree
plots=all
simple rmsstd rsquare nonorm noeigen pseudo ccc;
var x6 x8 x12 x15 x18;
id id;
run;
proc tree data=tree out=outData nclusters=6;
copy x6 x8 x12 x15 x18;
proc sort data=outData;
by cluster;

PROC SGPLOT DATA=outData;
SCATTER Y=x6 X=x8 / GROUP=cluster;
Title3 'Klasterines analizes rezultatai';
RUN;

PROC PRINT;
BY cluster;
VAR x6 x8 x12 x15 x18;
RUN;

PROC MEANS DATA=outData N MEAN STD fw=8;
CLASS cluster;
VAR x6 x8 x12 x15 x18;
RUN;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

Title3 'K-vidurkiu metodas - FASTCLUS procedura';
RUN;
PROC FASTCLUS DATA=duom2
RADIUS=0
REPLACE=full
MAXCLUSTERS=6 MAXITER=20 LIST DISTANCE
MEAN=rez_mean OUTSTAT=rez_stat OUT=rez_out;
ID id;
VAR x6 x8 x12 x15 x18;
RUN;

PROC PRINT DATA=rez_mean;
RUN;
PROC PRINT DATA=rez_stat;
RUN;
PROC PRINT DATA=rez_out;
RUN;
