SUBSYSTEM_DEF(nightshift)
	name = "Night Shift"
	wait = 600
	flags = SS_NO_TICK_CHECK

	var/nightshift_active = FALSE
	var/nightshift_start_time = 702000		//7:30 PM, station time
	var/nightshift_end_time = 270000		//7:30 AM, station time
	var/nightshift_first_check = 30 SECONDS

	var/high_security_mode = FALSE

/datum/controller/subsystem/nightshift/Initialize()
	if(!CONFIG_GET(flag/enable_night_shifts))
		can_fire = FALSE
	return ..()

/datum/controller/subsystem/nightshift/fire(resumed = FALSE)
	if(world.time - SSticker.round_start_time < nightshift_first_check)
		return
	check_nightshift()

/datum/controller/subsystem/nightshift/proc/announce(message)
	priority_announce(message, sound='sound/misc/notice2.ogg', sender_override="Automated Lighting System Announcement")

/datum/controller/subsystem/nightshift/proc/check_nightshift()
	var/emergency = GLOB.security_level >= SEC_LEVEL_RED
	var/announcing = TRUE
	var/time = station_time()
	var/night_time = (time < nightshift_end_time) || (time > nightshift_start_time)
	if(!SSmapping.config.allow_night_lighting)
		if(night_time)
			night_time = FALSE
			update_nightshift(night_time, FALSE)
		return
	if(high_security_mode != emergency)
		high_security_mode = emergency
		if(night_time)
			announcing = FALSE
			if(!emergency)
				announce("Przywracanie nocnej konfiguracji świateł do normalnego operowania.") // AQ EDIT
			else
				announce("Wyłączanie nocnych świateł: Nagły wypadek na stacji.") // AQ EDIT
	if(emergency)
		night_time = FALSE
	if(nightshift_active != night_time)
		update_nightshift(night_time, announcing)

/datum/controller/subsystem/nightshift/proc/update_nightshift(active, announce = TRUE)
	nightshift_active = active
	if(announce)
		if (active)
			announce("Dobry wieczór, załogo. By zmniejszyć zużycie mocy i stymulować cykle dobowe niektórych gatunków, wszystkie światła na pokładzie stacji zostały przyciemnione na noc.")
		else
			announce("Dzień dobry, załogo. Jako że mamy dzień, wszystkie światła na pokładzie stacji zostały przywrócone do poprzedniej jasności.")
	for(var/A in GLOB.apcs_list)
		var/obj/machinery/power/apc/APC = A
		if (APC.area && (APC.area.type in GLOB.the_station_areas))
			APC.set_nightshift(active)
			CHECK_TICK
