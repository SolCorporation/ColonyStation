/obj/item/organ/eyes/android
	name = "android photon sensors"
	desc = "A pair of experimental photon sensors. They function identically to human eyes."
	//lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	//actions_types = list(/datum/action/item_action/organ_action/use)

/*
/obj/item/organ/eyes/android/ui_action_click()
	var/datum/species/android/S = owner.dna.species
	if(S.charge < ANDROID_LEVEL_FED)
		return
	sight_flags = initial(sight_flags)
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			sight_flags &= ~SEE_BLACKNESS
	owner.update_sight()
*/

/obj/item/organ/eyes/android/on_life()
	. = ..()
	if(!isandroid(owner))
		qdel(src) //these eyes depend on being inside a android
		return

/obj/item/organ/lungs/android
	name = "android respirator"
	desc = "An advanced respirator. While androids do not need oxygen, this filters out harmful gasses from the androids interior."
	icon_state = "lungs-c"

	safe_oxygen_min = 0
	safe_toxins_max = 15
	gas_stimulation_min = INFINITY //fucking filters removing my stimulants

	//Cold!
	cold_level_1_threshold = 0
	cold_level_1_damage = 0
	cold_level_2_threshold = 0
	cold_level_2_damage = 0
	cold_level_3_threshold = 0
	cold_level_3_damage = 0
	//Hot!
	heat_level_1_threshold = INFINITY
	heat_level_2_threshold = INFINITY
	heat_level_3_threshold = INFINITY

/obj/item/organ/tongue/android
	name = "vocal oscillator "
	desc = "A mechanical contraption that creates sound waves mimicing voice."
	icon_state = "tonguerobot"
	say_mod = "intones"
	taste_sensitivity = 0
	modifies_speech = TRUE

/obj/item/organ/tongue/android/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT