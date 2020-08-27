/obj/machinery/terraformer_upgrades
	name = "terraformer upgrade housing"
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter-broken"
	desc = "An accessory to the terraformer, that accepts various upgrades."
	use_power = IDLE_POWER_USE
	idle_power_usage = 500
	active_power_usage = 500

	density = TRUE

	var/obj/machinery/terraformer/terra

	var/list/upgrades = list()

	var/maxUpgrades = 3

/obj/machinery/terraformer_upgrades/Initialize()
	for(var/obj/machinery/terraformer/T in orange(7, src))
		terra = T
	..()

/obj/machinery/terraformer_upgrades/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/terraform_upgrade))
		var/obj/item/terraform_upgrade/upgrade = W
		if(upgrades.len >= maxUpgrades)
			to_chat(user, "<span class='warning'>There is no more room for upgrades!</span>")
			return
		upgrades += upgrade
		upgrade.forceMove(src)
		upgrade.upgrade.OnApply(terra)
		terra.recalculateProperties()
	else
		..()

/obj/machinery/terraformer_upgrades/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(upgrades.len)
		I.play_tool_sound(src, 100)
		for(var/obj/item/terraform_upgrade/upgrade in upgrades)
			upgrade.forceMove(get_turf(src))
			upgrade.upgrade.OnRemove(terra)
		upgrades = list()
		terra.recalculateProperties()
	else
		to_chat(user, "<span class='notice'>There are no upgrades currently installed.</span>")





/obj/item/terraform_upgrade
	name = "circuit board"
	desc = "An upgrade for the terraformer, hit the upgrade housing to apply."
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/terraformer_upgrade/upgrade = new /datum/terraformer_upgrade()

/obj/item/terraform_upgrade/Initialize()
	name = "[upgrade.name] - Terraformer Upgrade"
	..()

/obj/item/terraform_upgrade/examine(mob/user)
	. = ..()
	. += "<span>[upgrade.desc]</span>"

/obj/item/terraform_upgrade/phasic_manipulation
	upgrade = new /datum/terraformer_upgrade/phasic_eff()

/obj/item/terraform_upgrade/plasma
	upgrade = new /datum/terraformer_upgrade/plasma_beaming()

/obj/item/terraform_upgrade/electromagnetic
	upgrade = new /datum/terraformer_upgrade/electromagnetic_infusing()

/datum/terraformer_upgrade
	var/name = "TEST"
	var/desc = "BUG"

/datum/terraformer_upgrade/proc/OnApply(obj/machinery/terraformer/T)
	return

/datum/terraformer_upgrade/proc/OnRemove(obj/machinery/terraformer/T)
	return

/datum/terraformer_upgrade/phasic_eff
	name = "Phasic Gas Manipulation"
	desc = "Reduces terraformer power usage by 25%"

/datum/terraformer_upgrade/phasic_eff/OnApply(obj/machinery/terraformer/T)
	T.base_power_usage = initial(T.base_power_usage) * 0.75

/datum/terraformer_upgrade/phasic_eff/OnRemove(obj/machinery/terraformer/T)
	T.base_power_usage = initial(T.base_power_usage)


/datum/terraformer_upgrade/plasma_beaming
	name = "Plasma Quantum Beaming"
	desc = "Allows the terraformer to produce plasma, a very flammable and very potent greenhouse gas."

/datum/terraformer_upgrade/plasma_beaming/OnApply(obj/machinery/terraformer/T)
	for(var/G in T.possibleGasses)
		var/datum/terraforming_gas/U = G
		if(U.gas == "plasma")
			U.unlocked = TRUE

/datum/terraformer_upgrade/plasma_beaming/OnRemove(obj/machinery/terraformer/T)
	for(var/G in T.possibleGasses)
		var/datum/terraforming_gas/U = G
		if(U.gas == "plasma")
			U.unlocked = FALSE

/datum/terraformer_upgrade/electromagnetic_infusing
	name = "Electromagnetic Infusion"
	desc = "The terraformer now produces an additional 0.1 moles of gas."

/datum/terraformer_upgrade/electromagnetic_infusing/OnApply(obj/machinery/terraformer/T)
	T.baseMoles += 0.1

/datum/terraformer_upgrade/electromagnetic_infusing/OnRemove(obj/machinery/terraformer/T)
	T.baseMoles -= 0.1