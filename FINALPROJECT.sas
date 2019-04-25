/*Library Name*/
libname FinalPr 'C:\NU SAS Data Sets\Final Project\ANA 610 Final Project Data';


/*Import Fortune credit csv file*/
proc import datafile='C:\NU SAS Data Sets\Final Project\ANA 610 Final Project Data\fortune_credit.csv' 
out=work.fortune_credit replace; run;


/*Check contents for each files*/
*====> Fortune_acct; proc contents data=FinalPr.Fortune_acct; run; 
*====> Fortune_attrition; proc contents data=FinalPr.Fortune_attrition; run;
*====> Fortune_hr;  proc contents data=FinalPr.Fortune_hr; run;
*====> Fortune_survey;  proc contents data=FinalPr.Fortune_survey; run;

*====> Fortune_acct;
/* Numerical data */
proc means data=FinalPr.Fortune_acct n nmiss min mean median max; 
var dailyRate HourlyRate PercentSalaryHike MonthlyIncome employee_no; run;


/* Categorical data */
 proc freq data=FinalPr.Fortune_acct; table Department StockOptionLevel PerformanceRating OverTime; run; 
 

/*Character data*/
 data work.char_Fortune_acct; 
set FinalPr.Fortune_acct; len_ssn_no=length(ssn_no); run;
proc means data=work.char_Fortune_acct n nmiss min mean median max; var len_ssn_no; run;

*====> Fortune_attrition;
/*Numerical data*/
proc means data=FinalPr.Fortune_attrition n nmiss min mean median max; var employee_no; run;

/*Date data*/
/*SAS won'tuse date formats in PROC MEANS.  So use PROC TABULATE. In table statement, before the comma = rows, 
after comma = cols;*/

proc tabulate data=finalPr.fortune_attrition;
var depart_dt; table depart_dt, n nmiss mean median (min max)*f=mmddyy10.; run;
data work.yr_attrition; set finalPr.fortune_attrition; 
yr_depart_dt=yr(depart_dt); run; 
proc freq data=work.yr_attrition; table yr_depart_dt; run;


*====> Fortune_hr;
/*Numerical data*/
proc means data=FinalPr.Fortune_hr n nmiss min mean median max; var employee_no; run;

/* Categorical data */
 proc freq data=FinalPr.Fortune_hr; table Education EducationField Gender birth_state; run; 

/*Character data*/
data work.char_Fortune_hr; 
set FinalPr.Fortune_hr; len_first_name=length(first_name); run;
proc means data=work.char_Fortune_hr n nmiss min mean median max; var len_first_name; run;

/*Date data*/
 proc tabulate data=work.char_Fortune_hr; var birth_dt hire_dt; 
table birth_dt hire_dt, n nmiss median mean (min max)*f=mmddyy10. ; run;
data work.year_Fortune_hr; set FinalPr.Fortune_hr; year_birth_dt=year(birth_dt); year_hire_dt=year(hire_dt); run;
proc freq data=work.year_Fortune_hr; table year_birth_dt year_hire_dt; run;


*====> Fortune_survey;
/* Numerical data */
proc means data=FinalPr.Fortune_survey n nmiss min mean median max; var DistanceFromHome NumCompaniesWorked TotalWorkingYears 
TrainingTimesLastYear YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager employee_no; run;

/* Categorical data */
proc freq data=finalPr.fortune_survey;
table EnvironmentSatisfaction JobInvolvement JobLevel JobSatisfaction MaritalStatus RelationshipSatisfaction 
WorkLifeBalance BusinessTravel; run;


/* MERGE FILES = 3 files (attrition, hr & survey) */	
proc sort data=finalPr.fortune_attrition;  by employee_no; run;
proc sort data=finalPr.fortune_hr ;        by employee_no; run;
proc sort data=finalPr.fortune_survey ;    by employee_no; run;
data work.employee_no; merge finalPr.fortune_attrition finalPr.fortune_hr finalPr.fortune_survey ; by employee_no; run;

/*making ssn into numeric(fortune_acct)*/
data work.test; set finalPr.fortune_acct;
ssn = compress(ssn, "-");
if length(ssn) = 9 then valid_ssn = "Yes"; else valid_ssn = "No";
ssn_n = input(ssn,$9.); run;

data work.acct work.excel; set work.test; keep id ssn_number; 
	if valid_ssn = "Yes" then output work.test; else output work.excel; run;

proc print data= work.acct (firstobs = 1 obs=20); run; 
proc sql; select count(*) into : nobs from work.test2; quit;

proc print data= work.excel (firstobs = 1 obs=20); run; 
proc sql; select count(*) into : nobs from work.excel; quit;

proc contents data=work.acct; run;
proc contents data=work.credit; run;

data work.credit; set work.credit;
rename ssn = ssn_number; run;

	*merge credit with acct;
proc sort data=work.acct; 	by ssn_n; run;
proc sort data=work.credit; by ssn_n; run;
	data work.credit_acct; merge work.acct work.credit; by ssn_n; run;
 	*merge acct with hr, survey, and attrition;
proc sort data=work.employ_no; 		by employee_no; run;
proc sort data=work.credit_acct; 	by employee_no; run;
	data work.master_employ; merge work.employ_no work.credit_acct; by employee_no; run;

	*save master file;
data finalPr.master_employ; set work.master_employ; drop ssn ssn_number valid_ssn; run;








