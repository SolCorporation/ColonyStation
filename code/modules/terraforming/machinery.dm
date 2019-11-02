/obj/machinery/terraformer
	name = "Atmospheric Terraformer"
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter-broken"
	desc = "A large, power hungry machine that slowly changes the atmosphere of the terrestrial body it is on."
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 250
	circuit = /obj/item/circuitboard/machine/terraformer

	var/atmos_goal = 0 //the goal of said gas, in mols
	var/atmos_goal_gas = "o2" //what gas it's doing
	var/cost_modifier = 10 //use this when making upgrades for the machine
	var/list/cur_atmos = null // the current atmosphere
	var/on = FALSE // bruh
	var/molsPerTick = 0.001

/obj/machinery/terraformer/Initialize()
	. = ..()
	cur_atmos = SSterraforming.atmos.getAtmosString()

/obj/machinery/terraformer/ui_interact(mob/user)
	. = ..()
	var/dat = "Terraformer<br><br>"
	if(powered(power_channel))
		cur_atmos = SSterraforming.atmos.getAtmosString()
		dat += "Current Atmosphere: [cur_atmos]<br>"
		dat += "Current goal (mols, gas): [atmos_goal], [atmos_goal_gas]<br>"
		dat += "<a href='byond://?src=[REF(src)];on=1'>Turn On</a>  <a href='byond://?src=[REF(src)];off=1'>Turn Off</a><br><br>"
		dat += "<a href='byond://?src=[REF(src)];o2=1'>Oxygen</a><BR>"
		dat += "<a href='byond://?src=[REF(src)];n2=1'>Nitrogen</a><BR>"
		dat += "<a href='byond://?src=[REF(src)];co2=1'>Carbon Dioxide</a><BR>"
	user << browse(dat, "window=terraformer")
	onclose(user, "terraformer")

/obj/machinery/terraformer/Topic(href, href_list)
	if(..())
		return
	if(href_list["o2"])
		atmos_goal_gas = "o2"
		return
	else if(href_list["n2"])
		atmos_goal_gas = "n2"
		return
	else if(href_list["co2"])
		atmos_goal_gas = "co2"
		return
	else if(href_list["on"])
		on = TRUE
		return
	else if(href_list["off"])
		on = FALSE
		return
	else
		return

/obj/machinery/terraformer/process()
	. = ..()
	if(!on)
		return
	else
		changeAtmos()

/obj/machinery/terraformer/proc/changeAtmos()
	var/current_gas = SSterraforming.atmos.getSpecificAtmos(atmos_goal_gas)
	if(current_gas > atmos_goal)
		SSterraforming.updateAtmosphere(list(atmos_goal_gas = -molsPerTick))
		return
	else if(current_gas < atmos_goal)
		SSterraforming.updateAtmosphere(list(atmos_goal_gas = molsPerTick))
		return
	else
		return
