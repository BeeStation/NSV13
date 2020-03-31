//Utility is as Raptor
//Slow, Reasonably Nimble, Robust
//Pickups up pods, refuels in space, repairs things, module module modules
/obj/structure/overmap/fighter/utility
	name = "Su-437 Sabre"
	desc = "An Su-437 Sabre utility vessel. Designed for robustness in deep space and as a highly modular platform, able to be fitted out for any situation."
	icon = 'nsv13/icons/overmap/nanotrasen/carrier.dmi'
	icon_state = "carrier"
	armor = list("melee" = 70, "bullet" = 40, "laser" = 70, "energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 20)
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	mass = MASS_TINY
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 150 //Squishy!
	max_passengers = 1
	speed_limit = 3 //Slower than fighters
	pixel_w = -16
	pixel_z = -20

	forward_maxthrust = 2
	backward_maxthrust = 2
	side_maxthrust = 2

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

/obj/structure/overmap/fighter/utility/attackby(obj/item/W, mob/user, params) //changing utility equipment - used in fighters.dm maintenance mode
	.=..()
	if(maint_state == 2)  //MS_OPEN == 2
		if(istype(W, /obj/item/fighter_component/armour_plating/utility) && !get_part(/obj/item/fighter_component/armour_plating/utility))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			fuel_setup()
		else if(istype(W, /obj/item/fighter_component/engine/utility) && !get_part(/obj/item/fighter_component/engine/utility))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/fighter_component/secondary/utility) && !get_part(/obj/item/fighter_component/secondary/utility))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()
		else if(istype(W, /obj/item/fighter_component/primary/utility) && !get_part(/obj/item/fighter_component/primary/utility))
			to_chat(user, "<span class='notice'>You start installing [W] in [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You install [W] in [src].</span>")
			W.forceMove(src)
			update_stats()

/obj/structure/overmap/fighter/utility/docking_act(obj/structure/overmap/OM)
	if(docking_cooldown)
		return
	if(mass < OM.mass && OM.docking_points.len && docking_mode) //If theyre smaller than us,and we have docking points, and they want to dock
		transfer_from_overmap(OM)
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

/obj/structure/overmap/fighter/utility/verb/space_to_space_refueling()
	set name = "Toggle Space-to-Space Refueling Mode"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
