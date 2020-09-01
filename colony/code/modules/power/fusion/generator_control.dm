/obj/machinery/power/generator_control
	name = "thermo generator controller"
	desc = "This little thing controls the generators, that turn heat into actual power."
	icon = 'goon/icons/obj/fusion_control.dmi'
	icon_state = "cab3"

	density = TRUE


	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 500

	var/list/generators = list()


/obj/machinery/power/generator_control/Initialize()
	for(var/obj/machinery/power/fusion_gen/G in orange(15, src))
		if(G.reactor)
			generators += G
	..()

/obj/machinery/power/generator_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(generators.len == 0)
		for(var/obj/machinery/power/fusion_gen/G in orange(15, src))
			if(G.reactor)
				generators += G
	if(!ui)
		ui = new(user, src, ui_key, "GeneratorController", name, 475, 800, master_ui, state)
		ui.open()

/obj/machinery/power/generator_control/ui_data()
	var/list/data = list()

	data["generator"] = list()

	for(var/obj/machinery/power/fusion_gen/G in generators)
		var/list/upgrades = list()
		for(var/obj/item/generator_upgrade/upgrade in G.upgrades)
			upgrades += list(list("upNameG" = upgrade.upgrade.name))
		var/onOff = 1
		if(G.status == GENERATOR_OFF)
			onOff = 0
		data["generator"] += list(list("gName" = G.name, "condition" = G.condition, "gen" = REF(G),
		"maxHeat" = G.warmUpMax, "gUps" = upgrades, "heat" = G.warmUp, "lastOutput" = DisplayPower(G.lastOutput), "status" = G.returnStatus(),
		"cutoff" = G.warmUpMax * G.heatGenerationCutoff, "on" = onOff))

	return data

/obj/machinery/power/generator_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggleOn")
			var/obj/machinery/power/fusion_gen/G = locate(params["G"])
			G.toggleOn()
			. = TRUE
