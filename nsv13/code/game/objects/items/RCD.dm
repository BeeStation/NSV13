//NSV13 makes RCDs use our own airlocks
/obj/item/construction/rcd/proc/change_airlock_setting(mob/user)
	if(!user)
		return

	var/list/solid_or_glass_choices = list(
		"Solid" = get_airlock_image(/obj/machinery/door/airlock/ship/station),
		"Glass" = get_airlock_image(/obj/machinery/door/airlock/ship/station/glass)
	)

	var/list/solid_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock/ship/station),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/ship/public),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/ship/engineering),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/ship/security),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/ship/command),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/ship/medical),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/ship/station/mining),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/ship/maintenance),
		"External" = get_airlock_image(/obj/machinery/door/airlock/ship/external),
		"Airtight Hatch" = get_airlock_image(/obj/machinery/door/airlock/ship/hatch),
		"Ship" = get_airlock_image(/obj/machinery/door/airlock/ship)
	)

	var/list/glass_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock/ship/station/glass),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/ship/public/glass),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/ship/engineering/glass),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/ship/security/glass),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/ship/command/glass),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/ship/medical/glass),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/ship/station/mining/glass),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/ship/maintenance/glass),
		"External" = get_airlock_image(/obj/machinery/door/airlock/ship/external/glass),
		"Airtight Hatch" = get_airlock_image(/obj/machinery/door/airlock/ship/hatch/glass),
		"Ship" = get_airlock_image(/obj/machinery/door/airlock/ship/glass)
	)

	var/airlockcat = show_radial_menu(user, src, solid_or_glass_choices, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(airlockcat)
		if("Solid")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src, solid_choices, radius = 42, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock/ship/station
					if("Public")
						airlock_type = /obj/machinery/door/airlock/ship/public
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/ship/engineering
					if("Security")
						airlock_type = /obj/machinery/door/airlock/ship/security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/ship/command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/ship/medical
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/ship/station/mining
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/ship/maintenance
					if("External")
						airlock_type = /obj/machinery/door/airlock/ship/external
					if("Airtight Hatch")
						airlock_type = /obj/machinery/door/airlock/ship/hatch
					if("Ship")
						airlock_type = /obj/machinery/door/airlock/ship/station
				airlock_glass = FALSE
			else
				airlock_type = /obj/machinery/door/airlock/ship
				airlock_glass = FALSE

		if("Glass")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src , glass_choices, radius = 42, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock/ship/station/glass
					if("Public")
						airlock_type = /obj/machinery/door/airlock/ship/public/glass
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/ship/engineering/glass
					if("Security")
						airlock_type = /obj/machinery/door/airlock/ship/security/glass
					if("Command")
						airlock_type = /obj/machinery/door/airlock/ship/command/glass
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/ship/medical/glass
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research/glass
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/ship/station/mining/glass
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/ship/maintenance/glass
					if("External")
						airlock_type = /obj/machinery/door/airlock/ship/external/glass
					if("Airtight Hatch")
						airlock_type = /obj/machinery/door/airlock/ship/hatch/glass
					if("Ship")
						airlock_type = /obj/machinery/door/airlock/ship/station/glass
				airlock_glass = TRUE
			else
				airlock_type = /obj/machinery/door/airlock/ship/glass
				airlock_glass = TRUE
		else
			airlock_type = /obj/machinery/door/airlock/ship
			airlock_glass = FALSE
