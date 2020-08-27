/obj/machinery/exploration/machines/acid_bath
	name = "acid bath"
	desc = "Learn science by submerging them in acid"
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner_off"

	act = "acid"
	specific = "hcl"



/obj/machinery/exploration/machines/acid_bath/ui_data()
	var/list/data = ..()

	data["goodName"] = "Acid Bath Container"


	data["specifics"] += list(list("ourSpecific" = "hcl", "specificName" = "Light Acid Bath"))
	data["specifics"] += list(list("ourSpecific" = "carb", "specificName" = "Heavy Acid Bath"))

	return data


/obj/machinery/exploration/machines/acid_bath/update_icon()
	if(running)
		icon_state = "card_scanner"
	else
		icon_state = initial(icon_state)