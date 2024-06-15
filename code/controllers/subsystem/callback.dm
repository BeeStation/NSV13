SUBSYSTEM_DEF(callbacks)
	name = "Auxtools Callbacks"
	flags = SS_TICKER | SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_CALLBACKS

/proc/process_atmos_callbacks(remaining)
	return LIBCALL(AUXMOS, "byond:atmos_callback_handle_ffi")(remaining)

/datum/controller/subsystem/callbacks/fire()
	if(process_atmos_callbacks(MC_TICK_REMAINING_MS))
		pause()
