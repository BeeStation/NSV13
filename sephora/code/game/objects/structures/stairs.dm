/obj/structure/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs_down"
	anchored = TRUE
	var/active_stairs = FALSE //The active subtype handles this.
	var/obj/structure/stairs/linked = null //The fake stairs that they have to cross first to go up / down a deck
	var/obj/structure/stairs/master = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/stairs/active/Initialize()
	. = ..()
	var/locate_dir = SOUTH //Find the stairs that start
	switch(dir)
		if(NORTH)
			locate_dir = SOUTH
		if(SOUTH)
			locate_dir = NORTH
		if(EAST)
			locate_dir = WEST
		if(WEST)
			locate_dir = EAST
	var/obj/structure/stairs/paired = locate(/obj/structure/stairs) in(get_step(src,locate_dir))
	if(paired)
		linked = paired
		linked.master = src
	update_icon()

/obj/structure/stairs/update_icon()
	var/turf/T = SSmapping.get_turf_above(get_turf(src)) //Check if there are stairs above us. Otherwise, update our icon to show that we're the final deck / flight of stairs
	if(T)
		var/obj/structure/stairs/target = locate(/obj/structure/stairs) in(T)
		if(!target)
			icon_state = "[initial(icon_state)]_top"
	else
		icon_state = "[initial(icon_state)]_top"

/obj/structure/stairs/active //The stairs that actually move us up..
	icon_state = "stairs_up"
	active_stairs = TRUE

/obj/structure/stairs/Crossed(atom/movable/AM)
	. = ..()
	update_icon()
	if(!active_stairs) //Check if theyre moving the opposite direction of up.
		var/necessary_dir = null //walking down the stairs
		switch(dir)
			if(NORTH)
				necessary_dir = SOUTH
			if(SOUTH)
				necessary_dir = NORTH
			if(EAST)
				necessary_dir = WEST
			if(WEST)
				necessary_dir = EAST
		if(AM.dir == necessary_dir)
			var/turf/T = SSmapping.get_turf_below(get_turf(src))
			if(!T && !istype(T, /turf/open)) //No turf below
				return
			var/obj/structure/stairs/target = locate(/obj/structure/stairs) in(T)
			if(!target)
				return //nothing below
			to_chat(AM, "<span class='notice'>You start descending [src]...</span>")
			if (do_after(AM,20, target = src))
				if(isliving(AM))
					var/mob/living/L = AM
					if(L.pulling)
						L.pulling.forceMove(get_turf(target.master))
				if(target.master) //We do this shitcode so you dont infinitely go up stairs :)
					AM.forceMove(get_turf(target.master))
	if(AM.dir != dir) //they arent facing us, so they cant move up.
		return
	else
		var/turf/T = SSmapping.get_turf_above(get_turf(src))
		if(!T && !istype(T, /turf/open)) //No turf below
			return
		var/obj/structure/stairs/target = locate(/obj/structure/stairs) in(T)
		if(!target)
			return //nothing below
		if(target.linked) //We do this shitcode so you dont infinitely go up stairs :)
			to_chat(AM, "<span class='notice'>You start ascending [src]...</span>")
			if (do_after(AM,20, target = src))
				if(isliving(AM))
					var/mob/living/L = AM
					if(L.pulling)
						L.pulling.forceMove(get_turf(target.linked))
				AM.forceMove(get_turf(target.linked))