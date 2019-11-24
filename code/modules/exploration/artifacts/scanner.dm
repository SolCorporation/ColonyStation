//Used for figuring out the order in which to do artifacts

/obj/machinery/exploration/machines/analyzer
	name = "artifact analyzer"
	desc = "Learn science by... Analyzing... Things.."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "d_analyzer"

	act = "SCANNER"
	specific = "SCANNER"


	cooldown = 3000

/obj/machinery/exploration/machines/analyzer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "artifact_analyzer", name, 475, 800, master_ui, state)
		ui.open()

/obj/machinery/exploration/machines/analyzer/ui_data()
	var/list/data = list()

	data["running"] = running
	data["max"] = cooldown
	data["ticksRemaining"] = cooldownTimer - world.time
	data["timeRemaining"] = (cooldownTimer - world.time) / 10
	data["art"] = art

	var/stat
	if(running)
		stat = "Running"
	else
		stat = "Idle"

	data["status"] = stat

	return data

/obj/machinery/exploration/machines/analyzer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("abort")
			if(running)
				running = FALSE
				update_icon()
		if("eject")
			if(!running)
				remove()
				running = FALSE
				update_icon()
		if("begin")
			if(art && !running)
				Begin()


/obj/machinery/exploration/machines/analyzer/Finished()
	if(!running)
		return
	if(!art)
		visible_message("<span class='warning'>No artifact loaded</span>")
		return

	visible_message("<span class='danger'>The scanner reports that the next step should be: [art.getNextStep()]</span>")

	running = FALSE
	remove()
	update_icon()

/obj/machinery/exploration/machines/analyzer/update_icon()
	if(running)
		icon_state = "d_analyzer_process"
	else if(!running && art)
		icon_state = "d_analyzer_l"
	else
		icon_state = initial(icon_state)

/obj/machinery/exploration/machines/analyzer/success()
	return

/obj/machinery/exploration/machines/analyzer/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/artifact))
		if(art)
			flick("d_analyzer_la", src)
			update_icon()

