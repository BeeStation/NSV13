/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = FALSE
	flag = "bullet"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect

/obj/item/projectile/bullet/process_hit(turf/T, atom/target, qdel_self, hit_something = FALSE)
	. = ..()
	if(ishuman(target) && damage && !nodamage)
		var/obj/effect/decal/cleanable/blood/hitsplatter/B = new(target.loc, target)
		playsound(target.loc, 'aquila/sound/effects/bullet_hit.ogg', 100, 1)
		B.add_blood_DNA(return_blood_DNA())
		var/dist = rand(1,7)
		var/turf/targ = get_ranged_target_turf(target, get_dir(starting, target), dist)
		B.GoTo(targ, dist)
