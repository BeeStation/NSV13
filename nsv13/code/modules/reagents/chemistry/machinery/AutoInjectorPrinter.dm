/obj/machinery/autoinject_printer
	name = "autoinjector printer"
	desc = "A machine that takes in reagents and prints them into instant injectors."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'nsv13/icons/obj/hypospray.dmi'
	icon_state = "heater_0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/autoinject_printer

	var/obj/item/reagent_containers/beaker = null
	var/mode = 1
	var/condi = FALSE
	var/useramount = 30 // Last used amount
	var/max_create = 2

/obj/machinery/autoinject_printer/Initialize()
	create_reagents(100)
	. = ..()

/obj/machinery/autoinject_printer/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/autoinject_printer/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

	max_create = 2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		max_create += M.rating

/obj/machinery/autoinject_printer/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		reagents.clear_reagents()
		update_icon()
		ui_update()

/obj/machinery/autoinject_printer/update_icon()
	cut_overlays()
	if(beaker)
		icon_state = "heater_1"
		add_overlay("beaker")
	else
		icon_state = "heater_0"

/obj/machinery/autoinject_printer/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "heater-o", "heater_0", I))
		return

	else if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE // no afterattack
		if(panel_open)
			to_chat(user, "<span class='warning'>You can't use the [src.name] while its panel is opened!</span>")
			return
		var/obj/item/reagent_containers/B = I
		. = TRUE // no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		ui_update()
		update_icon()
	else
		return ..()

/obj/machinery/autoinject_printer/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)
	ui_update()
	return

/obj/machinery/autoinject_printer/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		beaker.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)
	if(new_beaker)
		beaker = new_beaker
	else
		beaker = null
	update_icon()
	return TRUE

/obj/machinery/autoinject_printer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/autoinject_printer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AutoInjectorPrinter")
		ui.open()

/obj/machinery/autoinject_printer/ui_data(mob/user)
	var/list/data = list()
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["mode"] = mode
	data["condi"] = condi
	data["MaxDispense"] = max_create

	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id" = ckey(R.name), "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	var/bufferContents[0]
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			bufferContents.Add(list(list("name" = N.name, "id" = ckey(N.name), "volume" = N.volume))) // ^
	data["bufferContents"] = bufferContents
	return data

/obj/machinery/autoinject_printer/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("eject")
			replace_beaker(usr)
			. = TRUE
		if("transfer")
			if(!beaker)
				return
			var/reagent = GLOB.name2reagent[params["id"]]
			var/amount = text2num(params["amount"])
			var/to_container = params["to"]
			// Custom amount
			if (amount == -1)
				amount = text2num(input(
					"Enter the amount you want to transfer:",
					name, ""))
			if (amount == null || amount <= 0)
				return
			if (to_container == "buffer")
				beaker.reagents.trans_id_to(src, reagent, amount)
				. = TRUE
			else if (to_container == "beaker" && mode)
				reagents.trans_id_to(beaker, reagent, amount)
				. = TRUE
			else if (to_container == "beaker" && !mode)
				reagents.remove_reagent(reagent, amount)
				. = TRUE
		if("toggleMode")
			mode = !mode
			. = TRUE
		if("create")
			if(reagents.total_volume == 0)
				return
			var/item_type = params["type"]
			// Get amount of items
			var/amount = text2num(params["amount"])
			if(amount == null)
				amount = text2num(input(usr,
					"Max 10. Buffer content will be split evenly.",
					"How many to make?", 1))
			amount = clamp(round(amount), 0, 10)
			if (amount <= 0)
				return
			// Get units per item
			var/vol_each = text2num(params["volume"])
			var/vol_each_text = params["volume"]
			var/vol_each_max = reagents.total_volume / amount
			if (item_type == "medipen" && !condi)
				vol_each_max = min(10, vol_each_max)
			else
				return
			if(vol_each_text == "auto")
				vol_each = vol_each_max
			if(vol_each == null)
				vol_each = text2num(input(usr,
					"Maximum [vol_each_max] units per item.",
					"How many units to fill?",
					vol_each_max))
			vol_each = clamp(vol_each, 0, vol_each_max)
			if(vol_each <= 0)
				return
			// Get item name
			var/name = params["name"]
			var/name_has_units = item_type == "medipen"
			if(!name)
				var/name_default = reagents.get_master_reagent_name()
				if (name_has_units)
					name_default += " ([vol_each]u)"
				name = stripped_input(usr,
					"Name:",
					"Give it a name!",
					name_default,
					MAX_NAME_LEN)
			if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, !issilicon(usr)))
				return
			// Start filling
			switch(item_type)
				if("medipen")
					var/obj/item/reagent_containers/hypospray/autoinjector/P
					var/target_loc = drop_location()
					var/drop_threshold = INFINITY
					for(var/i = 0; i < amount; i++)
						if(i < drop_threshold)
							P = new/obj/item/reagent_containers/hypospray/autoinjector(target_loc)
						else
							P = new/obj/item/reagent_containers/hypospray/autoinjector(drop_location())
						P.name = trim("[name] autoinjector")
						adjust_item_drop_location(P)
						reagents.trans_to(P, vol_each, transfered_by = usr)
					. = TRUE

/obj/machinery/autoinject_printer/proc/isgoodnumber(num)
	if(isnum_safe(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 0
		else
			num = round(num)
		return num
	else
		return 0

/obj/machinery/autoinject_printer/adjust_item_drop_location(atom/movable/AM) // Special version for chemmasters and condimasters
	if (AM == beaker)
		AM.pixel_x = -8
		AM.pixel_y = 8
		return null
	else
		var/md5 = rustg_hash_string(RUSTG_HASH_MD5, AM.name)
		for (var/i in 1 to 32)
			. += hex2num(md5[i])
		. = . % 9
		AM.pixel_x = ((.%3)*6)
		AM.pixel_y = -8 + (round( . / 3)*8)
