/obj/machinery/ship_weapon/deck_turret
	name = "M4-15 'Hood' deck turret"
	desc = "A huge naval gun utilising an integral railgun to fire. Inspired by the classics, this gun packs a major punch and is quite easy to reload."
	icon = 'nsv13/icons/obj/munitions/deck_turret.dmi'
	icon_state = "deck_turret"
	fire_mode = FIRE_MODE_MAC
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	pixel_x = -45
	pixel_y = -63
	bound_width = 64
	bound_height = 128
	semi_auto = TRUE
	max_ammo = 6
	obj_integrity = 500
	max_integrity = 500
	safety = FALSE
	var/obj/structure/gauss_rack/ammo_rack = null

/obj/machinery/ship_weapon/deck_turret/local_fire()
	. = ..()
	var/obj/structure/overmap/OM = get_overmap()
	for(var/mob/M in OM.mobs_in_ship)
		if(OM.z == z)
			shake_camera(M, 1, 1)

/obj/machinery/ship_weapon/deck_turret/north
	pixel_x = -43
	pixel_y = -32

/obj/machinery/ship_weapon/deck_turret/east
	pixel_x = -30
	pixel_y = -42
	bound_width = 128
	bound_height = 64

/obj/machinery/ship_weapon/deck_turret/west
	pixel_x = -63
	pixel_y = -42
	bound_width = 128
	bound_height = 64

/obj/machinery/ship_weapon/deck_turret/Initialize()
	. = ..()
	ammo_rack = new /obj/structure/gauss_rack(src)
	ammo_rack.gun = src
	lower_rack()

/obj/machinery/ship_weapon/deck_turret/proc/raise_rack()
	if(!ammo_rack || ammo?.len >= max_ammo)
		return
	playsound(ammo_rack.loc, 'nsv13/sound/effects/ship/freespace2/crane_2.wav', 100, FALSE)
	ammo_rack.pixel_y = 0
	ammo_rack.loading = TRUE
	animate(ammo_rack, pixel_y = 60, time = 4 SECONDS)
	sleep(4 SECONDS)
	ammo_rack.forceMove(src)
	rackLoad()

/obj/machinery/ship_weapon/deck_turret/proc/rackLoad()
	loading = TRUE
	var/cache = ammo.len
	for(var/obj/item/ship_weapon/ammunition/A in ammo_rack.contents)
		if(ammo?.len < max_ammo)
			ammo_rack.unload(A)
			A.forceMove(src)
			ammo += A
	if(load_sound)
		playsound(src, load_sound, 100, 1)
	state = 2
	loading = FALSE
	if(cache <= 0)
		feed()
		chamber()
	sleep(3 SECONDS)
	lower_rack()

/obj/machinery/ship_weapon/deck_turret/proc/lower_rack()
	if(!ammo_rack)
		return
	ammo_rack.loading = FALSE
	var/turf/below = get_turf(SSmapping.get_turf_below(src))
	playsound(below, 'nsv13/sound/effects/ship/freespace2/crane_2.wav', 100, FALSE)
	ammo_rack.forceMove(below)
	ammo_rack.pixel_y = 60
	animate(ammo_rack, pixel_y = 0, time = 4 SECONDS)
	sleep(4 SECONDS)
	ammo_rack.visible_message("<span class='notice'>[ammo_rack] clunks into place!</span>")
	playsound(ammo_rack, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
