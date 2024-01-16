/datum/nanite_program/sensor/impact
	name = "Impact Sensor"
	desc = "Sends a signal when the nanites detect fluctuations in host's health."

/datum/nanite_program/sensor/impact/register_extra_settings()
	. = ..()
	extra_settings[NES_DAMAGE_TYPE] = new /datum/nanite_extra_setting/type(BRUTE, list(BRUTE, BURN, TOX, OXY, CLONE))

/datum/nanite_program/sensor/impact/on_mob_add()
	. = ..()
	RegisterSignal(host_mob, COMSIG_MOB_APPLY_DAMGE, .proc/host_damaged)

/datum/nanite_program/sensor/impact/on_mob_remove()
	. = ..()
	UnregisterSignal(host_mob, COMSIG_MOB_APPLY_DAMGE, .proc/host_damaged)

/datum/nanite_program/sensor/impact/proc/host_damaged(datum/source, damage, damagetype, def_zone)
	var/datum/nanite_extra_setting/type = extra_settings[NES_DAMAGE_TYPE]
	if(damagetype == type.get_value())
		send_code()
