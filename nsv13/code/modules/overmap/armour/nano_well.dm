//WELL GOES HERE
#define RR_MAX 5000

/obj/machinery/armour_plating_nanorepair_well
	name = "Armour Plating Nano-repair Well"
	desc = "Central Well for the AP thingies"
	icon = 'nsv13/icons/obj/machinery/armour_well.dmi'
	icon_state = "well"
	pixel_x = -16
	density = TRUE
	anchored = TRUE
	idle_power_usage = 50
	active_power_usage = 1000 //DOES THIS EVEN DO ANYTHING???
	circuit = /obj/item/circuitboard/machine/armour_plating_nanorepair_well
	layer = ABOVE_MOB_LAYER
	obj_integrity = 500
	var/obj/structure/overmap/OM //our parent ship
	var/list/apnp = list()
	var/repair_resources = 0
	var/repair_resources_processing = FALSE
	var/repair_efficiency = 0
	var/power_allocation = 0
	var/system_allocation = 0
	var/system_stress = 0
	var/list/material_silo = list()
	var/list/material_switch = list("iron" = list("online" = FALSE, "datum" = /datum/material/iron), \
									"silver" = list("online" = FALSE, "datum" = /datum/material/silver), \
									"titanium" = list("online" = FALSE, "datum" = /datum/material/titanium), \
									"plasma" = list("online" = FALSE, "datum" = /datum/material/plasma))
	var/material_modifier = 0
	var/material_modifier_target = 0
	var/delta_material_modifier = 0
	var/apnw_id = null

/obj/machinery/armour_plating_nanorepair_well/Initialize()
	/*things we need to do here:
	- link to APNPs in the vacinity
	*/
	.=..()
	AddComponent(/datum/component/material_container,\
				list(/datum/material/iron,\
					/datum/material/silver,\
					/datum/material/titanium,\
					/datum/material/plasma),
					100000,
					FALSE,
					/obj/item/stack,
					null,
					null,
					FALSE)

	OM = get_overmap()
	addtimer(CALLBACK(src, .proc/handle_linking), 10 SECONDS)

/obj/machinery/armour_plating_nanorepair_well/process()

	if(is_operational())
		handle_system_stress()
		handle_repair_resources()
		handle_power_allocation()
		handle_repair_efficiency()
	update_icon()

/obj/machinery/armour_plating_nanorepair_well/proc/handle_repair_efficiency() //Basic implementation
	repair_efficiency = ((1 / (0.01 + (NUM_E ** (-0.00001 * power_allocation)))) * material_modifier) / 100

/obj/machinery/armour_plating_nanorepair_well/proc/handle_system_stress() //Basic implementation
	system_allocation = 0
	for(var/obj/machinery/armour_plating_nanorepair_pump/P in apnp)
		if(P.armour_allocation > 0 || P.structure_allocation > 0)
			system_allocation += P.armour_allocation
			system_allocation += P.structure_allocation

	switch(system_allocation)
		if(0 to 100)
			system_stress --
			if(system_stress <= 0)
				system_stress = 0
		if(100 to INFINITY)
			system_stress += (system_allocation/100)

	if(system_stress >= 100)
		var/turf/open/L = get_turf(src)
		if(!istype(L) || !(L.air))
			return
		var/datum/gas_mixture/env = L.return_air()
		var/current_temp = env.return_temperature()
		env.set_temperature(current_temp + 1)
		air_update_turf()
		if(prob(system_stress - 100))
			var/list/overload_candidate = list()
			for(var/obj/machinery/armour_plating_nanorepair_pump/oc_apnp in apnp)
				if(oc_apnp.armour_allocation > 0 || oc_apnp.structure_allocation > 0)
					overload_candidate += oc_apnp
			if(overload_candidate.len > 0)
				var/obj/machinery/armour_plating_nanorepair_pump/target_apnp = pick(overload_candidate)
				if(target_apnp.last_restart < world.time + 60 SECONDS)
					target_apnp.stress_shutdown = TRUE

	//stress implications go here

/obj/machinery/armour_plating_nanorepair_well/proc/handle_power_allocation()
	idle_power_usage = power_allocation

/obj/machinery/armour_plating_nanorepair_well/proc/handle_repair_resources()
	if(repair_resources >= RR_MAX)
		repair_resources_processing = FALSE
		return
	else if(repair_resources < RR_MAX)
		var/material_types_online = 0
		for(var/X in material_switch)
			if(material_switch[X]["online"])
				material_types_online ++
		if(material_types_online > 0)
			var/material_division = min(100 / material_types_online, (RR_MAX - repair_resources) / material_types_online)
			material_modifier_target = 0
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			for(var/X in material_switch)
				if(material_switch[X]["online"])
					if(materials.use_amount_mat(material_division, material_switch[X]["datum"]))
//					if(materials.has_enough_of_material(material_switch[X]["datum"], material_division))
						materials.use_amount_mat(material_division, material_switch[X]["datum"])
						repair_resources += material_division / 2
						material_modifier_target += 0.25
					repair_resources_processing = TRUE

	if(repair_resources_processing)
		delta_material_modifier = material_modifier_target - material_modifier
		material_modifier += delta_material_modifier / 2

/obj/machinery/armour_plating_nanorepair_well/proc/handle_linking()
	if(apnw_id) //If mappers set an ID)
		for(var/obj/machinery/armour_plating_nanorepair_pump/P in GLOB.machines)
			if(P.apnw_id == apnw_id)
				apnp += P

/obj/machinery/armour_plating_nanorepair_well/attackby(obj/item/I, mob/user, params)
	.=..()
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		M.buffer = src
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer loaded</span>")

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

	if(system_stress > 100)
		add_overlay("stressed")
	else if(repair_resources_processing)
		add_overlay("active")

/obj/machinery/armour_plating_nanorepair_well/attack_hand(mob/living/carbon/user)
	.=..()
	ui_interact(user)

/obj/machinery/armour_plating_nanorepair_well/attack_ai(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/armour_plating_nanorepair_well/attack_robot(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/armour_plating_nanorepair_well/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ArmourPlatingNanorepairWell", name, 560, 600, master_ui, state)
		ui.open()

/obj/machinery/armour_plating_nanorepair_well/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!in_range(src, usr))
		return
	var/adjust = text2num(params["adjust"])
	if(action == "power_allocation")
		if(adjust && isnum(adjust))
			power_allocation = adjust
			if(power_allocation > 1000000)
				power_allocation = 1000000
				return
			if(power_allocation < 0)
				power_allocation = 0
				return
	switch(action)
		if("iron")
			material_switch["iron"]["online"] = !material_switch["iron"]["online"]
			if(material_switch["silver"]["online"] == TRUE)
				if(material_switch["iron"]["online"] == FALSE && material_switch["titanium"]["online"] == FALSE)
					material_switch["silver"]["online"] = FALSE
			if(material_switch["plasma"]["online"] == TRUE)
				if(material_switch["iron"]["online"] == FALSE && material_switch["titanium"]["online"] == FALSE)
					material_switch["plasma"]["online"] = FALSE
		if("titanium")
			material_switch["titanium"]["online"] = !material_switch["titanium"]["online"]
			if(material_switch["silver"]["online"] == TRUE)
				if(material_switch["iron"]["online"] == FALSE && material_switch["titanium"]["online"] == FALSE)
					material_switch["silver"]["online"] = FALSE
			if(material_switch["plasma"]["online"] == TRUE)
				if(material_switch["iron"]["online"] == FALSE && material_switch["titanium"]["online"] == FALSE)
					material_switch["plasma"]["online"] = FALSE
		if("silver")
			if(material_switch["iron"]["online"] == TRUE || material_switch["titanium"]["online"] == TRUE)
				material_switch["silver"]["online"] = !material_switch["silver"]["online"]
			else
				(to_chat(usr, "<span class='warning'> Error: Silver can only be used in a metal alloy</span>"))
		if("plasma")
			if(material_switch["iron"]["online"] == TRUE || material_switch["titanium"]["online"] == TRUE)
				material_switch["plasma"]["online"] = !material_switch["plasma"]["online"]
			else
				(to_chat(usr, "<span class='warning'> Error: Plasma can only be used in a metal alloy</span>"))
		if("purge")
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			materials.retrieve_all(get_turf(usr))

/obj/machinery/armour_plating_nanorepair_well/ui_data(mob/user)
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
	data["power_allocation"] = power_allocation
	data["iron"] = material_switch["iron"]["online"]
	data["silver"] = material_switch["silver"]["online"]
	data["titanium"] = material_switch["titanium"]["online"]
	data["plasma"] = material_switch["plasma"]["online"]
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

#undef RR_MAX