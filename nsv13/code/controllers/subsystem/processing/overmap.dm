//Fires five times every second.

PROCESSING_SUBSYSTEM_DEF(overmap)
	name = "Overmap Processing"
	wait = 2
	stat_tag = "OP"
	priority = 10
	var/next_boarding_time = 0