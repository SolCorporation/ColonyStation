GLOBAL_LIST_EMPTY(terraformable_turfs)

//Used for updating terraformable turfs
SUBSYSTEM_DEF(terraforming)
	name = "Terraforming"
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME
	var/datum/terraform_state/currentState = new /datum/terraform_state/base()
	var/datum/terraform_state/lastState

/datum/controller/subsystem/terraforming/Initialize(start_timeofday)
	lastState = currentState
	return ..()

/datum/controller/subsystem/terraforming/fire()
	if(currentState.id != lastState.id)
		updateTiles()
		return

/datum/controller/subsystem/terraforming/proc/updateTiles()
	for(var/turf/T in GLOB.terraformable_turfs)
		currentState.updateState(T)

	SSair.active_turfs += GLOB.terraformable_turfs
	lastState = currentState
	return

/datum/controller/subsystem/terraforming/proc/setState(state)
	currentState = new state()

/datum/controller/subsystem/terraforming/proc/setStateAdmin()
	var/state = input("Select Terraforming State.", "Terraforming Admin", "Cancel") as null|anything in subtypesof(/datum/terraform_state)
	currentState = new state()