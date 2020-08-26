/obj/machinery/computer/reactor_control
	name = "fusion reactor controller"
	desc = "Used to monitor and control the fusion reaction. (In a fusion reactor...)"
	icon_screen = "power"
	icon_keyboard = "power_key"
	circuit = /obj/item/circuitboard/computer/reactor_control

	light_color = LIGHT_COLOR_YELLOW

	var/detectionRadius = 15

	var/obj/machinery/power/fusion/core/reactor

	var/obj/item/disk/fuel_mix/mix

/obj/machinery/computer/reactor_control/Initialize()
	for(var/obj/machinery/power/fusion/core/R in orange(detectionRadius, src))
		reactor = R
		reactor.controller = src
		continue
	..()

/obj/machinery/computer/reactor_control/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/disk/fuel_mix))
		if(mix)
			mix.forceMove(get_turf(src))
			mix = null
		mix = W
		W.forceMove(src)

/obj/machinery/computer/reactor_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(!reactor)
		to_chat(user, "<span class='warning'>The computer is unable to connect to a reactor. It has to be within 15 metres!</span>")
		return

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "FusionController", name, 475, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/reactor_control/ui_data()
	var/list/data = list()

	data["status"] = reactor.getStatus()

	var/state = "good"

	if(reactor.currentTemp > (reactor.maxTemp * 0.75))
		state = "average"
	if(reactor.currentTemp > (reactor.maxTemp * 0.9))
		state = "bad"

	data["deuterium"] = reactor.deuterium
	data["tritium"] = reactor.tritium

	data["tempState"] = state
	data["minTemp"] = reactor.minTemp
	data["maxTemp"] = reactor.maxTemp

	data["overheating"] = reactor.overheating

	data["meltDown"] = reactor.meltedDown

	data["temp"] = reactor.currentTemp

	data["injecting"] = reactor.injectingFuel

	data["collecting"] = reactor.sendingHeat
	data["running"] = reactor.reacting

	data["cryo"] = reactor.cryo

	data["preheating"] = reactor.preHeating

	data["maxPower"] = DisplayPower(reactor.getMaxOutput(TRUE))

	if(mix)
		data["hasMix"] = TRUE
	else
		data["hasMix"] = FALSE

	data["fuelAdditives"] = list()
	if(mix)
		data["deuteriumFuel"] = mix.deuteriumMix
		data["tritiumFuel"] = mix.tritiumMix
		for(var/datum/fuel_additive/additive in mix.additives)
			data["fuelAdditives"] += list(list("fuelName" = additive.name))
	else
		data["deuteriumFuel"] = 0
		data["tritiumFuel"] = 0

	return data

/obj/machinery/computer/reactor_control/ui_act(action, params)
	if(..())
		return
	if(!reactor)
		return
	switch(action)
		if("toggleInject")
			reactor.toggleInject()
			. = TRUE
		if("startReaction")
			if(!mix)
				return
			reactor.tryReaction()
			. = TRUE
		if("toggleCollect")
			reactor.toggleCollect()
			. = TRUE
		if("flush")
			reactor.flush()
			. = TRUE
		if("ejectMix")
			if(!mix || reactor.status != "stopped")
				return
			mix.forceMove(get_turf(src))
			mix = null
			. = TRUE
		if("cryo")
			reactor.InjectCryo()
			. = TRUE
		if("togglePreheat")
			reactor.togglePreheating()
			. = TRUE

/obj/item/circuitboard/computer/reactor_control
	name = "Fusion Reactor Controller (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/reactor_control

