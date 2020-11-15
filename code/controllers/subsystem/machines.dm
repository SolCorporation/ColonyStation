SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = INIT_ORDER_MACHINES
	flags = SS_KEEP_TIMING
	var/list/processing = list()
	var/list/currentrun = list()
	var/list/powernets = list()

	var/list/waternets = list()

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	makewaternets()
	fire()
	return ..()

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in GLOB.cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new(PC.loc.z)
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/proc/makewaternets()
	for(var/datum/waternet/PN in waternets)
		qdel(PN)
	waternets.Cut()

	for(var/obj/structure/water_pipe/PC in GLOB.pipe_list)
		if(!PC.waternet)
			var/datum/waternet/NewPN = new(PC.loc.z)
			NewPN.add_pipe(PC)
			propagate_water_network(PC,PC.waternet)

/datum/controller/subsystem/machines/stat_entry(msg)
	msg = "M:[length(processing)]|PN:[length(powernets)]|WN:[waternets.len]"
	return ..()


/datum/controller/subsystem/machines/fire(resumed = 0)
	if (!resumed)
		for(var/datum/powernet/Powernet in powernets)
			Powernet.reset() //reset the power state.
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	var/seconds = wait * 0.1
	while(currentrun.len)
		var/obj/machinery/thing = currentrun[currentrun.len]
		currentrun.len--
		if(!QDELETED(thing) && thing.process(seconds) != PROCESS_KILL)
			if(thing.use_power)
				thing.auto_use_power() //add back the power state
		else
			processing -= thing
			if (!QDELETED(thing))
				thing.datum_flags &= ~DF_ISPROCESSING
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	for(var/A in cables)
		var/obj/structure/cable/PC = A
		if(!PC.powernet)
			var/datum/powernet/NewPN = new(PC.loc.z)
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/Recover()
	if (istype(SSmachines.processing))
		processing = SSmachines.processing
	if (istype(SSmachines.powernets))
		powernets = SSmachines.powernets
