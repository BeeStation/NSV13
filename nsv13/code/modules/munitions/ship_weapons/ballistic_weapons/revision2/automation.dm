//Allows you to fully automate missile construction
/obj/machinery/missile_builder
	name = "\improper Seegson model 'Ford' robotic autowrench"
	desc = "An advanced robotic arm that can be arrayed with other such devices to form an assembly line for guided munition production. Swipe it with your ID to access maintenance mode options (only on some models!)"
	icon = 'nsv13/icons/obj/munitions/assembly.dmi'
	icon_state = "assemblybase"
	circuit = /obj/item/circuitboard/machine/missile_builder
	anchored = TRUE
	can_be_unanchored = TRUE
	density = TRUE
	processing_flags = START_PROCESSING_MANUALLY //Does not process.
	///Icon state the arm of this device will have
	var/arm_icon_state = "welder3"
	///An overlay for the machine that varies by its arm icon state. For some reason an item and not an overlay or any kind of effect.
	var/obj/item/arm = null //This being an /item makes me scream.
	///List of valid munition types. These are SUPER DIRTY types. DO NOT TRUST THESE TYPES. If you are reading this, new coder, PLEASE keep a common ancestor if you want to access vars and have the things be basically the same!!
	var/munition_types = list(/obj/item/ship_weapon/ammunition/missile/missile_casing, /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing) //This is super bad but I don't feel like rewriting all of missile / torp casing code so it stays :)
	///The target construction states of the missile
	var/list/target_states = list(1, 7, 9)  //Who would magic number these even *after* having to reference them in machines too?? I am not cleaning up after you.. right now at least. -Delta
	///The turf this assembler is tracking
	var/turf/target_turf
	///The timer that tracks how long the arm should be doing arm things.
	var/active_arm_timer_id
	///Next time a success sound can play.
	var/next_success_sound = 0
	///Next time a fail sound can play.
	var/next_fail_sound = 0

/obj/machinery/missile_builder/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	if(default_deconstruction_crowbar(I))
		return
	. = ..()

/obj/machinery/missile_builder/default_unfasten_wrench(mob/user, obj/item/I, time)
	. = ..()
	if(. != SUCCESSFUL_UNFASTEN)
		return
	if(anchored) //just got anchored
		target_turf = get_turf(get_step(src, src.dir))
		if(target_turf)
			RegisterSignal(target_turf, COMSIG_ATOM_ENTERED, PROC_REF(attempt_assembler_action))
	else //just got unanchored
		if(target_turf)
			UnregisterSignal(target_turf, COMSIG_ATOM_ENTERED)
			target_turf = null

/obj/item/stack/conveyor/slow
	name = "Slow conveyor assembly"
	conveyor_type = /obj/machinery/conveyor/slow

/obj/machinery/conveyor/slow
	name = "Slow conveyor"
	subsystem_type = /datum/controller/subsystem/machines
	stack_type = /obj/item/stack/conveyor/slow //What does this conveyor drop when decon'd?
	conveyor_speed = 2 SECONDS

/obj/machinery/missile_builder/wirer
	name = "Seegson model 'Ford' robotic autowirer"
	target_states = list(8)
	circuit = /obj/item/circuitboard/machine/missile_builder/wirer

/obj/machinery/missile_builder/welder
	name = "Seegson model 'Ford' robotic autowelder"
	target_states = list(10)
	circuit = /obj/item/circuitboard/machine/missile_builder/welder

/obj/machinery/missile_builder/screwdriver
	name = "Seegson model 'Ford' robotic bolt driver"
	target_states = list(3,5)
	circuit = /obj/item/circuitboard/machine/missile_builder/screwdriver

/obj/machinery/missile_builder/AltClick(mob/user)
	. = ..()
	if(target_turf)
		UnregisterSignal(target_turf, COMSIG_ATOM_ENTERED)
		target_turf = null
	setDir(turn(src.dir, -90))
	target_turf = get_turf(get_step(src, src.dir))
	if(target_turf)
		RegisterSignal(target_turf, COMSIG_ATOM_ENTERED, PROC_REF(attempt_assembler_action))

/obj/machinery/missile_builder/Initialize(mapload)
	. = ..()
	arm = new /obj/item(src) //WHY IS THIS AN ITEM (worse, basetype..) and not an overlay or something else that would make more sense?!
	arm.icon = icon
	arm.icon_state = arm_icon_state
	vis_contents += arm
	arm.mouse_opacity = FALSE
	target_turf = get_turf(get_step(src, src.dir))
	if(target_turf)
		RegisterSignal(target_turf, COMSIG_ATOM_ENTERED, PROC_REF(attempt_assembler_action)) //aaa

/obj/machinery/missile_builder/Destroy()
	qdel(arm)
	if(target_turf)
		UnregisterSignal(target_turf, COMSIG_ATOM_ENTERED)
		target_turf = null
	if(active_arm_timer_id)
		deltimer(active_arm_timer_id)
		active_arm_timer_id = null
	return ..()

/**
 * This beautiful proc handles interacting with objects that enter the turf we watch. Which is much more effective than processing all the time.
 * * Does not return anything. SHOULD NOT RETURN ANYTHING.
**/
/obj/machinery/missile_builder/proc/attempt_assembler_action(turf/source, atom/movable/entering, old_loc, old_locs)
	SIGNAL_HANDLER
	if(QDELETED(entering)) //How would this happen? Who knows.. but this is NSV after all.
		return
	if(!isobj(entering) || iseffect(entering))
		return
	if(!(entering.type in munition_types))
		visible_message("[src] shakes its arm melancholically.")
		arm.shake_animation()
		if(world.time >= next_fail_sound)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			next_fail_sound = world.time + 0.2 SECONDS
		return
	switch(entering.type) //This is VERY BAD but they do not share a common type.
		if(/obj/item/ship_weapon/ammunition/missile/missile_casing)
			var/obj/item/ship_weapon/ammunition/missile/missile_casing/missile_target = entering
			if(!(missile_target.state in target_states))
				visible_message("<span class='notice'>[src] sighs.</span>")
				if(world.time >= next_fail_sound)
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
					next_fail_sound = world.time + 0.5 SECONDS
				return
			trigger_arm_animation()
			missile_target.state++ //Next step!
			missile_target.check_completion()
			if(world.time >= next_success_sound)
				do_sparks(4, TRUE, missile_target)
				playsound(src, 'sound/items/welder.ogg', 100, 1)
				next_success_sound = world.time + 0.2 SECONDS
		if(/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing)
			var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/torpedo_target = entering
			if(!(torpedo_target.state in target_states))
				visible_message("<span class='notice'>[src] sighs.</span>")
				if(world.time >= next_fail_sound)
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
					next_fail_sound = world.time + 0.5 SECONDS
				return
			trigger_arm_animation()
			torpedo_target.state++ //Next step!
			torpedo_target.check_completion()
			if(world.time >= next_success_sound)
				do_sparks(4, TRUE, torpedo_target)
				playsound(src, 'sound/items/welder.ogg', 100, 1)
				next_success_sound = world.time + 0.2 SECONDS
		else
			CRASH("Please stop handing the missile assemblers invalid types as valid ammunition. Type: [entering.type]. ALL valid casings must be missile or torpedo types.")

//overrides parent.
/obj/machinery/missile_builder/assembler/attempt_assembler_action(turf/source, atom/movable/entering, old_loc, old_locs)
	if(QDELETED(entering)) //How would this happen? Who knows.. but this is NSV after all.
		return
	if(!isobj(entering) || iseffect(entering))
		return
	if(entering.loc != source)
		return
	if(tracked_component_type && tracked_component_type == entering.type) //Please do throw these hungry machines some components.
		var/obj/item/entering_item = entering
		visible_message("<span class='notice'>[src] happily adds [entering_item] to its component storage.</span>")
		if(world.time >= next_success_sound)
			playsound(src, 'sound/machines/ping.ogg', 50, 0)
			next_success_sound = world.time + 0.2 SECONDS
		entering_item.do_pickup_animation(src)
		entering_item.forceMove(src)
		held_components += entering_item
		return
	if(!(entering.type in munition_types))
		visible_message("[src] shakes its arm melancholically.")
		arm.shake_animation()
		if(world.time >= next_fail_sound)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			next_fail_sound = world.time + 0.2 SECONDS
		return
	switch(entering.type) //This is VERY BAD but they do not share a common type.
		if(/obj/item/ship_weapon/ammunition/missile/missile_casing)
			var/obj/item/ship_weapon/ammunition/missile/missile_casing/missile_target = entering
			if(!length(held_components))
				visible_message("<span class='notice'>[src] sighs.</span>")
				if(world.time >= next_fail_sound)
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
					next_fail_sound = world.time + 0.5 SECONDS
				return
			var/obj/item/ship_weapon/parts/missile/missile_part = held_components[1]
			if((missile_part.fits_type && !istype(missile_target, missile_part.fits_type)) || missile_target.state != missile_part.target_state)
				visible_message("<span class='notice'>[src] sighs.</span>")
				if(world.time >= next_fail_sound)
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
					next_fail_sound = world.time + 0.5 SECONDS
				return
			trigger_arm_animation()
			do_item_attack_animation(missile_target, used_item = missile_part)

			missile_target.state++ //Next step!
			missile_part.forceMove(missile_target)
			held_components -= missile_part
			missile_target.check_completion()
			if(world.time >= next_success_sound)
				do_sparks(4, TRUE, missile_target)
				playsound(src, 'sound/machines/ping.ogg', 50, 0)
				next_success_sound = world.time + 0.2 SECONDS
		if(/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing)
			var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/torpedo_target = entering
			if(!length(held_components))
				if(world.time >= next_fail_sound)
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
					next_fail_sound = world.time + 0.5 SECONDS
				return
			var/obj/item/ship_weapon/parts/missile/torpedo_part = held_components[1]
			if((torpedo_part.fits_type && !istype(torpedo_target, torpedo_part.fits_type)) || torpedo_target.state != torpedo_part.target_state)
				if(world.time >= next_fail_sound)
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
					next_fail_sound = world.time + 0.5 SECONDS
				return
			trigger_arm_animation()
			do_item_attack_animation(torpedo_target, used_item = torpedo_part)

			torpedo_target.state++ //Next step!
			torpedo_part.forceMove(torpedo_target)
			held_components -= torpedo_part
			torpedo_target.check_completion()
			if(world.time >= next_success_sound)
				do_sparks(4, TRUE, torpedo_target)
				playsound(src, 'sound/machines/ping.ogg', 50, 0)
				next_success_sound = world.time + 0.2 SECONDS
		else
			CRASH("Please stop handing the missile assemblers invalid types as valid ammunition. Type: [entering.type]. ALL valid casings must be missile or torpedo types.")


///Starts the machine's arm animation to reset after some time.
/obj/machinery/missile_builder/proc/trigger_arm_animation()
	if(arm.icon_state != "[arm_icon_state]_anim")
		arm.icon_state = "[arm_icon_state]_anim"
		visible_message("<span class='notice'>[src] whirrs into life!</span>")
	if(active_arm_timer_id)
		deltimer(active_arm_timer_id)
	active_arm_timer_id = addtimer(CALLBACK(src, PROC_REF(stop_arm_animation)), 1 SECONDS, TIMER_STOPPABLE)

///Stops the machine's arm animation after some time.
/obj/machinery/missile_builder/proc/stop_arm_animation()
	arm.icon_state = arm_icon_state
	active_arm_timer_id = null

/obj/machinery/missile_builder/assembler
	name = "Robotic Missile Part Applicator"
	arm_icon_state = "assembler2"
	desc = "An assembly arm which can slot a multitude of missile components into casings for you! Swipe it with an ID to release its stored components."
	req_one_access = list(ACCESS_MUNITIONS)
	circuit = /obj/item/circuitboard/machine/missile_builder/assembler
	///Currently loaded missile components.
	var/list/held_components = list()
	///Currently tracked type for autopickup
	var/tracked_component_type = null

/obj/machinery/missile_builder/assembler/examine(mob/user)
	. = ..()
	if(!length(held_components))
		return
	. += "<span class='notice'>It currently holds...</span>"
	var/listofitems = list()
	for(var/obj/item/C in held_components)
		var/path = C.type
		if(listofitems[path])
			listofitems[path]["amount"]++
		else
			listofitems[path] = list("name" = C.name, "amount" = 1)
	for(var/i in listofitems)
		. += "<span class='notice'>[listofitems[i]["name"]] x[listofitems[i]["amount"]]</span>"

/obj/machinery/missile_builder/assembler/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/ship_weapon/parts/missile))
		if(!do_after(user, 0.5 SECONDS, target=src))
			return FALSE
		to_chat(user, "<span class='notice'>You slot [I] into [src], ready for construction.</span>")
		I.forceMove(src)
		held_components += I
		tracked_component_type = I.type
	if(istype(I, /obj/item/card/id) && allowed(user))
		to_chat(user, "<span class='warning'>You dump [src]'s contents out.</span>")
		for(var/obj/item/X in held_components)
			X.forceMove(get_turf(src))
			held_components -= X
		tracked_component_type = null

/obj/machinery/missile_builder/assembler/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(!isliving(user))
		return FALSE
	if(istype(A, /obj/structure/closet))
		if(!LAZYFIND(A.contents, /obj/item/ship_weapon/parts/missile))
			to_chat(user, "<span class='warning'>There's nothing in [A] that can be loaded into [src]...</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to load [src] with the contents of [A]...</span>")
		if(do_after(user, 4 SECONDS , target = src))
			for(var/obj/item/ship_weapon/parts/missile/P in A)
				P.forceMove(src)
				held_components += P

/datum/design/board/ammo_sorter_computer
	name = "Ammo sorter console (circuitboard)"
	desc = "The central control console for ammo sorters.."
	id = "ammo_sorter_computer"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/computer/ammo_sorter
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/ammo_sorter
	name = "Ammo sorter (circuitboard)"
	desc = "A helpful storage unit that allows for mass storage of ammunition, with the ability to retrieve it all from a central console."
	id = "ammo_sorter"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/ammo_sorter
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

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

/obj/machinery/computer/ammo_sorter
	name = "ammo rack control console"
	icon_screen = "ammorack"
	circuit = /obj/item/circuitboard/computer/ammo_sorter
	var/id = null
	var/list/linked_sorters = list()

/obj/machinery/computer/ammo_sorter/Initialize(mapload, obj/item/circuitboard/C)
	..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ammo_sorter/LateInitialize()
	. = ..()
	for(var/obj/machinery/ammo_sorter/W in GLOB.machines)
		if(istype(W) && W.id == id)
			linkSorter(W)
	sortList(linked_sorters) //Alphabetise the list initially...

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
			AS.pop()
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

/obj/machinery/computer/ammo_sorter/proc/unload_all()
	for(var/obj/machinery/ammo_sorter/AS as() in linked_sorters)
		AS.unload()

/obj/machinery/computer/ammo_sorter/proc/linkSorter(var/obj/machinery/ammo_sorter/AS)
	linked_sorters += AS
	AS.linked_consoles += src
	ui_update()

/obj/machinery/computer/ammo_sorter/proc/unlinkSorter(var/obj/machinery/ammo_sorter/AS)
	linked_sorters -= AS
	AS.linked_consoles -= src
	ui_update()

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
	var/loading = FALSE
	var/durability = 100
	var/max_durability = 100
	var/repair_multiplier = 10 // How many points of durability we repair per unit of oil
	var/jammed = FALSE //if at 0 durability, jam it, handled in weardown().
	var/jamchance = 0 //probability to jam every weardown
	var/busy = FALSE

/obj/machinery/ammo_sorter/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		busy = FALSE // Just in case it gets stuck somehow, you can reset it
		update_icon()
		return
	if(default_deconstruction_crowbar(I))
		return
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already working on [src]!</span>")
		return TRUE
	if(panel_open && istype(I, /obj/item/reagent_containers))
		if(!jammed)
			if(durability < 100)
				if(I.reagents.has_reagent(/datum/reagent/oil))
					// get how much oil we have
					var/oil_amount = min(I.reagents.get_reagent_amount(/datum/reagent/oil), max_durability/repair_multiplier)
					var/oil_needed = CLAMP(round((max_durability-durability)/repair_multiplier), 1, oil_amount)
					oil_amount = min(oil_amount, oil_needed)
					to_chat(user, "<span class='notice'>You start lubricating the inner workings of [src]...</span>")
					busy = TRUE
					if(!do_after(user, 5 SECONDS, target=src))
						busy = FALSE
						return
					if(!I.reagents.has_reagent(/datum/reagent/oil, oil_amount)) //things can change, check again.
						to_chat(user, "<span class='notice'>You don't have enough oil left to lubricate [src]!</span>")
						busy = FALSE
						return TRUE
					to_chat(user, "<span class='notice'>You lubricate the inner workings of [src].</span>")
					durability = min(durability + (oil_amount * repair_multiplier), max_durability)
					I.reagents.remove_reagent(/datum/reagent/oil, oil_amount)
					busy = FALSE
					return TRUE
				else
					to_chat(user, "<span class='notice'>You need oil to lubricate this!</span>")
					return TRUE
			else
				to_chat(user, "<span class='notice'>[src] doesn't need any oil right now!</span>")
				return TRUE
		else
			to_chat(user, "<span class='notice'>You can't lubricate a jammed machine!</span>")
			return TRUE
	if(jammed && I.tool_behaviour == TOOL_CROWBAR)
		if(!panel_open)
			busy = TRUE
			to_chat(user, "<span class='notice'>You begin clearing the jam...</span>")
			if(!do_after(user, 10 SECONDS, target=src))
				busy = FALSE
				return
			to_chat(user, "<span class='notice'>You clear the jam with the crowbar.</span>")
			playsound(src, 'nsv13/sound/effects/ship/mac_load_unjam.ogg', 100, 1)
			jammed = FALSE
			durability += rand(0,5) //give the poor fools a few more uses if they're lucky
			busy = FALSE
		else
			to_chat(user, "<span class='notice'>You need to close the panel to get at the jammed machinery.</span>")
		return TRUE
	return ..()

/obj/machinery/ammo_sorter/AltClick(mob/user)
	. = ..()
	setDir(turn(src.dir, -90))

/obj/machinery/ammo_sorter/ex_act(severity, target)
	for(var/obj/item/X in loaded)
		X.ex_act(severity, target)
	. = ..()

/obj/machinery/ammo_sorter/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in get_turf(src))
		if(istype(I, /obj/item/ship_weapon/ammunition) || istype(I, /obj/item/powder_bag))
			load(I, force = TRUE)

/obj/machinery/ammo_sorter/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/M = I
	if(M.buffer && istype(M.buffer, /obj/machinery/computer/ammo_sorter))
		var/obj/machinery/computer/ammo_sorter/C = M.buffer
		if(LAZYFIND(C.linked_sorters, src))
			to_chat(user, "<span class='warning'>This sorter is already linked to [C]...")
			return TRUE
		C.linkSorter(src)
		to_chat(user, "<span class='warning'>You've linked [src] to [C]...")
	else
		to_chat(user, "<span class='warning'>There is no control console in [M]'s buffer.")
	return TRUE

/obj/machinery/computer/ammo_sorter/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return TRUE
	var/obj/item/multitool/M = I
	M.buffer = src
	to_chat(user, "<span class='notice'>You add [src] to [M]'s buffer.</span>")
	return TRUE

/obj/machinery/computer/ammo_sorter/Destroy()
	for(var/obj/machinery/ammo_sorter/AS as() in linked_sorters)
		AS.linked_consoles -= src
	. = ..()

/obj/machinery/ammo_sorter/Destroy()
	for(var/obj/machinery/computer/ammo_sorter/AS as() in linked_consoles)
		AS.linked_sorters -= src
		AS.ui_update()
	. = ..()

/obj/machinery/ammo_sorter/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='notice'>Its maintenance panel is open, you could probably add some oil to lubricate it.</span>" //it didnt tell the players if this was the case before.
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
	. += "<br/><span class='notice'>It's currently holding [loaded.len]/[max_capacity] items:</span>"
	if(loaded.len)
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
		to_chat(user, "<span class='notice'>You start to load [src] with [A]</span>")
		if(do_after(user, 2 SECONDS , target = src))
			load(A, user)

/obj/machinery/ammo_sorter/Bumped(atom/movable/AM)
	. = ..()
	load(AM) //Try load

/obj/machinery/ammo_sorter/proc/pop()
	var/length = length(loaded)
	if(length)
		unload(loaded[length])

/obj/machinery/ammo_sorter/proc/unload(atom/movable/AM)
	if(!loaded.len)
		return FALSE
	if(jammed)
		playsound(src, 'nsv13/sound/effects/ship/mac_load_jam.ogg', 100, 1)
		return FALSE
	else
		playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
		flick("ammorack_dispense", src)
		loaded -= AM
		//Load it out the back.
		AM.forceMove(get_turf(get_step(src, dir)))
		weardown()


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
		loading = FALSE
		return FALSE
	if(jammed)
		if(istype(A, /obj/item/ship_weapon/ammunition) || istype(A, /obj/item/powder_bag))
			playsound(src, 'nsv13/sound/effects/ship/mac_load_jam.ogg', 100, 1)
			loading = FALSE
			return FALSE
	else
		if(istype(A, /obj/item/ship_weapon/ammunition) || istype(A, /obj/item/powder_bag))
			playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
			flick("ammorack_dispense", src)
			A.forceMove(src)
			loading = FALSE
			loaded += A
			weardown()
			for(var/obj/machinery/computer/ammo_sorter/AS as() in linked_consoles)
				AS.ui_update()
			return TRUE
		else
			loading = FALSE
			return FALSE

/obj/machinery/ammo_sorter/proc/weardown()
	if(durability > 0) //don't go under 0, that's bad
		durability -= 1 //using it wears it down.
	else
		jammed = TRUE // if it's at 0, jam it.
		durability = 0 // in case an admin plays with this and doesn't know how to use it, we reset it here for good measure.
	jamchance = CLAMP(-50*log(50, durability/50), 0, 100) //logarithmic function; at 50 it starts increasing from 0
	if(prob(jamchance))
		jammed = TRUE

/obj/machinery/ammo_sorter/upgraded
	circuit = /obj/item/circuitboard/machine/ammo_sorter/upgraded
	max_capacity = 21
