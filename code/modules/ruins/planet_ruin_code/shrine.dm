/obj/structure/fluff/divine/shrine/shrine_ruin
	name = "\improper shrine"
	desc = "A shrine dedicated to a deity. You feel an... Aura, emanating from it"

	var/dispensed = FALSE

/obj/structure/fluff/divine/shrine/shrine_ruin/attack_hand(mob/user)
	var/list/pylon_list = list()

	for(var/obj/structure/fluff/divine/conduit/shrine_ruin/S in orange(10, src))
		if(S.active)
			pylon_list += S

	if(pylon_list.len >= 4)
		if(!dispensed)
			audible_message("<span class='warning'>\The [src] lights up briefly. When the light dies down, an artifact lies at it's base.")
			new /obj/item/artifact/easy(get_turf(src))
			dispensed = TRUE
		else
			audible_message("<span class='warning'>\The [src] fizzles and nothing happens.")

/obj/structure/fluff/divine/conduit/shrine_ruin
	var/active = FALSE

/obj/structure/fluff/divine/conduit/shrine_ruin/attack_hand(mob/user)
	if(!active)
		active = TRUE
		audible_message("<span class='warning'>An audible boom is heard from \the [src]</span>")