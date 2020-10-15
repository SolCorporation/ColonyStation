#define GENERATOR_OFF 0
#define GENERATOR_STARTING 1
#define GENERATOR_STARTED 2
#define GENERATOR_STOPPING 3

/obj/machinery/power/water/fusion_gen/center
	name = "turbine"
	desc = "This machine uses the thermal energy of steam to create mechanical motion, which is then converted to electricity." 
	icon = 'icons/obj/fusion_machines.dmi'
	icon_state = "gen_center"

	density = TRUE
	///How much steam did we have last tick?
	var/last_tick_usage = 0

	///How much steam/water can we process at max?
	var/max_throughput = 250

	///At what temp and above do we get 100% power output?
	var/optimal_temp = 600

	///How much of the heat can we turn into power?
	var/efficiency = 0.5

	///1 heat unit (After efficiency applied, efficiency*max_throughput*this), 1000 = 1kW per heat = 500W per heat at 50% efficiency
	var/conversion_rate = 1000

	var/obj/machinery/power/fusion_gen/left/electric_part

	var/obj/machinery/power/water/fusion_gen/right/steam_part


/obj/machinery/power/water/fusion_gen/center/Initialize()
	. = ..()
	name += " ([num2hex(rand(1,65535), -1)])"

	electric_part = locate(/obj/machinery/power/fusion_gen/left) in get_step(src, WEST)
	steam_part = locate(/obj/machinery/power/water/fusion_gen/right) in get_step(src, EAST)

	if(electric_part)
		electric_part.update_icon()
	if(steam_part)
		steam_part.center = src

	addtimer(CALLBACK(src, .proc/CheckBroken), 5 SECONDS)
	
/obj/machinery/power/water/fusion_gen/center/proc/CheckBroken()
	var/turf/T = get_turf(src)

	if(!electric_part || !steam_part)
		stack_trace("parts")
		stat |= BROKEN
		return
	if(!T.get_pipe_node())
		stack_trace("waternet")
		stat |= BROKEN
		return
	if(!electric_part.connect_to_network())
		stack_trace("electric network")
		stat |= BROKEN
		return
	if(!steam_part.waternet)
		stack_trace("steam water")
		stat |= BROKEN
		return
	update_icon()
	START_PROCESSING(SSobj, src)


/obj/machinery/power/water/fusion_gen/center/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/machinery/power/water/fusion_gen/center/update_icon()
	electric_part.update_icon()

	cut_overlays()
	if(last_tick_usage > (max_throughput * 0.95))
		add_overlay("mid_overlay_overmax")
		electric_part.update_icon(TRUE)
		return
	if(last_tick_usage > (max_throughput * 0.9))
		add_overlay("mid_overlay_max")
		return
	if(last_tick_usage > (max_throughput * 0.675))
		add_overlay("mid_overlay_high")
		return
	if(last_tick_usage > (max_throughput * 0.45))
		add_overlay("mid_overlay_med")
		return
	if(last_tick_usage > (max_throughput * 0.225))
		add_overlay("mid_overlay_low")
		return
	add_overlay("mid_overlay_off")

/obj/machinery/power/water/fusion_gen/center/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		to_chat(user, "<span class='info'>Attempting to reactivate machine...</span>")
		if(!do_after(user, 25))
			to_chat(user, "<span class='warning'>You fail to reactivate the machine!</span>")
			return
		var/still_broken = FALSE
		if(!electric_part || !steam_part)
			still_broken = TRUE

		if(!waternet)
			still_broken = TRUE

		if(!electric_part.connect_to_network())
			still_broken = TRUE

		if(!steam_part.waternet)
			still_broken = TRUE
		
		if(still_broken) 
			to_chat(user, "<span class='warning'>You fail to reactivate the machine!</span>")
		else
			to_chat(user, "<span class='info'>You reactivate the machine.</span>")
			update_icon()
			START_PROCESSING(SSobj, src)
			stat &= ~BROKEN
		return

	return ..()

/obj/machinery/power/water/fusion_gen/center/process()
	if(stat & BROKEN)
		return PROCESS_KILL

	electric_part.add_avail(process_power())


/obj/machinery/power/water/fusion_gen/center/proc/process_power()
	if(!steam_part)
		stat |= BROKEN
		return

	var/water = steam_part.get_water()
	var/temp = steam_part.get_temp()

	var/found_intakes = 0
	//Distribute the water amongst the generators
	for(var/obj/machinery/power/water/fusion_gen/right/intake in steam_part.waternet.nodes)
		found_intakes++

	if(!found_intakes) //This is bad..
		return 0
	
	water = water / found_intakes

	if(water > max_throughput)
		water = max_throughput

	

	//Steal the water
	steam_part.remove_water(water)

	last_tick_usage = water
	update_icon()

	var/multiplier = 1
	if(temp < optimal_temp && temp > 0)
		multiplier = temp / optimal_temp

	var/water_dest = get_water()
	var/temp_dest = get_temp()
	
	if(water <= 0)
		return 0
	if(water + water_dest <= 0)
		return 0

	var/final_temp = EQUALIZE_WATER_TEMP(water, temp, water_dest, temp_dest) * efficiency
	set_temp(final_temp)

	add_water(water)
	
	return conversion_rate * multiplier * water


/obj/machinery/power/water/fusion_gen/right
	name = "turbine intake"
	desc = "This part of the machine takes in heat energy in the form of steam." 
	icon = 'icons/obj/fusion_machines.dmi'
	icon_state = "gen_right"

	density = TRUE

	var/obj/machinery/power/water/fusion_gen/center/center

/obj/machinery/power/water/fusion_gen/right/Destroy()
	if(center)
		center |= BROKEN
	return ..()

/obj/machinery/power/fusion_gen/left
	name = "turbine generator"
	desc = "This part of the machine converts the mechanical energy to electricity." 
	icon = 'icons/obj/fusion_machines.dmi'
	icon_state = "gen_left"

	density = TRUE

	var/obj/machinery/power/water/fusion_gen/center/center

/obj/machinery/power/fusion_gen/left/update_icon(max_reached = FALSE)
	cut_overlays()
	if(max_reached)
		add_overlay("left_overlay_blinking")
	else
		add_overlay("left_overlay")


/obj/machinery/power/fusion_gen/left/Destroy()
	if(center)
		center |= BROKEN
	return ..()
