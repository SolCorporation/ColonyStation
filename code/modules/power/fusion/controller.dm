/obj/machinery/computer/reactor_control
	name = "fusion reactor controller"
	desc = "Used to monitor and control the fusion reaction. (In a fusion reactor...)"
	icon_screen = "power"
	icon_keyboard = "power_key"
	circuit = /obj/item/circuitboard/computer/reactor_control

	light_color = LIGHT_COLOR_YELLOW

	var/detectionRadius = 15

	var/obj/machinery/power/water/fusion/core/reactor

	var/obj/item/disk/fuel_mix/mix

/obj/machinery/computer/reactor_control/Initialize()
	for(var/obj/machinery/power/water/fusion/core/R in orange(detectionRadius, src))
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
		
/obj/machinery/computer/reactor_control/ui_interact(mob/user, datum/tgui/ui)
	if(!reactor)
		to_chat(user, "<span class='warning'>The computer is unable to connect to a reactor. It has to be within 15 metres!</span>")
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FusionController")
		ui.open()

/obj/machinery/computer/reactor_control/ui_data()
	var/list/data = list()

	data["internal_heat"] = reactor.internal_heat
	data["internal_heat_max"] = reactor.max_internal_heat

	data["core_heat"] = reactor.heat
	data["core_heat_max"] = reactor.max_heat

	data["health"] = reactor.containment_health

	data["meltdown"] = reactor.meltdown

	data["fuel"] = list()

	for(var/obj/item/fuel_rod/rod in reactor.fuel)
		var/fuel_data = list(list("amount" = rod.fuel_amount, "max_amount" = rod.max_fuel, "name" = rod.fuel.name, "power_multi" = rod.fuel.power_multiplier, "heat_multi" = rod.fuel.heat_multiplier))
		data["fuel"] += fuel_data

	data["fuel_use"] = reactor.fuel_use


	return data


/obj/item/circuitboard/computer/reactor_control
	name = "Fusion Reactor Controller (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/reactor_control

