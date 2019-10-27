//An automatic chem filter; think of it like a automated chem master somewhat
//Takes a reagent container as a input and will remove chemicals that don't fit with the inputted chem macro
//Alternatively, the machine can also remove certain reagents VIA chem macro input instead of making reagents like a chem macro

#define FILTER_INTO 0
#define FILTER_OUT 1

/obj/machinery/automation/chem_filter
	name = "automatic chem filter"
	desc = "A machine used for the filteration of inputted reagent containers."
	var/current_mode = FILTER_INTO //filter_out is the other possible one
	var/current_chem_macro = ""
	radial_categories = list(
	"Toggle Filter Type",
	"Change Macro"
	)

/obj/machinery/automation/chem_filter/Bumped(atom/movable/input)
	var/obj/item/I = input
	if(istype(I) && I.reagents && current_chem_macro)
		contents += I //We add it to ourself later for processing
	..()

/obj/machinery/automation/chem_filter/Initialize()
	. = ..()
	radial_categories["Toggle Filter Type"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_toggle_filter")
	radial_categories["Change Macro"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_macro")

/obj/machinery/automation/chem_filter/MakeRadial(mob/living/user)
	var/category = show_radial_menu(user, src, radial_categories, null, require_near = TRUE)
	if(category)
		switch(category)
			if("Change Macro")
				current_chem_macro = stripped_input(usr,"Recipe","Insert the chem macro with chem IDs")
			if("Toggle Filter Type")
				if(current_mode) //If FILTER_OUT
					current_mode = FILTER_INTO
					to_chat(user, "<span class='notice'>You set the filteration to the FILTER INTO chem setting.</span>")
				else
					current_mode = FILTER_OUT
					to_chat(user, "<span class='notice'>You set the filteration to the FILTER OUT chem setting.</span>")

/obj/machinery/automation/chem_filter/examine(mob/user)
	. = ..()
	if(.)
		to_chat(user, "<span class='notice'>Current chem filter setting: <span class='bold'>[current_mode ? "Filtering into" : "Filtering out"]</span> the chem macro set.</span>")
		to_chat(user, "<span class='notice'>Current chem macro: <span class='bold'>[current_chem_macro ? current_chem_macro : "No chem macro set"]</span></span>")

/obj/machinery/automation/chem_filter/process()
	..()
	if(contents.len && current_chem_macro)
		var/obj/item/processing = contents[1]
		switch(current_mode)
			if(FILTER_INTO)
				var/list/reagents_to_save = process_recipe_list(current_chem_macro)
				for(var/datum/reagent/reagent in processing.reagents.reagent_list)
					if(reagents_to_save[reagent.id])
						processing.reagents.remove_reagent(reagent.id, 0, processing.reagents.get_reagent_amount(reagent.id) - reagents_to_save.[reagent.id], TRUE) //Remove any excess reagent
					else
						processing.reagents.del_reagent(reagent.id)

				playsound(loc, 'sound/machines/ping.ogg', 30, 1)
				processing.loc = get_step(src, outputdir)

			if(FILTER_OUT)
				var/list/reagents_to_remove = process_recipe_list(current_chem_macro)
				for(var/r_id in reagents_to_remove)
					processing.reagents.remove_reagent(r_id, reagents_to_remove[r_id])
				playsound(loc, 'sound/machines/ping.ogg', 30, 1)
				processing.loc = get_step(src, outputdir)
