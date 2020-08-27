/datum/action/android_program/standard/optimize_power
	name = "Processing Optimization"
	pdesc = "Reduces power usage by 15%."

	//Costs
	cpu_cost = 1 //What does it cost to RUN the program?

	ram_cost = 2 //What does it cost to INSTALL the program?



/datum/action/android_program/standard/optimize_power/run_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	active = TRUE
	A.active_programs += src

	A.power_modifier -= 0.15
	A.exempt_cpus++

	return TRUE

/datum/action/android_program/standard/optimize_power/stop_program(mob/user)
	..()
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE
	A.power_modifier += 0.15
	A.exempt_cpus--

	return TRUE
