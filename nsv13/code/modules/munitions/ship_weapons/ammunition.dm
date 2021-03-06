/obj/item/ship_weapon/ammunition
	var/projectile_type = null //What does the projectile look like on the overmap?
	var/volatility = 0 //Is this ammo likely to go up in flames when hit or burned?
	var/explode_when_hit = FALSE //If the ammo's volatile, can it be detonated by damage? Or just burning it.
	var/climb_time = 20 //Time it takes to climb
	var/climb_stun = 20 //Time to be stunned for after climbing
	var/climbable = FALSE //Can you climb on it?
	var/mob/living/climber //Who is climbing on it

/obj/item/ship_weapon/ammunition/Initialize()
	. = ..()
	if(volatility > 0)
		AddComponent(/datum/component/volatile, volatility, explode_when_hit)

/obj/item/ship_weapon/ammunition/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!climbable)
		return
	if(user == O && iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.mobility_flags & MOBILITY_MOVE)
			climb_torp(user)
			return
	if(!istype(O, /obj/item) || user.get_active_held_item() != O)
		return
	if(iscyborg(user))
		return
	if(!user.dropItemToGround(O))
		return
	if (O.loc != src.loc)
		step(O, get_dir(O, src))

/obj/item/ship_weapon/ammunition/proc/do_climb(atom/movable/A)
	if(climbable)
		density = FALSE
		. = step(A,get_dir(A,src.loc))
		density = TRUE

/obj/item/ship_weapon/ammunition/proc/climb_torp(mob/living/user)
	src.add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] starts climbing onto [src].</span>", \
								"<span class='notice'>You start climbing onto [src]...</span>")
	var/adjusted_climb_time = climb_time
	if(user.restrained()) //climbing takes twice as long when restrained.
		adjusted_climb_time *= 2
	if(isalien(user))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8
	climber = user
	if(do_mob(user, user, adjusted_climb_time))
		if(src.loc) //Checking if torp has been destroyed
			if(do_climb(user))
				user.visible_message("<span class='warning'>[user] climbs onto [src].</span>", \
									"<span class='notice'>You climb onto [src].</span>")
				log_combat(user, src, "climbed onto")
				if(climb_stun)
					user.Stun(climb_stun)
				. = 1
			else
				to_chat(user, "<span class='warning'>You fail to climb onto [src].</span>")
	climber = null
