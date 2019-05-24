* Transitions - prepare data

/* NOTES and PROBLEMS:


*/

clear all
* Change folder here
cd "C:\Users\rlluberas\Dropbox\BCU\Income dynamics\HL2016\"

* Only men

use lineas_ALL_men.dta, clear

* There are 1 million + observations without vinculo_funcional and the same id_empresa (5754270). Drop it now, have to ask the reason.  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
drop if vinculo_funcional==.

* Drop variables for now (database too large) -------------------------------------------------------------------------------------    SEE COLLAPSE BELOW !!!!!!!!!!!!!!!!
drop nacionalidad sexo pais fecha_nacimiento tipo_renumeracion

* Recode remuneracion (.=0)
forvalue i=1/3 {
	replace remuneracion_imponible`i' = 0 if remuneracion_imponible`i'==.
	}
	
* Time variable (date)
gen year=int(anio_mes/100)
gen month=anio_mes-(year*100)
gen day = 1

gen temp = mdy(month, day, year)
gen date=mofd(temp)
format date %tmMon_CCYY
drop temp

drop anio_mes month year day

sort id_persona date

*********************************************************************************************************************************
* An observation for each worker-firm-date-social security type-job type (id_persona, id_empresa, date, aportacion, vinculo_fun)
* Aggregation by activity (acumulacion_laboral)

* Use this collapse if all the variables are included 
* collapse (mean) nacionalidad sexo pais cod_causal_egreso tipo_renumeracion (sum) remuneracion_imponible1 remuneracion_imponible2 remuneracion_imponible3  (max) fecha_nacimiento fecha_ingreso fecha_egreso, by(id_persona id_empresa date aportacion vinculo_funcional)  
 
collapse (mean)  cod_causal_egreso  (sum) remuneracion_imponible1 remuneracion_imponible2 remuneracion_imponible3  (max)  fecha_ingreso fecha_egreso, by(id_persona id_empresa date aportacion vinculo_funcional)   

duplicates tag id_persona date, gen(tag)

 /* Duplicates worker/month

. tab tag

        tag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 81,771,829       74.44       74.44
          1 | 21,239,630       19.34       93.78
          2 |  4,217,427        3.84       97.62
          3 |  1,340,664        1.22       98.84
          4 |    544,140        0.50       99.34
          5 |    251,682        0.23       99.57
          6 |    119,098        0.11       99.67
          7 |     55,576        0.05       99.72
          8 |     30,492        0.03       99.75
          9 |     12,550        0.01       99.76
         10 |      6,644        0.01       99.77
         11 |      2,904        0.00       99.77
         12 |      2,613        0.00       99.77
         13 |      1,918        0.00       99.78
         14 |      1,350        0.00       99.78
         15 |      1,152        0.00       99.78
         16 |      1,394        0.00       99.78
         17 |      1,620        0.00       99.78
         18 |      1,729        0.00       99.78
         19 |      3,120        0.00       99.79
         20 |      3,612        0.00       99.79
         21 |      4,444        0.00       99.79
         22 |      5,773        0.01       99.80
         23 |      9,432        0.01       99.81
         24 |      7,175        0.01       99.81
         25 |      5,642        0.01       99.82
         26 |      9,585        0.01       99.83
         27 |     14,924        0.01       99.84
         28 |     17,139        0.02       99.86
         29 |     15,480        0.01       99.87
         30 |     16,492        0.02       99.89
         31 |     13,920        0.01       99.90
         32 |     14,817        0.01       99.91
         33 |     21,964        0.02       99.93
         34 |     20,545        0.02       99.95
         35 |     16,956        0.02       99.97
         36 |     14,356        0.01       99.98
         37 |      8,170        0.01       99.99
         38 |      7,722        0.01       99.99
         39 |      5,360        0.00      100.00
         40 |      1,804        0.00      100.00
         41 |        294        0.00      100.00
------------+-----------------------------------
      Total |109,843,138      100.00


. tab tag if id_empresa==1

        tag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |  2,474,820       60.35       60.35
          1 |  1,516,378       36.98       97.32
          2 |    105,009        2.56       99.88
          3 |      4,579        0.11       99.99
          4 |        207        0.01      100.00
          5 |         21        0.00      100.00
          6 |         11        0.00      100.00
          7 |          7        0.00      100.00
          8 |          1        0.00      100.00
         10 |          3        0.00      100.00
         12 |          1        0.00      100.00
------------+-----------------------------------
      Total |  4,101,037      100.00
	  
	  Keep only those with at most 5 observations per month (99.4% of observations). Morover, those with more than 5 obs per month where always working.
*/


bysort id_persona: egen temp = max(tag)
drop if temp>4

/* . tab tag

        tag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 81,533,026       76.69       76.69
          1 | 19,976,622       18.79       95.47
          2 |  3,719,766        3.50       98.97
          3 |    932,472        0.88       99.85
          4 |    160,020        0.15      100.00
------------+-----------------------------------
      Total |106,321,906      100.00
*/



drop temp tag

* Work categories ---------------------------------------------------------------------------------------------- REDEFINIR JUBILADO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

gen category = .

replace category =  1 if aportacion==1 & vinculo_fun==12 /* empleado privado */
replace category =  2 if aportacion==2 & vinculo_fun==12 /* empleado publico */
replace category =  3 if aportacion==3 & vinculo_fun==12 /* empleado rural */

replace category =  4 if aportacion==1 & vinculo_fun==1 /* self-employed privado */
replace category =  5 if aportacion==3 & vinculo_fun==1 /* self-employed rural */ 
replace category =  6 if aportacion==4 & vinculo_fun==1 /* self-employed construccion */

replace category =  7 if aportacion==1 & (vinculo_fun==2|vinculo_fun==3|vinculo_fun==5|vinculo_fun==33) /* empresario */
replace category =  8 if aportacion==3 & (vinculo_fun==2|vinculo_fun==3|vinculo_fun==5|vinculo_fun==33) /* empresario rural */
replace category =  9 if aportacion==4 & (vinculo_fun==2|vinculo_fun==3|vinculo_fun==5|vinculo_fun==33) /* empresario construccion */
 
replace category =  10 if (aportacion==1|aportacion==3|aportacion==4) & (vinculo_fun==4) /* cooperativa */

replace category =  11 if (aportacion==1|aportacion==3) & (vinculo_fun==6) /* director remunerado */
replace category =  12 if (aportacion==1|aportacion==3) & (vinculo_fun==7) /* director no remunerado */

replace category =  13 if (aportacion==1) & (vinculo_fun==15) /* obrero privado */
replace category =  14 if (aportacion==2) & (vinculo_fun==15) /* obrero publico */
replace category =  15 if (aportacion==3) & (vinculo_fun==15) /* obrero rural */
replace category =  16 if (aportacion==4) & (vinculo_fun==15) /* obrero construccion */

replace category =  17 if (aportacion==1) & (vinculo_fun==13|vinculo_fun==14|vinculo_fun==16|vinculo_fun==17) /* temporal privado */
replace category =  18 if (aportacion==2) & (vinculo_fun==13|vinculo_fun==14|vinculo_fun==16|vinculo_fun==17) /* temporal publico */
replace category =  19 if (aportacion==3) & (vinculo_fun==13|vinculo_fun==14|vinculo_fun==16|vinculo_fun==17) /* temporal rural */
replace category =  20 if (aportacion==4) & (vinculo_fun==13|vinculo_fun==14|vinculo_fun==16|vinculo_fun==17) /* temporal construccion */

replace category =  21 if (aportacion==1) & ((vinculo_fun>=8 & vinculo_fun<=11)|(vinculo_fun>=18 & vinculo_fun<=22)|(vinculo_fun>=26 & vinculo_fun<=30)|(vinculo_fun>=34 & vinculo_fun<=76)|(vinculo_fun>=78 & vinculo_fun<=114)|(vinculo_fun==32)) /* otros privado */
replace category =  22 if (aportacion==2) & ((vinculo_fun>=1 & vinculo_fun<=11)|(vinculo_fun>=18 & vinculo_fun<=19)|(vinculo_fun>=27 & vinculo_fun<=30)|(vinculo_fun>=32 & vinculo_fun<=46)|(vinculo_fun>=48 & vinculo_fun<=114))                   /* otros publico */
replace category =  23 if (aportacion==3) & ((vinculo_fun>=8 & vinculo_fun<=11)|(vinculo_fun>=18 & vinculo_fun<=32)|(vinculo_fun>=34 & vinculo_fun<=114)) /* otros rural */
replace category =  24 if (aportacion==4) & ((vinculo_fun>=6 & vinculo_fun<=12)|(vinculo_fun>=18 & vinculo_fun<=32)|(vinculo_fun>=34 & vinculo_fun<=114)) /* otros construccion */

replace category =  25 if (aportacion==2) & ((vinculo_fun>=20 & vinculo_fun<=22)|(vinculo_fun==26)|(vinculo_fun==47)) /* politicos */

replace category =  26 if (aportacion==48) & ((vinculo_fun>=1 & vinculo_fun<=76)|(vinculo_fun>=78 & vinculo_fun<=114)) /* servicio domestico */
replace category =  27 if (aportacion==13) & ((vinculo_fun>=1 & vinculo_fun<=76)|(vinculo_fun>=78 & vinculo_fun<=114)) /* policia */
replace category =  28 if (aportacion==6) & ((vinculo_fun>=1 & vinculo_fun<=76)|(vinculo_fun>=78 & vinculo_fun<=114)) /* bancario */
replace category =  29 if (aportacion==5) & ((vinculo_fun>=1 & vinculo_fun<=76)|(vinculo_fun>=78 & vinculo_fun<=114)) /* notarial */
replace category =  30 if (aportacion==11) & ((vinculo_fun>=1 & vinculo_fun<=76)|(vinculo_fun>=78 & vinculo_fun<=114)) /* servicios personales */

replace category =  31 if (aportacion==1|aportacion==2) & (vinculo_fun==25) /* desempleo */
replace category =  32 if (aportacion==1|aportacion==2) & (vinculo_fun==24) /* maternidad */
replace category =  33 if (aportacion==1|aportacion==2) & (vinculo_fun==23) /* enfermedad */
replace category =  34 if (aportacion==1|aportacion==2) & (vinculo_fun==31) /* subsidio transitorio */

replace category =  35 if (aportacion==1|aportacion==2|aportacion==3|aportacion==4|aportacion==5|aportacion==6|aportacion==7|aportacion==11|aportacion==13|aportacion==48) & (vinculo_fun==77) /* jubilado */


************************************************************************************************************
************************************ Create current status *************************************************
* Employed   
* Self-employed  
* Unemployed (in unemployment insurance)
* Health
* Maternity
* Out of the database (either unemployed or working in the informal sector --- after tsfill) 
************************************************************************************************************

gen employed = . 
gen selfemployed = .
gen ui = .
gen health = .
gen maternity = .
gen retiree = .
gen unemployed = .

*-----------------------------------------------------------------------------------------------------------
replace employed = 1 if (category>=1 & category<=3)|(category>=10 & category<=30)
replace selfemployed = 1 if (category>=4 & category<=9)
replace ui = 1 if (category==31)
replace health = 1 if (category==33)|(category==34)
replace maternity = 1 if (category==32)
replace retiree = 1 if category==35

* For those with more than 1 job
foreach var in employed selfemployed ui health maternity retiree {
	bysort id_persona date: egen `var'_n = sum(`var') 
	}

	
* Number of "jobs" per worker/date
bysort id_persona date: gen N=_N

gen E = 1 if employed_n == N
gen SE = 1 if selfemployed_n == N
gen UI = 1 if ui_n == N
gen H = 1 if health_n == N
gen M = 1 if maternity_n == N
gen R = 1 if retiree_n == N

drop  employed_n selfemployed_n ui_n health_n maternity_n retiree_n

* Flag workers with issues (the others were already classified in one of the categories above)
gen temp = 1 if E==.&SE==.&UI==.&H==.&M==.&R==.
bysort id_persona: egen flag=mean(temp)
drop temp

*save temp_ALL_men, replace

* Keep only those with more than one observation

*keep if flag==1
*drop flag

/* Cases

(1) 2 observations per worker:
	- employed and unemployment insurance: unemployment insurance
	- employed and health: health
	- employed and maternith: maternity

	
*/

gen remuneracion_total = remuneracion_imponible1+ remuneracion_imponible2+ remuneracion_imponible3

gen temp = remuneracion_total if employed == 1
bysort id_persona date: egen rem_E = sum(temp)
drop temp

gen temp = remuneracion_total if selfemployed == 1
bysort id_persona date: egen rem_SE = sum(temp)
drop temp

gen temp = remuneracion_total if ui == 1
bysort id_persona date: egen rem_UI = sum(temp)
drop temp

gen temp = remuneracion_total if health == 1
bysort id_persona date: egen rem_H = sum(temp)
drop temp

gen temp = remuneracion_total if maternity == 1
bysort id_persona date: egen rem_M = sum(temp)
drop temp

gen temp = remuneracion_total if retiree == 1
bysort id_persona date: egen rem_R = sum(temp)
drop temp

* Employed and self-employed
replace E = 1 if rem_E>rem_SE & rem_UI==0 & rem_H==0 & rem_M==0 & rem_R==0
replace SE = 1 if rem_E<rem_SE & rem_UI==0 & rem_H==0 & rem_M==0 & rem_R==0

* Retiree
replace R = 1 if rem_R>0

* Social security benefits
replace UI = 1 if rem_UI>0 
replace H = 1 if rem_H>0
replace M = 1 if rem_M>0

/* There are 117,691 obs still to be classified. Most are retired ----------------------------------------------------- we have to ask why there are in the database!!!!!!!!
   There are also many "entrepreneurs" (empresarios) with no remuneration.

 
   category |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      6,093        5.18        5.18
          2 |        694        0.59        5.77
          3 |        268        0.23        5.99
          4 |        453        0.38        6.38
          5 |      1,257        1.07        7.45
          6 |          2        0.00        7.45
          7 |     42,433       36.05       43.50
          8 |      6,631        5.63       49.14
         10 |        511        0.43       49.57
         11 |      2,837        2.41       51.98
         12 |     31,360       26.65       78.63
         13 |      2,084        1.77       80.40
         14 |         34        0.03       80.43
         15 |        583        0.50       80.92
         16 |      1,270        1.08       82.00
         17 |     10,044        8.53       90.54
         18 |        271        0.23       90.77
         19 |         70        0.06       90.83
         20 |         53        0.05       90.87
         21 |      1,055        0.90       91.77
         22 |        192        0.16       91.93
         23 |        983        0.84       92.77
         25 |        501        0.43       93.19
         26 |          1        0.00       93.19
         27 |         20        0.02       93.21
         28 |         46        0.04       93.25
         30 |        352        0.30       93.55
         31 |      3,135        2.66       96.21
         32 |          1        0.00       96.21
         33 |      3,950        3.36       99.57
         34 |          4        0.00       99.57
         35 |        502        0.43      100.00
------------+-----------------------------------
      Total |    117,690      100.00


Most are with no remuneration:
	  
gen temp=10000 if E==.&SE==.&UI==.&H==.&M==.&R==.
count if temp==10000 & remuneracion_total==0
115857


	  */

* Firm ID for the highest individual income 
* There are issues with R and EN ----------------------------------------------------------------------------- drop them for now !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


gen temp = .
foreach var in E SE UI H M R {
	replace temp = 1 if remuneracion_total==rem_`var' & `var'==1
	}

drop if temp==.
drop temp

/* There are still duplicates, most with 0 remuneration (see below) ---------------------------------------------------- Drop for now ---- CHECK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


Duplicates in terms of id_persona date

. tab tag

        tag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 51,367,549       99.76       99.76
          1 |    106,488        0.21       99.97
          2 |     14,328        0.03      100.00
          3 |      2,016        0.00      100.00
          4 |        160        0.00      100.00
------------+-----------------------------------
      Total | 51,490,541      100.00
	  
count if tag>0 & remuneracion_total==0



*/

duplicates tag id_persona date, gen(tag)

drop if tag>0

drop tag
drop rem_E rem_SE rem_UI rem_H rem_M rem_R
drop employed selfemployed ui health maternity unemployed retiree N  remuneracion_total

* Expand
tsset id_persona date
*tsfill, full
tsfill

bysort id_persona: gen N=_N
bysort id_persona: gen n=_n
gen exp = 2 if n==N
expand exp, gen(duplicate)
drop N n exp

foreach var in  aportacion id_empresa vinculo_funcional date cod_causal_egreso remuneracion_imponible1 remuneracion_imponible2 remuneracion_imponible3 fecha_ingreso fecha_egreso category  E SE UI H M R{
	replace `var' = . if duplicate==1
	}

bysort id_persona: egen test=max(date)
replace test=test+1
replace date = test if duplicate==1
drop test

tsset id_persona date

* Correct last observation created 

replace category=35 if L1.cod_causal_egreso==5 & cod_causal_egreso==.
replace R=1 if category==35

gen U = 1 if id_empresa==. & duplicate!=1
replace U = 1 if L1.id_empresa==1 & duplicate==1

replace U=1 if L1.cod_causal_egreso==1 & duplicate==1 & L1.E==1

gen D = 1 if L1.cod_causal_egreso==3 & duplicate==1

************************************************************************************************************
*Transitions
* 1 = EE
* 2 = EO  (same job)
* 3 = EUI
* 4 = UIE
* 5 = EH
* 6 = HE
* 7 = EM
* 8 = ME
* 9 = HUI
* 10 = UIH
* 11 = SEE
* 12 = ESE
* 13 = EU
* 14 = UE
* 15 = UIU
* 16 = HU
* 17 = MU
* 18 = SEU
* 19 = USE
* 20 = SEUI
* 21 = UU      
* 22 = SESE
* 23 = UIUI
* 24 = HH
* 25 = MM
* 26 = UM
* 27 = UH
* 28 = SEH
* 29 = SEM
* 30 = HSE
* 31 = MSE
* 32 = ER
* 33 = SER
* 34 = HR
* 35 = MR
* 36 = UIR
* 37 = RR
* 38 = UIM
* 39 = UISE
* 40 = UR
* 41 = UUI

drop duplicate

gen transition = 1 if (E==1 & L1.E==1) & (id_empresa!=L1.id_empresa) 
replace transition = 2 if (E==1 & L1.E==1) & (id_empresa==L1.id_empresa)

replace transition = 3 if (UI==1 & L1.E==1) 
replace transition = 4 if (E==1 & L1.UI==1) 

replace transition = 5 if (H==1 & L1.E==1) 
replace transition = 6 if (E==1 & L1.H==1) 

replace transition = 7 if (M==1 & L1.E==1) 
replace transition = 8 if (E==1 & L1.M==1) 

replace transition = 9 if (UI==1 & L1.H==1) 
replace transition = 10 if (H==1 & L1.UI==1) 

replace transition = 11 if (E==1 & L1.SE==1)
replace transition = 12 if (SE==1 & L1.E==1)

replace transition = 13 if (U==1 & L1.E==1)
replace transition = 14 if (E==1 & L1.U==1)

replace transition = 15 if (U==1 & L1.UI==1)
replace transition = 16 if (U==1 & L1.H==1)
replace transition = 17 if (U==1 & L1.M==1)
replace transition = 18 if (U==1 & L1.SE==1)
replace transition = 19 if (SE==1 & L1.U==1)
replace transition = 20 if (UI==1 & L1.SE==1)

replace transition = 21 if (U==1 & L1.U==1)
replace transition = 22 if (SE==1 & L1.SE==1)

replace transition = 23 if (UI==1 & L1.UI==1)
replace transition = 24 if (H==1 & L1.H==1)
replace transition = 25 if (M==1 & L1.M==1)

replace transition = 26 if (M==1 & L1.U==1)
replace transition = 27 if (H==1 & L1.U==1)

replace transition = 28 if (H==1 & L1.SE==1)
replace transition = 29 if (M==1 & L1.SE==1)
replace transition = 30 if (SE==1 & L1.H==1)
replace transition = 31 if (SE==1 & L1.M==1)

replace transition = 32 if (R==1 & L1.E==1)
replace transition = 33 if (R==1 & L1.SE==1)
replace transition = 34 if (R==1 & L1.H==1)
replace transition = 35 if (R==1 & L1.M==1)
replace transition = 36 if (R==1 & L1.UI==1)
replace transition = 37 if (R==1 & L1.R==1)

replace transition = 38 if (M==1 & L1.UI==1)
replace transition = 39 if (SE==1 & L1.UI==1)

replace transition = 40 if (R==1 & L1.U==1)
replace transition = 41 if (UI==1 & L1.U==1)

/*

Still to classify (n>1 means do not consider the first observation that is always missing)

. su E SE UI H M R U if transition==. & n>1

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
           E |       692           1           0          1          1
          SE |       104           1           0          1          1
          UI |       191           1           0          1          1
           H |       251           1           0          1          1
           M |       242           1           0          1          1
-------------+--------------------------------------------------------
           R |         0
           U |      3054           1           0          1          1

		   */

* For those that transit from E to U, it could be voluntary or because they were fired but are not entitled to unemployment insurance
* New variable: 1 = voluntary, 2 = involuntary (only for those with transition == 13 (EU)

gen voluntary = 1 if transition == 13 & L1.cod_causal_egreso == 1
replace voluntary = 2 if transition == 13 & (L1.cod_causal_egreso == 2 | L1.cod_causal_egreso == 4)
replace voluntary = 2 if transition == 3 
tab voluntary, gen(vv)
replace vv2 = 0 if L1.E==1 & vv2!=1
replace vv1 = 0 if L1.E==1 & vv1!=1


gen EE = 1 if transition == 1
replace EE = 0 if L1.E==1 & EE!=1

gen EUI = 1 if transition == 3
replace EUI = 0 if L1.E==1 & EUI!=1




