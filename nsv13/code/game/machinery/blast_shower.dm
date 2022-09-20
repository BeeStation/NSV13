/obj/machinery/shower/blast_shower
	name = "blast shower"
	desc = "The RS-455. High pressure shower system guaranteed to remove radiation at unprecedented rates."
	icon = 'nsv13icons/obj/blast_shower.dmi'
	icon_state = "blast_shower"
	density = FALSE
	use_power = NO_POWER_USE

/obj/machinery/shower/blast_shower/wash_mob(mob/living/L)
	SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	L.wash_cream()
	L.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	L.radiation -= min(L.radiation, 15)
	L.damage_clothes(8, BRUTE)
	L.adjustBruteLoss(0.5)
	if(iscarbon(L))
		var/mob/living/carbon/M = L
		. = TRUE
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/blast_shower)
		for(var/obj/item/I in M.held_items)
			wash_obj(I)

		if(M.back && wash_obj(M.back))
			M.update_inv_back(0)

		var/list/obscured = M.check_obscured_slots()

		if(M.head && wash_obj(M.head))
			M.update_inv_head()

		if(M.glasses && !(ITEM_SLOT_EYES in obscured) && wash_obj(M.glasses))
			M.update_inv_glasses()

		if(M.wear_mask && !(ITEM_SLOT_MASK in obscured) && wash_obj(M.wear_mask))
			M.update_inv_wear_mask()

		if(M.ears && !(HIDEEARS in obscured) && wash_obj(M.ears))
			M.update_inv_ears()

		if(M.wear_neck && !(ITEM_SLOT_NECK in obscured) && wash_obj(M.wear_neck))
			M.update_inv_neck()

		if(M.shoes && !(HIDESHOES in obscured) && wash_obj(M.shoes))
			M.update_inv_shoes()

		var/washgloves = FALSE
		if(M.gloves && !(HIDEGLOVES in obscured))
			washgloves = TRUE

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(check_clothes(L))
				to_chat(H, "<span class='warning'>Your clothes will get damaged if you wear them in this shower</span>")
			else
				H.set_hygiene(HYGIENE_LEVEL_CLEAN)
			if(H.wear_suit && wash_obj(H.wear_suit))
				H.update_inv_wear_suit()
			else if(H.w_uniform && wash_obj(H.w_uniform))
				H.update_inv_w_uniform()

			if(washgloves)
				SEND_SIGNAL(H, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

			if(!H.is_mouth_covered())
				H.lip_style = null
				H.update_body()

			if(H.belt && wash_obj(H.belt))
				H.update_inv_belt()

/datum/mood_event/blast_shower
	description = "<span class='warning'>My skin feels raw!.</span>\n"
	mood_change = -4
	timeout = 5 MINUTES

/obj/structure/showerframe/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/titanium))
		balloon_alert(user, "You start constructing the blast shower")
		if(do_after(user, 4 SECONDS, target = src))
			I.use(1)
			balloon_alert(user, "Blast Shower created")
			var/obj/machinery/shower/blast_shower/new_shower = new /obj/machinery/shower/blast_shower(loc)
			new_shower.setDir(dir)
			qdel(src)
			return
	return ..()
