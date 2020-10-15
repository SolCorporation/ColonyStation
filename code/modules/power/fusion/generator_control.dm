/obj/machinery/power/generator_control
	name = "turbine monitor"
	desc = "The main monitoring console for the turbines."
	icon = 'goon/icons/obj/fusion_control.dmi'
	icon_state = "cab3"

	density = TRUE


	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 500

	var/list/generators = list()

/obj/machinery/power/generator_control/Initialize()
	. = ..()
	for(var/obj/machinery/power/water/fusion_gen/center/gen in orange(30, src))	
		generators += gen


/obj/machinery/power/generator_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(!generators.len)
		to_chat(user, "<span class='warning'>The controller is unable to connect to any turbines within 30 metres!</span>")
		return

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "GeneratorController", name, 475, 800, master_ui, state)
		ui.open()

/obj/machinery/power/generator_control/ui_data()
	var/list/data = list()

	data["generators"] = list()

	for(var/obj/machinery/power/water/fusion_gen/center/gen in generators)
		var/generator = list(list("name" = gen.name, "last_tick_steam" = gen.last_tick_usage, "max_tick" = gen.max_throughput, "optimal_temp" = gen.optimal_temp, "efficiency" = gen.efficiency, "conversion" = gen.conversion_rate))
		data["generators"] += generator

	return data
