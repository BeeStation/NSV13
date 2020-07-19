/obj/machinery/ship_weapon/mac
	name = "Radial MAC cannon"
	desc = "An extremely powerful electromagnet which can accelerate a projectile to devastating speeds."
	icon_state = "MAC"
	fire_mode = FIRE_MODE_MAC
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	pixel_y = -64
	bound_width = 128
	bound_height = 64


/obj/machinery/ship_weapon/mac/set_position(obj/structure/overmap/OM)
	..()
	overlay = linked.add_weapon_overlay("/obj/weapon_overlay/railgun")