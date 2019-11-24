#define ARTIFACT_EASY 2
#define ARTIFACT_MEDIUM 3
#define ARTIFACT_HARD 4
#define ARTIFACT_IMPOSSIBLE 5


/obj/item/artifact
	name = "\improper artifact"
	desc = "What mysteries could this hold?"
	icon = 'icons/obj/assemblies.dmi'

	var/list/requirements = list()

	var/list/possibleRequirements = list()

	var/difficulty = ARTIFACT_EASY

	var/outcome = /obj/item

	var/list/possibleIcons = list("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1",
	"radio-radio","timer-multitool0","radio-igniter-tank","infra-igniter-tank0","infra-igniter-tank1","infrared-radio0","infrared-radio1",
	"prox-igniter0","prox-igniter1","prox-igniter2","prox-multitool0","prox-multitool1","prox-multitool2","prox-radio0","prox-radio1",
	"prox-radio2","prox-igniter-tank0","prox-igniter-tank1","prox-igniter-tank2","radio-igniter","timer-igniter0","timer-igniter1",
	"timer-igniter2","timer-igniter-tank0","timer-igniter-tank1","timer-igniter-tank2","timer-multitool1","timer-multitool2","timer-radio0","timer-radio1","timer-radio2")

/obj/item/artifact/easy

/obj/item/artifact/medium
	difficulty = ARTIFACT_MEDIUM

/obj/item/artifact/hard
	difficulty = ARTIFACT_HARD

/obj/item/artifact/impossible
	difficulty = ARTIFACT_IMPOSSIBLE



/obj/item/artifact/Initialize()
	. = ..()
	icon_state = pick(possibleIcons)
	for(var/R in subtypesof(/datum/artifact_requirement))
		possibleRequirements += new R()

	pickRequirement(difficulty)

/obj/item/artifact/proc/pickRequirement(difficulty)
	if(!possibleRequirements)
		return
	for(var/i = 0, i < difficulty, i++)
		var/datum/artifact_requirement/req = pick(possibleRequirements)
		requirements += new req.type

/obj/item/artifact/proc/onAttempt(attempt, specific, obj/M)
	checkCompletion(M)
	for(var/datum/artifact_requirement/R in requirements)
		if(R.fulfilled)
			continue

		if(R.process == attempt)
			if(R.specifics)
				if(R.specifics == specific)
					R.fulfilled = TRUE
					if(M)
						M.visible_message("<span class='warning'>\The [src] [pick(R.possible_solve_texts)].</span>")
					checkCompletion(M)
					return
			else
				if(M)
					M.visible_message("<span class='warning'>\The [src] [pick(R.possible_solve_texts)].</span>")
				R.fulfilled = TRUE
				checkCompletion(M)
				return

		Reset(M)
		return

/obj/item/artifact/proc/checkCompletion(obj/machinery/exploration/machines/M)
	var/completed = 0
	for(var/datum/artifact_requirement/R in requirements)
		if(R.fulfilled)
			completed++

	if(completed >= requirements.len)
		var/item = new outcome(get_turf(src))
		if(M)
			M.visible_message("<span class='warning'>\The [src] cracks and reveals \the [item].</span>")
			M.success()
		qdel(src)

/obj/item/artifact/proc/getNextStep(obj/M)
	for(var/datum/artifact_requirement/R in requirements)
		if(R.fulfilled)
			continue
		return R.solve_tip


/obj/item/artifact/proc/Reset(obj/M)
	if(M)
		M.visible_message("<span class='warning'>\The [src] makes an audible hiss.")
	for(var/datum/artifact_requirement/R in requirements)
		R.fulfilled = FALSE


/datum/artifact_requirement
	var/name = "TEST"
	var/solve_tip

	var/possible_solve_texts = list("pings", "pongs", "bongs", "rings", "dings", "vibrates", "shakes")

	var/process

	var/specifics

	var/fulfilled = FALSE

/datum/artifact_requirement/electrify_5v
	name = "Low Conductance"
	solve_tip = "5 volt electrification."
	process = "electrify"
	specifics = "5v"

/datum/artifact_requirement/electrify_120v
	name = "High Conductance"
	solve_tip = "120 volt electrification."
	process = "electrify"
	specifics = "120v"

/datum/artifact_requirement/crush_low
	name = "Rigid Material"
	solve_tip = "Low pressure crushing."
	process = "crush"
	specifics = "low"

/datum/artifact_requirement/crush_high
	name = "Solid Material"
	solve_tip = "High pressure crushing."
	process = "crush"
	specifics = "high"

/datum/artifact_requirement/submerge_hcl
	name = "Metallic Shell"
	solve_tip = "Low-intensity acid bath."
	process = "acid"
	specifics = "hcl"

/datum/artifact_requirement/submerge_fluoro
	name = "Quantum Material Properties"
	solve_tip = "High-intensity acid bath."
	process = "acid"
	specifics = "carb"