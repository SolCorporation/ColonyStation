/obj/machinery/exploration/machines/electrifier
	name = "electrification device"
	desc = "Learn science by running electricity through them"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "doppler-off"

	act = "electrify"
	specific = "5v"



/obj/machinery/exploration/machines/electrifier/ui_data()
	var/list/data = ..()

	data["goodName"] = "Electrification Experimentor"


	data["specifics"] += list(list("ourSpecific" = "5v", "specificName" = "5 Volts"))
	data["specifics"] += list(list("ourSpecific" = "120v", "specificName" = "120 Volts"))

	return data


/obj/machinery/exploration/machines/electrifier/update_icon()
	if(running)
		icon_state = "doppler"
	else
		icon_state = initial(icon_state)