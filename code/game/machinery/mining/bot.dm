GLOBAL_LIST_EMPTY(mining_bots)

/obj/machinery/mining/bot
	name = "Automated Extraction Drill"
	desc = "An automated drill, that extracts minerals based on a set pattern"

	icon = 'icons/obj/mining_drill.dmi'
	icon_state = "drill-off"
	density = TRUE

	circuit = /obj/item/circuitboard/machine/mining_bot


	var/list/cargo = list()
	var/maxCargo = 25
	var/possibleOres = list(/obj/item/stack/ore/iron, /obj/item/stack/ore/glass, /obj/item/stack/ore/plasma, /obj/item/stack/ore/silver, /obj/item/stack/ore/gold)
	var/oresPerCycle = 1

	var/miningCooldown = 100
	var/miningTimer

	var/list/appliedUpgrades = list()
	var/maxUpgrades = 3

	//Power Usage per mined ore
	var/powerUsage = 400

	var/mining = FALSE
	var/obj/item/stock_parts/cell/battery

	var/obj/item/radio/radio
	var/radio_channel = RADIO_CHANNEL_SUPPLY

/obj/machinery/mining/bot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/mining_upgrade))
		var/obj/item/mining_upgrade/upgrade = W
		if(appliedUpgrades.len >= maxUpgrades)
			to_chat(user, "<span class='warning'>There is no more room for upgrades!</span>")
			return
		appliedUpgrades += upgrade
		upgrade.forceMove(src)
		upgrade.upgrade.OnApply(src)

	else if(istype(W, /obj/item/stock_parts/cell))
		battery.forceMove(get_turf(src))
		battery = W
		W.forceMove(src)
		to_chat(user, "<span class='notice'>Battery replaced! New max charge is [battery.maxcharge]</span>")
	else
		..()


/obj/machinery/mining/bot/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(appliedUpgrades.len)
		I.play_tool_sound(src, 100)
		for(var/obj/item/mining_upgrade/upgrades in appliedUpgrades)
			upgrades.forceMove(get_turf(src))
			upgrades.upgrade.OnRemove(src)
		appliedUpgrades = list()
	else
		to_chat(user, "<span class='notice'>There are no upgrades currently installed.</span>")

/obj/machinery/mining/bot/Initialize()
	name += " ([num2hex(rand(1,65535), -1)])"
	GLOB.mining_bots += src
	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_cargo
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()
	battery = new /obj/item/stock_parts/cell/high(src)
	..()

/obj/machinery/mining/bot/Destroy()
	GLOB.mining_bots -= src
	QDEL_NULL(radio)
	..()

/obj/machinery/mining/bot/process()
	if(miningTimer < world.time && mining)
		Mine()


/obj/machinery/mining/bot/proc/Unload()
	for(var/obj/item/I in cargo)
		I.forceMove(get_turf(src))
	cargo = list()

/obj/machinery/mining/bot/proc/Mine()
	if(!mining)
		return
	if(!battery.use(powerUsage))
		stopMining()
		var/message = "Battery depleted. Operator interaction required."
		radio.talk_into(src, message, radio_channel)
		return

	for(var/i = 0, i < oresPerCycle, i++)
		if(cargo.len >= maxCargo)
			stopMining()
			var/message = "Cargo Hold full. Operator interaction required."
			radio.talk_into(src, message, radio_channel)
			continue
		var/obj/item/ore = pick(possibleOres)
		ore = new ore(src)
		cargo += ore

	miningTimer = world.time + miningCooldown

/obj/machinery/mining/bot/proc/goMine()
	var/message = "Cargo hold full. Unable to start mining"
	if(cargo.len >= maxCargo)
		radio.talk_into(src, message, radio_channel)
		return
	if(battery.charge < powerUsage)
		message = "Not enough battery to begin mining."
		radio.talk_into(src, message, radio_channel)
		return
	message = "Initiating Mining Operation."
	radio.talk_into(src, message, radio_channel)
	icon_state = "drill-on"
	density = FALSE
	mining = TRUE
	miningTimer = world.time + miningCooldown
	START_PROCESSING(SSobj, src)

/obj/machinery/mining/bot/proc/stopMining()
	var/message = "Stopping Mining Operation."
	radio.talk_into(src, message, radio_channel)
	flick("drill-retract", src)
	icon_state = "drill-off"
	density = TRUE
	mining = FALSE
	STOP_PROCESSING(SSobj, src)

/obj/machinery/mining/bot/proc/toggleMining()
	if(mining)
		stopMining()
	else
		goMine()

/obj/machinery/mining/bot/examine(mob/user)
	. = ..()
	. += "<span>Installed Upgrades:</span>"
	for(var/obj/item/mining_upgrade/upgradeItem in appliedUpgrades)
		. += "<span>[upgradeItem.upgrade.name] installed</span>"
	. += "<span>([appliedUpgrades.len]/[maxUpgrades])</span>"

/obj/item/circuitboard/machine/mining_bot
	name = "Automated Extraction Drone (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/mining/bot
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 2)
