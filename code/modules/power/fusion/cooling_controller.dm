/obj/machinery/power/cooling_controller
	name = "coolant controller"
	desc = "The main control console for the cooling towers and condensers."
	icon = 'goon/icons/obj/fusion_control.dmi'
	icon_state = "cab2"

	density = TRUE
	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 500

	var/list/condenser = list()

	var/list/exchanger = list()

/obj/machinery/power/cooling_controller/Initialize()
	. = ..()
	for(var/obj/machinery/power/water/condenser/con in orange(30, src))	
		condenser += con

	for(var/obj/machinery/power/water/heat_exchanger/heat in orange(30, src))	
		exchanger += heat

/obj/machinery/power/cooling_controller/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(!condenser.len && !exchanger.len)
		to_chat(user, "<span class='warning'>The controller is unable to connect to any cooling machines within 30 metres!</span>")
		return

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CoolingController", name, 475, 800, master_ui, state)
		ui.open()

/obj/machinery/power/cooling_controller/ui_data()
	var/list/data = list()

	data["condensers"] = list()

	for(var/obj/machinery/power/water/condenser/con in condenser)
		var/condenser = list(list("name" = con.name, "cooling" = con.water_cooling_temp, "cooled_last" = con.last_water_amount, "max_capacity" = con.max_capacity, "temp_output" = con.last_temp = 0))
		data["condensers"] += condenser


	data["heat_exchangers"] = list()

	for(var/obj/machinery/power/water/heat_exchanger/heat in exchanger)
		var/heater = list(list("name" = heat.name, "cooling" = clamp(SSterraforming.atmos.getTemp() * heat.water_cooling_modifier, MINIMUM_WATER_TEMP, INFINITY), "cooled_last" = heat.last_water_amount, 
		"max_capacity" = heat.cooling_capacity, "temp_output" = heat.last_temp))
		data["heat_exchangers"] += heater

	return data
