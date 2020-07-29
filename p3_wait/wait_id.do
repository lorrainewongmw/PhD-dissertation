// Paper 3 - The effect of waiting time on LM outcomes //
* Identification
* Lorraine Wong, UCD.
* Last update: 29 July 2020
* Stata version 14.2

* GLOBALS * 
global covarNOFE "sexst age age2 i.highestcompleduaggi lang_2 hhsize rural" 
global spec "label nocons addstat(Sample mean, r(mean))"
global fulltext "addtext(Individual characteristics, Yes, Fixed effects yrnatXayearcan, Yes) nonotes"

********************************************************************************
* Identification *
********************************************************************************

* 1. No perfect collinearity
*===============================================================================

** Regress treatment (waitB) on covariates -------------------------------------

*** Permit B 
qui reg waitB $covarNOFE i.year if $Bsample, vce(cluster id)
qui sum waitB if e(sample)
outreg2 using lastpaper/output/may/id/1trt_cov.xls, dec(3) ctitle(B_Basic) excel replace $spec ///
drop (i.year) addtext(Year FE, Yes, Nationality FE, No, Arrival year FE, No, Nationality X Arrival year FE, No) nonotes

qui reg waitB $covarNOFE i.year i.charrivalyear if $Bsample, vce(cluster id)
qui sum waitB if e(sample)
outreg2 using lastpaper/output/may/id/1trt_cov.xls, dec(3) ctitle(Arrival year) excel append $spec ///
drop (i.year i.charrivalyear) addtext(Year FE, Yes, Nationality FE, No, Arrival year FE, Yes, Nationality X Arrival year FE, No)

qui reg waitB $covarNOFE i.year i.charrivalyear##ib8362.nationalityid if $Bsample, vce(cluster id)
qui sum waitB if e(sample)
outreg2 using lastpaper/output/may/id/1trt_cov.xls, dec(3) ctitle(Interact FE) excel append $spec ///
keep ($covarNOFE) addtext(Year FE, Yes, Nationality FE, Yes, Arrival year FE, Yes, Nationality X Arrival year FE, Yes)


**** Permit F
qui reg waitF ib3.traject $covarNOFE i.year if $Fsample , vce(cluster id)
qui sum waitF if e(sample)
outreg2 using lastpaper/output/may/id/1trt_cov.xls, dec(3) ctitle(F_Basic) excel append $spec ///
drop (i.year) addtext(Year FE, Yes, Nationality FE, No, Arrival year FE, No, Nationality X Arrival year FE, No) nonotes

qui reg waitF ib3.traject $covarNOFE i.year i.charrivalyear if $Fsample , vce(cluster id)
qui sum waitF if e(sample)
outreg2 using lastpaper/output/may/id/1trt_cov.xls, dec(3) ctitle(Arrival year) excel append $spec ///
drop (i.year i.charrivalyear) addtext(Year FE, Yes, Nationality FE, No, Arrival year FE, Yes, Nationality X Arrival year FE, No)

qui reg waitF ib3.traject $covarNOFE i.year i.charrivalyear##ib8362.nationalityid if $Fsample , vce(cluster id)
qui sum waitF if e(sample)
outreg2 using lastpaper/output/may/id/1trt_cov.xls, dec(3) ctitle(Interact FE) excel append $spec ///
keep ($covarNOFE 5.traject) addtext(Year FE, Yes, Nationality FE, Yes, Arrival year FE, Yes, Nationality X Arrival year FE, Yes)



** Reg each covariates on the continuous treatment + familywise error rate (10,000 boostraps) -------------------------------------
local prearrive "sexst age_arrive" 
local post "EDU1 EDU2 EDU3 lang_2 hhsize rural" 

*** Permit B
wyoung `prearrive', cmd(regress OUTCOMEVAR waitB i.nid_pool i.charrivalyear i.year if $Bsample ) cluster(id) familyp(waitB) bootstraps(10000) seed(20) 
matrix A= r(table)
putexcel set lastpaper/output/may/id/wy_test.xlsx, sheet(B_admin) modify
putexcel A1=matrix(A), names

wyoung `post', cmd(regress OUTCOMEVAR waitB i.nid_pool i.charrivalyear i.year if $Bsample ) cluster(id) familyp(waitB) bootstraps(10000) seed(20) 
matrix A= r(table)
putexcel set lastpaper/output/may/id/wy_test.xlsx, sheet(B_svy) modify
putexcel A1=matrix(A), names

*** Permit F
wyoung `prearrive', cmd(regress OUTCOMEVAR waitF i.nid_pool i.charrivalyear i.year if $Fsample ) cluster(id) familyp(waitF) bootstraps(10000) seed(20)  
matrix A= r(table)
putexcel set lastpaper/output/may/id/wy_test.xlsx, sheet(F_admin) modify
putexcel A1=matrix(A), names

wyoung `post', cmd(regress OUTCOMEVAR waitF i.nid_pool i.charrivalyear i.year if $Fsample ) cluster(id) familyp(waitF) bootstraps(10000) seed(20)  
matrix A= r(table)
putexcel set lastpaper/output/may/id/wy_test.xlsx, sheet(F_svy) modify
putexcel A1=matrix(A), names


// STAY/ WAIT //

*** Permit B
wyoung `prearrive', cmd(regress OUTCOMEVAR stay_waitB i.nid_pool i.charrivalyear i.year if $Bsample ) cluster(id) familyp(stay_waitB) bootstraps(10000) seed(20) 
matrix A= r(table)
putexcel set lastpaper/output/may/id/wy_test2.xlsx, sheet(stayB_admin) modify
putexcel A1=matrix(A), names

wyoung `post', cmd(regress OUTCOMEVAR stay_waitB i.nid_pool i.charrivalyear i.year if $Bsample ) cluster(id) familyp(stay_waitB) bootstraps(10000) seed(20) 
matrix A= r(table)
putexcel set lastpaper/output/may/id/wy_test2.xlsx, sheet(stayB_svy) modify
putexcel A1=matrix(A), names

*** Permit F
wyoung `prearrive', cmd(regress OUTCOMEVAR stay_waitF i.nid_pool i.charrivalyear i.year if $Fsample ) cluster(id) familyp(stay_waitF) bootstraps(10000) seed(20)  
matrix A= r(table)
putexcel set lastpaper/output/may/id/wy_test2.xlsx, sheet(stayF_admin) modify
putexcel A1=matrix(A), names

wyoung `post', cmd(regress OUTCOMEVAR stay_waitF i.nid_pool i.charrivalyear i.year if $Fsample ) cluster(id) familyp(stay_waitF) bootstraps(10000) seed(20)  
matrix A= r(table)
putexcel set lastpaper/output/may/id/wy_test2.xlsx, sheet(stayF_svy) modify
putexcel A1=matrix(A), names



** Regress treatment (stay_waitB) on covariates -------------------------------------
** Corrlations 
corr stay_waitB ayear_* if $Bsample
matrix C=r(C)
putexcel set lastpaper/output/may/id/corr.xlsx, sheet(stay_waitB, replace) modify
putexcel A1=matrix(C), names 

corr stay_waitF ayear_* if $Fsample
matrix C=r(C)
putexcel set lastpaper/output/may/id/corr.xlsx, sheet(stay_waitF, replace) modify
putexcel A1=matrix(C), names 


*** Stay/Permit B 
qui reg stay_waitB $covarNOFE i.year if $Bsample, vce(cluster id)
qui sum stay_waitB if e(sample)
outreg2 using lastpaper/output/may/id/1btrt_cov.xls, dec(3) ctitle(B_Basic) excel replace $spec ///
drop (i.year) addtext(Year FE, Yes, Nationality FE, No, Arrival year FE, No, Nationality X Arrival year FE, No) nonotes

qui reg stay_waitB $covarNOFE i.year i.charrivalyear if $Bsample, vce(cluster id)
qui sum stay_waitB if e(sample)
outreg2 using lastpaper/output/may/id/1btrt_cov.xls, dec(3) ctitle(Arrival year) excel append $spec ///
drop (i.year i.charrivalyear) addtext(Year FE, Yes, Nationality FE, No, Arrival year FE, Yes, Nationality X Arrival year FE, No)

qui reg stay_waitB $covarNOFE i.year i.charrivalyear##ib8362.nationalityid if $Bsample, vce(cluster id)
qui sum stay_waitB if e(sample)
outreg2 using lastpaper/output/may/id/1btrt_cov.xls, dec(3) ctitle(Interact FE) excel append $spec ///
keep (preBwage_any $covarNOFE) addtext(Year FE, Yes, Nationality FE, Yes, Arrival year FE, Yes, Nationality X Arrival year FE, Yes)


**** Stay/Permit F
qui reg stay_waitF ib3.traject $covarNOFE i.year if $Fsample , vce(cluster id)
qui sum stay_waitF if e(sample)
outreg2 using lastpaper/output/may/id/1btrt_cov.xls, dec(3) ctitle(F_Basic) excel append $spec ///
drop (i.year) addtext(Year FE, Yes, Nationality FE, No, Arrival year FE, No, Nationality X Arrival year FE, No) nonotes

qui reg stay_waitF ib3.traject $covarNOFE i.year i.charrivalyear if $Fsample , vce(cluster id)
qui sum stay_waitF if e(sample)
outreg2 using lastpaper/output/may/id/1btrt_cov.xls, dec(3) ctitle(Arrival year) excel append $spec ///
drop (i.year i.charrivalyear) addtext(Year FE, Yes, Nationality FE, No, Arrival year FE, Yes, Nationality X Arrival year FE, No)

qui reg stay_waitF ib3.traject $covarNOFE i.year i.charrivalyear##ib8362.nationalityid if $Fsample , vce(cluster id)
qui sum stay_waitF if e(sample)
outreg2 using lastpaper/output/may/id/1btrt_cov.xls, dec(3) ctitle(Interact FE) excel append $spec ///
keep ($covarNOFE 5.traject) addtext(Year FE, Yes, Nationality FE, Yes, Arrival year FE, Yes, Nationality X Arrival year FE, Yes) ///
sortvar ($covarNOFE 5.traject)


	
	
* 2. Random sampling (independent and identically distributed)
*===============================================================================

** Balance Table by waiting time categories
preserve 
local admin "sexst age_arrive "
local svy "EDU1 EDU2 EDU3 lang_2 hhsize rural"

*--------------------------------------
* Permit B
*--------------------------------------
***
* Calculate unweighted means of each var for each group, and test for equality across groups
***
putexcel set lastpaper/output/may/id/bal_test.xlsx, sheet(B_a, replace) modify
putexcel A1= "Outcome"
putexcel B1= "1-2 years"
putexcel C1= "3-5 years"
putexcel D1= "6 years"
putexcel E1= "7-8 years"
putexcel F1= "p-value"
putexcel G1= "Observations"

local run_no = 1
qui foreach v in `admin' `svy' {
		
	* Sample size for the variable
	count if !mi(`v') & traject==4
	local sample_size = `r(N)'
	
	* Calculate means for all groups (including those not in study)
	reg `v' ibn.waitB_cat i.charrivalyear i.year if $Bsample , nocons vce(cluster id) 
	
	* Test for equality across those enrolled in study
	test i1.waitB_cat==i2.waitB_cat==i3.waitB_cat==i4.waitB_cat
	local pval = `r(p)'
	
	* Label results and save excel
	local cell = `run_no'+1 
	
	putexcel A`cell'="`v'"
	putexcel B`cell'=_b[1.waitB_cat]
	putexcel C`cell'=_b[2.waitB_cat]
	putexcel D`cell'=_b[3.waitB_cat]
	putexcel E`cell'=_b[4.waitB_cat]
	putexcel F`cell'=`pval'
	putexcel G`cell'=`sample_size'
	
	local run_no = `run_no'+1
	restore, preserve
}

** Joint balance test and sample size
putexcel set lastpaper/output/may/id/bal_test.xlsx, sheet(B_ajoint, replace) modify

putexcel A1= "Joint blanace test for Panel"
putexcel F1= "p-value"
putexcel G1= "Observations"

local run_no = 1
qui foreach panel in A B {

	     if "`panel'"=="A" local joint_test_vars "`admin'"
	else if "`panel'"=="B" local joint_test_vars "`svy'"
	else error 1
	
	reg waitB_cat `joint_test_vars' i.charrivalyear i.year if $Bsample , vce(cluster id)
	test `joint_test_vars'
	
	local joint_test_`panel' = string(`r(p)',"%5.3f")
	local sample_size_`panel' = e(N)
	
	* Label results and save excel
	local cell = `run_no'+1 
	
	putexcel A`cell'="Panel `panel' (p-value)"
	putexcel F`cell'="`joint_test_`panel''"
	putexcel G`cell'="`sample_size_`panel''"
	
	local run_no = `run_no'+1
}

*--------------------------------------
* Permit F
*--------------------------------------
***
* Permit F sample: Calculate unweighted means of each var for each group, and test for equality across groups
***
putexcel set lastpaper/output/may/id/bal_test.xlsx, sheet(F_a, replace) modify
putexcel A1= "Outcome"
putexcel B1= "1-2 years"
putexcel C1= "3 years"
putexcel D1= "4 years"
putexcel E1= "5-9 years"
putexcel F1= "p-value"
putexcel G1= "Observations"

local run_no = 1
qui foreach v in `admin' `svy' {
		
	* Sample size for the variable
	count if !mi(`v') & traject==3 | traject==5
	local sample_size = `r(N)'
	
	* Calculate means for all groups (including those not in study)
	reg `v' ibn.waitF_cat i.charrivalyear i.year if $Fsample , nocons vce(cluster id)
	
	* Test for equality across those enrolled in study
	test i1.waitF_cat==i2.waitF_cat==i3.waitF_cat==i4.waitF_cat
	local pval = `r(p)'
	
	* Label results and save excel
	local cell = `run_no'+1 
	
	putexcel A`cell'="`v'"
	putexcel B`cell'=_b[1.waitF_cat]
	putexcel C`cell'=_b[2.waitF_cat]
	putexcel D`cell'=_b[3.waitF_cat]
	putexcel E`cell'=_b[4.waitF_cat]
	putexcel F`cell'=`pval'
	putexcel G`cell'=`sample_size'
	
	local run_no = `run_no'+1
	restore, preserve
}

** Joint balance test and sample size
putexcel set lastpaper/output/may/id/bal_test.xlsx, sheet(F_ajoint, replace) modify

putexcel A1= "Joint blanace test for Panel"
putexcel F1= "p-value"
putexcel G1= "Observations"

local run_no = 1
qui foreach panel in A B {

	     if "`panel'"=="A" local joint_test_vars "`admin'"
	else if "`panel'"=="B" local joint_test_vars "`svy'"
	else error 1
	
	reg waitF_cat `joint_test_vars' i.charrivalyear i.year if $Fsample, vce(cluster id)
	test `joint_test_vars'
	
	local joint_test_`panel' = string(`r(p)',"%5.3f")
	local sample_size_`panel' = e(N)
	
	* Label results and save excel
	local cell = `run_no'+1 
	
	putexcel A`cell'="Panel `panel' (p-value)"
	putexcel F`cell'="`joint_test_`panel''"
	putexcel G`cell'="`sample_size_`panel''"
	
	local run_no = `run_no'+1
}


* Store count of number of people in each waiting group
forvalues n=1(1)4{
	count if waitB_cat==`n'
	local N_group`n' = r(N)
}

forvalues n=1(1)4{
	count if waitF_cat==`n'
	local N_group`n' = r(N)
}

* Sample size 
xttab waitB_cat if $Bsample
xttab waitF_cat if $Fsample




* 3. Pre-decision employment should not be correlated with waiting time 
*===============================================================================
********************************************************************************
* Placebo Test *
* Is time to decision correlated with pre-decision employment?
* Cross section sample restriction to those who are still asylum seekers (N)
********************************************************************************
** wait ------------------------------------------------------------------------
foreach y of varlist emp {

* Permit B 
	qui reg `y' waitB $covar if occur==1 & $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3placebo.xls, dec(3) ctitle(Obs. year1) append $spec ///
	keep(waitB) $fulltext 

	qui reg `y' waitB $covar if occur==2 & N_dum==1 & $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3placebo.xls, dec(3) ctitle(Obs. year2) append $spec ///
	keep(waitB) $fulltext 
	
	qui reg `y' waitB $covar if occur==3 & N_dum==1 & $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3placebo.xls, dec(3) ctitle(Obs. year3) append $spec ///
	keep(waitB) $fulltext 


* Permit F (only N->F; OMIT N->F->B)
	qui reg `y' waitF $covar if occur==1 & traject==3, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3placebo.xls, dec(3) ctitle(Obs. year1) append $spec ///
	keep(waitF) $fulltext 

	qui reg `y' waitF $covar if occur==2 & N_dum==1 & traject==3, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3placebo.xls, dec(3) ctitle(Obs. year2) append $spec ///
	keep(waitF) $fulltext

	qui reg `y' waitF $covar if occur==3 & N_dum==1 & traject==3, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3placebo.xls, dec(3) ctitle(Obs. year3) append $spec ///
	keep(waitF) $fulltext sortvar(waitB waitF)
}


** stay/wait ------------------------------------------------------------------------
foreach y of varlist emp {

* Permit B 
	qui reg `y' stay_waitB $covar if stay_waitB_plc==1 & $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3bplacebo.xls, dec(3) ctitle(Pre) append $spec ///
	keep(stay_waitB) $fulltext 

	qui reg `y' stay_waitB $covar if stay_waitB_plc==0 & $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3bplacebo.xls, dec(3) ctitle(Post) append $spec ///
	keep(stay_waitB) $fulltext 
	
	qui reg `y' c.stay_waitB##i.stay_waitB_plc $covar if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3bplacebo.xls, dec(3) ctitle(Full interact) append $spec ///
	keep(stay_waitB 1.stay_waitB_plc 1.stay_waitB_plc#c.stay_waitB ) $fulltext 


* Permit F (only N->F; OMIT N->F->B)
	qui reg `y' stay_waitF $covar if stay_waitF_plc==1 & $Fsample, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3bplacebo.xls, dec(3) ctitle(Pre) append $spec ///
	keep(stay_waitF) $fulltext 

	qui reg `y' stay_waitF $covar if stay_waitF_plc==0 & $Fsample, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3bplacebo.xls, dec(3) ctitle(Post) append $spec ///
	keep(stay_waitF) $fulltext

	qui reg `y' c.stay_waitF##i.stay_waitF_plc $covar if $Fsample, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/id/3bplacebo.xls, dec(3) ctitle(Full interact) append $spec ///
	keep(stay_waitF 1.stay_waitF_plc 1.stay_waitF_plc#c.stay_waitF ) $fulltext sortvar(waitB waitF)
}
	
