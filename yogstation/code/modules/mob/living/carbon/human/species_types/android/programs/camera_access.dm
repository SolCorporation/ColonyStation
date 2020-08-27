/datum/action/android_program/standard/camera_access
	name = "Camera Network Access"
	desc = "Access the camera network"
	pdesc = "Connects to the local camera network."

	button_icon = 'icons/mob/screen_ai.dmi'
	background_icon_state = "camera"
	icon_icon = null

	needs_button = TRUE
	//Costs
	cpu_cost = 1 //What does it cost to RUN the program?

	ram_cost = 1 //What does it cost to INSTALL the program?

	var/network = list("ss13")
	var/hard_stop = FALSE


/datum/action/android_program/standard/camera_access/proc/cancel_camera(mob/user)
	user.reset_perspective(null)


/datum/action/android_program/standard/camera_access/run_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE

	addtimer(CALLBACK(src, .proc/stop_program, user), 1200)

	awaiting_callback = TRUE

	to_chat(user, "<span class='info'>[name] instance initiated. CPU power will be re-available in 120 seconds.</span>")

	hard_stop = FALSE
	use_camera(user)

	return TRUE

/datum/action/android_program/standard/camera_access/stop_program(mob/user)
	var/datum/species/android/A = get_species(user, /datum/species/android)
	if(!A)
		return FALSE


	to_chat(user, "<span class='info'>[name] instance finished. Freed CPU Power: [cpu_cost]</span>")
	hard_stop = TRUE

	cancel_camera(user)
	return stop_active_program(user)

/datum/action/android_program/standard/camera_access/proc/use_camera(mob/user)
	if(hard_stop)
		cancel_camera(user)
		return
	var/list/camera_list = get_available_cameras()
	var/t = input(user, "Which camera should you change to?") as null|anything in camera_list
	if(!t)
		cancel_camera(user)
		return

	var/obj/machinery/camera/C = camera_list[t]

	if(t == "Cancel")
		cancel_camera(user)
		return

	if(C)
		var/camera_fail = 0
		if(!C.can_use() || user.eye_blind || user.incapacitated())
			camera_fail = 1

		if(camera_fail)
			cancel_camera(user)
			return 0

		user.reset_perspective(C)
		user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
		user.clear_fullscreen("flash", 5)

		addtimer(CALLBACK(src, .proc/use_camera, user), 5)
	else
		cancel_camera(user)


/datum/action/android_program/standard/camera_access/proc/get_available_cameras()
	if(hard_stop)
		cancel_camera(owner)
		return
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if((is_away_level(owner.z) || C.z != owner.z))
			continue
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			D["[C.c_tag][(C.status ? null : " (Deactivated)")]"] = C
	return D