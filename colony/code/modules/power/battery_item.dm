/obj/item/battery_bank_cell
	name = "high-density power cell"
	desc = "A rechargeable electrochemical high-density power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	materials = list(MAT_METAL=700, MAT_GLASS=50)
	grind_results = list(/datum/reagent/lithium = 15, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	var/rigged = FALSE	// true if rigged to explode

/obj/item/battery_bank_cell/Initialize(mapload, override_maxcharge)
	. = ..()
	create_reagents(5, INJECTABLE | DRAINABLE)
	if (override_maxcharge)
		maxcharge = override_maxcharge
	charge = maxcharge
	desc += " This one has a rating of [DisplayEnergy(maxcharge)], and you should not swallow it."
	update_icon()


/obj/item/battery_bank_cell/update_icon()
	cut_overlays()
	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		add_overlay("cell-o2")
	else
		add_overlay("cell-o1")

/obj/item/battery_bank_cell/proc/percent()		// return % charge of cell
	return 100*charge/maxcharge

// use power from a cell
/obj/item/battery_bank_cell/use(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(charge < amount)
		return 0
	charge = (charge - amount)
	if(!istype(loc, /obj/machinery/power/apc))
		SSblackbox.record_feedback("tally", "cell_used", 1, type)
	return 1

// recharge the cell
/obj/item/battery_bank_cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge-charge,amount)
	charge += power_used
	return power_used

/obj/item/battery_bank_cell/examine(mob/user)
	. = ..()
	if(rigged)
		. += "<span class='danger'>This power cell seems to be faulty!</span>"
	else
		. += "The charge meter reads [round(src.percent() )]%."

/obj/item/battery_bank_cell/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is licking the electrodes of [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/battery_bank_cell/on_reagent_change(changetype)
	rigged = !isnull(reagents.has_reagent(/datum/reagent/toxin/plasma, 5)) //has_reagent returns the reagent datum
	..()


/obj/item/battery_bank_cell/proc/explode()
	var/turf/T = get_turf(src.loc)
	if (charge==0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge)/60)
	var/light_impact_range = round(sqrt(charge)/30)
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = FALSE
		corrupt()
		return
	//explosion(T, 0, 1, 2, 2)
	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	qdel(src)

/obj/item/battery_bank_cell/proc/corrupt()
	charge /= 2
	maxcharge = maxcharge / 2
	if (prob(10))
		rigged = TRUE //broken batterys are dangerous

/obj/item/battery_bank_cell/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	charge -= 1000 / severity
	if (charge < 0)
		charge = 0

/obj/item/battery_bank_cell/ex_act(severity, target)
	..()
	if(!QDELETED(src))
		switch(severity)
			if(2)
				if(prob(50))
					corrupt()
			if(3)
				if(prob(25))
					corrupt()


/obj/item/battery_bank_cell/blob_act(obj/structure/blob/B)
	ex_act(EXPLODE_DEVASTATE)

/* Cell variants*/
/obj/item/battery_bank_cell/empty/Initialize()
	. = ..()
	charge = 0
