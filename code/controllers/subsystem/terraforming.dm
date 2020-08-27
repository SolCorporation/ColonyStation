GLOBAL_LIST_EMPTY(terraformable_turfs)

//Used for updating terraformable turfs
SUBSYSTEM_DEF(terraforming)
	name = "Terraforming"
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/datum/terraform_state/currentState = new /datum/terraform_state/base()
	var/datum/terraform_state/lastState
	var/datum/planet_atmosphere/atmos
	var/datum/gas_mixture/immutable/planet/mix
	var/possibleStates = list()

/datum/controller/subsystem/terraforming/Initialize(start_timeofday)
	for(var/S in subtypesof(/datum/terraform_state))
		possibleStates += new S()
	lastState = currentState
	if(!atmos)
		atmos = new /datum/planet_atmosphere()
		updateTiles()

	return ..()

/datum/controller/subsystem/terraforming/fire()
	for(var/datum/terraform_state/state in possibleStates)
		var/pass = TRUE
		for(var/gas in state.requiredAtmos)
			var/atmosGas = atmos.getSpecificAtmos(gas)
			if(atmosGas < state.requiredAtmos[gas])
				pass = FALSE
		if(pass && !state.reached)
			currentState = state
			state.reached = TRUE

	if(!lastState)
		updateTiles()
		return

	if(currentState.id != lastState.id)
		updateTiles()
		return

/datum/controller/subsystem/terraforming/proc/updateTiles()
	mix = new /datum/gas_mixture/immutable/planet
	for(var/turf/open/T in GLOB.terraformable_turfs)
		currentState.updateState(T)
		T.air = mix

	lastState = currentState
	return


/datum/controller/subsystem/terraforming/proc/setState(state)
	currentState = new state()

/datum/controller/subsystem/terraforming/proc/setStateAdmin()
	var/state = input("Select Terraforming State.", "Terraforming Admin", "Cancel") as null|anything in subtypesof(/datum/terraform_state)
	currentState = new state()

/datum/controller/subsystem/terraforming/proc/updateAtmosphere(list/addedAtmos, absoluteValue = FALSE)
	atmos.changeComposition(addedAtmos, TRUE, absoluteValue)
