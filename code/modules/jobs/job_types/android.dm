/datum/job/android
	title = "Android"
	flag = ANDROID
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	department_flag = ENGSEC
	faction = "Station"


	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EVA,
			            ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS, ACCESS_MINISAT, ACCESS_MECH_ENGINE,
			            ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM)
	outfit = /datum/outfit/job/android
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

/datum/outfit/job/android
	name = "Android"
	jobtype = /datum/job/android
	uniform = /obj/item/clothing/under/color/random