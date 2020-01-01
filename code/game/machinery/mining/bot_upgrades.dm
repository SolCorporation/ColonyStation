/obj/item/mining_upgrade
	name = "circuit board"
	desc = "An upgrade for the Automatic Extraction Drones, hit the drone with this to apply."
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/mine_bot_upgrade/upgrade = new /datum/mine_bot_upgrade()

/obj/item/mining_upgrade/cargo1
	upgrade = new /datum/mine_bot_upgrade/cargo1()

/obj/item/mining_upgrade/adv_sensor
	upgrade = new /datum/mine_bot_upgrade/adv_sensor()

/obj/item/mining_upgrade/regen_drilling
	upgrade = new /datum/mine_bot_upgrade/regenerative_drilling()

/obj/item/mining_upgrade/ceramic_drill
	upgrade = new /datum/mine_bot_upgrade/ceramic_drill()

/obj/item/mining_upgrade/lightweight_alloy
	upgrade = new /datum/mine_bot_upgrade/lightweight_alloy()

/obj/item/mining_upgrade/Initialize()
	name = "[upgrade.name] - AED Upgrade"
	..()

/obj/item/mining_upgrade/examine(mob/user)
	. = ..()
	. += "<span>[upgrade.desc]</span>"


/datum/mine_bot_upgrade
	var/name = "TEST"
	var/desc = "BUG"
/datum/mine_bot_upgrade/proc/OnApply(obj/machinery/mining/bot/bot)
	return

/datum/mine_bot_upgrade/proc/OnRemove(obj/machinery/mining/bot/bot)
	return

/datum/mine_bot_upgrade/cargo1
	name = "Reinforced Cargo Hull"
	desc = "Adds 15 extra cargo slots"

/datum/mine_bot_upgrade/cargo1/OnApply(obj/machinery/mining/bot/bot)
	bot.maxCargo += 15

/datum/mine_bot_upgrade/cargo1/OnRemove(obj/machinery/mining/bot/bot)
	bot.maxCargo -= 15

/datum/mine_bot_upgrade/regenerative_drilling
	name = "Regenerative Drilling"
	desc = "Reduces power usage by 100 units"

/datum/mine_bot_upgrade/regenerative_drilling/OnApply(obj/machinery/mining/bot/bot)
	bot.powerUsage -= 100

/datum/mine_bot_upgrade/regenerative_drilling/OnRemove(obj/machinery/mining/bot/bot)
	bot.powerUsage += 100

/datum/mine_bot_upgrade/adv_sensor
	name = "Advanced Mineral Sensor"
	desc = "Allows the drone to gather materials such as diamond, titanium and uranium."

/datum/mine_bot_upgrade/adv_sensor/OnApply(obj/machinery/mining/bot/bot)
	bot.possibleOres += /obj/item/stack/ore/uranium
	bot.possibleOres += /obj/item/stack/ore/diamond
	bot.possibleOres += /obj/item/stack/ore/titanium

/datum/mine_bot_upgrade/adv_sensor/OnRemove(obj/machinery/mining/bot/bot)
	bot.possibleOres -= /obj/item/stack/ore/uranium
	bot.possibleOres -= /obj/item/stack/ore/diamond
	bot.possibleOres -= /obj/item/stack/ore/titanium

/datum/mine_bot_upgrade/ceramic_drill
	name = "Ceramic Drill"
	desc = "Increases the amount of ore per cycle by 1"

/datum/mine_bot_upgrade/ceramic_drill/OnApply(obj/machinery/mining/bot/bot)
	bot.oresPerCycle += 1

/datum/mine_bot_upgrade/ceramic_drill/OnRemove(obj/machinery/mining/bot/bot)
	bot.oresPerCycle -= 1

/datum/mine_bot_upgrade/lightweight_alloy
	name = "Lightweight Alloy"
	desc = "Decreases the mining delay by 2.5 seconds."

/datum/mine_bot_upgrade/ceramic_drill/OnApply(obj/machinery/mining/bot/bot)
	bot.miningCooldown -= 25

/datum/mine_bot_upgrade/ceramic_drill/OnRemove(obj/machinery/mining/bot/bot)
	bot.miningCooldown += 25