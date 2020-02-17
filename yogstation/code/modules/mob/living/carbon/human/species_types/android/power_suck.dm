/datum/species/android/spec_AltClickOn(atom/A,H)
	return drain_power_from(H, A)

/datum/species/android/proc/drain_power_from(mob/living/carbon/human/H, atom/A)
	if(!istype(H) || !A)
		return FALSE

	if(draining)
		to_chat(H,"<span class='info'>CONSUME protocols can only be used on one object at any single time.</span>")
		return FALSE
	if(!A.can_consume_power_from())
		return FALSE //if it returns text, we want it to continue so we can get the error message later.

	draining = TRUE

	var/siemens_coefficient = 1

	if(H.reagents.has_reagent("teslium"))
		siemens_coefficient *= 1.5

	if (charge >= max_charge - 25) //just to prevent spam a bit
		to_chat(H,"<span class='notice'>CONSUME protocol reports no need for additional power at this time.</span>")
		draining = FALSE
		return TRUE

	if(H.gloves)
		if(!H.gloves.siemens_coefficient)
			to_chat(H,"<span class='info'>NOTICE: [H.gloves] prevent electrical contact - CONSUME protocol aborted.</span>")
			draining = FALSE
			return TRUE
		else
			if(H.gloves.siemens_coefficient < 1)
				to_chat(H,"<span class='info'>NOTICE: [H.gloves] are interfering with electrical contact - advise removal before activating CONSUME protocol.</span>")
			siemens_coefficient *= H.gloves.siemens_coefficient

	H.face_atom(A)
	H.visible_message("<span class='warning'>[H] starts placing their hands on [A]...</span>", "<span class='warning'>You start placing your hands on [A]...</span>")
	if(!do_after(H, 20, target = A))
		to_chat(H,"<span class='info'>CONSUME protocol aborted.</span>")
		draining = FALSE
		return TRUE

	to_chat(H,"<span class='info'>Extracutaneous implants detect viable power source. Initiating CONSUME protocol.</span>")

	var/done = FALSE
	var/drain = 150 * siemens_coefficient

	var/cycle = 0
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.attach(A)
	spark_system.set_up(5, 0, A)



	while(!done)
		cycle++
		var/nutritionIncrease = drain * electricity_to_nutriment

		if(charge + nutritionIncrease > max_charge)
			nutritionIncrease = CLAMP(max_charge - charge, ANDROID_LEVEL_NONE, max_charge) //if their nutrition goes up from some other source, this could be negative, which would cause bad things to happen.
			drain = nutritionIncrease / electricity_to_nutriment

		if (do_after(H,5, target = A))
			var/can_drain = A.can_consume_power_from()
			if(!can_drain || istext(can_drain))
				if(istext(can_drain))
					to_chat(H,can_drain)
				done = TRUE
			else
				playsound(A.loc, "sparks", 50, 1)
				if(prob(75))
					spark_system.start()
				var/drained = A.consume_power_from(drain)
				if(drained < drain)
					to_chat(H,"<span class='info'>[A]'s power has been depleted, CONSUME protocol halted.</span>")
					done = TRUE
				charge = CLAMP(charge + (drained * electricity_to_nutriment), ANDROID_LEVEL_NONE, max_charge)

				if(!done)
					if(charge > (max_charge - 25))
						to_chat(H,"<span class='info'>CONSUME protocol complete. Physical nourishment refreshed.</span>")
						done = TRUE
					else if(!(cycle % 4))
						var/nutperc = round((charge / max_charge) * 100)
						to_chat(H,"<span class='info'>CONSUME protocol continues. Current satiety level: [nutperc]%.</span>")
		else
			done = TRUE
	qdel(spark_system)
	draining = FALSE
	return TRUE
