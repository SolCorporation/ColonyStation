#define TRITUM_SETTING 1
#define DEUTERIUM_SETTING 0

/obj/machinery/power/neutron_inj
	name = "neutron injector"
	desc = "This little thing injects neutrons into hydrogen, so the reactor can use them for fuel!"
	icon = 'goon/icons/obj/fusion_machines.dmi'
	icon_state = "neutinj"

	density = TRUE

	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 5000

	var/running = FALSE

	var/setting = TRITUM_SETTING

	var/list/upgrades = list()

	var/fuelPerProcess = 1

	var/obj/machinery/power/fusion/core/reactor

/obj/machinery/power/neutron_inj/Initialize()
	name += " ([num2hex(rand(1,65535), -1)])"
	for(var/obj/machinery/power/fusion/core/R in orange(15, src))
		reactor = R
	START_PROCESSING(SSobj, src)
	..()

/obj/machinery/power/neutron_inj/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/machinery/power/neutron_inj/proc/toggleFuel()
	if(setting == TRITUM_SETTING)
		setting = DEUTERIUM_SETTING
	else
		setting = TRITUM_SETTING

/obj/machinery/power/neutron_inj/process()
	if(reactor.injectingFuel && running)
		switch(setting)
			if(TRITUM_SETTING)
				reactor.tritium += fuelPerProcess
				if(reactor.tritium > 100)
					reactor.tritium = 100
			if(DEUTERIUM_SETTING)
				reactor.deuterium += fuelPerProcess
				if(reactor.deuterium > 100)
					reactor.deuterium = 100

/obj/machinery/power/neutron_inj/proc/toggleOn()
	running = !running
	if(running)
		use_power = ACTIVE_POWER_USE
		icon_state = "neutinjon"
	else
		use_power = IDLE_POWER_USE
		icon_state = "neutinj"

/obj/machinery/power/neutron_inj/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/neutron_upgrade))
		var/obj/item/neutron_upgrade/upgrade = W
		upgrades += upgrade
		upgrade.forceMove(src)
		upgrade.upgrade.OnApply(src)

/obj/machinery/power/neutron_inj/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(upgrades.len)
		I.play_tool_sound(src, 100)
		for(var/obj/item/neutron_upgrade/upgrades in upgrades)
			upgrades.forceMove(get_turf(src))
			upgrades.upgrade.OnRemove(src)
		upgrades = list()
	else
		to_chat(user, "<span class='notice'>There are no upgrades currently installed.</span>")