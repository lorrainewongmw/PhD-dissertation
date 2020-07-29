// Paper 1 JMP - compare the LM outcomes between economic migrants and asylum populations //
* DESCRIPTIVES
* Lorraine Wong, UCD.
* Last update: 29 July 2020
* Stata version 14.2

*******************************************************************************
* Table 1: Employment rates and monthly wage *
******************************************************************************** 
tabout emp asypop if year==2010 using secondpaper/OUT/april/descriptives/emp_1.xls, c(freq col) lay(cb) replace 

forvalues i= 2011(1)2014 {
	tabout emp asypop if year==`i' using secondpaper/OUT/april/descriptives/emp_1.xls, c(freq col) lay(cb) append
} 

forvalues i= 2010(1)2014 {
	bys asypop: sum revenu if year==`i'
} 

******************************************************************************** 
* Table 2: Descriptive Statistics *
******************************************************************************** 
set matsize 800
set more off		

bysort asypop: outreg2 if age>=18 & age <=65 using secondpaper/OUT/des/T2_08052019.xls, append sum(log) keep(sexst ///
charrivalyear age age_arrive edu1 edu2 edu3 mlang1 mlang2 mlang3 hhsize cob1 cob2 cob3 yugos war1 war2 war3 recent ///
permitnf permisc permisnat rural lang_region) ///
sort(sexst charrivalyear age age_arrive edu1 edu2 edu3 mlang1 mlang2 mlang3 hhsize cob1 cob2 cob3 yugos war1 war2 war3 recent permitnf permisc permisnat rural lang_region)

******************************************************************************** 
* Table 3: Top nationality *
******************************************************************************** 
tabout SG_NAMKE_NID if asypop==1 using secondpaper/OUT/des/topnat.xls, cells(freq col) format(0c 3) replace sort // % asylum by top 10 nationalities 
tabout SG_NAMKE_NID if asypop==0 using secondpaper/OUT/des/topnat.xls, cells(freq col) format(0c 3) append sort // % migrant by top 10 nationalities 

******************************************************************************** 
* Subgroup descriptives (TA 16) *
******************************************************************************** 
tabout female yugos3 recent permisc permisnat active rural lang_region emp if asypop==1 using secondpaper/OUT/des/emp_asy.xls, c(freq row) lay(cb) replace 
tabout female yugos3 recent permisc permisnat active rural lang_region emp if asypop==0 using secondpaper/OUT/des/emp_mig.xls, c(freq row) lay(cb) replace 

foreach i of varlist female yugos3 recent permisc permisnat active rural lang_region {
	tabout `i' if asypop==1 using secondpaper/OUT/des/wage_asy.xls, sum cells(N revenu mean revenu sd revenu) format(0c 0c 0c) append // asy
	tabout `i' if asypop==0 using secondpaper/OUT/des/wage_mig.xls, sum cells(N revenu mean revenu sd revenu) format(0c 0c 0c) append // mig
}

********************************************************************************
* Figure 4 : Entry of former Yugoslavia nationals *
********************************************************************************
tabout charrivalyear asypop if yugos==1 using secondpaper/OUT/des/yugos.xls, c(freq row) lay(cb) replace 
