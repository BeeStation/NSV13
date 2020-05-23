//Fires five times every second.

PROCESSING_SUBSYSTEM_DEF(overmap)
	name = "Overmap Processing"
	wait = 1
	stat_tag = "OP"
	priority = FIRE_PRIORITY_OVERMAP
	var/next_boarding_time = 0
