/obj/machinery/railgun_forge
	name = "Railgun Forge"
	desc = "Device for forging railgun munitions"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 100
	active_power_usage = 2000
	circuit = /obj/item/circuitboard/machine/railgun_forge

	var/datum/component/remote_materials/r_materials //Ore Silo Link

	//Coating Alloy Tank
	var/tank_1_volume = 0 //Alloy volume as a percentile
	var/tank_1_alloy_lock = FALSE //Is the alloy selection locked in?
	var/tank_1_processing = FALSE //Is the alloy being produced?
	var/material_selection_1 //Tank 1 material selection
	var/t1_holder

	//Core Alloy Tank
	var/tank_2_volume = 0
	var/tank_2_alloy_lock = FALSE
	var/tank_2_processing = FALSE
	var/material_selection_2
	var/t2_holder

/obj/machinery/railgun_forge/Initialize(mapload)
	.=..()
	r_materials = AddComponent(/datum/component/remote_materials, "railgun_forge", mapload)

/obj/machinery/railgun_forge/process(delta_time)
	if(auto_use_power()) //check proc
		handle_material_processing_t1()
		handle_material_processing_t2()

/obj/machinery/railgun_forge/proc/handle_material_processing_t1()
	if(tank_1_processing)
		if(tank_1_volume >= 100)
			tank_1_volume = 100
			tank_1_processing = FALSE
			return
		if(tank_1_volume < 100)
			switch(material_selection_1)
				if(0) //No Selection
					return
				if("Iron")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/iron)
						tank_1_volume += 10
				if("Silver")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/silver, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/silver)
						tank_1_volume += 10
				if("Gold")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/gold, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/gold)
						tank_1_volume += 10
				if("Diamond")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/diamond, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/diamond)
						tank_1_volume += 10
				if("Uranium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/uranium, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/uranium)
						tank_1_volume += 10
				if("Plasma")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/plasma)
						tank_1_volume += 10
				if("Bluespace")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/bluespace, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/bluespace)
						tank_1_volume += 10
				if("Bananium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/bananium, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/bananium)
						tank_1_volume += 10
				if("Titanium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/titanium)
						tank_1_volume += 10
				if("Copper")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/copper, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/copper)
						tank_1_volume += 10
				if("Plasteel")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 500) && r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 500) )
						r_materials.mat_container.use_amount_mat(500, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(500, /datum/material/plasma)
						tank_1_volume += 10
				if("Ferrotitanium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 250) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 750))
						r_materials.mat_container.use_amount_mat(250, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(750, /datum/material/titanium)
						tank_1_volume += 10
				if("Durasteel")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 200) && r_materials.mat_container.has_enough_of_material(/datum/material/silver, 150) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 650))
						r_materials.mat_container.use_amount_mat(200, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(150, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(650, /datum/material/iron)
						tank_1_volume += 10
				if("Duranium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 175) && r_materials.mat_container.has_enough_of_material(/datum/material/silver, 150) && r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 50) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 625))
						r_materials.mat_container.use_amount_mat(175, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(150, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(50, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(625, /datum/material/iron)
						tank_1_volume += 10

/obj/machinery/railgun_forge/proc/handle_material_processing_t2()
	if(tank_2_processing)
		if(tank_2_volume >= 100)
			tank_2_volume = 100
			tank_2_processing = FALSE
			return
		if(tank_2_volume < 100)
			switch(material_selection_1)
				if(0) //No Selection
					return
				if("Iron")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/iron)
						tank_2_volume += 10
				if("Silver")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/silver, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/silver)
						tank_2_volume += 10
				if("Gold")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/gold, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/gold)
						tank_2_volume += 10
				if("Diamond")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/diamond, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/diamond)
						tank_2_volume += 10
				if("Uranium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/uranium, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/uranium)
						tank_2_volume += 10
				if("Plasma")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/plasma)
						tank_2_volume += 10
				if("Bluespace")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/bluespace, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/bluespace)
						tank_2_volume += 10
				if("Bananium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/bananium, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/bananium)
						tank_2_volume += 10
				if("Titanium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/titanium)
						tank_2_volume += 10
				if("Copper")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/copper, 1000))
						r_materials.mat_container.use_amount_mat(1000, /datum/material/copper)
						tank_2_volume += 10
				if("Plasteel")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 500) && r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 500) )
						r_materials.mat_container.use_amount_mat(500, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(500, /datum/material/plasma)
						tank_2_volume += 10
				if("Ferrotitanium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 250) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 750))
						r_materials.mat_container.use_amount_mat(250, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(750, /datum/material/titanium)
						tank_2_volume += 10
				if("Durasteel")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 200) && r_materials.mat_container.has_enough_of_material(/datum/material/silver, 150) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 650))
						r_materials.mat_container.use_amount_mat(200, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(150, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(650, /datum/material/iron)
						tank_2_volume += 10
				if("Duranium")
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 175) && r_materials.mat_container.has_enough_of_material(/datum/material/silver, 150) && r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 50) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 625))
						r_materials.mat_container.use_amount_mat(175, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(150, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(50, /datum/material/iron)
						r_materials.mat_container.use_amount_mat(625, /datum/material/iron)
						tank_2_volume += 10

/obj/machinery/railgun_forge/proc/getConductivity(var/T) //Extrapolated from electric conductivity at 20C
	var/final_conductivty = 0
	var/conductivity_1 = 0
	var/conductivity_2 = 0

	switch(material_selection_1)
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
			conductivity_1 = 2 //TEST
		if("Bluespace")
			conductivity_1 = 10 //TEST
		if("Bananium")
			conductivity_1 = 1 //TEST
		if("Titanium")
			conductivity_1 = 0.24
		if("Copper")
			conductivity_1 = 5.9
		if("Plasteel")
			conductivity_1 = 0 //<-------
		if("Ferrotitanium")
			conductivity_1 = 0 //<-------
		if("Durasteel")
			conductivity_1 = 0 //<-------
		if("Duranium")
			conductivity_1 = 0 //<-------

	switch(material_selection_2)
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
			conductivity_2 = 2 //TEST
		if("Bluespace")
			conductivity_2 = 10 //TEST
		if("Bananium")
			conductivity_2 = 1 //TEST
		if("Titanium")
			conductivity_2 = 0.24
		if("Copper")
			conductivity_2 = 5.9
		if("Plasteel")
			conductivity_2 = 0 //<-------
		if("Ferrotitanium")
			conductivity_2 = 0 //<-------
		if("Durasteel")
			conductivity_2 = 0 //<-------
		if("Duranium")
			conductivity_2 = 0 //<-------
/*
		silver, = 6.3x10^7					-> 6.3
		copper, = 5.9x10^7 					-> 5.9
		gold, = 4.1x10^7 					-> 4.1
		iron, = 1x10^7						-> 1.0
		uranium, = 3.6x10^6					-> 0.36
		titanium, = 2.4x10^6				-> 0.24
		*stainless steel, = 1.5x10^6
		diamond, = 1x10^-13					-> 0.001
		*carbon steel, = 1.4x10^-7
		plasma, = 2x10^3 //not real			-> 0.001
		bananium, //?
		bluespace, //?
		plasteel, //?
		ferrotitanium, //?
		durasteel, //?
		duranium, //?
*/

	if(T == "slug")
		final_conductivty = ((0.75 * conductivity_1) + (0.25 * conductivity_2))
	else if(T == "canister")
		final_conductivty = ((0.6 * conductivity_1) + (0.4 * conductivity_2))

	return final_conductivty

/obj/machinery/railgun_forge/proc/getDensity(var/T) //extrapolated from g/cm3
	var/final_density = 0
	var/density_1 = 0
	var/density_2 = 0

	switch(material_selection_1)
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
			density_1 = 10 //TEST
		if("Bluespace")
			density_1 = 4 //TEST
		if("Bananium")
			density_1 = 25 //TEST
		if("Titanium")
			density_1 = 9
		if("Copper")
			density_1 = 18
		if("Plasteel")
			density_1 = 0 //<-------
		if("Ferrotitanium")
			density_1 = 0 //<-------
		if("Durasteel")
			density_1 = 0 //<-------
		if("Duranium")
			density_1 = 0 //<-------

	switch(material_selection_2)
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
			density_2 = 10 //TEST
		if("Bluespace")
			density_2 = 4 //TEST
		if("Bananium")
			density_2 = 25 //TEST
		if("Titanium")
			density_2 = 9
		if("Copper")
			density_2 = 18
		if("Plasteel")
			density_2 = 0 //<-------
		if("Ferrotitanium")
			density_2 = 0 //<-------
		if("Durasteel")
			density_2 = 0 //<-------
		if("Duranium")
			density_2 = 0 //<-------
/*
		gold, = 19.282						-> 40
		uranium, = 18.95					-> 38
		silver, = 10.501					-> 22
		copper, = 8.933						-> 18
		*stainless steel, = 8.05
		iron, = 7.874						-> 14
		*carbon steel, = 7.85
		titanium, = 4.5						-> 9
		diamond, = 3.5						-> 7
		plasma,
		bananium,
		bluespace,
		plasteel, //?
		ferrotitanium, //?
		durasteel, //?
		duranium, //?
*/

	if(T == "slug")
		final_density = ((0.25 * density_1) + (0.75 * density_2))
	else if(T == "canister")
		final_density = ((0.5 * density_1) + (0.5 * density_2))

	return final_density

/obj/machinery/railgun_forge/proc/getHardness(var/T) //Mohs
	var/final_hardness = 0
	var/hardness_1 = 0
	var/hardness_2 = 0

	switch(material_selection_1)
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
			hardness_1 = 3 //TEST
		if("Bluespace")
			hardness_1 = NUM_E ^ 1.5 //TEST
		if("Bananium")
			hardness_1 = 1 //TESTs
		if("Titanium")
			hardness_1 = 6
		if("Copper")
			hardness_1 = 5
		if("Plasteel")
			hardness_1 = 0 //<-------
		if("Ferrotitanium")
			hardness_1 = 0 //<-------
		if("Durasteel")
			hardness_1 = 0 //<-------
		if("Duranium")
			hardness_1 = 0 //<-------

	switch(material_selection_2)
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
			hardness_2 = 3 //TEST
		if("Bluespace")
			hardness_2 = NUM_E ^ 1.5 //TEST
		if("Bananium")
			hardness_2 = 1 //TEST
		if("Titanium")
			hardness_2 = 6
		if("Copper")
			hardness_2 = 5
		if("Plasteel")
			hardness_2 = 0 //<-------
		if("Ferrotitanium")
			hardness_2 = 0 //<-------
		if("Durasteel")
			hardness_2 = 0 //<-------
		if("Duranium")
			hardness_2 = 0 //<-------
/*
		diamond, = 10.0
		*carbon steel, = 7.5
		uranium, = 6.0
		titanium, = 6.0
		*stainless steel, = 4.5
		copper, = 5.0
		iron, = 4.0
		silver, = 2.5
		gold, = 2.5
		plasma,
		bananium,
		bluespace,
		plasteel, //?
		ferrotitanium, //?
		durasteel, //?
		duranium, //?
*/

	if(T == "slug")
		final_hardness = ((0.25 * hardness_1) + (0.75 * hardness_2))
	else if(T == "canister")
		final_hardness = ((0.8 * hardness_1) + (0.2 * hardness_2))

	return final_hardness

/obj/machinery/railgun_forge/proc/forge_slug()
	if(tank_1_volume >= 4 && tank_2_volume >= 20) //Duplicate checks
		tank_1_volume -= 4
		tank_2_volume -= 20
		var/turf/T = loc
		var/obj/item/ship_weapon/ammunition/railgun_ammo/forged/F = new(T)
		F.name = "\improper Forged 400mm [material_selection_1] coated [material_selection_2] slug"
		F.material_conductivity = getConductivity("slug")
		F.material_density = getDensity("slug")
		F.material_hardness = getHardness("slug")
		if(material_selection_1 == "Bananium" || material_selection_2 == "Bananium")
			F.railgun_flags += RAIL_BANANA
			F.AddComponent(/datum/component/slippery, 40, null, 20, TRUE)
		if(material_selection_1 == "Bluespace" || material_selection_2 == "Bluespace")
			F.railgun_flags += RAIL_BLUESPACE
		if(material_selection_1 == "Plasma" || material_selection_2 == "Plasma")
			F.railgun_flags += RAIL_BURN
			F.AddComponent(/datum/component/volatile, 3, TRUE, 1)
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
		do_sparks(5, FALSE, src)

/obj/machinery/railgun_forge/proc/forge_canister()
	if(tank_1_volume >= 20 && tank_2_volume >= 30) //Duplicate checks
		tank_1_volume -= 20
		tank_2_volume -= 30
		var/turf/T = loc
		var/obj/item/ship_weapon/ammunition/railgun_ammo_canister/F = new(T)
		F.name = "\improper Forged 800mm [material_selection_1] coated [material_selection_2] canister"
		F.material_conductivity = getConductivity("canister")
		F.material_density = getDensity("canister")
		F.material_hardness = getHardness("canister")
		if(material_selection_1 == "Bananium" || material_selection_2 == "Bananium")
			F.railgun_flags += RAIL_BANANA
			F.AddComponent(/datum/component/slippery, 40, null, 20, TRUE)
		if(material_selection_1 == "Bluespace" || material_selection_2 == "Bluespace")
			F.railgun_flags += RAIL_BLUESPACE
		if(material_selection_1 == "Plasma" || material_selection_2 == "Plasma")
			F.railgun_flags += RAIL_BURN
			F.AddComponent(/datum/component/volatile, 3, TRUE, 1)
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
		do_sparks(5, FALSE, src)

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
	switch(action)
		if("print_slug")
			if(tank_1_alloy_lock == FALSE || tank_2_alloy_lock == FALSE)
				to_chat(usr, "<span class='notice'>Error: Fabrication materials not selected</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else if(tank_1_volume < 4 || tank_2_volume < 20)
				to_chat(usr, "<span class='notice'>Error: Insufficent fabrication resources</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				forge_slug()

		if("print_canister")
			if(tank_1_alloy_lock == FALSE || tank_2_alloy_lock == FALSE)
				to_chat(usr, "<span class='notice'>Error: Fabrication materials not selected</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else if(tank_1_volume < 20 || tank_2_volume < 30)
				to_chat(usr, "<span class='notice'>Error: Insufficent fabrication resources</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				forge_canister()

		if("purge_t1")
			if(alert("Allocated resources will not be recoverable when purging the coating tank",name,"Continue","Abort") != "Abort" && Adjacent(usr))
				to_chat(usr, "<span class='warning'>Purging coating tank</span>")
				material_selection_1 = 0
				tank_1_alloy_lock = FALSE
				tank_1_processing = FALSE
				tank_1_volume = 0
				return

		if("purge_t2")
			if(alert("Allocated resources will not be recoverable when purging the core tank",name,"Continue","Abort") != "Abort" && Adjacent(usr))
				to_chat(usr, "<span class='warning'>Purging core tank</span>")
				material_selection_2 = 0
				tank_2_alloy_lock = FALSE
				tank_2_processing = FALSE
				tank_2_volume = 0
				return

		if("t1_list")
			t1_holder = params["value"]
			return

		if("t2_list")
			t2_holder = params["value"]
			return

		if("t1_set_material")
			if(tank_1_alloy_lock)
				to_chat(usr, "<span class='notice'>Error: Coating tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_1 = t1_holder //Because I've only used strings in the tgui materials list, we will also just use those here.
				tank_1_alloy_lock = TRUE
				return TRUE //We can safely return after having completed our action TRUE will make the ui reload itself to update any ui_data that may have changed.

		if("t2_set_material")
			if(tank_2_alloy_lock)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = t2_holder
				tank_2_alloy_lock = TRUE
				return TRUE

		if("t1_set_processing")
			if(tank_1_processing)
				tank_1_processing = FALSE
				to_chat(usr, "<span class='notice'>Coating Tank Processing: Disabled.</span>")
				return
			else if(!tank_1_alloy_lock)
				to_chat(usr, "<span class='notice'>Error: Material selection must be locked before processing.</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				tank_1_processing = TRUE
				to_chat(usr, "<span class='notice'>Coating Tank Processing: Enabled.</span>")
				return

		if("t2_set_processing")
			if(tank_2_processing)
				tank_2_processing = FALSE
				to_chat(usr, "<span class='notice'>Core Tank Processing: Disabled.</span>")
				return
			else if(!tank_2_alloy_lock)
				to_chat(usr, "<span class='notice'>Error: Material selection must be locked before processing.</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				tank_2_processing = TRUE
				to_chat(usr, "<span class='notice'>Core Tank Processing: Enabled.</span>")
				return

	return

/obj/machinery/railgun_forge/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["t1_volume"] = tank_1_volume
	data["t1_alloy_lock"] = tank_1_alloy_lock
	data["t1_processing"] = tank_1_processing
	data["t1_material"] = material_selection_1
	data["t2_volume"] = tank_2_volume
	data["t2_alloy_lock"] = tank_2_alloy_lock
	data["t2_processing"] = tank_2_processing
	data["t2_material"] = material_selection_2
	return data

///////////////////////////////////////////////////////////////////////////////

/obj/machinery/atmospherics/components/binary/railgun_filler
	name = "Railgun Canister Filler"
	desc = "Device for filling and sealing railgun canister munitions"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = TRUE
	anchored = TRUE
	dir = 8
	var/loading = FALSE
	var/obj/item/ship_weapon/ammunition/railgun_ammo_canister/F

/obj/machinery/atmospherics/components/binary/railgun_filler/proc/fill_canister()
	if(F)
		var/moles_check = F.canister_gas.total_moles()
		if(moles_check != 0)
			message_admins("Pressure Check:[moles_check]")
			return
		else
			var/datum/gas_mixture/air1 = airs[1]
			var/datum/gas_mixture/buffer = air1.remove(50)
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
			var/datum/gas_mixture/buffer = F.canister_gas.remove(50)
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
		var/datum/gas_mixture/buffer = F.canister_gas.remove(50)
		env.merge(buffer)
		update_parents()
	eject_canister()

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
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
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
			if(F.material_charge < 100)
				F.material_charge += (charge_rate / 10000)
				if(F.material_charge > 100)
					F.material_charge = 100
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
				discharge = !discharge
		if("toggle_charge")
			if(!discharge)
				charge = !charge
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
		/obj/item/stock_parts/matter_bin = 10,
		/obj/item/stock_parts/manipulator = 5,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/capacitor = 8,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/railgun_charger //update my components
	name = "Railgun Forge (Machine Board)"
	build_path = /obj/machinery/railgun_forge
	req_components = list(
		/obj/item/stock_parts/matter_bin = 10,
		/obj/item/stock_parts/manipulator = 5,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/capacitor = 8,
		/obj/item/stock_parts/micro_laser = 2)
