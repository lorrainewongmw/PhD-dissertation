// Paper 1 JMP - compare the LM outcomes between economic migrants and asylum populations //
* FUll CODE
* Lorraine Wong, UCD.
* Last update: 29 July 2020
* Stata version 14.2

* Get Data *
cd "/Users/lorrainewong/Documents/Geneve/UNIGE/NCCR/"
use "data/lorraine_analysis.dta", clear
set more off

********************************************************************************
* Globals in most .do files *
********************************************************************************
global control "sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free "
global controlfe "sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid i.year"
global controlfe_as "sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.Canton i.nationalityid i.year" // no arrival cohort fe

global spec "label nocons addstat(Sample mean, r(mean))"
global text_base "addtext(Individual characteristics, No, Fixed effects Y, Yes) nonotes"
global text_full "addtext(Individual characteristics, Yes, Fixed effects YACN, Yes) nonotes" // year, arrivalcohort, canton, nationality
global text_assim "addtext(Individual characteristics, Yes, Fixed effects YCN, Yes, Fixed effects A, No) nonotes" // year, canton, nationality


********************************************************************************
* Run .do files *
********************************************************************************

* label of the variables
run /Users/lorrainewong/github/asymig_paper/asymig_var.do // not available as the data is not publicly available

use data/lorraine_paper2_full.dta, clear

* descriptives
run /Users/lorrainewong/github/asymig_paper/asymig_des.do

* simulations by varying k and _delta
run /Users/lorrainewong/github/asymig_paper/asymig_sim.do

******************************************************************************** 
* MAIN RESULTS * 
******************************************************************************** 
corr emp sexst age age2 highestcompleduaggi mainlang hhsize free rural if asypop==1 // asylum
corr emp sexst age age2 highestcompleduaggi mainlang hhsize free rural if asypop==0 // migrants

********************************************************************************
* Pooled OLS * (Table 4)
******************************************************************************** 	
foreach y of varlist emp lrevenu {
	qui reg `y' asypop i.year, vce(cluster id_nat_can)  
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/main/t4_ols.xls, dec(3) ctitle(Base) append $spec ///
	drop(i.year) $text_base

	qui reg `y' asypop $controlfe , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/main/t4_ols.xls, dec(3) ctitle(Control) append $spec ///
	drop(i.year i.arrival_cohort i.Canton i.nationalityid) $text_full ///
	sortvar(asypop sexst age age2 2.highestcompleduaggi 3.highestcompleduaggi 1.mainlang 2.mainlang hhsize 1.free 2.free) 
	
	qui reg `y' asypop rural $controlfe , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/main/t4_ols.xls, dec(3) ctitle(Control) append $spec ///
	drop(i.year i.arrival_cohort i.Canton i.nationalityid) $text_full ///
	sortvar(asypop rural sexst age age2 2.highestcompleduaggi 3.highestcompleduaggi 1.mainlang 2.mainlang hhsize 1.free 2.free) 
}


********************************************************************************
* Oster * (Table 5)
******************************************************************************** 	
foreach y of varlist emp lrevenu {

	qui reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5, vce(cluster id_nat_can)  		
    local r_tilde1=e(r2)*1.3
	
	* Beta                		
	bs r(beta), reps(200) cluster(id_nat_can): psacalc beta asypop, model (reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5) ///
												rmax(`r_tilde1') mcontrol(y2 y3 y4 y5) 
	outreg2 using secondpaper/OUT/main/t5_b13.xls, dec(3) ctitle(`y') append label 
		
	* Delta 			
	qui reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5, vce(cluster id_nat_can)  		
    local r_tilde1=e(r2)*1.3

	psacalc delta asypop, rmax(`r_tilde1') mcontrol(y2 y3 y4 y5) 
	local d1=round(r(delta),.001)

	qui reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5, vce(cluster id_nat_can)  
	outreg2 using secondpaper/OUT/main/t5_model.xls, dec(3) ctitle(`y') append label nocons ///
	keep(asypop) addtext(D1.3,`d1')
}


********************************************************************************
* Assimilation pooled OLS * (Table 6)
******************************************************************************** 
foreach y of varlist emp lrevenu {
	qui reg `y' i.asypop##c.chduration $controlfe_as , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/main/t6_assim.xls, dec(3) ctitle(All`y') append $spec ///
	keep(1.asypop chduration 1.asypop#c.chduration) $text_assim
	
	qui reg `y' i.asypop##c.chduration $controlfe_as if recent==1, vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/main/t6_assim.xls, dec(3) ctitle(Recent`y') append $spec ///
	keep(1.asypop chduration 1.asypop#c.chduration) $text_assim
}


********************************************************************************
* Subgroup pooled OLS * (Table 7)
******************************************************************************** 
foreach y of varlist emp lrevenu {
	
	** Age at arrival (out= age age2)
	qui reg `y' asypop i.asypop##i.agearr_grp sexst i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid i.year, vce(cluster id_nat_can) 
	outreg2 using secondpaper/OUT/main/t7_subgroup.xls, side paren dec(3) ctitle(`y'_age) append label nocons ///
	keep(asypop 1.asypop##2.agearr_grp 1.asypop##3.agearr_grp 1.asypop##4.agearr_grp 1.asypop##5.agearr_grp 1.asypop##6.agearr_grp 1.asypop##7.agearr_grp) ///
	$text_full

	** Demo
	*** Female
	qui reg `y' asypop i.asypop##i.sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid i.year, vce(cluster id_nat_can)  // 1=female
	outreg2 using secondpaper/OUT/main/t7_subgroup.xls, side paren dec(3) ctitle(`y'_sex) append label nocons ///
	keep(asypop 1.asypop##1.sexst) $text_full 
	
	*** Recent (>2006) (out= arrive cohort)
	qui reg `y' asypop i.asypop##i.recent sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.Canton i.nationalityid i.year, vce(cluster id_nat_can)  // control + nid + arrival 
	outreg2 using secondpaper/OUT/main/t7_subgroup.xls, side paren dec(3) ctitle(`y'_recent) append label nocons ///
	keep(asypop 1.asypop##1.recent) $text_full 
	
	*** Former Yugoslavia
	qui reg `y' asypop i.asypop##i.yugos3 sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid i.year, vce(cluster id_nat_can)  // control + nid + arrival 
	outreg2 using secondpaper/OUT/main/t7_subgroup.xls,side paren dec(3) ctitle(`y'_war) append label nocons ///
	keep(asypop 1.asypop##1.yugos3 1.asypop##2.yugos3) $text_full 
}


********************************************************************************
* Robustness: Matching * (Table 8)
* useful: https://www.stata.com/meeting/spain18/slides/spain18_Arpino.pdf
******************************************************************************** 

* PSM 
*-------------------------------------------------------------------------------
capture log close
log using secondpaper/OUT/rob/psm.log, replace

qui logit asypop sexst $controlfe , vce(cluster id_nat_can)
predict double ps
sum ps // propensity score[0,1]
scalar cal=r(sd)*0.25 // caliper = 1/4 of the standard deviation of the ps

* Col 1: Nearest neighbor (n=4) 
psmatch2 asypop, outcome(emp lrevenu) pscore(ps) common n(4) // Abadie and Imbens (2006) suggests 4 neighbors minimizes mean-squared error. 
*psmatch2 asypop, outcome(emp lrevenu) pscore(ps) // robust
*psmatch2 asypop, outcome(emp lrevenu) pscore(ps) common n(2) // robust
*psmatch2 asypop, outcome(emp lrevenu) pscore(ps) common n(3) // robust

	/** Figure
	*** Balance check 
	pstest $controlfe , sum both // (APPENDINX TABLE 17)
	pstest $controlfe , both graph lab ysize(6) xsize(12)
	pstest $control nationalityid arrival_cohort Canton i.year, both graph  ysize(6) xsize(12)
	
	*** Matching quality 
	// Before //
	twoway (kdensity ps if asypop==1) (kdensity ps if asypop==0, ///
	lpattern(dash)), legend( label( 1 "Asylum populations") label( 2 "Economic migrant" ) ) ///
	xtitle("Propensity scores BEFORE matching") saving(secondpaper/OUT/july/before, replace)

	// After //
	gen match=_n1
	replace match=_id if match==.
	duplicates tag match, gen(dup)
	twoway (kdensity ps if asypop==1) (kdensity ps if asypop==0 ///
	& dup>0, lpattern(dash)), legend( label( 1 "Asylum populations") label( 2 "Economic migrant" )) ///
	xtitle("Propensity scores AFTER matching") saving(secondpaper/OUT/julyaug/after, replace)

	graph combine secondpaper/OUT/july/before.gph secondpaper/OUT/july/after.gph, ycommon ysize(6) xsize(12) 
	*/

* Col 2: Caliper/ radius
psmatch2 asypop, outcome(emp lrevenu) pscore(ps) common radius caliper(`=scalar(cal)') // nn caliper (1/4 sd), replace and common support
*psmatch2 asypop, outcome(emp lrevenu ) pscore(ps) common radius caliper(0.0005) // nn caliper, replace and common support; robust


* Col 3 : Kernel 
psmatch2 asypop, outcome(emp lrevenu) pscore(ps) common kernel kerneltype(epan) bwidth(0.08) // kernel matching approach

log close

* CEM 
*-------------------------------------------------------------------------------
preserve 
log using secondpaper/OUT/rob/cem.log, replace

keep id nationalityid SG_KONT_NID Canton asypop sexst age highestcompleduaggi mainlang ///
hhsize free arrival_cohort year emp lrevenu id_nat_can age_arrive
tab asypop

cem sexst age (#6) SG_KONT_NID free arrival_cohort Canton year, tr(asypop)  
save "data/jmp_cem.dta", replace
restore 


preserve 
keep id nationalityid SG_KONT_NID Canton asypop sexst age highestcompleduaggi mainlang ///
hhsize free arrival_cohort year emp lrevenu id_nat_can age_arrive
tab asypop

cem sexst age (#6) SG_KONT_NID free arrival_cohort Canton year highestcompleduaggi mainlang hhsize (#3), tr(asypop)  
save "data/jmp_cem2.dta", replace
restore 


preserve
** Col 4: CEM (pre-arrival)
use "data/jmp_cem.dta", replace
reg emp asypop i.highestcompleduaggi i.mainlang hhsize [iweight=cem_weights], vce(cluster id_nat_can)
reg lrevenu  asypop i.highestcompleduaggi i.mainlang hhsize[iweight=cem_weights], vce(cluster id_nat_can)

** Col 5: CEM (post-arrival)
use "data/jmp_cem2.dta", replace
reg emp asypop [iweight=cem_weights], vce(cluster id_nat_can)
reg lrevenu  asypop [iweight=cem_weights], vce(cluster id_nat_can)

log close
restore


********************************************************************************
* Robustnest: Adjust k, AET, and _delta * (Table 9)
******************************************************************************** 
* k=2
*-------------------------------------------------------------------------------
foreach y of varlist emp lrevenu {

	qui reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5, vce(cluster id_nat_can)  		
	local r_tilde2=e(r2)*2
	
	* Beta                			
	bs r(beta), reps(200) cluster(id_nat_can): psacalc beta asypop, model (reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5) ///
												rmax(`r_tilde2') mcontrol(y2 y3 y4 y5) 
	outreg2 using secondpaper/OUT/rob/t9_b20.xls, dec(3) ctitle(`y') append label  
	
	* Delta 			
	qui reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5, vce(cluster id_nat_can)  
	local r_tilde2=e(r2)*2
	
	psacalc delta asypop, rmax(`r_tilde2') mcontrol(y2 y3 y4 y5) 
	local d2=round(r(delta),.001)
	
	qui reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5, vce(cluster id_nat_can)  
	outreg2 using secondpaper/OUT/rob/t9_model.xls, dec(3) ctitle(`y') append label nocons ///
	keep(asypop) addtext(D2,`d2')
}


* AET
*-------------------------------------------------------------------------------
run /Users/lorrainewong/github/asymig_paper/asymig_AET.do // available upon request


* Higher delta (assume 1.25, 1.5, 1.75, 2)
*-------------------------------------------------------------------------------
foreach y of varlist emp lrevenu {

	qui reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5, vce(cluster id_nat_can)  		
    local r_tilde1=e(r2)*1.3
	
	// Beta //               		
	bs r(beta), reps(200) cluster(id_nat_can): psacalc beta asypop, model (reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5) ///
												rmax(`r_tilde1') mcontrol(y2 y3 y4 y5) 
	outreg2 using secondpaper/OUT/rob/t9_Hdelta.xls, dec(3) ctitle(`y'_1) append label 

	foreach d in 1.25 1.5 1.75 2 {
	bs r(beta), reps(200) cluster(id_nat_can): psacalc beta asypop, model (reg `y' asypop $control i.nationalityid i.arrival_cohort i.Canton y2 y3 y4 y5) ///
												rmax(`r_tilde1') mcontrol(y2 y3 y4 y5) delta(`d')
	outreg2 using secondpaper/OUT/rob/t9_Hdelta.xls, dec(3) ctitle(`y'_`d') append label 
	}
}










** APPENDIX BEGIN HERE
********************************************************************************
* Before and after policy (Appendix Table 4 + 5)
******************************************************************************** 
forvalues i=2010(1)2014 {
	foreach y of varlist emp lrevenu {
	
		qui reg `y' asypop asypop##i.policy $control i.arrival_cohort i.Canton i.nationalityid if year==`i', vce(cluster nid_canton) 
		qui sum `y' if e(sample)
		outreg2 using secondpaper/OUT/append/ta4_policy_`y'.xls, dec(3) ctitle(`i') append $spec ///
		keep(asypop 1.asypop##1.policy) addtext(Individual characteristics, Yes, Fixed effects ACN, Yes, Fixed effects Y, No) nonotes
	}
}

foreach y of varlist emp lrevenu {
	qui reg `y' asypop asypop##i.policy $controlfe , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta4_policy_`y'.xls, dec(3) ctitle(pool) append $spec ///
	keep(asypop 1.asypop##1.policy) $text_full
}


********************************************************************************
* Different fixed effects (Appendix Table 6)
******************************************************************************** 
foreach y of varlist emp lrevenu {
	qui reg `y' asypop asypop $controlfe , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta6_fe.xls, dec(3) ctitle(Ctrl) append $spec ///
	keep(asypop) addtext(Individual characteristics, Yes, Fixed effects YACN, Yes, Fixed effects AN, No, Fixed effects AC, No) 
	
	qui reg `y' asypop asypop $control i.arrival_cohort##i.nationalityid i.Canton i.year, vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta6_fe.xls, dec(3) ctitle(Fe1) append $spec ///
	keep(asypop) addtext(Individual characteristics, Yes, Fixed effects YACN, Yes, Fixed effects AN, Yes, Fixed effects AC, No) 
	
	qui reg `y' asypop asypop $control i.arrival_cohort##i.Canton i.nationalityid i.year, vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta6_fe.xls, dec(3) ctitle(Fe2) append $spec ///
	keep(asypop) addtext(Individual characteristics, Yes, Fixed effects YACN, Yes, Fixed effects AN, Yes, Fixed effects AC, Yes) 
}


********************************************************************************
* OLS, probit, logit (Appendix Table 7)
******************************************************************************** 
* Uncontrolled regression 
qui reg emp asypop i.year, vce(cluster id_nat_can)  
qui sum emp if e(sample)
outreg2 using secondpaper/OUT/append/ta7_plogit.xls, dec(3) ctitle(OLS Base) replace $spec ///
keep(asypop) $text_base

qui logit emp asypop i.year, vce(cluster id_nat_can) 
margins, dydx(_all) post 
qui sum emp if e(sample)
outreg2 using secondpaper/OUT/append/ta7_plogit.xls, dec(3) ctitle(Logit Base) append $spec ///
keep(asypop) $text_base

qui probit emp asypop i.year, vce(cluster id_nat_can)
margins, dydx(_all) post
qui sum emp if e(sample)  
outreg2 using secondpaper/OUT/append/ta7_plogit.xls, dec(3) ctitle(Probit Base) append $spec ///
keep(asypop) $text_base

* Controlled regression
qui reg emp asypop $controlfe , vce(cluster id_nat_can) 
qui sum emp if e(sample)
outreg2 using secondpaper/OUT/append/ta7_plogit.xls, dec(3) ctitle(OLS Control) append $spec ///
keep (asypop) $text_full

qui logit emp asypop $controlfe , vce(cluster id_nat_can) 
margins, dydx(asypop) post
qui sum emp if e(sample)
outreg2 using secondpaper/OUT/append/ta7_plogit.xls, dec(3) ctitle(Logit Control) append $spec ///
keep (asypop) $text_full

qui probit emp asypop $controlfe , vce(cluster id_nat_can) 
margins, dydx(asypop) post
qui sum emp if e(sample) 
outreg2 using secondpaper/OUT/append/ta7_plogit.xls, dec(3) ctitle(Probit Control) append $spec ///
keep (asypop) $text_full


********************************************************************************
* Simple cross and pool (Appendix Table 8 + 9)
******************************************************************************** 
forvalues i=2010(1)2014 {
	foreach y of varlist emp lrevenu {
		qui reg `y' asypop $control i.arrival_cohort i.Canton i.nationalityid if year==`i', vce(cluster nid_canton) 
		qui sum `y' if e(sample)
		outreg2 using secondpaper/OUT/append/ta89_xpool_`y'.xls, dec(3) ctitle(`i') append $spec ///
		keep(asypop) addtext(Individual characteristics, Yes, Fixed effects ACN, Yes, Fixed effects Y, No) nonotes
	}
}

foreach y of varlist emp lrevenu {
	qui reg `y' asypop $controlfe , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta89_xpool_`y'.xls, dec(3) ctitle(Pool) append $spec ///
	keep(asypop) $text_full
}


********************************************************************************
* Duration of stay dummy interactions (Appendix Table 11)
******************************************************************************** 
foreach y of varlist emp lrevenu {
	qui reg `y' i.asypop##i.duration_cat2 $controlfe_as , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta11_assim.xls, side paren dec(3) ctitle(All`y') append $spec ///
	keep(1.asypop i.duration_cat2 1.asypop#i.duration_cat2) $text_assim
}


********************************************************************************
* Bounds by duration of stay (Appendix Table 12 + 13)
******************************************************************************** 
foreach y of varlist emp lrevenu {
	forvalues i=1(1)7 {
	
		preserve 
		keep if duration_cat2==`i'
		
		qui reg `y' asypop sexst age age2 i.mainlang hhsize i.highestcompleduaggi i.free i.Canton i.nationalityid chduration i.year, vce(cluster id_nat_can) 
		local r_tilde1=e(r2)*1.3

		// Beta //               		
		bs r(beta), reps(200) cluster(id_nat_can): psacalc beta asypop, model (reg `y' asypop $control i.nationalityid chduration i.Canton y2 y3 y4 y5) ///
													rmax(`r_tilde1') mcontrol(y2 y3 y4 y5) 
		outreg2 using secondpaper/OUT/append/ta1213_b13_`y'.xls, dec(3) ctitle(`i') append label 

		// Delta //			
		qui reg `y' asypop $control i.nationalityid chduration i.Canton y2 y3 y4 y5, vce(cluster id_nat_can)  
		local r_tilde1=e(r2)*1.3
		
		psacalc delta asypop, rmax(`r_tilde1') mcontrol(y2 y3 y4 y5) 
		local d1=round(r(delta),.001)

		qui reg `y' asypop $control i.nationalityid chduration i.Canton y2 y3 y4 y5, vce(cluster id_nat_can)
		qui sum `y' if e(sample)
		outreg2 using secondpaper/OUT/append/ta1213_model_`y'.xls, dec(3) ctitle(`i') append $spec ///
		keep(asypop) addtext(D1.3,`d1')	
			
		restore
	}
}


********************************************************************************
* Recent arrivals - cross + pool (Appendix Table 14 + 15)
******************************************************************************** 
foreach y of varlist emp lrevenu {

	forvalues i=2010(1)2014{
		qui reg `y' asypop sexst age age2 i.mainlang hhsize i.highestcompleduaggi i.free chduration i.Canton i.nationalityid if recent==1 & year==`i', vce(cluster nid_canton) 
		qui sum `y' if e(sample)
		outreg2 using secondpaper/OUT/append/ta1415_recent_`y'.xls, dec(3) ctitle(`i') append $spec ///
		keep(asypop) addtext(Individual characteristics, Yes, Fixed effects CN, Yes, Fixed effects Y, No, Fixed effects A, No) nonotes
	}
	
	qui reg `y' asypop sexst age age2 i.mainlang hhsize i.highestcompleduaggi i.free chduration i.Canton i.nationalityid i.year if recent==1, vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta1415_recent_`y'.xls, dec(3) ctitle(pool) append $spec ///
	keep(asypop) addtext(Individual characteristics, Yes, Fixed effects CN, Yes, Fixed effects Y, Yes, Fixed effects A, No) nonotes
}	


********************************************************************************
* Unconditional LM outcomes by demographic groups (Appendix Table 16)
******************************************************************************** 
tabout female yugos3 recent permisc permisnat active rural lang_region emp if asypop==1 using secondpaper/OUT/des/ta16_emp_asy.xls, c(freq row) lay(cb) replace 
tabout female yugos3 recent permisc permisnat active rural lang_region emp if asypop==0 using secondpaper/OUT/des/ta16_emp_mig.xls, c(freq row) lay(cb) replace 

capture log close
log using secondpaper/OUT/des/ta16_wages.log, replace

foreach i of varlist female yugos3 recent permisc permisnat active rural lang_region {
	tabout `i' if asypopo==1 using secondpaper/OUT/des/ta16_wages_asy.xls, sum cells (N revenu mean revenu) f(2) append
	tabout `i' if asypopo==0 using secondpaper/OUT/des/ta16_wages_mig.xls, sum cells (N revenu mean revenu) f(2) append
} 
log close

**************** PSM Descriptives (Appdneix Table 17) SEE ABOVE ****************

******************************************************************************** 
* COB fe: cross section and pooled (Appendix Table 18)
******************************************************************************** 
forvalues i=2010(1)2014 {
	foreach y of varlist emp lrevenu {
		qui reg `y' asypop $control i.arrival_cohort i.Canton i.birthplace if year==`i', vce(cluster cid_canton) 
		qui sum `y' if e(sample)
		outreg2 using secondpaper/OUT/append/ta18_cobxpool_`y'.xls, dec(3) ctitle(`i') append $spec ///
		keep(asypop) nonotes
	}
}

foreach y of varlist emp lrevenu {
	qui reg `y' asypop $control i.arrival_cohort i.Canton i.birthplace i.year, vce(cluster id_cob_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta18_cobxpool_`y'.xls, dec(3) ctitle(pool) append $spec ///
	keep(asypop) nonotes
}


******************************************************************************** 
* COB fe: All and recent (Appendix Table 19)
******************************************************************************** 
foreach y of varlist emp lrevenu {
	qui reg `y' i.asypop##c.chduration $control i.Canton i.birthplace i.year, vce(cluster id_cob_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta19_cobrecent.xls, dec(3) ctitle(All`x') append $spec ///
	keep(1.asypop chduration 1.asypop#c.chduration) addtext(Individual characteristics, Yes, Fixed effects YCB, Yes, Fixed effects A, No) nonotes
		
	qui reg `y' i.asypop##c.chduration $control i.Canton i.birthplace i.year if recent==1, vce(cluster id_cob_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta19_cobrecent.xls, dec(3) ctitle(Recent`x') append $spec ///
	keep(1.asypop chduration 1.asypop#c.chduration) addtext(Individual characteristics, Yes, Fixed effects YCB, Yes, Fixed effects A, No) nonotes
}


******************************************************************************** 
* COB fe: Stairs (Appendix Table 20)
******************************************************************************** 
foreach y of varlist emp lrevenu {
	forvalues i=1(1)7 {
		qui reg `y' asypop sexst age age2 i.mainlang hhsize i.highestcompleduaggi i.free i.Canton i.birthplace chduration i.year if duration_cat2==`i', vce(cluster id_cob_can) 
		qui sum `y' if e(sample)
		outreg2 using secondpaper/OUT/append/ta20_cobassim_`y'.xls, dec(3) ctitle(`i') append $spec ///
		keep(asypop) nonotes
	}
}	


******************************************************************************** 
* Quantile: cross section and pooled * (Appendix Table 21 + 22)
******************************************************************************** 
set mat 10000
log using secondpaper/OUT/append/ta2122_qreg.log, replace

preserve
keep lrevenu asypop sexst age age2 highestcompleduaggi mainlang hhsize free arrival_cohort Canton nationalityid year

* CROSS SECTION *
forvalues i=2010(1)2014 {
	sqreg lrevenu asypop $control i.arrival_cohort i.Canton i.nationalityid if year==`i', q(.1 .25 .5 .75 .9)

	test[q25]asypop = [q50]asypop
	test[q75]asypop = [q50]asypop
	test[q10]asypop = [q25]asypop = [q50]asypop = [q75]asypop = [q90]asypop
}	
	
* POOL *
sqreg lrevenu asypop $control i.arrival_cohort i.Canton i.nationalityid, q(.1 .25 .5 .75 .9)
test[q25]asypop = [q50]asypop
test[q75]asypop = [q50]asypop
test[q10]asypop = [q25]asypop = [q50]asypop = [q75]asypop = [q90]asypop

restore 

log close

******************************************************************************** 
* Sample adjust 15 or 20 (Appendix Table 23)
******************************************************************************** 
foreach y of varlist emp lrevenu {

	qui reg `y' asypop $controlfe , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta23_nadj.xls, dec(3) ctitle(Control) append $spec ///
	keep(asypop) $text_full
	
	preserve 
	#delimit ;
	drop if SG_NAMKE_NID=="Albania" | 	// included with pre-1988 arrivals
	SG_NAMKE_NID=="Egypt" | 
	SG_NAMKE_NID=="Hungary" |  			// added with pre 1988 sample
	SG_NAMKE_NID=="India" |  			// added with pre 1988 sample
	SG_NAMKE_NID=="Mongolia" |
	SG_NAMKE_NID=="Yemen" ;
	#delimit cr
	// 6 nationalities dropped (16,410 observations deleted)
	
	qui reg `y' asypop $controlfe , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta23_nadj.xls, dec(3) ctitle(`y'_N15) append $spec ///
	keep(asypop) $text_full
	
	#delimit ;
	drop if SG_NAMKE_NID=="Azerbaijan" |
	SG_NAMKE_NID=="Burundi" | 
	SG_NAMKE_NID=="Central Serbia" |
	SG_NAMKE_NID=="Georgia" |
	SG_NAMKE_NID=="Laos" |
	SG_NAMKE_NID=="Montenegro" |
	SG_NAMKE_NID=="Nigeria" |
	SG_NAMKE_NID=="Romania" | 			// added with pre 1988 sample
	SG_NAMKE_NID=="Tibet" ;
	#delimit cr
	// 9 more nationalities dropped (11,647 observations deleted)
	
	qui reg `y' asypop $controlfe , vce(cluster id_nat_can) 
	qui sum `y' if e(sample)
	outreg2 using secondpaper/OUT/append/ta23_nadj.xls, dec(3) ctitle(`y'_N20) append $spec ///
	keep(asypop) $text_full
	
	restore
}

*-------- END --------*



