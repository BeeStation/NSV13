/**
 * This file contains the ammo rack and ammo rack control console.
 * Each rack is linked to a console, which allows for remote dispensation and management of the rack.
 * Ammo racks can be loaded via hand, dragging, or bumping, and they can be maintained using oil.
 */

// Ammo rack control console
/obj/machinery/computer/ammo_sorter
	name = "ammo rack control console"
	icon_screen = "ammorack"
	circuit = /obj/item/circuitboard/computer/ammo_sorter
	var/id = null
	var/list/linked_sorters = list()

/obj/machinery/computer/ammo_sorter/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ammo_sorter/LateInitialize()
	. = ..()
	for(var/obj/machinery/ammo_sorter/W in GLOB.machines)
		if(istype(W) && W.id == id)
			linkSorter(W)
	sortList(linked_sorters) //Alphabetise the list initially...

/obj/machinery/computer/ammo_sorter/Destroy()
	for(var/obj/machinery/ammo_sorter/AS as() in linked_sorters)
		AS.linked_consoles -= src
	. = ..()

/obj/machinery/computer/ammo_sorter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AmmoSorter")
		ui.open()

/obj/machinery/computer/ammo_sorter/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/obj/machinery/ammo_sorter/AS = locate(params["id"])
	switch(action)
		if("unload_all")
			unload_all()
		if("unload")
			if(!AS)
				return
			if(!AS.pop())
				to_chat(usr, "<span class='warning'>[src] displays an error message!</span>")
		if("unlink")
			if(!AS)
				return
			unlinkSorter(AS)
		if("rename")
			if(!AS)
				return
			var/new_name = stripped_input(usr, message="Enter a new name for [AS]", max_length=MAX_CHARTER_LEN)

			if(!new_name)
				return

			AS.name = new_name
			message_admins("[key_name(usr)] renamed an ammo rack to [new_name].")
			log_game("[key_name(usr)] renamed an ammo rack to [new_name].")
		if("moveup")
			if(!AS)
				return
			var/id = linked_sorters.Find(AS)
			if (id <= 1)
				return
			linked_sorters.Swap(id,id-1)
		if("movedown")
			if(!AS)
				return
			var/id = linked_sorters.Find(AS)
			if (id >= linked_sorters.len)
				return
			linked_sorters.Swap(id,id+1)
	// update UI
	ui_interact(usr)

/obj/machinery/computer/ammo_sorter/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/racks_info = list()
	for(var/obj/machinery/ammo_sorter/AS as() in linked_sorters)
		var/atom/what = null
		var/loadedlen = length(AS.loaded)
		if(loadedlen)
			what = AS.loaded[loadedlen]
		racks_info[++racks_info.len] = list("name"=AS.name, "has_loaded"=loadedlen > 0, "id"="\ref[AS]", "top"=(what ? what.name : "Nothing"))
	data["racks_info"] = racks_info
	return data

/obj/machinery/computer/ammo_sorter/proc/unload_all()
	for(var/obj/machinery/ammo_sorter/AS as() in linked_sorters)
		AS.unload()

/obj/machinery/computer/ammo_sorter/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return TRUE
	var/obj/item/multitool/M = I
	M.buffer = src
	to_chat(user, "<span class='notice'>You add [src] to [M]'s buffer.</span>")
	return TRUE

/obj/machinery/computer/ammo_sorter/proc/linkSorter(var/obj/machinery/ammo_sorter/AS)
	linked_sorters += AS
	AS.linked_consoles += src
	ui_update()

/obj/machinery/computer/ammo_sorter/proc/unlinkSorter(var/obj/machinery/ammo_sorter/AS)
	linked_sorters -= AS
	AS.linked_consoles -= src
	ui_update()

// The ammo rack itself
/obj/machinery/ammo_sorter
	name = "Ammo Rack"
	desc = "A machine that allows you to compartmentalise your ship's ammo stores, controlled by a central console. Drag and drop items onto it to load them."
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "ammorack"
	circuit = /obj/item/circuitboard/machine/ammo_sorter
	density = TRUE
	anchored = TRUE
	var/id = null
	var/list/linked_consoles = list() //to help with unlinking after destruction
	var/list/loaded = list() //What's loaded in?
	var/max_capacity = 12	//Max cap for holding.
	var/durability = 100
	var/max_durability = 100
	var/repair_multiplier = 10 // How many points of durability we repair per unit of oil
	var/jammed = FALSE //if at 0 durability, jam it, handled in weardown().
	var/busy = FALSE

/obj/machinery/ammo_sorter/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in get_turf(src))
		if(istype(I, /obj/item/ship_weapon/ammunition) || istype(I, /obj/item/powder_bag))
			load(I, force = TRUE)

/obj/machinery/ammo_sorter/Exited(atom/movable/gone, direction)
	. = ..()
	loaded -= gone
	for(var/obj/machinery/computer/ammo_sorter/AS as() in linked_consoles)
		AS.ui_update()

/obj/machinery/ammo_sorter/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		busy = FALSE // Just in case it gets stuck somehow, you can reset it
		update_icon()
		return
	// Makes sure you can't accidentally decon a jammed machine
	if(!jammed && default_deconstruction_crowbar(I))
		return
	// Smacking
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already working on [src]!</span>")
		return TRUE
	if(panel_open && istype(I, /obj/item/reagent_containers))
		if(jammed)
			to_chat(user, "<span class='warning'>You can't lubricate a jammed machine!</span>")
			return TRUE
		if(durability >= max_durability)
			to_chat(user, "<span class='warning'>[src] doesn't need any oil right now!</span>")
			return TRUE
		if(!I.reagents.has_reagent(/datum/reagent/oil))
			to_chat(user, "<span class='warning'>You need oil to lubricate this!</span>")
			return TRUE
		// get how much oil we have
		var/oil_amount = min(I.reagents.get_reagent_amount(/datum/reagent/oil), max_durability/repair_multiplier)
		var/oil_needed = CLAMP(ROUND_UP((max_durability-durability)/repair_multiplier), 1, oil_amount)
		oil_amount = min(oil_amount, oil_needed)
		user.visible_message("<span class='notice'>[user] begins lubricating [src]...</span>", \
					"<span class='notice'>You start lubricating the inner workings of [src]...</span>")
		busy = TRUE
		if(!do_after(user, 5 SECONDS, target=src))
			busy = FALSE
			to_chat(user, "<span class='warning'>You were interrupted!</span>")
			return TRUE
		if(!I.reagents.has_reagent(/datum/reagent/oil, oil_amount)) //things can change, check again.
			to_chat(user, "<span class='warning'>You don't have enough oil left to lubricate [src]!</span>")
			busy = FALSE
			return TRUE
		user.visible_message("<span class='notice'>[user] lubricates [src].</span>", \
					"<span class='notice'>You lubricate the inner workings of [src].</span>")
		durability = min(durability + (oil_amount * repair_multiplier), max_durability)
		I.reagents.remove_reagent(/datum/reagent/oil, oil_amount)
		busy = FALSE
		return TRUE
	if(jammed && I.tool_behaviour == TOOL_CROWBAR)
		if(panel_open)
			to_chat(user, "<span class='notice'>You need to close the panel to get at the jammed machinery.</span>")
			return TRUE
		busy = TRUE
		user.visible_message("<span class='notice'>[user] begins clearing the jam in [src].</span>", \
					"<span class='notice'>You being clearing the jam in [src].</span>")
		if(!do_after(user, 10 SECONDS, target=src))
			busy = FALSE
			to_chat(user, "<span class='warning'>You were interrupted!</span>")
			return TRUE
		user.visible_message("<span class='notice'>[user] clears the jam in [src].</span>", \
					"<span class='notice'>You clear the jam in [src].</span>")
		playsound(src, 'nsv13/sound/effects/ship/mac_load_unjam.ogg', 100, 1)
		jammed = FALSE
		durability += rand(0,5) //give the poor fools a few more uses if they're lucky
		busy = FALSE
		return TRUE
	if(istype(I, /obj/item/ship_weapon/ammunition) || istype(I, /obj/item/powder_bag))
		to_chat(user, "<span class='notice'>You start to load [src] with [I].</span>")
		if(!do_after(user, 0.5 SECONDS , target = src))
			to_chat(user, "<span class='warning'>You were interrupted!</span>")
			return TRUE
		load(I, user)
		return TRUE
	return ..()

/obj/machinery/ammo_sorter/AltClick(mob/user)
	. = ..()
	setDir(turn(src.dir, -90))

/obj/machinery/ammo_sorter/ex_act(severity, target)
	for(var/obj/item/X in loaded)
		X.ex_act(severity, target)
	. = ..()

/obj/machinery/ammo_sorter/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/M = I
	if(!(M.buffer && istype(M.buffer, /obj/machinery/computer/ammo_sorter)))
		to_chat(user, "<span class='warning'>There is no control console in [M]'s buffer.")
		return TRUE
	var/obj/machinery/computer/ammo_sorter/C = M.buffer
	if(LAZYFIND(C.linked_sorters, src))
		to_chat(user, "<span class='warning'>This sorter is already linked to [C]!")
		return TRUE
	C.linkSorter(src)
	to_chat(user, "<span class='notice'>You link [src] to [C].")
	return TRUE

/obj/machinery/ammo_sorter/Destroy()
	for(var/obj/machinery/computer/ammo_sorter/AS as() in linked_consoles)
		AS.linked_sorters -= src
		AS.ui_update()
	. = ..()

/obj/machinery/ammo_sorter/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='notice'>It's maintenance panel is open, you could probably add some oil to lubricate it.</span>" //it didnt tell the players if this was the case before.
	if(jammed)
		. += "<span class='notice'>It's jammed shut.</span>"	//if it's jammed, don't show durability. only thing they need to know is that it's jammed.
	else
		switch(durability)
			if(71 to 100)
				. += "<span class='notice'>It doesn't need any maintenance right now.</span>"
			if(31 to 70)
				. += "<span class='notice'>It might need some maintenance done soon.</span>"
			if(11 to 30)
				. += "<span class='notice'>It could really do with some maintenance.</span>"
			if(0 to 10)
				. += "<span class='notice'>It's completely wrecked.</span>"
	. += "<br/><span class='notice'>It's currently holding [length(loaded)]/[max_capacity] items:</span>"
	if(length(loaded))
		var/listofitems = list()
		for(var/obj/item/C in loaded)
			var/path = C.type
			if (listofitems[path])
				listofitems[path]["amount"]++
			else
				listofitems[path] = list("name" = C.name, "amount" = 1)
		for(var/i in listofitems)
			. += "<span class='notice'>[listofitems[i]["name"]] x[listofitems[i]["amount"]]</span>"

/obj/machinery/ammo_sorter/RefreshParts()
	max_capacity = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		max_capacity += MB.rating+3
	if(max_capacity < length(loaded))
		pop()

/obj/machinery/ammo_sorter/MouseDrop_T(atom/movable/A, mob/user)
	. = ..()
	if(!isliving(user))
		return FALSE
	//You can store any kind of ammo here for now.
	if(istype(A, /obj/item/ship_weapon/ammunition) || istype(A, /obj/item/powder_bag))
		to_chat(user, "<span class='notice'>You start to load [src] with [A].</span>")
		if(do_after(user, 2 SECONDS , target = src))
			load(A, user)

/obj/machinery/ammo_sorter/Bumped(atom/movable/AM)
	. = ..()
	load(AM) //Try load

/obj/machinery/ammo_sorter/proc/pop()
	var/length = length(loaded)
	if(length)
		return unload(loaded[length])
	return FALSE

/obj/machinery/ammo_sorter/proc/unload(atom/movable/AM)
	if(!loaded.len)
		return FALSE
	if(jammed)
		return FALSE
	// do visuals/sound
	playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	flick("ammorack_dispense", src)
	//Load it out the back.
	loaded -= AM
	AM.forceMove(get_turf(get_step(src, dir)))
	weardown()
	return TRUE

/obj/machinery/ammo_sorter/proc/load(atom/movable/A, mob/user, force)
	if(force && length(loaded) < max_capacity)
		A.forceMove(src)
		loaded += A
		for(var/obj/machinery/computer/ammo_sorter/AS as() in linked_consoles)
			AS.ui_update()
		return TRUE
	if(length(loaded) >= max_capacity)
		if(user)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
		return FALSE
	if(jammed || !(istype(A, /obj/item/ship_weapon/ammunition) || istype(A, /obj/item/powder_bag)))
		return FALSE
	playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	flick("ammorack_dispense", src)
	A.forceMove(src)
	loaded += A
	weardown()
	for(var/obj/machinery/computer/ammo_sorter/AS as() in linked_consoles)
		AS.ui_update()
	return TRUE

/obj/machinery/ammo_sorter/proc/weardown()
	if(jammed)
		return

	// Subtract durability
	if(durability > 0)
		durability -= 1

	// see if we're going to jam
	var/jamchance = (durability > 0 ? CLAMP(-50*log(50, durability/50), 0, 100) : 100)
	if(prob(jamchance))
		jammed = TRUE
		durability = 0

	// Play a warning sound if the loader jams.
	if(jammed)
		playsound(src, 'nsv13/sound/effects/ship/mac_load_jam.ogg', 100, 1)

/obj/machinery/ammo_sorter/upgraded
	circuit = /obj/item/circuitboard/machine/ammo_sorter/upgraded
	max_capacity = 21

// Circuits for ammunition sorters
/obj/item/circuitboard/computer/ammo_sorter
	name = "ammo sorter console (circuitboard)"
	build_path = /obj/machinery/computer/ammo_sorter

/obj/item/circuitboard/machine/ammo_sorter
	name = "ammo sorter (circuitboard)"
	req_components = list(/obj/item/stock_parts/matter_bin = 3)
	build_path = /obj/machinery/ammo_sorter
	needs_anchored = FALSE

/obj/item/circuitboard/machine/ammo_sorter/upgraded
	def_components = list(/obj/item/stock_parts/matter_bin = /obj/item/stock_parts/matter_bin/bluespace) //item capacity of 21 (12+9)
