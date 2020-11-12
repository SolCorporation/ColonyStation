/obj/machinery/power/fuel_compressor
	name = "fuel compressor"
	desc = "Used to compress fuel isotopes into a usable form. Injects the compressed isotopes into an inserted empty fuel rod. Uses purely mechanical forces and requires no power."
	icon = 'goon/icons/obj/fusion_machines.dmi'
	icon_state = "neutinj"

	density = TRUE

	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 5000

	var/obj/item/fuel_rod/inserted_rod
	var/progress = 0

	var/inserted_fuel = list()

/obj/machinery/power/fuel_compressor/Initialize()
	..()
	START_PROCESSING(SSobj, src)

/obj/machinery/power/fuel_compressor/examine(mob/user)
	. = ..()
	if(inserted_rod)
		. += "<span class='info'>It is [progress]% complete.</span>"
	else
		. += "<span class='info'>It is ready to have an empty fuel rod inserted.</span>"

	for(var/fuel in inserted_fuel)
		. += "<span class='info'>It has [inserted_fuel[fuel]] moles of [fuel] inserted.</span>"

/obj/machinery/power/fuel_compressor/process()
	if(!inserted_rod)
		return

	var/fuel_to_fill = inserted_rod.max_fuel - inserted_rod.fuel_amount 
	if(inserted_fuel[inserted_rod.fuel.name] < fuel_to_fill)
		inserted_rod.forceMove(get_turf(src))
		inserted_rod = null
		say("Unable to process fuel rod. Not enough [inserted_rod.fuel.name] fuel!")
		progress = 0
		update_icon()
		return
	if(progress >= 100)
		inserted_fuel[inserted_rod.fuel.name] -= fuel_to_fill
		inserted_rod.fuel_amount = inserted_rod.max_fuel
		inserted_rod.forceMove(get_turf(src))
		inserted_rod = null
		update_icon()
		audible_message("[src] chimes as it ejects a refilled fuel rod!")
		progress = 0
		return

	progress++

/obj/machinery/power/fuel_compressor/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/fuel_item))
		var/obj/item/fuel_item/fuel = W
		inserted_fuel[fuel.fuel_name] += fuel.fuel_amount
		visible_message("[src] accepts [fuel].")
		qdel(W)
		return
	if(istype(W, /obj/item/fuel_rod/default ))
		inserted_rod = W
		update_icon()
		W.forceMove(src)
		visible_message("[src] accepts [W].")
		return
	return ..()

/obj/machinery/power/fuel_compressor/update_icon()
	if(inserted_fuel)
		icon_state = "neutinjon"
	else 
		icon_state = "neutinj"

