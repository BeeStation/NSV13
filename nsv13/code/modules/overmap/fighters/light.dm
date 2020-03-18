//Light Fighter as is Viper
//Fast, nimble, flimsy
//Uses Light Cannons and Missiles
/obj/structure/overmap/fighter/light
	name = "F-614B Quebec" //need better name
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	brakes = TRUE
	armor = list("melee" = 80, "bullet" = 50, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //temp to stop easy destruction from small arms
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	mass = MASS_TINY
	sprite_size = 32
	damage_states = TRUE
	faction = "nanotrasen"
	max_integrity = 120 //Really really squishy!
	torpedoes = 0
	speed_limit = 6 //We want fighters to be way more maneuverable
	weapon_safety = TRUE //This happens wayy too much for my liking. Starts OFF.
	pixel_w = -16
	pixel_z = -20

/obj/structure/overmap/fighter/light/prebuilt
	prebuilt = TRUE
	components = list(/obj/item/fighter_component/fuel_tank/t1,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/light/t1,
						/obj/item/fighter_component/targeting_sensor/light/t1,
						/obj/item/fighter_component/engine/light/t1,
						/obj/item/fighter_component/countermeasure_dispenser/t1,
						/obj/item/fighter_component/light/secondary/missile_rack/t1,
						/obj/item/fighter_component/light/primary/light_cannon/t1)