/obj/machinery/power/neutron_control
	name = "neutron injection controller"
	desc = "This little thing controls the neutron injectors, without it there is no fuel."
	icon = 'goon/icons/obj/fusion_control.dmi'
	icon_state = "cab2"

	density = TRUE
	var/temp
	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 500

	var/list/injectors = list()


/obj/machinery/power/neutron_control/Initialize()
	for(var/obj/machinery/power/neutron_inj/INJ in orange(15, src))
		if(INJ.reactor)
			injectors += INJ
	..()

/obj/machinery/power/neutron_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "neutron_controller", name, 475, 800, master_ui, state)
		ui.open()

/obj/machinery/power/neutron_control/ui_data()
	var/list/data = list()

	data["injector"] = list()

	for(var/obj/machinery/power/neutron_inj/I in injectors)

		var/tempList
		tempList += list(list("injName" = I.name, "fuel" = I.setting, "inj" = REF(I),
		"fuelAmount" = I.fuelPerProcess, "NUps" = list(), "running" = I.running))
		for(var/obj/item/neutron_upgrade/upgrade in I.upgrades)
			tempList[1]["NUps"] += list(list("upNameN" = upgrade.upgrade.name))
		data["injector"] += tempList
	temp = data
	return data

/obj/machinery/power/neutron_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggleFuel")
			var/obj/machinery/power/neutron_inj/I = locate(params["inj"])
			I.toggleFuel()
			. = TRUE
		if("toggleActive")
			var/obj/machinery/power/neutron_inj/I = locate(params["inj"])
			I.toggleOn()
			. = TRUE