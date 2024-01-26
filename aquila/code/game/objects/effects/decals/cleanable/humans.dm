#define isexacttype(A, B) (typesof(A).len == typesof(B).len)

/obj/effect/decal/cleanable/blood
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
