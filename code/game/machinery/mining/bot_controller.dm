/obj/machinery/computer/mining_bot_control
	name = "mining drone controller"
	desc = "Used to order around the mining drones."
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/mining_bot_control
	light_color = "#E2853D"//orange

/obj/machinery/computer/mining_bot_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Miningdronecontrol", name, 550, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/mining_bot_control/ui_data()
	var/list/data = list()

	data["drones"] = list()
	for(var/obj/machinery/mining/bot/drones in GLOB.mining_bots)
		var/list/upgrades = list()
		for(var/obj/item/mining_upgrade/upgradesBot in drones.appliedUpgrades)
			upgrades += list(list("upName" = upgradesBot.upgrade.name))
		data["drones"] += list(list("cargo" = drones.cargo, "name" = drones.name, "cargoLen" = drones.cargo.len, "cargoMax" = drones.maxCargo,
		"mining" = drones.mining, "botID" = REF(drones), "upgradesLen" = drones.appliedUpgrades.len, "upgradesMax" = drones.maxUpgrades,
		"upgrades" = upgrades, "charge" = drones.battery.charge, "chargePercent" = drones.battery.percent(), "maxcharge" = drones.battery.maxcharge,
		"mineDelay" = (drones.miningCooldown / 10), "mineAmount" = drones.oresPerCycle, "powerUsage" = drones.powerUsage))
	return data

/obj/machinery/computer/mining_bot_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggleMining")
			var/obj/machinery/mining/bot/bot = locate(params["bot"])
			bot.toggleMining()
			. = TRUE
		if("unload")
			var/obj/machinery/mining/bot/bot = locate(params["bot"])
			if(!bot.mining)
				bot.Unload()
				. = TRUE

/obj/item/circuitboard/computer/mining_bot_control
	name = "Mining Drone Controller (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/mining_bot_control

