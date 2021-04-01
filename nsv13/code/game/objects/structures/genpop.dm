/obj/structure/closet/secure_closet/genpop
	desc = "It's a secure locker for inmates's personal belongings."
	var/default_desc = "It's a secure locker for the storage inmates's personal belongings during their time in prison."
	name = "prisoner closet"
	var/default_name = "prisoner closet"
	req_access = list(ACCESS_BRIG)
	var/obj/item/card/id/prisoner/registered_id = null
	icon = "NSV13/icons/obj/custom_closets.dmi"
	icon_state = "prisoner"
	locked = FALSE
	anchored = TRUE
	opened = TRUE
	density = FALSE

/obj/structure/closet/secure_closet/genpop/attackby(obj/item/W, mob/user, params)
	if(!broken && locked && W == registered_id) //Prisoner opening
		handle_prisoner_id(user)
		return

	return ..()

/obj/structure/closet/secure_closet/genpop/proc/handle_prisoner_id(mob/user)
	var/obj/item/card/id/prisoner/prisoner_id = null
	for(prisoner_id in user.held_items)
		if(prisoner_id != registered_id)
			prisoner_id = null
		else
			break

	if(!prisoner_id)
		to_chat(user, "<span class='danger'>Access Denied.</span>")
		return FALSE

	qdel(registered_id)
	registered_id = null
	locked = FALSE
	open(user)
	desc = "It's a secure locker for prisoner effects."
	to_chat(user, "<span class='notice'>You insert your prisoner id into \the [src] and it springs open!</span>")

	return TRUE

/obj/structure/closet/secure_closet/genpop/proc/handle_edit_sentence(mob/user)
	var/prisoner_name = input(user, "Please input the name of the prisoner.", "Prisoner Name", registered_id.registered_name) as text|null
	if(prisoner_name == null | !user.Adjacent(src))
		return FALSE
	var/sentence_length = input(user, "Please input the length of their sentence in minutes (0 for perma).", "Sentence Length", registered_id.sentence) as num|null
	if(sentence_length == null | !user.Adjacent(src))
		return FALSE
	var/crimes = input(user, "Please input their crimes.", "Crimes", registered_id.crime) as text|null
	if(crimes == null | !user.Adjacent(src))
		return FALSE

	registered_id.registered_name = prisoner_name
	registered_id.sentence = text2num(sentence_length)
	registered_id.crime = crimes
	registered_id.update_label(prisoner_name, registered_id.assignment)

	name = "[default_name] ([prisoner_name])"
	desc = "[default_desc] It contains the personal effects of [prisoner_name]."

	return TRUE

/obj/structure/closet/secure_closet/genpop/togglelock(mob/living/user)
	if(!allowed(user))
		return ..()

	if(!broken && locked && registered_id != null)
		var/name = registered_id.registered_name
		var/result = alert(user, "This locker currently contains [name]'s personal belongings ","Locker In Use","Reset","Amend ID", "Open")
		if(!user.Adjacent(src))
			return
		if(result == "Reset")
			name = default_name
			desc = default_desc
			registered_id = null
		if(result == "Open" | result == "Reset")
			locked = FALSE
			open(user)
		if(result == "Amend ID")
			handle_edit_sentence(user)
			if(alert(user, "Do you want to reset their timer to 0?", "Reset Sentence?", "Yes", "No") == "Yes")
				registered_id.served = 0
	else
		return ..()

/obj/structure/closet/secure_closet/genpop/close(mob/living/user)
	if(registered_id != null)
		locked = TRUE
	return ..()

/obj/structure/closet/secure_closet/genpop/attack_hand(mob/user)
	if(user.lying && get_dist(src, user) > 0)
		return

	if(!broken && registered_id in user.held_items)
		handle_prisoner_id(user)
		return

	if(!broken && opened && !locked && allowed(user) && !registered_id) //Genpop setup

		registered_id = new /obj/item/card/id/prisoner/(src.contents)
		if(handle_edit_sentence(user))
			registered_id.served = 0
			close(user)
			locked = TRUE
			update_icon()
			registered_id.forceMove(src.loc)
		else
			qdel(registered_id)
			registered_id = null

		return

	..()
