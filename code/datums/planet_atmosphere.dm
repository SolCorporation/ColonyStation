/datum/planet_atmosphere
	var/list/atmosphere = list(
	"o2" = 12,
	"n2" = 25,
	"co2" = 0,
	"n2o" = 0,
	"plasma" = 0,
	"TEMP" = 259.15
	)

	var/baseTemp = 259.15

	var/list/warming_gasses = list(
	"co2" = 7,
	"plasma" = 20)


/datum/planet_atmosphere/proc/getAtmosString()
	var/string
	var/valid = FALSE
	for(var/gas in atmosphere)
		if(atmosphere[gas] != 0)
			string += "[gas]=[atmosphere[gas]];"
			valid = TRUE
			continue
		if(gas == "TEMP")
			string += "TEMP=[atmosphere[gas]]"

	if(valid)
		return string
	else
		return FALSE



/datum/planet_atmosphere/proc/setTemp(temp)
	for(var/gas in atmosphere)
		if(gas == "TEMP")
			atmosphere[gas] = temp

/datum/planet_atmosphere/proc/recalculateTemp()
	var/ourTemp = baseTemp
	for(var/warmGas in warming_gasses)
		for(var/gas in atmosphere)
			if(gas == warmGas)
				ourTemp += atmosphere[gas] * warming_gasses[warmGas]

	setTemp(ourTemp)


/datum/planet_atmosphere/proc/getAtmos()
	if(!atmosphere)
		return FALSE
	return atmosphere

/datum/planet_atmosphere/proc/getSpecificAtmos(atmos)
	for(var/gas in atmosphere)
		if(gas == atmos)
			return atmosphere[gas]
	return FALSE

/datum/planet_atmosphere/proc/getTotalMoles()
	var/totalMoles
	for(var/gas in atmosphere)
		if(gas != "TEMP")
			totalMoles += atmosphere[gas]

	return totalMoles

/datum/planet_atmosphere/proc/getTemp()
	for(var/gas in atmosphere)
		if(gas == "TEMP")
			return atmosphere[gas]

/datum/planet_atmosphere/proc/getPressure(volume = 2500)
	var/totalPressure
	var/temp = getTemp()
	for(var/gas in atmosphere)
		if(gas != "TEMP")
			totalPressure += atmosphere[gas]

	totalPressure = totalPressure * R_IDEAL_GAS_EQUATION * temp / volume

	return totalPressure

/datum/planet_atmosphere/proc/changeComposition(list/newComp, updateTileAtmos, absolute = FALSE)
	for(var/gas in newComp)
		if(!absolute)
			atmosphere[gas] += newComp[gas]
		else
			atmosphere[gas] = newComp[gas]

	recalculateTemp()
	if(updateTileAtmos)
		SSterraforming.updateTilesAir()