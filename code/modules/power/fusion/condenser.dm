/obj/machinery/power/water/condenser
	name = "condenser"
	desc = "This cools down any water that enters it." 
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"

	density = TRUE

	///What temp does the water get cooled to? Increased by upgrades. Higher is better, less energy needed to heat up to optimal generator level
	var/water_cooling_temp = 50
	///What amount of water can we cool to this temp before we go over?
	var/max_capacity = 50

	var/last_water_amount = 0
	var/last_temp = 0


/obj/machinery/power/water/condenser/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	name += " ([num2hex(rand(1,65535), -1)])"

/obj/machinery/power/water/condenser/process()
	if(stat & BROKEN)
		return PROCESS_KILL


	if(!get_water())
		return

	var/turf/T = get_step(src, SOUTH)
	var/obj/structure/water_pipe/C = T.get_pipe_node() //check if we have a node cable on the southern turf
	if(!C || !C.waternet)
		return
	
	var/water = get_water() * 0.9
	

	if(water <= 0)
		return

	remove_water(water)
	var/current_temp = get_temp()

	last_water_amount = water

	var/temp_of_destination = get_temp(T)
	var/water_of_destination = get_water(T)

	var/capacity_used = water / max_capacity
	var/temp_modulation = clamp(capacity_used * water_cooling_temp, water_cooling_temp, current_temp)

	last_temp = temp_modulation

	var/final_temp = EQUALIZE_WATER_TEMP(water, temp_modulation, water_of_destination, temp_of_destination)

	add_water(water, T)
	set_temp(final_temp, T)
