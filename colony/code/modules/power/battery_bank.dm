//TODO: Circuits

#define MESSRATE 0.05			// rate of internal charge to external power

#define MAX_CELLS 4

/obj/machinery/power/battery_bank
	name = "modular energy storage system controller"
	desc = "A modular energy storage system (MESS)"

	icon = 'icons/obj/battery_bank.dmi'
	icon_state = "mid"
	density = TRUE
	use_power = NO_POWER_USE

	ui_x = 340
	ui_y = 350

	var/capacity = 5e6 // maximum charge
	var/charge = 0 // actual charge

	var/input_attempt = TRUE // TRUE = attempting to charge, FALSE = not attempting to charge
	var/inputting = TRUE // TRUE = actually inputting, FALSE = not inputting
	var/input_level = 50000 // amount of power the SMES attempts to charge by
	var/input_level_max = 200000 // cap on input_level
	var/input_available = 0 // amount of charge available from input last tick

	var/output_attempt = TRUE // TRUE = attempting to output, FALSE = not attempting to output
	var/outputting = TRUE // TRUE = actually outputting, FALSE = not outputting
	var/output_level = 50000 // amount of power the SMES attempts to output
	var/output_level_max = 200000 // cap on output_level
	var/output_used = 0 // amount of power actually outputted. may be less than output_level if the powernet returns excess power

	var/obj/machinery/power/terminal/terminal = null

	var/obj/machinery/power/battery_bank_section/L
	var/obj/machinery/power/battery_bank_section/R


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
		break
	T = get_step(src, EAST)
	for(var/obj/machinery/power/battery_bank_section/S in T)
		R = S
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

/obj/machinery/power/battery_bank/update_icon()
	..()
	cut_overlays()
	if(inputting && input_attempt)
		add_overlay("up_arrow")
	else if(input_attempt && !inputting && !outputting)
		add_overlay("neutral_arrow")
	else if(!inputting && outputting)
		add_overlay("down_arrow")

	var/charge = get_charge()
	var/max_charge = get_total_charge()

	var/percent = charge / max_charge * 100

	if(percent > 67)
		add_overlay("right_overlay_high")
	else if(percent > 34)
		add_overlay("right_overlay_med")
	else
		add_overlay("right_overlay_low")

	
/obj/machinery/power/battery_bank/proc/get_charge()
	var/list/all_cells = L.cells + R.cells
	var/total_charge = 0

	for(var/obj/item/stock_parts/cell/cell in all_cells)
		total_charge += cell.charge
	return total_charge

/obj/machinery/power/battery_bank/proc/get_total_charge()
	var/list/all_cells = L.cells + R.cells
	var/total_charge = 0

	for(var/obj/item/stock_parts/cell/cell in all_cells)
		total_charge += cell.maxcharge
	return total_charge

/obj/machinery/power/battery_bank/proc/make_terminal(turf/T)
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
	var/last_percent = get_charge / get_total_charge * 100
	var/last_chrg = inputting
	var/last_onln = outputting

	//inputting
	if(terminal && input_attempt)
		input_available = terminal.surplus()

		if(inputting)
			if(input_available > 0)		// if there's power available, try to charge

				var/load = min(min((capacity-charge) / MESSRATE, input_level), input_available)		// charge at set rate, limited to spare capacity

				charge += load * MESSRATE	// increase the charge

				terminal.add_load(load) // add the load to the terminal side network

			else					// if not enough capcity
				inputting = FALSE		// stop inputting

		else
			if(input_attempt && input_available > 0)
				inputting = TRUE
	else
		inputting = FALSE

	//outputting
	if(output_attempt)
		if(outputting)
			output_used = min( charge/SMESRATE, output_level)		//limit output to that stored

			if (add_avail(output_used))				// add output to powernet if it exists (smes side)
				charge -= output_used*SMESRATE		// reduce the storage (may be recovered in /restore() if excessive)
			else
				outputting = FALSE

			if(output_used < 0.0001)		// either from no charge or set to 0
				outputting = FALSE
				investigate_log("SMES lost power and turned <font color='red'>off</font>", INVESTIGATE_SINGULO)
				investigate_log("SMES lost power and turned <font color='red'>off</font>", INVESTIGATE_SUPERMATTER) // yogs - so supermatter investigate is useful
		else if(output_attempt && charge > output_level && output_level > 0)
			outputting = TRUE
		else
			output_used = 0
	else
		outputting = FALSE

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		update_icon()


//SECTIONS
/obj/machinery/power/battery_bank_section
	name = "modular energy storage system extension"

	var/list/cells = list()

/obj/machinery/power/battery_bank_section/update_icon()
	..()
	cut_overlays()
	if(cells.len > MAX_CELLS)
		stack_trace("Battery bank has more than [MAX_CELLS] cells!")
		return

	for(var/i = 1, i <= cells.len, i++)
		var/obj/item/stock_parts/cell/cell = cells[i]
		if(!istype(cell))
			continue
		var/percent = cell.percent()
		if(percent > 80)
			add_overlay("[icon_state]_[i]_full")
		else if(percent > 1)
			add_overlay("[icon_state]_[i]_half")
		else
			add_overlay("[icon_state]_[i]_empty")


/obj/machinery/power/battery_bank_section/left
	icon_state = "left"

/obj/machinery/power/battery_bank_section/right
	icon_state = "right"


#undef MAX_CELLS
