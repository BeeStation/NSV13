/datum/looping_sound/advanced/ftl_drive
	start_sound = 'nsv13/sound/machines/FTL/main_drive_spoolup.ogg'
	start_length = 24 SECONDS
	mid_sounds = 'nsv13/sound/machines/FTL/main_drive_loop.ogg'
	mid_length = 10.9 SECONDS
	end_sound = 'nsv13/sound/machines/FTL/main_drive_spooldown.ogg'
	volume = 100
	can_process = TRUE

// We use pretty long sounds here so we'll update the volume for listeners on process
/datum/looping_sound/advanced/ftl_drive/process()
	recalculate_volume(1)
