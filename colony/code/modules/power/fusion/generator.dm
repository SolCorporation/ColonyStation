#define GENERATOR_OFF 0
#define GENERATOR_STARTING 1
#define GENERATOR_STARTED 2
#define GENERATOR_STOPPING 3

/obj/machinery/power/fusion_gen
	name = "thermo generator"
	desc = "This little uses the heat from a fusion reactor, to create power!"
	icon = 'goon/icons/obj/fusion_machines.dmi'
	icon_state = "engineoff"

	density = TRUE

	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 5000

	var/maxOutput = 400000
	var/outputBonus = 1
	var/heatGenerationCutoff = 0.5
	var/lastOutput = 0

	var/status = GENERATOR_OFF

	var/warmUp = 0
	var/warmUpMax = 100
	var/warmUpAmount = 0.75

	var/condition = 100
	var/degradation = 0.1

	var/list/upgrades = list()

	var/obj/machinery/power/fusion/core/reactor

/obj/machinery/power/fusion_gen/Initialize()
	name += " ([num2hex(rand(1,65535), -1)])"
	for(var/obj/machinery/power/fusion/core/R in orange(15, src))
		reactor = R
	START_PROCESSING(SSobj, src)
	connect_to_network()
	..()

/obj/machinery/power/fusion_gen/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/machinery/power/fusion_gen/update_icon()
	switch(status)
		if(GENERATOR_OFF)
			icon_state = "engineoff"

		if(GENERATOR_STARTING || GENERATOR_STOPPING)
			icon_state = "enginenopow"

		if(GENERATOR_STARTED)
			icon_state = "enginepoweredworking"

/obj/machinery/power/fusion_gen/proc/toggleOn()
	if(status == GENERATOR_OFF)
		status = GENERATOR_STARTING
	else
		status = GENERATOR_STOPPING
	update_icon()


/obj/machinery/power/fusion_gen/process()
	if(status == GENERATOR_OFF)
		return

	checkCondition()

	if(status == GENERATOR_STOPPING)
		if(warmUp <= 0)
			status = GENERATOR_OFF
			update_icon()
		warmUp -= warmUpAmount
		if(warmUp < 0)
			warmUp = 0

	if(status == GENERATOR_STARTING)
		if(warmUp >= heatGenerationCutoff * warmUpMax)
			status = GENERATOR_STARTED
			update_icon()
		warmUp += warmUpAmount
		condition -= degradation

	if(status == GENERATOR_STARTED)
		warmUp += warmUpAmount
		condition -= degradation
		if(warmUp > warmUpMax)
			warmUp = warmUpMax

		add_avail(calculatePowerOutput())


/obj/machinery/power/fusion_gen/proc/calculatePowerOutput()
	reactor.load -= lastOutput
	if(status != GENERATOR_STARTED)
		return

	if(!reactor.sendingHeat)
		lastOutput = 0
		return

	//How much heat do we have after being activated. Max heat is 100, 50 is used for starting up, calculate the last 50
	var/heatAfterActivation = warmUpMax * heatGenerationCutoff

	//How much heat do we have of the surplus, after starting. Max is 100, 50 is used for starting up, this gets the heat-50,
	var/max = (warmUp - heatAfterActivation) / heatAfterActivation
	//Warmer = more power, 0,25 at 25 extra heat(50%), 0,5625 at 37.5heat(75%)
	var/multiplier = max ** 2

	var/possibleOutput = (maxOutput * outputBonus) * multiplier

	if((reactor.possibleLoad - reactor.load) > possibleOutput)
		lastOutput = possibleOutput
		reactor.load += possibleOutput
		return clamp(possibleOutput, 0, maxOutput)
	else if((reactor.possibleLoad - reactor.load) > 0)
		var/correctedOutput = clamp(possibleOutput, 0, (reactor.possibleLoad - reactor.load))
		lastOutput = correctedOutput
		reactor.load += correctedOutput
		return correctedOutput

	lastOutput = 0
	return 0

/obj/machinery/power/fusion_gen/proc/checkCondition()
	if(condition < 0)
		condition = 0
		status = GENERATOR_OFF
		warmUp = 0
		update_icon()

/obj/machinery/power/fusion_gen/proc/returnStatus()
	switch(status)
		if(GENERATOR_OFF)
			return "OFF"

		if(GENERATOR_STARTING)
			return "SPINNING UP"

		if(GENERATOR_STOPPING)
			return "STOPPING"

		if(GENERATOR_STARTED)
			return "GENERATING POWER"

/obj/machinery/power/fusion_gen/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/generator_upgrade))
		var/obj/item/generator_upgrade/upgrade = W
		upgrades += upgrade
		upgrade.forceMove(src)
		upgrade.upgrade.OnApply(src)

/obj/machinery/power/fusion_gen/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(upgrades.len)
		I.play_tool_sound(src, 100)
		for(var/obj/item/generator_upgrade/upgrades in upgrades)
			upgrades.forceMove(get_turf(src))
			upgrades.upgrade.OnRemove(src)
		upgrades = list()
	else
		to_chat(user, "<span class='notice'>There are no upgrades currently installed.</span>")

/obj/machinery/power/fusion_gen/welder_act(mob/living/user, obj/item/I)
	if(!I.tool_start_check(user, amount=0))
		return TRUE

	playsound(src, 'sound/items/welder2.ogg', 100, 1)
	to_chat(user, "<span class='notice'>You start repairing \the [src]...</span>")
	if(I.use_tool(src, user, 50))
		to_chat(user, "<span class='notice'>You repair \the [src].</span>")
		condition = initial(condition)
	return TRUE