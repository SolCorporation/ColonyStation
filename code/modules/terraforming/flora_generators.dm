/obj/structure/flora_spawner
	name = "Small Fauna Generator"
	var/possibleSpawns = list(/obj/structure/flora/bush, /obj/structure/flora/ausbushes/genericbush, /obj/structure/flora/ausbushes/reedbush,
	/obj/structure/flora/ausbushes/fullgrass)
	var/range = 4
	var/spawnProbability = 7
	//invisibility = 70

/obj/structure/flora_spawner/Initialize()
	addtimer(CALLBACK(src, .proc/Create), 100)
	..()

/obj/structure/flora_spawner/proc/Create()

	for(var/turf/open/floor/plating/asteroid/terraformable/ourT in orange(range))
		if(prob(spawnProbability))
			var/ourObj = pick(possibleSpawns)
			new ourObj(ourT)

	qdel(src)
