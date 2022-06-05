/obj/item/fighter_component/ftl
	name = "class II torch drive"
	desc = "The torch drive is a far faster and more safe alternative to traditional FTL travel methods, however it requires either a star to jump to, or a phyically placed jump beacon."
	icon_state = "ftl_drive"
	slot = HARDPOINT_SLOT_FTL
	active = FALSE
	power_usage = 200
	weight = 0.5
	var/progress = 0
	var/spoolup_time = 2 MINUTES
	var/ftl_startup_time = 6 SECONDS
	var/ftl_loop = 'nsv13/sound/effects/ship/FTL_loop.ogg'
	var/ftl_start = 'nsv13/sound/effects/ship/FTL_torchdrive.ogg'
	var/ftl_exit = 'nsv13/sound/effects/ship/freespace2/warp_close.wav'

	var/jump_speed_factor = 5.5 //How quickly do we jump? Larger is faster.
	var/ftl_state = FTL_STATE_IDLE //Mr Gaeta, spool up the FTLs.

	var/can_cancel_jump = TRUE //Defaults to true. TODO: Make emagging disable this
	var/max_range = 50 //Short range drive
	var/lockout = FALSE

/obj/item/fighter_component/ftl/tier2
	name = "class III torch drive"
	desc = "A micro jump drive with an expanded range."
	max_range = 200

/obj/item/fighter_component/ftl/proc/jump(datum/star_system/target_system, force=FALSE)
	if(!target_system || !SSmapping.level_trait(loc.z, ZTRAIT_OVERMAP))
		return
	var/obj/structure/overmap/linked = loc
	if(!linked)
		return FALSE
	ftl_state = FTL_STATE_JUMPING
	linked?.begin_jump(target_system, force)
	linked.relay('nsv13/sound/effects/ship/freespace2/computer/escape.wav')
	progress = 0
	addtimer(CALLBACK(src, .proc/depower), ftl_startup_time)

/obj/item/fighter_component/ftl/proc/cancel_ftl()
	depower()

/obj/item/fighter_component/ftl/proc/depower()
	progress = 0
	ftl_state = FTL_STATE_IDLE

/*
/obj/item/fighter_component/ftl/proc/jump(obj/structure/overmap/OM, obj/structure/overmap/target, dangerous=FALSE)
	set waitfor = FALSE
	ftl_spool_progress = 0
	OM.relay('nsv13/sound/effects/ship/FTL_torchdrive.ogg')
	sleep(6 SECONDS)
	if(dangerous)
		for(var/mob/living/karmics_victim in OM.mobs_in_ship)
			if(karmics_victim.stat == DEAD)	//They're dead!
				continue
			if(istype(karmics_victim.loc, /obj/structure/closet/secure_closet/freezer)) //Indiana Jones reference go brrr.
				shake_camera(karmics_victim, 2, 1)
				continue
			shake_camera(karmics_victim, 4, 1)
			karmics_victim.soundbang_act(1, 0, 10, 15)
			karmics_victim.flash_act(affect_silicon = TRUE)
		var/turf/T = get_turf(OM)
		radiation_pulse(T, 1000, 10)
		OM.take_damage(obj_integrity/2)
		T.atmos_spawn_air("o2=1500;plasma=1000;TEMP=5000")
		playsound(OM, 'nsv13/sound/effects/ship/FTL.ogg', 100, FALSE)//"Crack"
		return FALSE

	for(var/mob/M in OM.mobs_in_ship)
		if(iscarbon(M))
			var/mob/living/carbon/L = M
			if(HAS_TRAIT(L, TRAIT_SEASICK))
				to_chat(L, "<span class='warning'>You can feel your head start to swim...</span>")
				//BUCKLE YOUR SEATBELT
				var/sick_chance = L.buckled ? 20 : 100
				if(prob(sick_chance)) //Take a roll! First option makes you puke and feel terrible. Second one makes you feel iffy.
					L.adjust_disgust(40)
				else
					L.adjust_disgust(10)
		shake_camera(M, 8, 1)

	OM.relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg', null, ignore_self=TRUE)//"Crack"
	ftl_spool_progress = 0
	OM.alpha = 0
	new /obj/effect/temp_visual/overmap_ftl(get_turf(OM))
	OM.forceMove(get_turf(pick(orange(10, target))))
	new /obj/effect/temp_visual/overmap_ftl(get_turf(OM))
	sleep(1 SECONDS)
	OM.alpha = 255
	OM.relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg', null, ignore_self=TRUE)//"Crack"
	OM.last_overmap = target
	OM.dradis?.reset_dradis_contacts()
	return TRUE
*/

/obj/item/fighter_component/ftl/process()
	//No need to use power here. We're already spooled.
	var/obj/structure/overmap/OM = loc
	if(OM)
		OM.ftl_drive = src
	if(ftl_state == FTL_STATE_JUMPING)
		return
	ftl_state = FTL_STATE_SPOOLING
	if(progress >= spoolup_time)
		ftl_state = FTL_STATE_READY
		return FALSE
	if(!powered())
		return FALSE
	progress += 1 SECONDS
	progress = CLAMP(progress, 0, spoolup_time)

/obj/effect/temp_visual/overmap_ftl
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "warp"
	duration = 1 SECONDS
	randomdir = FALSE
