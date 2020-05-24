/obj/structure/fighter_component/underconstruction_fighter
	name = "Incomplete Fighter"
	desc = "An Incomplete Fighter"
	icon = 'icons/obj/bedsheets.dmi'
	icon_state = "sheetwhite"
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	var/build_state = null
	var/fighter_name = null
	var/building = FALSE //Are we currently actively being built by someone?


/obj/structure/fighter_component/underconstruction_fighter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There is an open instruction manual sitting on the [src], the next step reads:</span>"

/obj/structure/fighter_component/underconstruction_fighter/proc/get_part(type)
	if(!type)
		return
	var/atom/movable/desired = locate(type) in contents
	return desired

/obj/structure/fighter_component/underconstruction_fighter/update_icon()
	cut_overlays()
	icon_state = "[initial(icon_state)][build_state]"