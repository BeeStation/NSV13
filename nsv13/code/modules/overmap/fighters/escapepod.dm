/obj/structure/overmap/fighter/escapepod
	name = "Escape Pod"
	desc = "An escape pod launched from a space faring vessel. It only has very limited thrusters and is thus very slow."
	icon = 'nsv13/icons/overmap/nanotrasen/escape_pod.dmi'
	icon_state = "escape_pod"
	damage_states = FALSE
	bound_width = 32 //Change this on a per ship basis
	bound_height = 32
	pixel_z = 0
	pixel_w = 0
	mass = MASS_TINY
	max_integrity = 50 //Able to withstand more punishment so that people inside it don't get yeeted as hard
	speed_limit = 2 //This, for reference, will feel suuuuper slow, but this is intentional
	flight_state = 6 //FLIGHT_READY
	canopy_open = FALSE
	has_escape_pod = FALSE
	docking_mode = TRUE //Trust me on this :bonklit:
	max_torpedoes = 0
	max_missiles = 0
	prebuilt = TRUE
	components = list(/obj/item/fighter_component/fuel_tank/t1,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/light/t1,
						/obj/item/fighter_component/targeting_sensor/light/t1,
						/obj/item/fighter_component/engine/light/t1,
						/obj/item/fighter_component/countermeasure_dispenser/t1)
