/obj/item/disk/fuel_mix
	name = "fusion fuel mix"
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.

	var/deuteriumMix = 50
	var/tritiumMix = 50
	var/list/additives = list()

/obj/item/disk/fuel_mix/default
	name = "SolCorp Standard Mix"
	deuteriumMix = 80
	tritiumMix = 20



/datum/fuel_additive
	var/name = "TEST"
	var/desc = "TEST"

/datum/fuel_additive/proc/onAdded()
	return

/datum/fuel_additive/proc/onRemove()
	return