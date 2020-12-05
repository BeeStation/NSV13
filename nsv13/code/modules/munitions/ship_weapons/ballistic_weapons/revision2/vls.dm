/obj/item/ship_weapon/ammunition/missile/cruise
	name = "MS-1 'Sparrowhawk' standard cruise missile"
	desc = "Lethally precise, terrifyingly destructive. Can only be fired from the VLS."
	icon = 'nsv13/icons/obj/munitions/missile.dmi'
	icon_state = "standard"
	bound_width = 128
	anchored = TRUE
	density = TRUE

/datum/ship_weapon/vls
	name = "Vertical Launch System"
	default_projectile_type = /obj/item/projectile/guided_munition/torpedo
	burst_size = 1
	fire_delay = 5
	range_modifier = 30
	select_alert = "<span class='notice'>Missile target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Missile tubes are not loaded.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'

/obj/machinery/ship_weapon/vls
	name = "M14 VLS Loader"
	desc = "A highly advanced launch platform for missiles inspired by recently discovered old-earth technology. The VLS allows for launching cruise missiles from any angle, and directly interfaces with the AMS for lethal precision."
	icon = 'nsv13/icons/obj/munitions/vls.dmi'
	icon_state = "loader"

	firing_sound = 'nsv13/sound/effects/ship/plasma.ogg'
	load_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav'
	fire_mode = FIRE_MODE_AMS
	ammo_type = /obj/item/ship_weapon/ammunition/missile/cruise
	CanAtmosPass = FALSE
	CanAtmosPassVertical = FALSE
	var/obj/structure/fluff/vls_hatch/hatch = null

/obj/machinery/ship_weapon/vls/Initialize()
	. = ..()
	var/turf/T = SSmapping.get_turf_above(src)
	if(!T)
		return
	hatch = locate(/obj/structure/fluff/vls_hatch) in T

/obj/machinery/ship_weapon/vls/feed()
	. = ..()
	if(!hatch)
		return
	hatch.icon_state = "vls"
	hatch.density = FALSE

/obj/machinery/ship_weapon/vls/local_fire()
	. = ..()
	if(!hatch)
		return
	hatch.icon_state = "vls_closed"
	hatch.density = TRUE

/obj/machinery/ship_weapon/vls/unload_magazine()
	. = ..()
	if(!hatch)
		return
	hatch.icon_state = "vls_closed"
	hatch.density = TRUE

/obj/structure/fluff/vls_hatch
	name = "VLS Launch Hatch"
	desc = "A hatch designed to let cruise missiles out, and keep air in for the deck below."
	icon = 'nsv13/icons/obj/munitions/vls.dmi'
	icon_state = "vls_closed"
	CanAtmosPass = FALSE
	CanAtmosPassVertical = FALSE
	obj_flags = CAN_BE_HIT | BLOCK_Z_FALL
vls_hatch
