// Paper 3 - The effect of waiting time on LM outcomes //
* Lorraine Wong, UCD.
* Last update: 29 July 2020
* Stata version 14.2

cd "/Users/lorrainewong/Documents/Geneve/UNIGE/NCCR/"
use "data/asy_0514_income.dta", clear

set more off 
sort id year
set matsize 8000

********************************************************************************
* Globals in most .do files *
********************************************************************************
global Bsample "traject==4"
global Fsample "(traject==3 | traject==5)"

global covarNOFE "sexst age age2 i.highestcompleduaggi lang_2 hhsize rural" 
global covar "sexst age age2 i.highestcompleduaggi lang_2 hhsize rural i.charrivalyear##ib8362.nationalityid i.Canton i.year" 
global spec "label nocons addstat(Sample mean, r(mean))"
global fulltext "addtext(Individual characteristics, Yes, Fixed effects yrnatXayearcan, Yes) nonotes"


********************************************************************************
* Run .do files *
********************************************************************************

* label of the variables
run /Users/lorrainewong/github/wait_paper/wait_var.do // Not available as the data is not publicly available

* descriptives
run /Users/lorrainewong/github/wait_paper/wait_des.do

* identification
run /Users/lorrainewong/github/wait_paper/wait_id.do


********************************************************************************
********************************************************************************
* Results *
********************************************************************************
********************************************************************************

// B - Treatment = Waiting time //
foreach y of varlist emp lrevenu {
	qui reg `y' waitB i.charrivalyear i.year if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/1waitB.xls, dec(3) ctitle(No controls) append $spec ///
	keep(waitB) addtext(Individual characteristics, No, Year FE, Yes, Arrival year FE, Yes, Nationality FE, No, Canton FE, No, Nationality X Arrival year FE, No) nonot

	qui reg `y' waitB $covarNOFE i.year i.charrivalyear ib8362.nationalityid i.Canton if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/1waitB.xls, dec(3) ctitle(Separate FE) append $spec ///
	keep(waitB $covarNOFE ) addtext(Individual characteristics, Yes, Year FE, Yes, Arrival year FE, Yes, Nationality FE, Yes, Canton FE, Yes, Nationality X Arrival year FE, No)
	
	qui reg `y' waitB $covar if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/1waitB.xls, dec(3) ctitle(Main) append $spec ///
	keep(waitB $covarNOFE ) addtext(Individual characteristics, Yes, Year FE, Yes, Arrival year FE, Yes, Nationality FE, Yes, Canton FE, Yes, Nationality X Arrival year FE, Yes)
}	


// F - Treatment = Waiting time //
foreach y of varlist emp lrevenu {
	qui reg `y' waitF i.charrivalyear i.year if $Fsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/2waitF.xls, dec(3) ctitle(No controls) append $spec ///
	keep(waitF) addtext(Individual characteristics, No, Year FE, Yes, Arrival year FE, Yes, Nationality FE, No, Canton FE, No, Nationality X Arrival year FE, No) nonot

	qui reg `y' waitF $covarNOFE i.year i.charrivalyear ib8362.nationalityid i.Canton if $Fsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/2waitF.xls, dec(3) ctitle(Separate FE) append $spec ///
	keep(waitF $covarNOFE ) addtext(Individual characteristics, Yes, Year FE, Yes, Arrival year FE, Yes, Nationality FE, Yes, Canton FE, Yes, Nationality X Arrival year FE, No)

	qui reg `y' waitF ib3.traject $covar if $Fsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/2waitF.xls, dec(3) ctitle(Main) append $spec ///
	keep(waitF 5.traject $covarNOFE ) addtext(Individual characteristics, Yes, Year FE, Yes, Arrival year FE, Yes, Nationality FE, Yes, Canton FE, Yes, Nationality X Arrival year FE, Yes)

	qui reg `y' waitF preFwage_any ib3.traject $covar if $Fsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/2waitF.xls, dec(3) ctitle(predecision) append $spec ///
	keep(waitF 5.traject preFwage_any $covarNOFE ) addtext(Individual characteristics, Yes, Year FE, Yes, Arrival year FE, Yes, Nationality FE, Yes, Canton FE, Yes, Nationality X Arrival year FE, Yes)

	qui reg `y' waitF l.emp ib3.traject $covar if $Fsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/2waitF.xls, dec(3) ctitle(lag emp) append $spec ///
	keep(waitF 5.traject l.emp $covarNOFE ) addtext(Individual characteristics, Yes, Year FE, Yes, Arrival year FE, Yes, Nationality FE, Yes, Canton FE, Yes, Nationality X Arrival year FE, Yes) ///
	sortvar(waitF preFwage_any l.emp)
}


********************************************************************************
* Nonlinear effects 
********************************************************************************

// Figure. categorical graphs (alternative: margins // marginsplot) //
foreach y of varlist emp lrevenu {

* Permit B
	qui reg `y' ibn.waitB_cat $covar if $Bsample , nocons cluster(id_can)
	matrix A= r(table)
	putexcel set lastpaper/output/may/main/3nonlin_nocons.xlsx, sheet(waitB_`y', replace) modify
	putexcel A1=matrix(A), names 

* Permit F
	qui reg `y' ibn.waitF_cat ib3.traject $covar if $Fsample , nocons cluster(id_can)
	matrix A= r(table)
	putexcel set lastpaper/output/may/main/3nonlin_nocons.xlsx, sheet(waitF_`y', replace) modify
	putexcel A1=matrix(A), names 
}


// Table. Waiting time dummy //
foreach y of varlist emp lrevenu {

* Permit B 
	qui reg `y' ibn.waitB_cat $covar if $Bsample , cluster(id_can) nocons
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/3nonlin.xls, dec(3) ctitle(`y') append $spec ///
	keep(1bn.waitB_cat 2.waitB_cat 3.waitB_cat 4.waitB_cat) $fulltext ///
	sortvar(1bn.waitB_cat 2.waitB_cat 3.waitB_cat 4.waitB_cat)

* Permit F
	qui reg `y' ibn.waitF_cat ib3.traject $covar if $Fsample , cluster(id_can) nocons
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/3nonlin.xls, dec(3) ctitle(`y') append $spec ///
	keep(1bn.waitF_cat 2.waitF_cat 3.waitF_cat 4.waitF_cat) $fulltext ///
	sortvar(1bn.waitF_cat 2.waitF_cat 3.waitF_cat 4.waitF_cat)
	
	qui reg `y' ibn.waitF_cat5 ib3.traject $covar if $Fsample , cluster(id_can) nocons
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/3nonlin.xls, dec(3) ctitle(`y') append $spec ///
	keep(1bn.waitF_cat5 2.waitF_cat5 3.waitF_cat5 4.waitF_cat5 5.waitF_cat5) $fulltext ///
	sortvar(1bn.waitB_cat 2.waitB_cat 3.waitB_cat 4.waitB_cat 1bn.waitF_cat 2.waitF_cat 3.waitF_cat 4.waitF_cat 1bn.waitF_cat5 2.waitF_cat5 3.waitF_cat5 4.waitF_cat5 5.waitF_cat5)
}

********************************************************************************
* Adjusted duration of stay (Time stay/ Time wait)
********************************************************************************
foreach y of varlist emp lrevenu {

	qui reg `y' stay_waitB $covar if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/5stay_wait.xls, dec(3) ctitle(Permit B) append $spec ///
	keep(stay_waitB) $fulltext 
	
	qui reg `y' stay_waitB preBwage_any $covar if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/5stay_wait.xls, dec(3) ctitle(Pre B) append $spec ///
	keep(stay_waitB preBwage_any) $fulltext ///
	
	qui reg `y' stay_waitB l.emp $covar if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/5stay_wait.xls, dec(3) ctitle(lag emp) append $spec ///
	keep(stay_waitB l.emp) $fulltext 
	
	qui reg `y' stay_waitF ib3.traject $covar if $Fsample, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/5stay_wait.xls, dec(3) ctitle(Permit F) append $spec ///
	keep(stay_waitF) $fulltext 
	
	qui reg `y' stay_waitF preFwage_any ib3.traject $covar if $Fsample, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/5stay_wait.xls, dec(3) ctitle(Pre F) append $spec ///
	keep(stay_waitF preFwage_any) $fulltext ///
	
	qui reg `y' stay_waitF l.emp ib3.traject $covar if $Fsample, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/5stay_wait.xls, dec(3) ctitle(lag emp) append $spec ///
	keep(stay_waitF l.emp) $fulltext ///
	sortvar(stay_waitB stay_waitF preBwage_any preFwage_any l.emp)
}	

corr ayear_* CHduration waitB if $Bsample
corr ayear_* CHduration waitF if $Fsample


* Available upon request material
*-------------------------------------------------------------------------------
// Conditional on same waiting time //
foreach y of varlist emp lrevenu {

	qui reg `y' c.stay_waitB##i.waitB_cat $covar if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/6samewait.xls, dec(3) ctitle(Permit B) append $spec ///
	keep(stay_waitB i.waitB 1.waitB_cat#c.stay_waitB 2.waitB_cat#c.stay_waitB 3.waitB_cat#c.stay_waitB 4.waitB_cat#c.stay_waitB) $fulltext 
	
	qui reg `y' c.stay_waitF##i.waitF_cat ib3.traject $covar if $Fsample, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/6samewait.xls, dec(3) ctitle(Permit F) append $spec ///
	keep(stay_waitF i.waitF 1.waitF_cat#c.stay_waitF 2.waitF_cat#c.stay_waitF 3.waitF_cat#c.stay_waitF 4.waitF_cat#c.stay_waitF) $fulltext ///
	sortvar(stay_waitB stay_waitF)
}


// Conditional on same length of stay //
foreach y of varlist emp lrevenu {

	qui reg `y' c.stay_waitB##i.charrivalyear $covar if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/6samestay.xls, dec(3) ctitle(Permit B) append $spec ///
	keep(stay_waitB i.charrivalyear 2006.charrivalyear#c.stay_waitB 2007.charrivalyear#c.stay_waitB ///
		2008.charrivalyear#c.stay_waitB 2009.charrivalyear#c.stay_waitB 2010.charrivalyear#c.stay_waitB ///
		2011.charrivalyear#c.stay_waitB 2012.charrivalyear#c.stay_waitB 2013.charrivalyear#c.stay_waitB) $fulltext 
	
	qui reg `y' c.stay_waitF##i.i.charrivalyear ib3.traject $covar if $Fsample, cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/6samestay.xls, dec(3) ctitle(Permit F) append $spec ///
	keep(stay_waitF i.charrivalyear 2006.charrivalyear#c.stay_waitF 2007.charrivalyear#c.stay_waitF ///
		2008.charrivalyear#c.stay_waitF 2009.charrivalyear#c.stay_waitF 2010.charrivalyear#c.stay_waitF ///
		2011.charrivalyear#c.stay_waitF 2012.charrivalyear#c.stay_waitF 2013.charrivalyear#c.stay_waitF) $fulltext ///
		sortvar(stay_waitB stay_waitF)
}



// Table. Investigate occupations pre- and post-permit decision (stay_waitB_plc==1 is pre-decision) //
tabout isco_skill stay_waitB_plc if $Bsample using lastpaper/output/may/des/skill.xls, cells(freq col) format(0c 2) replace 
tabout isco_skill stay_waitF_plc if $Fsample using lastpaper/output/may/des/skill.xls, cells(freq col) format(0c 2) append

bys isco_skill: groups isco_description if $Bsample, order(h) select(5)
bys isco_skill: groups isco_description if $Fsample, order(h) select(5)





********************************************************************************
********************************************************************************
* ROBUSTNESS *
********************************************************************************
********************************************************************************

********************************************************************************
* Robustness Test *
* Selection on unobservables
********************************************************************************

// Table. Selection on unobservables //
* Categorical dummies
tab year, gen(y) // canton dummies are already here

global control "sexst age age2 i.highestcompleduaggi hhsize rural lang_2 i.Canton ib8362.nationalityid i.charrivalyear#ib8362.nationalityid"
global base "y2 y3 y4 y5 ayear_2 ayear_3 ayear_4 ayear_5 ayear_6 ayear_7 ayear_8 ayear_9"

foreach y of varlist emp {	
	
	* Permit B *
	foreach x of varlist waitB stay_waitB {
	
		qui reg `y' `x' $control $base if $Bsample, vce(cluster id_can)  
		local r_tilde1=e(r2)*1.3
		local r_tilde2=e(r2)*2

		// Beta //               
		psacalc beta `x', rmax(`r_tilde1') mcontrol($base)        
		local b1=round(r(beta),.001)
		
		psacalc beta `x', rmax(`r_tilde2') mcontrol($base)   
		local b2=round(r(beta),.001) 	
				
		// Delta //			
		psacalc delta `x', rmax(`r_tilde1') mcontrol($base)  
		local d1=round(r(delta),.001)
		
		psacalc delta `x', rmax(`r_tilde2') mcontrol($base)  
		local d2=round(r(delta),.001)
			
		qui reg `y' `x' $control $base if $Bsample , vce(cluster id_can)  
		qui sum `y' if e(sample)
		outreg2 using lastpaper/output/may/rob/1oster.xls, dec(3) ctitle(`y'_B) append $spec  ///	
		keep(`x') addtext(B1.3,`b1', D1.3,`d1', B2,`b2', D2,`d2', Individual characteristics, Yes, Fixed effects yrnatXayearcan, Yes) nonotes
	}
	
	* Permit F *
	foreach x of varlist waitF stay_waitF {
	
		qui reg `y' `x' ib3.traject $control $base if $Fsample, vce(cluster id_can)  
		local r_tilde1=e(r2)*1.3
		local r_tilde2=e(r2)*2 // because r2=0.549 (B) and 0.577(F)

		// Beta //               
		psacalc beta `x', rmax(`r_tilde1') mcontrol($base)        
		local b1=round(r(beta),.001)
		
		psacalc beta `x', rmax(`r_tilde2') mcontrol($base)   
		local b2=round(r(beta),.001) 	
				
		// Delta //			
		psacalc delta `x', rmax(`r_tilde1') mcontrol($base)  
		local d1=round(r(delta),.001)
		
		psacalc delta `x', rmax(`r_tilde2') mcontrol($base)  
		local d2=round(r(delta),.001)
			
		qui reg `y' `x' ib3.traject $control $base if $Fsample , vce(cluster id_can)  
		qui sum `y' if e(sample)
		outreg2 using lastpaper/output/may/rob/1oster.xls, dec(3) ctitle(`y'_F) append $spec  ///	
		keep(`x') addtext(B1.3,`b1', D1.3,`d1', B2,`b2', D2,`d2', Individual characteristics, Yes, Fixed effects yrnatXayearcan, Yes) nonotes
	}
}


foreach y of varlist lrevenu {	
	
	* Permit B *
	foreach x of varlist waitB stay_waitB {
	
		qui reg `y' `x' $control $base if $Bsample, vce(cluster id_can)  
		local r_tilde1=e(r2)*1.3
		*local r_tilde2=e(r2)*2

		// Beta //               
		psacalc beta `x', rmax(`r_tilde1') mcontrol($base)        
		local b1=round(r(beta),.001)
		
		/* psacalc beta `x', rmax(`r_tilde2') mcontrol($base)   
		local b2=round(r(beta),.001) */	
				
		// Delta //			
		psacalc delta `x', rmax(`r_tilde1') mcontrol($base)  
		local d1=round(r(delta),.001)
		
		/* psacalc delta `x', rmax(`r_tilde2') mcontrol($base)  
		local d2=round(r(delta),.001) */
			
		qui reg `y' `x' $control $base if $Bsample , vce(cluster id_can)  
		qui sum `y' if e(sample)
		outreg2 using lastpaper/output/may/rob/1oster.xls, dec(3) ctitle(`y'_B) append $spec  ///	
		keep(`x') addtext(B1.3,`b1', D1.3,`d1', Individual characteristics, Yes, Fixed effects yrnatXayearcan, Yes) nonotes
	}
	
	* Permit F *
	foreach x of varlist waitF stay_waitF {
	
		qui reg `y' `x' ib3.traject $control $base if $Fsample, vce(cluster id_can)  
		local r_tilde1=e(r2)*1.3
		*local r_tilde2=e(r2)*2 // because r2=0.549 (B) and 0.577(F)

		// Beta //               
		psacalc beta `x', rmax(`r_tilde1') mcontrol($base)        
		local b1=round(r(beta),.001)
		
		/*psacalc beta `x', rmax(`r_tilde2') mcontrol($base)   
		local b2=round(r(beta),.001) */
				
		// Delta //			
		psacalc delta `x', rmax(`r_tilde1') mcontrol($base)  
		local d1=round(r(delta),.001)
		
		/*psacalc delta `x', rmax(`r_tilde2') mcontrol($base)  
		local d2=round(r(delta),.001) */
			
		qui reg `y' `x' ib3.traject $control $base if $Fsample , vce(cluster id_can)  
		qui sum `y' if e(sample)
		outreg2 using lastpaper/output/may/rob/1oster.xls, dec(3) ctitle(`y'_F) append $spec  ///	
		keep(`x') addtext(B1.3,`b1', D1.3,`d1', Individual characteristics, Yes, Fixed effects yrnatXayearcan, Yes) nonotes
	}
}


********************************************************************************
* Robustness test *
* Predecision employment
********************************************************************************
local covarB "$covar"
local covarF "ib3.traject $covar"

foreach v in B F {
	foreach y of varlist emp lrevenu {
		qui reg `y' wait`v'  `covar`v'' if $`v'sample , cluster(id_can)
		qui sum `y' if e(sample)
		outreg2 using lastpaper/output/may/rob/pre`v'decision.xls, dec(3) ctitle(Main) append $spec ///
		keep(wait`v') $fulltext

		qui reg `y' wait`v' pre`v'wage_any `covar`v'' if $`v'sample , cluster(id_can)
		qui sum `y' if e(sample)
		outreg2 using lastpaper/output/may/rob/pre`v'decision.xls, dec(3) ctitle(Predecision) append $spec ///
		keep(wait`v' pre`v'wage_any) $fulltext
		
		qui reg `y' stay_wait`v' `covar`v'' if $`v'sample , cluster(id_can)
		qui sum `y' if e(sample)
		outreg2 using lastpaper/output/may/rob/pre`v'decision.xls, dec(3) ctitle(Main) append $spec ///
		keep(stay_wait`v') $fulltext

		qui reg `y' stay_wait`v' pre`v'wage_any `covar`v'' if $`v'sample , cluster(id_can)
		qui sum `y' if e(sample)
		outreg2 using lastpaper/output/may/rob/pre`v'decision.xls, dec(3) ctitle(Predecision) append $spec ///
		keep(stay_wait`v' pre`v'wage_any) $fulltext ///
		sortvar(wait`v' stay_wait`v' pre`v'wage_any)
	}
}


********************************************************************************
* Robustness test *
* Falsification test (F->B traject==6)
********************************************************************************
foreach y of varlist emp lrevenu {
	qui reg `y' waitB $covar if $Bsample , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/4falsify.xls, dec(3) ctitle(Main) append $spec ///
	keep(waitB) $fulltext

	qui reg `y' waitB $covar if traject==6 , cluster(id_can)
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/main/4falsify.xls, dec(3) ctitle(F->B) append $spec ///
	keep(waitB) $fulltext
}

// Table. Are they systematically different? //
qui reg traject waitB $covar if traject==4 | traject==6, cluster(id_can) nocons
qui sum traject if e(sample)
outreg2 using lastpaper/output/may/rob/5falsify_sup.xls, dec(3) ctitle(F->B) append $spec ///
keep(waitB $covarNOFE ) $fulltext
	


********************************************************************************
********************************************************************************
* APPENDIX *
********************************************************************************
********************************************************************************

// Appendix Table. Logit/ Probit //
qui logit emp waitB $covar if $Bsample , cluster(id_can)
gen in_logitB = e(sample)

qui logit emp waitF ib3.traject $covar if $Fsample , cluster(id_can)
gen in_logitF = e(sample) 

tab in_logitB if $Bsample
tab in_empB  if $Bsample

tab in_logitF if $Fsample
tab in_empB  if $Bsample

* B - Treatment = Continuous waiting time 
qui reg emp waitB $covar if $Bsample, cluster(id_can)
qui sum emp if e(sample)
outreg2 using lastpaper/output/may/rob/2plogitB.xls, dec(3) ctitle(OLS_Main) replace $spec ///
keep(waitB) $fulltext 

qui reg emp waitB $covar if $Bsample & in_logitB, cluster(id_can)
qui sum emp if e(sample)
outreg2 using lastpaper/output/may/rob/2plogitB.xls, dec(3) ctitle(OLS) append $spec ///
keep(waitB) $fulltext 

qui logit emp waitB $covar if $Bsample & in_logitB, cluster(id_can)
margins, dydx(waitB) post
qui sum emp if e(sample)
outreg2 using lastpaper/output/may/rob/2plogitB.xls, dec(3) ctitle(Logit) append $spec ///
keep(waitB) $fulltext 

qui probit emp waitB $covar if $Bsample & in_logitB, cluster(id_can)
margins, dydx(waitB) post
qui sum emp if e(sample)
outreg2 using lastpaper/output/may/rob/2plogitB.xls, dec(3) ctitle(Probit) append $spec ///
keep(waitB) $fulltext 


* F - Treatment = Continuous waiting time 
qui reg emp waitF $covar if $Fsample , cluster(id_can)
qui sum emp if e(sample)
outreg2 using lastpaper/output/may/rob/2plogitF.xls, dec(3) ctitle(OLS_Main) replace $spec ///
keep(waitF) $fulltext

qui reg emp waitF $covar if $Fsample & in_logitF, cluster(id_can)
qui sum emp if e(sample)
outreg2 using lastpaper/output/may/rob/2plogitF.xls, dec(3) ctitle(OLS) append $spec ///
keep(waitF) $fulltext

qui logit emp waitF ib3.traject $covar if $Fsample & in_logitF, cluster(id_can)
margins, dydx(waitF) post
qui sum emp if e(sample)
outreg2 using lastpaper/output/may/rob/2plogitF.xls, dec(3) ctitle(Logit) append $spec ///
keep(waitF) $fulltext

qui probit emp waitF ib3.traject $covar if $Fsample & in_logitF, cluster(id_can)
margins, dydx(waitF) post
qui sum emp if e(sample)
outreg2 using lastpaper/output/may/rob/2plogitF.xls, dec(3) ctitle(Probit) append $spec ///
keep(waitF) $fulltext



// Appendix table: Categorical waiting time //
qui logit emp i.waitB_cat $covar if $Bsample , cluster(id_can) nocons 
gen in_logitBcat = e(sample)  // drop n=203 because of small cells (n=1,811)

qui logit emp i.waitF_cat ib3.traject $covar if $Fsample , cluster(id_can) nocons 
gen in_logitFcat = e(sample) // drop n=309 because of small cells (n=2,077)

foreach y of varlist emp {

* Permit B 
	qui reg `y' i.waitB_cat $covar if $Bsample & in_logitBcat, cluster(id_can) 
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/rob/4plogit_i.xls, dec(3) ctitle(OLS) append $spec ///
	keep(1.waitB_cat 2.waitB_cat 3.waitB_cat 4.waitB_cat) $fulltext 
	
	qui logit `y' i.waitB_cat $covar if $Bsample & in_logitBcat, cluster(id_can) 
	margins, dydx(1.waitB_cat 2.waitB_cat 3.waitB_cat 4.waitB_cat) post
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/rob/4plogit_i.xls, dec(3) ctitle(Logit) append $spec ///
	keep(1.waitB_cat 2.waitB_cat 3.waitB_cat 4.waitB_cat) $fulltext 

	qui probit `y' i.waitB_cat $covar if $Bsample & in_logitBcat, cluster(id_can) 
	margins, dydx(1.waitB_cat 2.waitB_cat 3.waitB_cat 4.waitB_cat) post
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/rob/4plogit_i.xls, dec(3) ctitle(Probit) append $spec ///
	keep(1.waitB_cat 2.waitB_cat 3.waitB_cat 4.waitB_cat) $fulltext 

* Permit F
	qui reg `y' i.waitF_cat ib3.traject $covar if $Fsample & in_logitFcat, cluster(id_can) 
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/rob/4plogit_i.xls, dec(3) ctitle(OLS) append $spec ///
	keep(1.waitF_cat 2.waitF_cat 3.waitF_cat 4.waitF_cat) $fulltext 
	
	qui logit `y' i.waitF_cat ib3.traject $covar if $Fsample & in_logitFcat, cluster(id_can) 
	margins, dydx(1.waitF_cat 2.waitF_cat 3.waitF_cat 4.waitF_cat) post
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/rob/4plogit_i.xls, dec(3) ctitle(Logit) append $spec ///
	keep(1.waitF_cat 2.waitF_cat 3.waitF_cat 4.waitF_cat) $fulltext 
	
	qui probit `y' i.waitF_cat ib3.traject $covar if $Fsample & in_logitFcat, cluster(id_can) 
	margins, dydx(1.waitF_cat 2.waitF_cat 3.waitF_cat 4.waitF_cat) post
	qui sum `y' if e(sample)
	outreg2 using lastpaper/output/may/rob/4plogit_i.xls, dec(3) ctitle(Probit) append $spec ///
	keep(1.waitF_cat 2.waitF_cat 3.waitF_cat 4.waitF_cat) $fulltext ///
	sortvar(1.waitB_cat 2.waitB_cat 3.waitB_cat 4.waitB_cat 1.waitF_cat 2.waitF_cat 3.waitF_cat 4.waitF_cat)
}



// Appendix Table. Sample restrictions: Wage regression excluding unemployment benefits //
local y "lrevenu"
gen Xvar=.
lab var Xvar "Waiting time, in years"

* Permit B
replace Xvar= waitB

qui reg `y' Xvar ib4.traject $covar if $Bsample , cluster(id_can)
qui sum `y' if e(sample)
outreg2 using lastpaper/output/may/rob/3wage.xls, dec(3) ctitle(Main) replace $spec ///
keep(Xvar) $fulltext 

qui reg `y' Xvar ib4.traject $covar if $Bsample & dureechomage==. & chomage==. & chomagep==. , cluster(id_can)
qui sum `y' if e(sample)
outreg2 using lastpaper/output/may/rob/3wage.xls, dec(3) ctitle(Exclude) append $spec ///
keep(Xvar) $fulltext 

* Permit F 
replace Xvar= waitF

qui reg `y' Xvar $covar if $Fsample , cluster(id_can)
qui sum  `y' if e(sample)
outreg2 using lastpaper/output/may/rob/3wage.xls, dec(3) ctitle(Main) append $spec ///
keep(Xvar) $fulltext

qui reg `y' Xvar $covar if $Fsample & dureechomage==. & chomage==. & chomagep==. , cluster(id_can)
qui sum `y' if e(sample)
outreg2 using lastpaper/output/may/rob/3wage.xls, dec(3) ctitle(Exclude) append $spec ///
keep(Xvar) $fulltext

drop Xvar


*---------------------------------END------------------------------------------*
