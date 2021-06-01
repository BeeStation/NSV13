//Allows you to fully automate missile construction
/obj/machinery/missile_builder
	name = "Seegson model 'Ford' robotic autowrench"
	desc = "An advanced robotic arm that can be arrayed with other such devices to form an assembly line for guided munition production. Swipe it with your ID to access maintenance mode options (only on some models!)"
	icon = 'nsv13/icons/obj/munitions/assembly.dmi'
	icon_state = "assemblybase"
	circuit = /obj/item/circuitboard/machine/missile_builder
	anchored = TRUE
	can_be_unanchored = TRUE
	density = TRUE
	speed_process = TRUE
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
	speed_process = FALSE
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
	name = "Ammo sorter console (circuitboard)"
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
	var/max_capacity = 12 //Max cap for holding.
	var/loading = FALSE

/obj/machinery/ammo_sorter/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
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
	. += "<span class='notice'>It's current holding:</span>"
	if(loaded.len)
		for(var/obj/item/C in loaded)
			. += "<br/><span class='notice'>[C].</span>"

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
	unload(loaded[loaded.len])

/obj/machinery/ammo_sorter/proc/unload(atom/movable/AM)
	if(!loaded.len)
		return FALSE
	playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	flick("ammorack_dispense", src)
	loaded -= AM
	//Load it out the back.
	AM.forceMove(get_turf(get_step(src, dir)))

/obj/machinery/ammo_sorter/proc/load(atom/movable/A, mob/user)
	if(loaded.len >= max_capacity)
		if(user)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
		loading = FALSE
		return FALSE
	if(istype(A, /obj/item/ship_weapon/ammunition) || istype(A, /obj/item/powder_bag))
		playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
		flick("ammorack_dispense", src)
		A.forceMove(src)
		loading = FALSE
		loaded += A
		return TRUE
	else
		loading = FALSE
		return FALSE
