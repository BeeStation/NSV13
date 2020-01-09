#define MSTATE_CLOSED 0
#define MSTATE_UNSCREWED 1
#define MSTATE_UNBOLTED 2
#define MSTATE_PRIEDOUT 3

#define STATE_NOTLOADED 1
#define STATE_LOADED 2
#define STATE_CHAMBERED 3
#define STATE_READY 4
#define STATE_FIRING 5

/obj/machinery/ship_weapon //CREDIT TO CM FOR THE SPRITES!
	name = "A ship weapon"
	desc = "Don't use this, use the subtypes"
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "OBC"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/fire_sound = 'nsv13/sound/effects/ship/mac_fire.ogg'
	var/load_sound = 'nsv13/sound/effects/ship/reload.ogg'
	var/safety = TRUE //Can only fire when safeties are off
	var/loading = FALSE
	var/state = STATE_NOTLOADED
	var/obj/structure/overmap/linked = null
	var/maint_state = MSTATE_CLOSED
	var/maint_req = 0 //Number of times a weapon can fire until a maintenance cycle is required. This will countdown to 0.
	var/malfunction = FALSE
	var/obj/item/ship_weapon/ammunition/chambered //What have we got loaded? Extrapolate ammo type from this

/obj/machinery/ship_weapon/Initialize()
	. = ..()
	get_ship()
	maint_req = rand(15,25) //Setting initial number of cycles until maintenance is required
	create_reagents(50)

/obj/machinery/ship_weapon/proc/get_ship()
	var/area/AR = get_area(src)
	if(AR.linked_overmap)
		linked = AR.linked_overmap
		set_position(linked)

/obj/machinery/ship_weapon/proc/set_position(obj/structure/overmap/OM) //Use this to tell your ship what weapon category this belongs in
	return

/obj/machinery/ship_weapon/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/item/ship_weapon/ammunition))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading a round into [src]!.</span>")
		if(!chambered || state == STATE_NOTLOADED)
			to_chat(user, "<span class='notice'>You start to load [A] into [src]...</span>")
			loading = TRUE
			if(do_after(user,20, target = src))
				to_chat(user, "<span class='notice'>You load [A] into [src].</span>")
				loading = FALSE
				A.forceMove(src)
				playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
				chambered = A
				state = STATE_LOADED
			loading = FALSE
		else
			to_chat(user, "<span class='warning'>[src] already has a round loaded!</span>")

/obj/machinery/ship_weapon/proc/load()
	if(state != STATE_LOADED)
		return
	flick("[initial(icon_state)]_loading",src)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/crane_short.ogg', 100, 1)
	sleep(20)
	playsound(src, load_sound, 100, 1)
	icon_state = "[initial(icon_state)]_loaded"
	state = STATE_CHAMBERED

/obj/machinery/ship_weapon/proc/unload()
	if(state < STATE_LOADED)
		return
	flick("[initial(icon_state)]_unloading",src)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/crane_short.ogg', 100, 1)
	sleep(20)
	chambered.forceMove(get_turf(src))
	chambered = null //Cancel fire
	state = STATE_NOTLOADED
	icon_state = initial(icon_state)

/obj/machinery/ship_weapon/proc/chamber(rapidfire = FALSE) //Rapidfire is used for when you want to reload rapidly. This is done for the railgun autoloader so that you can "volley" shots quickly.
	if(state != STATE_CHAMBERED)
		return
	flick("[initial(icon_state)]_chambering",src)
	if(rapidfire)
		sleep(2)
	else
		sleep(10)
	icon_state = "[initial(icon_state)]_chambered"
	playsound(src, 'nsv13/sound/weapons/railgun/ready.ogg', 100, 1)
	state = STATE_READY

/obj/machinery/ship_weapon/proc/fire()
	if(!can_fire())
		return
	var/atom/projectile = null
	if(maint_req <= 0)
		weapon_malfunction()
		return
	spawn(0) //Branch so that there isnt a fire delay for the helm.
		do_animation()
	state = STATE_FIRING
	playsound(src, fire_sound, 100, 1)
	for(var/mob/living/M in get_hearers_in_view(10, get_turf(src))) //Burst unprotected eardrums
		if(M.stat == DEAD || !isliving(M))
			continue
		M.soundbang_act(1,200,10,15)
	projectile = new chambered.type() //Dummy munition in nullspace so we can get its attributes for the ship to fire it.
	qdel(chambered)
	chambered = null
	state = STATE_NOTLOADED
	maint_req --
	after_fire()
	if(projectile) //Looks like we were able to fire a projectile, let's tell the ship what kind of bullet to shoot.
		return projectile

/obj/machinery/ship_weapon/proc/after_fire()
	return

/obj/machinery/ship_weapon/proc/can_fire()
	if(state < STATE_READY || state >= STATE_FIRING || !chambered || malfunction || maint_state != MSTATE_CLOSED)
		return FALSE
	else
		return TRUE

/obj/machinery/ship_weapon/proc/do_animation()
	flick("[initial(icon_state)]_firing",src)
	sleep(5)
	flick("[initial(icon_state)]_unloading",src)
	sleep(5)
	icon_state = initial(icon_state)

/obj/machinery/ship_weapon/proc/weapon_malfunction()
	malfunction = TRUE
	playsound(src, 'sound/effects/alert.ogg', 100, TRUE) //replace this with appropriate sound
	visible_message("<span class=userdanger>Malfunction detected in [src]! Firing sequence aborted!</span>") //perhaps additional flavour text of a non angry red kind?
	for(var/mob/living/M in range(10, get_turf(src)))
		shake_camera(M, 2, 1)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(6, 0, src)
	s.start()
	light_color = LIGHT_COLOR_RED
	set_light(3)


// Ship Weapon Maintenance
/obj/machinery/ship_weapon/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	if(state >= STATE_LOADED && maint_state == MSTATE_CLOSED)
		to_chat(user, "<span class='warning'>You cannot open the maintence panel while [src] is loaded!</span>")
		return TRUE
	else if(state < STATE_LOADED && maint_state == MSTATE_CLOSED)
		to_chat(user, "<span class='notice'>You begin unfastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You unfasten the maintenance panel on [src].</span>")
			maint_state = MSTATE_UNSCREWED
			update_overlay()
			return TRUE
	else if(maint_state == MSTATE_UNSCREWED)
		to_chat(user, "<span class='notice'>You begin fastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You fasten the maintenance panel on [src].</span>")
			maint_state = MSTATE_CLOSED
			update_overlay()
			return TRUE

/obj/machinery/ship_weapon/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	if(maint_state == MSTATE_UNSCREWED)
		to_chat(user, "<span class='notice'>You begin unfastening the inner casing bolts on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unfasten the inner case bolts on [src].</span>")
			maint_state = MSTATE_UNBOLTED
			update_overlay()
			return TRUE
	else if(maint_state == MSTATE_UNBOLTED)
		to_chat(user, "<span class='notice'>You begin fastening the inner casing bolts on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You fasten the inner case bolts on [src].</span>")
			maint_state = MSTATE_UNSCREWED
			update_overlay()
			return TRUE

/obj/machinery/ship_weapon/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	if(maint_state == MSTATE_UNBOLTED)
		to_chat(user, "<span class='notice'>You begin prying the inner casing off [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You pry the inner casing off [src].</span>")
			maint_state = MSTATE_PRIEDOUT
			update_overlay()
			if(prob(50))
				to_chat(user, "<span class='warning'>Oil spurts out of the exposed machinery!</span>")
				new /obj/effect/decal/cleanable/oil(user.loc)
				reagents.clear_reagents()
			return TRUE
	if(maint_state == MSTATE_PRIEDOUT)
		to_chat(user, "<span class='notice'>You begin slotting the inner casing back in [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You slot the inner casing back in [src].</span>")
			maint_state = MSTATE_UNBOLTED
			update_overlay()
			return TRUE

/obj/machinery/ship_weapon/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers))
		if(maint_state != MSTATE_PRIEDOUT)
			to_chat(user, "<span class='notice'>You require access to the inner workings of [src].</span>")
			return
		else if(maint_state == MSTATE_PRIEDOUT)
			if(I.reagents.has_reagent(/datum/reagent/oil, 10))
				to_chat(user, "<span class='notice'>You start lubricating the inner workings of [src]...</span>")
				if(!do_after(user, 2 SECONDS, target=src))
					return
				to_chat(user, "<span class='notice'>You lubricate the inner workings of [src].</span>")
				if(malfunction)
					malfunction = FALSE
					visible_message("<span class='notice'>The red warning lights on [src] fade away.</span>")
					set_light(0)
				maint_req = rand(15,25)
				I.reagents.trans_to(src, 10)
				reagents.clear_reagents()
				return
			else if(I.reagents.has_reagent(/datum/reagent/oil))
				to_chat(user, "<span class='notice'>You need at least 10 units of oil to lubricate [src]!</span>")
				return
			else if(!I.reagents.has_reagent(/datum/reagent/oil))
				visible_message("<span class=warning>Warning: Contaminants detected, flushing systems.</span>")
				new /obj/effect/decal/cleanable/oil(user.loc)
				I.reagents.trans_to(src, 10)
				reagents.clear_reagents()
				return

/obj/machinery/ship_weapon/proc/update_overlay()
	cut_overlays()
	switch(maint_state)
		if(MSTATE_UNSCREWED)
			add_overlay("[initial(icon_state)]_screwdriver")
		if(MSTATE_UNBOLTED)
			add_overlay("[initial(icon_state)]_wrench")
		if(MSTATE_PRIEDOUT)
			add_overlay("[initial(icon_state)]_crowbar")


#undef MSTATE_CLOSED
#undef MSTATE_UNSCREWED
#undef MSTATE_UNBOLTED
#undef MSTATE_PRIEDOUT

#undef STATE_NOTLOADED
#undef STATE_LOADED
#undef STATE_CHAMBERED
#undef STATE_READY
#undef STATE_FIRING