/obj/machinery/exploration/machines
	name = "ARTIFACT MACHINE"
	desc = "Look away, this is embarrasing!"
	density = TRUE
	use_power = IDLE_POWER_USE
	var/act
	var/specific

	var/obj/item/artifact/art

	var/cooldown = 1200

	var/cooldownTimer = 0

	var/running = FALSE

/obj/machinery/exploration/machines/Initialize()
	START_PROCESSING(SSobj, src)
	..()

/obj/machinery/exploration/machines/process()
	if(running)
		if(world.time > cooldownTimer)
			Finished()

/obj/machinery/exploration/machines/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(art)
		art.forceMove(get_turf(src))
	art = null
	..()

/obj/machinery/exploration/machines/proc/Finished()
	applyAct()
	running = FALSE
	remove()
	update_icon()

/obj/machinery/exploration/machines/proc/SwitchSpecific(newSpecific)
	if(running)
		return
	specific = newSpecific

/obj/machinery/exploration/machines/proc/Begin()
	if(running)
		return
	if(!art)
		return
	cooldownTimer = world.time + cooldown

	running = TRUE
	update_icon()

/obj/machinery/exploration/machines/proc/applyAct()
	if(cooldownTimer > world.time)
		visible_message("<span class='warning'>Cooldown period active. Please wait [(cooldownTimer - world.time) / 10] second(s)</span>")
		return

	if(!art)
		visible_message("<span class='warning'>No artifact loaded</span>")
		return
	art.onAttempt(act, specific, src)

/obj/machinery/exploration/machines/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/artifact))
		if(art)
			return
		art = W
		W.forceMove(src)
		visible_message("<span class='notice'>Artifact recieved...</span>")

	..()

/obj/machinery/exploration/machines/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("specific")
			SwitchSpecific(params["newSpecific"])
		if("eject")
			if(!running)
				remove()
				running = FALSE
				update_icon()
		if("begin")
			if(art && !running)
				Begin()
		if("abort")
			if(running)
				running = FALSE
				update_icon()

/obj/machinery/exploration/machines/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ArtifactMachine", name, 475, 800, master_ui, state)
		ui.open()

/obj/machinery/exploration/machines/ui_data()
	var/list/data = list()

	data["running"] = running

	var/stat
	if(running)
		stat = "Running"
	else
		stat = "Idle"

	data["status"] = stat

	data["max"] = cooldown
	data["ticksRemaining"] = cooldownTimer - world.time
	data["timeRemaining"] = (cooldownTimer - world.time) / 10
	data["art"] = art
	data["curSpecific"] = specific

	return data

/obj/machinery/exploration/machines/proc/remove()
	if(art)
		art.forceMove(get_turf(src))
	art = null
	visible_message("<span class='notice'>Ejecting artifact...</span>")

/obj/machinery/exploration/machines/proc/success()
	art = null
