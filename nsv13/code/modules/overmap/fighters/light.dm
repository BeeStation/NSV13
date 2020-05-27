//Light Fighter as is Viper
//Fast, nimble, flimsy
//Uses Light Cannons and Missiles
/obj/structure/overmap/fighter/light
	name = "Su-818 Rapier"
	desc = "An Su-818 Rapier space superiorty fighter craft. Designed for high maneuvreability and maximum combat effectivness against other similar weight classes."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 30, "bomb" = 30, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 10, "overmap_heavy" = 5)
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	mass = MASS_TINY
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 100 //Really really squishy!
	speed_limit = 6 //We want fighters to be way more maneuverable
	pixel_w = -16
	pixel_z = -20
	chassis = 1

/obj/structure/overmap/fighter/light/prebuilt
	prebuilt = TRUE
	components = list(/obj/item/fighter_component/fuel_tank/t1,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/light/t1,
						/obj/item/fighter_component/targeting_sensor/light/t1,
						/obj/item/fighter_component/engine/light/t1,
						/obj/item/fighter_component/countermeasure_dispenser/t1,
						/obj/item/fighter_component/secondary/light/missile_rack/t1,
						/obj/item/fighter_component/primary/light/light_cannon/t1)

/obj/structure/overmap/fighter/light/prebuilt/flight_leader
	req_one_access = list(ACCESS_FL)
	icon_state = "ace"

/obj/structure/overmap/fighter/light/prebuilt/syndicate //PVP MODE
	name = "Syndicate Light Fighter"
	desc = "The Syndicate's answer to Nanotrasen's light fighter craft, this fighter is designed to maintain aerial supremacy."
	icon = 'nsv13/icons/overmap/syndicate/syn_viper.dmi'
	req_one_access = ACCESS_SYNDICATE
	faction = "syndicate"
	start_emagged = TRUE