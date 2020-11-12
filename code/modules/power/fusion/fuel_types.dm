//Contains fuel datums + the canister

/obj/item/fuel_rod
	name = "fuel rod"
	desc = "Contains isotopes of the fuel needed for a fusion reactor."
	icon = 'yogstation/icons/obj/machines/antimatter.dmi'
	icon_state = "jar"
	density = FALSE
	anchored = FALSE
	force = 8
	throwforce = 10
	throw_speed = 1
	throw_range = 2

	///Reference to the type of fuel we contain
	var/datum/fuel_type/fuel
	///How much of the fuel do we have?
	var/fuel_amount = 0
	///Max amount of fuel
	var/max_fuel = 10000

/obj/item/fuel_rod/Initialize()
	name += " ([fuel.name])"
	fuel_amount = max_fuel
	return ..()

/obj/item/fuel_rod/examine(mob/user)
	. = ..()
	. += "<span class='info'>It is [round((fuel_amount / max_fuel) * 100, 0.1)]% full.</span>"
	. += "<span class='info'>This one contains [fuel ? fuel.name : "nothing"].</span>"

/obj/item/fuel_rod/proc/use_fuel(amount)
	if(fuel_amount < amount)
		var/fuel_amount_cache = fuel_amount
		fuel_amount = 0
		fuel = null
		update_icon()
		return fuel_amount_cache
	fuel_amount -= amount
	return amount

/* Readd when we get the sprites
/obj/item/fuel_rod/update_icon()
	
	cut_overlays()
	if(!fuel)
		add_overlay("empty")
	else
		add_overlay(fuel.overlay)
	*/

/obj/item/fuel_rod/default
	fuel = new /datum/fuel_type/deuterium()
	fuel_amount = 1000

/datum/fuel_type
	///User visible name
	var/name = "I am a bug!"

	///The icon state of the overlay to lay on the fuel rod
	var/overlay = "overlay_iconstate"


	///How much heat do we make per unit expended?
	var/heat_multiplier = 1
	///How muhc power do we make per unit expended?
	var/power_multiplier = 1

///If we have a special effect when we are used (Radiation for example)
/datum/fuel_type/proc/special_effect()
	return FALSE

/datum/fuel_type/deuterium
	name = "deuterium"

	overlay = "deut"

	heat_multiplier = 30
	power_multiplier = 10

