/* Final Project */

/* import data */
libname s '/home/u61014676/ANA 625/Data/Project';

data project; set s.yrbs2019; run;
proc contents data=project; run;

/* Checking Data and Variables */
proc print data=project (firstobs=1 obs=25); run;

proc freq data= project;
	table Q28;
	title "Suicide";
run;

proc freq data= project;
	table Q2;
	title "Gender";
run;

proc freq data= project;
	table QNILLICT;
	title "Drug Use";
run;

proc freq data= project;
	table Q41;
	title "Current Alcohol";
run;

proc freq data= project;
	table Q95;
	title "Exercise";
run;

proc freq data= project;
	table Q98;
	title "Concentration";
run;

/* Cleaning Data */
data df; set project;
	where Q28 in ('1', '2', '3', '4', '5') 
		and Q2 in ('1', '2') 
		and QNILLICT in (1, 2) 
		and Q41 in ('1', '2', '3', '4', '5', '6', '7') 
		and Q95 in ('1', '2', '3', '4', '5', '6', '7', '8') 
		and Q98 in ('1', '2');

	if Q28 = '1' then SUICIDE = 0; /* not attemted suicide during the past 12mo */
	if Q28 = '2' then SUICIDE = 1; /* attemted suicide during the past 12mo*/
	if Q28 = '3' then SUICIDE = 1; /* attemted suicide during the past 12mo*/
	if Q28 = '4' then SUICIDE = 1; /* attemted suicide during the past 12mo*/
	if Q28 = '5' then SUICIDE = 1; /* attemted suicide during the past 12mo*/
	
	if Q2 = '1' then GENDER = 0; /* female */
	if Q2 = '2' then GENDER = 1; /* male */
	
	if QNILLICT = 2 then DRUGUSE = 0; /* not used illicict drugs: cocaine, inhalants, heroin, methamphetamines, ecstasy, or hallucinogens, one or more times during their life) */
	if QNILLICT = 1 then DRUGUSE = 1; /* used illicit drugs, see above for definition of illicit drugs*/
	
	if Q41 = '1' then ALCOHOLUSE = 0; /* not had a drink of alcohol within the last 30 days */
	if Q41 = '2' then ALCOHOLUSE = 1; /* had a drink of alcohol within the last 30 days */
	if Q41 = '3' then ALCOHOLUSE = 1; /* had a drink of alcohol within the last 30 days */
	if Q41 = '4' then ALCOHOLUSE = 1; /* had a drink of alcohol within the last 30 days */
	if Q41 = '5' then ALCOHOLUSE = 1; /* had a drink of alcohol within the last 30 days */
	if Q41 = '6' then ALCOHOLUSE = 1; /* had a drink of alcohol within the last 30 days */
	if Q41 = '7' then ALCOHOLUSE = 1; /* had a drink of alcohol within the last 30 days */
	
	if Q95 = '1' then EXCERCISE = 0; /* not exercised during last 7 days to tone/strengthen muscles */
	if Q95 = '2' then EXCERCISE = 1; /* exercised during last 7 days to tone/strengthen muscles */
	if Q95 = '3' then EXCERCISE = 1; /* exercised during last 7 days to tone/strengthen muscles */
	if Q95 = '4' then EXCERCISE = 1; /* exercised during last 7 days to tone/strengthen muscles */
	if Q95 = '5' then EXCERCISE = 1; /* exercised during last 7 days to tone/strengthen muscles */
	if Q95 = '6' then EXCERCISE = 1; /* exercised during last 7 days to tone/strengthen muscles */
	if Q95 = '7' then EXCERCISE = 1; /* exercised during last 7 days to tone/strengthen muscles */
	if Q95 = '8' then EXCERCISE = 1; /* exercised during last 7 days to tone/strengthen muscles */

	if Q98 = '2' then CONCENTRATE = 0; /* not had serious difficulty concentrating, remembering, or making decisions, because of a physical, mental, or emotional problem */
	if Q98 = '1' then CONCENTRATE = 1; /* had serious difficulty concentrating, remembering, or making decisions, because of a physical, mental, or emotional problem */
	
run;
/* Checking */
proc contents data=df; run;
proc print data=df (firstobs=1 obs=250);
	var Q28 SUICIDE Q2 GENDER QNILLICT DRUGUSE Q41 ALCOHOLUSE 
		Q95 EXCERCISE Q98 CONCENTRATE;
run;

/* 	Create variables with the following pattern
	outcomeVar = SUICIDE
	exposeVar =  GENDER
	controlVar = DRUGUSE ALCOHOLUSE EXCERCISE CONCENTRATE
	AllVar = GENDER DRUGUSE ALCOHOLUSE EXCERCISE CONCENTRATE
*/

%let outcome = SUICIDE;
%let expose =  GENDER;
%let control = DRUGUSE ALCOHOLUSE EXCERCISE CONCENTRATE;
%let allVar = GENDER DRUGUSE ALCOHOLUSE EXCERCISE CONCENTRATE;

%let interactions = GENDER DRUGUSE ALCOHOLUSE EXCERCISE CONCENTRATE
					GENDER*DRUGUSE GENDER*ALCOHOLUSE GENDER*EXCERCISE GENDER*CONCENTRATE 
					DRUGUSE*ALCOHOLUSE DRUGUSE*EXCERCISE DRUGUSE*CONCENTRATE 
					ALCOHOLUSE*EXCERCISE ALCOHOLUSE*CONCENTRATE
					CONCENTRATE*EXCERCISE;
					
%let final = GENDER DRUGUSE ALCOHOLUSE EXCERCISE CONCENTRATE DRUGUSE*CONCENTRATE;
					
/* correlation test results:  -0.02.  Very small, ignore variable. */ 
ods noproctitle;
ods graphics / imagemap=on;

/* proc corr data=project pearson nosimple noprob plots=none;
	var SUICIDE;
	with GRADE;
run; */ 

/* Table 1 */
proc freq data=df; 
	tables (&control)*&expose
		/ norow nocol nopercent chisq; 
		title 'Table 1';
run;

/* Table 2 */
proc freq data=df; 
	tables (&allVar )*&outcome 
		/ norow nocol nopercent chisq; 
	title 'Table 2';
run;

/* Table 3 */
proc logistic data=df;
	class 	SUICIDE (ref='0') GENDER (ref='0') DRUGUSE (ref='0') ALCOHOLUSE (ref='0') 
			EXCERCISE (ref='0') CONCENTRATE (ref='0')  / param=ref; 
	model &outcome = &allVar / aggregate scale=none; 
	title 'Table 3';
run;

/*	Interactions involving exposure variable are not satistically significant 
	Use main effects model.
*/
proc logistic data=df;
	class 	SUICIDE (ref='0') GENDER (ref='0') DRUGUSE (ref='0') ALCOHOLUSE (ref='0') 
			EXCERCISE (ref='0') CONCENTRATE (ref='0')  / param=ref; 
	model &outcome = &interactions / aggregate scale=none; 
	title 'Interactions Model - ALL';
run;

/* test*/
proc logistic data=df;
	class 	SUICIDE (ref='0') GENDER (ref='0') DRUGUSE (ref='0') ALCOHOLUSE (ref='0') 
			EXCERCISE (ref='0') CONCENTRATE (ref='0')  / param=ref; 
	model &outcome = &allVar GENDER*CONCENTRATE GENDER*DRUGUSE/ aggregate scale=none; 
	oddsratio GENDER;
	title 'Kamika's Model;
run;



/* Confounding check:  They all are confounding the exposure variable */
proc logistic data=df;
	class 	SUICIDE (ref='0') GENDER (ref='0') DRUGUSE (ref='0') ALCOHOLUSE (ref='0') 
			EXCERCISE (ref='0') CONCENTRATE (ref='0')  / param=ref;  
	model &outcome = GENDER DRUGUSE ALCOHOLUSE EXCERCISE CONCENTRATE; 
	oddsratio GENDER; 
	title 'Check for confounding ';
run;

/* need a model statement */
/* clean the data based on this model statement */
/* what is null hypothesis */
/* what methods:  what data source, what is my population, log regression */

*
title slide, add the objective.  Maybe the formula?  no

add table of contents

Background:  3-4 bullets.  start broad, then narrow down the points.  WTF does
this mean?  

null hupothesis:  be direct, be short.

methods:  population size - not the sample in your data set.

population:  describe  the population - I am interested in the association of
suicide in teenages.  I need to talk about and describe my population.

Target population consists of all public, Catholic, and other private school students 
in grades 9 through 12.

Sample size.  
can use A = f(b, c, d, e, f)
or the complete formula.
secondary variables should be called control variables.

outcome var:  	attempted suicide(yes/no), have data
					Q28 and Q29
					if Q28 = A and Q29 = A then SUICIDE = 0
					if Q28 = B, C, D, E and Q29 = B, C then SUICIDE = 1
					
exposure var:  	sex(male female), have data
					Q2  Self explanitory

control var:	drug use(yes/no - 1/0), have data
					usable
					Q45=A Q50=A Q51=A Q52=A Q53=A Q54=A Q48=A Q49=A:  
						A in all of these = no drug use.  Make these 0
				
					Maybe QNILLICT
				
				alcohol use (yes/ no), have data
					Q40 = ever drink 41 = current drink
					if Q41=A then ALCOHOL = 0
					If Q41 = all others values then ALCOHOL = 1
					
				excercise (yes/no - 1/0), have data
					Q95
					if Q95 = A then EXERCISE = 0
					if Q95 = B, C, D, E, F, G, H then EXERCISE = 1
					
					also QN95
					
				Concentration (2-4 levels), Maybe remove. 
									good mental health
									bad mental health
									var q98 qn98

Citations page.
;





