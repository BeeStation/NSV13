//A test machine that grinds up a item if applicable and outputs all the results as a reagent patch
/obj/machinery/automation/grinder
	name = "autogrinder"
	desc = "Grinds up items with reagents inside and outputs it as a patch."
	var/obj/item/reagent_containers/output_container = new/obj/item/reagent_containers/pill/patch() //The typepath of the reagent container we want to output; patch by default, also allows pills
	var/amount_to_transfer = 10 //How many units should be dispensed into the output container
	var/name_of_output = "" //If we want to append a custom name to the output we will, otherwise just uses default setup AKA get_master_reagent and total volume

	radial_categories = list(
	"Change Output Name",
	"Change Transfer Rate",
	"Change Container Output"
	)

	var/list/valid_containers = list(
	new/obj/item/reagent_containers/pill(),
	new/obj/item/reagent_containers/pill/patch()
	)

/obj/machinery/automation/grinder/Initialize()
	. = ..()
	for(var/obj/item/reagent_containers/stuff in valid_containers)
		valid_containers[stuff] = image(stuff)

/obj/machinery/automation/grinder/examine(mob/user)
	. = ..()
	if(.)
		to_chat(user, "<span class='notice'>Current outputted name: <span class='bold'>[name_of_output ? name_of_output : "Default naming scheme"]</span></span>")
		to_chat(user, "<span class='notice'>Units of reagents transferred to new: <span class='bold'>[amount_to_transfer ? amount_to_transfer : "No output!!!"]</span></span>")

/obj/machinery/automation/grinder/MakeRadial(mob/living/user)
	var/category = show_radial_menu(user, src, radial_categories, null, require_near = TRUE)
	if(category)
		switch(category)
			if("Change Output Name")
				name_of_output = stripped_input(user,"Putting in nothing will use the default naming scheme (name of main reagent + unit amount)","Input a custom name!", "", MAX_NAME_LEN)

			if("Change Transfer Rate")
				amount_to_transfer = CLAMP(round(input(user, "The max amount of reagents that can be put inside is [output_container.reagents.maximum_volume]u.", "How many units to transfer?") as num|null), 0, output_container.reagents.maximum_volume)

			if("Change Container Output")
				var/obj/storage_choice = show_radial_menu(user, src, valid_containers, null, require_near = TRUE)
				if(storage_choice && storage_choice in valid_containers)
					output_container = storage_choice
					to_chat(user, "You set the reagent container to output to <span class='bold'>[output_container.name]</span>.")

/obj/machinery/automation/grinder/Initialize()
	. = ..()
	create_reagents(10000, NO_REACT) //Because of the way this machine would work, all of this would be constantly be outputting anyway, or you could just use this as a unpowered 10000 unit vat
	radial_categories["Change Output Name"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_label")
	radial_categories["Change Transfer Rate"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_transfer_rate")
	radial_categories["Change Container Output"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_container")

/obj/machinery/automation/grinder/Bumped(atom/input)
	var/obj/item/I = input
	if(istype(I) && I.grind_results && (reagents.total_volume != reagents.maximum_volume)) //We'll only grind if it's acceptable and that we don't have the max capacity hit
		reagents.add_reagent_list(I.grind_results)
		if(I.reagents) //Any reagents already present inside besides the grind_results are transferred
			I.reagents.trans_to(reagents, I.reagents.total_volume)
		contents -= I
		qdel(I)
		return //Quiet return if it was an item that could be grinded
	..()

//For testing purposes, this machine will output a patch reagent container with some of the chems
/obj/machinery/automation/grinder/process()
	if(reagents.total_volume > amount_to_transfer && amount_to_transfer)
		var/obj/item/reagent_containers/outputed_container = new output_container.type(get_step(src, outputdir))
		playsound(loc, 'sound/machines/ping.ogg', 30, 1)
		reagents.trans_to(outputed_container, min(reagents.total_volume, amount_to_transfer)) //Transfer the chemicals
		if(name_of_output)
			outputed_container.name = trim(name_of_output)
		else
			outputed_container.name = trim("[outputed_container.reagents.get_master_reagent_name()] ([amount_to_transfer]u)")
	..()
