/obj/structure/peacekeeper_barricade //CREDIT TO CM FOR THIS. Cleanup up by Kmc.
	icon = 'nsv13/icons/obj/barricades.dmi'
	climbable = FALSE //Disable climbing.
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	climb_time = 20 //Leaping a barricade is universally much faster than clumsily climbing on a table or rack
	climb_stun = 0
	var/stack_type //The type of stack the barricade dropped when disassembled if any.
	var/stack_amount = 5 //The amount of stack dropped when disassembled at full health
	var/destroyed_stack_amount //to specify a non-zero amount of stack to drop when destroyed
	max_integrity = 100 //Pretty tough. Changes sprites at 300 and 150
	var/base_acid_damage = 2
	var/barricade_resistance = 5 //How much force an item needs to even damage it at all.
	var/barricade_hitsound

	var/barricade_type = "barricade" //"metal", "plasteel", etc.
	var/can_change_dmg_state = TRUE
	var/damage_state = 0
	var/closed = FALSE
	var/can_wire = FALSE
	var/is_wired = FALSE
	var/image/wired_overlay
	var/build_state = 2 // 2 = Fully built.

/obj/structure/peacekeeper_barricade/metal
	name = "metal barricade"
	desc = "A sturdy and easily assembled barricade made of metal plates, often used for quick fortifications. Use a blowtorch to repair."
	icon_state = "metal_0"
	max_integrity = 200
	barricade_resistance = 10
	stack_type = /obj/item/stack/sheet/iron
	stack_amount = 4
	destroyed_stack_amount = 2
	barricade_hitsound = "sound/effects/metalhit.ogg"
	barricade_type = "metal"
	can_wire = TRUE

/obj/structure/peacekeeper_barricade/metal/plasteel
	name = "plasteel barricade"
	desc = "A very sturdy barricade made out of plasteel panels, the pinnacle of strongpoints. Use a blowtorch to repair. Can be flipped down to create a path."
	icon_state = "plasteel_closed_0"
	max_integrity = 400
	barricade_resistance = 20
	stack_type = /obj/item/stack/sheet/plasteel
	stack_amount = 5
	destroyed_stack_amount = 2
	barricade_hitsound = "sound/effects/metalhit.ogg"
	barricade_type = "plasteel"
	density = FALSE
	closed = TRUE
	can_wire = TRUE

/obj/structure/peacekeeper_barricade/metal/plasteel/deployable //Preset one that starts unanchored and placed down.
	icon_state = "plasteel_0"
	closed = FALSE
	density = TRUE
	anchored = FALSE
	build_state = 0

/* You can reenable this when you fix it, KMC.
/obj/structure/peacekeeper_barricade/do_climb(var/mob/living/user)
	if(is_wired) //Ohhh boy this is gonna hurt...
		user.apply_damage(10)
		user.Stun(20) //Leaping into barbed wire is VERY bad
	if(get_turf(user) == get_turf(src))
		usr.forceMove(get_step(src, src.dir))
	else
		usr.forceMove(get_turf(src))
*/
/obj/structure/peacekeeper_barricade/metal/plasteel/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	var/turf/target = get_turf(user)
	if(get_dir(loc, target) & dir) //Don't let people who aren't behind the barricade through, as we plan to have PVP where humans are involved. If the barricade is flipped down, then theyre fine to flip it back up.
		if(!closed)
			user.visible_message("<span class='notice'>[user] leans on [src], trying to force it down!.</span>",
			"<span class='notice'>You lean on [src] to try and force it down!.</span>")
			playsound(src.loc, 'sound/items/jaws_pry.ogg', 25, 1)
			if(!do_after(user, 100, target = src))
				return FALSE
	playsound(src.loc, 'sound/items/ratchet.ogg', 25, 1)
	closed = !closed
	density = !density

	if(closed)
		user.visible_message("<span class='notice'>[user] flips [src] open.</span>",
		"<span class='notice'>You flip [src] open.</span>")
	else
		user.visible_message("<span class='notice'>[user] flips [src] closed.</span>",
		"<span class='notice'>You flip [src] closed.</span>")

	update_icon()
	update_overlay()

/obj/structure/peacekeeper_barricade/Initialize()
	. = ..()
	update_icon()

/obj/structure/peacekeeper_barricade/examine(mob/user)
	. = ..()

	if(is_wired)
		. += "<span class='info'>There is a length of wire strewn across the top of this barricade.</span>"
	switch(damage_state)
		if(0) . += "<span class='info'>It appears to be in good shape.</span>"
		if(1) . += "<span class='warning'>It's slightly damaged, but still very functional.</span>"
		if(2) . += "<span class='warning'>It's quite beat up, but it's holding together.</span>"
		if(3) . += "<span class='warning'>It's crumbling apart, just a few more blows will tear it apart.</span>"

/obj/structure/peacekeeper_barricade/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(AM.throwing && is_wired)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			C.visible_message("<span class='danger'>The barbed wire slices into [C]!</span>",
			"<span class='danger'>The barbed wire slices into you!</span>")
			C.apply_damage(10)
			C.Stun(20) //Leaping into barbed wire is VERY bad
	..()

/obj/structure/peacekeeper_barricade/CheckExit(atom/movable/O, turf/target)
	if(closed || !anchored)
		return TRUE
	if(istype(O, /obj/item/projectile))
		var/obj/item/projectile/S = O
		if(get_turf(S.firer) == get_turf(src)) //This is a pretty safe bet to say that they're allowed to shoot through us.
			return TRUE
		var/edir = get_dir(S.starting,target)
		if(!(edir in GLOB.cardinals)) //Sometimes shit can come in from odd angles, so we need to strip out diagonals
			switch(edir)
				if(NORTHEAST)
					edir = EAST
				if(NORTHWEST)
					edir = WEST
				if(SOUTHEAST)
					edir = EAST
				if(SOUTHWEST)
					edir = WEST
		if(dir & edir) //In other words, theyre shooting the way that we're facing. So that means theyre behind us, and are allowed.
			return TRUE
		else
			return FALSE

	if(O.throwing)
		if(is_wired && iscarbon(O)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE

	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE

/obj/structure/peacekeeper_barricade/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(closed)
		return TRUE
	if(mover && mover.throwing)
		if(is_wired && iscarbon(mover)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE

	if(istype(mover, /obj/vehicle))
		visible_message("<span class='danger'>[mover] drives over and destroys [src]!</span>")
		destroy_structure(0)
		return FALSE

	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && climbable && isliving(mover)) //Climbable objects allow you to universally climb over others
		return TRUE
	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE

/obj/structure/peacekeeper_barricade/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	obj_integrity -= M.melee_damage
	if(barricade_hitsound)
		playsound(src, barricade_hitsound, 25, 1)
	if(obj_integrity <= 0)
		M.visible_message("<span class='danger'>[M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>You slash [src]!</span>", null, 5)
	if(is_wired)
		M.visible_message("<span class='danger'>The barbed wire slices into [M]!</span>",
		"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
		M.apply_damage(10)
	update_health(TRUE)


/obj/structure/peacekeeper_barricade/metal/attackby(obj/item/I, mob/user, params)

	for(var/obj/effect/acid/A in get_turf(src))
		if(A.target == get_turf(src))
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(istype(I, /obj/item/stack/barbed_wire))
		var/obj/item/stack/barbed_wire/B = I
		if(!can_wire)
			return

		user.visible_message("<span class='notice'>[user] starts setting up [I] on [src].</span>",
		"<span class='notice'>You start setting up [I] on [src].</span>")
		if(!do_after(user, 20, target=src) || !can_wire)
			return

		playsound(loc, 'nsv13/sound/effects/barbed_wire_movement.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] sets up [I] on [src].</span>",
		"<span class='notice'>You set up [I] on [src].</span>")

		if(!closed)
			wired_overlay = image('nsv13/icons/obj/barricades.dmi', icon_state = "[barricade_type]_wire")
		else
			wired_overlay = image('nsv13/icons/obj/barricades.dmi', icon_state = "[barricade_type]_closed_wire")

		B.use(1)
		overlays += wired_overlay
		max_integrity += 50
		obj_integrity += 50
		update_health()
		can_wire = FALSE
		is_wired = TRUE
	//	climbable = FALSE
		return FALSE

	if(istype(I, /obj/item/wirecutters))
		if(!is_wired)
			return

		user.visible_message("<span class='notice'>[user] starts to remove the barbed wire on [src].</span>",
		"<span class='notice'>You begin removing the barbed wire on [src].</span>")

		if(!do_after(user, 20, target=src))
			return

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] removes the barbed wire on [src].</span>",
		"<span class='notice'>You remove the barbed wire on [src].</span>")
		overlays -= wired_overlay
		max_integrity -= 50
		obj_integrity -= 50
		update_health()
		can_wire = TRUE
		is_wired = FALSE
		climbable = TRUE
		new /obj/item/stack/barbed_wire(loc)

	if(istype(I, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = I
		if(obj_integrity <= max_integrity * 0.3)
			to_chat(user, "<span class='warning'>[src] has sustained too much structural damage to be repaired.</span>")
			return

		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
			return

		if(!WT.use())
			return

		user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
		"<span class='notice'>You begin repairing the damage to [src].</span>")
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)

		var/old_loc = loc
		if(!do_after(user, 50, target=src) || old_loc != loc)
			return

		user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
		"<span class='notice'>You repair [src].</span>")
		obj_integrity += 150
		update_health()
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)

	switch(build_state)
		if(2) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(istype(I, /obj/item/screwdriver))

				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)

				if(!do_after(user, 10, src))
					return

				user.visible_message("<span class='notice'>[user] removes [src]'s protection panel.</span>",
				"<span class='notice'>You remove [src]'s protection panels, exposing the anchor bolts.</span>")
				build_state = 1
				return FALSE
		if(1) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(istype(I, /obj/item/screwdriver))

				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				if(!do_after(user, 10, target=src))
					return

				user.visible_message("<span class='notice'>[user] set [src]'s protection panel back.</span>",
				"<span class='notice'>You set [src]'s protection panel back.</span>")
				build_state = 2
				return FALSE

			else if(istype(I, /obj/item/wrench))

				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				if(!do_after(user, 10, src))
					return

				user.visible_message("<span class='notice'>[user] loosens [src]'s anchor bolts.</span>",
				"<span class='notice'>You loosen [src]'s anchor bolts.</span>")
				anchored = FALSE
				build_state = 0
				update_icon() //unanchored changes layer
				return FALSE
		if(0) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to resecure anchor bolts
			if(istype(I, /obj/item/wrench))
				for(var/obj/structure/peacekeeper_barricade/B in loc)
					if(B != src && B.dir == dir)
						to_chat(user, "<span class='warning'>There's already a barricade here.</span>")
						return

				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				if(!do_after(user, 10, src))
					return

				user.visible_message("<span class='notice'>[user] secures [src]'s anchor bolts.</span>",
				"<span class='notice'>You secure [src]'s anchor bolts.</span>")
				build_state = 1
				anchored = TRUE
				update_icon() //unanchored changes layer
				return FALSE

			else if(istype(I, /obj/item/crowbar))

				user.visible_message("<span class='notice'>[user] starts unseating [src]'s panels.</span>",
				"<span class='notice'>You start unseating [src]'s panels.</span>")

				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				if(!do_after(user, 50, src))
					return

				user.visible_message("<span class='notice'>[user] takes [src]'s panels apart.</span>",
				"<span class='notice'>You take [src]'s panels apart.</span>")
				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				destroy_structure(TRUE) //Note : Handles deconstruction too !
				return FALSE
	. = ..()

/obj/structure/peacekeeper_barricade/proc/destroy_structure(deconstruct)
	if(deconstruct && is_wired)
		new /obj/item/stack/barbed_wire(loc)
	if(stack_type)
		var/stack_amt
		if(!deconstruct && destroyed_stack_amount)
			stack_amt = destroyed_stack_amount
		else
			stack_amt = round(stack_amount * (obj_integrity/max_integrity)) //Get an amount of sheets back equivalent to remaining health. Obviously, fully destroyed means 0

		if(stack_amt)
			new stack_type (loc, stack_amt)
	qdel(src)

/obj/structure/peacekeeper_barricade/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>[src] is blown apart!</span>")
			qdel(src)
			return
		if(2.0)
			obj_integrity -= rand(33, 66)
		if(3.0)
			obj_integrity -= rand(10, 33)
	update_health()

/obj/structure/peacekeeper_barricade/setDir(newdir)
	. = ..()
	update_icon()

/obj/structure/peacekeeper_barricade/update_icon()
	if(!closed)
		if(can_change_dmg_state)
			icon_state = "[barricade_type]_[damage_state]"
		else
			icon_state = "[barricade_type]"
		switch(dir)
			if(SOUTH)
				layer = ABOVE_MOB_LAYER
			if(NORTH)
				layer = initial(layer) - 0.01
			else
				layer = initial(layer)
		if(!anchored)
			layer = initial(layer)
	else
		if(can_change_dmg_state)
			icon_state = "[barricade_type]_closed_[damage_state]"
		else
			icon_state = "[barricade_type]_closed"
		layer = OBJ_LAYER

/obj/structure/peacekeeper_barricade/proc/update_overlay()
	if(!is_wired)
		return

	overlays -= wired_overlay
	if(!closed)
		wired_overlay = image('nsv13/icons/obj/barricades.dmi', icon_state = "[src.barricade_type]_wire")
	else
		wired_overlay = image('nsv13/icons/obj/barricades.dmi', icon_state = "[src.barricade_type]_closed_wire")
	overlays += wired_overlay

/obj/structure/peacekeeper_barricade/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	update_health()
	playsound(src, "ricochet", 50, TRUE)

/obj/structure/peacekeeper_barricade/proc/update_health(nomessage)
	obj_integrity = CLAMP(obj_integrity, 0, max_integrity)

	if(!obj_integrity)
		if(!nomessage)
			visible_message("<span class='danger'>[src] falls apart!</span>")
		destroy_structure()
		return

	update_damage_state()
	update_icon()

/obj/structure/peacekeeper_barricade/proc/update_damage_state()
	var/health_percent = round(obj_integrity/max_integrity * 100)
	switch(health_percent)
		if(0 to 25) damage_state = 3
		if(25 to 50) damage_state = 2
		if(50 to 75) damage_state = 1
		if(75 to INFINITY) damage_state = 0

/obj/structure/peacekeeper_barricade/AltClick(mob/user)
	. = ..()
	revrotate()

/obj/structure/peacekeeper_barricade/verb/rotate()
	set name = "Rotate Barricade Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>")
		return FALSE

	setDir(turn(dir, 90))
	return

/obj/structure/peacekeeper_barricade/verb/revrotate()
	set name = "Rotate Barricade Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>")
		return FALSE

	setDir(turn(dir, 270))
	return

/obj/item/stack/barbed_wire
	name = "barbed wire"
	desc = "A spiky length of wire."
	icon = 'nsv13/icons/obj/barricades.dmi'
	icon_state = "barbed_wire"
	singular_name = "length"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	throwforce = 5
	throw_speed = 5
	throw_range = 20
	attack_verb = list("hit", "whacked", "sliced")
	max_amount = 20
	merge_type = /obj/item/stack/barbed_wire

//small stack
/obj/item/stack/barbed_wire/five
	amount = 5

//half stack
/obj/item/stack/barbed_wire/ten
	amount = 10

//full stack
/obj/item/stack/barbed_wire/full
	amount = 20
