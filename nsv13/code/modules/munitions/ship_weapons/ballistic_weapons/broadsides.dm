/obj/machinery/ship_weapon/broadside
	name = "\improper SN 'Sucker Punch' Broadside Cannon"
	icon = 'nsv13/icons/obj/broadside.dmi'
	icon_state = "broadside"
	desc = "Line 'em up, knock 'em down."
	anchored = TRUE

	density = TRUE
	safety = FALSE

	bound_width = 64
	bound_height = 128
	ammo_type = /obj/item/ship_weapon/ammunition/broadside_shell
	circuit = /obj/item/circuitboard/machine/broadside

	weapon_datum_type = /datum/overmap_ship_weapon/broadside

	auto_load = TRUE
	semi_auto = TRUE
	maintainable = FALSE
	max_ammo = 5
	feeding_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav'
	fed_sound = null
	chamber_sound = null

	load_delay = 20
	unload_delay = 20
	fire_animation_length = 2 SECONDS

	feed_delay = 0
	chamber_delay_rapid = 0
	chamber_delay = 0
	bang = TRUE
	bang_range = 5
	var/next_sound = 0

	var/soot = 0 //!How dirty the gun is
	var/stovepipe = FALSE //!Whether the shell is jammed in the gun
	var/busy = FALSE

/obj/machinery/ship_weapon/broadside/north
	dir = NORTH

/obj/item/circuitboard/machine/broadside
	name = "circuit board (broadside)"
	desc = "Man the cannons!"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 20,
		/obj/item/stack/sheet/iron = 50,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/matter_bin = 6,
		/obj/item/ship_weapon/parts/firing_electronics = 1
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	build_path = /obj/machinery/ship_weapon/broadside

/obj/item/circuitboard/machine/broadside/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/machine/broadside/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

/obj/machinery/ship_weapon/broadside/animate_projectile(atom/target)
	var/obj/item/ship_weapon/ammunition/broadside_shell/T = chambered
	if(T)
		linked.fire_projectile(T.projectile_type, target, firing_flags = linked_overmap_ship_weapon.weapon_firing_flags)

/obj/machinery/ship_weapon/broadside/examine()
	. = ..()
	switch(maint_state)
		if(MSTATE_CLOSED)
			pop(.)
		if(MSTATE_UNSCREWED)
			pop(.)
		if(MSTATE_UNBOLTED)
			pop(.)
	if(panel_open)
		. += "The maintenance panel is <b>unscrewed</b> and the machinery could be <i>pried out</i>. You could flip the cannon by rotating the <u>bolts</u>. You can disengage the shell locks <b>electronically</b>."
	else
		. += "The maintenance panel is <b>closed</b> and could be <i>screwed open</i>."
	. += "<span class ='notice'>It has [get_ammo()]/[max_ammo] shells loaded.</span>"
	if(stovepipe)
		. += "<span class ='warning'>It's stovepiped! You need to <i>pry</i> the jammed shell out!</span>"
	switch(soot)
		if(0)
			. += "<span class ='notice'>It's as clean as the day it was haphazardly welded together.</span>"
		if(1 to 20)
			. += "<span class ='notice'>It's got some soot caked on, could use a clean soon.</span>"
		if(21 to 40)
			. += "<span class ='notice'>It's getting dirty, definitely needs a good cleaning.</span>"
		if(41 to 60)
			. += "<span class ='notice'>It's got soot caked on good, it needs to cleaned.</span>"
		if(61 to 80)
			. += "<span class ='warning'>It's hard to see any metal under all that black, it's dangerous to operate like this.</span>"
		if(81 to 100)
			. += "<span class ='warning'>It's completely coated, the gun's practically useless like this until it gets cleaned.</span>"

/obj/machinery/ship_weapon/broadside/screwdriver_act(mob/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "broadside_open", "broadside", tool)

/obj/machinery/ship_weapon/broadside/wrench_act(mob/user, obj/item/tool)
	if(panel_open)
		tool.play_tool_sound(src, 50)
		switch(dir)
			if(NORTH)
				setDir(SOUTH)
				to_chat(user, "<span class='notice'>You rotate the bolts, swiveling the cannon to Port</span>")
			if(SOUTH)
				setDir(NORTH)
				to_chat(user, "<span class='notice'>You rotate the bolts, swiveling the cannon to Starboard</span>")
		return TRUE

/obj/machinery/ship_weapon/broadside/crowbar_act(mob/user, obj/item/tool)
	if(panel_open && !stovepipe)
		default_deconstruction_crowbar(tool)
		return TRUE
	if(busy)
		return TRUE
	if(stovepipe) //How to fix a stovepiped shell
		tool.play_tool_sound(src, 50)
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		busy = TRUE
		if(do_after(user, 5 SECONDS, target = src))
			stovepipe = FALSE
			to_chat(user, "<span class='notice'>You free the jammed shell, the [src] is safe to use again!</span>")
			cut_overlay("[dir]_broadside_stovepipe")
			if(dir == SOUTH)
				var/obj/R = new /obj/item/ship_weapon/parts/broadside_casing(get_ranged_target_turf(src, NORTH, 4)) //Right
				var/turf/S = get_offset_target_turf(src, rand(5)-rand(5), 5+rand(5)) //Starboard
				R.throw_at(S, 12, 20)
			else
				var/obj/L = new /obj/item/ship_weapon/parts/broadside_casing(get_ranged_target_turf(src, SOUTH, 1)) //Left
				var/turf/P = get_offset_target_turf(src, rand(5)-rand(5), 0-rand(5)) //Port
				L.throw_at(P, 12, 20)
		busy = FALSE
		return TRUE
	return FALSE

/obj/machinery/ship_weapon/broadside/multitool_act(mob/user, obj/item/tool)
	if(!panel_open)
		..()
		return TRUE
	else
		if(length(ammo) == 0)
			to_chat(user, "<span class='warning'>There are no shells to unload!</span>")
			return TRUE
		else
			playsound(src, 'sound/machines/locktoggle.ogg', 100, TRUE)
			to_chat(user, "<span class='notice'>You release the magnetic locks, the shells come loose!</span>")
			unload()
			update_overlay()
			playsound(src, 'sound/effects/bang.ogg', 100, TRUE)
			return TRUE

/obj/machinery/ship_weapon/broadside/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(RefreshParts)), world.tick_lag)

/obj/machinery/ship_weapon/broadside/overmap_fire(atom/target)
	if(world.time >= next_sound) //Prevents ear destruction from soundspam
		overmap_sound()
		next_sound = world.time + 1 SECONDS
	if(overlay)
		overlay.do_animation()
	animate_projectile(target)

/obj/machinery/ship_weapon/broadside/fire(atom/target, shots = linked_overmap_ship_weapon.burst_size, manual = TRUE)
	. = ..()
	if(.)
		new /obj/effect/particle_effect/muzzleflash(loc)
		if(dir == SOUTH)
			var/turf/A = get_offset_target_turf(src, 0, 4)
			var/turf/B = get_offset_target_turf(src, 1, 4)
			new /obj/effect/particle_effect/smoke(A)
			new /obj/effect/particle_effect/smoke(B)
		else
			var/turf/C = get_offset_target_turf(src, 0, -1)
			var/turf/D = get_offset_target_turf(src, 1, -1)
			new /obj/effect/particle_effect/smoke(C)
			new /obj/effect/particle_effect/smoke(D)

/obj/machinery/ship_weapon/broadside/local_fire(shots = linked_overmap_ship_weapon.burst_size, atom/target) //For the broadside cannons, we want to eject spent casings
	. = ..()
	cut_overlay(list("[dir]_chambered_1", "[dir]_chambered_2", "[dir]_chambered_3", "[dir]_chambered_4", "[dir]_chambered_5"))
	if(dir == SOUTH)
		var/obj/R = new /obj/item/ship_weapon/parts/broadside_casing(get_ranged_target_turf(src, NORTH, 4)) //Right
		var/turf/S = get_offset_target_turf(src, rand(5)-rand(5), 5+rand(5)) //Starboard
		R.throw_at(S, 12, 20)
		var/turf/A = get_offset_target_turf(src, 0, 4)
		var/turf/B = get_offset_target_turf(src, 1, 4)
		for (var/mob/living/M in A)
			if(isliving(M) && !M.incapacitated())
				M.apply_damage(10, BURN)
				M.Stun(5)
				M.Knockdown(50)
				to_chat(M, "<span class='userdanger'>The burning backblast sends you to the floor!</span>")
		for (var/mob/living/M in B)
			if(isliving(M) && !M.incapacitated())
				M.apply_damage(10, BURN)
				M.Stun(5)
				M.Knockdown(50)
				to_chat(M, "<span class='userdanger'>The burning backblast sends you to the floor!</span>")
	else
		var/obj/L = new /obj/item/ship_weapon/parts/broadside_casing(get_ranged_target_turf(src, SOUTH, 1)) //Left
		var/turf/P = get_offset_target_turf(src, rand(5)-rand(5), 0-rand(5)) //Port
		var/turf/C = get_offset_target_turf(src, 0, -1)
		var/turf/D = get_offset_target_turf(src, 1, -1)
		for (var/mob/living/M in C)
			if(isliving(M) && !M.incapacitated())
				M.apply_damage(10, BURN)
				M.Stun(5)
				M.Knockdown(50)
				to_chat(M, "<span class='userdanger'>The burning backblast sends you to the floor!</span>")
		for (var/mob/living/M in D)
			if(isliving(M) && !M.incapacitated())
				M.apply_damage(10, BURN)
				M.Stun(5)
				M.Knockdown(50)
				to_chat(M, "<span class='userdanger'>The burning backblast sends you to the floor!</span>")
		L.throw_at(P, 12, 20)
	soot = min(soot + rand(1,5), 100)
	if(stovepipe)
		if(dir == NORTH)
			explosion(src, 0, 0, 5, 3, FALSE, FALSE, 0, FALSE, TRUE)
		else
			var/turf/E = get_offset_target_turf(src, 0, 3)
			explosion(E, 0, 0, 5, 3, FALSE, FALSE, 0, FALSE, TRUE)
	switch(soot) //Manages the overlays for how dirty the gun is, feels like there's a better way to do this...
		if(0)
			cut_overlay(list("[dir]_broadside_soot_1", "[dir]_broadside_soot_2", "[dir]_broadside_soot_3", "[dir]_broadside_soot_4", "[dir]_broadside_soot_5"))
		if(1 to 20)
			add_overlay("[dir]_broadside_soot_1")
		if(21 to 40)
			cut_overlay("[dir]_broadside_soot_1")
			add_overlay("[dir]_broadside_soot_2")
		if(41 to 60)
			cut_overlay("[dir]_broadside_soot_2")
			add_overlay("[dir]_broadside_soot_3")
		if(61 to 80)
			cut_overlay("[dir]_broadside_soot_3")
			add_overlay("[dir]_broadside_soot_4")
		if(81 to 100)
			cut_overlay("[dir]_broadside_soot_4")
			add_overlay("[dir]_broadside_soot_5")


/obj/effect/particle_effect/muzzleflash //Flash Effect when the weapon fires
	name = "muzzleflash"
	light_range = 3
	light_power = 30
	light_color = LIGHT_COLOR_ORANGE
	light_flags = LIGHT_NO_LUMCOUNT
	light_system = STATIC_LIGHT

/obj/effect/particle_effect/muzzleflash/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/particle_effect/muzzleflash/LateInitialize()
	QDEL_IN(src, 3)

/obj/effect/particle_effect/muzzleflash/Destroy()
	return ..()

//Newer Broadsides features start here

/obj/machinery/ship_weapon/broadside/MouseDrop_T(atom/movable/A, mob/user)
	if(!isliving(user))
		return FALSE
	if(busy)
		return FALSE
	if(stovepipe)
		to_chat(user, "<span class='warning'>The [src] is completely locked up, you have to <i>pry</i> out the stovepiped shell!</span>")
		return FALSE
	..()
	if(istype(A, /obj/structure/closet))
		if(!(locate(/obj/item/ship_weapon/ammunition/broadside_shell) in A.contents))
			to_chat(user, "<span class='warning'>There's nothing in [A] that can be loaded into [src]...</span>")
			return FALSE
		if(length(ammo) >= max_ammo)
			return FALSE
		to_chat(user, "<span class='notice'>You start to load [src] with the contents of [A]...</span>")
		busy = TRUE
		if(do_after(user, 8 SECONDS , target = src))
			if(!(locate(/obj/item/ship_weapon/ammunition/broadside_shell) in A.contents))
				to_chat(user, "<span class='warning'>There's nothing in [A] that can be loaded into [src]...</span>")
				busy = FALSE
				return FALSE
			if(prob(soot)) //likelihood of stovepipe is a lot higher if you crateload the gun
				stovepipe = TRUE
				add_overlay("[dir]_broadside_stovepipe")
				flick("[initial(icon_state)]_chambering",src)
				playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
				to_chat(user, "<span class='warning'>The [src] groans horrendously, a shell has stovepiped!</span>")
				busy = FALSE
				return FALSE
			for(var/obj/item/ship_weapon/ammunition/broadside_shell/G in A)
				if(length(ammo) < max_ammo)
					G.forceMove(src)
					ammo += G
					chambered = G
			if(feeding_sound)
				playsound(src, feeding_sound, 100, 1)
			if(load_sound)
				playsound(src, load_sound, 100, 1)
			flick("[initial(icon_state)]_chambering",src)
			cut_overlay("[dir]_chambered_[get_ammo()]")
			add_overlay("[dir]_chambered_[get_ammo()]")
			state = STATE_CHAMBERED
			update()
		busy = FALSE
	if((ismoth(A) || istype(A, /mob/living/simple_animal/mothroach)) && A != user)
		mothclean(A, user)
		return TRUE

/obj/machinery/ship_weapon/broadside/proc/mothclean(mob/moth, mob/user) //This is an easter egg, let's you clean the gun with moth/roach
	if(!panel_open)
		to_chat(user, "<span class='notice'>You can't reach the barrels unless you <i>unscrew</i> the maintenance panel.</span>")
		return
	if(soot == 0)
		to_chat(user, "<span class='notice'>The [src] is clean as can be, no need for further swabbing.</span>")
		return
	if(busy)
		return
	if(state == STATE_CHAMBERED)
		to_chat(user, "<span class='warning'>You can't clean the [src] while it's loaded!</span>")
		return
	if(stovepipe)
		to_chat(user, "<span class='warning'>The [src] is all jammed up, you can't clean it like this!</span>")
		return
	visible_message("<span class='warning'>[user] is stuffing [moth] into the [src]!</span>", ignored_mobs = list(moth))
	to_chat(moth, "<span class='userdanger'>[user] is shoving you into the [src]!</span>")
	if(do_after(user, 5 SECONDS, target = src, extra_checks = CALLBACK(src, PROC_REF(proximity_check), user, moth)))
		moth.forceMove(src)
		moth.emote("scream")
		playsound(src, 'nsv13/sound/effects/swab.ogg', 100, TRUE)
		while(soot > 0)
			if(!do_after(user, 1 SECONDS, target = src))
				if(dir == NORTH)
					moth.forceMove(get_turf(src))
				else
					moth.forceMove(get_offset_target_turf(src, 0, 3))
				return
			soot -= rand(5,10)
			if(soot <= 0)
				soot = 0
				cut_overlays()
				to_chat(user, "<span class='notice'>The [src] is spic and span!</span>")
				moth.reagents.add_reagent(/datum/reagent/colorful_reagent/powder/black, 5)
				if(dir == NORTH)
					moth.forceMove(get_turf(src))
				else
					moth.forceMove(get_offset_target_turf(src, 0, 3))
				break

/obj/machinery/ship_weapon/broadside/proc/proximity_check(mob/user, mob/moth)
	return user.Adjacent(moth) && user.Adjacent(src)

/obj/machinery/ship_weapon/broadside/chamber(rapidfire = FALSE)
	. = ..()
	cut_overlay("[dir]_chambered_[get_ammo()]")
	add_overlay("[dir]_chambered_[get_ammo()]")
	update()

/obj/machinery/ship_weapon/broadside/load(obj/A, mob/user)
	if(stovepipe)
		to_chat(user, "<span class='warning'>The [src] is completely locked up, you have to <i>pry</i> out the stovepiped shell!</span>")
		return
	if(prob(soot / 10)) //Divides soot by 10 so maximum chance to stovepipe is 10%
		stovepipe = TRUE //find way to send message to TAC that the cannons are stovepiped
		add_overlay("[dir]_broadside_stovepipe")
		flick("[initial(icon_state)]_chambering",src)
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		visible_message("<span class='warning'>The [src] groans horrendously, a shell has stovepiped!</span>")
		qdel(A)
		return
	busy = TRUE
	. = ..()
	busy = FALSE

/obj/item/swabber
	name = "swabber"
	desc = "This a gun barrel swabber, it's covered in cotton and metal bristles. It can be used to clean the broadside's barrels."
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "swabber"
	lefthand_file = 'nsv13/icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/items_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("swabbed", "scrubbed", "plunged", "maintained")
	resistance_flags = FLAMMABLE

/obj/machinery/ship_weapon/broadside/attackby(obj/item/I, user) //why can they queue up a thousand cleaning bars at once?
	if(istype(I, /obj/item/swabber))
		if(busy)
			return
		if(state == STATE_CHAMBERED)
			to_chat(user, "<span class='warning'>You can't clean the [src] while it's loaded!</span>")
			return
		if(stovepipe)
			to_chat(user, "<span class='warning'>The [src] is all jammed up, you can't clean it like this!</span>")
			return
		if(soot == 0)
			to_chat(user, "<span class='notice'>The [src] is clean as a two ton whistle that blows hot steel.</span>")
			return
		if(!panel_open)
			to_chat(user, "<span class='notice'>You can't reach the barrels unless you <i>unscrew</i> the maintenance panel.</span>")
			return
		else
			busy = TRUE
			to_chat(user, "<span class='notice'>You shove the mop deep into gun's barrels to give them a good swab.</span>")
			playsound(src, 'nsv13/sound/effects/swab.ogg', 100, TRUE)
			while(soot > 0)
				if(!do_after(user, 2 SECONDS, target = src))
					busy = FALSE
					return TRUE
				soot -= rand(5,10)
				if(soot <= 0)
					busy = FALSE
					soot = 0
					cut_overlays()
					to_chat(user, "<span class='notice'>The [src] is spic and span!</span>")
					break
	. = ..()
