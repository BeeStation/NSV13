#define READY 1
#define REPLICATING 2

/obj/machinery/replicator
	name = "Food Replicator"
	desc = "An advanced energy to matter synthesizer which is charged by <i>biomatter</i>. Click it to see what's on the menu and simply say what you want to order from it."
	icon = 'nsv13/icons/obj/machinery/replicator.dmi'
	icon_state = "replicator"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	density = TRUE
	circuit = /obj/item/circuitboard/machine/replicator
	/// The list of possible vocal choosen temperatures.
	var/list/temperatures = list("cold", "warm", "hot", "extra hot", "well done")
	/// The list of activator words, used to trigger the replicator to listen to whatever they are ordering.
	var/list/activator = list("computer", "alexa", "google", "ai", "voice")
	/// The list of currently Active Holographic Iguanas.
	var/list/iguanas = list()
	/// The how much biomass is gained when converting organic stuff into biomass.
	var/matter_energy_efficiency = 1
	/// How high the chance of not having a replicator failure is.
	var/failure_grade = 1
	/// How fast the Replicator will create something.
	var/speed_grade = 1
	/// If the Replicator is Emagged and can make more dangerous things.
	var/emagged = FALSE
	/// If the Replicator is currently replicating something.
	var/ready = TRUE
	/// The current state of the Replicator.
	var/menutype = READY
	/// The maximum amount of biomass that will affect the UI Progress bar.
	var/max_visual_biomass = 5000
	/// The research that is stored within this food replicator.
	var/datum/techweb/stored_research
	/// The different visual categories for the food replicator, for the tabs.
	var/list/show_categories = list(
		"Nutritional Supplements",
		"Basic Dishes",
		"Complex Dishes",
		"Exotic Dishes"
	)
	/// Currently selected category in the UI
	var/selected_cat
	/// Currently selected temperature in the UI
	var/selected_temperature = "cold"
	/// Linked Biogenerator.
	var/obj/machinery/biogenerator/biogen
	/// Internal biomass storage of the food replicator.
	var/internal_points = 0

/obj/machinery/replicator/Initialize()
	. = ..()
	stored_research = new /datum/techweb/specialized/autounlocking/replicator
	become_hearing_sensitive(ROUNDSTART_TRAIT)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/replicator/LateInitialize()
	. = ..()
	var/turf/object_current_turf = get_turf(src)
	var/Z_level = object_current_turf.get_virtual_z_level()
	var/valid_z = get_level_trait(Z_level)
	for(var/obj/machinery/biogenerator/Bio in GLOB.machines)
		if(Bio.get_virtual_z_level() in SSmapping.levels_by_trait(valid_z))
			var/area/location = get_area(Bio)
			if(location.name == "Hydroponics")
				biogen = Bio
				break

/**
 * This is a hacky way to check whether the replicator is using
 * the internal biomass store or a biogenerators biomass.
 *
 * * Returns TRUE if the replicator is linked to a biogenerator.
 * * Returns FALSE if the replicator is using the internal biomass store.
 */
/obj/machinery/replicator/proc/link_check()
	if(!biogen)
		return FALSE
	return TRUE

/obj/machinery/replicator/proc/return_store()
	if(!link_check())
		return internal_points
	else
		return biogen.points

/**
 * This is a hacky way to check whether the replicator has enough
 * biomass to complete the order.
 *
 * * amount - The amount of biomass to check for.
 */
/obj/machinery/replicator/proc/check_store(var/amount)
	if(!link_check())
		if(internal_points >= amount)
			return TRUE
		else
			return FALSE
	else
		if(biogen.points >= amount)
			return TRUE
		else
			return FALSE

/**
 * This is a hacky way to use biomass from the replicator.
 * It will use the internal biomass store if the replicator
 * is not linked to a biogenerator.
 *
 * * amount - The amount of biomass to use.
 * * decrease - Whether to decrease the biomass count.
 * * increase - Whether to increase the biomass count.
 */
/obj/machinery/replicator/proc/connection_use(var/amount, var/decrease = FALSE, var/increase = FALSE)
	if(!link_check())
		if(increase)
			internal_points += amount
			return
		else if(decrease)
			internal_points -= amount
			return
	else
		if(increase)
			biogen.points += amount
		else if(decrease)
			biogen.points -= amount

/obj/machinery/replicator/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(default_deconstruction_screwdriver(user, "replicator-o", "replicator-on", O))
		return FALSE

	if(default_unfasten_wrench(user, O))
		return FALSE

	if(istype(O, /obj/item/disk/design_disk/replicator))
		user.visible_message(
			"<span class='notice'>[user] begins to load \the [O] in \the [src]...</span>",
			"<span class='notice'>You begin to load designs from \the [O]...</span>",
			"<span class='hear'>You hear the clatter of a floppy drive.</span>"
		)
		var/obj/item/disk/design_disk/replicator/replicator_design_disk = O
		if(do_after(user, 2 SECONDS, target = src))
			for(var/datum/design/replicator/found_design in replicator_design_disk.blueprints)
				stored_research.add_design(found_design)
			update_static_data(user)
		return

	var/success = FALSE
	if(istype(O, /obj/item/reagent_containers/food/drinks/drinkingglass) || istype(O, /obj/item/trash))
		visible_message("<span class='warning'>[O] is vaporized by [src]</span>")
		playsound(src, 'nsv13/sound/effects/replicator-vaporize.ogg', 100, 1)
		qdel(O)
		return FALSE

	if(istype(O, /obj/item/reagent_containers/food/snacks))
		convert_to_biomass(O)
		success = TRUE
	else if(istype(O, /obj/item/storage/bag/plants))
		var/obj/item/storage/bag/plants/P = O
		for(var/obj/item/reagent_containers/food/snacks/grown/G in P.contents)
			convert_to_biomass(G)
			success = TRUE

	if(success)
		if(istype(O, /obj/item/storage/bag/plants))
			visible_message("<span class='warning'>The contents of [O] is vaporized by [src]</span>")
		else
			visible_message("<span class='warning'>[O] is vaporized by [src]</span>")
		playsound(src, 'nsv13/sound/effects/replicator-vaporize.ogg', 100, 1)
		use_power(50)
		return

/obj/machinery/replicator/multitool_act(mob/living/user, obj/item/multitool/M)
	if(istype(M))
		if(istype(M.buffer, /obj/machinery/biogenerator))
			biogen = M.buffer
			to_chat(user, "<span class='notice'>You link [src] to the biogenerator in [M]'s buffer.</span>")
			return TRUE

/obj/machinery/replicator/ui_status(mob/user)
	if(machine_stat & BROKEN || panel_open)
		return UI_CLOSE
	return ..()

/obj/machinery/replicator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/obj/machinery/replicator/ui_state(mob/user)
	return GLOB.not_incapacitated_state // Always viewable from a long range

/obj/machinery/replicator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Replicator", name)
		ui.open()
		ui.set_autoupdate(TRUE) // Used for the progress bar.

/obj/machinery/replicator/ui_data()
	var/list/data = list()
	data["replicating"] = ready
	data["biomass"] = return_store()
	data["max_visual_biomass"] = max_visual_biomass
	data["selected_temperature"] = selected_temperature

	return data

/obj/machinery/replicator/ui_static_data(mob/user)
	var/list/data = list()
	data["temperatures"] = temperatures
	data["categories"] = list()

	var/categories = show_categories.Copy()
	for(var/V in categories)
		categories[V] = list()
	for(var/V in stored_research.researched_designs)
		var/datum/design/replicator/D = SSresearch.techweb_design_by_id(V)
		for(var/C in categories)
			if(C in D.category)
				categories[C] += D

	for(var/category in categories)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		for(var/item in categories[category])
			var/datum/design/replicator/D = item
			var/costs = 0
			if(D.build_path)
				var/obj/item/temporary = new D.build_path
				if(istype(temporary, /obj/item/reagent_containers/food))
					costs = temporary.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
				else
					costs = D.cost ? D.cost : 5
				qdel(temporary)
			cat["items"] += list(list(
				"id" = D.id,
				"name" = D.name,
				"cost" = costs,
			))
		data["categories"] += list(cat)

	return data

/obj/machinery/replicator/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("replicate")
			if(!ready)
				say("I'm not ready to replicate yet!")
				return

			var/repli = params["id"]
			if(!stored_research.researched_designs.Find(repli))
				stack_trace("ID did not map to a researched datum [repli]")
				return

			if(menutype == READY)
				var/datum/design/replicator/D = SSresearch.techweb_design_by_id(repli)
				if(D && !istype(D, /datum/design/error_design))
					activation(D, selected_temperature, usr)
				else
					stack_trace("ID could not be turned into a valid techweb design datum [repli]")
					return

		if("select")
			selected_cat = params["category"]

		if("change_temperature")
			if(params["updated_temperature"] in temperatures)
				selected_temperature = params["updated_temperature"]

	return TRUE

/obj/machinery/replicator/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You corrupt the chemical processors.</span>")
		emagged = TRUE

/obj/machinery/replicator/RefreshParts()
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		matter_energy_efficiency = S.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		speed_grade = M.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		failure_grade = L.rating

/obj/machinery/replicator/examine(mob/user)
	. = ..()
	ui_interact(user)
	to_chat(user, "<span class='notice'>Fuel reserves: <b>[return_store()]</b>. Click it with any biomatter to recharge.</span>")

/obj/machinery/replicator/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(speaker == src)
		return
	else
		check_activation(speaker, raw_message)

/obj/machinery/replicator/proc/check_activation(atom/movable/speaker, raw_message)
	if(!powered() || !ready || panel_open)//Shut down.
		return
	if(!findtext(raw_message, activator))
		return FALSE //They have to say computer, like a discord bot prefix.
	if(menutype == READY)
		if(findtext(raw_message, "?")) //Burger? no be SPECIFIC. REEE
			return
		var/target
		var/temperature = null
		for(var/v in stored_research.researched_designs)
			var/datum/design/replicator/design = SSresearch.techweb_design_by_id(v)
			if(findtext(raw_message, design.name))
				target = design
			else if(length(design.alt_name) > 0)
				for(var/alt in design.alt_name)
					if(findtext(raw_message, alt))
						target = design
		for(var/Y in temperatures) //See if they want it hot, or cold.
			var/hotorcold = Y
			if(findtext(raw_message, hotorcold))
				temperature = hotorcold //If they specifically request a temperature, we'll oblige. Else it doesn't rename.
		if(target && powered())
			activation(target, temperature, speaker)

/obj/machinery/replicator/proc/activation(var/menu, var/temperature, var/mob/living/user)
	menutype = REPLICATING
	idle_power_usage = 400
	icon_state = "replicator-replicating"
	playsound(src, 'nsv13/sound/effects/replicator.ogg', 100, 1)
	ready = FALSE
	var/speed_mult = 60 //Starts off hella slow.
	speed_mult -= (speed_grade*10) //Upgrade with manipulators to make this faster!
	if(istype(menu, /datum/design/replicator))
		var/datum/design/replicator/design = menu
		menu = design

	menu = lowertext(menu)
	addtimer(CALLBACK(src, PROC_REF(replicate), menu, temperature, user), speed_mult)
	addtimer(CALLBACK(src, PROC_REF(set_ready), TRUE), speed_mult)

/obj/machinery/replicator/proc/set_ready()
	icon_state = "replicator-on"
	idle_power_usage = 40
	menutype = READY
	ready = TRUE

/obj/machinery/replicator/proc/convert_to_biomass(obj/item/reagent_containers/food/snacks/S)
	var/nutrimentgain = S.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	if(nutrimentgain < 0.1)
		nutrimentgain = 5 * matter_energy_efficiency
	qdel(S)
	connection_use(nutrimentgain, increase = TRUE)
	return

/obj/machinery/replicator/proc/replicate(var/what, var/temp, var/mob/living/user)
	var/atom/food
	if(istype(what, /datum/design/replicator))
		var/datum/design/replicator/design = what
		if(design.build_path)
			food = new design.build_path(get_turf(src))
		else
			what = lowertext(design.name)

	switch(what)
		if("tea earl grey")
			food = new /obj/item/reagent_containers/food/drinks/mug/tea(get_turf(src))
			food.name = "Earl Grey tea"
			food.desc = "Just how Captain Picard likes it."
			if(emagged)
				var/tea = food.reagents.get_reagent_amount(/datum/reagent/consumable/tea)
				food.reagents.add_reagent(/datum/reagent/consumable/ethanol, tea)
				food.reagents.remove_reagent(/datum/reagent/consumable/tea, tea)
		if("surprise me")
			if(emagged)
				switch(rand(1,6))
					if(1)
						new /mob/living/simple_animal/hostile/killertomato(get_turf(src))
					if(2)
						new /mob/living/simple_animal/hostile/netherworld(get_turf(src))
					if(3)
						new /mob/living/simple_animal/hostile/bear(get_turf(src))
					if(4)
						new /mob/living/simple_animal/hostile/blob/blobspore(get_turf(src))
					if(5)
						new /mob/living/simple_animal/hostile/carp(get_turf(src))
					if(6)
						food = new /obj/item/reagent_containers/food/snacks/soup/mystery(get_turf(src))
				playsound(src.loc, 'sound/effects/explosion3.ogg', 50, 1)
				var/datum/effect_system/smoke_spread/bad/smoke = new
				smoke.set_up(2, src.loc)
				smoke.start()
				del(src)
				return
			else
				food = new /obj/item/reagent_containers/food/snacks/soup/mystery(get_turf(src))
		if("coffee")
			food = new /obj/item/reagent_containers/food/drinks/coffee(get_turf(src))
			food.name = "coffee"
			food.desc = "A wise woman once said that coffee keeps you sane in deep space."
			if(emagged)
				var/coffee = food.reagents.get_reagent_amount(/datum/reagent/consumable/coffee)
				food.reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, coffee)
				food.reagents.remove_reagent(/datum/reagent/consumable/coffee, coffee)
		if("activate iguana")
			if(length(iguanas) > 9)
				say("You have reached the iguana limit!")
				return
			iguanas += new /mob/living/simple_animal/kalo/leonard(get_turf(src))
		if("deactivate iguana")
			for(var/mob/M as() in iguanas)
				iguanas -= M
				qdel(M)
	if(food)
		finalize_replication(food, temp, user)

/obj/machinery/replicator/proc/finalize_replication(var/atom/food, var/temp, var/mob/living/user)
	var/nutriment = food.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	if(check_store(nutriment) && check_store(5))
		//time to check laser power.
		if(prob(6-failure_grade)) //Chance to make a burned mess so the chef is still useful.
			var/obj/item/reagent_containers/food/snacks/badrecipe/neelixcooking = new /obj/item/reagent_containers/food/snacks/badrecipe(get_turf(src))
			neelixcooking.name = "replicator mess"
			neelixcooking.desc = "perhaps you should invest in some higher quality parts."
			connection_use(5, decrease = TRUE)
			qdel(food) //NO FOOD FOR YOU!
			return
		else
			if(temp || selected_temperature)
				food.name = "[temp ? temp : selected_temperature] [food.name]"
				var/temperature_check = temp ? temp : selected_temperature
				switch(temperature_check)
					if("cold")
						food.reagents.chem_temp = 0
					if("hot")
						food.reagents.chem_temp = 450
					if("extra hot")
						food.reagents.chem_temp = 5000
					if("well done")
						food.reagents.chem_temp = 2000000000000 //A nice warm Steak or a perfectly well boiled Cup of Tea
			if(nutriment > 0)
				connection_use(nutriment, decrease = TRUE)
			else
				connection_use(5, decrease = TRUE) //Default, in case the food is useless.
			if(emagged)
				food.reagents.add_reagent(/datum/reagent/toxin/munchyserum, nutriment)
				food.reagents.remove_reagent(/datum/reagent/consumable/nutriment, nutriment)
			var/currentHandIndex = user.get_held_index_of_item(food)
			user.put_in_hand(food, currentHandIndex)
	else
		visible_message("<span_class='warning'>Insufficient fuel to create [food.name]. [src] requires [nutriment] U of biomatter.</span>")
		qdel(food) //NO FOOD FOR YOU!
		return

/obj/item/circuitboard/machine/replicator
	name = "Food Replicator (Machine Board)"
	icon = 'nsv13/icons/obj/module.dmi'
	icon_state = "repli_board"
	build_path = /obj/machinery/replicator
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1
	)

/mob/living/simple_animal/kalo/leonard
	name = "Leonard"
	desc = "A holographic pet lizard. Say 'deactivate iguana' if you're a square."

//Tasteless alternative to lipolicide, less powerful. This has the reverse of the intended effect of a replicator and makes you hungrier.
/datum/reagent/toxin/munchyserum
	name = "Metabolism Override Toxin"
	description = "A strong toxin that increases the appetite of their victim while dampening their ability to absorb nutrients for as long as it is in their system."
	silent_toxin = TRUE
	reagent_state = LIQUID
	taste_mult = 0 //no flavor
	color = "#F0FFF0"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/munchyserum/on_mob_life(mob/living/carbon/M)
	if(M.nutrition >= NUTRITION_LEVEL_STARVING+75)
		M.adjust_nutrition(-3)
		M.overeatduration = 0
	return ..()

/obj/item/disk/design_disk/replicator
	name = "Pattern Upgrade Disk"
	desc = "You shouldn't be seeing this."
	icon = 'nsv13/icons/obj/module.dmi'
	var/subtype

/obj/item/disk/design_disk/replicator/Initialize()
	. = ..()
	if(subtype)
		for(var/design in subtypesof(subtype)-/datum/design/replicator)
			var/datum/design/replicator/new_design = design
			blueprints += new new_design

/obj/item/disk/design_disk/replicator/tier2
	name = "Pattern Upgrade Disk (Tier 2)"
	desc = "A disk containing the schematics for Tier 2 Replicator Patterns."
	icon_state = "disk_tier2"
	subtype = /datum/design/replicator/tier2

/obj/item/disk/design_disk/replicator/tier3
	name = "Pattern Upgrade Disk (Tier 3)"
	desc = "A disk containing the schematics for Tier 3 Replicator Patterns."
	icon_state = "disk_tier3"
	subtype = /datum/design/replicator/tier3

/obj/item/disk/design_disk/replicator/tier4
	name = "Pattern Upgrade Disk (Tier 4)"
	desc = "A disk containing the schematics for Tier 4 Replicator Patterns."
	icon_state = "disk_tier4"
	subtype = /datum/design/replicator/tier4

#undef READY
#undef REPLICATING
