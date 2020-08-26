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


/datum/gas_mixture/immutable/planet
	initial_temperature = 259.15
	initial_volume  = CELL_VOLUME

/datum/gas_mixture/immutable/planet/New()
	initial_temperature = SSterraforming.atmos.getTemp()
	..()

/datum/gas_mixture/immutable/planet/populate()
	if(!SSterraforming)
		return
	if(!SSterraforming.atmos)
		return

	set_moles(/datum/gas/oxygen, SSterraforming.atmos.getSpecificAtmos("o2"))
	set_moles(/datum/gas/oxygen, SSterraforming.atmos.getSpecificAtmos("n2"))
	set_moles(/datum/gas/oxygen, SSterraforming.atmos.getSpecificAtmos("co2"))
	set_moles(/datum/gas/oxygen, SSterraforming.atmos.getSpecificAtmos("n2o"))
	set_moles(/datum/gas/oxygen, SSterraforming.atmos.getSpecificAtmos("plasma"))