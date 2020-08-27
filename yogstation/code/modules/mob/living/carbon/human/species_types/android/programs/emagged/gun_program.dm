/datum/action/android_program/emagged/gun_program
	name = "Subvert Harm Prevention"
	pdesc = "ERROR 503... FOREIGN CODE DETECTED"


	//Costs
	cpu_cost = 3 //What does it cost to RUN the program?

	ram_cost = 5 //What does it cost to INSTALL the program?



/datum/action/android_program/emagged/gun_program/run_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	active = TRUE
	A.active_programs += src

	A.can_use_guns = TRUE

	return TRUE

/datum/action/android_program/emagged/gun_program/stop_program(mob/user)
	..()
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE
	A.can_use_guns = FALSE

	return TRUE
