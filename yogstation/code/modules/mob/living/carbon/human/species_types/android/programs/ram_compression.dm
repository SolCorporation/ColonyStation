/datum/action/android_program/standard/compression
	name = "Memory Compression"
	pdesc = "Uses CPU power to compress RAM. Gives 3TB after installation RAM usage is factored in."

	//Costs
	cpu_cost = 2 //What does it cost to RUN the program?

	ram_cost = 2 //What does it cost to INSTALL the program?



/datum/action/android_program/standard/compression/run_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	active = TRUE
	A.active_programs += src

	A.add_ram(5)

	return TRUE

/datum/action/android_program/standard/compression/stop_program(mob/user)
	..()
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	A.remove_ram(5)

	return TRUE
