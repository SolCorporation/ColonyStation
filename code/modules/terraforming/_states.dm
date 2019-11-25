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

//First Plants/shrubs
/datum/terraform_state/first_plants
	id = "first_plants"
	icon_state = "asteroid"
	probability = 7
	requiredAtmos = list("o2" = 14, "co2" = 1, "TEMP" = 274.15)

/datum/terraform_state/first_plants/updateState(turf/T)
	if(prob(probability))
		var/pickedPlant = pick(possibleSpawns)
		new pickedPlant(T)

//More shrubs
/datum/terraform_state/more_plants
	id = "more_plants"
	icon_state = "asteroid"
	probability = 8
	requiredAtmos = list("o2" = 15, "co2" = 2, "TEMP" = 275.15)

/datum/terraform_state/more_plants/updateState(turf/T)
	if(prob(probability))
		var/pickedPlant = pick(possibleSpawns)
		new pickedPlant(T)


//First grass
/datum/terraform_state/first_green
	id = "first_green"
	icon_state = "grass"
	probability = 10
	possibleSpawns = list(/obj/structure/flora/grass/brown)
	requiredAtmos = list("o2" = 17, "co2" = 3, "TEMP" = 278.15)

/datum/terraform_state/first_green/updateState(turf/T)
	if(prob(probability))
		T.icon_state = icon_state
		if(prob(30))
			var/pickedPlant = pick(possibleSpawns)
			new pickedPlant(T)

//More Grass
/datum/terraform_state/more_grass
	id = "more_grass"
	icon_state = "grass"
	probability = 20

	possibleSpawns = list(/obj/structure/flora/grass/both, /obj/structure/flora/grass/brown, /obj/structure/flora/grass/green, /obj/structure/flora/ausbushes/fullgrass)
	requiredAtmos = list("o2" = 18.5, "co2" = 3, "TEMP" = 284.15)

/datum/terraform_state/more_grass/updateState(turf/T)
	if(prob(probability))
		T.icon_state = icon_state
		var/pickedPlant = pick(possibleSpawns)
		new pickedPlant(T)



//Trees
/datum/terraform_state/trees
	id = "trees"
	icon_state = "grass"
	probability = 20
	possibleSpawns = list(/obj/structure/flora/tree/jungle, /obj/structure/flora/tree/jungle/small, /obj/structure/flora/grass/both)
	requiredAtmos = list("o2" = 19.5, "co2" = 4, "TEMP" = 288.15)

/datum/terraform_state/trees/updateState(turf/T)
	if(prob(probability))
		var/pickedPlant = pick(possibleSpawns)
		new pickedPlant(T)



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