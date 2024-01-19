/datum/wires/jukebox
	holder_type = /obj/machinery/jukebox
	proper_name = "Jukebox"

/datum/wires/jukebox/New(atom/holder)
	wires = list(
		WIRE_POWER,
		WIRE_SHOCK,
		WIRE_ZAP1, WIRE_ZAP2,
		WIRE_SLOW, WIRE_FAST,
		WIRE_IDSCAN,
		WIRE_PLAY,
		WIRE_LISTING,
		WIRE_RANCH,
	)
	add_duds(2)
	..()

/datum/wires/jukebox/interactable(mob/user)
	var/obj/machinery/jukebox/J = holder
	if(J.panel_open)
		return TRUE

/datum/wires/jukebox/get_status()
	var/obj/machinery/jukebox/J = holder
	var/unpowered = (J.machine_stat & (BROKEN|NOPOWER)) || !J.mains
	var/voltage = 0
	if(!(J.machine_stat & (BROKEN|NOPOWER)))
		voltage = round(12.34+(J.get_speed_factor()*2.67), 0.01)
	var/list/status = list()
	status += "Napięcie serwomechanizmu: [voltage]V."
	status += "Zielona dioda [J.selection_blocked || unpowered ? "nie " : ""]świeci się."
	status += "Pomarańczowa dioda [length(J.list_source) != length(SSjukeboxes.song_lib_ranch) || unpowered ? "nie " : ""]świeci się."
	return status

/datum/wires/jukebox/on_pulse(wire)
	var/obj/machinery/jukebox/J = holder
	if ((J.machine_stat & NOPOWER) || !J.mains)
		return
	switch(wire)
		if(WIRE_POWER)
			if(isliving(usr))
				J.shock(usr, 50)
		if(WIRE_SHOCK)
			J.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME
		if(WIRE_SLOW)
			J.stop = 0
			if(J.speed_potentiometer > 0.65)
				J.speed_potentiometer -= 0.01
		if(WIRE_FAST)
			J.stop = 0
			if(J.speed_potentiometer < 1.50)
				J.speed_potentiometer += 0.01
		if(WIRE_LISTING)
			J.stop = 0
			J.pick_random()
		if(WIRE_RANCH)
			J.stop = 0
			J.pick_random(SSjukeboxes.song_lib_ranch)
		if(WIRE_PLAY)
			J.attempt_playback()

/datum/wires/jukebox/on_cut(wire, mend)
	var/obj/machinery/jukebox/J = holder
	switch(wire)
		if(WIRE_POWER)
			if(isliving(usr))
				J.shock(usr, 75)
			if(mend)
				J.mains = TRUE
				J.power_change()
			else
				J.mains = FALSE
				J.power_change()
		if(WIRE_IDSCAN)
			if(mend)
				J.verify = TRUE
			else
				J.verify = FALSE
		if(WIRE_ZAP1, WIRE_ZAP2)
			if(isliving(usr))
				J.shock(usr, 50)
		if(WIRE_SHOCK)
			if(mend)
				J.seconds_electrified = MACHINE_NOT_ELECTRIFIED
			else
				J.seconds_electrified = MACHINE_ELECTRIFIED_PERMANENT
		if(WIRE_SLOW)
			if(mend)
				J.speed_servo_regulator_cut = FALSE
				J.stop = 0
			else
				J.speed_servo_regulator_cut = TRUE
				J.stop = 0
		if(WIRE_FAST)
			if(mend)
				J.speed_servo_resistor_cut = FALSE
				J.stop = 0
			else
				J.speed_servo_resistor_cut = TRUE
				J.stop = 0
		if(WIRE_LISTING)
			if(mend)
				J.selection_blocked = FALSE
			else
				J.selection_blocked = TRUE
		if(WIRE_RANCH)
			if(mend)
				J.stop = 0
				J.list_source = SSjukeboxes.song_lib
			else
				J.stop = 0
				J.list_source = SSjukeboxes.song_lib_ranch
		if(WIRE_PLAY)
			if(mend)
				J.stop_blocked = FALSE
			else
				J.stop_blocked = TRUE 
