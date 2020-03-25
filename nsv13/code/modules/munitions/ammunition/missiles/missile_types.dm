/obj/item/ship_weapon/ammunition/missile //CREDIT TO CM FOR THIS SPRITE
	name = "Test Missile"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "standard"
	desc = "missile."
	anchored = TRUE
	density = TRUE
	projectile_type = /obj/item/projectile/bullet/missile //What torpedo type we fire
	pixel_x = -17
	var/speed = 1 //Placeholder, allows upgrading speed with better propulsion