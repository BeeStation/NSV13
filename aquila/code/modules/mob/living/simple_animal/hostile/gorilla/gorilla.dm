/mob/living/simple_animal/hostile/gorilla
	var/diseased = FALSE

/mob/living/simple_animal/hostile/gorilla/AttackingTarget()
	if(client)
		oogaooga()
	var/list/parts = target_bodyparts(target)
	if(parts)
		if(!parts.len)
			return FALSE
		var/obj/item/bodypart/BP = pick(parts)
		BP.dismember()
		return ..()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(prob(80))
			var/atom/throw_target = get_edge_target_turf(L, dir)
			L.throw_at(throw_target, rand(1,2), 7, src)
			if(diseased)
				var/flesh_wound = ran_zone(CHEST, 40)
				if(prob(100-L.getarmor(flesh_wound, "melee")))
					L.ForceContractDisease(new /datum/disease/transformation/jungle_fever())
		else
			L.Unconscious(20)
			visible_message("<span class='danger'>[src] knocks [L] out!</span>")

/mob/living/simple_animal/hostile/gorilla/rabid
	diseased = TRUE
