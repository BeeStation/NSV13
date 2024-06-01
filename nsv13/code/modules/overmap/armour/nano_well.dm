/*
HOW 2 APNP/APNW?! - A Guide for M*ppers

General Checklist:
 - High Security Engineering Room
 - APNW x 1
 - APNP x 4 (using each of the pref definied quadrants)
 - 10 Iron Sheets
 - 10 Titanium Sheets

//ADDITION INFORMATION

High Security Engineering Room Requirements
	As this room controls ALL of the overmap repairing abilities of the ship, it is a great target for sabotage and damage in general.
	If destroyed it could swiftly lead to catastrophic mission failure.
	Things to consider:
						Reinforced Walls
						Reinforced Ceilings/Floors
						Motion Sensors
						Cameras Gallore
						Restricted Access
						Anything that makes this a real pain to get into (be creative)

Room Layout
	Each of the the APNPs and the APNW must be accessable, in addition to having a small material storage area/rack
	Things to consider:
						APNP and APNW sprites are approximately 1.5x2 tiles in size, spread them out to look better
						How far do you want to make the engineers run to manage all five devices?
						How are you going to integrate the room security features?

Power Considerations
	The APNP/APNW can be quite power intensive (Approximately 1.5MW total at maximum load), PLEASE DO NOT HAVE THE APC HOTWIRED INTO MAIN AT ROUND START.
	If engineers choose to do that during the round, then that is their decision.
	Things to consider:
						Large power draw to room
						Dedicated SMES Battery (remember they are 200KW per unit)
						Expanding current SMES bank handle higher loads

Starting Materials
	While it may seem tempting to give the engineers a massive pile of mats at round start, we are trying to encourage interdepartment cooperation.
	Additional materials can be scavenged from around the ship, acquired from mining or ordered from cargo (with the engineering budget card)
*/

#define RR_MAX 5000

/obj/machinery/armour_plating_nanorepair_well
	name = "\improper Armour Plating Nano-repair Well"
	desc = "Central Well for the AP thingies"
	icon = 'nsv13/icons/obj/machinery/armour_well.dmi'
	icon_state = "well"
	pixel_x = -16
	density = TRUE
	anchored = TRUE
	idle_power_usage = 50
	active_power_usage = 0
	circuit = /obj/item/circuitboard/machine/armour_plating_nanorepair_well
	layer = ABOVE_MOB_LAYER
	obj_integrity = 500
	var/obj/structure/overmap/OM //our parent ship
	var/obj/structure/cable/cable = null //Connected cable
	var/list/apnp = list() //our child pumps
	var/resourcing_system = FALSE //System for generating additional RR
	var/repair_resources = 0 //Pool of liquid metal ready to be pumped out for repairs
	var/repair_resources_processing = FALSE
	var/repair_efficiency = 0 //modifier for how much repairs we get per cycle
	var/power_allocation = 0 //how much power we are pumping into the system
	var/maximum_power_allocation = 3000000 //3MW
	var/system_allocation = 0 //the load on the system
	var/system_stress = 0 //how overloaded the system has been over time
	var/system_stress_threshold = 100 //Threshold at which stress beings to build up
	var/system_cooling = 1 //Rate at which stress is reduced
	var/material_modifier = 0 //efficiency of our materials
	var/material_tier = 0 //The selected tier recipe producing RR
	var/apnw_id = null //The ID by which we identify our child devices - These should match the child devices and follow the formula: 1 - Main Ship, 2 - Secondary Ship, 3 - Syndie PvP Ship

/obj/machinery/armour_plating_nanorepair_well/Initialize(mapload)
	.=..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/armour_plating_nanorepair_well/LateInitialize()
	. = ..()
	AddComponent(/datum/component/material_container,\
		list(/datum/material/iron, /datum/material/silver, /datum/material/titanium, /datum/material/plasma),\
		1000000, FALSE, /obj/item/stack, null, null, FALSE)

	OM = get_overmap()
	addtimer(CALLBACK(src, PROC_REF(handle_linking)), 30 SECONDS)

/obj/machinery/armour_plating_nanorepair_well/examine(mob/user)
	.=..()
	if(OM?.linked_apnw != src)
		. += "<span class='warning'>WARNING: DUPLICATE APNW DETECTED!</span>"
	if(maximum_power_allocation != initial(maximum_power_allocation))
		. += "<span class='notice'>It hums with energy.</span>"
	if(system_stress_threshold != initial(system_stress_threshold))
		. += "<span class='notice'>It whirrs with vim.</span>"
	if(system_cooling != initial(system_cooling))
		. += "<span class='notice'>It resonates with stability.</span>"

/obj/machinery/armour_plating_nanorepair_well/process()
	if(OM?.linked_apnw == src)
		handle_power_allocation()
		handle_system_stress()

		if(!try_use_power(active_power_usage))
			repair_resources_processing = FALSE
			repair_efficiency = 0
			update_icon()
			return FALSE

		if(is_operational)
			handle_repair_resources()
			handle_repair_efficiency()
			update_icon()
			return TRUE

/obj/machinery/armour_plating_nanorepair_well/proc/try_use_power(amount) //checking to see if we have a cable
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(cable?.surplus() > amount)
		cable.powernet.load += amount
		return TRUE
	return FALSE

/obj/machinery/armour_plating_nanorepair_well/proc/handle_repair_efficiency() //Sigmoidal Curve
	repair_efficiency = ((1 / (0.01 + (NUM_E ** (-0.000003334 * power_allocation)))) * material_modifier) / 100
	if(power_allocation > 3e6) //If overclocking
		repair_efficiency += ((power_allocation - 3e6) / 3e7) / 2

/obj/machinery/armour_plating_nanorepair_well/proc/handle_system_stress()
	system_allocation = 0
	for(var/obj/machinery/armour_plating_nanorepair_pump/P in apnp)
		if(P.armour_allocation > 0 || P.structure_allocation > 0)
			system_allocation += P.armour_allocation
			system_allocation += P.structure_allocation

	if(system_allocation <= system_stress_threshold)
		system_stress -= system_cooling
		if(system_stress <= 0)
			system_stress = 0
	if(system_allocation > system_stress_threshold)
		system_stress += (system_allocation/system_stress_threshold)
		if(system_stress_threshold != initial(system_stress_threshold))
			if(prob(2))
				do_sparks(3, FALSE, src)
		if(system_stress > system_stress_threshold * 2)
			system_stress = system_stress_threshold * 2

	if(system_stress >= system_stress_threshold)
		var/turf/open/L = get_turf(src)
		if(!istype(L) || !(L.air))
			return
		var/datum/gas_mixture/env = L.return_air()
		var/current_temp = env.return_temperature()
		env.set_temperature(current_temp + 3)
		air_update_turf()
		if(prob(system_stress - system_stress_threshold))
			var/list/overload_candidate = list()
			for(var/obj/machinery/armour_plating_nanorepair_pump/oc_apnp in apnp)
				if(oc_apnp.armour_allocation > 0 || oc_apnp.structure_allocation > 0)
					overload_candidate += oc_apnp
			if(overload_candidate.len > 0)
				var/obj/machinery/armour_plating_nanorepair_pump/target_apnp = pick(overload_candidate)
				if(target_apnp.last_restart < world.time + 60 SECONDS)
					target_apnp.stress_shutdown = TRUE

/obj/machinery/armour_plating_nanorepair_well/proc/handle_power_allocation()
	active_power_usage = power_allocation
	if(power_allocation >= 3e6) //If overlocking
		var/turf/open/L = get_turf(src)
		if(!istype(L) || !(L.air))
			return
		var/datum/gas_mixture/env = L.return_air()
		var/current_temp = env.return_temperature()
		if(current_temp < 398) //Spicy but not too spicy
			env.set_temperature(current_temp + (power_allocation / 3e7)) //Heat the air
			air_update_turf()

/obj/machinery/armour_plating_nanorepair_well/proc/handle_repair_resources()
	if(resourcing_system)
		if(repair_resources >= RR_MAX)
			repair_resources_processing = FALSE
			return
		else if(repair_resources < RR_MAX)
			switch(material_tier)
				if(0) //None Selected
					return
				if(1) //Iron
					var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
					var/iron_amount = (min(100, (RR_MAX - repair_resources))) * 10
					if(materials.has_enough_of_material(/datum/material/iron, iron_amount))
						materials.use_amount_mat(iron_amount, /datum/material/iron)
						repair_resources += iron_amount / 8
						material_modifier = 0.33 //Very Low modifier
						repair_resources_processing = TRUE
				if(2) //Plasteel
					var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
					var/iron_amount = (min(50, (RR_MAX - repair_resources) * 0.5)) * 10
					var/plasma_amount = (min(50, (RR_MAX - repair_resources) * 0.5)) * 10
					if(materials.has_enough_of_material(/datum/material/iron, iron_amount) && materials.has_enough_of_material(/datum/material/plasma, plasma_amount))
						materials.use_amount_mat(iron_amount, /datum/material/iron)
						materials.use_amount_mat(plasma_amount, /datum/material/plasma)
						repair_resources += (iron_amount + plasma_amount) / 8
						material_modifier = 0.50 //Low Modifier
						repair_resources_processing = TRUE
				if(3) //Ferrotitanium
					var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
					var/iron_amount = (min(25, (RR_MAX - repair_resources) * 0.25)) * 10
					var/titanium_amount = (min(75, (RR_MAX - repair_resources) * 0.75)) * 10
					if(materials.has_enough_of_material(/datum/material/iron, iron_amount) && materials.has_enough_of_material(/datum/material/titanium, titanium_amount))
						materials.use_amount_mat(iron_amount, /datum/material/iron)
						materials.use_amount_mat(titanium_amount, /datum/material/titanium)
						repair_resources += (iron_amount + titanium_amount) / 8
						material_modifier = 0.50 //Low Modifier
						repair_resources_processing = TRUE
				if(4) //Durasteel
					var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
					var/iron_amount = (min(20, (RR_MAX - repair_resources) * 0.20)) * 10
					var/silver_amount = (min(15, (RR_MAX -  repair_resources) * 0.15)) * 10
					var/titanium_amount = (min(65, (RR_MAX - repair_resources) * 0.65)) * 10
					if(materials.has_enough_of_material(/datum/material/iron, iron_amount) && materials.has_enough_of_material(/datum/material/silver, silver_amount) && materials.has_enough_of_material(/datum/material/titanium, titanium_amount))
						materials.use_amount_mat(iron_amount, /datum/material/iron)
						materials.use_amount_mat(silver_amount, /datum/material/silver)
						materials.use_amount_mat(titanium_amount, /datum/material/titanium)
						repair_resources += (iron_amount + silver_amount + titanium_amount) / 8
						material_modifier = 0.75 //Moderate Modifier
						repair_resources_processing = TRUE
				if(5) //Duranium
					var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
					var/iron_amount = (min(17.5, (RR_MAX - repair_resources) * 0.175)) * 10
					var/silver_amount = (min(15, (RR_MAX -  repair_resources) * 0.15)) * 10
					var/plasma_amount = (min(5, (RR_MAX - repair_resources) * 0.05)) * 10
					var/titanium_amount = (min(62.5, (RR_MAX - repair_resources) * 0.625)) * 10
					if(materials.has_enough_of_material(/datum/material/iron, iron_amount) && materials.has_enough_of_material(/datum/material/silver, silver_amount) && materials.has_enough_of_material(/datum/material/plasma, plasma_amount) && materials.has_enough_of_material(/datum/material/titanium, titanium_amount))
						materials.use_amount_mat(iron_amount, /datum/material/iron)
						materials.use_amount_mat(silver_amount, /datum/material/silver)
						materials.use_amount_mat(plasma_amount, /datum/material/plasma)
						materials.use_amount_mat(titanium_amount, /datum/material/titanium)
						repair_resources += (iron_amount + silver_amount + plasma_amount + titanium_amount) / 8
						material_modifier = 1 //High Modifier
						repair_resources_processing = TRUE
	else
		repair_resources_processing = FALSE

/obj/machinery/armour_plating_nanorepair_well/proc/handle_linking()
	if(!OM)
		OM = get_overmap()
	if(apnw_id) //If mappers set an ID)
		for(var/obj/machinery/armour_plating_nanorepair_pump/P in GLOB.machines)
			if(P.apnw_id == apnw_id)
				apnp += P

	if(!OM?.linked_apnw)
		OM.linked_apnw = src

/obj/machinery/armour_plating_nanorepair_well/attackby(obj/item/I, mob/user, params)
	.=..()
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		M.buffer = src
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer loaded</span>")
	if(istype(I, /obj/item/apnw_oc_module/power))
		if(locate(/obj/item/apnw_oc_module/power) in contents)
			to_chat(user, "<span class='notice'>This type of overclock has already been installed.</span>")
			return
		else
			to_chat(user, "<span class='notice'>You install the [I.name] into the [src.name]")
			playsound(src.loc, "sparks", 50, 1)
			I.forceMove(src)
			maximum_power_allocation = 12000000 //12MW

	if(istype(I, /obj/item/apnw_oc_module/load))
		if(locate(/obj/item/apnw_oc_module/load) in contents)
			to_chat(user, "<span class='notice'>This type of overclock has already been installed.</span>")
			return
		else
			to_chat(user, "<span class='notice'>You install the [I.name] into the [src.name]")
			playsound(src.loc, "sparks", 50, 1)
			I.forceMove(src)
			system_stress_threshold = 200 //Double the load

	if(istype(I, /obj/item/apnw_oc_module/cooling))
		if(locate(/obj/item/apnw_oc_module/cooling) in contents)
			to_chat(user, "<span class='notice'>This type of overclock has already been installed.</span>")
			return
		else
			to_chat(user, "<span class='notice'>You install the [I.name] into the [src.name]")
			playsound(src.loc, "sparks", 50, 1)
			I.forceMove(src)
			system_cooling = 2.5 //2.5x the stress reduction

/obj/machinery/armour_plating_nanorepair_well/update_icon()
	cut_overlays()
	var/repair_resources_percent = (repair_resources / RR_MAX) * 100
	switch(repair_resources_percent)
		if(0 to 25)
			icon_state = "well_0"
		if(25 to 50)
			icon_state = "well_25"
		if(50 to 75)
			icon_state = "well_50"
		if(75 to 100)
			icon_state = "well_75"
		if(100 to INFINITY)
			icon_state = "well_100"

	if(system_stress > system_stress_threshold)
		add_overlay("stressed")
	else if(repair_resources_processing)
		add_overlay("active")

/obj/machinery/armour_plating_nanorepair_well/attack_hand(mob/living/carbon/user)
	.=..()
	if(OM?.linked_apnw != src)
		to_chat(user, "<span class='warning'>WARNING: DUPLICATE APNW DETECTED!</span>")
		return
	else
		ui_interact(user)

/obj/machinery/armour_plating_nanorepair_well/attack_ai(mob/user)
	.=..()
	if(OM?.linked_apnw != src)
		to_chat(user, "<span class='warning'>WARNING: DUPLICATE APNW DETECTED!</span>")
		return
	else
		ui_interact(user)

/obj/machinery/armour_plating_nanorepair_well/attack_robot(mob/user)
	.=..()
	if(OM?.linked_apnw != src)
		to_chat(user, "<span class='warning'>WARNING: DUPLICATE APNW DETECTED!</span>")
		return
	else
		ui_interact(user)

/obj/machinery/armour_plating_nanorepair_well/attack_ghost(mob/user)
	. = ..()
	if(OM?.linked_apnw != src)
		to_chat(user, "<span class='warning'>WARNING: DUPLICATE APNW DETECTED!</span>")
		return
	else
		ui_interact(user)

/obj/machinery/armour_plating_nanorepair_well/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArmourPlatingNanorepairWell")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/armour_plating_nanorepair_well/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!(in_range(src, usr) || IsAdminGhost(usr)))
		return
	var/adjust = text2num(params["adjust"])
	if(action == "power_allocation")
		if(isnum(adjust))
			power_allocation = CLAMP(adjust, 0, maximum_power_allocation)
			return TRUE
	switch(action)
		if("iron")
			if(material_tier != 0)
				to_chat(usr, "<span class='notice'>Error: Resources must be purged from the Well before selecting a different alloy</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_tier = 1
				. = TRUE

		if("plasteel")
			if(material_tier != 0)
				to_chat(usr, "<span class='notice'>Error: Resources must be purged from the Well before selecting a different alloy</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_tier = 2
				. = TRUE

		if("ferrotitanium")
			if(material_tier != 0)
				to_chat(usr, "<span class='notice'>Error: Resources must be purged from the Well before selecting a different alloy</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_tier = 3
				. = TRUE

		if("durasteel")
			if(material_tier != 0)
				to_chat(usr, "<span class='notice'>Error: Resources must be purged from the Well before selecting a different alloy</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_tier = 4
				. = TRUE

		if("duranium")
			if(material_tier != 0)
				to_chat(usr, "<span class='notice'>Error: Resources must be purged from the Well before selecting a different alloy</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				material_tier = 5
				. = TRUE

		if("purge")
			if(resourcing_system)
				to_chat(usr, "<span class='notice'>Error: Resource Processing must first be disabled before purging the Well</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return

			else if(alert("Purging the Well will prevent APNPs from functioning until refilled, continue?",name,"Yes","No") != "No" && Adjacent(usr))
				to_chat(usr, "<span class='warning'>System purging repair resources</span>")
				playsound(src, 'sound/machines/clockcult/steam_whoosh.ogg', 100, 1)
				repair_resources = 0
				material_tier = 0
				var/turf/open/L = get_turf(src)
				if(!istype(L) || !(L.air))
					return
				var/datum/gas_mixture/env = L.return_air()
				var/current_temp = env.return_temperature()
				env.set_temperature(current_temp + 25)
				air_update_turf()
				. = TRUE

		if("unload")
			if(resourcing_system)
				to_chat(usr, "<span class='notice'>Error: Resource Processing must first be disabled before purging the Well</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
				return
			else
				var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
				materials.retrieve_all(get_turf(usr))
				. = TRUE

		if("toggle")
			if(material_tier == 0)
				to_chat(usr, "<span class='notice'>Error: An alloy must be selected before commencing Resource Processing</span>")
				var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
				playsound(src, sound, 100, 1)
			else
				resourcing_system = !resourcing_system
				. = TRUE

/obj/machinery/armour_plating_nanorepair_well/ui_data(mob/user)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/list/data = list()
	data["structural_integrity_current"] = OM.obj_integrity
	data["structural_integrity_max"] = OM.max_integrity
	data["quadrant_fs_armour_current"] = OM.armour_quadrants["forward_starboard"]["current_armour"]
	data["quadrant_fs_armour_max"] = OM.armour_quadrants["forward_starboard"]["max_armour"]
	data["quadrant_as_armour_current"] = OM.armour_quadrants["aft_starboard"]["current_armour"]
	data["quadrant_as_armour_max"] = OM.armour_quadrants["aft_starboard"]["max_armour"]
	data["quadrant_ap_armour_current"] = OM.armour_quadrants["aft_port"]["current_armour"]
	data["quadrant_ap_armour_max"] = OM.armour_quadrants["aft_port"]["max_armour"]
	data["quadrant_fp_armour_current"] = OM.armour_quadrants["forward_port"]["current_armour"]
	data["quadrant_fp_armour_max"] = OM.armour_quadrants["forward_port"]["max_armour"]
	data["repair_resources"] = repair_resources
	data["repair_resources_max"] = RR_MAX
	data["repair_efficiency"] = repair_efficiency
	data["system_allocation"] = system_allocation
	data["system_stress"] = system_stress
	data["system_stress_threshold"] = system_stress_threshold
	data["power_allocation"] = power_allocation
	data["maximum_power_allocation"] = maximum_power_allocation
	data["resourcing"] = resourcing_system
	data["iron"] = materials.get_material_amount(/datum/material/iron)
	data["titanium"] = materials.get_material_amount(/datum/material/titanium)
	data["silver"] = materials.get_material_amount(/datum/material/silver)
	data["plasma"] = materials.get_material_amount(/datum/material/plasma)

	data["available_power"] = 0
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(cable)
		if(cable.powernet)
			data["available_power"] = cable.surplus()

	switch(material_tier)
		if(0)
			data["alloy_t1"] = FALSE
			data["alloy_t2"] = FALSE
			data["alloy_t3"] = FALSE
			data["alloy_t4"] = FALSE
			data["alloy_t5"] = FALSE
		if(1)
			data["alloy_t1"] = TRUE
			data["alloy_t2"] = FALSE
			data["alloy_t3"] = FALSE
			data["alloy_t4"] = FALSE
			data["alloy_t5"] = FALSE
		if(2)
			data["alloy_t1"] = FALSE
			data["alloy_t2"] = TRUE
			data["alloy_t3"] = FALSE
			data["alloy_t4"] = FALSE
			data["alloy_t5"] = FALSE
		if(3)
			data["alloy_t1"] = FALSE
			data["alloy_t2"] = FALSE
			data["alloy_t3"] = TRUE
			data["alloy_t4"] = FALSE
			data["alloy_t5"] = FALSE
		if(4)
			data["alloy_t1"] = FALSE
			data["alloy_t2"] = FALSE
			data["alloy_t3"] = FALSE
			data["alloy_t4"] = TRUE
			data["alloy_t5"] = FALSE
		if(5)
			data["alloy_t1"] = FALSE
			data["alloy_t2"] = FALSE
			data["alloy_t3"] = FALSE
			data["alloy_t4"] = FALSE
			data["alloy_t5"] = TRUE
	return data

/obj/item/circuitboard/machine/armour_plating_nanorepair_well
	name = "Armour Plating Nano-repair Well (Machine Board)"
	build_path = /obj/machinery/armour_plating_nanorepair_well
	req_components = list(
		/obj/item/stock_parts/matter_bin = 10,
		/obj/item/stock_parts/manipulator = 5,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/capacitor = 8,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/apnw_oc_module
	name = "Armour Plating Nano-repair Well Overclocking Module (PARENT)"
	desc = "A small electronic device that alters operational parameters of the APNW. This will likely void the warranty."
	icon = 'nsv13/icons/obj/objects.dmi'
	icon_state = "oc_module"
	w_class = 3

/obj/item/apnw_oc_module/power //Changes power cap to 10MW
	name = "Armour Plating Nano-repair Well Overclocking Module (Overwattage)"

/obj/item/apnw_oc_module/power/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Allows the allocation of additional power to the APNW - MAY CAUSE OVERHEATING</span>"

/obj/item/apnw_oc_module/load //Changes stress threshold to 200%
	name = "Armour Plating Nano-repair Well Overclocking Module (Overload)"

/obj/item/apnw_oc_module/load/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Allows the allocation of additional system load to the APNW - MAY CAUSE VOLTAGE SPIKES</span>"

/obj/item/apnw_oc_module/cooling //Changes stress reduction to 2.5 per cycle
	name = "Armour Plating Nano-repair Well Overclocking Module (Cooling)"

/obj/item/apnw_oc_module/cooling/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Allows the allocation of additional system load to the APNW - MAY CAUSE REALITY DISTORTIONS</span>" //It really doesn't

#undef RR_MAX
