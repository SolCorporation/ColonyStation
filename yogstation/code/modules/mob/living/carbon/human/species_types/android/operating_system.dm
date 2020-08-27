//The Holy Grail of Androids
//Their operating system controls all their perks, debuffs and anything of the sort. Their brain.

/datum/action/innate/android_os
	name = "Access Operating System"
	desc = "Monitor and Configure internal settings"
	icon_icon = 'icons/obj/modular_laptop.dmi'
	button_icon_state = "laptop-off"
	background_icon_state = "bg_tech"
	var/datum/operating_system/os


/datum/action/innate/android_os/New(target_os)
	. = ..()
	button.name = name
	if(istype(target_os, /datum/operating_system))
		os = target_os

/datum/action/innate/android_os/Activate()
	os.ui_interact(owner)


/datum/operating_system
	var/name = "Operating System"
	var/datum/species/android/android

/datum/operating_system/New(new_android)
	. = ..()
	android = new_android

/datum/operating_system/Destroy()
	android = null
	. = ..()

/datum/operating_system/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "OperatingSystem", name, 900, 480, master_ui, state)
		ui.open()

/datum/operating_system/ui_data(mob/user)
	var/list/data = list()

	data["installed_programs"] = list()
	data["installed_programs_text"] = list()

	for(var/datum/action/android_program/P in android.installed_programs)
		data["installed_programs"] += list(list("name" = P.name, "desc" = P.pdesc, "cpu_cost" = P.cpu_cost, "ram_cost" = P.ram_cost, "active" = P.active, "requires_button" = P.needs_button))
		data["installed_programs_text"] += P.name


	data["emagged"] = android.emagged
	data["can_use_guns"] = android.can_use_guns

	data["total_cpu"] = android.local_cpu + android.external_cpu
	data["local_cpu"] = android.local_cpu
	data["external_cpu"] = android.external_cpu
	data["free_cpu"] = android.free_cpu

	data["total_ram"] = android.local_ram + android.external_ram
	data["local_ram"] = android.local_ram
	data["external_ram"] = android.external_ram
	data["free_ram"] = android.free_ram

	data["charge"] = android.charge
	data["max_charge"] = android.max_charge

	data["power_usage"] = android.get_power_usage()

	data["can_uninstall"] = android.can_uninstall


	return data

/datum/operating_system/ui_static_data(mob/user)
	var/list/data = list()


	data["available_programs"] = list()
	data["emagged_programs"] = list()

	for(var/path in android.standard_programs)
		var/datum/action/android_program/P = new path
		data["available_programs"] += list(list("name" = P.name, "desc" = P.pdesc, "cpu_cost" = P.cpu_cost, "ram_cost" = P.ram_cost))
		qdel(P)

	for(var/path in android.emagged_programs)
		var/datum/action/android_program/P = new path
		data["emagged_programs"] += list(list("name" = P.name, "desc" = P.pdesc, "cpu_cost" = P.cpu_cost, "ram_cost" = P.ram_cost))
		qdel(P)

	return data

/datum/operating_system/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("install")
			var/program_name = params["name"]
			android.install(program_name, usr)
		if("run")
			var/program_name = params["name"]
			android.run_program(program_name, usr)
		if("stop")
			var/program_name = params["name"]
			android.stop(program_name, usr)
		if("uninstall")
			var/program_name = params["name"]
			android.uninstall(program_name, usr)
