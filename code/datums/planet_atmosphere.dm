/datum/planet_atmosphere
	var/list/atmosphere = list(
	"o2" = 12,
	"n2" = 25,
	"co2" = 0.25,
	"n2o" = 0,
	"plasma" = 0,
	"TEMP" = 259.15
	)

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

/datum/planet_atmosphere/proc/changeComposition(list/newComp, updateTileAtmos, absolute = FALSE)
	for(var/gas in newComp)
		if(!absolute)
			atmosphere[gas] += newComp[gas]
		else
			atmosphere[gas] = newComp[gas]

	if(updateTileAtmos)
		SSterraforming.updateTilesAir()