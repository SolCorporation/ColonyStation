/obj/machinery/terraformer
	name = "atmospheric terraformer"
	icon = 'icons/obj/96x96.dmi'
	icon_state = "terraformer_off"
	desc = "A large, power hungry machine that slowly changes the atmosphere of the terrestrial body it is on."
	use_power = IDLE_POWER_USE
	idle_power_usage = 500
	active_power_usage = 250000
	var/base_power_usage = 250000
	circuit = /obj/item/circuitboard/machine/terraformer

	density = TRUE

	var/cooldown = 300
	var/cooldownMultiplier = 1.5
	var/cooldownBase = 300
	var/cooldownTimer

	var/on = FALSE

	var/list/possibleGasses = list()

	var/molesPerProcess = 0.15
	var/baseMoles = 0.15

	bound_width = 96
	bound_height = 96


/obj/machinery/terraformer/Initialize()
	for(var/D in subtypesof(/datum/terraforming_gas))
		possibleGasses += new D()
	..()

/obj/machinery/terraformer/Destroy()
	..()

/obj/machinery/terraformer/process()
	if(on)
		use_power = ACTIVE_POWER_USE
		if(!powered())
			on = FALSE
			update_icon()
			use_power = IDLE_POWER_USE
	else
		use_power = IDLE_POWER_USE
	if(cooldownTimer < world.time && on)
		HandleTerraforming()
		cooldownTimer = world.time + cooldown

/obj/machinery/terraformer/proc/recalculateProperties()
	var/activeGasses = 0
	for(var/datum/terraforming_gas/gas in possibleGasses)
		if(gas.active)
			activeGasses++
	if(activeGasses == 0)
		molesPerProcess = baseMoles
		active_power_usage = base_power_usage
		cooldown = cooldownBase
	else
		molesPerProcess = baseMoles / activeGasses
		active_power_usage = base_power_usage * activeGasses
		if(activeGasses == 1)
			cooldown = cooldownBase
		else
			cooldown = cooldownBase * ((cooldownMultiplier) ** activeGasses)


/obj/machinery/terraformer/proc/HandleTerraforming()
	if(!on)
		return
	if(stat & NOPOWER)
		return
	var/list/updatedAtmos = list()
	for(var/datum/terraforming_gas/gasD in possibleGasses)
		if(gasD.active && gasD.unlocked)
			updatedAtmos[gasD.gas] = molesPerProcess

	SSterraforming.updateAtmosphere(updatedAtmos)

/obj/machinery/terraformer/update_icon()
	if(on)
		icon_state = "terraformer"
	else
		icon_state = "terraformer_off"

/obj/machinery/terraformer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Terraformer", name, 600, 700, master_ui, state)
		ui.open()

/obj/machinery/terraformer/ui_data()
	var/list/data = list()
	var/totalPressure = SSterraforming.atmos.getPressure()
	var/temp = SSterraforming.atmos.getTemp()

	data["on"] = on
	if(on)
		data["powerUsage"] = DisplayPower(active_power_usage)
	else
		data["powerUsage"] = DisplayPower(idle_power_usage)
	data["cooldown"] = round(cooldown / 10, 0.001)
	data["molesPerCycle"] = round(molesPerProcess, 0.001)
	data["pressure"] = round(totalPressure, 0.001)
	data["o2"] = SSterraforming.atmos.getSpecificAtmos("o2")
	data["n2"] = SSterraforming.atmos.getSpecificAtmos("n2")
	data["co2"] = SSterraforming.atmos.getSpecificAtmos("co2")
	data["n2o"] = SSterraforming.atmos.getSpecificAtmos("n2o")
	data["plasma"] = SSterraforming.atmos.getSpecificAtmos("plasma")
	data["temp"] = round(temp, 0.001)
	data["c"] = round(temp - 273.15, 0.001)


	data["gasses"] = list()
	for(var/datum/terraforming_gas/Ogas in possibleGasses)
		if(!Ogas.unlocked)
			continue
		data["gasses"] += list(list("active" = Ogas.active, "gas" = Ogas.gas, "gasName" = Ogas.name))
	return data

/obj/machinery/terraformer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggleOn")
			on = !on
			if(on)
				cooldownTimer = world.time + cooldown
				recalculateProperties()
			update_icon()
			. = TRUE
		if("toggleGas")
			for(var/datum/terraforming_gas/Ogas in possibleGasses)
				if(Ogas.gas == params["gasType"])
					Ogas.active = !Ogas.active
					recalculateProperties()
				. = TRUE

/datum/terraforming_gas
	var/name = "TEST"
	var/gas = "TEST"
	var/active = FALSE
	var/unlocked = TRUE

/datum/terraforming_gas/oxy
	name = "Oxygen"
	gas = "o2"
	active = FALSE

/datum/terraforming_gas/n2
	name = "Nitrogen"
	gas = "n2"
	active = FALSE

/datum/terraforming_gas/carbon_dioxide
	name = "CO2"
	gas = "co2"
	active = FALSE

/datum/terraforming_gas/n2o
	name = "N2O"
	gas = "n2o"
	active = FALSE
	unlocked = FALSE

/datum/terraforming_gas/plasma
	name = "Plasma"
	gas = "plasma"
	active = FALSE
	unlocked = FALSE
