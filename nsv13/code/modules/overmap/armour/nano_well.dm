//WELL GOES HERE
#define OFFLINE 0
#define ONLINE 1

/obj/machinery/armour_plating_nanorepair_well
	name = "Armour Plating Nano-repair Well"
	desc = "Central Well for the AP thingies"
	icon = 'nsv13/icons/obj/machinery/FTL_silo.dmi'
	icon_state = "silo"
	pixel_x = -32
	density = TRUE
	anchored = TRUE
	idle_power_usage = 50
	active_power_usage = 1000 //temp
	var/obj/structure/overmap/OM //our parent ship
	var/repair_resources = 0
	var/repair_efficiency = 0
	var/power_allocation = 0
	var/system_allocation = 0
	var/system_stress = 0
	var/list/material_silo = list()
	var/material_modifier = 1
	var/state = 0
	var/apnw_id = 0

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

/obj/machinery/armour_plating_nanorepair_well/LateInitialize()
	OM = get_overmap()

/obj/machinery/armour_plating_nanorepair_well/process()
	/*things we need to do here:
	- check if we are on
	- check our stress levels and act
	- check our resources and process them
	- check our power allocation and adjust accordingly
	- check our repair efficiency
	*/
	if(state == ONLINE)
		handle_system_stress()
		handle_repair_resources()
		handle_power_allocation()
		handle_repair_efficiency()

/obj/machinery/armour_plating_nanorepair_well/proc/handle_repair_efficiency() //Basic implementation
	repair_efficiency = power_allocation * material_modifier

/obj/machinery/armour_plating_nanorepair_well/proc/handle_system_stress() //Basic implementation
	switch(system_allocation)
		if(-INFINITY to 0)
			system_stress = 0
		if(0 to 100)
			system_stress -= (100 - system_allocation / 25)
		if(100 to INFINITY)
			system_stress += (system_allocation/100)

	//stress implications go here

/obj/machinery/armour_plating_nanorepair_well/proc/handle_power_allocation()

/obj/machinery/armour_plating_nanorepair_well/proc/handle_repair_resources()
	if(repair_resources >= 5000)
		return
	else if(repair_resources < 5000)
		var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
		if(materials.use_amount_mat(100, /datum/material/iron)) //test case
			repair_resources += 100
			material_modifier = 1
		//chew metals
		//update material modifier based on number of materals used

/*
/datum/component/material_container/proc/remove_amount_from_all(amt)
	var/toRemove = amt / materials.len
	var/removed = 0
	for(var/X in materials)
		removed += materials[X]

	materials[X] = (materials[X] >= 0) ? materials[X] : 0

	if(istype(X, /datum/material/iron))
*/

#undef OFFLINE
#undef ONLINE