/obj/item/reagent_containers/hypospray/autoinjector
	name = "autoinjector"
	desc = "An autoinjector, delivers 10u of a desired drug instantly. Compatible with hardsuit intravenous systems."
	icon = 'nsv13/icons/obj/hypospray.dmi'
	icon_state = "autoinjector"
	item_state = "autoinjector"
	amount_per_transfer_from_this = 10
	volume = 10
	reagent_flags = DRAWABLE
	possible_transfer_amounts = list()
	ignore_flags = 1
	fill_icon_thresholds = list(100)
	var/cap_icon_state = "injector_cap"
	var/cap_on = TRUE
	var/cap_lost = FALSE
	var/mutable_appearance/cap_overlay
//Putting caps on them for balance and aesthetics.
/obj/item/reagent_containers/hypospray/autoinjector/Initialize()
	. = ..()
	cap_overlay = mutable_appearance(icon, cap_icon_state)
	if(cap_on)
		add_overlay(cap_overlay, TRUE)

/obj/item/reagent_containers/hypospray/autoinjector/examine(mob/user)
	. = ..()
	if(cap_lost)
		. += "<span class='notice'>The cap seems to be missing.</span>"
	else if(cap_on)
		. += "<span class='notice'>The cap is firmly on to prevent accidental sticking. Alt-click to remove the cap.</span>"
	else
		. += "<span class='notice'>The cap has been taken off. Alt-click to put a cap on.</span>"

/obj/item/reagent_containers/hypospray/autoinjector/AltClick(mob/user)
	if(cap_lost)
		to_chat(user, "<span class='warning'>The cap seems to be missing! Where did it go?</span>")
		return
	var/fumbled = HAS_TRAIT(user, TRAIT_CLUMSY) && prob(5)
	if(cap_on || fumbled)
		cap_on = FALSE
		cut_overlay(cap_overlay, TRUE)
		animate(src, transform = null, time = 2, loop = 0)
		if(fumbled)
			to_chat(user, "<span class='warning'>You fumble with the [src]'s cap! The cap falls onto the ground and simply vanishes. Where the hell did it go?</span>")
			cap_lost = TRUE
		else
			to_chat(user, "<span class='notice'>You remove the cap from the [src].</span>")
			visible_message("<span class='warning'> [user] took the cap off the [src]!</span>")
	else
		cap_on = TRUE
		add_overlay(cap_overlay, TRUE)
		to_chat(user, "<span class='notice'>You put the cap on the [src].</span>")
	update_icon()

/obj/item/reagent_containers/hypospray/autoinjector/attack(mob/M, mob/user, obj/target)
	if(cap_on && reagents.total_volume && istype(M))
		to_chat(user, "<span class='warning'>You must remove the cap before you can do that!</span>")
		return
	. = ..()

/obj/item/reagent_containers/hypospray/autoinjector/afterattack(obj/target, mob/user, proximity)
	if(cap_on && (target.is_refillable() || target.is_drainable() || (reagents.total_volume && user.a_intent == INTENT_HARM)))
		to_chat(user, "<span class='warning'>You must remove the cap before you can do that!</span>")
		return

	else if(istype(target, /obj/item/reagent_containers/hypospray/autoinjector))
		var/obj/item/reagent_containers/hypospray/autoinjector/WB = target
		if(WB.cap_on)
			to_chat(user, "<span class='warning'>[WB] has a cap firmly stuck on!</span>")
	. = ..()

//Self Stabbing
/obj/item/reagent_containers/hypospray/autoinjector/pickup(mob/living/user)
	var/mob/living/carbon/C = user
	if(cap_on == FALSE)
		if(prob(25))
			var/hit_zone = (C.held_index_to_dir(C.active_hand_index) == "l" ? "l_":"r_") + "arm"
			var/obj/item/bodypart/affecting = C.get_bodypart(hit_zone)
			if(affecting)
				if(affecting.receive_damage(1))
					C.update_damage_overlays()
			to_chat(user, "<span class='warning'>You pricked yourself with the [src]!")
			attack(user, user)
		else
			return
	. = ..()

/obj/item/reagent_containers/hypospray/autoinjector/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/hypospray/autoinjector/update_icon(dont_fill=FALSE)
    if(!fill_icon_thresholds || dont_fill)
        return ..()

    cut_overlays()

    if(reagents.total_volume)
        var/fill_name = fill_icon_state? fill_icon_state : icon_state
        var/mutable_appearance/filling = mutable_appearance('nsv13/icons/obj/nsv13_reagentfillings.dmi', "[fill_name][fill_icon_thresholds[1]]")

        var/percent = round((reagents.total_volume / volume) * 100)
        for(var/i in 1 to fill_icon_thresholds.len)
            var/threshold = fill_icon_thresholds[i]
            var/threshold_end = (i == fill_icon_thresholds.len)? INFINITY : fill_icon_thresholds[i+1]
            if(threshold <= percent && percent < threshold_end)
                filling.icon_state = "[fill_name][fill_icon_thresholds[i]]"

        filling.color = mix_color_from_reagents(reagents.reagent_list)
        add_overlay(filling)
