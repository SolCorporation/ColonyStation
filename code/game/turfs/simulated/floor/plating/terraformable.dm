/turf/open/floor/plating/asteroid/terraformable //Turf for terraforming, starting turf on the station.
	name = "sand"
	baseturfs = /turf/open/floor/plating/asteroid/terraformable
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	icon_plating = "asteroid"
	planetary_atmos = FALSE
	initial_gas_mix = PLANET_DEFAULT_ATMOS

	light_power = 0.25

/turf/open/floor/plating/asteroid/terraformable/Initialize()
	GLOB.terraformable_turfs += src

	air = SSterraforming.mix
	update_light()

	..()

/turf/open/floor/plating/asteroid/terraformable/Destroy()
	GLOB.terraformable_turfs -= src
	..()

/turf/open/floor/plating/planet_atmos
	initial_gas_mix = PLANET_DEFAULT_ATMOS