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

/obj/machinery/power/generator_control/ui_interact(mob/user, datum/tgui/ui)
	if(!generators.len)
		to_chat(user, "<span class='warning'>The controller is unable to connect to any turbines within 30 metres!</span>")
		return
	
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GeneratorController")
		ui.open()

/obj/machinery/power/generator_control/ui_data()
	var/list/data = list()

	data["generators"] = list()

	for(var/obj/machinery/power/water/fusion_gen/center/gen in generators)
		var/average_used_capacity = 0
		if(gen.average_capacity_usage.len)
			var/total = 0
			var/length = gen.average_capacity_usage.len
			for(var/i in gen.average_capacity_usage)
				total += i
			average_used_capacity = total / length

		var/average_power_output = 0
		if(gen.average_power_output.len)
			var/total = 0
			var/length = gen.average_power_output.len
			for(var/i in gen.average_power_output)
				total += i
			average_power_output = total / length

		var/generator = list(list("name" = gen.name, "last_tick_steam" = gen.last_tick_usage, "max_tick" = gen.max_throughput, "optimal_temp" = gen.optimal_temp, "efficiency" = gen.efficiency, "conversion" = gen.conversion_rate, "average_usage" = average_used_capacity, "temp" = gen.last_temp, "average_power" = average_power_output))
		data["generators"] += generator

	return data
