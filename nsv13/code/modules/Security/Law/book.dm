/obj/item/lawbook
	name = "Book of Laws"
	desc = "A standard printed space law book, although this one seems to resonate with an unknown power"
	icon = 'icons/obj/library.dmi'
	icon_state = "bookSpaceLaw"

/obj/item/lawbook/Initialize()
	. = ..()
	build_crime_list()

/obj/item/lawbook/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrimeBook")
		ui.status = UI_INTERACTIVE
		ui.open()

/obj/item/lawbook/ui_status(mob/user)
	return UI_INTERACTIVE

/obj/item/lawbook/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/lawbook/ui_static_data(mob/user)
	var/data = list()
	data["crime"] = GLOB.crime_list_results_lookup_list

	return data
/*
/obj/item/lawbook/ui_data(mob/user)
	var/data = list()

	for(var/C in GLOB.crime_list)
		var/datum/crime/crime = find_crime_object_from_type(C)
		if(!crime)
		else
			data["crime"] = list("name" = crime.name, "desc" = crime.description)
	return data
*/
