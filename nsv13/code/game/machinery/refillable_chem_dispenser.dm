/obj/machinery/refillable_chem_dispenser
	name = "refillable chem dispenser"
	desc = "Stores and dispenses chemicals."
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/refillable_chem_dispenser

	var/base_capacity = 3000
	var/mode = 1
	var/amount = 30
	var/list/default_transfer_amounts = list(5,10,15,20,25,30)
	var/mutable_appearance/beaker_overlay
	var/working_state = "dispenser_working"
	var/nopower_state = "dispenser_nopower"
	var/has_panel_overlay = TRUE
	var/obj/item/reagent_containers/beaker = null
	//Base reagent list - show even if we don't have any
	var/list/basic_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/silver,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel
	)
	// Additional reagents - update if they add stuff to storage
	var/list/upgrade_reagents = list()
	// Dispensable reagents - sum of both lists
	var/list/dispensable_reagents
	var/list/recording_recipe

	var/list/saved_recipes = list()

/obj/machinery/refillable_chem_dispenser/Initialize(mapload)
	create_reagents(base_capacity)
	reagents.flags = NO_REACT
	. = ..()
	basic_reagents = sortList(basic_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))
	if(upgrade_reagents)
		upgrade_reagents = sortList(upgrade_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))
	dispensable_reagents = basic_reagents + upgrade_reagents
	update_icon()

/obj/machinery/refillable_chem_dispenser/full

/obj/machinery/refillable_chem_dispenser/full/Initialize(mapload)
	. = ..()
	var/init_amount = round(base_capacity / length(basic_reagents))
	for(var/R in basic_reagents)
		reagents.add_reagent(R, init_amount, no_react=TRUE)

/obj/machinery/refillable_chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/refillable_chem_dispenser/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='notice'>[src]'s maintenance hatch is open!</span>"

/obj/machinery/refillable_chem_dispenser/proc/display_beaker()
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	b_o.pixel_y = -4
	b_o.pixel_x = -7
	return b_o

/obj/machinery/refillable_chem_dispenser/proc/work_animation()
	if(working_state)
		flick(working_state,src)

/obj/machinery/refillable_chem_dispenser/power_change()
	..()
	icon_state = "[(nopower_state && !powered()) ? nopower_state : initial(icon_state)]"

/obj/machinery/refillable_chem_dispenser/update_icon()
	cut_overlays()
	if(has_panel_overlay && panel_open)
		add_overlay(mutable_appearance(icon, "[initial(icon_state)]_panel-o"))

	if(beaker)
		beaker_overlay = display_beaker()
		add_overlay(beaker_overlay)

/obj/machinery/refillable_chem_dispenser/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/refillable_chem_dispenser/contents_explosion(severity, target)
	..()
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += beaker

/obj/machinery/refillable_chem_dispenser/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		cut_overlays()

/obj/machinery/refillable_chem_dispenser/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/refillable_chem_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RefillableChemDispenser")
		ui.open()

/obj/machinery/refillable_chem_dispenser/ui_data(mob/user)
	var/data = list()
	data["amount"] = amount
	data["volume"] = reagents.total_volume //To prevent NaN in the UI.
	data["maxVolume"] = reagents.maximum_volume
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var/beakerContents[0]
	var/beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id" = ckey(R.name), "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
		data["beakerTransferAmounts"] = beaker.possible_transfer_amounts
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null
		data["beakerTransferAmounts"] = default_transfer_amounts
	data["mode"] = mode

	var/chemicals[0]
	var/is_hallucinating = FALSE
	if(user.hallucinating())
		is_hallucinating = TRUE
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			var/chemname = temp.name
			var/volume = reagents.get_reagent_amount(temp.type)
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals.Add(list(list("title" = chemname, "id" = ckey(temp.name), "volume" = volume)))
	data["chemicals"] = chemicals
	data["recipes"] = saved_recipes

	data["recordingRecipe"] = recording_recipe
	return data

/obj/machinery/refillable_chem_dispenser/ui_act(action, params)
	. = ..()
	ui_update()
	if(.) // Propagation only used by debug machine, but eh
		return

	switch(action)
		if("eject")
			replace_beaker(usr)
			. = TRUE

	if(!is_operational)
		return

	switch(action)
		if("amount")
			var/target = text2num(params["target"])
			if(!QDELETED(beaker))
				if(target in beaker.possible_transfer_amounts)
					amount = target
			else if(recording_recipe && (amount in default_transfer_amounts))
				amount = target
			else
				return
			work_animation()
			. = TRUE
		if("dispense")
			var/reagent_name = params["reagent"]
			if(!recording_recipe)
				var/reagent = GLOB.name2reagent[reagent_name]
				if(beaker)
					var/datum/reagents/R = beaker.reagents
					var/free = R.maximum_volume - R.total_volume
					if(!reagents.get_reagent_amount(reagent))
						say("No [reagent_name] left in storage!")
						return
					reagents.trans_id_to(beaker, reagent, min(amount, free))
					update_reagents()

					work_animation()
			else
				recording_recipe[reagent_name] += amount
			. = TRUE
		if("dispense_recipe")
			var/list/chemicals_to_dispense = saved_recipes[params["recipe"]]
			if(!LAZYLEN(chemicals_to_dispense))
				return
			// Dry run - before we do anything, is there enough space and do we have enough chems?
			var/enough_stored = TRUE
			var/total_space_needed = 0
			if(!recording_recipe)
				for(var/key in chemicals_to_dispense)
					var/reagent = GLOB.name2reagent[key]
					var/dispense_amount = chemicals_to_dispense[key]
					if(!beaker)
						return
					if(!reagents.get_reagent_amount(reagent) || reagents.get_reagent_amount(reagent) < dispense_amount)
						enough_stored = FALSE
						break
					total_space_needed += amount
			var/free = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			if(!enough_stored || (free < total_space_needed))
				var/reply = alert(usr, "[enough_stored ? "There is not enough space for this recipe." : "There are not enough reagents stored for this recipe."] Continue?", "Recipe", "OK", "Cancel")
				if(reply == "Cancel")
					return
			// Transfer them for real
			for(var/key in chemicals_to_dispense)
				var/reagent = GLOB.name2reagent[key]
				var/dispense_amount = chemicals_to_dispense[key]
				if(!recording_recipe)
					if(!beaker)
						return
					var/datum/reagents/R = beaker.reagents
					free = R.maximum_volume - R.total_volume
					if(!reagents.get_reagent_amount(reagent))
						say("No [key] left in storage!")
						return
					reagents.trans_id_to(beaker, reagent, min(dispense_amount, free))
					update_reagents()
				else
					recording_recipe[key] += dispense_amount
			. = TRUE
		if("clear_recipes")
			var/yesno = alert("Clear all recipes?",, "Yes","No")
			if(yesno == "Yes")
				saved_recipes = list()
			. = TRUE
		if("record_recipe")
			recording_recipe = list()
			. = TRUE
		if("save_recording")
			var/name = stripped_input(usr,"Name","What do you want to name this recipe?", "Recipe", MAX_NAME_LEN)
			if(!usr.canUseTopic(src, !issilicon(usr)))
				return
			if(saved_recipes[name] && alert("\"[name]\" already exists, do you want to overwrite it?",, "Yes", "No") == "No")
				return
			if(name && recording_recipe)
				for(var/reagent in recording_recipe)
					var/reagent_id = GLOB.name2reagent[translate_legacy_chem_id(reagent)]
					if(!dispensable_reagents.Find(reagent_id))
						visible_message("<span class='warning'>[src] buzzes.</span>", "<span class='italics'>You hear a faint buzz.</span>")
						to_chat(usr, "<span class ='danger'>[src] cannot find <b>[reagent]</b>!</span>")
						playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
						return
				saved_recipes[name] = recording_recipe
				recording_recipe = null
				. = TRUE
		if("cancel_recording")
			recording_recipe = null
			. = TRUE
		if("transfer")
			if(!beaker)
				return
			var/reagent = GLOB.name2reagent[params["id"]]
			var/amount = min(text2num(params["amount"]))
			// Custom amount
			if (amount == -1)
				amount = text2num(input(
					"Enter the amount you want to transfer:",
					name, ""))
			if (amount == null || amount <= 0)
				return
			if(mode)
				beaker.reagents.trans_id_to(src, reagent, amount)
				update_reagents()
			else
				beaker.reagents.remove_reagent(reagent, amount)
			. = TRUE
		if("toggleMode")
			mode = !mode
			. = TRUE
	ui_update()

/obj/machinery/refillable_chem_dispenser/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	if(default_deconstruction_crowbar(I))
		return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/B = I
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
	else if(user.a_intent != INTENT_HARM && !istype(I, /obj/item/card/emag))
		to_chat(user, "<span class='warning'>You can't load [I] into [src]!</span>")
		return ..()
	else
		return ..()

/obj/machinery/refillable_chem_dispenser/RefreshParts()
	reagents.maximum_volume = base_capacity
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/refillable_chem_dispenser/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
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

/obj/machinery/refillable_chem_dispenser/on_deconstruction()
	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null
	return ..()

/obj/machinery/refillable_chem_dispenser/AltClick(mob/living/user)
	. = ..()
	if(istype(user) && user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		replace_beaker(user)

/obj/machinery/refillable_chem_dispenser/proc/update_reagents()
	var/list/new_upgrade_reagents = list()
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			if(!(N.type in basic_reagents))
				new_upgrade_reagents |= N.type
	upgrade_reagents = sortList(new_upgrade_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))
	dispensable_reagents = basic_reagents + upgrade_reagents
