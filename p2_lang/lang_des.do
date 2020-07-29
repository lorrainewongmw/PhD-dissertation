// The Language paper //

* Descriptives - tables and figures

* Lorraine Wong, UCD
* Last update: 29 July 2020
* Stata version 14.2


********************************************************************************
* Descriptives/ Figures *
********************************************************************************
// Figure: Histogram with language proximity // 
twoway (hist std_LDND if lang_region==0, percent lcolor(gs12) fcolor(gs12)) (hist std_LDND if lang_region==1, percent fcolor(none) lcolor(red)), ///
legend(off) xtitle("Linguistic proximity (Grey: Swiss German, Red: French and Italian)") ///
ysize(6) xsize(12) graphregion(color(white)) saving(lang_paper/graphs/hist_lang, replace)


*================================================================================
// Table: Nationality Description //
tabout SG_NAMKE_NID if std_LDND!=. using lang_paper/output/may/des/topnat.xls, cells(freq col) format(0c 3) replace sort // % sample by top 10 nationalities 


// Table: Mean langauge proximity by top nationalities //
tabout nid_pool using lang_paper/output/may/des/nat_lang.xls, sum cells(N id mean LDNDmajor_jchge mean LDNDmajor_jfr mean LDNDmajor_jit mean LDND_Major_en) f(2) replace 
tabout SG_NAMKE_NID using lang_paper/output/may/des/all_lang.xls, sum cells(N id mean LDNDmajor_jchge mean LDNDmajor_jfr mean LDNDmajor_jit mean LDND_Major_en) f(2) replace 
 
 
// Table: Summary statistics //
set matsize 8000
set more off		

qui outreg2 if lang_region==0 using lang_paper/output/may/des/summary.xls, replace sum(log) label keep(emp emp_b revenu std_LDND std_LDNDge std_INDEX std_LDNDen ///
sexst age_arrive age EDU1 EDU2 EDU3 hhsize charrivalyear recent rural ///
distcap2ch2010 ldist lpopratio lstock FST_dom_std PR CL colcomb) ///
sortvar(emp revenu std_LDND std_LDNDge std_INDEX std_LDNDen sexst age_arrive age EDU1 EDU2 EDU3 hhsize charrivalyear recent rural distcap2ch2010 ldist lpopratio lstock FST_dom_std PR CL colcomb) ///
eqkeep(N mean sd min max)

qui outreg2 if lang_region==1 using lang_paper/output/may/des/summary.xls, append sum(log) label keep(emp emp_b revenu std_LDND std_LDNDge std_INDEX std_LDNDen ///
sexst age_arrive age EDU1 EDU2 EDU3 hhsize charrivalyear recent rural ///
distcap2ch2010 ldist lpopratio lstock FST_dom_std PR CL colcomb) ///
sortvar(emp revenu std_LDND std_LDNDge std_INDEX  std_LDNDen sexst age_arrive age EDU1 EDU2 EDU3 hhsize charrivalyear recent rural distcap2ch2010 ldist lpopratio lstock FST_dom_std PR CL colcomb) ///
eqkeep(N mean sd min max)


// just the indices //
qui outreg2 if lang_region==0 using lang_paper/output/may/des/sum_index.xls, replace sum(log) label keep(std_LDND std_LDNDge std_INDEX std_LDNDen ///
LDND_Major LDNDge_Major INDEX_Major LDND_Major_en) ///
sortvar(std_LDND std_LDNDge std_INDEX std_LDNDen LDND_Major LDNDge_Major INDEX_Major LDND_Major_en) ///
eqkeep(N mean sd min max)

qui outreg2 if lang_region==1 using lang_paper/output/may/des/sum_index.xls, append sum(log) label keep(std_LDND std_LDNDge std_INDEX std_LDNDen ///
LDND_Major LDNDge_Major INDEX_Major LDND_Major_en) ///
sortvar(std_LDND std_LDNDge std_INDEX std_LDNDen LDND_Major LDNDge_Major INDEX_Major LDND_Major_en) ///
eqkeep(N mean sd min max)


// Table: Outcomes by nationality and language region //
tabout nid_pool if lang_region==0 using lang_paper/output/may/des/topnat_outcomes.xls, sum cells(N emp mean emp sd emp N emp_b mean emp_b sd emp_b N revenu mean revenu sd revenu) format(0c 3 3 0c 3 3 0c 0c 0c) h2(German-speaking region) replace // Romance
tabout nid_pool if lang_region==1 using lang_paper/output/may/des/topnat_outcomes.xls, sum cells(N emp mean emp sd emp N emp_b mean emp_b sd emp_b N revenu mean revenu sd revenu) format(0c 3 3 0c 3 3 0c 0c 0c) h2(Romance-speaking region) append // German


// Table: Outcomes by year and language region //
tabout year if lang_region==0 using lang_paper/output/may/des/outcomes.xls, sum cells(mean emp mean revenu) format(3 0c 3) h2(German-speaking region) replace // Romance
tabout year if lang_region==1 using lang_paper/output/may/des/outcomes.xls, sum cells(mean emp mean revenu) format(3 0c 3) h2(Romance-speaking region) append // German


// Table: Incidence of move by duration of stay //
xttab move if charrivalyear>=2010 // (only 1.94% of the sample who entered after 2010 moved after the first year of stay. More than half of these cases already obtained permit B.)
xttab residentpermit if charrivalyear>=2010 & move>=1 
*list id charrivalyear residentpermit can_change move Canton if move!=0 & charrivalyear>=2010


** Correlation 
forvalues n=0(1)1 {
	corr std_LDND std_LDNDge std_INDEX if lang_region==`n'
	local N = r(N)
	matrix c= r(C)
	
	putexcel set lang_paper/output/may/des/corr_indices.xlsx, sheet(corr`n', replace) modify
	putexcel A1=`N'
	putexcel A2=matrix(c), names 
}

