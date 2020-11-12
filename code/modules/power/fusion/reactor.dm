///How much heat the water gets from 1 internal heat
#define HEAT_COEFFICIENT 0.75
///How much heat the coolant water can take
#define MAX_COOLANT_TEMP 10000
///How long between warnings
#define WARNING_COOLDOWN 60
///Normal heat generation, both internal + generator is multiplied by this.
#define HEAT_MULTIPLIER 10


//FOLLOWING VALUES ARE BASED ON THE ICON STATE
#define REACTOR_RIGHT 4
#define REACTOR_LEFT 6
#define REACTOR_TOP 2
#define REACTOR_BOTTOM 8


/obj/machinery/power/water/fusion
	density = TRUE
	opacity = TRUE
	max_integrity = 2500

/obj/machinery/power/water/fusion/core
	name = "fusion reaction core"
	desc = "The heart of the reactor. Powers the fusion reaction by using the energy of external laser beams."
	icon = 'goon/icons/obj/fusion_machines.dmi'
	icon_state = "core"


	use_power = NO_POWER_USE

	

	///Parts of the reactor
	var/list/parts = list()
	///Is the reactor flipped? Default is FALSE/Core at top middle
	var/flipped = FALSE

	///Core heat, needs to be cooled down.
	var/heat = 0
	///Max core heat before we start taking damage.
	var/max_heat = 25000

	///Internal heat, used for 
	var/internal_heat = 0
	///Max internal heat before it starts getting added to the core
	var/max_internal_heat = 2500
	

	///Have we been started?
	var/has_been_powered = FALSE


	///When were we lasted warned about too high temps?
	var/last_warning

	///How much health do we have until meltdown?
	var/containment_health = 100
	///Are we below 15% health?
	var/emergency_point_reached = FALSE
	///If we reach this point eject hot steam from nowhere, honk
	var/meltdown = FALSE

	///What fuel rods do we have inserted. Tick each of these once per laser hit
	var/list/fuel = list()
	///How much fuel do we try to use per rod per hit?
	var/fuel_use = 10

	///Internal radio
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/engineering_channel = "Engineering"
	var/common_channel = null

	///Reference to the controller
	var/obj/machinery/computer/reactor_control/controller

	//Reference to the part that gets water inlet for the generators
	var/obj/machinery/power/water/fusion/generator_inlet
	//Where is the part even
	var/generator_inlet_index = REACTOR_TOP

	//Reference to the part that gets water inlet for cooling
	var/obj/machinery/power/water/fusion/cooling_inlet
	//Where is the part even
	var/cooling_inlet_index = REACTOR_LEFT

	//Reference to the part that lets heated water out for the generators
	var/obj/machinery/power/water/fusion/generator_outlet
	//Where is the part even
	var/generator_outlet_index = REACTOR_RIGHT

	///Reference to tile so we can let water out for cooling
	var/obj/machinery/power/water/fusion/cooling_outlet
	//Where is the part even
	var/cooling_outlet_index = REACTOR_BOTTOM

/obj/machinery/power/water/fusion/core/bullet_act(obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))
		return FALSE
	if(Proj.flag != "bullet")
		process_fuel()
		if(!has_been_powered)

			investigate_log("has been powered for the first time.", INVESTIGATE_SUPERMATTER)
			message_admins("[src] has been powered for the first time [ADMIN_JMP(src)].")
			has_been_powered = TRUE

	return BULLET_ACT_HIT



/obj/machinery/power/water/fusion/core/Initialize()
	. = ..()
	setup_parts()

	GLOB.poi_list |= src

	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.use_command = TRUE
	radio.recalculateChannels()

	SSair.atmos_machinery += src

	update_icon()

	START_PROCESSING(SSobj, src)

/obj/machinery/power/water/fusion/core/process()
	..()

	if(heat > max_heat)
		containment_health -= 0.1
		update_icon()
		if((REALTIMEOFDAY - last_warning) / 10 >= WARNING_COOLDOWN)
			warn()
	else if(containment_health > 0.15 && containment_health < 100)
		containment_health += 0.1
		if(containment_health > 100)
			containment_health = 100
		emergency_point_reached = FALSE
	
	if(containment_health <= 0)
		meltdown()
		return PROCESS_KILL

	if(internal_heat > max_internal_heat)
		heat += internal_heat - max_internal_heat
		internal_heat = max_internal_heat


	//HEATING THE GENERATOR LOOP
	var/generator_water = get_water(generator_inlet) * 0.75
	if(generator_water && internal_heat > 0)
		var/amount_to_heat = internal_heat * HEAT_COEFFICIENT
		internal_heat -= amount_to_heat
		if(internal_heat < 0)
			internal_heat = 0
		//Move the water
		remove_water(generator_water, generator_inlet)

		var/outlet_water = get_water(generator_outlet)
		var/outlet_temp = get_temp(generator_outlet)
		
		add_water(generator_water, generator_outlet)
		//Spread it out amongst the total volume of water
		amount_to_heat = EQUALIZE_WATER_TEMP(outlet_water, outlet_temp, generator_water, amount_to_heat)
		set_temp(amount_to_heat, generator_outlet)
	
	//COOLING THE REACTOR/HEATING COOLING LOOP
	var/cooling_inlet_water = get_water(cooling_inlet) 
	var/cooling_inlet_water_temp = get_temp(cooling_inlet)

	if(cooling_inlet_water)
		var/max_cooling = (MAX_COOLANT_TEMP - cooling_inlet_water_temp) * cooling_inlet_water
		var/amount_to_heat = min(heat, max_cooling)
		heat -= amount_to_heat

		//Reset input water
		remove_water(cooling_inlet_water, cooling_inlet)

		//Handle output water

		var/outlet_water = get_water(cooling_outlet)
		var/outlet_temp = get_temp(cooling_outlet)

		add_water(cooling_inlet_water, cooling_outlet)
		amount_to_heat = EQUALIZE_WATER_TEMP(outlet_water, outlet_temp, cooling_inlet_water, amount_to_heat)
		set_temp(amount_to_heat, cooling_outlet)

/obj/machinery/power/water/fusion/core/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/fuel_rod))
		var/obj/item/fuel_rod/rod = I
		if(rod.fuel_amount <= 0)
			to_chat(user, "<span class='warning'>[I] is empty and can't be inserted!</span>")
			return ..()
		fuel += I
		I.forceMove(src)
		to_chat(user, "<span class='info'>You insert [I].</span>")
		update_icon()
		return

	return ..()

/obj/machinery/power/water/fusion/core/crowbar_act(mob/user, obj/item/tool)
	for(var/obj/item/fuel_rod/rod in fuel)
		rod.forceMove(get_turf(src))
		fuel -= rod
	

	to_chat(user, "<span class='warning'>You remove all the inserted fuel rods.</span>")
	tool.play_tool_sound(src)
	return TRUE

/obj/machinery/power/water/fusion/core/process_atmos()
	if(meltdown)
		release_steam()
	
/obj/machinery/power/water/fusion/core/proc/process_fuel()
	//So we can notify them if a rod depletes, without spamming them if multiple deplete at the same time
	var/empty_fuel_rod = FALSE
	for(var/obj/item/fuel_rod/rod in fuel)
		var/fuel_used = round(rod.use_fuel(fuel_use)) //Boo hoo you lost 0.5 fuel :(
		
		internal_heat += fuel_used * rod.fuel.power_multiplier * HEAT_MULTIPLIER
		heat += fuel_used * rod.fuel.heat_multiplier * HEAT_MULTIPLIER

		if(rod.fuel_amount <= 0)
			rod.forceMove(get_turf(src))
			fuel -= rod
			empty_fuel_rod = TRUE
			update_icon()

	if(empty_fuel_rod)
		radio.talk_into(src, "Fuel rod depleted. Ejecting fuel rod.", engineering_channel)


/obj/machinery/power/water/fusion/core/proc/release_steam()
	var/turf/T = loc
	if(isnull(T))
		return
	if(!istype(T))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/datum/gas_mixture/removed = new()

	removed.adjust_moles(/datum/gas/water_vapor, 100)
	
	removed.set_temperature(7500)

	env.merge(removed)
	air_update_turf()

/obj/machinery/power/water/fusion/core/proc/meltdown()
	if(meltdown)
		return
	investigate_log("has melted down.", INVESTIGATE_SUPERMATTER)
	message_admins("[src] has melted down [ADMIN_JMP(src)].")
	radio.talk_into(src, "DANGER. STEAM RELEASE IN PROGRESS. EVACUATE.", common_channel)
	meltdown = TRUE


/obj/machinery/power/water/fusion/core/proc/warn()
	last_warning = REALTIMEOFDAY
	if(containment_health < 0.15)
		if(!emergency_point_reached)
			investigate_log("has reached the emergency point for the first time.", INVESTIGATE_SUPERMATTER)
			message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
			emergency_point_reached = TRUE
		radio.talk_into(src, "STEAM RELEASE IMMINENT Integrity: [containment_health]%", common_channel)
	else
		radio.talk_into(src, "Warning. Integrity decreasing. Integrity: [containment_health]%", engineering_channel)
	

/obj/machinery/power/water/fusion/core/update_icon()
	cut_overlays()
	if(containment_health < 0.5)
		add_overlay("hot")
		return
	if(fuel.len)
		add_overlay("no_fuel")
	else
		add_overlay("has_fuel")

///Setup reactor parts
/obj/machinery/power/water/fusion/core/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs
	if(flipped)
		spawn_turfs = block(locate(our_turf.x - 1, our_turf.y + 2, our_turf.z), locate(our_turf.x + 1, our_turf.y, our_turf.z))
	else
		spawn_turfs = block(locate(our_turf.x - 1, our_turf.y - 2, our_turf.z), locate(our_turf.x + 1, our_turf.y, our_turf.z))
	
	var/count = 10
	var/list/part_list = list()
	for(var/turf/T in spawn_turfs)
		count--
		if(T == our_turf) // Skip our turf.
			part_list += src
			continue
		
		var/obj/machinery/power/water/fusion/part/part = new(T)
		part.sprite_number = count
		part.main = src
		parts += part
		part.update_icon()
		part_list += part

	for(var/i = 1, i <= part_list.len, i++)
		var/obj/machinery/power/water/fusion/part = part_list[i]
		var/icon = text2num(part.icon_state)
		if(part.icon_state == "core")
			icon = 2
		if(icon == generator_inlet_index)
			generator_inlet = part
		if(icon == generator_outlet_index)
			generator_outlet = part
		if(icon == cooling_inlet_index)
			cooling_inlet = part
		if(icon == cooling_outlet_index)
			cooling_outlet = part

/// If we somehow get deleted, remove all of our other parts.
/obj/machinery/power/water/fusion/core/Destroy() 
	for(var/obj/machinery/power/water/fusion/part/O in parts)
		O.main = null
		new /obj/effect/decal/cleanable/ash(O.loc)
		if(!QDESTROYING(O))
			qdel(O)

	QDEL_NULL(radio)
	SSair.atmos_machinery -= src
	new /obj/effect/decal/cleanable/ash(loc)
	return ..()


///Passive part, does nothing by itself
/obj/machinery/power/water/fusion/part
	name = "reactor casing"
	desc = "A simple casing for the reactor. Does nothing on its own."
	icon = 'goon/icons/obj/fusion_machines.dmi'
	///Reference to the core
	var/obj/machinery/power/water/fusion/core/main = null
	///What sprite number do we have?
	var/sprite_number

/obj/machinery/power/water/fusion/part/attackby(obj/item/I, mob/user, params)
	return main.attackby(I, user)

/obj/machinery/power/water/fusion/part/update_icon()
	..()
	icon_state = "[sprite_number]"

/obj/machinery/power/water/fusion/part/attack_hand(mob/user)
	return main.attack_hand(user)

/obj/machinery/power/water/fusion/part/Destroy()
	if(main)
		main.parts -= src
		qdel(main)
		return
	return ..()
