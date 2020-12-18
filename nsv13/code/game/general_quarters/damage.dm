/obj/structure/overmap/proc/nuclear_impact()
	set waitfor = FALSE
	relay('nsv13/sound/effects/ship/nukehit.ogg', message="<span class='warning'>You hear a huge rumble as a blinding flash of light envelops you!</span>")
	for(var/mob/living/karmics_victim in mobs_in_ship)
		if(karmics_victim.stat == DEAD)	//They're dead!
			continue
		if(istype(karmics_victim.loc, /obj/structure/closet/secure_closet/freezer)) //Indiana Jones reference go brrr.
			shake_camera(karmics_victim, 2, 1)
			continue
		shake_camera(karmics_victim, 4, 1)
		karmics_victim.soundbang_act(1, 0, 10, 15)
		karmics_victim.flash_act(affect_silicon = TRUE)
		new /obj/effect/dummy/lighting_obj (get_turf(karmics_victim), LIGHT_COLOR_WHITE, (10), 4, 2)

	for(var/area/AR in linked_areas)
		if(prob(10))
			relay(pick(GLOB.overmap_impact_sounds)) //Kaboom
		if(prob(80))
			var/turf/T = pick(get_area_turfs(AR))
			radiation_pulse(T, 1000, 10)
			T.atmos_spawn_air("o2=500;plasma=200;TEMP=5000")

//For training purposes.
/obj/structure/overmap/proc/simulate_nuke()
	relay('nsv13/sound/effects/ship/incoming_missile.ogg', message="<h1>Missile Impact Imminent</h1><br/><span class='danger'>Thermonuclear launch detected. All hands brace for impact.</span>")
	sleep(5 SECONDS) //This is a sin, but it won't be used much.
	var/turf/open/pickedstart = get_turf(pick(orange(10, src)))
	var/turf/open/pickedgoal = get_turf(src)
	var/obj/item/projectile/proj = new /obj/item/projectile/guided_munition/torpedo/nuclear(pickedstart)
	proj.starting = pickedstart
	proj.firer = null
	proj.def_zone = "chest"
	proj.original = pickedgoal
	spawn()
		proj.fire(Get_Angle(pickedstart,pickedgoal))
		proj.set_pixel_speed(4)
