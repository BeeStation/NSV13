#define VV_HK_FORCE_DOCK "ForceDocking"
#define VV_HK_FORCE_UNDOCK "ForceUndocking"

/obj/structure/overmap/small_craft/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_FORCE_DOCK, "Force Docking")
	VV_DROPDOWN_OPTION(VV_HK_FORCE_UNDOCK, "Force onto Overmap")

/obj/structure/overmap/small_craft/vv_do_topic(list/href_list)
	set waitfor = FALSE
	. = ..()
	if(href_list[VV_HK_FORCE_DOCK])
		if(!check_rights(R_ADMIN))
			return
		var/obj/structure/overmap/target
		switch(alert(usr, "Which ship will it dock to?", "Select Target Ship", "Main Ship", "Choose", "Cancel"))
			if("Cancel")
				return
			if("Main Ship")
				target = SSstar_system.find_main_overmap()
			if("Choose")
				target = input(usr, "Select target ship:", "Select Target") as null|anything in GLOB.overmap_objects //Needs to go through global list due to requiring access to any overmap.

		var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
		if(!DC)
			DC = new()
			loadout.install_hardpoint(DC)
		DC.docking_cooldown = FALSE
		DC.docking_mode = TRUE
		if(!length(target.docking_points))
			if(usr.client?.holder?.marked_datum && isturf(usr.client.holder.marked_datum))
				switch(alert(usr, "[target] has no docking points. Add marked turf to docking points?", "Warning", "Yes", "No"))
					if("No")
						return
					if("Yes")
						target.docking_points |= usr.client.holder.marked_datum
			else
				alert(usr, "[target] has no docking points. Unable to dock.", "Warning", "OK")
				return

		transfer_from_overmap(target)

		message_admins("[key_name_admin(usr)] has transferred [src] onto [target]")
		log_admin("[key_name_admin(usr)] has transferred [src] onto [target]")

	if(href_list[VV_HK_FORCE_UNDOCK])
		if(!check_rights(R_ADMIN))
			return

		if(get_fuel() < 1000)
			set_fuel(1000)

		var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
		if(!APU)
			APU = new()
			loadout.install_hardpoint(APU)
		APU.fuel_line = TRUE
		APU.active = TRUE

		var/obj/item/fighter_component/battery/B = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
		if(!B)
			B = new()
			loadout.install_hardpoint(B)
		B.active = TRUE
		B.charge = B.maxcharge

		var/obj/item/fighter_component/engine/E = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
		if(!E)
			E = new()
			loadout.install_hardpoint(E)
		E.rpm = ENGINE_RPM_SPUN
		E.try_start()

		APU.active = FALSE

		canopy_open = FALSE
		check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE)

		message_admins("[key_name_admin(usr)] has transferred [src] to the overmap")
		log_admin("[key_name_admin(usr)] has transferred [src] to the overmap")
