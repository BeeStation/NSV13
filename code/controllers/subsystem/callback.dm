SUBSYSTEM_DEF(callbacks)
	name = "Auxtools Callbacks"
	flags = SS_TICKER | SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_CALLBACKS

/datum/controller/subsystem/callbacks/fire()
	if(SSair.thread_running())
		pause()
		return

	if(process_atmos_callbacks(MC_TICK_REMAINING_MS))
		pause()
