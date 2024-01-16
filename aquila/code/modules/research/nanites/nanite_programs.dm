///A nanite program containing a behaviour protocol. Only one protocol of each class can be active at once.
/datum/nanite_program/protocol
	name = "Nanite Protocol"
	var/protocol_class = NONE

/datum/nanite_program/protocol/check_conditions()
	. = ..()
	for(var/protocol in nanites.protocols)
		var/datum/nanite_program/protocol/P = protocol
		if(P != src && P.activated && P.protocol_class == protocol_class)
			return FALSE

/datum/nanite_program/protocol/on_add(datum/component/nanites/_nanites)
	..()
	nanites.protocols += src

/datum/nanite_program/protocol/Destroy()
	if(nanites)
		nanites.protocols -= src
	return ..()
