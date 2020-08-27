/obj/item/neutron_upgrade
	name = "circuit board"
	desc = "An upgrade for a Neutron Injector, just hit the injector with this to apply."
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/neutron_upgrade/upgrade = new /datum/neutron_upgrade()

/obj/item/neutron_upgrade/lens
	upgrade = new /datum/neutron_upgrade/particle_lens()


/obj/item/neutron_upgrade/Initialize()
	name = "[upgrade.name] - Neutron Injector Upgrade"
	..()

/obj/item/neutron_upgrade/examine(mob/user)
	. = ..()
	. += "<span>[upgrade.desc]</span>"


/datum/neutron_upgrade
	var/name = "TEST"
	var/desc = "BUG"
/datum/neutron_upgrade/proc/OnApply(obj/machinery/power/neutron_inj/I)
	return

/datum/neutron_upgrade/proc/OnRemove(obj/machinery/power/neutron_inj/I)
	return

/datum/neutron_upgrade/particle_lens
	name = "Additional Particle Lens"
	desc = "Increases fuel production amount by 0.5"

/datum/neutron_upgrade/particle_lens/OnApply(obj/machinery/power/neutron_inj/I)
	I.fuelPerProcess += 0.5

/datum/neutron_upgrade/particle_lens/OnRemove(obj/machinery/power/neutron_inj/I)
	I.fuelPerProcess -= 0.5