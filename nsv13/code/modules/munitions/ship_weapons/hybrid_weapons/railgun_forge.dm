/obj/machinery/railgun_forge
	name = "Railgun Forge"
	desc = "Device for forging railgun munitions"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "railgun_forge_core"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 100
	active_power_usage = 2000
	circuit = /obj/item/circuitboard/machine/railgun_forge

	var/datum/component/remote_materials/r_materials //Ore Silo Link
	var/obj/structure/overmap/OM //Our overmap entity for round start linking
	var/forge_ID = null //Set on mapping for linking
	var/average_component_tier = 1

	//Coating Alloy Tank
	var/obj/machinery/railgun_forge_coating_tank/T1 = null
	var/tank_1_volume = 0 //Alloy volume as a percentile
	var/tank_1_alloy_lock = FALSE //Is the alloy selection locked in?
	var/tank_1_processing = FALSE //Is the alloy being produced?
	var/material_selection_1 //Tank 1 material selection
	var/t1_holder

	//Core Alloy Tank
	var/obj/machinery/railgun_forge_core_tank/T2 = null
	var/tank_2_volume = 0
	var/tank_2_alloy_lock = FALSE
	var/tank_2_processing = FALSE
	var/material_selection_2
	var/t2_holder

/obj/machinery/railgun_forge/Initialize(mapload)
	.=..()
	OM = get_overmap()
	r_materials = AddComponent(/datum/component/remote_materials, "railgun_forge", mapload)
	addtimer(CALLBACK(src, PROC_REF(handle_linking)), 30 SECONDS)

/obj/machinery/railgun_forge/proc/handle_linking()
	if(!OM)
		OM = get_overmap()
	if(forge_ID) //If mappers set an ID
		for(var/obj/machinery/railgun_forge_coating_tank/M1 in GLOB.machines)
			if(M1.forge_ID == forge_ID)
				T1 = M1
		for(var/obj/machinery/railgun_forge_core_tank/M2 in GLOB.machines)
			if(M2.forge_ID == forge_ID)
				T2 = M2

/obj/machinery/railgun_forge/process(delta_time)
	if(auto_use_power()) //check proc
		handle_material_processing_t1()
		handle_material_processing_t2()

/obj/machinery/railgun_forge/proc/handle_material_processing_t1()
	if(T1)
		if(T1.tank_processing)
			if(T1.tank_volume >= 100)
				T1.tank_volume = 100
				T1.tank_processing = FALSE
				return
			if(T1.tank_volume < 100)
				var/tank_tier = T1.average_component_tier
				var/single_material_amount = 1000
				switch(tank_tier)
					if(1)
						single_material_amount = 1000
					if(2)
						single_material_amount = 950
					if(3)
						single_material_amount = 900
					if(4)
						single_material_amount = 850

				switch(T1.material_selection)
					if(0) //No Selection
						return
					if("Iron")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/iron)
							T1.tank_volume += 10
					if("Silver")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/silver, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/silver)
							T1.tank_volume += 10
					if("Gold")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/gold, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/gold)
							T1.tank_volume += 10
					if("Diamond")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/diamond, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/diamond)
							T1.tank_volume += 10
					if("Uranium")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/uranium, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/uranium)
							T1.tank_volume += 10
					if("Plasma")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/plasma, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/plasma)
							T1.tank_volume += 10
					if("Bluespace")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/bluespace, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/bluespace)
							T1.tank_volume += 10
					if("Bananium")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/bananium, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/bananium)
							T1.tank_volume += 10
					if("Titanium")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/titanium, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/titanium)
							T1.tank_volume += 10
					if("Copper")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/copper, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/copper)
							T1.tank_volume += 10

/obj/machinery/railgun_forge/proc/handle_material_processing_t2()
	if(T2)
		if(T2.tank_processing)
			if(T2.tank_volume >= 100)
				T2.tank_volume = 100
				T2.tank_processing = FALSE
				return
			if(T2.tank_volume < 100)
				var/tank_tier = T2.average_component_tier
				var/single_material_amount = 1000
				switch(tank_tier)
					if(1)
						single_material_amount = 1000
					if(2)
						single_material_amount = 950
					if(3)
						single_material_amount = 900
					if(4)
						single_material_amount = 850

				switch(T2.material_selection)
					if(0) //No Selection
						return
					if("Iron")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/iron)
							T2.tank_volume += 10
					if("Silver")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/silver, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/silver)
							T2.tank_volume += 10
					if("Gold")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/gold, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/gold)
							T2.tank_volume += 10
					if("Diamond")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/diamond, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/diamond)
							T2.tank_volume += 10
					if("Uranium")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/uranium, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/uranium)
							T2.tank_volume += 10
					if("Plasma")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/plasma, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/plasma)
							T2.tank_volume += 10
					if("Bluespace")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/bluespace, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/bluespace)
							T2.tank_volume += 10
					if("Bananium")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/bananium, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/bananium)
							T2.tank_volume += 10
					if("Titanium")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/titanium, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/titanium)
							T2.tank_volume += 10
					if("Copper")
						if(r_materials.mat_container.has_enough_of_material(/datum/material/copper, single_material_amount))
							r_materials.mat_container.use_amount_mat(single_material_amount, /datum/material/copper)
							T2.tank_volume += 10

/obj/machinery/railgun_forge/proc/getConductivity(var/T) //Extrapolated from electric conductivity at 20C
	var/final_conductivty = 0
	var/conductivity_1 = 0
	var/conductivity_2 = 0
	if(T1 && T2)
		switch(T1.material_selection)
			if("Iron")
				conductivity_1 = 1.0
			if("Silver")
				conductivity_1 = 6.3
			if("Gold")
				conductivity_1 = 4.1
			if("Diamond")
				conductivity_1 = 0.001
			if("Uranium")
				conductivity_1 = 0.36
			if("Plasma")
				conductivity_1 = 2
			if("Bluespace")
				conductivity_1 = 8
			if("Bananium")
				conductivity_1 = 1
			if("Titanium")
				conductivity_1 = 0.24
			if("Copper")
				conductivity_1 = 5.9

		switch(T2.material_selection)
			if("Iron")
				conductivity_2 = 1.0
			if("Silver")
				conductivity_2 = 6.3
			if("Gold")
				conductivity_2 = 4.1
			if("Diamond")
				conductivity_2 = 0.001
			if("Uranium")
				conductivity_2 = 0.36
			if("Plasma")
				conductivity_2 = 2
			if("Bluespace")
				conductivity_2 = 8
			if("Bananium")
				conductivity_2 = 1
			if("Titanium")
				conductivity_2 = 0.24
			if("Copper")
				conductivity_2 = 5.9

	if(T == "slug")
		final_conductivty = ((0.75 * conductivity_1) + (0.25 * conductivity_2))
	else if(T == "canister")
		final_conductivty = ((0.6 * conductivity_1) + (0.4 * conductivity_2))

	return final_conductivty

/obj/machinery/railgun_forge/proc/getDensity(var/T) //extrapolated from g/cm3
	var/final_density = 0
	var/density_1 = 0
	var/density_2 = 0

	if(T1 && T2)
		switch(T1.material_selection)
			if("Iron")
				density_1 = 14
			if("Silver")
				density_1 = 22
			if("Gold")
				density_1 = 40
			if("Diamond")
				density_1 = 7
			if("Uranium")
				density_1 = 38
			if("Plasma")
				density_1 = 10
			if("Bluespace")
				density_1 = 4
			if("Bananium")
				density_1 = 25
			if("Titanium")
				density_1 = 9
			if("Copper")
				density_1 = 18

		switch(T2.material_selection)
			if("Iron")
				density_2 = 14
			if("Silver")
				density_2 = 22
			if("Gold")
				density_2 = 40
			if("Diamond")
				density_2 = 7
			if("Uranium")
				density_2 = 38
			if("Plasma")
				density_2 = 10
			if("Bluespace")
				density_2 = 4
			if("Bananium")
				density_2 = 25
			if("Titanium")
				density_2 = 9
			if("Copper")
				density_2 = 18

	if(T == "slug")
		final_density = ((0.25 * density_1) + (0.75 * density_2))
	else if(T == "canister")
		final_density = ((0.5 * density_1) + (0.5 * density_2))

	return final_density

/obj/machinery/railgun_forge/proc/getHardness(var/T) //Mohs
	var/final_hardness = 0
	var/hardness_1 = 0
	var/hardness_2 = 0

	if(T1 && T2)
		switch(T1.material_selection)
			if("Iron")
				hardness_1 = 4
			if("Silver")
				hardness_1 = 2.5
			if("Gold")
				hardness_1 = 2.5
			if("Diamond")
				hardness_1 = 10
			if("Uranium")
				hardness_1 = 6
			if("Plasma")
				hardness_1 = 3
			if("Bluespace")
				hardness_1 = NUM_E
			if("Bananium")
				hardness_1 = 1
			if("Titanium")
				hardness_1 = 6
			if("Copper")
				hardness_1 = 5

		switch(T2.material_selection)
			if("Iron")
				hardness_2 = 4
			if("Silver")
				hardness_2 = 2.5
			if("Gold")
				hardness_2 = 2.5
			if("Diamond")
				hardness_2 = 10
			if("Uranium")
				hardness_2 = 6
			if("Plasma")
				hardness_2 = 3
			if("Bluespace")
				hardness_2 = NUM_E
			if("Bananium")
				hardness_2 = 1
			if("Titanium")
				hardness_2 = 6
			if("Copper")
				hardness_2 = 5

	if(T == "slug")
		final_hardness = ((0.25 * hardness_1) + (0.75 * hardness_2))
	else if(T == "canister")
		final_hardness = ((0.8 * hardness_1) + (0.2 * hardness_2))

	return final_hardness

/obj/machinery/railgun_forge/proc/forge_slug()
	if(T1 && T2)
		var/component_multiplier = 1
		switch(average_component_tier)
			if(1)
				component_multiplier = 1
			if(2)
				component_multiplier = 0.95
			if(3)
				component_multiplier = 0.9
			if(4)
				component_multiplier = 0.85

		if(T1.tank_volume >= (4 * component_multiplier) && T2.tank_volume >= (20 * component_multiplier)) //Duplicate checks
			T1.tank_volume -= (4 * component_multiplier)
			T2.tank_volume -= (20 * component_multiplier)
			var/turf/T = loc
			var/obj/item/ship_weapon/ammunition/railgun_ammo/forged/F = new(T)
			F.name = "\improper Forged 400mm [T1.material_selection] coated [T2.material_selection] slug"
			F.material_conductivity = getConductivity("slug")
			F.material_density = getDensity("slug")
			F.material_hardness = getHardness("slug")
			if(T1.material_selection == "Bananium" || T2.material_selection == "Bananium")
				F.railgun_flags += RAIL_BANANA
				F.AddComponent(/datum/component/slippery, 40, null, 20, TRUE)
			if(T1.material_selection == "Bluespace" || T2.material_selection == "Bluespace")
				F.railgun_flags += RAIL_BLUESPACE
			if(T1.material_selection == "Plasma" || T2.material_selection == "Plasma")
				F.railgun_flags += RAIL_BURN
				F.AddComponent(/datum/component/volatile, 3, TRUE, 1)
			set_tint(F)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)
			do_sparks(5, FALSE, src)

/obj/machinery/railgun_forge/proc/forge_canister()
	if(T1 && T2)
		var/component_multiplier = 1
		var/modified_integrity = 100
		switch(average_component_tier)
			if(1)
				component_multiplier = 1
				modified_integrity = 100
			if(2)
				component_multiplier = 0.95
				modified_integrity = 110
			if(3)
				component_multiplier = 0.9
				modified_integrity = 120
			if(4)
				component_multiplier = 0.85
				modified_integrity = 130

		if(T1.tank_volume >= (20 * component_multiplier) && T2.tank_volume >= (30 * component_multiplier)) //Duplicate checks
			T1.tank_volume -= (20 * component_multiplier)
			T2.tank_volume -= (30 * component_multiplier)
			var/turf/T = loc
			var/obj/item/ship_weapon/ammunition/railgun_ammo_canister/F = new(T)
			F.name = "\improper Forged 800mm [T1.material_selection] coated [T2.material_selection] canister"
			F.material_conductivity = getConductivity("canister")
			F.material_density = getDensity("canister")
			F.material_hardness = getHardness("canister")
			if(T1.material_selection == "Bananium" || T2.material_selection == "Bananium")
				F.railgun_flags += RAIL_BANANA
				F.AddComponent(/datum/component/slippery, 40, null, 20, TRUE)
			if(T1.material_selection == "Bluespace" || T2.material_selection == "Bluespace")
				F.railgun_flags += RAIL_BLUESPACE
			if(T1.material_selection == "Plasma" || T2.material_selection == "Plasma")
				F.railgun_flags += RAIL_BURN
				F.AddComponent(/datum/component/volatile, 3, TRUE, 1)
			set_tint(F)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)
			do_sparks(5, FALSE, src)
			F.canister_integrity = modified_integrity

/obj/machinery/railgun_forge/proc/set_tint(var/obj/item/ship_weapon/ammunition/A)
	if(!A)
		return
	switch(T1.material_selection)
		if("Iron")
			A.color = "#BBBBBB"
		if("Silver")
			A.color = "#FFFFFF"
		if("Gold")
			A.color = "#FFD27D"
		if("Diamond")
			A.color = "#ABF7FF"
		if("Uranium")
			A.color = "#D9FFE0"
		if("Plasma")
			A.color = "#FF88F4"
		if("Bluespace")
			A.color = "#A9BDFF"
		if("Bananium")
			A.color = "#FEFFA3"
		if("Titanium")
			A.color = "#EEEEEE"
		if("Copper")
			A.color = "#FFB888"

/obj/machinery/railgun_forge/RefreshParts()
	var/comp_number = 0
	var/comp_total = 0
	var/comp_averaged = 0
	for(var/obj/item/stock_parts/S in component_parts)
		comp_total += S.rating
		comp_number ++
	comp_averaged = comp_total / comp_number
	switch(comp_averaged)
		if(1 to 1.99)
			average_component_tier = 1
		if(2 to 2.99)
			average_component_tier = 2
		if(3 to 3.99)
			average_component_tier = 3
		if(4)
			average_component_tier = 4

/obj/machinery/railgun_forge/multitool_act(mob/user, obj/item/tool)
	. = TRUE
	if(!multitool_check_buffer(user, tool))
		return
	var/obj/item/multitool/M = tool
	if(!isnull(M.buffer) && istype(M.buffer, /obj/machinery/railgun_forge_coating_tank))
		T1 = M.buffer
		M.buffer = null
	else if(!isnull(M.buffer) && istype(M.buffer, /obj/machinery/railgun_forge_core_tank))
		T2 = M.buffer
		M.buffer = null
	playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
	to_chat(user, "<span class='notice'>Buffer transfered</span>")
	return

/obj/machinery/railgun_forge/attack_hand(mob/living/carbon/user)
	ui_interact(user)

/obj/machinery/railgun_forge/attack_ai(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/railgun_forge/attack_robot(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/railgun_forge/attack_ghost(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/railgun_forge/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RailgunForge")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/railgun_forge/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!(in_range(src, usr) || IsAdminGhost(usr)))
		return
	if(!T1 || !T2)
		to_chat(usr, "<span class='notice'>Error: Coating/Core tanks not detected!</span>")
		return
	if(T1 && T2)
		switch(action)
			if("print_slug")
				if(T1.tank_alloy_lock == FALSE || T2.tank_alloy_lock == FALSE)
					to_chat(usr, "<span class='notice'>Error: Fabrication materials not selected</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else if(T1.tank_volume < 4 || T2.tank_volume < 20)
					to_chat(usr, "<span class='notice'>Error: Insufficent fabrication resources</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else
					forge_slug()

			if("print_canister")
				if(T1.tank_alloy_lock == FALSE || T2.tank_alloy_lock == FALSE)
					to_chat(usr, "<span class='notice'>Error: Fabrication materials not selected</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else if(T1.tank_volume < 20 || T2.tank_volume < 30)
					to_chat(usr, "<span class='notice'>Error: Insufficent fabrication resources</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else
					forge_canister()

			if("purge_t1")
				if(alert("Allocated resources will not be recoverable when purging the coating tank",name,"Continue","Abort") != "Abort" && Adjacent(usr))
					to_chat(usr, "<span class='warning'>Purging coating tank</span>")
					T1.material_selection = 0
					T1.tank_alloy_lock = FALSE
					T1.tank_processing = FALSE
					T1.tank_volume = 0
					return

			if("purge_t2")
				if(alert("Allocated resources will not be recoverable when purging the core tank",name,"Continue","Abort") != "Abort" && Adjacent(usr))
					to_chat(usr, "<span class='warning'>Purging core tank</span>")
					T2.material_selection = 0
					T2.tank_alloy_lock = FALSE
					T2.tank_processing = FALSE
					T2.tank_volume = 0
					return

			if("t1_list")
				t1_holder = params["value"]
				return

			if("t2_list")
				t2_holder = params["value"]
				return

			if("t1_set_material")
				if(T1.tank_alloy_lock)
					to_chat(usr, "<span class='notice'>Error: Coating tank must be purged before selecting another material</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else
					T1.material_selection = t1_holder //Because I've only used strings in the tgui materials list, we will also just use those here.
					T1.tank_alloy_lock = TRUE
					return TRUE //We can safely return after having completed our action TRUE will make the ui reload itself to update any ui_data that may have changed.

			if("t2_set_material")
				if(T2.tank_alloy_lock)
					to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else
					T2.material_selection = t2_holder
					T2.tank_alloy_lock = TRUE
					return TRUE

			if("t1_set_processing")
				if(T1.tank_processing)
					T1.tank_processing = FALSE
					to_chat(usr, "<span class='notice'>Coating Tank Processing: Disabled.</span>")
					return
				else if(!T1.tank_alloy_lock)
					to_chat(usr, "<span class='notice'>Error: Material selection must be locked before processing.</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else
					T1.tank_processing = TRUE
					to_chat(usr, "<span class='notice'>Coating Tank Processing: Enabled.</span>")
					return

			if("t2_set_processing")
				if(T2.tank_processing)
					T2.tank_processing = FALSE
					to_chat(usr, "<span class='notice'>Core Tank Processing: Disabled.</span>")
					return
				else if(!T2.tank_alloy_lock)
					to_chat(usr, "<span class='notice'>Error: Material selection must be locked before processing.</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else
					T2.tank_processing = TRUE
					to_chat(usr, "<span class='notice'>Core Tank Processing: Enabled.</span>")
					return

	return

/obj/machinery/railgun_forge/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["t1_volume"] = T1 ? T1.tank_volume : 0
	data["t1_alloy_lock"] = T1 ? T1.tank_alloy_lock : 0
	data["t1_processing"] = T1 ? T1.tank_processing : 0
	data["t1_material"] = T1 ? T1.material_selection : 0
	data["t2_volume"] = T2 ? T2.tank_volume : 0
	data["t2_alloy_lock"] = T2 ? T2.tank_alloy_lock : 0
	data["t2_processing"] = T2 ? T2.tank_processing : 0
	data["t2_material"] = T2? T2.material_selection : 0
	return data

///////////////////////////////////////////////////////////////////////////////
/obj/machinery/railgun_forge_coating_tank
	name = "Railgun Forge Coating Tank"
	desc = "Device for forging railgun munitions"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "railgun_forge_tank"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 100
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/railgun_forge_coating_tank
	var/forge_ID = null //Set on mapping for linking
	var/tank_volume = 0 //Alloy volume as a percentile
	var/tank_alloy_lock = FALSE //Is the alloy selection locked in?
	var/tank_processing = FALSE //Is the alloy being produced?
	var/material_selection //Tank material selection
	var/average_component_tier = 1

/obj/machinery/railgun_forge_coating_tank/attackby(obj/item/I, mob/user, params)
	.=..()
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		M.buffer = src
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer loaded</span>")

/obj/machinery/railgun_forge_coating_tank/RefreshParts()
	var/comp_number = 0
	var/comp_total = 0
	var/comp_averaged = 0
	for(var/obj/item/stock_parts/S in component_parts)
		comp_total += S.rating
		comp_number ++
	comp_averaged = comp_total / comp_number
	switch(comp_averaged)
		if(1 to 1.99)
			average_component_tier = 1
		if(2 to 2.99)
			average_component_tier = 2
		if(3 to 3.99)
			average_component_tier = 3
		if(4)
			average_component_tier = 4

///////////////////////////////////////////////////////////////////////////////
/obj/machinery/railgun_forge_core_tank
	name = "Railgun Forge Core Tank"
	desc = "Device for forging railgun munitions"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "railgun_forge_tank"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 100
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/railgun_forge_core_tank
	var/forge_ID = null //Set on mapping for linking
	var/tank_volume = 0 //Alloy volume as a percentile
	var/tank_alloy_lock = FALSE //Is the alloy selection locked in?
	var/tank_processing = FALSE //Is the alloy being produced?
	var/material_selection //Tank material selection
	var/average_component_tier = 1

/obj/machinery/railgun_forge_core_tank/attackby(obj/item/I, mob/user, params)
	.=..()
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		M.buffer = src
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer loaded</span>")

/obj/machinery/railgun_forge_core_tank/RefreshParts()
	var/comp_number = 0
	var/comp_total = 0
	var/comp_averaged = 0
	for(var/obj/item/stock_parts/S in component_parts)
		comp_total += S.rating
		comp_number ++
	comp_averaged = comp_total / comp_number
	switch(comp_averaged)
		if(1 to 1.99)
			average_component_tier = 1
		if(2 to 2.99)
			average_component_tier = 2
		if(3 to 3.99)
			average_component_tier = 3
		if(4)
			average_component_tier = 4

///////////////////////////////////////////////////////////////////////////////

/obj/machinery/atmospherics/components/binary/railgun_filler
	name = "Railgun Canister Filler"
	desc = "Device for filling and sealing railgun canister munitions"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "railgun_filler"
	density = TRUE
	anchored = TRUE
	dir = 8
	circuit = /obj/item/circuitboard/machine/railgun_filler
	var/loading = FALSE
	var/obj/item/ship_weapon/ammunition/railgun_ammo_canister/F
	var/fill_amount = 50

/obj/machinery/atmospherics/components/binary/railgun_filler/proc/fill_canister()
	if(F)
		var/moles_check = F.canister_gas.total_moles()
		if(moles_check != 0)
			return
		else
			var/datum/gas_mixture/air1 = airs[1]
			var/datum/gas_mixture/buffer = air1.remove(fill_amount)
			buffer.set_temperature(T20C) //Simplification
			F.canister_gas.merge(buffer)
			update_parents()

/obj/machinery/atmospherics/components/binary/railgun_filler/proc/empty_canister()
	if(F)
		var/moles_check = F.canister_gas.total_moles()
		if(moles_check != 0)
			return
		else
			var/datum/gas_mixture/air2 = airs[2]
			var/datum/gas_mixture/buffer = F.canister_gas.remove(fill_amount)
			air2.merge(buffer)
			update_parents()

/obj/machinery/atmospherics/components/binary/railgun_filler/proc/eject_canister()
	if(F)
		F.forceMove(get_turf(src))
		F = null

/obj/machinery/atmospherics/components/binary/railgun_filler/proc/eject_unsealed_canister()
	var/turf/T = get_turf(src)
	if(T)
		var/datum/gas_mixture/env = T.return_air()
		var/datum/gas_mixture/buffer = F.canister_gas.remove(fill_amount)
		env.merge(buffer)
		update_parents()
	eject_canister()

/obj/machinery/atmospherics/components/binary/railgun_filler/RefreshParts()
	var/comp_number = 0
	var/comp_total = 0
	var/comp_averaged = 0
	for(var/obj/item/stock_parts/S in component_parts)
		comp_total += S.rating
		comp_number ++
	comp_averaged = comp_total / comp_number
	switch(comp_averaged)
		if(1 to 1.99)
			fill_amount = 50
		if(2 to 2.99)
			fill_amount = 60
		if(3 to 3.99)
			fill_amount = 70
		if(4)
			fill_amount = 80

/obj/machinery/atmospherics/components/binary/railgun_filler/attackby(obj/item/I, mob/user)
	if(!loading)
		if(istype(I, /obj/item/ship_weapon/ammunition/railgun_ammo_canister))
			if(user)
				to_chat(user, "<span class='notice'>You start to load [I] into [src]...</span>")
				loading = TRUE
			if(!user || !do_after(user, 20, target = src))
				loading = FALSE
				return
			F = I
			F.forceMove(src)
			loading = FALSE
			to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
	if(F)
		if(user)
			to_chat(user, "<span class='notice'>There is already an [F] in [src].</span>")

/obj/machinery/atmospherics/components/binary/railgun_filler/attack_hand(mob/living/carbon/user)
	ui_interact(user)

/obj/machinery/atmospherics/components/binary/railgun_filler/attack_ai(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/atmospherics/components/binary/railgun_filler/attack_robot(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/atmospherics/components/binary/railgun_filler/attack_ghost(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/atmospherics/components/binary/railgun_filler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RailgunFiller")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/atmospherics/components/binary/railgun_filler/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!(in_range(src, usr) || IsAdminGhost(usr)))
		return
	switch(action)
		if("fill")
			if(F)
				if(F.canister_sealed)
					to_chat(usr, "<span class='notice'>Error: Unable to fill canister as it has been permanently sealed shut.</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else
					fill_canister()
					return
			return
		if("empty")
			if(F)
				if(F.canister_sealed)
					to_chat(usr, "<span class='notice'>Error: Unabled to empty canister as it has been permanently sealed shut.</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else
					empty_canister()
			return
		if("seal")
			if(F)
				if(F.canister_sealed)
					to_chat(usr, "<span class='notice'>Error: Canister has already been sealed shut.</span>")
					var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
					playsound(src, sound, 100, 1)
					return
				else
					F.canister_sealed = TRUE
					F.icon_state = "railgun_canister_sealed"
					to_chat(usr, "<span class='notice'>Attention: [F.name] has been been permamently sealed")
					return
			return
		if("eject")
			if(!F)
				return
			else if(F.canister_sealed)
				eject_canister()
				return
			else
				to_chat(usr, "<span class='danger'>The canister vents its contents!</span>")
				eject_unsealed_canister()
				return
	return

/obj/machinery/atmospherics/components/binary/railgun_filler/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["canister_name"] = F ? F.name : 0
	data["gas_moles"] = airs[1].total_moles()
	data["o2"] = airs[1].get_moles(GAS_O2)
	data["pluox"] = airs[1].get_moles(GAS_PLUOXIUM)
	data["plasma"] = airs[1].get_moles(GAS_PLASMA)
	data["c_plasma"] = airs[1].get_moles(GAS_CONSTRICTED_PLASMA)
	data["trit"] = airs[1].get_moles(GAS_TRITIUM)
	data["nucleium"] = airs[1].get_moles(GAS_NUCLEIUM)
	data["canister_gas_moles"] = F ? F.canister_gas.total_moles() : 0
	data["canister_o2"] = F ? F.canister_gas.get_moles(GAS_O2) : 0
	data["canister_pluox"] = F ? F.canister_gas.get_moles(GAS_PLUOXIUM) : 0
	data["canister_plasma"] = F ? F.canister_gas.get_moles(GAS_PLASMA) : 0
	data["canister_c_plasma"] = F ? F.canister_gas.get_moles(GAS_CONSTRICTED_PLASMA) : 0
	data["canister_trit"] = F ? F.canister_gas.get_moles(GAS_TRITIUM) : 0
	data["canister_nucleium"] = F ? F.canister_gas.get_moles(GAS_NUCLEIUM) : 0

	return data

///////////////////////////////////////////////////////////////////////////////

/obj/machinery/railgun_charger
	name = "Railgun Canister Charger"
	desc = "Device for charging and discharging railgun canister munitions"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "railgun_charger"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 15
	active_power_usage = 0
	circuit = /obj/item/circuitboard/machine/railgun_charger
	var/discharge = FALSE
	var/charge = FALSE
	var/loading = FALSE
	var/charge_rate = 0 //In watts
	var/max_charge_rate = 100000 //In watts
	var/obj/item/ship_weapon/ammunition/railgun_ammo_canister/F
	var/max_canister_charge = 100

/obj/machinery/railgun_charger/process(delta_time)
	if(!try_use_power(active_power_usage))
		if(F)
			if(F.stabilized)
				F.stabilized = FALSE
		return
	if(F)
		if(F.stabilized == FALSE)
			F.stabilized = TRUE
		if(discharge)
			if(F.material_charge > 0)
				F.material_charge -= 3 //Safe discharge is slow
				if(F.material_charge < 0)
					F.material_charge = 0
				else
					active_power_usage = 100 //Reduced power operation
		else if(charge)
			if(F.material_charge < max_canister_charge)
				F.material_charge += (charge_rate / 10000)
				if(F.material_charge > max_canister_charge)
					F.material_charge = max_canister_charge
				if(F.railgun_flags & RAIL_BLUESPACE)
					if(prob(0.1))
						bluespace()
			else
				active_power_usage = 100 //Reduced power operation

/obj/machinery/railgun_charger/proc/try_use_power(amount)
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(!C.powernet)
			return FALSE
		var/power_in_net = C.powernet.avail-C.powernet.load

		if(power_in_net && power_in_net >= amount)
			C.powernet.load += amount
			return TRUE
		return FALSE
	return FALSE

/obj/machinery/railgun_charger/proc/eject_canister()
	if(F)
		F.forceMove(get_turf(src))
		F.stabilized = FALSE
		F = null //wipe our ref

/obj/machinery/railgun_charger/proc/bluespace() //Mirror the proc in hybrid_railgun.dm
	F.stabilized = FALSE
	var/obj/item/ship_weapon/ammunition/A = F
	F = null //reference in our charger
	var/bluespace_roll = rand(0, 100) //Random effect table here
	switch(bluespace_roll) //ADD MORE HERE PLEASE
		if(0 to 50) //Send to the aether
			qdel(A)
			return
		if(51 to 100) //Teleport somewhere randomly on the ship - hope this wasn't a charged canister
			var/turf/T = find_safe_turf()
			do_teleport(A, T)

/obj/machinery/railgun_charger/RefreshParts()
	var/comp_number = 0
	var/comp_total = 0
	var/comp_averaged = 0
	for(var/obj/item/stock_parts/S in component_parts)
		comp_total += S.rating
		comp_number ++
	comp_averaged = comp_total / comp_number
	switch(comp_averaged)
		if(1 to 1.99)
			max_canister_charge = 100
		if(2 to 2.99)
			max_canister_charge = 133
		if(3 to 3.99)
			max_canister_charge = 166
		if(4)
			max_canister_charge = 200

/obj/machinery/railgun_charger/attackby(obj/item/I, mob/user)
	if(!loading)
		if(istype(I, /obj/item/ship_weapon/ammunition/railgun_ammo_canister))
			if(user)
				to_chat(user, "<span class='notice'>You start to load [I] into [src]...</span>")
				loading = TRUE
			if(!user || !do_after(user, 20, target = src))
				loading = FALSE
				return
			F = I
			F.forceMove(src)
			loading = FALSE
			to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
	if(F)
		if(user)
			to_chat(user, "<span class='notice'>There is already an [F] in [src].</span>")

/obj/machinery/railgun_charger/attack_hand(mob/living/carbon/user)
	ui_interact(user)

/obj/machinery/railgun_charger/attack_ai(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/railgun_charger/attack_robot(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/railgun_charger/attack_ghost(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/railgun_charger/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RailgunCanisterCharger")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/railgun_charger/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!(in_range(src, usr) || IsAdminGhost(usr)))
		return
	var/adjust = text2num(params["adjust"])
	if(action == "canister_charge_rate")
		if(isnum(adjust))
			charge_rate = CLAMP(adjust, 0, max_charge_rate)
			return TRUE
	switch(action)
		if("charge_rate")
			charge_rate = adjust
			active_power_usage = adjust
		if("toggle_discharge")
			if(!charge)
				cut_overlays()
				discharge = !discharge
				if(discharge)
					add_overlay("railgun_charger_d")
		if("toggle_charge")
			if(!discharge)
				cut_overlays()
				charge = !charge
				if(charge)
					add_overlay("railgun_charger_c")
		if("eject")
			eject_canister()
	return

/obj/machinery/railgun_charger/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["canister_charge"] = F ? F.material_charge : 0
	data["canister_name"] = F ? F.name : 0
	data["canister_integrity"] = F ? F.canister_integrity : 0
	data["canister_charge_rate"] = charge_rate
	data["canister_max_charge_rate"] = max_charge_rate
	data["charging"] = charge
	data["discharging"] = discharge
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(C.powernet)
			data["available_power"] = C.powernet.avail-C.powernet.load
	return data

///////////////CIRCUIT BOARDS//////////////////

/obj/item/circuitboard/machine/railgun_forge //update my components
	name = "Railgun Forge (Machine Board)"
	build_path = /obj/machinery/railgun_forge
	req_components = list(
		/obj/item/stock_parts/manipulator = 12,
		/obj/item/stock_parts/scanning_module = 4,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/micro_laser = 10)

/obj/item/circuitboard/machine/railgun_charger //update my components
	name = "Railgun Charger (Machine Board)"
	build_path = /obj/machinery/railgun_charger
	req_components = list(
		/obj/item/stock_parts/scanning_module = 10,
		/obj/item/stock_parts/capacitor = 25,
		/obj/item/stock_parts/micro_laser = 5)

/obj/item/circuitboard/machine/railgun_filler //update my components
	name = "Railgun Filler (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/binary/railgun_filler
	req_components = list(
		/obj/item/stock_parts/matter_bin = 10,
		/obj/item/stock_parts/manipulator = 5,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/capacitor = 8,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/railgun_forge_coating_tank
	name = "Railgun Forge Coating Tank (Machine Board)"
	build_path = /obj/machinery/railgun_forge_coating_tank
	req_components = list(
		/obj/item/stock_parts/matter_bin = 20,
		/obj/item/stock_parts/manipulator = 5,
		/obj/item/stock_parts/scanning_module = 2)

/obj/item/circuitboard/machine/railgun_forge_core_tank
	name = "Railgun Forge Core Tank (Machine Board)"
	build_path = /obj/machinery/railgun_forge_core_tank
	req_components = list(
		/obj/item/stock_parts/matter_bin = 20,
		/obj/item/stock_parts/manipulator = 5,
		/obj/item/stock_parts/scanning_module = 2)
