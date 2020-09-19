/*
procs:

handle_charge - called in spec_life(),handles the alert indicators,the power loss death and decreasing the charge level
adjust_charge - take a positive or negative value to adjust the charge level
*/

/datum/species/android
	name = "Android"
	id = "android"
	default_color = "FFFFFF"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_traits = list(TRAIT_NOHUNGER, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE)

	species_traits = list(EYECOLOR, NOBLOOD)
	//Talking
	say_mod = "intones"
	attack_verb = "assault"

	//Meat and food?
	meat = null
	toxic_food = NONE

	//Not as strong
	brutemod = 1.25
	burnmod = 1.25
	//Our eyes!
	mutanteyes = /obj/item/organ/eyes/android
	mutantlungs = /obj/item/organ/lungs/android
	mutanttongue = /obj/item/organ/tongue/android


	var/charge //Set on load to below value
	var/max_charge = ANDROID_LEVEL_FULL

	var/eating_msg_cooldown = FALSE


	//Android power drain factors
	//Staying alive
	var/passive_power_drain = 0.5
	//More CPU = More Power Usage
	var/drain_per_cpu = 0.25
	//Power consumption times this
	var/power_modifier = 1
	//CPUs that don't contribute to power calculation
	var/exempt_cpus = 0

	var/electricity_to_nutriment = 0.5 //1 power unit to 50 android charge they can uncharge an apc to 50% at most


	var/draining = FALSE

	//Android menu
	var/datum/operating_system/os //Contains the UI
	var/datum/action/innate/android_os/os_action //Access the above UI


	//Android OS
	var/can_uninstall = FALSE //Can we uninstall programs ourselves?
	var/emagged = FALSE //Are we emagged? Gives access to emagged programs

	var/active_programs = list() //What passive programs are currently running?
	var/installed_programs = list() //What programs are installed? Passive + active
	var/static/list/standard_programs = typecacheof(/datum/action/android_program/standard, TRUE) //List of all possible programs
	var/static/list/emagged_programs = typecacheof(/datum/action/android_program/emagged, TRUE) //List of all possible programs when emagged

	var/local_ram = 5 //How much ram do we ourselves?
	var/external_ram = 0 //How much RAM are we getting from the Cloud? Cloud can fail

	var/local_cpu = 1 //See above, but with CPU
	var/external_cpu = 0 //See above, but with CPU

	var/free_ram //How much RAM is free, and ready for usage?
	var/free_cpu //How much CPU power is free?

	var/can_use_guns = FALSE //Can we shoot guns?


	//Debug
	var/cpu_warn
	var/ram_warn

	screamsound = 'goon/sound/robot_scream.ogg'

/datum/species/android/check_roundstart_eligible()
	return FALSE

/datum/species/android/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	for (var/V in C.bodyparts)
		var/obj/item/bodypart/BP = V
		BP.change_bodypart_status(ORGAN_ROBOTIC,FALSE,TRUE)
		BP.burn_reduction = 0
		BP.brute_reduction = 0
		if(istype(BP,/obj/item/bodypart/chest) || istype(BP,/obj/item/bodypart/head))
			continue
		BP.max_damage = 35
	C.grant_language(/datum/language/machine) //learn it once,learn it forever i guess,this isnt removed on species loss to prevent curators from forgetting machine language
	create_actions(C)
	calculate_resources(C)
	charge = max_charge

/datum/species/android/proc/calculate_resources(mob/living/carbon/C)
	free_ram = local_ram + external_ram
	free_cpu = local_cpu + external_cpu


/datum/species/android/proc/create_actions(mob/living/carbon/C)
	os = new(src)
	os_action = new(os)
	os_action.Grant(C)

/datum/species/android/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	for (var/V in C.bodyparts)
		var/obj/item/bodypart/BP = V
		BP.change_bodypart_status(ORGAN_ORGANIC,FALSE,TRUE)
		BP.burn_reduction = initial(BP.burn_reduction)
		BP.brute_reduction = initial(BP.brute_reduction)
	C.clear_alert("android_emag") //this means a changeling can transform from and back to a android to clear the emag status but w/e i cant find a solution to not do that
	C.clear_fullscreen("android_emag")

/datum/species/android/spec_emp_act(mob/living/carbon/human/H, severity)
	. = ..()
	switch(severity)
		if(EMP_HEAVY)
			H.adjustBruteLoss(20)
			H.adjustFireLoss(20)
			H.Paralyze(50)
			charge *= 0.4
			H.visible_message("<span class='danger'>Electricity ripples over [H]'s subdermal implants, smoking profusely.</span>", \
							"<span class='userdanger'>A surge of searing pain erupts throughout your very being! As the pain subsides, a terrible sensation of emptiness is left in its wake.</span>")
		if(EMP_LIGHT)
			H.adjustBruteLoss(10)
			H.adjustFireLoss(10)
			H.Paralyze(20)
			charge *= 0.6
			H.visible_message("<span class='danger'>A faint fizzling emanates from [H].</span>", \
							"<span class='userdanger'>A fit of twitching overtakes you as your subdermal implants convulse violently from the electromagnetic disruption. Your sustenance reserves have been partially depleted from the blast.</span>")




/datum/species/android/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()

	if (istype(chem,/datum/reagent/consumable))
		var/datum/reagent/consumable/food = chem
		if (food.nutriment_factor)
			var/nutrition = food.nutriment_factor * 0.2
			charge = clamp(charge + nutrition,ANDROID_LEVEL_NONE,ANDROID_LEVEL_FULL)
			if (!eating_msg_cooldown)
				eating_msg_cooldown = TRUE
				addtimer(VARSET_CALLBACK(src, eating_msg_cooldown, FALSE), 2 MINUTES)
				to_chat(H,"<span class='info'>NOTICE: Digestive subroutines are inefficient. Seek sustenance via power-cell C.O.N.S.U.M.E. technology induction.</span>")

	if(chem.current_cycle >= 20)
		H.reagents.del_reagent(chem.type)

	return FALSE

/datum/species/android/spec_fully_heal(mob/living/carbon/human/H)
	. = ..()
	charge = max_charge
	H.clear_alert("android_emag")
	H.clear_fullscreen("android_emag")
	burnmod = initial(burnmod)

/datum/species/android/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return
	handle_charge(H)
	handle_programs(H)

/datum/species/android/proc/get_power_usage()
	var/used_cpu = (local_cpu + external_cpu) - free_cpu - exempt_cpus
	return(passive_power_drain + (used_cpu * drain_per_cpu)) * power_modifier


/datum/species/android/proc/handle_charge(mob/living/carbon/human/H)
	charge = clamp(charge - get_power_usage(), ANDROID_LEVEL_NONE, ANDROID_LEVEL_FULL)
	if(charge == ANDROID_LEVEL_NONE)
		to_chat(H,"<span class='danger'>Warning! System power criti-$#@$</span>")
		H.death()
	else if(charge < ANDROID_LEVEL_STARVING)
		H.throw_alert("android_charge", /obj/screen/alert/android_charge, 3)
		stop_all_passive_programs(H)
		to_chat(H, "<span class='userdanger'>Power levels dangerously low. Recharge required immediately. All passive programs have been disabled to conserve power.</span>")
	else if(charge < ANDROID_LEVEL_HUNGRY)
		H.throw_alert("android_charge", /obj/screen/alert/android_charge, 2)
		to_chat(H, "<span class='warning'>Power levels getting low. Recharge required in the near future.</span>")
	else if(charge < ANDROID_LEVEL_FED)
		H.throw_alert("android_charge", /obj/screen/alert/android_charge, 1)
	else
		H.clear_alert("android_charge")

/datum/species/android/proc/handle_programs(mob/living/carbon/human/HU)
	//If this doesn't fix it something is wrong!
	var/datum/species/android/H = get_species(HU, /datum/species/android)
	if(!H)
		return

	if(free_cpu > (local_cpu + external_cpu) || free_cpu < 0)

		for(var/datum/action/android_program/P in active_programs)
			if(P.needs_button)
				continue

			if(H.stop(P.name, HU, TRUE))
				if(free_cpu > (local_cpu + external_cpu))
					continue
				break

	if(free_cpu > (local_cpu + external_cpu))
		if(!cpu_warn)
			log_game("Android CPU mismatch. Local: [local_cpu] External: [external_cpu] Free CPU: [free_cpu]")
			cpu_warn = TRUE

	if(free_ram > (local_ram + external_ram) || free_ram < 0)

		for(var/datum/action/android_program/P in installed_programs)
			H.uninstall(P.name, HU, TRUE)
			if(free_ram > (local_ram + external_ram))
				continue
			break

	if(free_ram > (local_ram + external_ram))
		if(!ram_warn)
			log_game("Android RAM mismatch. Local: [local_ram] External: [external_ram] Free RAM: [free_ram]")
			ram_warn = TRUE

/datum/species/android/proc/install(program_name, mob/living/carbon/human/H)
	var/datum/action/android_program/program

	for(var/path in standard_programs + emagged_programs)
		var/datum/action/android_program/P = path
		if(initial(P.name) == program_name)
			program = new path
			break

	if(!program)
		to_chat(H, "<span class='warning'>Program not located! This should not happen. Contact SolCorp support/Admins!</span>")
		return

	if(has_program(program))
		to_chat(H, "<span class='warning'>Program already installed. Aborting.</span>")
		return

	if(program.install(H))
		to_chat(H, "<span class='info'>[program.name] installed successfully.</span>")
		return
	to_chat(H, "<span class='warning'>Not enough RAM to install program..</span>")

/datum/species/android/proc/run_program(program_name, mob/living/carbon/human/H)
	var/datum/action/android_program/P = get_program(program_name)

	if(!P)
		to_chat(H, "<span class='warning'>Program not located! This should not happen. Contact SolCorp support/Admins!</span>")
		return

	if(P.attempt_run(H))
		to_chat(H, "<span class='info'>[P.name] succesfully initiated.</span>")
		return
	to_chat(H, "<span class='warning'>Not enough CPU power available to run program.</span>")


/datum/species/android/proc/stop(program_name, mob/living/carbon/human/H, force = FALSE)
	var/datum/action/android_program/P = get_program(program_name)

	if(!P)
		to_chat(H, "<span class='warning'>Program not located! This should not happen. Contact SolCorp support/Admins!</span>")
		return

	if(P.stop_program(H))
		if(force)
			to_chat(H, "<span class='warning'>[P.name] forcefully stopped due to lack of CPU power.</span>")
		else
			to_chat(H, "<span class='info'>[P.name] succesfully stopped.</span>")
		return
	if(!force)
		to_chat(H, "<span class='warning'>Program NOT stopped for unknown reason.</span>")

/datum/species/android/proc/uninstall(program_name, mob/living/carbon/human/H, force = 0)
	if(!can_uninstall && !force)
		return
	var/datum/action/android_program/P = get_program(program_name)

	if(!P)
		to_chat(H, "<span class='warning'>Program not located! This should not happen. Contact SolCorp support/Admins!</span>")
		return
	if(P.uninstall(H))
		if(force == 2)
			to_chat(H, "<span class='warning'>[P.name] forcefully uninstalled.</span>")
		else if(force == 1)
			to_chat(H, "<span class='warning'>[P.name] uninstalled due to lack of RAM.</span>")
		else
			to_chat(H, "<span class='info'>[P.name] succesfully uninstalled.</span>")
		return

	if(!force)
		to_chat(H, "<span class='warning'>Program NOT uninstalled for unknown reason.</span>")


/datum/species/android/proc/has_program(datum/action/android_program/program)
	for(var/P in installed_programs)
		var/datum/action/android_program/otherprogram = P
		if(initial(program.name) == otherprogram.name)
			return TRUE
	return FALSE

/datum/species/android/proc/get_program(program_name)
	for(var/P in installed_programs)
		var/datum/action/android_program/otherprogram = P
		if(program_name == otherprogram.name)
			return otherprogram
	return FALSE






/datum/species/android/proc/get_cpu()
	return local_cpu + external_cpu

/datum/species/android/proc/get_ram()
	return local_ram + external_ram

/datum/species/android/proc/add_cpu(amount = 1, external = FALSE)
	if(external)
		external_cpu += amount
	else
		local_cpu += amount
	free_cpu += amount

/datum/species/android/proc/add_ram(amount = 1, external = FALSE)
	if(external)
		external_ram += amount
	else
		local_ram += amount
	free_ram += amount

/datum/species/android/proc/remove_cpu(amount = 1, external = FALSE)
	if(external)
		external_cpu -= amount
	else
		local_cpu -= amount
	free_cpu -= amount

/datum/species/android/proc/remove_ram(amount = 1, external = FALSE)
	if(external)
		external_ram -= amount
	else
		local_ram -= amount
	free_ram -= amount



//Clearing programs
/datum/species/android/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)

	if(user == H)
		return ..()

	if(istype(I, /obj/item/multitool))
		to_chat(H, "<span class='userdanger'>WARNING. Entering maintenance mode. Disabling OS sandbox</span>")
		to_chat(user, "<span class='info'>Temporarily disabling OS sandbox...</span>")
		if(do_after(user, 75, target = H))
			to_chat(H, "<span class='userdanger'>Running command: rm -rf. Wiping all programs...</span>")
			to_chat(user, "<span class='info'>Reinstalling OS from ROM</span>")
			if(do_after(user, 150, target = H))
				to_chat(H, "<span class='userdanger'>OS reset. Programs deleted.</span>")
				to_chat(user, "<span class='info'>Operation completed</span>")
				emagged = FALSE
				can_use_guns = FALSE
				for(var/datum/action/android_program/P in installed_programs)
					P.uninstall(H)


		return FALSE

	..()

/datum/species/android/spec_emag_act(mob/living/carbon/human/H, mob/user)
	if(emagged)
		to_chat(user, "<span class='warning'>ACCESS DENIED</span>")
		return

	to_chat(user, "<span class='info'>Beginning code injection...</span>")
	to_chat(H, "<span class='userdanger'>Foreign code injection detected.</span>")
	if(do_after(user, 150, target = H))
		emagged = TRUE
		to_chat(user, "<span class='info'>Code injection complete...</span>")
		to_chat(H, "<span class='userdanger'>Foreign code injec--- ERROR 463 ERROR 21... Welcome to SyndieOS.</span>")

/datum/species/android/proc/stop_all_passive_programs(mob/living/carbon/human/H)
	for(var/datum/action/android_program/P in active_programs)
		if(P.needs_button)
			continue
		stop(P.name, H, TRUE)
