#define MSTATE_CLOSED 0
#define MSTATE_UNSCREWED 1
#define MSTATE_UNBOLTED 2
#define MSTATE_PRIEDOUT 3

#define STATE_NOTLOADED 1
#define STATE_LOADED 2
#define STATE_FED 3
#define STATE_CHAMBERED 4
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
	var/load_sound = 'nsv13/sound/effects/ship/mac_load.ogg'
	var/feeding_sound = 'nsv13/sound/effects/ship/freespace2/crane_short.ogg'
	var/fed_sound = 'nsv13/sound/effects/ship/reload.ogg'
	var/chamber_sound = 'nsv13/sound/weapons/railgun/ready.ogg'

	var/safety = TRUE //Can only fire when safeties are off
	var/loading = FALSE
	var/state = STATE_NOTLOADED
	var/bang = TRUE //Is firing loud?

	var/obj/item/ship_weapon/ammunition/chambered //What have we got loaded? Extrapolate ammo type from this
	var/list/ammo = list()
	var/max_ammo = 1
	var/ammo_type = /obj/item/ship_weapon/ammunition/torpedo
	var/magazine_type = null
	var/semi_auto = FALSE //Does the weapon chamber for us?

	var/maintainable = TRUE //Does the weapon require maintenance?
	var/maint_state = MSTATE_CLOSED
	var/maint_req = 0 //Number of times a weapon can fire until a maintenance cycle is required. This will countdown to 0.
	var/malfunction = FALSE
	var/obj/structure/overmap/linked = null


/obj/machinery/ship_weapon/Initialize()
	. = ..()
	get_ship()
	if(maintainable)
		maint_req = rand(15,25) //Setting initial number of cycles until maintenance is required
	create_reagents(50)

/obj/machinery/ship_weapon/proc/get_ship()
	var/area/AR = get_area(src)
	if(AR.linked_overmap)
		linked = AR.linked_overmap
		set_position(linked)

/obj/machinery/ship_weapon/proc/set_position(obj/structure/overmap/OM) //Use this to tell your ship what weapon category this belongs in
	return

/obj/machinery/ship_weapon/MouseDrop_T(obj/item/A, mob/user)
	. = ..()
	load(A, user)

/obj/machinery/ship_weapon/proc/load(obj/A, mob/user)
	if(istype(A, ammo_type))
		if( ( (state >= STATE_LOADED) && !semi_auto ) || ( semi_auto && (ammo.len < max_ammo) ) )
			if(!loading)
				to_chat(user, "<span class='notice'>You start to load [A] into [src]...</span>")
				loading = TRUE
				if(do_after(user,20, target = src))
					to_chat(user, "<span class='notice'>You load [A] into [src].</span>")
					loading = FALSE
					A.forceMove(src)
					playsound(src, load_sound, 100, 1)
					ammo += A
					state = STATE_LOADED
				loading = FALSE
			else
				to_chat(user, "<span class='notice'>You're already loading a round into [src]!.</span>")
		else
			to_chat(user, "<span class='warning'>[src] is already fully loaded!</span>")
	else if(istype(A, magazine_type))
		// Do magazine load
	else
		to_chat(user, "<span class='warning'>You can't load [A] into [src]!</span>")


/obj/machinery/ship_weapon/proc/feed()
	if(state != STATE_LOADED)
		return
	flick("[initial(icon_state)]_loading",src)
	playsound(src, feeding_sound, 100, 1)
	sleep(20)
	playsound(src, fed_sound, 100, 1)
	icon_state = "[initial(icon_state)]_loaded"
	state = STATE_FED

/obj/machinery/ship_weapon/proc/unload() //Un-feeds and unloads
	if(state < STATE_LOADED)
		return
	if(state == STATE_CHAMBERED)
		unchamber()

	flick("[initial(icon_state)]_unloading",src)
	playsound(src, feeding_sound, 100, 1)
	sleep(10)

	ammo[0].forceMove(get_turf(src))
	ammo -= ammo[0]

	state = STATE_NOTLOADED
	icon_state = initial(icon_state)

	if(ammo.len)
		for(var/obj/ammo in ammo)
			ammo.forceMove(get_turf(src))
			ammo -= ammo

/obj/machinery/ship_weapon/proc/chamber(rapidfire = FALSE) //Rapidfire is used for when you want to reload rapidly. This is done for the railgun autoloader so that you can "volley" shots quickly.
	if(state != STATE_FED)
		return
	flick("[initial(icon_state)]_chambering",src)
	if(rapidfire)
		sleep(2)
	else
		sleep(10)
	icon_state = "[initial(icon_state)]_chambered"
	playsound(src, chamber_sound, 100, 1)
	state = STATE_CHAMBERED

/obj/machinery/ship_weapon/proc/unchamber()
	if(state != STATE_CHAMBERED || !chambered)
		return
	flick("[initial(icon_state)]_chambering",src)
	sleep(10)
	icon_state = "[initial(icon_state)]_loaded"
	playsound(src, fed_sound, 100, 1)
	state = STATE_FED

/obj/machinery/ship_weapon/proc/can_fire()
	if(state < STATE_CHAMBERED || state >= STATE_FIRING || maint_state != MSTATE_CLOSED)
		return FALSE
	if(maintainable && malfunction)
		return FALSE
	if(!chambered)
		return FALSE
	else
		return TRUE

/obj/machinery/ship_weapon/proc/fire()
	if(can_fire())
		spawn(0) //Branch so that there isnt a fire delay for the helm.
		do_animation()
		state = STATE_FIRING
		playsound(src, fire_sound, 100, 1)
		if(bang)
			for(var/mob/living/M in get_hearers_in_view(10, get_turf(src))) //Burst unprotected eardrums
				if(M.stat == DEAD || !isliving(M))
					continue
				M.soundbang_act(1,200,10,15)

		var/atom/projectile = new chambered.type() //Dummy munition in nullspace so we can get its attributes for the ship to fire it.
		ammo -= chambered
		qdel(chambered)
		chambered = null

		if(projectile) //Looks like we were able to fire a projectile, let's tell the ship what kind of bullet to shoot.
			return projectile

	if(maintainable)
		if(maint_req > 0)
			maint_req --
		else
			weapon_malfunction()

/obj/machinery/ship_weapon/proc/after_fire()
	if(!ammo.len)
		state = STATE_NOTLOADED
	else if(!semi_auto)
		state = STATE_FED
	else
		chamber(rapidfire = TRUE)

/obj/machinery/ship_weapon/proc/do_animation()
	flick("[initial(icon_state)]_firing",src)
	sleep(5)
	flick("[initial(icon_state)]_unloading",src)
	sleep(5)
	icon_state = initial(icon_state)

// Ship Weapon Maintenance
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

/obj/machinery/ship_weapon/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	if(state >= STATE_CHAMBERED && maint_state == MSTATE_CLOSED)
		to_chat(user, "<span class='warning'>You cannot open the maintence panel while [src] has a round chambered!</span>")
		return TRUE
	else if(state < STATE_CHAMBERED && maint_state == MSTATE_CLOSED)
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
#undef STATE_FED
#undef STATE_CHAMBERED
#undef STATE_FIRING