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
	active_power_usage = 1000 //temp
	var/obj/structure/overmap/OM //our parent ship
	var/list/apnp = list()
	var/repair_resources = 0
	var/repair_resources_processing = FALSE
	var/repair_efficiency = 0
	var/power_allocation = 0
	var/system_allocation = 0
	var/system_stress = 0
	var/list/material_silo = list()
	var/material_modifier = 1
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
					20000,
					FALSE,
					/obj/item/stack,
					null,
					null,
					FALSE)

	OM = get_overmap()
	addtimer(CALLBACK(src, .proc/handle_linking), 10 SECONDS)

/obj/machinery/armour_plating_nanorepair_well/process()
	/*things we need to do here:
	- check if we are on
	- check our stress levels and act
	- check our resources and process them
	- check our power allocation and adjust accordingly
	- check our repair efficiency
	*/
	handle_system_stress()
	handle_repair_resources()
	handle_power_allocation()
	handle_repair_efficiency()
	update_icon()

/obj/machinery/armour_plating_nanorepair_well/proc/handle_repair_efficiency() //Basic implementation
	repair_efficiency = (1 / (0.01 + (NUM_E ** (-0.00001 * power_allocation)))) * material_modifier

/obj/machinery/armour_plating_nanorepair_well/proc/handle_system_stress() //Basic implementation
	system_allocation = 0
	for(var/obj/machinery/armour_plating_nanorepair_pump/P in apnp)
		if(P.online)
			system_allocation += P.armour_allocation
			system_allocation += P.structure_allocation

	switch(system_allocation)
		if(0 to 100)
			system_stress -= min((100 - system_allocation / 25), 0 - system_stress)
		if(100 to INFINITY)
			system_stress += (system_allocation/100)

	//stress implications go here

/obj/machinery/armour_plating_nanorepair_well/proc/handle_power_allocation()
	active_power_usage = power_allocation

/obj/machinery/armour_plating_nanorepair_well/proc/handle_repair_resources()
	if(repair_resources >= RR_MAX)
		repair_resources_processing = FALSE
		return
	else if(repair_resources < RR_MAX)
		var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
		if(materials.use_amount_mat(100, /datum/material/iron)) //test case
			repair_resources += min(100, RR_MAX - repair_resources)
			material_modifier = 1
			repair_resources_processing = TRUE
		//chew metals
		//update material modifier based on number of materals used

/obj/machinery/armour_plating_nanorepair_well/proc/handle_linking()
	if(apnw_id) //If mappers set an ID)
		for(var/obj/machinery/armour_plating_nanorepair_pump/P in GLOB.machines)
			if(P.apnw_id == apnw_id)
				apnp += P

/*
/datum/component/material_container/proc/remove_amount_from_all(amt)
	var/toRemove = amt / materials.len
	var/removed = 0
	for(var/X in materials)
		removed += materials[X]

	materials[X] = (materials[X] >= 0) ? materials[X] : 0

	if(istype(X, /datum/material/iron))
*/
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

	if(repair_resources_processing)
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
	data["repair_efficiency"] = repair_efficiency
	data["system_allocation"] = system_allocation
	data["system_stress"] = system_stress
	data["power_allocation"] = power_allocation
	return data

#undef RR_MAX