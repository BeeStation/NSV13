/obj/structure/overmap/small_craft/transport/gunship
	name = "SC-130 'Halberd' gunship"
	desc = "A horrible, cramped death trap armed to the teeth with more guns than most small nations, all of which are under investigation for their carcinogenic properties."

	//Beefy Gunships get to use armour quads
	max_integrity = 300
	use_armour_quadrants = TRUE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 300, "current_armour" = 300),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 300, "current_armour" = 300),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 300, "current_armour" = 300),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 300, "current_armour" = 300))

	//Vars for tracking various repairs
	var/repair_inner = FALSE
	var/repair_fp = FALSE
	var/repair_fs = FALSE
	var/repair_ap = FALSE
	var/repair_as = FALSE

	possible_interior_maps = list(/datum/map_template/dropship/gunship)
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/ftl,
						/obj/item/fighter_component/countermeasure_dispenser)

/datum/map_template/dropship/gunship
    name = "SC-130 Halberd Gunship"
    mappath = "_maps/templates/boarding/gunship.dmm"

/obj/structure/overmap/small_craft/transport/gunship/apply_weapons()
	if(!weapon_types[FIRE_MODE_ANTI_AIR])
		weapon_types[FIRE_MODE_ANTI_AIR] = new/datum/ship_weapon/fighter_primary(src)
	if(!weapon_types[FIRE_MODE_TORPEDO])
		weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)
	if(!weapon_types[FIRE_MODE_AMS])
		weapon_types[FIRE_MODE_AMS] = new/datum/ship_weapon/vls(src)
	if(!weapon_types[FIRE_MODE_GAUSS])
		weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
	if(!weapon_types[FIRE_MODE_PDC])
		weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)

/obj/structure/overmap/small_craft/transport/gunship/gauss
	name = "SU-001 Alpha gunship"
	desc = "Alpha"
	possible_interior_maps = list(/datum/map_template/dropship/gunship_gauss)
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/ftl,
						/obj/item/fighter_component/countermeasure_dispenser)

/datum/map_template/dropship/gunship_gauss
	name = "SU-001 Alpha Gunship"
	mappath = "_maps/templates/boarding/gunship_gauss.dmm"

/obj/structure/overmap/small_craft/transport/gunship/gauss/apply_weapons()
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss/super(src)

/obj/structure/overmap/small_craft/transport/gunship/railgun
	name = "SU-999 Omega gunship"
	desc = "Omega"
	possible_interior_maps = list(/datum/map_template/dropship/gunship_railgun)
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/ftl,
						/obj/item/fighter_component/countermeasure_dispenser)

/datum/map_template/dropship/gunship_railgun
	name = "SU-999 Omega Gunship"
	mappath = "_maps/templates/boarding/gunship_railgun.dmm"

/obj/structure/overmap/small_craft/transport/gunship/railgun/apply_weapons()
	weapon_types[FIRE_MODE_HYBRID_RAIL] = new /datum/ship_weapon/hybrid_railgun(src)
