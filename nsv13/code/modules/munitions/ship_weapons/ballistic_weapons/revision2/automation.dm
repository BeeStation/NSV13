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
	merge_type = /obj/item/stack/conveyor/slow
	color = list(1,1,0,0, 0,0,0,0, 0,0.1,1,0, 0,0,0,1, 0,0,0,0) //Yellow Belt

/obj/machinery/conveyor/slow
	name = "Slow conveyor"
	subsystem_type = /datum/controller/subsystem/machines
	stack_type = /obj/item/stack/conveyor/slow //What does this conveyor drop when decon'd?
	conveyor_speed = 2 SECONDS
	color = list(1,1,0,0, 0,0,0,0, 0,0.1,1,0, 0,0,0,1, 0,0,0,0) //Yellow Belt

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
