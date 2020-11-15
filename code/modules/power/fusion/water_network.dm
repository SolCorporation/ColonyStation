////////////////////////////////////////////
// WATERNET DATUM
// each contiguous network of cables & nodes
/////////////////////////////////////
/datum/waternet
	///Unique ID
	var/number					
	///All pipes
	var/list/pipes = list()		
	///All connected machines
	var/list/nodes = list()

	///Temperature of the contained water
	var/temp = T20C				
	///Amount of water
	var/amount = STARTING_WATER_AMOUNT

/datum/waternet/New()
	SSmachines.waternets += src

/datum/waternet/Destroy()
	//Go away references, you suck!
	for(var/obj/structure/water_pipe/C in pipes)
		pipes -= C
		C.waternet = null
	for(var/obj/machinery/power/water/M in nodes)
		nodes -= M
		M.waternet = null

	SSmachines.waternets -= src
	return ..()

/datum/waternet/proc/is_empty()
	return !pipes.len && !nodes.len

//remove a cable from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the cable exists
/datum/waternet/proc/remove_pipe(obj/structure/water_pipe/C)
	pipes -= C
	C.waternet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it

//add a cable to the current powernet
//Warning : this proc DON'T check if the cable exists
/datum/waternet/proc/add_pipe(obj/structure/water_pipe/C)
	if(C.waternet)// if C already has a powernet...
		if(C.waternet == src)
			return
		else
			C.waternet.remove_pipe(C) //..remove it
	C.waternet = src
	pipes +=C

//remove a power machine from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/waternet/proc/remove_machine(obj/machinery/power/water/M)
	nodes -=M
	M.waternet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it


//add a power machine to the current powernet
//Warning : this proc DOESN'T check if the machine exists
/datum/waternet/proc/add_machine(obj/machinery/power/water/M)
	if(M.waternet)// if M already has a powernet...
		if(M.waternet == src)
			return
		else
			M.disconnect_from_water_network()//..remove it
	M.waternet = src
	nodes[M] = M

/proc/propagate_water_network(obj/O, datum/waternet/PN)
	var/list/worklist = list()
	var/list/found_machines = list()
	var/index = 1
	var/obj/P = null

	worklist+=O //start propagating from the passed object

	while(index<=worklist.len) //until we've exhausted all power objects
		P = worklist[index] //get the next power object found
		index++

		if( istype(P, /obj/structure/water_pipe))
			var/obj/structure/water_pipe/C = P
			if(C.waternet != PN) //add it to the powernet, if it isn't already there
				PN.add_pipe(C)
			worklist |= C.get_connections() //get adjacents power objects, with or without a powernet

		else if(P.anchored && istype(P, /obj/machinery/power/water))
			var/obj/machinery/power/water/M = P
			found_machines |= M //we wait until the powernet is fully propagates to connect the machines

		else
			continue

	//now that the powernet is set, connect found machines to it
	for(var/obj/machinery/power/water/PM in found_machines)
		if(!PM.connect_to_water_network()) //couldn't find a node on its turf...
			PM.disconnect_from_network() //... so disconnect if already on a powernet

/turf/proc/get_pipe_node()
	if(!can_have_cabling())
		return null
	for(var/obj/structure/water_pipe/C in src)
		if(C.d1 == 0)
			return C
	return null

/proc/merge_waternets(datum/waternet/net1, datum/waternet/net2)
	if(!net1 || !net2) //if one of the powernet doesn't exist, return
		return

	if(net1 == net2) //don't merge same powernets
		return

	//We assume net1 is larger. If net2 is in fact larger we are just going to make them switch places to reduce on code.
	if(net1.pipes.len < net2.pipes.len)	//net2 is larger than net1. Let's switch them around
		var/temp = net1
		net1 = net2
		net2 = temp

	//merge net2 into net1
	for(var/obj/structure/water_pipe/Cable in net2.pipes) //merge cables
		net1.add_pipe(Cable)

	for(var/obj/machinery/power/water/Node in net2.nodes) //merge power machines
		if(!Node.connect_to_water_network())
			Node.disconnect_from_water_network() //if somehow we can't connect the machine to the new powernet, disconnect it from the old nonetheless

	return net1

/proc/water_list(turf/T, source, d, unmarked=0, cable_only = 0)
	. = list()

	for(var/AM in T)
		if(AM == source)
			continue			//we don't want to return source

		if(!cable_only && istype(AM, /obj/machinery/power/water))
			var/obj/machinery/power/water/P = AM
			if(P.powernet == 0)
				continue		// exclude APCs which have powernet=0

			if(!unmarked || !P.waternet)		//if unmarked=1 we only return things with no powernet
				if(d == 0)
					. += P

		else if(istype(AM, /obj/structure/water_pipe))
			var/obj/structure/water_pipe/C = AM

			if(!unmarked || !C.waternet)
				if(C.d1 == d || C.d2 == d)
					. += C
	return .
