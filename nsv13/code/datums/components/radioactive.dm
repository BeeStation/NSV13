/datum/component/radioactive/proc/rad_beam(datum/source)
	radiation_pulse(parent, strength * 10, RAD_DISTANCE_COEFFICIENT / 5, FALSE, can_contaminate)