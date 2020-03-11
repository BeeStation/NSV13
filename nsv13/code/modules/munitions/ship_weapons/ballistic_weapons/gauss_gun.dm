/obj/machinery/ship_weapon/gauss_gun
	name = "NT-STC4 Ship mounted railgun chamber"
	desc = "A powerful ship-to-ship weapon which uses a localized magnetic field accelerate a projectile through a spinally mounted railgun with a 360 degree rotation axis. This particular model has an effective range of 20,000KM."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "gauss_map"
	bound_width = 96
	bound_height = 96
	pixel_x = -23

	fire_mode = FIRE_MODE_GAUSS
	weapon_type = new/datum/ship_weapon/gauss
	ammo_type = /obj/item/ship_weapon/ammunition/gauss

	semi_auto = TRUE
	max_ammo = 6 //Until you have to manually load it back up again. Battleships IRL have 3-4 shots before you need to reload the rack
	firing_sound = 'nsv13/sound/effects/ship/gauss.ogg'
	fire_animation_length = 0.2
	var/obj/left
	var/obj/right

/obj/machinery/ship_weapon/gauss_gun/Initialize()
	. = ..()
	icon_state = "gauss"
	left = new(src)
	left.icon = icon
	left.icon_state = "gauss_left"
	left.mouse_opacity = FALSE
	vis_contents += left

	right = new(src)
	right.icon = icon
	right.icon_state = "gauss_right"
	right.mouse_opacity = FALSE
	vis_contents += right

/obj/machinery/ship_weapon/gauss_gun/do_animation()
	left.icon_state = "gauss_left_firing"
	sleep(2)
	right.icon_state = "gauss_right_firing"
	sleep(10)
	left.icon_state = "gauss_left"
	right.icon_state = "gauss_right"