GLOBAL_LIST_EMPTY(pipe_list)	
/obj/structure/water_pipe
	name = "water pipe"
	desc = "A rigid pipe for transfering water."
	icon = 'icons/obj/power_cond/power_cond_heavy.dmi'
	icon_state = "0-1"
	level = 1 //is underfloor
	layer = WIRE_LAYER //Above hidden pipes, GAS_PIPE_HIDDEN_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	var/d1 = 0   // cable direction 1 (see above)
	var/d2 = 1   // cable direction 2 (see above)

	var/datum/waternet/waternet

/obj/structure/water_pipe/Initialize(mapload, param_color)
	. = ..()

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num( copytext( icon_state, 1, dash ) )
	d2 = text2num( copytext( icon_state, dash+1 ) )
	GLOB.pipe_list += src //add it to the global cable list

	update_icon()

/obj/structure/water_pipe/Destroy()					// called when a cable is deleted
	if(waternet)
		cut_cable_from_waternet()				// update the waternets
	GLOB.pipe_list -= src							//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/water_pipe/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = loc
		var/cableNum = 1
		if (d1*d2 > 0) //this be true if the cable has two directions, aka it contains two cables. If there is only one cable, one out of d1 and d2 will be zero
			cableNum = 2
		var/newCables = new /obj/item/stack/water_pipes(T, cableNum)
		TransferComponents(newCables) //this copies the fingerprints over to the new object
	qdel(src)

/obj/structure/water_pipe/update_icon()
	icon_state = "[d1]-[d2]"

/obj/structure/water_pipe/attackby(obj/item/W, mob/user, params)
	handlecable(W, user, params)

/obj/structure/water_pipe/proc/handlecable(obj/item/W, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		user.visible_message("[user] removes the pipe.", "<span class='notice'>You remove the pipe.</span>")
		investigate_log("was removed by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
		add_fingerprint(user)
		deconstruct()
		return

	else if(istype(W, /obj/item/stack/water_pipes))
		var/obj/item/stack/water_pipes/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough pipes!</span>")
			return
		coil.cable_join(src, user)

	else if(W.tool_behaviour == TOOL_MULTITOOL)
		if(waternet && (waternet.amount > 0))		// is it powered?
			to_chat(user, "<span class='danger'>Total water: [waternet.amount]L\nTemperature: [waternet.temp]K</span>")
		else
			to_chat(user, "<span class='danger'>The pipe does not contain any water.</span>")

	add_fingerprint(user)

/obj/structure/water_pipe/proc/mergeConnectedNetworks(direction)

	var/fdir = (!direction)? 0 : turn(direction, 180) //flip the direction, to match with the source position on its turf

	if(!(d1 == direction || d2 == direction)) //if the cable is not pointed in this direction, do nothing
		return

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/water_pipe/C in TB)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir) //we've got a matching cable in the neighbor turf
			if(!C.waternet) //if the matching cable somehow got no waternet, make him one (should not happen for cables)
				var/datum/waternet/newPN = new(C.loc.z)
				newPN.add_pipe(C)

			if(waternet) //if we already have a waternet, then merge the two waternets
				merge_waternets(waternet,C.waternet)
			else
				C.waternet.add_pipe(src) //else, we simply connect to the matching cable waternet

// merge with the waternets of power objects in the source turf
/obj/structure/water_pipe/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!waternet) //if we somehow have no waternet, make one (should not happen for cables)
		var/datum/waternet/newPN = new(loc.z)
		newPN.add_pipe(src)

	//first let's add turf cables to our waternet
	//then we'll connect machines on turf with a node cable is present
	for(var/AM in loc)
		if(istype(AM, /obj/structure/water_pipe))
			var/obj/structure/water_pipe/C = AM
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) //only connected if they have a common direction
				if(C.waternet == waternet)
					continue
				if(C.waternet)
					merge_waternets(waternet, C.waternet)
				else
					waternet.add_pipe(C) //the cable was waternetless, let's just add it to our waternet

		else if(istype(AM, /obj/machinery/power/water)) //other power machines
			var/obj/machinery/power/water/M = AM

			if(M.waternet == waternet)
				continue

			to_connect += M //we'll connect the machines after all cables are merged

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new waternet, remove it from the old nonetheless

/obj/structure/water_pipe/proc/get_connections(powernetless_only = 0)
	. = list()	// this will be a list of all connected power objects
	var/turf/T

	//get matching cables from the first direction
	if(d1) //if not a node cable
		T = get_step(src, d1)
		if(T)
			. += water_list(T, src, turn(d1, 180), powernetless_only) //get adjacents matching cables

	if(d1&(d1-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d1&3) // go north/south
		if(T)
			. += water_list(T, src, d1 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d1&12) // go east/west
		if(T)
			. += water_list(T, src, d1 ^ 12, powernetless_only) //get diagonally matching cables

	. += water_list(loc, src, d1, powernetless_only) //get on turf matching cables

	//do the same on the second direction (which can't be 0)
	T = get_step(src, d2)
	if(T)
		. += power_list(T, src, turn(d2, 180), powernetless_only) //get adjacents matching cables

	if(d2&(d2-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d2&3) // go north/south
		if(T)
			. += power_list(T, src, d2 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d2&12) // go east/west
		if(T)
			. += power_list(T, src, d2 ^ 12, powernetless_only) //get diagonally matching cables
	. += power_list(loc, src, d2, powernetless_only) //get on turf matching cables

	return .

/obj/structure/water_pipe/proc/auto_propogate_cut_cable(obj/O)
	if(O && !QDELETED(O))
		var/datum/waternet/newPN = new()// creates a new waternet...
		propagate_water_network(O, newPN)//... and propagates it to the other side of the cable

// cut the cable's waternet at this cable and updates the powergrid
/obj/structure/water_pipe/proc/cut_cable_from_waternet(remove=TRUE)
	var/turf/T1 = loc
	var/list/P_list
	if(!T1)
		return
	if(d1)
		T1 = get_step(T1, d1)
		P_list = water_list(T1, src, turn(d1,180),0,cable_only = 1)	// what adjacently joins on to cut cable...

	P_list += water_list(loc, src, d1, 0, cable_only = 1)//... and on turf


	if(P_list.len == 0)//if nothing in both list, then the cable was a lone cable, just delete it and its waternet
		waternet.remove_pipe(src)

		for(var/obj/machinery/power/water/P in T1)//check if it was powering a machine
			if(!P.connect_to_water_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_water_network() //remove from current network (and delete waternet)
		return

	var/obj/O = P_list[1]
	// remove the cut cable from its turf and waternet, so that it doesn't get count in propagate_network worklist
	if(remove)
		moveToNullspace()
	waternet.remove_pipe(src) //remove the cut cable from its waternet

	addtimer(CALLBACK(O, .proc/auto_propogate_cut_cable, O), 0) //so we don't rebuild the network X times when singulo/explosion destroys a line of X cables

	// Disconnect machines connected to nodes
	if(d1 == 0) // if we cut a node (O-X) cable
		for(var/obj/machinery/power/water/P in T1)
			if(!P.connect_to_water_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_water_network() //remove from current network

/obj/structure/water_pipe/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = water_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a waternet
	if(powerlist.len>0)
		var/datum/waternet/PN = new(loc.z)
		propagate_water_network(powerlist[1],PN) //propagates the new waternet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

/obj/item/stack/water_pipes
	name = "water pipes"
	custom_price = 15
	gender = NEUTER //That's a cable coil sounds better than that's some cable coils
	icon = 'icons/obj/power.dmi'
	icon_state = "wire"
	item_state = "wire"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/water_pipes // This is here to let its children merge between themselves
	item_color = "red"
	desc = "A bungled mess of water pipes."
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10, MAT_GLASS=5)
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	singular_name = "water pipe"
	full_w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/iron = 2) //2 iron per cable in the coil
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/stack/water_pipes/Initialize(mapload)
	. = ..()

	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

/obj/item/stack/water_pipes/update_icon()
	icon_state = "[initial(item_state)][amount < 3 ? amount : ""]"
	name = "water [amount < 2 ? "pipe" : "pipes"]"

/obj/item/stack/water_pipes/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/obj/item/stack/water_pipes/new_cable = ..()
	if(istype(new_cable))
		new_cable.update_icon()

/obj/item/stack/water_pipes/proc/get_new_cable(location)
	var/path = /obj/structure/water_pipe
	return new path(location)

// called when cable_coil is clicked on a turf
/obj/item/stack/water_pipes/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || T.intact || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay pipes on catwalks and plating!</span>")
		return

	if(get_amount() < 1) // Out of cable
		to_chat(user, "<span class='warning'>There is no pipe left!</span>")
		return

	if(get_dist(T,user) > 1) // Too far
		to_chat(user, "<span class='warning'>You can't lay pipes at a place that far away!</span>")
		return

	var/dirn
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew

	for(var/obj/structure/water_pipe/LC in T)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, "<span class='warning'>There's already a pipe at that position!</span>")
			return
	if(!(dirn in GLOB.cardinals))
		to_chat(user, "<span class='warning'>You can't lay pipes diagonally!</span>")
		return

	var/obj/structure/water_pipe/C = get_new_cable(T)

	//set up the new cable
	C.d1 = 0 //it's a O-X node cable
	C.d2 = dirn
	C.add_fingerprint(user)
	C.update_icon()

	//create a new waternet with the cable, if needed it will be merged later
	var/datum/waternet/PN = new(loc.z)
	PN.add_pipe(C)

	C.mergeConnectedNetworks(C.d2) //merge the waternet with adjacents waternets
	C.mergeConnectedNetworksOnTurf() //merge the waternet with on turf waternets

	use(1)

	return C

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/water_pipes/proc/cable_join(obj/structure/water_pipe/C, mob/user, var/showerror = TRUE, forceddir)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, "<span class='warning'>You can't lay pipe at a place that far away!</span>")
		return


	if(U == T && !forceddir) //if clicked on the turf we're standing on and a direction wasn't supplied, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)
	if(forceddir)
		dirn = forceddir

	// one end of the clicked cable is pointing towards us and no direction was supplied
	if((C.d1 == dirn || C.d2 == dirn) && !forceddir)
		if(!U.can_have_cabling())						//checking if it's a plating or catwalk
			if (showerror)
				to_chat(user, "<span class='warning'>You can only lay pipes on catwalks and plating!</span>")
			return
		// cable is pointing at us, we're standing on an open tile
		// so create a stub pointing at the clicked cable on our tile

		var/fdirn = turn(dirn, 180)		// the opposite direction

		for(var/obj/structure/water_pipe/LC in U)		// check to make sure there's not a cable there already
			if(LC.d1 == fdirn || LC.d2 == fdirn)
				if (showerror)
					to_chat(user, "<span class='warning'>There's already a pipe at that position!</span>")
				return

		if(!(fdirn in GLOB.cardinals))
			to_chat(user, "<span class='warning'>You can't lay pipes diagonally!</span>")
			return

		var/obj/structure/water_pipe/NC = get_new_cable (U)

		NC.d1 = 0
		NC.d2 = fdirn
		NC.add_fingerprint(user)
		NC.update_icon()

		//create a new waternet with the cable, if needed it will be merged later
		var/datum/waternet/newPN = new(loc.z)
		newPN.add_pipe(NC)

		NC.mergeConnectedNetworks(NC.d2) //merge the waternet with adjacents waternets
		NC.mergeConnectedNetworksOnTurf() //merge the waternet with on turf waternets


		use(1)

		return

	// exisiting cable doesn't point at our position or we have a supplied direction, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2

		if(!(nd1 in GLOB.cardinals))
			to_chat(user, "<span class='warning'>You can't lay pipes diagonally!</span>")
			return
		if(!(nd2 in GLOB.cardinals))
			to_chat(user, "<span class='warning'>You can't lay pipes diagonally!</span>")
			return


		for(var/obj/structure/water_pipe/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				if (showerror)
					to_chat(user, "<span class='warning'>There's already a pipe at that position!</span>")

				return


		C.update_icon()

		C.d1 = nd1
		C.d2 = nd2

		//updates the stored cable coil

		C.add_fingerprint(user)
		C.update_icon()


		C.mergeConnectedNetworks(C.d1) //merge the waternets...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()


		use(1)


		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the waternets.
		return
