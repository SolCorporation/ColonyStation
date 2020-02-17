/datum/job/android
	title = "Android"
	flag = ANDROID
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "the Crew"	//Nodrak
	selection_color = "#ddffdd"
	minimal_player_age = 21
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW

	display_order = JOB_DISPLAY_ORDER_CYBORG


/datum/job/android/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	..(H)
	H.set_species(/datum/species/android)