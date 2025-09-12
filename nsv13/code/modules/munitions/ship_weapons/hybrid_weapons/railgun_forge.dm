/obj/machinery/railgun_forge
	/*

	Material Allocation:
	0 - None
	1 - Iron
	# - GLASS
	2 - Silver
	3 - Gold
	4 - Diamond
	5 - Uranium
	6 - Plasma
	7 - Bluespace
	8 - Bananium
	9 - Titanium
	# - PLASTIC
	# - BIOMASS
	10 - Copper
	/ALLOYS\
	11 - Plasteel
	12 - Ferrotitanium
	13 - Durasteel
	14 - Duranium
	15 -

	*/

	name = "Railgun Forge"
	desc = "Device for forging railgun munitions"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "autolathe"
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

	//Core Alloy Tank
	var/tank_2_volume = 0
	var/tank_2_alloy_lock = FALSE
	var/tank_2_processing = FALSE
	var/material_selection_2

/obj/machinery/railgun_forge/Initialize(mapload)
	.=..()
	r_materials = AddComponent(/datum/component/remote_materials, "railgun_forge", mapload)

/obj/machinery/railgun_forge/process(delta_time)
	. = ..()
	if(auto_use_power()) //check proc
		handle_material_processing_t1()
		handle_material_processing_t2()

/obj/machinery/railgun_forge/proc/set_alloy_tank_1()
	tank_1_alloy_lock = TRUE //For simplicity sake, we aren't allowing mixing of additional materials in an active batch


/obj/machinery/railgun_forge/proc/set_alloy_tank_2()
	tank_2_alloy_lock = TRUE


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
				if(1) //Iron
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 100)
						tank_1_volume += 10
				if(2) //Silver
					if(r_materials.mat_container.has_enough_of_material(/datum/material/silver, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/silver, 100)
						tank_1_volume += 10
				if(3) //Gold
					if(r_materials.mat_container.has_enough_of_material(/datum/material/gold, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/gold, 100)
						tank_1_volume += 10
				if(4) //Diamond
					if(r_materials.mat_container.has_enough_of_material(/datum/material/diamond, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/diamond, 100)
						tank_1_volume += 10
				if(5) //Uranium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/uranium, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/uranium, 100)
						tank_1_volume += 10
				if(6) //Plasma
					if(r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/plasma, 100)
						tank_1_volume += 10
				if(7) //Bluespace
					if(r_materials.mat_container.has_enough_of_material(/datum/material/bluespace, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/bluespace, 100)
						tank_1_volume += 10
				if(8) //Bananium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/bananium, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/bananium, 100)
						tank_1_volume += 10
				if(9) //Titanium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/titanium, 100)
						tank_1_volume += 10
				if(10) //Copper
					if(r_materials.mat_container.has_enough_of_material(/datum/material/copper, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/copper, 100)
						tank_1_volume += 10
				if(11) //Plasteel
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 50) && r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 50) )
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 50)
						r_materials.mat_container.use_amount_mat(/datum/material/plasma, 50)
						tank_1_volume += 10
				if(12) //Ferrotitaium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 25) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 75))
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 25)
						r_materials.mat_container.use_amount_mat(/datum/material/titanium, 75)
						tank_1_volume += 10
				if(13) //Durasteel
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 20) && r_materials.mat_container.has_enough_of_material(/datum/material/silver, 15) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 65))
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 20)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 15)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 65)
						tank_1_volume += 10
				if(14) //Duranium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 17.5) && r_materials.mat_container.has_enough_of_material(/datum/material/silver, 15) && r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 5) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 62.5))
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 17.5)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 15)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 5)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 62.5)
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
				if(1) //Iron
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 100)
						tank_2_volume += 10
				if(2) //Silver
					if(r_materials.mat_container.has_enough_of_material(/datum/material/silver, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/silver, 100)
						tank_2_volume += 10
				if(3) //Gold
					if(r_materials.mat_container.has_enough_of_material(/datum/material/gold, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/gold, 100)
						tank_2_volume += 10
				if(4) //Diamond
					if(r_materials.mat_container.has_enough_of_material(/datum/material/diamond, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/diamond, 100)
						tank_2_volume += 10
				if(5) //Uranium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/uranium, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/uranium, 100)
						tank_2_volume += 10
				if(6) //Plasma
					if(r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/plasma, 100)
						tank_2_volume += 10
				if(7) //Bluespace
					if(r_materials.mat_container.has_enough_of_material(/datum/material/bluespace, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/bluespace, 100)
						tank_2_volume += 10
				if(8) //Bananium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/bananium, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/bananium, 100)
						tank_2_volume += 10
				if(9) //Titanium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/titanium, 100)
						tank_2_volume += 10
				if(10) //Copper
					if(r_materials.mat_container.has_enough_of_material(/datum/material/copper, 100))
						r_materials.mat_container.use_amount_mat(/datum/material/copper, 100)
						tank_2_volume += 10
				if(11) //Plasteel
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 50) && r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 50) )
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 50)
						r_materials.mat_container.use_amount_mat(/datum/material/plasma, 50)
						tank_2_volume += 10
				if(12) //Ferrotitaium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 25) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 75))
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 25)
						r_materials.mat_container.use_amount_mat(/datum/material/titanium, 75)
						tank_2_volume += 10
				if(13) //Durasteel
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 20) && r_materials.mat_container.has_enough_of_material(/datum/material/silver, 15) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 65))
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 20)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 15)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 65)
						tank_2_volume += 10
				if(14) //Duranium
					if(r_materials.mat_container.has_enough_of_material(/datum/material/iron, 17.5) && r_materials.mat_container.has_enough_of_material(/datum/material/silver, 15) && r_materials.mat_container.has_enough_of_material(/datum/material/plasma, 5) && r_materials.mat_container.has_enough_of_material(/datum/material/titanium, 62.5))
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 17.5)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 15)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 5)
						r_materials.mat_container.use_amount_mat(/datum/material/iron, 62.5)
						tank_2_volume += 10

/obj/machinery/railgun_forge/proc/getConductivity(var/T)
	var/final_conductivty = 0
	var/conductivity_1 = 0
	var/conductivity_2 = 0

	switch(material_selection_1)
		if(1) //Iron
			conductivity_1 = 1.0
		if(2) //Silver
			conductivity_1 = 6.3
		if(3) //Gold
			conductivity_1 = 4.1
		if(4) //Diamond
			conductivity_1 = 0.001
		if(5) //Uranium
			conductivity_1 = 0.36
		if(6) //Plasma
			conductivity_1 = 0.001
		if(7) //Bluespace
			conductivity_1 = 0.001
		if(8) //Bananium
			conductivity_1 = 0.001
		if(9) //Titanium
			conductivity_1 = 0.24
		if(10) //Copper
			conductivity_1 = 5.9
		if(11) //Plasteel
			conductivity_1 = 0 //<-------
		if(12) //Ferrotitanium
			conductivity_1 = 0 //<-------
		if(13) //Durasteel
			conductivity_1 = 0 //<-------
		if(14) //Duranium
			conductivity_1 = 0 //<-------

	switch(material_selection_2)
		if(1) //Iron
			conductivity_2 = 1.0
		if(2) //Silver
			conductivity_2 = 6.3
		if(3) //Gold
			conductivity_2 = 4.1
		if(4) //Diamond
			conductivity_2 = 0.001
		if(5) //Uranium
			conductivity_2 = 0.36
		if(6) //Plasma
			conductivity_2 = 0.001
		if(7) //Bluespace
			conductivity_2 = 0.001
		if(8) //Bananium
			conductivity_2 = 0.001
		if(9) //Titanium
			conductivity_2 = 0.24
		if(10) //Copper
			conductivity_2 = 5.9
		if(11) //Plasteel
			conductivity_2 = 0 //<-------
		if(12) //Ferrotitanium
			conductivity_2 = 0 //<-------
		if(13) //Durasteel
			conductivity_2 = 0 //<-------
		if(14) //Duranium
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
		final_conductivty = ((0.25 * conductivity_1) + (0.75 * conductivity_2))
	else if(T == "canister")
		final_conductivty = ((0.4 * conductivity_1) + (0.6 * conductivity_2))

	return final_conductivty

/obj/machinery/railgun_forge/proc/getDensity(var/T)
	var/final_density = 0
	var/density_1 = 0
	var/density_2 = 0

	switch(material_selection_1)
		if(1) //Iron
			density_1 = 14
		if(2) //Silver
			density_1 = 22
		if(3) //Gold
			density_1 = 40
		if(4) //Diamond
			density_1 = 7
		if(5) //Uranium
			density_1 = 38
		if(6) //Plasma
			density_1 = 0 //<-------
		if(7) //Bluespace
			density_1 = 0 //<-------
		if(8) //Bananium
			density_1 = 0 //<-------
		if(9) //Titanium
			density_1 = 9
		if(10) //Copper
			density_1 = 18
		if(11) //Plasteel
			density_1 = 0 //<-------
		if(12) //Ferrotitanium
			density_1 = 0 //<-------
		if(13) //Durasteel
			density_1 = 0 //<-------
		if(14) //Duranium
			density_1 = 0 //<-------

	switch(material_selection_2)
		if(1) //Iron
			density_2 = 14
		if(2) //Silver
			density_2 = 22
		if(3) //Gold
			density_2 = 40
		if(4) //Diamond
			density_2 = 7
		if(5) //Uranium
			density_2 = 38
		if(6) //Plasma
			density_2 = 0 //<-------
		if(7) //Bluespace
			density_2 = 0 //<-------
		if(8) //Bananium
			density_2 = 0 //<-------
		if(9) //Titanium
			density_2 = 9
		if(10) //Copper
			density_2 = 18
		if(11) //Plasteel
			density_2 = 0 //<-------
		if(12) //Ferrotitanium
			density_2 = 0 //<-------
		if(13) //Durasteel
			density_2 = 0 //<-------
		if(14) //Duranium
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
		if(1) //Iron
			hardness_1 = 4
		if(2) //Silver
			hardness_1 = 2.5
		if(3) //Gold
			hardness_1 = 2.5
		if(4) //Diamond
			hardness_1 = 10
		if(5) //Uranium
			hardness_1 = 6
		if(6) //Plasma
			hardness_1 = 0 //<-------
		if(7) //Bluespace
			hardness_1 = 0 //<-------
		if(8) //Bananium
			hardness_1 = 0 //<-------
		if(9) //Titanium
			hardness_1 = 6
		if(10) //Copper
			hardness_1 = 5
		if(11) //Plasteel
			hardness_1 = 0 //<-------
		if(12) //Ferrotitanium
			hardness_1 = 0 //<-------
		if(13) //Durasteel
			hardness_1 = 0 //<-------
		if(14) //Duranium
			hardness_1 = 0 //<-------

	switch(material_selection_2)
		if(1) //Iron
			hardness_2 = 4
		if(2) //Silver
			hardness_2 = 2.5
		if(3) //Gold
			hardness_2 = 2.5
		if(4) //Diamond
			hardness_2 = 10
		if(5) //Uranium
			hardness_2 = 6
		if(6) //Plasma
			hardness_2 = 0 //<-------
		if(7) //Bluespace
			hardness_2 = 0 //<-------
		if(8) //Bananium
			hardness_2 = 0 //<-------
		if(9) //Titanium
			hardness_2 = 6
		if(10) //Copper
			hardness_2 = 5
		if(11) //Plasteel
			hardness_2 = 0 //<-------
		if(12) //Ferrotitanium
			hardness_2 = 0 //<-------
		if(13) //Durasteel
			hardness_2 = 0 //<-------
		if(14) //Duranium
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
	if(tank_1_volume >= 10 && tank_2_volume >= 2) //Duplicate checks
		tank_1_volume -= 10
		tank_2_volume -= 2
		var/obj/item/ship_weapon/ammunition/railgun_ammo/forged/F = new(src)
		F.material_conductivity = getConductivity("slug")
		F.material_density = getDensity("slug")
		F.material_hardness = getHardness("slug")
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
		do_sparks(5, FALSE, src)

/obj/machinery/railgun_forge/proc/forge_canister()
	if(tank_1_volume >= 10 && tank_2_volume >= 15) //Duplicate checks
		tank_1_volume -= 10
		tank_2_volume -= 15
		var/obj/item/ship_weapon/ammunition/railgun_ammo/forged/canister/F = new(src)
		F.material_conductivity = getConductivity("canister")
		F.material_density = getDensity("canister")
		F.material_hardness = getHardness("canister")
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
	if(..())
		return
	switch(action)
		if("print_slug")
			if(material_selection_1 == 0 || material_selection_2 == 0)
				to_chat(usr, "<span class='notice'>Error: Fabrication materials not selected</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else if(tank_1_volume < 10 || tank_2_volume < 2)
				to_chat(usr, "<span class='notice'>Error: Insufficent fabrication resources</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				forge_slug()

		if("print_canister")
			if(material_selection_1 == 0 || material_selection_2 == 0)
				to_chat(usr, "<span class='notice'>Error: Fabrication materials not selected</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else if(tank_1_volume < 10 || tank_2_volume < 15)
				if(tank_1_volume >= 10 && tank_2_volume >= 15) //Double Check?
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
				tank_1_volume = 0

		if("purge_t2")
			if(alert("Allocated resources will not be recoverable when purging the core tank",name,"Continue","Abort") != "Abort" && Adjacent(usr))
				to_chat(usr, "<span class='warning'>Purging core tank</span>")
				material_selection_2 = 0
				tank_2_volume = 0
				return

		if("t1_set_material")
			if(material_selection_1 != 0)
				to_chat(usr, "<span class='notice'>Error: Coating tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
			else
				material_selection_1 = params[1] //Because I've only used strings in the tgui materials list, we will also just use those here.
				return TRUE //We can safely return after having completed our action TRUE will make the ui reload itself to update any ui_data that may have changed.
			return //You generally write this in the actual action and not at the end of the proc itself. I don't think there is a specific reason

		if("t2-1-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 1
				. = TRUE
		if("t2-2-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 2
				. = TRUE
		if("t2-3-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 3
				. = TRUE
		if("t2-4-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 4
				. = TRUE
		if("t2-5-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 5
				. = TRUE
		if("t2-6-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 6
				. = TRUE
		if("t2-7-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 7
				. = TRUE
		if("t2-8-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 8
				. = TRUE
		if("t2-9-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 9
				. = TRUE
		if("t2-10-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 10
				. = TRUE
		if("t2-11-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 11
				. = TRUE
		if("t2-12-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 12
				. = TRUE
		if("t2-13-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 13
				. = TRUE
		if("t2-14-a")
			if(material_selection_2 != 0)
				to_chat(usr, "<span class='notice'>Error: Core tank must be purged before selecting another material</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_selection_2 = 14
				. = TRUE

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

/obj/machinery/railgun_charger
	name = "Railgun Canister Charger"
	desc = "Device for charging and discharging railgun canister munitions"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "autolathe"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 15
	active_power_usage = 0
	circuit = /obj/item/circuitboard/machine/railgun_charger
	var/discharge = FALSE
	var/loading = FALSE
	var/charge_rate = 0
	var/obj/item/ship_weapon/ammunition/railgun_ammo/forged/canister/F

/obj/machinery/railgun_charger/process(delta_time)
	. = ..()
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
		else
			if(F.material_charge < 100)
				F.material_charge += charge_rate
				if(F.material_charge > 100)
					F.material_charge = 100
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

/obj/machinery/railgun_charger/proc/eject_canister() //Probably bad code practice
	if(F)
		F.forceMove(get_turf(src))
		F.stabilized = FALSE
		F = null //wipe our ref

/obj/machinery/railgun_charger/attackby(obj/item/I, mob/user)
	if(!loading)
		if(istype(I, /obj/item/ship_weapon/ammunition/railgun_ammo/forged/canister))
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
	if(..())
		return
	var/adjust = text2num(params["adjust"])
	switch(action)
		if("charge_rate")
			charge_rate = adjust
			active_power_usage = adjust
		if("toggle_charge")
			discharge = !discharge
		if("eject")
			eject_canister()
	return

/obj/machinery/railgun_charger/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["canister_charge"] = F.material_charge
	data["canister_name"] = F.name
	data["canister_charge_rate"] = charge_rate
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
