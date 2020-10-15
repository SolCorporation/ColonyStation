/obj/item/fuel_item
	name = "debug"
	desc = "Contains moles of X for a fuel compressor."
	icon = 'icons/obj/fusion_machines.dmi'
	icon_state = "fuel_container"
	density = FALSE
	anchored = FALSE
	force = 8
	throwforce = 10
	throw_speed = 1
	throw_range = 2

	///What kind of fuel does this contain?
	var/fuel_name = "deuterium"
	///How much of the fuel does this contain?
	var/fuel_amount = 0

/obj/item/fuel_item/examine(mob/user)
	. = ..()
	. += "<span class='info'>This one contains [fuel_amount] moles of [fuel_name].</span>"

/obj/item/fuel_item/deuterium
	name = "deuterium container"
	desc = "Contains deuterium fuel for a fuel compressor"

	fuel_amount = 20000


