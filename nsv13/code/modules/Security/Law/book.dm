/obj/item/lawbook
	name = "Book of Laws"
	desc = "A standard printed space law book, although this one seems to resonate with an unknown power"
	icon = 'icons/obj/library.dmi'
	icon_state = "bookSpaceLaw"
	var/ui_crime_id = list()
	var/highest_code = null

/obj/item/lawbook/Initialize()
	. = ..()
	build_crime_list()

/obj/item/lawbook/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrimeBook")
		ui.status = UI_INTERACTIVE
		ui_crime_id = list()
		ui.autoupdate = TRUE
		ui.open()

/obj/item/lawbook/ui_status(mob/user)
	return UI_INTERACTIVE

/obj/item/lawbook/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/lawbook/ui_data(mob/user)
	var/data = list()
	if(ui_crime_id)
		for(var/C in ui_crime_id)
			var/datum/crime/crime = find_crime_object_from_type(C)
			if(!crime)
				ui_crime_id = null
			else
				data["crime_mode_lookup"] += list(list("name" = crime.name, "level" = crime.level))
				if(!highest_code)
					highest_code = crime.code
				else if(crime.code > highest_code)
					highest_code = crime.code
		for(var/P in GLOB.punishment)
			var/datum/punishment/punishment = find_punishment_object_from_type(P)
			if(punishment.harshness == highest_code)
				data["punishment"] = list("sentence" = punishment.sentence)
				if(punishment.length > 0)
					data["punishment"]["jail"] += list("time" = punishment.length)
				else if(punishment.fine > 0)
					data["punishment"]["fine"] += list("fine" = punishment.fine)
	else
		data["crime_mode_lookup"] = null
		data["punishment"] = null

	return data

/obj/item/lawbook/ui_static_data(mob/user)
	var/data = list()
	data["crime"] = GLOB.crime_list_results_lookup_list

	return data

/obj/item/lawbook/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("crime_click")
			var/input_crime = params["id"]
			input_crime = get_crime_type_from_product_string(input_crime)
			var/datum/crime/crime = find_crime_object_from_type(input_crime)
			if(!crime)
				to_chat(usr, "Could not find reagent!")
				return FALSE
			ui_crime_id += crime.type
			return TRUE
		if("remove_click")
			var/input_crime = params["id"]
			input_crime = get_crime_type_from_product_string(input_crime)
			var/datum/crime/crime = find_crime_object_from_type(input_crime)
			if(!crime)
				to_chat(usr, "Could not find reagent!")
				return FALSE
			ui_crime_id -= crime.type
			return TRUE
