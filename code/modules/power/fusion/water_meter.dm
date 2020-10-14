/obj/machinery/water_meter
	name = "water flow meter"
	desc = "It measures the pressure of water moving through a pipe."
	icon = 'icons/obj/atmospherics/pipes/meter.dmi'
	icon_state = "meterX"
	layer = 1
	power_channel = ENVIRON
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	max_integrity = 150
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 40, "acid" = 0)

	var/atom/target

/obj/machinery/water_meter/Destroy()
	target = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/water_meter/Initialize(mapload)
	if(!target)
		reattach_to_layer()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/water_meter/proc/reattach_to_layer()
	var/obj/structure/water_pipe/candidate
	for(var/obj/structure/water_pipe/pipe in loc)
		candidate = pipe

	if(candidate)
		target = candidate

/obj/machinery/water_meter/process()
	if(!target)
		icon_state = "meterX"
		return FALSE

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return FALSE

	use_power(5)

	var/datum/waternet/WN = target.waternet
	if(!WN)
		icon_state = "meterX"
		return FALSE

	var/amount = WN.amount
	if(amount <= 0.25*STARTING_WATER_AMOUNT)
		icon_state = "meter0"
	else if(amount <= 0.5*STARTING_WATER_AMOUNT)
		var/val = round(amount/(STARTING_WATER_AMOUNT*0.41) + 0.5)
		icon_state = "meter1_[val]"
	else if(amount <= 2*STARTING_WATER_AMOUNT)
		var/val = round(amount/(STARTING_WATER_AMOUNT*6.5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(amount <= 4*STARTING_WATER_AMOUNT)
		var/val = round(amount/(STARTING_WATER_AMOUNT*6) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

/obj/machinery/water_meter/proc/status()
	if (target)
		var/datum/waternet/WN = target.waternet
		if(WN)
			. = "The gauge reads [round(WN.amount)] L; [round(WN.temp)] K ([round(WN.temp-T0C)]&deg;C)."
		else
			. = "The sensor error light is blinking."
	else
		. = "The connect error light is blinking."

/obj/machinery/water_meter/examine(mob/user)
	. = ..()
	. += status()

/obj/machinery/water_meter/wrench_act(mob/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (I.use_tool(src, user, 40, volume=50))
		user.visible_message(
			"[user] unfastens \the [src].",
			"<span class='notice'>You unfasten \the [src].</span>",
			"<span class='italics'>You hear ratchet.</span>")
		deconstruct()
	return TRUE

/obj/machinery/water_meter/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/pipe_meter_water(loc)
	qdel(src)

/obj/machinery/water_meter/interact(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	else
		to_chat(user, status())

/obj/machinery/water_meter/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/item/pipe_meter_water
	name = "water meter"
	desc = "A meter that can be laid on water pipes."
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/pipe_meter_water/wrench_act(mob/living/user, obj/item/wrench/W)

	var/obj/structure/water_pipe/pipe
	for(var/obj/structure/water_pipe/P in loc)
		pipe = P

	if(!pipe)
		to_chat(user, "<span class='warning'>You need to fasten it to a water pipe!</span>")
		return TRUE
	new /obj/machinery/water_meter(loc)
	W.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You fasten the water meter to the water pipe.</span>")
	qdel(src)
