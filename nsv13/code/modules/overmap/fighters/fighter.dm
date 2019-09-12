/obj/structure/overmap/fighter
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	icon_state = "fighter"
	bound_width = 96 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_TINY
	sprite_size = 32
	damage_states = TRUE

/obj/structure/overmap/fighter/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	faction = "nanotrasen"

/obj/structure/overmap/fighter/ai/syndicate
	faction = "syndicate"

/obj/structure/overmap/fighter/attack_hand(mob/user)
	. = ..()
	if(!pilot)
		to_chat(user, "<span class='notice'>You start to climb into [src]...</span>")
		if(do_after(user, 20, target=src))
			start_piloting(user, "all_positions")