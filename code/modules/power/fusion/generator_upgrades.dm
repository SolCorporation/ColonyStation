/obj/item/generator_upgrade
	name = "circuit board"
	desc = "An upgrade for a thermo generator just hit the generator with this to apply."
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/neutron_upgrade/upgrade = new /datum/generator_upgrade()


/obj/item/generator_upgrade/Initialize()
	name = "[upgrade.name] - Neutron Injector Upgrade"
	..()

/obj/item/generator_upgrade/examine(mob/user)
	. = ..()
	. += "<span>[upgrade.desc]</span>"


/datum/generator_upgrade
	var/name = "TEST"
	var/desc = "BUG"
/datum/generator_upgrade/proc/OnApply(obj/machinery/power/fusion_gen/G)
	return

/datum/generator_upgrade/proc/OnRemove(obj/machinery/power/fusion_gen/G)
	return
