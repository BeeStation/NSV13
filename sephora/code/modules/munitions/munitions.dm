/obj/structure/munition //CREDIT TO CM FOR THIS SPRITE
	name = "NTP-2 530mm torpedo"
	icon = 'sephora/icons/obj/munition_types.dmi'
	icon_state = "standard"
	desc = "A fairly standard torpedo which is designed to cause massive structural damage to a target. It is fitted with a basic homing mechanism to ensure it always hits the mark."
	anchored = TRUE
	density = TRUE
	var/torpedo_type = /obj/item/projectile/bullet/torpedo //What torpedo type we fire
	pixel_x = -17

/obj/structure/munition/hull_shredder //High damage torp. Use this when youve exhausted their flak.
	name = "NTP-4 'BNKR' 430mm torpedo"
	icon = 'sephora/icons/obj/munition_types.dmi'
	icon_state = "hull_shredder"
	desc = "A heavy torpedo which is packed with a high energy plasma charge, allowing it to impact a target with massive force."
	torpedo_type = /obj/item/projectile/bullet/torpedo/shredder

/obj/structure/munition/fast //Gap closer, weaker but quick.
	name = "NTP-1 'SPD' 430mm high velocity torpedo"
	icon = 'sephora/icons/obj/munition_types.dmi'
	icon_state = "highvelocity"
	desc = "A small torpedo which is fitted with an advanced propulsion system, allowing it to rapidly travel long distances. Due to its smaller frame however, it packs less of a punch."
	torpedo_type = /obj/item/projectile/bullet/torpedo/fast

/obj/structure/munition/decoy //A dud missile designed to exhaust flak
	name = "NTP-0x 'DCY' 530mm electronic countermeasure"
	icon = 'sephora/icons/obj/munition_types.dmi'
	icon_state = "decoy"
	desc = "A simple electronic countermeasure packed inside a standard torpedo casing. This model excels at diverting enemy PDC emplacements away from friendly ships, or even another barrage of missiles."
	torpedo_type = /obj/item/projectile/bullet/torpedo/decoy

/obj/item/projectile/bullet/torpedo/shredder
	icon_state = "torpedo_shredder"
	name = "plasma charge"
	damage = 120

/obj/item/projectile/bullet/torpedo/fast
	icon_state = "torpedo_fast"
	name = "high velocity torpedo"
	damage = 40

/obj/item/projectile/bullet/torpedo/decoy
	icon_state = "torpedo"
	damage = 0

/obj/structure/munition/CtrlClick(mob/user)
	. = ..()
	to_chat(user,"<span class='warning'>[src] is far too cumbersome to carry, and dragging it around might set it off! Load it onto a munitions trolley.</span>")

/obj/structure/munition/examine(mob/user)
	. = ..()
	. += "<span class='warning'>It's far too cumbersome to carry, and dragging it around might set it off!</span>"

/obj/structure/munitions_trolley
	name = "Munitions trolley"
	icon = 'sephora/icons/obj/munitions.dmi'
	icon_state = "trolley"
	desc = "A large trolley designed for ferrying munitions around. It has slots for traditional ammo magazines as well as a rack for loading torpedoes. To load it, click and drag the desired munition onto the rack."
	anchored = FALSE
	density = TRUE
	layer = 3
	var/capacity = 0 //Current number of munitions we have loaded
	var/max_capacity = 3//Maximum number of munitions we can load at once
	var/loading = FALSE //stop you loading the same torp over and over

/obj/structure/munitions_trolley/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/munitions_trolley/AltClick(mob/user)
	. = ..()
	add_fingerprint(user)
	if(!anchored)
		to_chat(user, "<span class='notice'>You toggle the brakes on [src], fixing it in place.</span>")
		anchored = TRUE
	else
		to_chat(user, "<span class='notice'>You toggle the brakes on [src], allowing it to move freely.</span>")
		anchored = FALSE

/obj/structure/munitions_trolley/examine(mob/user)
	. = ..()
	if(anchored)
		. += "<span class='notice'>[src]'s brakes are enabled!</span>"

/obj/structure/munitions_trolley/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(istype(A, /obj/structure/munition))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading something onto [src]!.</span>")
		if(capacity < max_capacity)
			to_chat(user, "<span class='notice'>You start to load [A] onto [src]...</span>")
			loading = TRUE
			if(do_after(user,20, target = src))
				load_trolley(A, src)
				to_chat(user, "<span class='notice'>You load [A] onto [src].</span>")
				loading = FALSE
			loading = FALSE
		else
			to_chat(user, "<span class='warning'>[src] is fully loaded!</span>")

/obj/structure/munitions_trolley/proc/load_trolley(atom/movable/A, mob/user)
//	if(istype(A, /obj/item))
	//	if(!user.transferItemToLoc(A, src))
	//		return
	playsound(src, 'sephora/sound/effects/ship/mac_load.ogg', 100, 1)
	if(istype(A, /obj/structure/munition))
		A.forceMove(src)
		A.pixel_y += 10+(capacity*10)
		vis_contents += A
		capacity ++
		A.layer = ABOVE_MOB_LAYER
		return

/obj/structure/munitions_trolley/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(capacity <= 0)
		return
	user.set_machine(src)
	var/dat
	if(contents.len)
		for(var/X in contents) //Allows you to remove things individually
			var/atom/content = X
			dat += "<a href='?src=[REF(src)];removeitem=\ref[content]'>[content.name]</a><br>"
	dat += "<a href='?src=[REF(src)];unloadall=1'>Unload All</a>"
	var/datum/browser/popup = new(user, "munitions trolley", name, 300, 200)
	popup.set_content(dat)
	popup.open()

/obj/structure/munitions_trolley/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	var/atom/whattoremove = locate(href_list["removeitem"])
	if(whattoremove && whattoremove.loc == src)
		unload_munition(whattoremove)
	if(href_list["unloadall"])
		for(var/atom/movable/A in src)
			unload_munition(A)

/obj/structure/munitions_trolley/proc/unload_munition(atom/movable/A)
	vis_contents -= A
	A.forceMove(get_turf(src))
	A.pixel_y = initial(A.pixel_y) //Remove our offset
	A.layer = initial(A.layer)
	to_chat(usr, "<span class='notice'>You unload [A] from [src].</span>")
	if(istype(A, /obj/structure/munition)) //If a munition, allow them to load other munitions onto us.
		capacity --
	if(contents.len)
		var/count = capacity
		for(var/X in contents)
			var/atom/movable/AM = X
			if(istype(AM, /obj/structure/munition))
				AM.pixel_y = count*10
				count --