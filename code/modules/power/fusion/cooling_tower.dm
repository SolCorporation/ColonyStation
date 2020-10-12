//TODO: Change to cooling tower when we get that sprite

/obj/machinery/power/water/heat_exchanger
	name = "heat exchanger"
	desc = "This cools down any water that enters it. Basically a larger version of a condenser" 
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	icon_state = "he1"

	density = TRUE

	///What temp does the water get cooled by? Increased by upgrades. Lower is better, since we're cooling
	var/water_cooling_amount = 5000

/obj/machinery/power/water/heat_exchanger/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/machinery/power/water/heat_exchanger/process()
	if(stat & BROKEN)
		return PROCESS_KILL


	if(!get_water())
		return

	var/turf/T = get_step(src, NORTH)
	var/obj/structure/water_pipe/C = T.get_pipe_node() //check if we have a node cable on the southern turf
	if(!C || !C.waternet)
		return
	
	var/water = get_water()
	var/temp = get_temp()
	remove_water(water)


	var/temp_of_destination = get_temp(T)
	var/water_of_destination = get_water(T)
	var/final_temp = EQUALIZE_WATER_TEMP(water, (min(temp - water_cooling_amount, 10)), water_of_destination, temp_of_destination)

	add_water(water, T)
	set_temp(T, final_temp)
