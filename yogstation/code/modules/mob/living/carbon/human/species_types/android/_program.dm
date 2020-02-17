/datum/action/android_program
	name = "Default Program - Ahelp This"
	var/pdesc = "Default Program - Ahelp This"

	background_icon_state = "bg_changeling"
	icon_icon = 'icons/mob/actions/actions_changeling.dmi'

	var/needs_button = FALSE //Give an action button? (Passive vs Active abilities)
	var/active = FALSE //Is it currently active? Used for passive abilities

	var/awaiting_callback = FALSE

	//Costs
	var/cpu_cost = 0 //What does it cost to RUN the program?

	var/ram_cost = 0 //What does it cost to INSTALL the program?

	var/requires_emag = FALSE

/datum/action/android_program/emagged
	requires_emag = TRUE

//Can we install it?
/datum/action/android_program/proc/can_install(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	if(ram_cost > A.free_ram)
		return FALSE

	return TRUE


//Actually installs it
/datum/action/android_program/proc/install(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	if(!can_install(user))
		return FALSE

	if(needs_button)
		Grant(user)

	A.free_ram -= ram_cost
	A.installed_programs += src

	return TRUE


//When the action is clicked
/datum/action/android_program/Trigger()
	var/mob/user = owner
	if(!user || !user.mind || !isandroid(user))
		return
	if(!attempt_run(user))
		return

//Try to run it.
/datum/action/android_program/proc/attempt_run(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	if(!can_run(user))
		return FALSE

	if(run_program(user))
		A.free_cpu -= cpu_cost
		return TRUE
	return FALSE

//Active actions have their own timer
/datum/action/android_program/proc/stop_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	if(!active)
		return FALSE

	active = FALSE

	A.free_cpu += cpu_cost
	A.active_programs -= src
	return TRUE

/datum/action/android_program/proc/stop_active_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	if(!awaiting_callback)
		return FALSE

	A.free_cpu += cpu_cost

	awaiting_callback = FALSE

	return TRUE

//Actually what it does
/datum/action/android_program/proc/run_program(mob/user)

	return FALSE

//Can we actually run it?
/datum/action/android_program/proc/can_run(mob/living/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	if(needs_button && awaiting_callback)
		to_chat(user, "<span class='warning'>Program recharging. Please wait.</span>")
		return FALSE

	if(cpu_cost > A.free_cpu)
		to_chat(owner, "<span class='warning'>Not enough CPU power available to run program.</span>")
		return FALSE

	return TRUE

/datum/action/android_program/proc/uninstall(mob/living/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	if(needs_button)
		stop_active_program(user)
		Remove(user)
		A.free_ram += ram_cost
		A.installed_programs -= src
		return TRUE
	else
		if(!active)
			A.free_ram += ram_cost
			A.installed_programs -= src
			return TRUE

		if(stop_program(user))
			A.free_ram += ram_cost
			A.installed_programs -= src
			return TRUE
	return FALSE