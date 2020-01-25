#define STATE_CHAMBERED 4

#define MSTATE_CLOSED 0
#define MSTATE_UNSCREWED 1
#define MSTATE_UNBOLTED 2
#define MSTATE_PRIEDOUT 3

/**
 * Give people a hint about what to do.
 */
/obj/machinery/ship_weapon/examine()
	. = ..()
	if(malfunction)
		. += "The maintenance lights are flashing red."
		if(maint_state == MSTATE_CLOSED)
			. += "The maintenance panel is <i>screwed</i> shut."

	if(maint_state == MSTATE_UNSCREWED)
		. += "The maintenance panel is <b>unscrewed</b> and the inner casing is <i>bolted</i> in place."
	else if(maint_state == MSTATE_UNBOLTED)
		. += "The inner casing has been <b>pried away</b> and the parts can be <i>lubricated</i>."

/**
 * The weapon has malfunctioned and needs maintenance. Set the flag and do some effects to let people know.
 */
/obj/machinery/ship_weapon/proc/weapon_malfunction()
	malfunction = TRUE
	playsound(src, malfunction_sound, 100, TRUE)
	visible_message("<span class=userdanger>Malfunction detected in [src]! Firing sequence aborted!</span>") //perhaps additional flavour text of a non angry red kind?
	for(var/mob/living/M in range(10, get_turf(src)))
		shake_camera(M, 2, 1)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(6, 0, src)
	s.start()
	light_color = LIGHT_COLOR_RED
	set_light(3)

/**
 * Unscrews or re-secures the maintenance panel.
 * Transitions from MSTATE_CLOSED to MSTATE_UNSCREWED.
 * Transitions from MSTATE_UNSCREWED to MSTATE_CLOSED.
 * Returns TRUE if handled, FALSE otherwise.
 */
/obj/machinery/ship_weapon/screwdriver_act(mob/user, obj/item/tool)
	if(state >= STATE_CHAMBERED && maint_state == MSTATE_CLOSED)
		to_chat(user, "<span class='warning'>You cannot open the maintence panel while [src] has a round chambered!</span>")
		return TRUE
	else if(state < STATE_CHAMBERED && maint_state == MSTATE_CLOSED)
		to_chat(user, "<span class='notice'>You begin unfastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You unfasten the maintenance panel on [src].</span>")
			maint_state = MSTATE_UNSCREWED
			panel_open = TRUE
			update_overlay()
			return TRUE
	else if(maint_state == MSTATE_UNSCREWED)
		to_chat(user, "<span class='notice'>You begin fastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You fasten the maintenance panel on [src].</span>")
			maint_state = MSTATE_CLOSED
			update_overlay()
			return TRUE
	. = ..()

/**
 * Unbolts or re-secures the inner casing bolts.
 * Transitions from MSTATE_UNSCREWED to MSTATE_UNBOLTED.
 * Transitions from MSTATE_UNBOLTED to MSTATE_UNSCREWED.
 * Returns TRUE if handled, FALSE otherwise.
 */
/obj/machinery/ship_weapon/wrench_act(mob/user, obj/item/tool)
	if(maint_state == MSTATE_UNSCREWED)
		to_chat(user, "<span class='notice'>You begin unfastening the inner casing bolts on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unfasten the inner case bolts on [src].</span>")
			maint_state = MSTATE_UNBOLTED
			update_overlay()
			return TRUE
	else if(maint_state == MSTATE_UNBOLTED)
		to_chat(user, "<span class='notice'>You begin fastening the inner casing bolts on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You fasten the inner case bolts on [src].</span>")
			maint_state = MSTATE_UNSCREWED
			update_overlay()
			return TRUE

/**
 * Removes or re-secures the inner casing to allow maintenance.
 * Transitions from MSTATE_UNBOLTED to MSTATE_PRIEDOUT.
 * Transitions from MSTATE_PRIEDOUT to MSTATE_UNBOLTED.
 * Returns TRUE if handled, FALSE otherwise.
 */
/obj/machinery/ship_weapon/crowbar_act(mob/user, obj/item/tool)
	if(maint_state == MSTATE_UNBOLTED)
		to_chat(user, "<span class='notice'>You begin prying the inner casing off [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You pry the inner casing off [src].</span>")
			maint_state = MSTATE_PRIEDOUT
			update_overlay()
			if(prob(50))
				to_chat(user, "<span class='warning'>Oil spurts out of the exposed machinery!</span>")
				new /obj/effect/decal/cleanable/oil(user.loc)
				reagents.clear_reagents()
			return TRUE
	if(maint_state == MSTATE_PRIEDOUT)
		to_chat(user, "<span class='notice'>You begin slotting the inner casing back in [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You slot the inner casing back in [src].</span>")
			maint_state = MSTATE_UNBOLTED
			update_overlay()
			return TRUE
	. = ..()

/**
 * Tries to use item I to lubricate the machinery.
 */
/obj/machinery/ship_weapon/proc/oil(obj/item/I, mob/user)
	if(maint_state != MSTATE_PRIEDOUT)
		to_chat(user, "<span class='notice'>You require access to the inner workings of [src].</span>")
		return
	else if((maint_state == MSTATE_PRIEDOUT) && istype(I, /obj/item/reagent_containers))
		if(I.reagents.has_reagent(/datum/reagent/oil, 10))
			to_chat(user, "<span class='notice'>You start lubricating the inner workings of [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You lubricate the inner workings of [src].</span>")
			if(malfunction)
				malfunction = FALSE
				visible_message("<span class='notice'>The red warning lights on [src] fade away.</span>")
				set_light(0)
			maint_req = max(maint_req, rand(15,25))
			I.reagents.trans_to(src, 10)
			reagents.clear_reagents()
			return
		else if(I.reagents.has_reagent(/datum/reagent/oil))
			to_chat(user, "<span class='notice'>You need at least 10 units of oil to lubricate [src]!</span>")
			return
		else if(!I.reagents.has_reagent(/datum/reagent/oil))
			visible_message("<span class=warning>Warning: Contaminants detected, flushing systems.</span>")
			new /obj/effect/decal/cleanable/oil(user.loc)
			I.reagents.trans_to(src, 10)
			reagents.clear_reagents()
			return
	else
		to_chat(user, "<span class='notice'>You can't lubricate the [src] with [I]!</span>")

/obj/machinery/ship_weapon/proc/update_overlay()
	cut_overlays()
	switch(maint_state)
		if(MSTATE_UNSCREWED)
			add_overlay("[initial(icon_state)]_screwdriver")
		if(MSTATE_UNBOLTED)
			add_overlay("[initial(icon_state)]_wrench")
		if(MSTATE_PRIEDOUT)
			add_overlay("[initial(icon_state)]_crowbar")

#undef MSTATE_CLOSED
#undef MSTATE_UNSCREWED
#undef MSTATE_UNBOLTED
#undef MSTATE_PRIEDOUT

#undef STATE_CHAMBERED
