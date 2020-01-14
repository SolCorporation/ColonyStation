//"immutable" gas mixture used for immutable calculations
//it can be changed, but any changes will ultimately be undone before they can have any effect

/datum/gas_mixture/immutable
	var/initial_temperature = 0

/datum/gas_mixture/immutable/New()
	..()
	set_temperature(initial_temperature)
	populate()
	mark_immutable()

/datum/gas_mixture/immutable/proc/populate()
	return

//used by space tiles
/datum/gas_mixture/immutable/space
	initial_temperature = TCMB

/datum/gas_mixture/immutable/space/populate()
	set_min_heat_capacity(HEAT_CAPACITY_VACUUM)

//used by cloners
/datum/gas_mixture/immutable/cloner
	initial_temperature = T20C

/datum/gas_mixture/immutable/cloner/populate()
	set_moles(/datum/gas/nitrogen, MOLES_O2STANDARD + MOLES_N2STANDARD)

/datum/gas_mixture/immutable/cloner/garbage_collect()
	..()
	ADD_GAS(/datum/gas/nitrogen, gases)
	gases[/datum/gas/nitrogen][MOLES] = MOLES_O2STANDARD + MOLES_N2STANDARD

/datum/gas_mixture/immutable/cloner/heat_capacity()
	return (MOLES_O2STANDARD + MOLES_N2STANDARD)*20 //specific heat of nitrogen is 20

/datum/gas_mixture/immutable/planet
	initial_temperature = 259.15
	volume = CELL_VOLUME

/datum/gas_mixture/immutable/planet/garbage_collect()
	if(!SSterraforming)
		return
	if(!SSterraforming.atmos)
		return
	initial_temperature = SSterraforming.atmos.getTemp()
	..()

	add_gases(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/nitrous_oxide, /datum/gas/plasma)
	gases[/datum/gas/oxygen][MOLES] = SSterraforming.atmos.getSpecificAtmos("o2")
	gases[/datum/gas/nitrogen][MOLES] = SSterraforming.atmos.getSpecificAtmos("n2")
	gases[/datum/gas/carbon_dioxide][MOLES] = SSterraforming.atmos.getSpecificAtmos("co2")
	gases[/datum/gas/nitrous_oxide][MOLES] = SSterraforming.atmos.getSpecificAtmos("n2o")
	gases[/datum/gas/plasma][MOLES] = SSterraforming.atmos.getSpecificAtmos("plasma")

/datum/gas_mixture/immutable/planet/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)
	. = ..(src, 0)
	garbage_collect()