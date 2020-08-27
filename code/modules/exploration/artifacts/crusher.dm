/obj/machinery/exploration/machines/crusher
	name = "crushing machine"
	desc = "Learn science by crushing things!"
	icon = 'icons/obj/economy.dmi'
	icon_state = "coinpress0"

	act = "crush"
	specific = "low"



/obj/machinery/exploration/machines/crusher/ui_data()
	var/list/data = ..()

	data["goodName"] = "Crusher"


	data["specifics"] += list(list("ourSpecific" = "low", "specificName" = "Low Pressure"))
	data["specifics"] += list(list("ourSpecific" = "high", "specificName" = "High Pressure"))

	return data


/obj/machinery/exploration/machines/crusher/update_icon()
	if(running)
		icon_state = "coinpress1"
	else
		icon_state = initial(icon_state)