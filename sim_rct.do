capture program drop sim_con
program define sim_con, rclass 
syntax [, obs(integer 500000)]
drop _all 

quietly {
	set obs `obs'

	// setting specific parameters

	gen age = rbinomial(1,.6)
	gen sex = rbinomial(1,.4)
	gen area = rbinomial(1,.8)

	* Parameters for the ZK relationship 	
	scalar a1 = log(1.2)	// Age
	scalar a2 = log(1.8)	// Sex	
	scalar a3 = log(1.2)	// Area

	* Parameters for the XKZ relationship 
	scalar c1 = log(2)		// Age
	scalar c2 = log(0.9)	// Sex
	scalar c3 = log(1.2)	// Area
	scalar c4 = log(runiform(1.1,3)) // XZ 

	* Parameters for the YXZK relationship 
	scalar b1 = rnormal(ln(1.35), (ln(1.56)-ln(1.17))/(2*1.96)) 
	scalar b2 = log(runiform(1.1, 4)) 
	scalar b3 = log(0.6) 
	scalar b4 = log(0.3)
	scalar b5 = log(0.9)

	// generate the exposure, outcome and confounding variable
	gen z = rbinomial(1, invlogit(logit(.3) + a1*age + a2*sex + a3*area))
	gen x = rbinomial(1, invlogit(logit(.17) + c1*age + c2*sex + c3*area + c4*z))
	gen y = rbinomial(1, invlogit(logit(.000377) + b1*x + b2*z + b3*age + b4*sex + b5*area))

	// DGM under an effect of X not adjusted for Z 
	logit y x age sex area, or 
	return scalar b1_1_x = _b[x]
	return scalar se_b1_1_x = _se[x]

	// DGM under an effect of X adjusted for Z 
	logit y x z age sex area, or
	test _b[x] = 0 
	return scalar p = r(p)
	return scalar b1_1_z = _b[x]
	return scalar se_b1_1_z = _se[x]
}
end 

* Simulate a 1000 studies
simulate p = r(p) b1_1_x = r(b1_1_x) se_b1_1_x = r(se_b1_1_x) ///
b1_1_z = r(b1_1_z) se_b1_1_z = r(se_b1_1_z), reps(1000) seed(8492): sim_con
