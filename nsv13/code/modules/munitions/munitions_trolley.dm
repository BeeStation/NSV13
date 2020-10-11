/obj/structure/munitions_trolley
	name = "Munitions trolley"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "trolley"
	desc = "A large trolley designed for ferrying munitions around. It has slots for traditional ammo magazines as well as a rack for loading torpedoes. To load it, click and drag the desired munition onto the rack."
	anchored = FALSE
	density = TRUE
	layer = 3
	var/capacity = 0 //Current number of munitions we have loaded
	var/max_capacity = 4//Maximum number of munitions we can load at once
	var/loading = FALSE //stop you loading the same torp over and over

/obj/structure/munitions_trolley/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/munitions_trolley/AltClick(mob/user)
	. = ..()
	if(!in_range(src, usr))
		return
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
	if(istype(A, /obj/item/ship_weapon/ammunition))
		if(loading)
			to_chat(user, "<span class='notice'>You're already loading something onto [src]!.</span>")
			return
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
	playsound(src, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	if(istype(A, /obj/item/ship_weapon/ammunition))
		A.forceMove(src)
		A.pixel_y = 10+(capacity*10)
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
	attack_hand(usr)

/obj/structure/munitions_trolley/proc/unload_munition(atom/movable/A)
	vis_contents -= A
	A.forceMove(get_turf(src))
	A.pixel_y = initial(A.pixel_y) //Remove our offset
	A.layer = initial(A.layer)
	to_chat(usr, "<span class='notice'>You unload [A] from [src].</span>")
	if(istype(A, /obj/item/ship_weapon/ammunition)) //If a munition, allow them to load other munitions onto us.
		capacity --
	if(contents.len)
		var/count = capacity
		for(var/X in contents)
			var/atom/movable/AM = X
			if(istype(AM, /obj/item/ship_weapon/ammunition))
				AM.pixel_y = count*10
				count --