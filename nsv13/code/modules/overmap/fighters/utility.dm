//Utility is as Raptor
//Slow, Reasonably Nimble, Robust
//Pickups up pods, refuels in space, repairs things, module module modules
/obj/structure/overmap/fighter/utility
	name = "ADL-77U Arroyomolinos"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/nanotrasen/carrier.dmi'
	icon_state = "carrier"
	brakes = TRUE
	armor = list("melee" = 80, "bullet" = 50, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //temp to stop easy destruction from small arms
	bound_width = 64 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_TINY
	sprite_size = 32
	damage_states = FALSE
	faction = "nanotrasen"
	max_integrity = 150 //Squishy!
	max_passengers = 1
	torpedoes = 0
	speed_limit = 6 //We want fighters to be way more maneuverable
	weapon_safety = TRUE //This happens wayy too much for my liking. Starts OFF.
	pixel_w = -26
	pixel_z = -28

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
