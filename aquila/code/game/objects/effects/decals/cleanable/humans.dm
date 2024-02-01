#define isexacttype(A, B) (typesof(A).len == typesof(B).len)
 // jaki leń to tutaj wrzucał???? ^^^^
/obj/effect/decal/cleanable/blood
	plane = -1
	var/is_slippery = FALSE
	var/is_old = FALSE
	var/can_dry = TRUE
	var/dry_timer = null

/obj/effect/decal/cleanable/blood/wallsplatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5") //te rzeczy można zmienić na coś bardziej pasującego
	plane = -1

/obj/effect/decal/cleanable/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3")
	var/turf/prev_loc
	var/mob/living/blood_source
	var/skip = FALSE
	var/amount = 3

/obj/effect/decal/cleanable/blood/hitsplatter/Initialize(mapload, blood)
	. = ..()
	if(blood)
		blood_source = blood
	prev_loc = loc

/obj/effect/decal/cleanable/blood/hitsplatter/proc/GoTo(turf/T, var/range, speed = 1)
	for(var/i in 1 to range)
		step_towards(src,T)
		sleep(speed)
		prev_loc = loc
		for(var/atom/A in get_turf(src))
			if(istype(A,/obj/item))
				var/obj/item/I = A
				I.add_mob_blood(blood_source)
				amount--
			if(istype(A, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = A
				if(H.wear_suit)
					H.wear_suit.add_mob_blood(blood_source)
					H.update_inv_wear_suit()
				if(H.w_uniform)
					H.w_uniform.add_mob_blood(blood_source)
					H.update_inv_w_uniform()
				amount--
		if(!amount)
			qdel(src)
			break
	qdel(src)

/obj/effect/decal/cleanable/blood/hitsplatter/Bump(atom/A)
	if(istype(A, /turf/closed/wall))
		if(istype(prev_loc))
			loc = A
			skip = TRUE
			var/mob/living/carbon/human/H = blood_source
			if(istype(H))
				var/obj/effect/decal/cleanable/blood/splatter/B = new(prev_loc)
				if(istype(B))
					B.pixel_x = (dir == EAST ? 32 : (dir == WEST ? -32 : 0))
					B.pixel_y = (dir == NORTH ? 32 : (dir == SOUTH ? -32 : 0))
		else
			loc = A
			QDEL_IN(src, 3)
	qdel(src)

/obj/effect/decal/cleanable/blood/hitsplatter/Destroy()
	if(istype(loc, /turf) && !skip)
		loc.add_mob_blood(blood_source)
	return ..()

/obj/effect/decal/cleanable/blood/examine()
	. = ..()
	if(is_old)
		. += "Looks like it's been here a while.  Eew.<br>"

/obj/effect/decal/cleanable/blood/proc/make_old()
	ASSERT(!is_old)
	dry_timer = null
	name = "dried [name]"

	check_slippery()
	is_old = TRUE
	bloodiness = 0
	var/old_alpha = alpha
	color = BLOOD_DRY_COLOR
	alpha = old_alpha

/obj/effect/decal/cleanable/blood/proc/update_dry_timer()
	if(dry_timer != null)
		deltimer(dry_timer)
		dry_timer = null
	if(can_dry && dry_timer == null)
		dry_timer = addtimer(CALLBACK(src, .proc/make_old), BLOOD_DRY_TIME_MINIMUM + bloodiness * BLOOD_DRY_TIME_PER_BLOODINESS, TIMER_STOPPABLE)

/obj/effect/decal/cleanable/blood/proc/check_slippery()
	var/comp = GetComponent(/datum/component/slippery)

	if(is_slippery && !is_old && bloodiness >= BLOOD_SLIPPERY_TRESHOLD)
		if(comp == null)
			AddComponent(/datum/component/slippery, BLOOD_SLIPPERY_KNOCKDOWN, NO_SLIP_WHEN_WALKING)
	else
		if(comp != null)
			qdel(comp)

/obj/effect/decal/cleanable/blood/proc/make_fresh()
	ASSERT(is_old)
	name = initial(name)

	check_slippery()
	is_old = FALSE
	color = initial(color)
	update_dry_timer()

/obj/effect/decal/cleanable/blood/add_bloodiness(var/amount)
	. = ..()
	if(is_old)
		if(amount > 0)
			make_fresh()
	else
		check_slippery()
		update_dry_timer()

/obj/effect/decal/cleanable/blood/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if(isexacttype(src, /obj/effect/decal/cleanable/blood))
		is_slippery = TRUE
	// we revert the is_old values so that asserts in make_* will pass
	// that's because is_old both corresponds to the initial "desired" value, and the "actual" one
	if(is_old && can_dry)
		is_old = FALSE
		make_old()
	else
		is_old = TRUE
		make_fresh()

/obj/effect/decal/cleanable/blood/splatter/add_bloodiness(var/amount)
	var/before = (bloodiness > MAX_SHOE_BLOODINESS / 2)
	. = ..()
	var/after = (bloodiness > MAX_SHOE_BLOODINESS / 2)
	if(before != after)
		if(bloodiness > MAX_SHOE_BLOODINESS / 2)
			icon_state = pick(list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7"))
		else if(bloodiness <= MAX_SHOE_BLOODINESS / 2)
			icon_state = pick(random_icon_states)

/obj/effect/decal/cleanable/blood/gibs/examine()
	. = ..()
	if(is_old)
		. += "Space Jesus, why didn't anyone clean this up?<br>"

/obj/effect/decal/cleanable/blood/gibs/make_fresh()
	. = ..()
	reagents.del_reagent(/datum/reagent/liquidgibs, 5)
	//qdel(GetComponent(/datum/component/rot/gibs))

