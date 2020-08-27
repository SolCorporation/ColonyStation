/turf/closed/indestructible/r_wall
	name = "ultra reinforced wall"
	desc = "The laws of physics prevent you from getting through here"
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall"
	canSmoothWith = list(/turf/closed/indestructible/r_wall)

/obj/machinery/door/poddoor/super_though
	name = "ancient blast door"
	max_integrity = 25000
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)

/obj/item/disk/holodisk/ancient_bunker/outside
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
	NAME Guard 1
	DELAY 20
	SAY Why the hell are they banging on the door? What's wrong out there?
	DELAY 30
	NAME Guard 2
	SAY I don't know man, it's freaking me out!
	DELAY 30
	SOUND sound/weapons/lasercannonfire.ogg
	DELAY 30
	SOUND sound/weapons/lasercannonfire.ogg
	DELAY 30
	NAME Guard 1
	SAY TURN THE TURRET OFF!
	DELAY 40
	SOUND sound/weapons/lasercannonfire.ogg
	DELAY 60
	SOUND sound/weapons/lasercannonfire.ogg
	DELAY 60
	SOUND sound/weapons/lasercannonfire.ogg
	DELAY 60
	SOUND sound/weapons/lasercannonfire.ogg
	DELAY 60"}