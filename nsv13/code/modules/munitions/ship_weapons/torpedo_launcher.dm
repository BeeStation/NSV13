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
	ammo_type = /obj/item/ship_weapon/ammunition/torpedo
	fire_mode = 3
	overmap_fire_delay = 5

/obj/machinery/ship_weapon/pdc_mount/notify_select(obj/structure/overmap/OM, mob/user)
	message_admins("Selecting torps")
	to_chat(user, "<span class='notice'>Long range target acquisition systems: online.</span>")
	OM.relay('nsv13/sound/effects/ship/reload.ogg')