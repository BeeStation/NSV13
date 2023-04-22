/obj/item/storage/fancy/coffee_condi_display
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "coffee_condi_display"
	name = "coffee condiments display"
	desc = "A neat small wooden box, holding all your favorite coffee condiments."
	//icon_type = "coffee condiment"
	fancy_open = TRUE

/obj/item/storage/fancy/coffee_condi_display/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 14
	var/static/list/can_hold = typecacheof(list(/obj/item/reagent_containers/food/condiment/pack/sugar,
												/obj/item/reagent_containers/food/condiment/creamer,
												/obj/item/reagent_containers/food/condiment/pack/astrotame,
												/obj/item/reagent_containers/food/condiment/chocolate))
	STR.can_hold = can_hold

/obj/item/storage/fancy/coffee_condi_display/update_icon()
	cut_overlays()
	icon_state = "coffee_condi_display"
	if(!contents.len)
		return
	else
		var/mutable_appearance/inserted_overlay = mutable_appearance(icon)
		if(locate(/obj/item/reagent_containers/food/condiment/pack/sugar) in contents)
			inserted_overlay.icon_state = "condi_display_sugar"
			add_overlay(inserted_overlay)
		if(locate(/obj/item/reagent_containers/food/condiment/pack/astrotame) in contents)
			inserted_overlay.icon_state = "condi_display_sweetener"
			add_overlay(inserted_overlay)
		if(locate(/obj/item/reagent_containers/food/condiment/creamer) in contents)
			inserted_overlay.icon_state = "condi_display_creamer"
			add_overlay(inserted_overlay)
		if(locate(/obj/item/reagent_containers/food/condiment/chocolate) in contents)
			inserted_overlay.icon_state = "condi_display_chocolate"
			add_overlay(inserted_overlay)

/obj/item/storage/fancy/coffee_condi_display/PopulateContents()
	for(var/i = 1 to 4)
		new /obj/item/reagent_containers/food/condiment/pack/sugar(src)
	for(var/i = 1 to 3)
		new /obj/item/reagent_containers/food/condiment/pack/astrotame(src)
	for(var/i = 1 to 4)
		new /obj/item/reagent_containers/food/condiment/creamer(src)
	for(var/i = 1 to 3)
		new /obj/item/reagent_containers/food/condiment/chocolate(src)
	update_icon()

/obj/item/storage/fancy/coffee_condi_display/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	return
