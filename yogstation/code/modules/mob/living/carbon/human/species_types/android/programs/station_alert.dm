GLOBAL_LIST_EMPTY(android_alerts)

/datum/action/android_program/standard/station_alert
	name = "Colony Alert Network Access"
	desc = "Access the alert network"
	pdesc = "Monitors the colony-wide alert network."

	button_icon = 'icons/mob/screen_ai.dmi'
	background_icon_state = "alerts"
	icon_icon = null

	needs_button = TRUE
	//Costs
	cpu_cost = 1 //What does it cost to RUN the program?

	ram_cost = 1 //What does it cost to INSTALL the program?
	var/datum/browser/ui
	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())

/datum/action/android_program/standard/station_alert/New(Target)
	..(Target)
	GLOB.android_alerts += src

/datum/action/android_program/standard/station_alert/Destroy()
	GLOB.android_alerts -= src
	..()

/datum/action/android_program/standard/station_alert/run_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE


	addtimer(CALLBACK(src, .proc/stop_program, user), 1200)

	awaiting_callback = TRUE

	to_chat(user, "<span class='info'>[name] instance initiated. CPU power will be re-available in 120 seconds.</span>")
	alerts()

	return TRUE

/datum/action/android_program/standard/station_alert/stop_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE


	to_chat(user, "<span class='info'>[name] instance finished. Freed CPU Power: [cpu_cost]</span>")
	ui.close()
	qdel(ui)

	return stop_active_program(user)

/datum/action/android_program/standard/station_alert/proc/alerts()
	var/dat = ""
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				dat += "<NOBR>"
				dat += text("-- [A.name]")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	ui = new(owner, "robotalerts", "Current Colony Alerts", 400, 410)
	ui.set_content(dat)
	ui.open()

/datum/action/android_program/standard/station_alert/proc/triggerAlarm(class, area/A, O, obj/alarmsource)
	if(alarmsource.z != owner.z)
		return
	if(owner.stat == DEAD)
		return 1
	var/list/L = alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	return 1

/datum/action/android_program/standard/station_alert/proc/cancelAlarm(class, area/A, obj/origin)
	var/list/L = alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I

	return !cleared
