// Paper 3 - The effect of waiting time on LM outcomes //
* Desriptives
* Lorraine Wong, UCD.
* Last update: 29 July 2020
* Stata version 14.2

********************************************************************************
* Descriptives *
********************************************************************************
* Table. Mean waiting time by trajectory 
tabout traject if in_empB==1 | in_empF==1 using lastpaper/output/may/des/1traject.xls, sum cells(N waitB mean waitB N waitF mean waitF) format(0c 1 0c 1) replace

* Table. Mean waiting time by top nationalities
tabout nid_pool if in_empB==1 | in_empF==1 using lastpaper/output/may/des/2top10nat.xls, sum cells(N waitB mean waitB N waitF mean waitF) format(0c 1 0c 1) replace

* Table. Mean waiting time by canton 
tabout Canton if in_empB==1 | in_empF==1 using lastpaper/output/may/des/3canton.xls, sum cells(N waitB mean waitB N waitF mean waitF) format(0c 1 0c 1) replace

* Table. Mean outcomes by trajectory 
tabout traject if in_empB==1 | in_empF==1 using lastpaper/output/may/des/4traject_outcomes.xls, sum cells(N emp mean emp N revenu mean revenu) format(0c 3 0c 1) replace  

* Table. Incidence of move by duration of stay 
tabout Canton move if charrivalyear>=2010 using lastpaper/output/may/des/5can_move.xls, c(freq row) lay(cb) replace
xttab move if (in_empB==1 | in_empF==1 ) & charrivalyear>=2010

list id charrivalyear residentpermit can_change move Canton if move!=0 & charrivalyear>=2010

* Table. Summary statistics
set matsize 1000
qui outreg2 if in_empB==1 | in_empF==1 using lastpaper/output/may/des/6sumstats.xls, replace sum(log) label ///
keep(emp revenu waitB waitF stay_waitB stay_waitF sexst age_arrive age EDU1 EDU2 EDU3 mainlang hhsize year charrivalyear lang_region rural) ///
sortvar(emp revenu waitB waitF stay_waitB stay_waitF sexst age_arrive age EDU1 EDU2 EDU3 mainlang hhsize charrivalyear year lang_region rural) ///
eqkeep(N mean sd min max)

* Table A. Nationality Description 
tabout SG_NAMKE_NID if in_empB==1 | in_empF==1 using lastpaper/output/may/des/A4nat.xls, cells(freq col) format(0c 2) replace

* Table A. Mean waiting time (absolute numbers) 
tabout waitB traject if in_empB==1 | in_empF==1 using lastpaper/output/may/des/A5B_traject.xls, c(freq) lay(rb) replace 
tabout waitF traject if in_empB==1 | in_empF==1 using lastpaper/output/may/des/A6F_traject.xls, c(freq) lay(rb) append

// Perhaps useful for later //
tab yearB if traject==4
tab yearF if traject==3 | traject==5


*============================================================================================
* Figure. Histogram of the variable of interest

hist waitB if $Bsample, percent lcolor("31 119 180") fcolor("31 119 180") graphregion(color(white)) xtitle("Permit: B refugee") saving (lastpaper/graphs/abs_waitB, replace) 
hist waitF if $Fsample, percent fcolor("255 127 14") lcolor("255 127 14") graphregion(color(white)) xtitle("Permit: F temporary accepted refugee/ person") saving (lastpaper/graphs/abs_waitF, replace) 

gr combine lastpaper/graphs/abs_waitB.gph lastpaper/graphs/abs_waitF.gph, ysize(6) xsize(12) scale(1.3) graphregion(color(white)) ///
caption("Time waiting for residence permit [years]", position(6) size(small)) saving(lastpaper/graphs/abs_wait, replace)

hist stay_waitB if $Bsample, percent lcolor("31 119 180") fcolor("31 119 180") graphregion(color(white)) xtitle("Permit: B refugee") saving (lastpaper/graphs/ratio_waitB, replace) 
hist stay_waitF if $Fsample, percent fcolor("255 127 14") lcolor("255 127 14") graphregion(color(white)) xtitle("Permit: F temporary accepted refugee/ person") saving (lastpaper/graphs/ratio_waitF, replace) 

gr combine lastpaper/graphs/ratio_waitB.gph lastpaper/graphs/ratio_waitF.gph, ysize(6) xsize(12) scale(1.3) graphregion(color(white)) ///
caption("Ratio [Time stay/ Time waiting for residence permit]", position(6) size(small)) saving(lastpaper/graphs/ratio_wait, replace)


* Figure. By trajectories
** Mean employment and wages by permit B and F waiting time
bys waitB: egen empB_graph= mean(emp)
bys waitB: egen wageB_graph= mean(revenu)  
gen wageB_graph000= wageB_graph/1000
label var wageB_graph000 "Annual wage [kCHF]"

bys waitF: egen empF_graph= mean(emp) 
bys waitF: egen wageF_graph= mean(revenu)  
gen wageF_graph000= wageF_graph/1000
label var wageF_graph000 "Annual wage [kCHF]"

bys waitB traject: egen tempB_graph= mean(emp)
bys waitB traject: egen twageB_graph= mean(revenu)  
gen twageB_graph000= twageB_graph/1000
label var twageB_graph000 "Annual wage [kCHF]"

bys waitF traject: egen tempF_graph= mean(emp) 
bys waitF traject: egen twageF_graph= mean(revenu)  
gen twageF_graph000= twageF_graph/1000
label var twageF_graph000 "Annual wage [kCHF]"


* Employment
scatter tempB_graph waitB, msymbol(O) mcolor("31 119 180") by(traject, graphregion(color(white))) ///
|| scatter tempF_graph waitF, msymbol(Dh) mcolor("255 127 14") by(traject) ///
ysize(6) xsize(12) scale(1.3) legend(off) ///
ytitle("Mean employment rate [%]") xtitle("Time waiting for residence permit [years]") ///
legend(label(1 "Permit: B refugee") label(2 "Permit: F temporary accepted refugee/ person")) saving(lastpaper/graphs/emp_wait_traj, replace) 

* Annual wage
scatter twageB_graph000 waitB, msymbol(O) mcolor("31 119 180") by(traject, graphregion(c(white) lc(gs11))) ///
|| scatter twageF_graph000 waitF, msymbol(Dh) mcolor("255 127 14") by(traject) ///
ylab(0(20)50, g) ysize(6) xsize(12) scale(1.3) legend(off) ///
ytitle("Mean annual wage [kCHF]") xtitle("Time waiting for residence permit [years]") ///
legend(label(1 "Permit: B refugee") label(2 "Permit: F temporary accepted refugee/ person")) saving(lastpaper/graphs/wage_wait_traj, replace) 

* Appendix Figure. Canton distribution
tabout Canton using lastpaper/output/may/des/A1can_distn.xls, c(col) lay(rb) replace 


********************************************************************************
* Graphs for identification *
********************************************************************************
*** lineraity checks/ mis-specification *** 

*============ Permit B ============*
qui reg emp waitB $covar if traject==4, cluster(id_can)
predict residBe if e(sample), residuals
egen residBe_std= std(residBe)

**** Normality checks
sum residBe_std
hist residBe_std, kdenop(lc(red)) lcolor(white) fcolor("31 119 180") graphregion(color(white)) xtitle("Std residuals, employment") saving(lastpaper/graphs/rno_Be.gph, replace) // the standardized residuals should have a normal distribution
qnorm residBe_std, rlop(lc(red)) mcolor("31 119 180") graphregion(color(white)) ytitle("Std residuals, employment") saving(lastpaper/graphs/qno_Be.gph, replace) // compares with normal distribution

**** Linearity checks: plot residuals against Var (lfit to show the correlation between the two)
scatter residBe_std waitB, mc("31 119 180") || lfit residBe_std waitB, lc(red) graphregion(color(white)) ytitle("Std residuals, employment") ///
legend(off) saving(lastpaper/graphs/cno_Be.gph, replace) // The correlation should be zero
corr residBe_std waitB // r=-0.00

gr combine lastpaper/graphs/rno_Be.gph lastpaper/graphs/qno_Be.gph lastpaper/graphs/cno_Be.gph, cols(3) ysize(6) xsize(12) scale(1.3) graphregion(color(white)) ///
caption("Normality and linearity checks, permit B employment", position(6) size(small)) saving(lastpaper/graphs/idassume_Be, replace)


*============ B wages ============*
qui reg lrevenu waitB $covar if traject==4, cluster(id_can)
predict residBw if e(sample), residuals
egen residBw_std= std(residBw)

**** Normality checks
sum residBw_std
hist residBw_std, kdenop(lc(red)) lcolor(white) fcolor("31 119 180") fcolor("31 119 180") graphregion(color(white)) xtitle("Std residuals, log annual wage") kdensity saving(lastpaper/graphs/rno_Bw.gph, replace) // the standardized residuals should have a normal distribution
qnorm residBw_std, rlop(lc(red)) mcolor("31 119 180") graphregion(color(white)) ytitle("Std residuals, log annual wage") graphregion(color(white)) saving(lastpaper/graphs/qno_Bw.gph, replace) // compares with normal distribution

**** Linearity checks: Plot residuals against Var (lfit to show the correlation between the two)
scatter residBw_std waitB, mc("31 119 180") || lfit residBw_std waitB, lc(red) graphregion(color(white)) ytitle("Std residuals, log annual wage") ///
legend(off) saving(lastpaper/graphs/cno_Bw.gph, replace)
corr residBw_std waitB // r=0.00

gr combine lastpaper/graphs/rno_Bw.gph lastpaper/graphs/qno_Bw.gph lastpaper/graphs/cno_Bw.gph, cols(3) ysize(6) xsize(12) scale(1.3) graphregion(color(white)) ///
caption("Normality and linearity checks, permit B log annual wages", position(6) size(small)) saving(lastpaper/graphs/idassume_Bw, replace)


*============ Permit F ============*
qui reg emp waitF $covar if traject==3 | traject==5, cluster(id_can)
predict residFe if e(sample), residuals
egen residFe_std= std(residFe)

**** Normality checks
sum residFe_std
hist residFe_std, kdenop(lc(red)) lcolor(white) fcolor("31 119 180") fcolor("31 119 180") graphregion(color(white)) xtitle("Std residuals, employment") kdensity saving(lastpaper/graphs/rno_Fe.gph, replace) // the standardized residuals should have a normal distribution
qnorm residFe_std, rlop(lc(red)) mcolor("31 119 180") graphregion(color(white)) ytitle("Std residuals, employment") graphregion(color(white)) saving(lastpaper/graphs/qno_Fe.gph, replace) // compares with normal distribution

**** Linearity checks: Plot residuals against Var (lfit to show the correlation between the two)
scatter residFe_std waitF, mc("31 119 180") || lfit residFe_std waitF, lc(red) graphregion(color(white)) ytitle("Std residuals, employment") ///
legend(off) saving(lastpaper/graphs/cno_Fe.gph, replace) // The correlation should be zero
corr residFe_std waitF // r=-0.00

gr combine lastpaper/graphs/rno_Fe.gph lastpaper/graphs/qno_Fe.gph lastpaper/graphs/cno_Fe.gph, cols(3) ysize(6) xsize(12) scale(1.3) graphregion(color(white)) ///
caption("Normality and linearity checks, permit F employment", position(6) size(small)) saving(lastpaper/graphs/idassume_Fe, replace)


*============ F wages ============*
qui reg lrevenu waitF $covar if traject==3 | traject==5, cluster(id_can)
predict residFw if e(sample), residuals
egen residFw_std= std(residFw)

**** Normality checks 
sum residFw_std
hist residFw_std, kdenop(lc(red)) lcolor(white) fcolor("31 119 180") fcolor("31 119 180") graphregion(color(white)) xtitle("Std residuals, log annual wage") kdensity saving(lastpaper/graphs/rno_Fw.gph, replace) // the standardized residuals should have a normal distribution
qnorm residFw_std, rlop(lc(red)) mcolor("31 119 180") graphregion(color(white)) ytitle("Std residuals, log annual wage") saving(lastpaper/graphs/qno_Fw.gph, replace) // compares with normal distribution

**** Linearity checks: Plot residuals against Var (lfit to show the correlation between the two)
scatter residFw_std waitF, mc("31 119 180") || lfit residFw_std waitF, lc(red) graphregion(color(white)) ytitle("Std residuals, log annual wage") ///
legend(off) saving(lastpaper/graphs/cno_Fw.gph, replace)
corr residFw_std waitF // r=0.00

gr combine lastpaper/graphs/rno_Fw.gph lastpaper/graphs/qno_Fw.gph lastpaper/graphs/cno_Fw.gph, cols(3) ysize(6) xsize(12) scale(1.3) graphregion(color(white)) ///
caption("Normality and linearity checks, permit F log annual wage", position(6) size(small)) saving(lastpaper/graphs/idassume_Fw, replace)

