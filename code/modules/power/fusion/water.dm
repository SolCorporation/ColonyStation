/obj/machinery/power/water
	var/datum/waternet/waternet

/obj/machinery/power/water/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/water_pipes))
		var/obj/item/stack/water_pipes/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough pipes!</span>")
			return
		to_chat(user, "<span class='info'>You start placing a node under [src]...</span>")
		if(!do_after(user, 25))
			to_chat(user, "<span class='warning'>You failed to place the node!</span>")
			return
		to_chat(user, "<span class='info'>You successfully place the node under [src].</span>")
		coil.cable_join(src, user)
		return
	return . = ..()

/obj/machinery/power/water/proc/disconnect_from_water_network()
	if(!waternet)
		return FALSE
	waternet.remove_machine(src)
	return TRUE

/obj/machinery/power/water/Destroy()
	disconnect_from_water_network()
	return ..()

/obj/machinery/power/water/Initialize()
	connect_to_water_network()
	return ..()

/obj/machinery/power/water/proc/connect_to_water_network()
	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/water_pipe/C = T.get_pipe_node() //check if we have a node cable on the machine turf, the first found is picked
	if(!C || !C.waternet)
		return FALSE

	waternet = C.waternet
	C.waternet.add_machine(src)
	return TRUE

/obj/machinery/power/water/proc/add_water(amount, var/turf/waternet_turf = get_turf(src))
	
	if(!isturf(waternet_turf))
		waternet_turf = get_turf(waternet_turf)
	if(!isturf(waternet_turf))
		return FALSE
	
	var/obj/structure/water_pipe/C = waternet_turf.get_pipe_node()
	if(!C.waternet)
		return FALSE
	C.waternet.amount += amount
	return TRUE

/obj/machinery/power/water/proc/remove_water(amount, turf/waternet_turf = get_turf(src))
	
	if(!isturf(waternet_turf))
		waternet_turf = get_turf(waternet_turf)
	if(!isturf(waternet_turf))
		return FALSE
	var/obj/structure/water_pipe/C = waternet_turf.get_pipe_node()

	if(!C.waternet)
		return FALSE
	if(C.waternet.amount < amount)
		return FALSE

	C.waternet.amount -= amount
	return TRUE

/obj/machinery/power/water/proc/heat_water(amount, turf/waternet_turf = get_turf(src))
	if(!isturf(waternet_turf))
		waternet_turf = get_turf(waternet_turf)
	if(!isturf(waternet_turf))
		return FALSE
	var/obj/structure/water_pipe/C = waternet_turf.get_pipe_node()
	if(!C.waternet)
		return FALSE
	C.waternet.temp += amount
	return TRUE

/obj/machinery/power/water/proc/cool_water(amount, turf/waternet_turf = get_turf(src))
	if(!isturf(waternet_turf))
		waternet_turf = get_turf(waternet_turf)
	if(!isturf(waternet_turf))
		return FALSE
	var/obj/structure/water_pipe/C = waternet_turf.get_pipe_node()
	if(!C.waternet)
		return FALSE
	if(C.waternet.temp < amount)
		C.waternet.temp = 0
		return TRUE
	C.waternet.temp -= amount
	return TRUE

/obj/machinery/power/water/proc/get_water(turf/waternet_turf = get_turf(src))
	if(!isturf(waternet_turf))
		waternet_turf = get_turf(waternet_turf)
	if(!isturf(waternet_turf))
		return FALSE
	var/obj/structure/water_pipe/C = waternet_turf.get_pipe_node()
	if(!C.waternet)
		return FALSE
	return C.waternet.amount


/obj/machinery/power/water/proc/get_temp(turf/waternet_turf = get_turf(src))
	if(!isturf(waternet_turf))
		waternet_turf = get_turf(waternet_turf)
	if(!isturf(waternet_turf))
		return FALSE
	var/obj/structure/water_pipe/C = waternet_turf.get_pipe_node()
	if(!C.waternet)
		return FALSE
	return C.waternet.temp

/obj/machinery/power/water/proc/set_temp(temp, turf/waternet_turf = get_turf(src))
	if(!isturf(waternet_turf))
		waternet_turf = get_turf(waternet_turf)
	if(!isturf(waternet_turf))
		return FALSE
	var/obj/structure/water_pipe/C = waternet_turf.get_pipe_node()
	if(!C.waternet)
		return FALSE
	C.waternet.temp = temp
	return TRUE
