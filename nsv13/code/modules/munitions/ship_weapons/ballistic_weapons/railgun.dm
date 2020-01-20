/obj/machinery/ship_weapon/railgun
	name = "NT-STC4 Ship mounted railgun chamber"
	desc = "A powerful ship-to-ship weapon which uses a localized magnetic field accelerate a projectile through a spinally mounted railgun with a 360 degree rotation axis. This particular model has an effective range of 20,000KM."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "OBC"
	bound_width = 128
	bound_height = 64
	pixel_y = -64

	fire_mode = FIRE_MODE_RAILGUN

	semi_auto = TRUE
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	max_ammo = 3 //Until you have to manually load it back up again. Battleships IRL have 3-4 shots before you need to reload the rack

/obj/machinery/ship_weapon/railgun/after_fire()
	if(!ammo.len)
		say("Autoloader has depleted all ammunition sources. Reload required.")
		return
	..()

/obj/machinery/ship_weapon/railgun/set_position(obj/structure/overmap/OM)
	..()
	overlay = new/obj/weapon_overlay/railgun
	overlay.icon = OM.icon
	overlay.appearance_flags |= KEEP_APART
	overlay.appearance_flags |= RESET_TRANSFORM
	OM.vis_contents += overlay

/obj/machinery/ship_weapon/railgun/MouseDrop_T(obj/structure/A, mob/user)
	return

/obj/machinery/ship_weapon/railgun/animate_projectile(atom/target)
	. = ..()
	linked.shake_everyone(3)
