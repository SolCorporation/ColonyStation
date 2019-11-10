/datum/terraform_state
	var/id
	var/icon_state
	var/probability = 100
	var/possibleSpawns = list(/obj/structure/flora/bush, /obj/structure/flora/ausbushes/genericbush, /obj/structure/flora/ausbushes/reedbush,
	/obj/structure/flora/ausbushes/fullgrass)
	var/requiredAtmos = list()
	var/reached = FALSE

/datum/terraform_state/proc/updateState(turf/T)
	return

/datum/terraform_state/base
	id = "base"
	icon_state = "asteroid"

/datum/terraform_state/base/updateState(turf/T)
	T.icon_state = icon_state

//First Plants
/datum/terraform_state/first_plants
	id = "first_plants"
	icon_state = "asteroid"
	probability = 7
	requiredAtmos = list("o2" = 15, "co2" = 2, "TEMP" = 274.15)

/datum/terraform_state/first_plants/updateState(turf/T)
	if(prob(probability))
		var/pickedPlant = pick(possibleSpawns)
		new pickedPlant(T)


//First grass
/datum/terraform_state/first_green
	id = "first_green"
	icon_state = "grass"
	probability = 20
	requiredAtmos = list("o2" = 18, "co2" = 3, "TEMP" = 278.15)

/datum/terraform_state/first_green/updateState(turf/T)
	if(prob(probability))
		T.icon_state = icon_state


//Everything is lovely!
/datum/terraform_state/fully_terraformed
	id = "fully_done"
	icon_state = "grass"
	probability = 14
	requiredAtmos = list("o2" = 21, "co2" = 5, "TEMP" = 293.15)

/datum/terraform_state/fully_terraformed/updateState(turf/T)
	T.icon_state = icon_state
	if(prob(probability))
		var/pickedPlant = pick(possibleSpawns)
		new pickedPlant(T)