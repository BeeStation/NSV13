/obj/machinery/ship_weapon/torpedo_launcher //heavily modified CM sprite
	name = "M4-B Torpedo tube"
	desc = "A weapon system that's employed by nigh on all modern ships. It's capable of delivering a self-propelling warhead with pinpoint accuracy to utterly annihilate a target."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "torpedo"
	bound_height = 32
	bound_width = 96
	pixel_y = -72
	pixel_x = -32

	firing_sound = 'nsv13/sound/effects/ship/plasma.ogg'
	load_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav'
	fire_mode = FIRE_MODE_TORPEDO
	ammo_type = /obj/item/ship_weapon/ammunition/torpedo
	fire_mode = 2
	weapon_type = new/datum/ship_weapon/torpedo_launcher

/obj/machinery/ship_weapon/torpedo_launcher/animate_projectile(atom/target, lateral=TRUE)
	// We have different sprites and behaviors for each torpedo
	var/obj/item/ship_weapon/ammunition/torpedo/T = chambered
	if(T)
		if(istype(T, /obj/item/projectile/bullet/torpedo/dud)) //Some brainlet MAA loaded an incomplete torp
			linked.fire_projectile(T.projectile_type, target, homing = FALSE, speed=T.speed, explosive = TRUE)
		else
			linked.fire_projectile(T.projectile_type, target, homing = TRUE, speed=T.speed, explosive = TRUE)
