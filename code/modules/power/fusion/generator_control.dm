/obj/machinery/power/generator_control
	name = "turbine controller"
	desc = "The main control console for the turbines."
	icon = 'goon/icons/obj/fusion_control.dmi'
	icon_state = "cab3"

	density = TRUE


	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 500

	var/list/generators = list()

