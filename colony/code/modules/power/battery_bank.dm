//TODO: Circuits
///Rate of internal charge to external power
#define MESSRATE 0.05			

///Max cells per FULL MESS, (Not per section)
#define MAX_CELLS 8

/obj/machinery/power/battery_bank
	name = "modular energy storage system controller"
	desc = "A modular energy storage system (MESS)"

	icon = 'icons/obj/battery_bank.dmi'
	icon_state = "mid"
	density = TRUE
	use_power = NO_POWER_USE

	ui_x = 340
	ui_y = 350

	var/input_on = TRUE // TRUE = attempting to charge, FALSE = not attempting to charge
	var/getting_input = TRUE // TRUE = actually getting_input, FALSE = not getting_input
	var/input_level = 50000 // amount of power the SMES attempts to charge by
	var/input_level_max = 200000 // cap on input_level
	var/input_available = 0 // amount of charge available from input last tick

	var/output_on = TRUE // TRUE = attempting to output, FALSE = not attempting to output
	var/outputting = TRUE // TRUE = actually outputting, FALSE = not outputting
	var/output_level = 50000 // amount of power the SMES attempts to output
	var/output_level_max = 200000 // cap on output_level
	var/output_used = 0 // amount of power actually outputted. may be less than output_level if the powernet returns excess power

	var/obj/machinery/power/terminal/terminal = null

	var/obj/machinery/power/battery_bank_section/L
	var/obj/machinery/power/battery_bank_section/R

	///Is the charge evenly being added to the cells?
	var/balanced_charging = FALSE


/obj/machinery/power/battery_bank/Initialize()
	. = ..()
	dir_loop:
		for(var/d in GLOB.cardinals)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/term in T)
				if(term && term.dir == turn(d, 180))
					terminal = term
					break dir_loop
	if(!terminal)
		stat |= BROKEN
		return
	terminal.master = src

	var/turf/T = get_step(src, WEST)
	for(var/obj/machinery/power/battery_bank_section/S in T)
		L = S
		S.master = src
		break
	T = get_step(src, EAST)
	for(var/obj/machinery/power/battery_bank_section/S in T)
		R = S
		S.master = src
		break
	
	if(!L || !R)
		stat |= BROKEN
		return
	update_icon()

/obj/machinery/power/battery_bank/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/T = get_turf(src)
		message_admins("MESS deleted at [ADMIN_VERBOSEJMP(T)]")
		log_game("MESS deleted at [AREACOORD(T)]")
		investigate_log("<font color='red'>deleted</font> at [AREACOORD(T)]", INVESTIGATE_SINGULO)
		investigate_log("<font color='red'>deleted</font> at [AREACOORD(T)]", INVESTIGATE_SUPERMATTER) // yogs - so supermatter investigate is useful
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/battery_bank/attackby(obj/item/I, mob/user, params)
	//opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon()
		return

	//building and linking a terminal
	if(istype(I, /obj/item/stack/cable_coil))
		var/dir = get_dir(user,src)

		if(dir & (dir-1))//we don't want diagonal click
			return

		if(terminal) //is there already a terminal ?
			to_chat(user, "<span class='warning'>This MESS already has a power terminal!</span>")
			return

		if(!panel_open) //is the panel open ?
			to_chat(user, "<span class='warning'>You must open the maintenance panel first!</span>")
			return

		var/turf/T = get_turf(user)
		if (T.intact) //is the floor plating removed ?
			to_chat(user, "<span class='warning'>You must first remove the floor plating!</span>")
			return


		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need more wires!</span>")
			return

		to_chat(user, "<span class='notice'>You start building the power terminal...</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)

		if(do_after(user, 20, target = src))
			if(C.get_amount() < 10 || !C)
				return
			var/obj/structure/cable/N = T.get_cable_node() //get the connecting node cable, if there's one
			if (prob(50) && electrocute_mob(usr, N, N, 1, TRUE)) //animate the electrocution if uncautious and unlucky
				do_sparks(5, TRUE, src)
				return
			if(!terminal)
				C.use(10)
				user.visible_message(\
					"[user.name] has built a power terminal.",\
					"<span class='notice'>You build the power terminal.</span>")

				//build the terminal and link it to the network
				make_terminal(T)
				terminal.connect_to_network()
				connect_to_network()
		return

	//crowbarring it !
	
	if(default_deconstruction_crowbar(I))
		var/turf/T = get_turf(src)
		message_admins("[src] has been deconstructed by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(T)]")
		log_game("[src] has been deconstructed by [key_name(user)] at [AREACOORD(src)]")
		investigate_log("MESS deconstructed by [key_name(user)] at [AREACOORD(src)]", INVESTIGATE_SINGULO)
		investigate_log("MESS deconstructed by [key_name(user)] at [AREACOORD(src)]", INVESTIGATE_SUPERMATTER) // yogs - so supermatter investigate is useful
		return
	else if(panel_open && I.tool_behaviour == TOOL_CROWBAR)
		return

	if(panel_open && I.tool_behaviour == TOOL_MULTITOOL)
		to_chat(user, "<span class='info'>Linking process initiated.</span>")
		if(!do_after(user, 25, target = src))
			to_chat(user, "<span class='warning'>Linking process failed!</span>")
			return

		var/turf/T = get_step(src, WEST)
		for(var/obj/machinery/power/battery_bank_section/S in T)
			L = S
			if(S.master)
				S.master.L = null
			S.master = src
			visible_message("Left system extension found.")
			break

		T = get_step(src, EAST)
		for(var/obj/machinery/power/battery_bank_section/S in T)
			R = S
			if(S.master)
				S.master.R = null
			S.master = src
			visible_message("Right system extension found.")
			break
		
		if(!L)
			visible_message("Left system extension NOT found.")
		if(!R)
			visible_message("Right system extension NOT found.")
		if(L && R && terminal)
			stat &= ~BROKEN
		return

	return ..()

/obj/machinery/power/battery_bank/proc/make_terminal(turf/T)
	terminal = new/obj/machinery/power/terminal(T)
	terminal.setDir(get_dir(T,src))
	terminal.master = src
	if(L && R)
		stat &= ~BROKEN

/obj/machinery/power/battery_bank/update_icon()
	..()
	cut_overlays()
	if(stat & BROKEN)
		return
	if(panel_open)
		return

	if(getting_input && input_on)
		add_overlay("up_arrow")
	else if(input_on && !getting_input && !outputting)
		add_overlay("neutral_arrow")
	else if(!getting_input && outputting)
		add_overlay("down_arrow")

	var/charge = get_current_charge()
	var/max_charge = get_max_charge()

	var/percent = 0
	if(max_charge > 0)
		percent = round(charge / max_charge * 100, 10)

	if(percent == 0)
		return
	add_overlay("right-overlay-[percent]")

	
/obj/machinery/power/battery_bank/proc/get_cells()
	var/list/all_cells = L.cells + R.cells
	return all_cells

/obj/machinery/power/battery_bank/proc/get_current_charge()
	var/list/all_cells = L.cells + R.cells
	var/total_charge = 0

	for(var/obj/item/battery_bank_cell/cell in all_cells)
		total_charge += cell.charge
	return total_charge

/obj/machinery/power/battery_bank/proc/get_max_charge()
	var/list/all_cells = L.cells + R.cells
	var/total_charge = 0

	for(var/obj/item/battery_bank_cell/cell in all_cells)
		total_charge += cell.maxcharge
	return total_charge

/obj/machinery/power/battery_bank/proc/add_charge(amount)
	var/list/cells = get_cells()
	var/amount_to_charge = amount

	for(var/obj/item/battery_bank_cell/cell in cells)
		amount_to_charge -= cell.give(balanced_charging ? (amount / cells.len) : amount_to_charge)
		if(amount_to_charge <= 0)
			return

/obj/machinery/power/battery_bank/proc/remove_charge(amount)
	var/list/cells = get_cells()
	var/amount_to_use = amount
	var/outputting_cells = cells.len

	for(var/obj/item/battery_bank_cell/cell in cells)
		var/detract_per_cell = amount_to_use / outputting_cells
		var/detract_amount = balanced_charging ? detract_per_cell : amount_to_use
		if(detract_amount > cell.charge)
			detract_amount = cell.charge
			if(cell.charge != 0)
				outputting_cells--

		if(cell.use(detract_amount))
			amount_to_use -= detract_amount


/obj/machinery/power/battery_bank/proc/create_terminal(turf/T)
	terminal = new/obj/machinery/power/terminal(T)
	terminal.setDir(get_dir(T, SOUTH))
	terminal.master = src
	stat &= ~BROKEN

/obj/machinery/power/battery_bank/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		stat |= BROKEN

/obj/machinery/power/battery_bank/process()
	if(stat & BROKEN)
		return

	//store machine state to see if we need to update the icon overlays
	var/last_percent = 0
	if(get_max_charge() > 0)
		last_percent = get_current_charge() / get_max_charge() * 100
	var/last_charge = getting_input
	var/last_output = outputting

	//getting_input
	if(terminal && input_on)
		input_available = terminal.surplus()

		if(getting_input)
			if(input_available > 0)		// if there's power available, try to charge
				var/capacity = get_max_charge()

				var/charge = get_current_charge()

				var/remaining_capacity = capacity - charge

				var/input = min(remaining_capacity / MESSRATE, input_level)

				var/load = min(input, input_available) // charge at set rate, limited to spare capacity

				add_charge(load * MESSRATE)	// increase the charge of the cells

				terminal.add_load(load) // add the load to the terminal side network

			else					// If the cells are full
				getting_input = FALSE		// We're no longer actually getting input, there's no space!

		else
			if(input_on && input_available > 0) //We want input and there's power in the network, start getting input!
				getting_input = TRUE
	else
		getting_input = FALSE //No terminal or we DON'T want input

	//outputting
	if(output_on)
		if(outputting)
			var/charge = get_current_charge()
			output_used = min(charge / MESSRATE, output_level)		//limit output to that stored

			if (add_avail(output_used))				// add output to powernet if it exists (MESS side)
				remove_charge(output_used * MESSRATE) // reduce the storage (may be recovered in /restore() if excessive)
			else
				outputting = FALSE //No powernet, abort!

			if(output_used < 0.0001) // Barely outputting anything, or output is disabled
				outputting = FALSE
				investigate_log("SMES lost power and turned <font color='red'>off</font>", INVESTIGATE_SINGULO)
				investigate_log("SMES lost power and turned <font color='red'>off</font>", INVESTIGATE_SUPERMATTER) // yogs - so supermatter investigate is useful
		 //We want to output, we have more charge than we want to output, and we want to output more than 0
		else if(output_on && get_current_charge() > output_level && output_level > 0)
			outputting = TRUE
		else
			output_used = 0 //Didn't actually output anything, reset last output
	else
		outputting = FALSE //We don't want to output

	// only update icon if state changed
	//Did the % charge change?
	var/current_percentage = 0
	if(get_max_charge() > 0)
		current_percentage = get_current_charge() / get_max_charge() * 100
	if(last_percent != current_percentage)
		update_icon()
	//Did we start/stop getting input/outputting?
	if(last_charge != getting_input || last_output != outputting)
		update_icon()

/obj/machinery/power/battery_bank/proc/restore()
	if(stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.netexcess		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(output_used, excess)				// clamp it to how much was actually output by this MESS last ptick


	var/remaining_capacity = get_max_charge() - get_current_charge()

	excess = min(remaining_capacity / MESSRATE, excess)	// for safety, also limit recharge by space capacity of MESS (shouldn't happen)

	// now recharge this amount

	var/charge_level = get_current_charge() / get_max_charge() * 100

	add_charge(excess * MESSRATE)  // restore unused power
	powernet.netexcess -= excess		// remove the excess from the powernet, so later MESS's don't try to use it

	output_used -= excess

	if(charge_level != get_current_charge() / get_max_charge() * 100) //if needed updates the icons overlay
		update_icon()
	return
	
/obj/machinery/power/battery_bank/proc/log_status(mob/user)
	investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Charge: [get_current_charge()] | Output-mode: [output_on?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_on?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [user ? key_name(user) : "outside forces"]", INVESTIGATE_SINGULO)
	investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Charge: [get_current_charge()] | Output-mode: [output_on?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_on?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [user ? key_name(user) : "outside forces"]", INVESTIGATE_SUPERMATTER) // yogs - so supermatter investigate is useful

/obj/machinery/power/battery_bank/CtrlClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	output_on = !output_on
	log_status(user)
	update_icon()

/obj/machinery/power/battery_bank/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	input_on = rand(0,1)
	getting_input = input_on
	output_on = rand(0,1)
	outputting = output_on
	output_level = rand(0, output_level_max)
	input_level = rand(0, input_level_max)

	var/amount_to_steal = rand(0, get_current_charge() / severity)
	remove_charge(amount_to_steal)

	update_icon()
	log_status()

/obj/machinery/power/battery_bank/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BatteryBank", name, ui_x, ui_y, master_ui, state)
		ui.open()


/*

	SECTIONS

*/
/obj/machinery/power/battery_bank_section
	name = "modular energy storage system extension"
	icon = 'icons/obj/battery_bank.dmi'

	density = TRUE

	var/obj/machinery/power/battery_bank/master
	var/list/cells = list()

/obj/machinery/power/battery_bank_section/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/battery_bank_cell))
		return ..()
	if(cells.len >= (MAX_CELLS / 2))
		to_chat(user, "<span class='warning'>[src] can't fit any more battery modules!</span>")
		return
	
	I.forceMove(src)
	cells += I
	update_icon()

/obj/machinery/power/battery_bank_section/update_icon()
	..()
	cut_overlays()
	if(cells.len > (MAX_CELLS / 2))
		stack_trace("Battery bank has more than [MAX_CELLS] cells!")
		return

	for(var/i = 0, i < cells.len, i++)
		var/obj/item/battery_bank_cell/cell = cells[i + 1]
		if(!istype(cell))
			continue
		var/percent = cell.percent()
		if(percent > 80)
			add_overlay("[icon_state]-[i + 1]-full")
		else if(percent > 1)
			add_overlay("[icon_state]-[i + 1]-half")
		else
			add_overlay("[icon_state]-[i + 1]-empty")


/obj/machinery/power/battery_bank_section/left
	icon_state = "left"

/obj/machinery/power/battery_bank_section/right
	icon_state = "right"


#undef MAX_CELLS
#undef MESSRATE
