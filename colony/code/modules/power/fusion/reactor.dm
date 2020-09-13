#define STOPPED "stopped"
#define STARTING "bootup"
#define STARTED "booted_up"
#define STOPPING "stopping"

//At 50% reduces starting temp by 2.500K (To 4.500K) & increases fuel consumption by 37.5%
//Outputs 1.5Mw at 50%, with 0% bonus. 3.5625Mw with 50% deuterium
#define TRITIUM_TEMP_REDUCTION 50
#define TRITIUM_FUEL_USAGE 1.25
#define TRITIUM_BASE_OUTPUT 30000
#define TRITIUM_TEMP_OUTPUT 1.1

//CURRENT MAX RAW POWER OUTPUT (Generator Bonus applies):
// 4.280175Mw
//1.7625 fuel use at max power.
//Adds about 37.85K per cycle.
//Adds about 11.01K per cycle when outputting

//Around 3.93Mw at heat negative design
//1.5 fuel use at heat negative.
//Removes 1K per cycle
//Removes 18.6K when outputting to generators

//Default Mix
//1.25 fuel use
//2.92Mw output.
//-38K per cycle
//-46.8K per cycle when outputting
//Requires a temperature of 6000K

//At 50%, adds 10.000K & 25% output boost
//Outputs 487,5Kw at 50%
#define DEUTERIUM_TEMP_OUTPUT -0.75
#define DEUTERIUM_OUTPUT_BOOST 2.75
#define DEUTERIUM_BASE_OUTPUT 12500

//1 cryo coolant reduces temps by this
#define CRYO_COOLANT_REDUCTION 500

//Added heat times this number when outputting to generators
#define HEAT_REDUCTION_ON_OUTPUT 0.6

#define NO_WARNING 0
#define WARNING_1 1
#define WARNING_2 2
#define WARNING_3 3

/obj/machinery/power/fusion
	density = TRUE
	opacity = TRUE

/obj/machinery/power/fusion/core
	name = "fusion reaction core"
	desc = "This little thing controls the whole reactor, without it there is no power."
	icon = 'goon/icons/obj/fusion_machines.dmi'
	icon_state = "core"

	var/list/parts = list()

	var/status = STOPPED

	use_power = NO_POWER_USE

	//FUEL INPUTS
	var/deuterium = 0
	var/tritium = 0

	var/cryo = 100


	//TEMPERATURES
	var/maxTemp = 15000
	var/minTemp = 293.15
	var/currentTemp = 293.15
	//If currentTemp > meltdownThreshold * maxTemp, we meltdown
	var/meltdownThreshold = 2
	//How many K do we lose a tick when no reaction is taking place?
	var/passiveHeatDecay = 125

	//REACTION VARIABLES
	var/minimumReactionTemp = 7000
	var/fuelUse = 1.2

	//PREHEATING
	var/maxPreheat = 7500
	var/preheatingSpeed = 300
	var/preHeating = FALSE

	//STATUSSES
	var/injectingFuel = FALSE
	var/sendingHeat = FALSE
	var/reacting = FALSE
	var/overheating = FALSE
	var/meltedDown = FALSE

	//For generators
	var/load = 0
	var/possibleLoad = 0

	var/warnedStatus = NO_WARNING

	//RADIO
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/engineering_channel = "Engineering"
	var/common_channel = null

	var/obj/machinery/computer/reactor_control/controller

/obj/machinery/power/fusion/core/proc/InjectCryo()
	if(cryo > 0)
		cryo--
		currentTemp -= CRYO_COOLANT_REDUCTION

/obj/machinery/power/fusion/core/proc/togglePreheating()
	preHeating = !preHeating

/obj/machinery/power/fusion/core/Initialize()
	. = ..()
	setup_parts()
	add_overlay(STOPPED)

	GLOB.poi_list |= src

	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.use_command = TRUE
	radio.recalculateChannels()

	START_PROCESSING(SSobj, src)

/obj/machinery/power/fusion/core/process()
	..()
	//If we are not running, process the passive heat decay.
	if(!reacting && !preHeating)
		currentTemp -= passiveHeatDecay
	if(preHeating)
		currentTemp += preheatingSpeed
		if(currentTemp >= maxPreheat)
			if(currentTemp <= maxPreheat * 1.25)
				currentTemp = maxPreheat

	//If we are below min temp, reset the temperature
	if(currentTemp < minTemp)
		currentTemp = minTemp

	//Process passive meltdowns.
	if(meltedDown)
		if(!deuterium)
			return
		if(!tritium)
			return
		//Slowly reduce fuel amounts, so we don't react FOREVER
		deuterium -= 0.75
		tritium -= 0.75

		if(deuterium < 0)
			deuterium = 0
			return

		if(tritium < 0)
			tritium = 0
			return

		passiveMeltdown()
		return

	//If there is no mix in the controller, abort the process
	if(!controller)
		return
	if(!controller.mix)
		return


	//If we are above the maximum temperature, warn the controller console
	if(currentTemp >= maxTemp)
		overheating = TRUE
	else
		overheating = FALSE

	//Warning messages
	if(warnedStatus < WARNING_1 && currentTemp > (meltdownThreshold * maxTemp) * 0.75 && !meltedDown)
		radio.talk_into(src, "The core is 50% towards melting down. Consider examining the core for misconfiguration.", engineering_channel)
		warnedStatus = WARNING_1
	else if(warnedStatus < WARNING_2 && currentTemp > (meltdownThreshold * maxTemp) * 0.875 && !meltedDown)
		radio.talk_into(src, "The core is 75% towards melting down. Immediate countermeasures required.", engineering_channel)
		warnedStatus = WARNING_2
	else if(warnedStatus < WARNING_3 && currentTemp > (meltdownThreshold * maxTemp) * 0.975 && !meltedDown)
		radio.talk_into(src, "The core is 95% towards melting down. ENGINEERING EVACUATION RECOMMENDED.", common_channel)
		warnedStatus = WARNING_3
	else if(warnedStatus == WARNING_3 && currentTemp < (meltdownThreshold * maxTemp) * 0.70 && !meltedDown)
		radio.talk_into(src, "Core stabilized.", engineering_channel)
		warnedStatus = NO_WARNING

	//Check if we are at the meltdown threshold
	if(currentTemp > meltdownThreshold * maxTemp)
		onMeltdown()
		return

	//Calculate total fuel usage
	var/ourFuel = fuelUse * (1 + ((controller.mix.tritiumMix * TRITIUM_FUEL_USAGE) / 100))

	//Calculate fuel use of deuterium & tritium, using total fuel usage
	var/detUse = ourFuel * (controller.mix.deuteriumMix / 100)
	var/tritUse = ourFuel * (controller.mix.tritiumMix / 100)

	//Subtract fuel if we are reacting.
	if(reacting)
		deuterium -= detUse
		tritium -= tritUse

	//Calculates positive temperature from tritium
	var/addTemp = (controller.mix.tritiumMix * TRITIUM_TEMP_OUTPUT) * HEAT_REDUCTION_ON_OUTPUT
	//Calculates the heat reduction from deuterium
	var/reduceTemp = controller.mix.deuteriumMix * DEUTERIUM_TEMP_OUTPUT

	//Add the positive heat gain to the negative heat gain.
	var/totalTempAdd = addTemp - reduceTemp
	//If we are reacting, add the temperature difference to the core.
	if(reacting)
		currentTemp += totalTempAdd
		possibleLoad = getMaxOutput(TRUE)
	else
		possibleLoad = 0

	//Check if both fuels are over 0%, and that we are still above the minimum reacting temperature
	if(reacting)
		tryReaction()

	/*
	var/minimumReact = (controller.mix.tritiumMix * TRITIUM_TEMP_REDUCTION) + minimumReactionTemp
	if(minimumReact < currentTemp)
		reacting = FALSE
	*/



	updateStatus()

//What happens when the core meltdowns
/obj/machinery/power/fusion/core/proc/onMeltdown()
	meltedDown = TRUE
	radio.talk_into(src, "Large scale reaction deteced in fusion containment core. Likely Cause: MELTDOWN", common_channel)
	for(var/mob/living/L in range(20, src))
		if(L in view(10, src))
			L.show_message("<span class='danger'>A bright flash of light eminates from \the [src]! You feel a burning sensation all over your body, it shortly passes, it has burned your outer nerve endings to a crisp.</span>", 2)
			L.apply_damage(25, BURN)
			L.adjust_fire_stacks(4)
			L.IgniteMob()
			L.flash_act(3)
		else
			L.show_message("<span class='italics'>You suddenly find yourself covered in fire. What the hell happened?</span>", 2)
			L.apply_damage(25, BURN)
			L.adjust_fire_stacks(2)
			L.IgniteMob()

//Runs on process when the core has melted down
/obj/machinery/power/fusion/core/proc/passiveMeltdown()
	for(var/mob/living/L in range(20, src))
		if(L in view(10, src))
			if(prob(10))
				L.show_message("<span class='danger'>You feel small burns all over your body.</span>", 2)
			L.apply_damage(0.33, BURN)
			if(prob(10))
				L.adjust_fire_stacks(1)
				L.IgniteMob()



/obj/machinery/power/fusion/core/proc/getStatus()
	switch(status)
		if(STOPPED)
			return "STOPPED"
		if(STARTING)
			return "INJECTING FUEL"
		if(STARTED)
			return "FUSING ELEMENTS"
		if(STOPPING)
			return "SHUTTING DOWN"

/obj/machinery/power/fusion/core/proc/updateStatus()
	if(reacting && injectingFuel)
		status = STARTED
	if(!reacting && injectingFuel)
		status = STARTING
	if(!reacting && !injectingFuel)
		status = STOPPED
	if(reacting && !injectingFuel)
		status = STOPPING

	setOverlay()

/obj/machinery/power/fusion/core/proc/setOverlay()
	cut_overlays()
	add_overlay(status)

/obj/machinery/power/fusion/core/proc/toggleInject()
	injectingFuel = !injectingFuel
	updateStatus()

/obj/machinery/power/fusion/core/proc/getMaxOutput(forced = FALSE)
	if(!controller || !controller.mix)
		return FALSE
	if(status != STARTED && !forced)
		return FALSE
	var/bonus = controller.mix.deuteriumMix * DEUTERIUM_OUTPUT_BOOST
	bonus = bonus / 100

	var/Trit = (controller.mix.tritiumMix * TRITIUM_BASE_OUTPUT) * bonus
	var/det = (controller.mix.deuteriumMix * DEUTERIUM_BASE_OUTPUT) * bonus

	return (Trit + det)

/obj/machinery/power/fusion/core/proc/tryReaction()
	var/minimumTemp =  minimumReactionTemp - (controller.mix.tritiumMix * TRITIUM_TEMP_REDUCTION)

	if(deuterium <= 0)
		radio.use_command = FALSE
		radio.talk_into(src, "Reaction aborted. Not enough deuterium!", engineering_channel)
		radio.use_command = TRUE
		reacting = FALSE
		updateStatus()
		return

	if(tritium <= 0)
		radio.use_command = FALSE
		radio.talk_into(src, "Reaction aborted. Not enough tritium!", engineering_channel)
		radio.use_command = TRUE
		reacting = FALSE
		updateStatus()
		return

	if(currentTemp >= minimumTemp)
		reacting = TRUE
	else
		radio.use_command = FALSE
		radio.talk_into(src, "Reaction aborted. Core is too cold!", engineering_channel)
		radio.use_command = TRUE
		reacting = FALSE
	updateStatus()

/obj/machinery/power/fusion/core/proc/toggleCollect()
	sendingHeat = !sendingHeat

/obj/machinery/power/fusion/core/proc/flush()
	sendingHeat = FALSE
	injectingFuel = FALSE

/obj/machinery/power/fusion/core/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs = block(locate(our_turf.x - 1, our_turf.y + 2, our_turf.z), locate(our_turf.x + 1, our_turf.y, our_turf.z))
	var/count = 10
	for(var/turf/T in spawn_turfs)
		count--
		if(T == our_turf) // Skip our turf.
			continue
		var/obj/machinery/power/fusion/part/part = new(T)
		part.sprite_number = count
		part.main = src
		parts += part
		part.update_icon()

/obj/machinery/power/fusion/core/Destroy() // If we somehow get deleted, remove all of our other parts.
	for(var/obj/machinery/power/fusion/part/O in parts)
		O.main = null
		if(!QDESTROYING(O))
			qdel(O)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(radio)
	return ..()

/obj/machinery/power/fusion/core/welder_act(mob/living/user, obj/item/I)
	if(!meltedDown)
		return

	if(!I.tool_start_check(user, amount=0))
		return TRUE

	playsound(src, 'sound/items/welder2.ogg', 100, 1)
	to_chat(user, "<span class='notice'>You start repairing the containment chamber in \the [src]...</span>")
	if(I.use_tool(src, user, 50))
		to_chat(user, "<span class='notice'>You repair the containtment chamber in \the [src].</span>")
		meltedDown = FALSE
		currentTemp = maxTemp
		updateStatus()
	return TRUE

//PARTS

/obj/machinery/power/fusion/part
	name = "reactor casing"
	desc = "Without this, the reactor cannot produce it's patented super hot plasma mix"
	icon = 'goon/icons/obj/fusion_machines.dmi'
	var/obj/machinery/power/fusion/core/main = null
	var/sprite_number

/obj/machinery/power/fusion/part/attackby(obj/item/I, mob/user, params)
	return main.attackby(I, user)

/obj/machinery/power/fusion/part/update_icon()
	..()
	icon_state = "[sprite_number]"

/obj/machinery/power/fusion/part/attack_hand(mob/user)
	return main.attack_hand(user)

/obj/machinery/power/fusion/part/Destroy()
	if(main)
		qdel(main)
	return ..()

#undef TRITIUM_TEMP_REDUCTION
#undef TRITIUM_FUEL_USAGE
#undef TRITIUM_BASE_OUTPUT
#undef TRITIUM_TEMP_OUTPUT
#undef DEUTERIUM_TEMP_OUTPUT
#undef DEUTERIUM_OUTPUT_BOOST
#undef DEUTERIUM_BASE_OUTPUT
#undef HEAT_REDUCTION_ON_OUTPUT