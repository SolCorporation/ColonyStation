/datum/action/android_program/standard/overclocking
	name = "Overclocking"
	pdesc = "Overclocking enables 1 additional CPUs worth of performance, at the cost of 25% more power usage."

	//Costs
	cpu_cost = 0 //What does it cost to RUN the program?

	ram_cost = 3 //What does it cost to INSTALL the program?



/datum/action/android_program/standard/overclocking/run_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	active = TRUE
	A.active_programs += src

	A.add_cpu()
	A.power_modifier += 0.25

	return TRUE

/datum/action/android_program/standard/overclocking/stop_program(mob/user)
	..()
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	A.remove_cpu()
	A.power_modifier -= 0.25

	return TRUE
