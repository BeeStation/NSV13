//Medical Research
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(chemist)
//Ivory Tower Research
MAP_REMOVE_JOB(scientist)
MAP_REMOVE_JOB(roboticist)
//Civilian
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(chaplain)
MAP_REMOVE_JOB(mime)
//Security
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(detective)
MAP_REMOVE_JOB(deputy)
MAP_REMOVE_JOB(brig_phys)
//Munitions
MAP_REMOVE_JOB(pilot)
MAP_REMOVE_JOB(air_traffic_controller)

//Shuttles Disabled - All

/datum/map_template/shuttle/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	can_be_bought = FALSE

//Disabled objects

/obj/item/circuitboard/machine/ore_silo/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	build_path = null

/obj/item/circuitboard/machine/ore_redemption/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	build_path = null

/obj/item/circuitboard/machine/chem_dispenser/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	build_path = null

/obj/structure/frame/machine/attackby(obj/item/P, mob/user, params)
	switch(state)
		if(2)
			if(istype(P, /obj/item/circuitboard/machine))
				var/obj/item/circuitboard/machine/B = P
				if(B.build_path == null)
					to_chat(user, "<span class='warning'>This ship cannot support this type of machine!</span>")
					return

			if(P.tool_behaviour == TOOL_SCREWDRIVER)
				if(circuit.build_path == null)
					to_chat(user, "<span class='warning'>This ship cannot support this type of machine!</span>")
					return
	. = ..()

//Bottle Chemistry Packs

/datum/supply_pack/medical/chemical_supply_compounds/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	hidden = FALSE

/datum/supply_pack/medical/chemical_supply_metals/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	hidden = FALSE

/datum/supply_pack/medical/chemical_supply_alkali_metals/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	hidden = FALSE

/datum/supply_pack/medical/chemical_supply_pnictogens/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	hidden = FALSE

/datum/supply_pack/medical/chemical_supply_tetrels/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	hidden = FALSE

/datum/supply_pack/medical/chemical_supply_alkaline_earth_metals_triels/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	hidden = FALSE

/datum/supply_pack/medical/chemical_supply_halogens/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	hidden = FALSE

/datum/supply_pack/medical/chemical_supply_chalcogens/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	hidden = FALSE

// Lathe storage
/obj/machinery/rnd/production/New()
	. = ..()
	base_storage *= 2

//Job Changes

/datum/job/bridge/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/atmos/New()
	..()
	MAP_JOB_CHECK
	minimal_access += ACCESS_ENGINE
	total_positions = 1
	spawn_positions = 1

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/cyborg/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 3

/datum/job/clown/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 3

/datum/job/emt/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/munitions_tech/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/cargo_tech/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4

/datum/job/bartender/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/cook/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/rd/New()
	..()
	MAP_JOB_CHECK
	total_positions = 0
	spawn_positions = 0

#undef JOB_MODIFICATION_MAP_NAME
