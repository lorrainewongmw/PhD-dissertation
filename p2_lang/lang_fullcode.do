// The Language paper //
* Full .do file (labels > describe > id > main > robust)

* asylum populations 18-65, arrivals between 2005 and 2014
* Lorraine Wong, UCD
* Last update: 29 July 2020
* Stata version 14.2

* Get Data *
cd "/Users/lorrainewong/Documents/Geneve/UNIGE/NCCR/"
use "data/lorraine_analysis.dta", clear

set more off

********************************************************************************
* Globals in most .do files *
********************************************************************************
global treat "std_LDND"
global covariates "sexst age age2 i.highestcompleduaggi hhsize rural asylumseeker i.arrive_cohort i.year i.Canton"
global origin "ldist lpopratio lstock FST_dom_std PR CL colcomb"

global covariate_as "sexst age age2 i.highestcompleduaggi hhsize rural i.year i.Canton"
global covariates_agearrive "sexst i.highestcompleduaggi hhsize rural i.arrive_cohort i.year i.Canton"

global spec "label nocons addstat(Sample mean, r(mean))"
global text_full "addtext(Individual characteristics, Yes, Fixed effects yeararrivalcohortcanton, Yes) nonotes"
global text_assim "addtext(Individual characteristics, Yes, Fixed effects yearcanton, Yes) nonotes"

********************************************************************************
* Run .do files *
********************************************************************************

* label of the variables
run /Users/lorrainewong/github/lang_paper/lang_var.do // not available because the data is not publicly available

* descriptives
run /Users/lorrainewong/github/lang_paper/lang_des.do

* identification
run /Users/lorrainewong/github/lang_paper/lang_id.do

******************************************************************************** 
* MAIN RESULTS * 
******************************************************************************** 

corr emp ldist lgdp lgdp2 lstock lpop FST_*std NEI*std lnPR lnCL colcomb
corr emp ldist lgdp lgdp2 lstock lpop FST_*std NEI*std PR CL colcomb // no difference
corr lrevenu ldist lgdp lgdp2 lstock lpop FST_*std NEI*std PR CL colcomb

// Table. Employment result - explain about the covariates //
forvalues n=0(1)1{
	foreach y of varlist emp {
	
	qui reg `y' $treat i.year i.Canton if lang_region==`n' , vce(cluster nat_can) // No covariates
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/main/maintabell.xls, dec(3) ctitle(Base_`n') append $spec ///
	keep($treat) addtext(Individual level control variables, No , Year fixed effects, Yes, Arrival cohort fixed effects, No , Canton fixed effects, Yes) nonotes

	qui reg `y' $treat $covariates if lang_region==`n' , vce(cluster nat_can) // With individual covariates
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/main/maintabell.xls, dec(3) ctitle(Individual control) append $spec ///
	keep($treat sexst age age2 i.highestcompleduaggi hhsize rural asylumseeker) addtext(Individual level control variables, Yes , Year fixed effects, Yes, Arrival cohort fixed effects, Yes , Canton fixed effects, Yes) nonotes
		
	qui reg `y' $treat $covariates $origin if lang_region==`n' , vce(cluster nat_can) 
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/main/maintabell.xls, dec(3) ctitle(Main) append $spec ///
	keep($treat sexst age age2 i.highestcompleduaggi hhsize rural asylumseeker ldist lgdp lpop lstock FST_dom_std PR CL colcomb) ///
	addtext(Individual level control variables, Yes , Year fixed effects, Yes, Arrival cohort fixed effects, Yes , Canton fixed effects, Yes) nonotes ///
	sortvar($treat sexst age age2 2.highestcompleduaggi 3.highestcompleduaggi hhsize rural asylumseeker ldist lgdp lpop lstock FST_dom_std PR CL colcomb)
	}
}	


// Table. All Result by language region //
forvalues n=0(1)1 {
	foreach y of varlist emp emp_b lrevenu {
	
	qui reg `y' $treat $covariates $origin if lang_region==`n', vce(cluster nat_can) 
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/main/langtabell.xls, dec(3) ctitle(`y'_`n') append $spec ///
	keep($treat) $text_full
	}
}


// Table. Result by language region [English] //
forvalues n=0(1)1 {
	foreach y of varlist emp emp_b lrevenu {
	
	qui reg `y' std_LDNDen $covariates $origin if lang_region==`n', vce(cluster nat_can) 
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/main/english.xls, dec(3) ctitle(`y'_`n') append $spec ///
	keep(std_LDNDen) $text_full
	}
}


// Table. Nationality X arrival cohort FE interaction (constant nationality and arrival cohort trends) //
* The effect of linguistic proximity to French survives despite I assume same trend over time within nationality
* There are some cohort effects in the German-speaking region 

global originX "c.ldist##i.arrive_cohort c.lpopratio##i.arrive_cohort c.lstock##i.arrive_cohort c.FST_dom_std##i.arrive_cohort c.PR##i.arrive_cohort c.CL##i.arrive_cohort i.colcomb##i.arrive_cohort"

forvalues n=0(1)1 {
	foreach y of varlist emp emp_b lrevenu {
	
	qui reg `y' c.$treat##i.arrive_cohort $covariate_as $originX if lang_region==`n', vce(cluster nat_can)  
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/main/natcohortfe.xls, dec(3) ctitle(`y'_`n') append $spec ///
	keep($treat i.arrive_cohort i.arrive_cohort#c.$treat) $text_assim
	}
} 




********************************************************************************
* Robustness *
********************************************************************************
// Table. INDICES //
forvalues n=0(1)1 {
	foreach y of varlist emp emp_b lrevenu {
	foreach x of varlist std_LDND std_LDNDge std_INDEX {
	
		qui reg `y' `x' $covariates $origin if lang_region==`n', vce(cluster nat_can) 
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/indices_`n'.xls, dec(3) ctitle(`y') append $spec ///
		keep(`x') $text_full
		}
	}
}


// Table. include main language //	
foreach y of varlist emp emp_b lrevenu {
	forvalues n=0(1)1 {		
	
	qui reg `y' $treat $covariates $origin if lang_region==`n', vce(cluster nat_can)
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/mainlang_`n'.xls, dec(3) ctitle(Main) append $spec ///
	keep($treat) $text_full 

	qui reg `y' $treat lang_2 $covariates $origin if lang_region==`n', vce(cluster nat_can)
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/mainlang_`n'.xls, dec(3) ctitle(`y'_`n') append $spec ///
	keep($treat lang_2) $text_full 
	}	
}


// Table. Region fixed effects //

* Notes: My reuslts are robust to the inclusion of continent fixed effects. I did not include continent
* or region dummies in the regression because some of the indicators are highly correlated with 
* country level characteristics (e.g. distance, freedom house indices, and population ratio.
* The results are available upon request. 

la def continent 1 "Europe" 2 "Africa" 3 "America" 4 "Asia"
la val SG_KONT_COB continent

la def region 17 "South-East Europe" 22 "Eastern Africa" 24 "Western Africa" 27 "South-East Africa" 36 "Southern South-America" 47 "South-East Asia"
la val CodeRegionRégion_COB region

tab SG_KONT_NID, gen(KONT_)
tab nid_gp, gen (nidgp_)

corr emp $origin KONT_* // KONT1: ldist, lstock, PR, CL // KONT3: PR, CL, lpop // KONT4: lpop
corr emp $origin nidgp_* // nidgp2: lpop, FST, PR, CL //  nid7:lpop // nid9: FST
corr emp $origin nid_pool_*

foreach y of varlist emp emp_b lrevenu {
	forvalues n= 0(1)1 {

	qui reg `y' $treat $covariates $origin if lang_region ==`n', vce(cluster nat_can) 
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/regionfe_`n'.xls, dec(3) ctitle(Control) append $spec ///
	keep($treat) $text_full
	
	qui reg `y' $treat $covariates $origin ib2.SG_KONT_NID if lang_region ==`n', vce(cluster nat_can) // Africa is the comparison group
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/regionfe_`n'.xls, dec(3) ctitle(Continent) append $spec ///
	keep($treat) $text_full
	
	qui reg `y' $treat $covariates  if lang_region ==`n', vce(cluster nat_can) // Eritrea is the comparison group
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/regionfe_`n'.xls, dec(3) ctitle(Top10) append $spec ///
	keep($treat i.nid_pool) $text_full ///
	sortvar ($treat)
	}
}

// Table. Region fixed effects (by langauge region) //
forvalues n= 0(1)1 {
	foreach y of varlist emp emp_b lrevenu {

	qui reg `y' $treat $covariates i.nid_pool if lang_region ==`n', vce(cluster nat_can) // Eritrea is the comparison group
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/Aregionfe.xls, dec(3) ctitle(`y'_`n') append $spec ///
	keep($treat i.nid_pool) $text_full ///
	sortvar ($treat i.nid_pool)
	}
}


// Table. Selection on unobservables //
tab year, gen(y) // canton dummies are already here
global control "sexst age age2 i.highestcompleduaggi hhsize rural i.arrive_cohort ldist lpopratio lstock FST_dom_std PR CL colcomb"
global base "y2 y3 y4 y5 can2 can3 can4 can5 can6 can7 can8 can9 can10 can11 can12 can13 can14 can15 can16 can17 can18 can19 can20 can21 can22 can23 can24 can25 can26"

forvalues n= 0(1)1{
foreach y of varlist emp emp_b lrevenu {
	foreach x of varlist $treat {
		
		qui reg `y' `x' $control $base if lang_region==`n', vce(cluster nat_can)  
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
			
		qui reg `y' `x' $control $base if lang_region==`n', vce(cluster nat_can)  
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/oster.xls, dec(3) ctitle(`y'_`n') append $spec  ///	
		keep(`x') addtext(B1.3,`b1', D1.3,`d1', B2,`b2', D2,`d2', Individual characteristics, Yes, Fixed effects year arrival cohort canton, Yes) nonotes
		}
	}
}	


// Table. Exclusion criteria for bilingual and birth information//
forvalues n=0(1)1{
	foreach y of varlist emp emp_b lrevenu {
	
	qui reg `y' $treat $covariates $origin if lang_region ==`n', vce(cluster nat_can) // main results
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/sample_restrict`n'.xls, dec(3) ctitle(Main) append $spec ///
	keep($treat) $text_full

	qui reg `y' $treat $covariates $origin if lang_region ==`n' & biling==0, vce(cluster nat_can) // exclude bilingual
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/sample_restrict`n'.xls, dec(3) ctitle(Unilingual) append $spec ///
	keep($treat) $text_full
	
	qui reg `y' $treat $covariates $origin if lang_region ==`n' & same==1, vce(cluster nat_can) // only those with COB=nationality
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/sample_restrict`n'.xls, dec(3) ctitle(Both origin) append $spec ///
	keep($treat) $text_full
	}
}





********************************************************************************
* Appendix *
********************************************************************************
// Appendix Table. Logit/ Probit //
forvalues n= 0(1)1 {
	foreach y of varlist emp emp_b {

	qui reg `y' $treat $covariates $origin if lang_region ==`n', vce(cluster nat_can) // OLS
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/plogit_`n'.xls, dec(3) ctitle(OLS) append $spec ///
	keep($treat) $text_full

	qui logit `y' $treat $covariates $origin if lang_region ==`n', vce(cluster nat_can) // Logit
	margins, dydx($treat) post
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/plogit_`n'.xls, dec(3) ctitle(Logit) append $spec ///
	keep($treat) $text_full

	qui probit `y' $treat $covariates $origin if lang_region ==`n', vce(cluster nat_can) // Probit
	margins, dydx($treat) post
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/plogit_`n'.xls, dec(3) ctitle(Probit) append $spec ///
	keep($treat) $text_full
	}
}


// Appendix Table. Wage regression excluding those receiving unemployment benefits //
local y "lrevenu"
forvalues n=0(1)1 {

	qui reg `y' $treat $covariates $origin if lang_region ==`n', cluster(nat_can)
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/wage.xls, dec(3) ctitle(Main_`n') append $spec ///
	keep($treat) $fulltext 

	qui reg `y' $treat $covariates $origin if lang_region ==`n' & dureechomage==. & chomage==. & chomagep==. , cluster(nat_can)
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/wage.xls, dec(3) ctitle(Exclude) append $spec ///
	keep($treat) $fulltext 
}


// Appendix Table. FULL pop //
foreach y of varlist emp emp_b lrevenu {
		
	qui reg `y' $treat $covariates $origin if in_`y' , vce(cluster nat_can) 
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/fullXregion.xls, dec(3) ctitle(`y') append $spec ///
	keep($treat) $fulltext
}	


// Appendix Table. Inference //
* multi-cluster: nationality, canton (nat_can)
* one-way cluster: nationality (nationalityid)
* two-way cluster: id, nationality, canton (nid_can)

foreach y of varlist emp emp_b lrevenu {
	forvalues n=0(1)1 {
	
	qui reg `y' $treat $covariates $origin if lang_region==`n', vce(cluster nat_can) 
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/inference_`y'.xls, dec(3) ctitle(Main_`n') append $spec ///
	keep($treat) $text_full
	
	qui reg `y' $treat $covariates $origin if lang_region==`n', vce(cluster nationalityid) 
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/inference_`y'.xls, dec(3) ctitle(National) append $spec ///
	keep($treat) $text_full
	
	qui reg `y' $treat $covariates $origin if lang_region==`n', vce(cluster nid_can) 
	qui sum `y' if e(sample)
	outreg2 using lang_paper/output/may/rob/inference_`y'.xls, dec(3) ctitle(Multi) append $spec ///
	keep($treat) $text_full
	}
}


// Available upon request materials: Decision on individual covariates //
corr emp ldist lgdp lgdp2 lstock lpop FST_*std NEI*std PR CL
corr lrevenu ldist lgdp lgdp2 lstock lpop FST_*std NEI*std PR CL

corr FST_*std NEI*std 
corr $treat FST_dom_std


forvalues n=0(1)1 {
foreach y of varlist emp {
	foreach x of varlist $treat {
	
		qui reg `y' `x' i.year i.Canton if lang_region==`n', vce(cluster nat_can) 
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/ind_cov.xls, dec(3) ctitle(No controls_`n') append $spec ///
		keep(`x' sexst age age2 i.highestcompleduaggi hhsize rural) $text_full

		qui reg `y' `x' sexst age age2 i.highestcompleduaggi asylumseeker i.arrive_cohort i.year i.Canton if lang_region==`n', vce(cluster nat_can) 
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/ind_cov.xls, dec(3) ctitle(Some controls) append $spec ///
		keep(`x' sexst age age2 i.highestcompleduaggi hhsize rural asylumseeker) $text_full
		
		qui reg `y' `x' sexst age age2 i.highestcompleduaggi hhsize asylumseeker i.arrive_cohort i.year i.Canton if lang_region==`n', vce(cluster nat_can) 
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/ind_cov.xls, dec(3) ctitle(Add hhsize) append $spec ///
		keep(`x' sexst age age2 i.highestcompleduaggi hhsize rural asylumseeker) $text_full

		qui reg `y' `x' $covariates if lang_region==`n', vce(cluster nat_can) // main lang
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/ind_cov.xls, dec(3) ctitle(Add rural) append $spec ///
		keep(`x' sexst age age2 i.highestcompleduaggi hhsize rural asylumseeker) $text_full ///
		sortvar(`x' sexst age age2 2.highestcompleduaggi 3.highestcompleduaggi asylumseeker hhsize rural)
		}
	}
}


// Decision on country of origin covariates //
forvalues n=0(1)1 {
foreach y of varlist emp {
	foreach x of varlist $treat {
	
		qui reg `y' `x' $covariates if lang_region ==`n', vce(cluster nat_can) 
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/country_cov.xls, dec(3) ctitle(Individual controls) append $spec ///
		keep(`x') $text_full
		
		qui reg `y' `x' $covariates ldist lgdp lpopratio lstock if lang_region ==`n', vce(cluster nat_can) 
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/country_cov.xls, dec(3) ctitle(Standard) append $spec ///
		keep(`x' ldist lgdp lpop lstock) $text_full
		
		qui reg `y' `x' $covariates ldist lpopratio lstock FST_dom_std if lang_region ==`n', vce(cluster nat_can) 
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/country_cov.xls, dec(3) ctitle(Genetics) append $spec ///
		keep(`x' ldist lgdp lpop lstock FST_dom_std PR CL colcomb) $text_full

		qui reg `y' `x' $covariates ldist lpopratio lstock FST_dom_std PR CL colcomb if lang_region ==`n', vce(cluster nat_can) 
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/country_cov.xls, dec(3) ctitle(Main) append $spec ///
		keep(`x' ldist lgdp lpop lstock FST_dom_std PR CL colcomb) $text_full
		
		qui reg `y' `x' $covariates ldist lpopratio lstock FST_dom_std PR CL colcomb i.SG_KONT_NID if lang_region ==`n', vce(cluster nat_can) // area (continent fe same effect)
		qui sum `y' if e(sample)
		outreg2 using lang_paper/output/may/rob/country_cov.xls, dec(3) ctitle(Continent) append $spec ///
		keep(`x' ldist lgdp lpop lstock FST_dom_std PR CL colcomb) $text_full
		}
	}
}


*------------------------------------ END ----------------------------------------


