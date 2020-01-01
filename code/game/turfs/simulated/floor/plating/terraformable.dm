/turf/open/floor/plating/asteroid/terraformable //Turf for terraforming, starting turf on the station.
	name = "sand"
	baseturfs = /turf/open/floor/plating/asteroid/terraformable
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	icon_plating = "asteroid"
	planetary_atmos = TRUE
	initial_gas_mix = PLANET_DEFAULT_ATMOS

/turf/open/floor/plating/asteroid/terraformable/Initialize()
	GLOB.terraformable_turfs += src

	if(requires_activation)
		SSair.add_to_active(src)

	..()

/turf/open/floor/plating/asteroid/terraformable/Destroy()
	GLOB.terraformable_turfs -= src
	..()

/turf/open/floor/plating/planet_atmos
	initial_gas_mix = PLANET_DEFAULT_ATMOS