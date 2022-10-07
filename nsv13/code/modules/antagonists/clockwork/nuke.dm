/obj/machinery/nuclearbomb/syndicate/clock
	name = "ratvar nuclear payload"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "ratvarbomb_base"

/obj/machinery/nuclearbomb/syndicate/clock/process()
	if(timing && !exploding)
		if(detonation_timer < world.time)
			clock_explode()
		else
			var/volume = (get_time_left() <= 20 ? 30 : 5)
			playsound(loc, 'sound/items/clock_nuke.ogg', volume, FALSE)

/obj/machinery/nuclearbomb/syndicate/clock/proc/clock_explode()
	if(safety)
		timing = FALSE
		return

	exploding = TRUE
	yes_code = FALSE
	safety = TRUE
	update_icon()
	if(proper_bomb)
		sound_to_playing_players('sound/effects/ratvar_rises.ogg')
	if(SSticker?.mode)
		SSticker.roundend_check_paused = TRUE
	addtimer(CALLBACK(src, .proc/actually_explode), 100)

/obj/machinery/nuclearbomb/syndicate/clock/update_icon()
	if(deconstruction_state == NUKESTATE_INTACT)
		switch(get_nuke_state())
			if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
				icon_state = "ratvarbomb_base"
				update_icon_interior()
				update_icon_lights()
			if(NUKE_ON_TIMING)
				cut_overlays()
				icon_state = "ratvarbomb_timing"
			if(NUKE_ON_EXPLODING)
				cut_overlays()
				icon_state = "ratvarbomb_exploding"
	else
		icon_state = "ratvarbomb_base"
		update_icon_interior()
		update_icon_lights()
