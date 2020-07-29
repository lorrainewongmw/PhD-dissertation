// The Language paper //

* Identification strategy; balancing test on the randomization of the asylum population

* Lorraine Wong, UCD
* Last update: 29 July 2020
* Stata version 14.2

set more off
********************************************************************************
* Balance *
********************************************************************************

* 1. Random sampling (independent and identically distributed)
*===============================================================================
global observables "sexst age_arrive i.highestcompleduaggi hhsize rural asylumseeker" // no top nationalities; mainlang(0/1) is sufficient
 
*-------------------------------------------------------------------------------
* Can observable characteristics predict canton of assignment? (Outcome = canton) 
*-------------------------------------------------------------------------------

** Pool OLS (include all observables) + top 10 nationality fe 
qui reg can1 $observables i.nid_pool i.charrivalyear i.year, vce(cluster id)
outreg2 using lang_paper/output/may/balance/eq3_nat.xls, dec(3) ctitle(can1) replace label nocons ///
drop(i.nid_pool i.charrivalyear i.year) addtext(Fixed effects yrayrnat, Yes)

forvalues i=2(1)26 {
	qui reg can`i' $observables i.nid_pool i.charrivalyear i.year, vce(cluster id)
	outreg2 using lang_paper/output/may/balance/eq3_nat.xls, dec(3) ctitle(can`i') append label nocons ///
	drop(i.nid_pool i.charrivalyear i.year) addtext(Fixed effects yrayrnat, Yes) ///
	sortvar(sexst age_arrive age i.highestcompleduaggi hhsize rural)
}


** all observables + top 10 nationality fe (Export for pyhton)
gen y=can1
qui reg y $observables i.nid_pool i.charrivalyear i.year, vce(cluster id)
matrix A= r(table)
putexcel set lang_paper/output/may/ex_py/eq3nat_pval.xlsx, sheet(can1, replace) modify
putexcel A1=matrix(A), names 
drop y

forvalues i=2(1)26 {
	gen y=can`i'
	qui reg y $observables i.nid_pool i.charrivalyear i.year, vce(cluster id)
	matrix A= r(table)
	putexcel set lang_paper/output/may/ex_py/eq3nat_pval.xlsx, sheet(can`i', replace) modify
	putexcel A1=matrix(A), names 
	drop y
}


*-------------------------------------------------------------------------------
* Can lingusitic proximity explain canton?
*-------------------------------------------------------------------------------
local candum "can1 can2 can3 can4 can5 can6 can7 can8 can9 can10 can11 can12 can13 can14 can15 can16 can17 can18 can19 can20 can21 can22 can23 can24 can25 can26"

// coefficient plot 1 - no prearrival controls //
qui reg can1 $treat i.nid_pool i.charrivalyear i.year, vce(cluster id)
est store can_1
outreg2 using lang_paper/output/may/balance/can_treat.xls, dec(3) ctitle(can1) replace label nocons ///
drop(i.nid_pool i.charrivalyear i.year) addtext(Fixed effects yrayrnat, Yes)

forvalues i=2(1)26 {
	qui reg can`i' $treat i.nid_pool i.charrivalyear i.year, vce(cluster id)
	est store can_`i'
	outreg2 using lang_paper/output/may/balance/can_treat.xls, dec(3) ctitle(can`i') append label nocons ///
	drop(i.nid_pool i.charrivalyear i.year) addtext(Fixed effects yrayrnat, Yes) 
}

#delimit ;
coefplot (can_*, color("31 119 180")),
keep($treat) 
asequation swapnames
eqrename(^can_(.*)$ = \1.Canton, regex)
xline(0, lcolor(red) lwidth(thin)) nokey
ciopts(recast(rcap) color("31 119 180"))
ysize(12) xsize(12) graphregion(color(white)) 
saving(lang_paper/graphs/can, replace)
;

est clear


*--------------------------------------------------------------------------------------------------
* Balance Table (Outcome = characteristics); By region
* Assignment to each canton is conditional on arrival year, top 10 nationalities, and outcome year
*--------------------------------------------------------------------------------------------------
global cantons "i1.Canton==i2.Canton==i3.Canton==i4.Canton==i5.Canton==i6.Canton==i7.Canton==i8.Canton==i9.Canton==i10.Canton==i11.Canton==i12.Canton==i13.Canton==i14.Canton==i15.Canton==i16.Canton==i17.Canton==i18.Canton==i19.Canton==i20.Canton==i21.Canton==i22.Canton==i23.Canton==i24.Canton==i25.Canton==i26.Canton"
global gecan "i1.Canton==i3.Canton==i4.Canton==i5.Canton==i6.Canton==i7.Canton==i8.Canton==i9.Canton==i11.Canton==i12.Canton==i13.Canton==i14.Canton==i15.Canton==i16.Canton==i17.Canton==i18.Canton==i19.Canton==i20.Canton"
global frcan "i21.Canton==i22.Canton==i24.Canton==i25.Canton==i26.Canton"
global bican "i2.Canton==i10.Canton==i23.Canton"

preserve
local arrive "sexst age_arrive"
local later "EDU1 EDU2 EDU3 hhsize rural asylumseeker"

putexcel set lang_paper/output/may/balance/2balance.xlsx, sheet(can, replace) modify
putexcel A1= "Outcome"
putexcel B1= "ZH"
putexcel C1= "BE"
putexcel D1= "LU"
putexcel E1= "UR"
putexcel F1= "SZ"
putexcel G1= "OW"
putexcel H1= "NW"
putexcel I1= "GL"
putexcel J1= "ZG"
putexcel K1= "FR"
putexcel L1= "SO"
putexcel M1= "BS"
putexcel N1= "BL"
putexcel O1= "SH"
putexcel P1= "AR"
putexcel Q1= "AI"
putexcel R1= "SG"
putexcel S1= "GR"
putexcel T1= "AG"
putexcel U1= "TG"
putexcel V1= "TI"
putexcel W1= "VD"
putexcel X1= "VS"
putexcel Y1= "NS"
putexcel Z1= "GE"
putexcel AA1= "JU"
putexcel AB1= "p-value(All)"
putexcel AC1= "p-value(Ger)"
putexcel AD1= "p-value(Rom)"
putexcel AE1= "p-value(Bil)"

local run_no = 1
qui foreach v in `arrive' `later' {
		
	* Sample size for the variable
	count if !mi(`v') 
	local sample_size = `r(N)'
	
	* Calculate means for all groups 
	reg `v' ibn.Canton i.nid_pool i.charrivalyear i.year , nocons vce(cluster id)
	sum `v' if e(sample) 

	* Test for equality across those enrolled in study
	test $cantons 
	local pval1 = `r(p)'
	
	test $gecan
	local pval2 = `r(p)'

	test $frcan 
	local pval3 = `r(p)'

	test $bican 
	local pval4 = `r(p)'

	
	* Label results and save excel
	local cell = `run_no'+1 
	
	putexcel A`cell'="`v'"
	putexcel B`cell'=_b[1.Canton]
	putexcel C`cell'=_b[2.Canton]
	putexcel D`cell'=_b[3.Canton]
	putexcel E`cell'=_b[4.Canton]
	putexcel F`cell'=_b[5.Canton]
	putexcel G`cell'=_b[6.Canton]
	putexcel H`cell'=_b[7.Canton]
	putexcel I`cell'=_b[8.Canton]
	putexcel J`cell'=_b[9.Canton]
	putexcel K`cell'=_b[10.Canton]
	putexcel L`cell'=_b[11.Canton]
	putexcel M`cell'=_b[12.Canton]
	putexcel N`cell'=_b[13.Canton]
	putexcel O`cell'=_b[14.Canton]
	putexcel P`cell'=_b[15.Canton]
	putexcel Q`cell'=_b[16.Canton]
	putexcel R`cell'=_b[17.Canton]
	putexcel S`cell'=_b[18.Canton]
	putexcel T`cell'=_b[19.Canton]
	putexcel U`cell'=_b[20.Canton]
	putexcel V`cell'=_b[21.Canton]
	putexcel W`cell'=_b[22.Canton]
	putexcel X`cell'=_b[23.Canton]
	putexcel Y`cell'=_b[24.Canton]
	putexcel Z`cell'=_b[25.Canton]
	putexcel AA`cell'=_b[26.Canton]
	putexcel AB`cell'=`pval1'
	putexcel AC`cell'=`pval2'
	putexcel AD`cell'=`pval3'
	putexcel AE`cell'=`pval4'
	
	local run_no = `run_no'+1
	restore, preserve
}

** Joint balance test and sample size
local arrive "sexst age_arrive"
local later "EDU1 EDU2 EDU3 hhsize rural asylumseeker"

putexcel set lang_paper/output/may/balance/2balance.xlsx, sheet(can_joint, replace) modify

putexcel A1= "Joint blanace test for Panel"
putexcel AB1= "p-value"
putexcel AC1= "Observations"

// All 26 cantons //
local run_no = 1
qui foreach panel in A B {

	     if "`panel'"=="A" local joint_test_vars "`arrive'"
	else if "`panel'"=="B" local joint_test_vars "`later'"
	else error 1
	
	reg Canton `joint_test_vars' i.nid_pool i.charrivalyear i.year, vce(cluster id)
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

// German and Romance cantons //
qui forvalues n=0(1)1 {
	qui foreach panel in A B {

	     if "`panel'"=="A" local joint_test_vars "`arrive'"
	else if "`panel'"=="B" local joint_test_vars "`later'"
	else error 1
	
	reg Canton `joint_test_vars' i.nid_pool i.charrivalyear i.year if lang_region==`n' & biling!=1 , vce(cluster id)
	test `joint_test_vars'
	
	local joint_test_`panel' = string(`r(p)',"%5.3f")
	local sample_size_`panel' = e(N)
	
	* Label results and save excel
	local cell = `run_no'+1 
	
	putexcel A`cell'="Panel `panel' for `n' cantons (p-value)"
	putexcel F`cell'="`joint_test_`panel''"
	putexcel G`cell'="`sample_size_`panel''"
	
	local run_no = `run_no'+1
	}
}

// Bilingual cantons //
qui foreach panel in A B {

	if "`panel'"=="A" local joint_test_vars "`arrive'"
	else if "`panel'"=="B" local joint_test_vars "`later'"
	else error 1
	
	reg Canton `joint_test_vars' i.nid_pool i.charrivalyear i.year if biling==1 , vce(cluster id)
	test `joint_test_vars'
	
	local joint_test_`panel' = string(`r(p)',"%5.3f")
	local sample_size_`panel' = e(N)
	
	* Label results and save excel
	local cell = `run_no'+1 
	
	putexcel A`cell'="Panel `panel' for Bilingual cantons (p-value)"
	putexcel F`cell'="`joint_test_`panel''"
	putexcel G`cell'="`sample_size_`panel''"
	
	local run_no = `run_no'+1
}





* 2. No perfect collinearity
*===============================================================================

*-------------------------------------------------------------------------------
* Regress Langauge on covariates * (by language region)
*-------------------------------------------------------------------------------
forvalues n=0(1)1 {
	qui reg std_LDND $observables i.charrivalyear i.year if lang_region ==`n', vce(cluster id)
	outreg2 using lang_paper/output/may/balance/trt_cov.xls, dec(3) ctitle(Basic_`n') append label nocons ///
	keep($observables) addtext(Fixed effects yrayr, Yes)

	qui reg std_LDND $observables i.nid_pool i.charrivalyear i.year if lang_region ==`n', vce(cluster id) // top10 nat
	outreg2 using lang_paper/output/may/balance/trt_cov.xls, dec(3) ctitle(Top10 nat) append label nocons ///
	keep($observables) addtext(Fixed effects yrayr, Yes, Top10 nationality FE, Yes, Country of origin characteristics, No)

	qui reg std_LDND $observables $origin i.charrivalyear i.year if lang_region ==`n', vce(cluster id) // add origin country controls
	outreg2 using lang_paper/output/may/balance/trt_cov.xls, dec(3) ctitle(Origin) append label nocons ///
	keep($observables) addtext(Fixed effects yrayr, Yes, Top10 nationality FE, No, Country of origin characteristics, Yes)
}





* 3. Assumption on zero conditional mean and normality
*===============================================================================

*========= Employment =========*
forvalues n=0(1)1 {

	qui reg emp $treat $covariates $origin if lang_region==`n', vce(cluster nat_can)
	predict res_e`n' if e(sample), residuals
	egen res_e`n'_std= std(res_e`n')
	
	predict fit_e`n' if e(sample), xb
	egen fit_e`n'_std= std(fit_e`n')
	
	**** Normality checks
	sum res_e`n'_std
	hist res_e`n'_std, kdenop(lc(red)) lcolor(white) fcolor("31 119 180") graphregion(color(white)) xtitle("Std residuals, employment") kdensity saving(lang_paper/graphs/rno_e`n'.gph, replace) // the standardized residuals should have a normal distribution
	qnorm res_e`n'_std, rlop(lc(red)) mcolor("31 119 180") graphregion(color(white)) ytitle("Employment, std residuals") graphregion(color(white)) saving(lang_paper/graphs/qno_e`n'.gph, replace) // compares with normal distribution

	**** Linearity checks: Plot residuals against Var (lfit to show the correlation between the two)
	scatter res_e`n'_std $treat, mc("31 119 180") || lfit res_e`n'_std $treat, lc(red) ///
	graphregion(color(white)) ytitle("Employment, std residuals") ///
	legend(off) saving(lang_paper/graphs/cno_e`n'.gph, replace)
			
	corr res_e`n'_std $treat // GE: r=0.00 // RO: r=0.00
	corr res_e`n'_std fit_e`n'_std // GE: r=0.00 // RO: r=0.00
}

*========= Living wage =========*
forvalues n=0(1)1 {

	qui reg emp_b $treat $covariates $origin if lang_region==`n', vce(cluster nat_can)
	predict res_eb`n' if e(sample), residuals
	egen res_eb`n'_std= std(res_eb`n')

	predict fit_eb`n' if e(sample), xb
	egen fit_eb`n'_std= std(fit_eb`n')
	
	**** Normality checks
	sum res_eb`n'_std
	hist res_eb`n'_std, kdenop(lc(red)) lcolor(white) fcolor("31 119 180") graphregion(color(white)) xtitle("Std residuals, living wage") kdensity saving(lang_paper/graphs/rno_eb`n'.gph, replace) // the standardized residuals should have a normal distribution
	qnorm res_eb`n'_std, rlop(lc(red)) mcolor("31 119 180") graphregion(color(white)) ytitle("Living wage, std residuals") graphregion(color(white)) saving(lang_paper/graphs/qno_eb`n'.gph, replace) // compares with normal distribution

	**** Linearity checks: Plot residuals against Var (lfit to show the correlation between the two)
	scatter res_eb`n'_std $treat, mc("31 119 180") || lfit res_eb`n'_std $treat, lc(red) ///
	graphregion(color(white)) ytitle("Living wage, std residuals") ///
	legend(off) saving(lang_paper/graphs/cno_eb`n'.gph, replace)
	
	corr res_eb`n'_std $treat // GE: r=0.00 // RO: r=0.00
	corr res_eb`n'_std fit_eb`n'_std // GE: r=0.00 // RO: r=0.00
}

*========= Log annual wage =========*
forvalues n=0(1)1 {

	qui reg lrevenu $treat $covariates $origin if lang_region==`n', vce(cluster nat_can)
	predict res_w`n' if e(sample), residuals
	egen res_w`n'_std= std(res_w`n')

	predict fit_w`n' if e(sample), xb
	egen fit_w`n'_std= std(fit_w`n')
	
	**** Normality checks
	sum res_w`n'_std
	hist res_w`n'_std, kdenop(lc(red)) lcolor(white) fcolor("31 119 180") graphregion(color(white)) xtitle("Std residuals, log annual wage") kdensity saving(lang_paper/graphs/rno_w`n'.gph, replace) // the standardized residuals should have a normal distribution
	qnorm res_w`n'_std, rlop(lc(red)) mcolor("31 119 180") graphregion(color(white)) ytitle("Log annual wage, std residuals") graphregion(color(white)) saving(lang_paper/graphs/qno_w`n'.gph, replace) // compares with normal distribution

	**** Linearity checks: Plot residuals against Var (lfit to show the correlation between the two)
	scatter res_w`n'_std $treat, mc("31 119 180") || lfit res_w`n'_std $treat, lc(red) ///
	graphregion(color(white)) ytitle("Log annual wage, std residuals") ///
	legend(off) saving(lang_paper/graphs/cno_w`n'.gph, replace)
	
	corr res_w`n'_std $treat // GE: r=0.00 // RO: r=0.00
	corr res_w`n'_std fit_w`n'_std // GE: r=0.00 // RO: r=0.00
}

// inspect mis-specification graphs (2X3)
gr combine lang_paper/graphs/cno_e0.gph lang_paper/graphs/cno_e1.gph ///
lang_paper/graphs/cno_eb0.gph lang_paper/graphs/cno_eb1.gph ///
lang_paper/graphs/cno_w0.gph lang_paper/graphs/cno_w1.gph, rows(3) cols(2) ysize(14) xsize(12)  graphregion(color(white)) ///
saving(lang_paper/graphs/idassume_zeromean, replace)

// nomality graphs (2X3)
gr combine lang_paper/graphs/qno_e0.gph lang_paper/graphs/qno_e1.gph ///
lang_paper/graphs/qno_eb0.gph lang_paper/graphs/qno_eb1.gph ///
lang_paper/graphs/qno_w0.gph lang_paper/graphs/qno_w1.gph, rows(3) cols(2) ysize(14) xsize(12) graphregion(color(white)) ///
saving(lang_paper/graphs/idassume_normal, replace)




*-------------------------------------------------------------------------------
* More on normality (Exclude outliers)
*-------------------------------------------------------------------------------
forvalues n=0(1)1 {
	*emp* 
	qui sum res_e`n'_std, detail
	gen emp_`n'_p1 = inrange(res_e`n'_std,`r(p1)',`r(p99)')
	gen emp_`n'_p5 = inrange(res_e`n'_std,`r(p5)',`r(p95)')
	gen emp_`n'_p10 = inrange(res_e`n'_std,`r(p10)',`r(p90)') 
	
	*emp_b* 
	qui sum res_eb`n'_std, detail
	gen emp_b_`n'_p1 = inrange(res_eb`n'_std,`r(p1)',`r(p99)')
	gen emp_b_`n'_p5 = inrange(res_eb`n'_std,`r(p5)',`r(p95)')
	gen emp_b_`n'_p10 = inrange(res_eb`n'_std,`r(p10)',`r(p90)') 
	
	*lrevenu* 
	qui sum res_w`n'_std, detail
	gen lrevenu_`n'_p1 = inrange(res_w`n'_std,`r(p1)',`r(p99)')
	gen lrevenu_`n'_p5 = inrange(res_w`n'_std,`r(p5)',`r(p95)')
	gen lrevenu_`n'_p10 = inrange(res_w`n'_std,`r(p10)',`r(p90)') 
}

// Appendix Table. Exclusion criteria for bilingual and birth information//
forvalues n=0(1)1{
	foreach y of varlist emp emp_b lrevenu {
	
	qui reg `y' $treat $covariates $origin if lang_region ==`n', vce(cluster nat_can) // main results
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/balance/normal`n'.xls, dec(3) ctitle(Main) append $spec ///
	keep($treat) $text_full

	qui reg `y' $treat $covariates $origin if lang_region ==`n' & `y'_`n'_p5, vce(cluster nat_can) // exclude top and bottom 5%
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/balance/normal`n'.xls, dec(3) ctitle(Excl.+-5%) append $spec ///
	keep($treat) $text_full
	
	qui reg `y' $treat $covariates $origin if lang_region ==`n' & `y'_`n'_p10, vce(cluster nat_can) // exclude top and bottom 10%
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/balance/normal`n'.xls, dec(3) ctitle(Excl.+-10%) append $spec ///
	keep($treat) $text_full
	}
}

tab SG_NAMKE_NID if emp_b_0_p5==0 & lang_region==0 // excluded 26% (n=241) from Sri Lanka, 20% (n=184) from Eritrea 

tab Canton if emp_b_0_p5==0 & lang_region==0 

tab Canton if emp_b_0_p5==0 & lang_region==0 & (SG_NAMKE_NID=="Eritrea" | SG_NAMKE_NID=="Sri Lanka")
