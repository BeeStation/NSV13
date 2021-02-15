//Ordenance monitoring console
/obj/machinery/computer/ship/ordnance
	name = "Seegson model ORD ordnance systems monitoring console"
	desc = "This console provides a succinct overview of the ship-to-ship weapons."
	icon_screen = "tactical"
	circuit = /obj/item/circuitboard/computer/ship/ordnance_computer

/obj/machinery/computer/ship/ordnance/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return
	ui_interact(user)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "OrdnanceConsole", name, 560, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/ordnance/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	for(var/datum/ship_weapon/SW_type in linked.weapon_types)
		var/ammo = 0
		var/max_ammo = 0
		var/thename = SW_type.name
		for(var/obj/machinery/ship_weapon/SW in SW_type.weapons["all"])
			if(!SW)
				continue
			max_ammo += SW.get_max_ammo()
			ammo += SW.get_ammo()
		data["weapons"] += list(list("name" = thename, "ammo" = ammo, "maxammo" = max_ammo))
	return data
