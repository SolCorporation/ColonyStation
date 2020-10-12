

/obj/machinery/power/cooling_controller
	name = "coolant controller"
	desc = "The main control console for the cooling towers and condensers."
	icon = 'goon/icons/obj/fusion_control.dmi'
	icon_state = "cab2"

	density = TRUE
	var/temp
	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 500

	var/list/injectors = list()
