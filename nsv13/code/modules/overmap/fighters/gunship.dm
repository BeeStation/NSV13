/obj/machinery/computer/ship/helm/console/gunship
	name = "Gunship Flight Station"
	desc = "A modified console that allows you to interface with the dropship's flight and weapon systems."
	position = (OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)
	circuit = /obj/item/circuitboard/computer/ship/helm/gunship

/obj/item/circuitboard/computer/ship/helm/gunship
	name = "circuit board (dropship gunship computer)"
	build_path = /obj/machinery/computer/ship/helm/console/gunship

/obj/machinery/computer/ship/helm/console/gunship/attack_hand(mob/living/user)
	. = ..()
	var/obj/structure/overmap/OM = has_overmap()
	OM?.start_piloting(user, position)
	ui_interact(user)
	to_chat(user, "<span class='notice'>Small craft use directional keys (WASD in hotkey mode) to accelerate/decelerate in a given direction and the mouse to change the direction of craft.\
			Mouse 1 will fire the selected weapon (if applicable).</span>")
	to_chat(user, "<span class='warning'>=Hotkeys=</span>")
	to_chat(user, "<span class='notice'>Use <b>tab</b> to activate hotkey mode, then:</span>")
	to_chat(user, "<span class='notice'>Use the <b> Ctrl + Scroll Wheel</b> to zoom in / out. \
			Press <b>Space</b> to cycle fire modes. \
			Press <b>X</b> to cycle inertial dampners. \
			Press <b>Alt<b> to cycle the handbrake. \
			Press <b>C<b> to cycle mouse free movement.</span>")

/obj/machinery/computer/ship/helm/console/gunship/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FighterControls")
		ui.open()
		ui.set_autoupdate(TRUE) // Fuel gauge, ammo, etc

/obj/machinery/computer/ship/helm/console/gunship/ui_data(mob/user)
	var/obj/structure/overmap/OM = get_overmap()
	var/list/data = OM.ui_data(user)
	return data

/obj/machinery/computer/ship/helm/console/gunship/ui_act(action, params, datum/tgui/ui)
	var/obj/structure/overmap/small_craft/transport/gunship/OM = get_overmap()
	if(..() || !OM)
		return
	if(action == "kick")
		return
	OM.ui_act(action, params, ui)

/obj/structure/overmap/small_craft/transport/gunship/welder_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE

	var/repair_target = input(user, "Which area would you like to repair?", "[name]") as null|anything in list("internal_structure", "forward_port", "forward_starboard", "aft_port", "aft_starboard")
	switch(repair_target)
		if("internal_structure")
			if(repair_inner == TRUE)
				to_chat(user, "<span class='notice'> Someone is already repairing [src]'s internal structure!.</span>")
				return FALSE

			if(obj_integrity >= max_integrity)
				to_chat(user, "<span class='notice'>[src]'s internal structure isn't in need of repairs.</span>")
				return FALSE

			to_chat(user, "<span class='notice'>You start repairing [src]'s internal structure...</span>")
			var/rep_amount = 1
			while(obj_integrity < max_integrity)
				if(!I.use_tool(src, user, 1 SECONDS))
					repair_inner = FALSE
					return FALSE
				obj_integrity += rep_amount
				rep_amount ++ //Try not to damage the internal structure too much, this will be slow
				if(obj_integrity >= max_integrity)
					obj_integrity = max_integrity
					break
			to_chat(user, "<span class='notice'>You finish repairing [src]'s internal structure...</span>")
			repair_inner = FALSE
			return TRUE

		if("forward_port")
			if(repair_fp == TRUE)
				to_chat(user, "<span class='notice'> Someone is already repairing [src]'s forward portside armour!.</span>")
				return FALSE

			if(armour_quadrants["forward_port"]["current_armour"] >= armour_quadrants["forward_port"]["max_armour"])
				to_chat(user, "<span class='notice'>[src]'s forward portside armour isn't in need of repairs.</span>")
				return FALSE

			to_chat(user, "<span class='notice'>You start repairing [src]'s forward portside armour...</span>")
			var/rep_amount = 1
			while(armour_quadrants["forward_port"]["current_armour"] < armour_quadrants["forward_port"]["max_armour"])
				if(!I.use_tool(src, user, 1 SECONDS))
					repair_fp = FALSE
					return FALSE
				armour_quadrants["forward_port"]["current_armour"] += rep_amount
				rep_amount += rand(2,5)
				if(armour_quadrants["forward_port"]["current_armour"] >= armour_quadrants["forward_port"]["max_armour"])
					armour_quadrants["forward_port"]["current_armour"] = armour_quadrants["forward_port"]["max_armour"]
					break
			to_chat(user, "<span class='notice'>You finish repairing [src]'s forward portside armour...</span>")
			repair_fp = FALSE
			return TRUE

		if("forward_starboard")
			if(repair_fs == TRUE)
				to_chat(user, "<span class='notice'> Someone is already repairing [src]'s forward starboard armour!.</span>")
				return FALSE

			if(armour_quadrants["forward_starboard"]["current_armour"] >= armour_quadrants["forward_starboard"]["max_armour"])
				to_chat(user, "<span class='notice'>[src]'s forward starboard armour isn't in need of repairs.</span>")
				return FALSE

			to_chat(user, "<span class='notice'>You start repairing [src]'s forward starboard armour...</span>")
			var/rep_amount = 1
			while(armour_quadrants["forward_starboard"]["current_armour"] < armour_quadrants["forward_starboard"]["max_armour"])
				if(!I.use_tool(src, user, 1 SECONDS))
					repair_fs = FALSE
					return FALSE
				armour_quadrants["forward_starboard"]["current_armour"] += rep_amount
				rep_amount += rand(2,5)
				if(armour_quadrants["forward_starboard"]["current_armour"] >= armour_quadrants["forward_starboard"]["max_armour"])
					armour_quadrants["forward_starboard"]["current_armour"] = armour_quadrants["forward_starboard"]["max_armour"]
					break
			to_chat(user, "<span class='notice'>You finish repairing [src]'s forward starboard armour...</span>")
			repair_fs = FALSE
			return TRUE

		if("aft_port")
			if(repair_ap == TRUE)
				to_chat(user, "<span class='notice'> Someone is already repairing [src]'s aft portside armour!.</span>")
				return FALSE

			if(armour_quadrants["aft_port"]["current_armour"] >= armour_quadrants["aft_port"]["max_armour"])
				to_chat(user, "<span class='notice'>[src]'s forward aft armour isn't in need of repairs.</span>")
				return FALSE

			to_chat(user, "<span class='notice'>You start repairing [src]'s aft portside armour...</span>")
			var/rep_amount = 1
			while(armour_quadrants["aft_port"]["current_armour"] < armour_quadrants["aft_port"]["max_armour"])
				if(!I.use_tool(src, user, 1 SECONDS))
					repair_ap = FALSE
					return FALSE
				armour_quadrants["aft_port"]["current_armour"] += rep_amount
				rep_amount += rand(2,5)
				if(armour_quadrants["aft_port"]["current_armour"] >= armour_quadrants["aft_port"]["max_armour"])
					armour_quadrants["aft_port"]["current_armour"] = armour_quadrants["aft_port"]["max_armour"]
					break
			to_chat(user, "<span class='notice'>You finish repairing [src]'s aft portside armour...</span>")
			repair_ap = FALSE
			return TRUE

		if("aft_starboard")
			if(repair_as == TRUE)
				to_chat(user, "<span class='notice'> Someone is already repairing [src]'s aft starboard armour!.</span>")
				return FALSE

			if(armour_quadrants["aft_starboard"]["current_armour"] >= armour_quadrants["aft_starboard"]["max_armour"])
				to_chat(user, "<span class='notice'>[src]'s aft starboard armour isn't in need of repairs.</span>")
				return FALSE

			to_chat(user, "<span class='notice'>You start repairing [src]'s aft starboard armour...</span>")
			var/rep_amount = 1
			while(armour_quadrants["aft_starboard"]["current_armour"] < armour_quadrants["aft_starboard"]["max_armour"])
				if(!I.use_tool(src, user, 1 SECONDS))
					repair_as = FALSE
					return FALSE
				armour_quadrants["aft_starboard"]["current_armour"] += rep_amount
				rep_amount += rand(2,5)
				if(armour_quadrants["aft_starboard"]["current_armour"] >= armour_quadrants["aft_starboard"]["max_armour"])
					armour_quadrants["aft_starboard"]["current_armour"] = armour_quadrants["aft_starboard"]["max_armour"]
					break
			to_chat(user, "<span class='notice'>You finish repairing [src]'s aft starboard armour...</span>")
			repair_as = FALSE
			return TRUE
