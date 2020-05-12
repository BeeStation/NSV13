//Heavy Fighter
//High Max Speed, Slow turn, Slow acceleration, Robust
//Uses Heavy Cannons and Torps (upgrades for Missiles)
/obj/structure/overmap/fighter/heavy
	name = "Su-410 Scimitar"
	desc = "An Su-410 Scimitar heavy attack craft. Designed for broad strafing runs, punishing soft and hard targets alike."
	icon = 'nsv13/icons/overmap/nanotrasen/heavy_fighter.dmi'
	icon_state = "heavy_fighter"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 25)
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	mass = MASS_TINY
	sprite_size = 32
	damage_states = FALSE //TEMP
	max_integrity = 100 //Really really squishy!
	speed_limit = 6 //We want fighters to be way more maneuverable
	pixel_w = -16
	pixel_z = -20
	chassis = 2

	forward_maxthrust = 2
	backward_maxthrust = 0.5
	side_maxthrust = 2
	max_angular_acceleration = 80

/obj/structure/overmap/fighter/heavy/prebuilt
	prebuilt = TRUE
	components = list(/obj/item/fighter_component/fuel_tank/t1,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/heavy/t1,
						/obj/item/fighter_component/targeting_sensor/heavy/t1,
						/obj/item/fighter_component/engine/heavy/t1,
						/obj/item/fighter_component/countermeasure_dispenser/t1,
						/obj/item/fighter_component/secondary/heavy/torpedo_rack/t1,
						/obj/item/fighter_component/primary/heavy/heavy_cannon/t1)