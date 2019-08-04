/obj/structure/munition
	name = "test munition"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	desc = "Testing singular munition for testing purposes"
	anchored = TRUE
	density = TRUE

/obj/structure/munitions_trolley
	name = "test munitions trolley"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	desc = "Test trolley for moving test munitions"
	anchored = FALSE
	density = TRUE
	var/capacity = 0
	//pull_force something something 1000 default - set to something else when loaded ie capacity >0
	//gotta increment capacity when a munition is loaded
	//need to actually load and unload that munition
	//also extend examine for when theres munition(s) on the trolley

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

/obj/structure/munitions_trolley/proc/load_trolley(atom/A, mob/user)
	if(!user.transferItemToLoc(A, src))

		return
	to_chat(user, "<span class='notice'>You load [A] onto [src].</span>")
	return

/obj/structure/munitions_trolley/MouseDrop_T(obj/structure/A, mob/user)
	if(istype(A, /obj/structure/munition) && capacity < 1)
		load_trolley(A, src)
		update_icon()
	else if(istype(A, /obj/structure/munition))
		to_chat(user, "<span class='warning'>[src] is fully loaded!</span>")
	else
		return

/obj/structure/munitions_trolley/update_icon()
	cut_overlays()
	add_overlay("cart_mop")