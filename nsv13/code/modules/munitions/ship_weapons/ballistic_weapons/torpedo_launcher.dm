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
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/torpedo.ogg','nsv13/sound/effects/ship/freespace2/m_shrike.wav','nsv13/sound/effects/ship/freespace2/m_stiletto.wav','nsv13/sound/effects/ship/freespace2/m_tsunami.wav','nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	ammo_type = /obj/item/ship_weapon/ammunition/torpedo
	fire_mode = 2
	overmap_fire_delay = 5

/obj/machinery/ship_weapon/torpedo_launcher/notify_select(obj/structure/overmap/OM, mob/user)
	to_chat(user, "<span class='notice'>Long range target acquisition systems: online.</span>")
	OM.relay(overmap_select_sound)

/obj/machinery/ship_weapon/torpedo_launcher/notify_failed_fire(mob/gunner)
	to_chat(gunner, "<span class='warning'>DANGER: Launch failure! Torpedo tubes are not loaded.</span>")

/obj/machinery/ship_weapon/torpedo_launcher/animate_projectile(atom/target, lateral=TRUE)
	var/obj/item/ship_weapon/ammunition/torpedo/T = chambered
	if(T)
		if(istype(T, /obj/item/projectile/bullet/torpedo/dud)) //Some brainlet MAA loaded an incomplete torp
			linked.fire_projectile(T.projectile_type, target, homing = FALSE, speed=T.speed, explosive = TRUE)
		else
			linked.fire_projectile(T.projectile_type, target, homing = TRUE, speed=T.speed, explosive = TRUE)
