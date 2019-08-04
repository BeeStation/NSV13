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

/obj/structure/munitions_trolley/proc/load_trolley(atom/A, atom/user)
	if(!user.transferItemToLoc(A, src))
		return
	to_chat(user, "<span class='notice'>You load [A] onto [src].</span>")
	return

/obj/structure/munitions_trolley/MouseDrop_T(atom/A, atom/user)
	if(!istype(A, /obj/structure/munition))
		return
	else
		load_trolley(A, atom/user)
		update_icon()

/obj/structure/munitions_trolley/update_icon()
	cut_overlays()
	add_overlay("cart_mop")