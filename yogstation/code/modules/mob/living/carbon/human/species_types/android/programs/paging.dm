/datum/action/android_program/standard/paging
	name = "Memory Paging"
	pdesc = "Redistribute RAM usage, creating 1 additional artificial CPU."

	//Costs
	cpu_cost = 0 //What does it cost to RUN the program?

	ram_cost = 5 //What does it cost to INSTALL the program?



/datum/action/android_program/standard/paging/run_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	active = TRUE
	A.active_programs += src

	A.add_cpu()

	return TRUE

/datum/action/android_program/standard/paging/stop_program(mob/user)
	..()
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE
	A.remove_cpu()

	return TRUE
