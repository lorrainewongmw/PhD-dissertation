// Paper 1 JMP - compare the LM outcomes between economic migrants and asylum populations //
* Lorraine Wong, UCD.
* Last update: 29 July 2020
* Stata version 14.2

********************************************************************************
* Oster bounds - simulations 
********************************************************************************
preserve

keep emp lrevenu id asypop sexst age age2 highestcompleduaggi mainlang hhsize free nationalityid arrival_cohort Canton y2 y3 y4 y5 id_nat_can
		
qui foreach y of varlist emp lrevenu {

	putexcel set secondpaper/OUT/append_sim.xlsx, sheet(`y'_d, replace) modify
	putexcel A1= "delta"
	putexcel B1= "coeff"
	putexcel C1= "se"

	local run_no = 1
	qui forvalues d=0.8(0.1)2.5 {
		qui reg `y' asypop sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid y2 y3 y4 y5, vce(cluster id_nat_can)  
		local r_tilde=e(r2)*1.3
		
		bs r(beta), reps(200) cluster(id_nat_can): psacalc beta asypop, model (reg `y' asypop sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid y2 y3 y4 y5) ///
		rmax(`r_tilde') mcontrol(y2 y3 y4 y5) delta(`d')										
												
		matrix b=e(b)
		matrix se=e(se)
		
		* Label results and save excel
		local cell = `run_no'+1
		
		putexcel A`cell'=`d'
		putexcel B`cell'=matrix(b)
		putexcel C`cell'=matrix(se)

		local run_no = `run_no'+1
	}	
		
		
	putexcel set secondpaper/OUT/append_sim.xlsx, sheet(`y'_k, replace) modify
	putexcel A1= "k"
	putexcel B1= "coeff"
	putexcel C1= "se"

	local run_no = 1
	qui forvalues k=1.1(0.1)3 {
		qui reg `y' asypop sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid y2 y3 y4 y5, vce(cluster id_nat_can)  
		local r_tilde=e(r2)*`k'
		
		bs r(beta), reps(150) cluster(id_nat_can): psacalc beta asypop, model (reg `y' asypop sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid y2 y3 y4 y5) ///
		rmax(`r_tilde') mcontrol(y2 y3 y4 y5)
			
		matrix b=e(b)
		matrix se=e(se)
		
		* Label results and save excel
		local cell = `run_no'+1
		
		putexcel A`cell'=`k'
		putexcel B`cell'=matrix(b)
		putexcel C`cell'=matrix(se)

		local run_no = `run_no'+1
	}	
}	

restore


*******************************************************************************
* Oster bounds - annual numbers for plots 
********************************************************************************
preserve

keep emp lrevenu id asypop sexst age age2 highestcompleduaggi mainlang hhsize free nationalityid arrival_cohort Canton year nid_canton

qui foreach y of varlist emp lrevenu {

	putexcel set secondpaper/OUT/py_poolx.xlsx, sheet(upper_`y', replace) modify
	putexcel A1= "year"
	putexcel B1= "u"
	putexcel C1= "u_err"
	
	local run_no = 1
	qui forvalues i=2010(1)2014 {
		
		qui reg `y' asypop sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid if year==`i', vce(cluster nid_canton)  
		local r_tilde=e(r2)*1.3
		
		bs r(beta), reps(200) cluster(nid_canton): psacalc beta asypop, model (reg `y' asypop sexst age age2 i.highestcompleduaggi i.mainlang hhsize i.free i.arrival_cohort i.Canton i.nationalityid if year==`i') ///
		rmax(`r_tilde') 
		
		matrix b=e(b)
		matrix se=e(se)
		
		* Label results and save excel
		local cell = `run_no'+1
		
		putexcel A`cell'=`i'
		putexcel B`cell'=matrix(b)
		putexcel C`cell'=matrix(se)

		local run_no = `run_no'+1
	}	
}		
restore
