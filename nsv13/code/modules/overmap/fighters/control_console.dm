/obj/machinery/computer/ship/fighter_controller
	name = "fighter control console"
	desc = "A computer which allows you to remotely modify fighter system settings. Its power should not be understated."
	icon_screen = "fighter_control"
	req_access = list(ACCESS_MAA)
	circuit = /obj/item/circuitboard/computer/ship/fighter_controller
	var/list/valid_filters = list("Only Occupied Ship", "Su-818 Rapier", "Su-410 Scimitar", "Su-437 Sabre") //This list works by looking at what the intial value of a fighter's name was to determine its class. We may want to move this over to a "class" var
	var/faction = "nanotrasen" //Change this to match the faction of your fighters.
	var/list/current_filters = null //Defaults to showing every kind of fighter. If a fighter type is "in current_filters" then it's visible

/obj/machinery/computer/ship/fighter_controller/Initialize()
	. = ..()
	current_filters = valid_filters.Copy()

/obj/machinery/computer/ship/fighter_controller/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='warning'>You override [src]'s access overrides.</span>")
	obj_flags |= EMAGGED

/obj/machinery/computer/ship/fighter_controller/ui_data(mob/user)
	var/list/data = list()
	data["fighters"] = list()
	var/desired_trait = is_station_level(src.z) ? ZTRAIT_STATION : ZTRAIT_BOARDABLE
	for(var/obj/structure/overmap/fighter/OM in GLOB.overmap_objects)
		if(!locate(OM.z) in SSmapping.levels_by_trait(desired_trait))
			continue
		if(LAZYFIND(current_filters, "Only Occupied Ship") && !OM.operators.len)
			continue
		var/fighter_class = initial(OM.name)
		if(istype(OM) && OM.faction == faction && LAZYFIND(current_filters, fighter_class)) //Yeah.
			data["fighters"] += list(list("name" = OM.name, "integrity" = OM.obj_integrity, "max_integrity" = OM.max_integrity, "safeties" = OM.weapon_safety, "class" = fighter_class))
	data["filter_types"] = list()
	for(var/class in valid_filters)
		data["filter_types"] += list(list("visible" = LAZYFIND(current_filters, class) ? TRUE : FALSE, "class"=class))
	return data

/obj/machinery/computer/ship/fighter_controller/attack_hand(mob/user)
	if(!allowed(user) && !(obj_flags & EMAGGED))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	add_fingerprint(user)
	ui_interact(user)
	return

/obj/machinery/computer/ship/fighter_controller/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(action)
		var/target_name = params["target"]
		if(action == "filter")
			var/filter_name = params["filter"]
			if(LAZYFIND(current_filters, filter_name))
				LAZYREMOVE(current_filters, filter_name)
			else
				LAZYADD(current_filters, filter_name)
			return
		if(action == "global_eject") //Messy. But oh boy do we fucking NEED IT
			if(alert(ui.user, "Are you sure you want to eject ALL PILOTS WHO ARE CURRENTLY SHIPSIDE?",name,"Yes","No") == "No" || !Adjacent(ui.user))
				return
			message_admins("[key_name(ui.user)] ([(ui.user.mind && ui.user.mind.antag_datums) ? "<b>Antagonist</b>" : "Non-Antagonist"]) has force-ejected every pilot from their fighter.")
		var/desired_trait = is_station_level(src.z) ? ZTRAIT_STATION : ZTRAIT_BOARDABLE
		for(var/obj/structure/overmap/fighter/OM in GLOB.overmap_objects)
			if(!locate(OM.z) in SSmapping.levels_by_trait(desired_trait))
				continue
			if(action == "global_toggle")
				if(OM.pilot)
					to_chat(OM.pilot, "<span class='notice'>Gun safety settings remotely overridden by an operator.</span>")
				OM.weapon_safety = !OM.weapon_safety
				log_game("\<span class='notice'>[key_name(ui.user)] forcefully [(OM.weapon_safety) ? "Enabled" : "Disabled"] [OM]'s weapon safeties from a [name] in [get_area(src)]!</span>")
				continue
			if(action == "global_eject")
				log_game("\<span class='notice'>[key_name(ui.user)] forcefully ejected people from [OM] from a [name] in [get_area(src)]!!</span>")
				OM.force_eject()
				continue
			if(OM.name != target_name)
				continue
			switch(action)
				if("eject")
					log_game("\<span class='notice'>[key_name(ui.user)] forcefully ejected people from [OM] from a [name] in [get_area(src)]!!</span>")
					OM.force_eject()
					break
				if("toggle_safeties")
					if(OM.pilot)
						to_chat(OM.pilot, "<span class='notice'>Gun safety settings remotely overridden by an operator.</span>")
					OM.weapon_safety = !OM.weapon_safety
					log_game("\<span class='notice'>[key_name(ui.user)] forcefully [(OM.weapon_safety) ? "Enabled" : "Disabled"] [OM]'s weapon safeties from a [name] in [get_area(src)]!</span>")
					break

/obj/machinery/computer/ship/fighter_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FighterController")
		ui.open()
