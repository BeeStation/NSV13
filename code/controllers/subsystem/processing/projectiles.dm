PROCESSING_SUBSYSTEM_DEF(projectiles)
	name = "Projectiles"
	wait = 1
	stat_tag = "PP"
	flags = SS_NO_INIT|SS_TICKER
	priority = FIRE_PRIORITY_PROJECTILES
	var/global_max_tick_moves = 10
	var/global_pixel_speed = 2
	var/global_iterations_per_move = 16

/datum/controller/subsystem/processing/projectiles/proc/set_pixel_speed(new_speed)
	global_pixel_speed = new_speed
	for(var/obj/item/projectile/P in processing) // NSV13 -- Optimizes projectile processing.	Note to future coders from elon, for some dumb reason there's non-projectiles in this list so don't typeless it
		P.set_pixel_speed(new_speed)

/datum/controller/subsystem/processing/projectiles/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, global_pixel_speed))
			set_pixel_speed(var_value)
			return TRUE
		else
			return ..()
