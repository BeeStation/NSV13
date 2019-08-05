/obj/structure/munition
	name = "test munition"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	desc = "Testing singular munition for testing purposes"
	anchored = TRUE
	density = TRUE

/obj/structure/munitions_trolley
	name = "test munitions trolley"
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	desc = "Test trolley for moving test munitions"
	anchored = FALSE
	density = TRUE
	var/capacity = 0

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

/obj/structure/munitions_trolley/proc/load_trolley(atom/movable/A, mob/user)
	if(istype(A, /obj/item))
		if(!user.transferItemToLoc(A, src))
			return
	if(istype(A, /obj/structure/munition))
		A.forceMove(src)
		vis_contents += A
		capacity = capacity + 1
		return

/obj/structure/munitions_trolley/MouseDrop_T(obj/structure/A, mob/user)
	if(istype(A, /obj/structure/munition) && capacity < 3)
		load_trolley(A, src)
		to_chat(user, "<span class='notice'>You load [A] onto [src].</span>")
	else if(istype(A, /obj/structure/munition))
		to_chat(user, "<span class='warning'>[src] is fully loaded!</span>")
	else
		return

/obj/structure/munitions_trolley/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.set_machine(src)
	var/dat
	if(capacity >0)
		dat += "<a href='?src=[REF(src)];unloadall=1'>Unload All</a>"
	var/datum/browser/popup = new(user, "munitions trolley", name, 300, 200)
	popup.set_content(dat)
	popup.open()

/obj/structure/munitions_trolley/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(href_list["unloadall"])
		var/turf/T = get_turf(src.loc)
		for(var/atom/movable/A in src)
			vis_contents -= A
			A.forceMove(T)
			capacity = capacity - 1
			to_chat(usr, "<span class='notice'>You unload [A] from [src].</span>")