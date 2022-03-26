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
	subsystem_type = /datum/controller/subsystem/processing //Needs to go faster than SSmachines
	var/process_delay = 0.5 SECONDS
	var/next_process = 0
	var/arm_icon_state = "welder3"
	var/tier = 1
	var/list/held_components = list() //All the missile construction components that they've put into the arm.
	var/obj/item/arm = null
	var/obj/item/ship_weapon/ammunition/missile/missile_casing/target
	var/munition_types = list(/obj/item/ship_weapon/ammunition/missile/missile_casing, /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing)
	var/list/target_states = list(1, 7, 9) //The target construction state of the missile

/obj/machinery/missile_builder/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It currently holds...</span>"
	for(var/atom/movable/X in held_components)
		. += "<span class='notice'>-[X]</span>"

/obj/machinery/missile_builder/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	. = ..()

/obj/item/stack/conveyor/slow
	name = "Slow conveyor assembly"
	conveyor_type = /obj/machinery/conveyor/slow

/obj/machinery/conveyor/slow
	name = "Slow conveyor"
	subsystem_type = /datum/controller/subsystem/machines
	stack_type = /obj/item/stack/conveyor/slow //What does this conveyor drop when decon'd?

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
	setDir(turn(src.dir, -90))

/obj/machinery/missile_builder/Initialize()
	. = ..()
	arm = new /obj/item(src)
	arm.icon = icon
	arm.icon_state = arm_icon_state
	vis_contents += arm
	arm.mouse_opacity = FALSE

/obj/machinery/missile_builder/Destroy()
	qdel(arm)
	. = ..()

/obj/machinery/missile_builder/process()
	if(world.time < next_process)
		return
	next_process = world.time + process_delay
	var/turf/input_turf = get_turf(get_step(src, src.dir))
	if(target && target.loc != input_turf)
		target = null
		visible_message("[name] shakes its arm melancholically.")
		arm.shake_animation()
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	if(target)
		arm.icon_state = arm_icon_state
		target.state++ //Next step!
		target.check_completion()
		do_sparks(10, TRUE, target)
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		target = null
		return
	for(var/munition_type in munition_types)
		target = locate(munition_type) in input_turf
		if(target)
			break
	if(!target)
		target = null
		arm.icon_state = arm_icon_state
		return
	var/found = FALSE
	for(var/target_state in target_states)
		if(target.state == target_state)
			found = TRUE
			break
	if(!found)
		visible_message("<span class='notice'>[src] sighs.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		target = null
		return FALSE
	src.visible_message("<span class='notice'>[src] whirrs into life!</span>")
	arm.icon_state = "[arm_icon_state]_anim"
	playsound(src, 'sound/items/drill_use.ogg', 70, 1)

/obj/machinery/missile_builder/assembler
	name = "Robotic Missile Part Applicator"
	arm_icon_state = "assembler2"
	desc = "An assembly arm which can slot a multitude of missile components into casings for you! Swipe it with an ID to release its stored components."
	req_one_access = list(ACCESS_MUNITIONS)
	circuit = /obj/item/circuitboard/machine/missile_builder/assembler

/obj/machinery/missile_builder/assembler/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/ship_weapon/parts/missile))
		if(!do_after(user, 0.5 SECONDS, target=src))
			return FALSE
		to_chat(user, "<span class='notice'>You slot [I] into [src], ready for construction.</span>")
		I.forceMove(src)
		held_components += I
	if(istype(I, /obj/item/card/id) && allowed(user))
		to_chat(user, "<span class='warning'>You dump [src]'s contents out.</span>")
		for(var/obj/item/X in held_components)
			X.forceMove(get_turf(src))
			held_components -= X

/obj/machinery/missile_builder/assembler/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/structure/closet))
		if(!LAZYFIND(A.contents, /obj/item/ship_weapon/parts/missile))
			to_chat(user, "<span class='warning'>There's nothing in [A] that can be loaded into [src]...</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to load [src] with the contents of [A]...</span>")
		if(do_after(user, 4 SECONDS , target = src))
			for(var/obj/item/ship_weapon/parts/missile/P in A)
				P.forceMove(src)
				held_components += P

/obj/machinery/missile_builder/assembler/process()
	if(world.time < next_process)
		return
	next_process = world.time + process_delay
	var/turf/input_turf = get_turf(get_step(src, src.dir))
	if(target && target.loc != input_turf)
		target = null
		visible_message("[name] shakes its arm melancholically.")
		arm.shake_animation()
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	if(target)
		var/found = FALSE
		for(var/obj/item/ship_weapon/parts/missile/M in held_components)
			if(M.fits_type && !istype(target, M.fits_type))
				continue
			if(target.state == M.target_state)
				M.forceMove(target)
				held_components -= M
				target.state ++
				found = TRUE
				break
		if(found)
			target.check_completion()
			playsound(src, 'sound/machines/ping.ogg', 50, 0)
			do_sparks(10, TRUE, target)
		target = null
		arm.icon_state = arm_icon_state
		return
	for(var/munition_type in munition_types)
		target = locate(munition_type) in input_turf
		if(target)
			break
	if(!target || !held_components.len)
		target = null
		arm.icon_state = arm_icon_state
		return
	src.visible_message("<span class='notice'>[src] whirrs into life!</span>")
	arm.icon_state = "[arm_icon_state]_anim"
	playsound(src, 'sound/items/drill_use.ogg', 70, 1)

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
	name = "Ammo sorter console (circuitboard)"
	build_path = /obj/machinery/computer/ammo_sorter

/obj/item/circuitboard/machine/ammo_sorter
	name = "Ammo sorter (circuitboard)"
	req_components = list(/obj/item/stock_parts/matter_bin = 3)
	build_path = /obj/machinery/ammo_sorter

/obj/machinery/computer/ammo_sorter
	name = "Ammo Rack Control Console"
	icon_screen = "ammorack"
	circuit = /obj/item/circuitboard/computer/ammo_sorter
	var/id = null
	var/list/linked_sorters = list()

/obj/machinery/computer/ammo_sorter/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ammo_sorter/LateInitialize()
	. = ..()
	for(var/obj/machinery/ammo_sorter/W in GLOB.machines)
		if(istype(W) && W.id == id)
			linked_sorters += W
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
			linked_sorters -= AS
		if("rename")
			if(!AS)
				return
			var/new_name = stripped_input(usr, message="Enter a new name for [AS]", max_length=MAX_CHARTER_LEN)

			if(!new_name)
				return

			AS.name = new_name
			message_admins("[key_name(usr)] renamed an ammo rack to [new_name].")
			log_game("[key_name(usr)] renamed an ammo rack to [new_name].")

/obj/machinery/computer/ammo_sorter/proc/unload_all()
	for(var/obj/machinery/ammo_sorter/AS in linked_sorters)
		AS.unload()

/obj/machinery/computer/ammo_sorter/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/racks_info = list()
	for(var/obj/machinery/ammo_sorter/AS in linked_sorters)
		var/atom/what = null
		if(AS.loaded.len)
			what = AS.loaded[AS.loaded.len]
		racks_info[++racks_info.len] = list("name"=AS.name, "has_loaded"=AS.loaded?.len > 0, "id"="\ref[AS]", "top"=(what ? what.name : "Nothing"))
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
	var/list/loaded = list() //What's loaded in?
	var/max_capacity = 12	//Max cap for holding.
	var/loading = FALSE
	var/durability = 100 //max durability: 100.
	var/jammed = FALSE //if at 0 durability, jam it, handled in weardown().
	var/jamchance = 0 //probability to jam every weardown

/obj/machinery/ammo_sorter/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	if(panel_open && istype(I, /obj/item/reagent_containers))
		if(!jammed)
			if(durability < 100)
				if(I.reagents.has_reagent(/datum/reagent/oil, 1))
					to_chat(user, "<span class='notice'>You start lubricating the inner workings of [src]...</span>")
					if(!do_after(user, 1 SECONDS, target=src))
						return
					if(!I.reagents.has_reagent(/datum/reagent/oil, 1)) //things can change, check again.
						to_chat(user, "<span class='notice'>You don't have enough oil left to lubricate [src]!</span>")
						return
					to_chat(user, "<span class='notice'>You lubricate the inner workings of [src].</span>")
					durability += 10
					if(durability > 100) //if we did an oopsie, set it back to 100.
						durability = 100
					I.reagents.remove_reagent(/datum/reagent/oil, 1)
					return TRUE
				else if(I.reagents.has_reagent(/datum/reagent/oil))
					to_chat(user, "<span class='notice'>You need at least 1 unit of oil to lubricate [src]!</span>")
					return
				else
					to_chat(user, "<span class='notice'>You need oil to lubricate this!</span>")
					return	
			else
				to_chat(user, "<span class='notice'>[src] doesn't need any oil right now!</span>")
		else
			to_chat(user, "<span class='notice'>You can't lubricate a jammed machine!</span>")
	if(jammed && istype(I, /obj/item/crowbar))
		if(!panel_open)
			to_chat(user, "<span class='notice'>You begin clearing the jam...</span>")
			if(!do_after(user, 10 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You clear the jam with the crowbar.</span>")
			playsound(src, 'nsv13/sound/effects/ship/mac_load_unjam.ogg', 100, 1)
			jammed = FALSE
			durability += rand(0,5) //give the poor fools a few more uses if they're lucky
		else
			to_chat(user, "<span class='notice'>You need to close the panel to get at the jammed machinery.</span>")
		return TRUE
	. = ..()

/obj/machinery/ammo_sorter/AltClick(mob/user)
	. = ..()
	setDir(turn(src.dir, -90))

/obj/machinery/ammo_sorter/ex_act(severity, target)
	for(var/obj/item/X in loaded)
		X.ex_act(severity, target)
	. = ..()

/obj/machinery/ammo_sorter/Initialize()
	. = ..()
	for(var/obj/item/I in get_turf(src))
		if(istype(I, /obj/item/ship_weapon/ammunition) || istype(I, /obj/item/powder_bag))
			load(I)

/obj/machinery/ammo_sorter/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return
	var/obj/item/multitool/M = I
	M.buffer = src
	to_chat(user, "<span class='notice'>You add [src] to multitool buffer.</span>")

/obj/machinery/computer/ammo_sorter/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/M = I
	if(M.buffer && istype(M.buffer, /obj/machinery/ammo_sorter))
		if(LAZYFIND(linked_sorters, M.buffer))
			to_chat(user, "<span class='warning'>That sorter is already linked to [src]...")
			return FALSE
		linked_sorters += M.buffer
		to_chat(user, "<span class='warning'>You've linked [M.buffer] to [src]...")

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
	. += "<br/><span class='notice'>It's currently holding:</span>"
	if(loaded.len)
		for(var/obj/item/C in loaded)
			. += "<br/><span class='notice'>[C].</span>"

/obj/machinery/ammo_sorter/RefreshParts()
	max_capacity = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		max_capacity += MB.rating+3

/obj/machinery/ammo_sorter/MouseDrop_T(atom/movable/A, mob/user)
	. = ..()
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
		

/obj/machinery/ammo_sorter/proc/load(atom/movable/A, mob/user)
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
