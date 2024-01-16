/datum/nanite_program/movement
	name = "Forced Locomotion"
	desc = "The nanites force the host to walk in a pre-programmed direction when triggered."
	can_trigger = TRUE
	unique = FALSE
	trigger_cost = 5
	trigger_cooldown = 10
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/movement/register_extra_settings()
	. = ..()
	extra_settings[NES_DIRECTION] = new /datum/nanite_extra_setting/type("NORTH", list("NORTH","SOUTH","EAST","WEST")) // same nazwe kierunków to stale oznaczające liczby, więc gdybyśmy poszli na łatwiznę, to menu programowania pokazywałoby cyfry

/datum/nanite_program/movement/on_trigger(comm_message)
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]
	var/D
	switch(direction.get_value())
		if("NORTH") D=NORTH
		if("SOUTH") D=SOUTH
		if("EAST") D=EAST
		if("WEST") D=WEST
	if(step(host_mob, D))
		to_chat(host_mob, "<span class='warning'>You feel compelled to walk...</span>")
