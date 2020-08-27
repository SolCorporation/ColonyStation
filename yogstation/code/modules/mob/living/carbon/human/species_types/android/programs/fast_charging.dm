/datum/action/android_program/standard/fast_charging
	name = "Fast Charging"
	pdesc = "Gain 0.25 more units of charge, per power unit expended."


	//Costs
	cpu_cost = 1 //What does it cost to RUN the program?

	ram_cost = 2 //What does it cost to INSTALL the program?



/datum/action/android_program/standard/fast_charging/run_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	active = TRUE
	A.active_programs += src

	A.electricity_to_nutriment += 0.25

	return TRUE

/datum/action/android_program/standard/fast_charging/stop_program(mob/user)
	..()
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE
	A.electricity_to_nutriment -= 0.25

	return TRUE
