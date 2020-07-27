//Utility is as Raptor
//Slow, Reasonably Nimble, Robust
//Pickups up pods, refuels in space, repairs things, module module modules
/obj/structure/overmap/fighter/utility
	name = "Su-437 Sabre"
	desc = "An Su-437 Sabre utility vessel. Designed for robustness in deep space and as a highly modular platform, able to be fitted out for any situation. Drag and drop crates / ore boxes to load them into its cargo hold."
	icon = 'nsv13/icons/overmap/nanotrasen/carrier.dmi'
	icon_state = "carrier"
	armor = list("melee" = 70, "bullet" = 70, "laser" = 70, "energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 15, "overmap_heavy" = 0)
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	mass = MASS_TINY
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 75 //Squishy!
	max_passengers = 1
	speed_limit = 3 //Slower than fighters
	pixel_w = -16
	pixel_z = -20
	req_one_access = list(ACCESS_MUNITIONS, ACCESS_ENGINE)
	chassis = 3
	max_cargo = 4

	forward_maxthrust = 3
	backward_maxthrust = 3
	side_maxthrust = 3
	max_angular_acceleration = 110
	ftl_goal = 45 SECONDS //Raptors can, by default, initiate relative FTL jumps to other ships.

/obj/structure/overmap/fighter/utility/apply_weapons()
	return

/obj/structure/overmap/fighter/utility/prebuilt/tanker //refueling other fighters in space
	prebuilt = TRUE
	components = list(/obj/item/fighter_component/fuel_tank/t1,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/utility/t1,
						/obj/item/fighter_component/engine/utility/t1,
						/obj/item/fighter_component/countermeasure_dispenser/t1,
						/obj/item/fighter_component/primary/utility/refueling_system,
						/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/t1)

/obj/structure/overmap/fighter/utility/prebuilt/carrier //search and recovery of pilots in space, and troop transport
	prebuilt = TRUE
	components = list(/obj/item/fighter_component/fuel_tank/t1,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/utility/t1,
						/obj/item/fighter_component/engine/utility/t1,
						/obj/item/fighter_component/countermeasure_dispenser/t1,
						/obj/item/fighter_component/primary/utility/search_rescue_module,
						/obj/item/fighter_component/secondary/utility/passenger_compartment_module/t1)

/obj/structure/overmap/fighter/utility/prebuilt/carrier/mining
	icon = 'nsv13/icons/overmap/nanotrasen/carrier_mining.dmi'
	req_one_access = list(ACCESS_FIGHTER, ACCESS_MINING)

/obj/structure/overmap/fighter/utility/prebuilt/repair //exterior repair of the main ship
	prebuilt = TRUE
	components = list(/obj/item/fighter_component/fuel_tank/t1,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/utility/t1,
						/obj/item/fighter_component/engine/utility/t1,
						/obj/item/fighter_component/countermeasure_dispenser/t1,
						/obj/item/fighter_component/primary/utility/rapid_breach_sealing_module,
						/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/t1)

/obj/structure/overmap/fighter/utility/prebuilt/carrier/syndicate //PVP MODE
	name = "Syndicate Utility Vessel"
	desc = "A boarding craft for rapid troop deployment."
	icon = 'nsv13/icons/overmap/syndicate/syn_raptor.dmi'
	req_one_access = ACCESS_SYNDICATE
	faction = "syndicate"
	start_emagged = TRUE

/obj/structure/overmap/fighter/utility/docking_act(obj/structure/overmap/OM)
	if(docking_cooldown)
		return FALSE
	if(mass < OM.mass && OM.docking_points.len && docking_mode) //If theyre smaller than us,and we have docking points, and they want to dock
		return transfer_from_overmap(OM)
	if(mass >= OM.mass && docking_mode) //Looks like theyre smaller than us, and need rescue.
		if(istype(OM, /obj/structure/overmap/fighter/escapepod)) //Can we take them aboard?
			if(OM.operators.len <= max_passengers+1-OM.mobs_in_ship.len) //Max passengers + 1 to allow for one raptor crew rescuing another. Imagine that theyre being cramped into the footwell or something.
				docking_cooldown = TRUE
				addtimer(VARSET_CALLBACK(src, docking_cooldown, FALSE), 5 SECONDS) //Prevents jank.
				var/obj/structure/overmap/fighter/escapepod/ep = OM
				relay_to_nearby('nsv13/sound/effects/ship/boarding_pod.ogg')
				to_chat(pilot,"<span class='warning'>Extending docking armatures...</span>")
				ep.transfer_occupants_to(src)
				qdel(ep)
			else
				if(pilot)
					to_chat(pilot,"<span class='warning'>[src]'s passenger cabin is full, you'd need [max_passengers+1-OM.mobs_in_ship.len] more seats to retrieve everyone!</span>")
			return TRUE

/obj/structure/overmap/fighter/utility/verb/space_to_space_refueling()
	set name = "Toggle Space-to-Space Refueling Mode"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
