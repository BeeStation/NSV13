#define VV_HK_FORCE_DOCK "ForceDocking"

/obj/structure/overmap/small_craft/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_FORCE_DOCK, "Force Docking")

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
				target = input(usr, "Select target ship:", "Select Target") as null|anything in GLOB.overmap_objects

		var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
		if(!DC)
			DC = new()
			loadout.install_hardpoint(DC)
		DC.docking_cooldown = FALSE
		DC.docking_mode = TRUE
		if(!length(target.docking_points)) //TODO allow them to create one if there's an interior
			alert(usr, "[target] has no docking points. Unable to dock.", "Warning", "OK")
			return

		transfer_from_overmap(target)

		message_admins("[key_name_admin(usr)] has transferred [src] onto [target]")
		log_admin("[key_name_admin(usr)] has transferred [src] onto [target]")
