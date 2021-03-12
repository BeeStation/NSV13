/area/shuttle/turbolift //Only use subtypes of this area
	requires_power = FALSE //no APCS in the lifts please
	ambient_effects = list('sound/effects/turbolift/elevatormusic.ogg')

/area/shuttle/turbolift/shaft //What the shuttle leaves behind
	name = "turbolift shaft"
	requires_power = TRUE
	ambient_effects = MAINTENANCE

/area/shuttle/turbolift/primary
	name = "primary turbolift"

/area/shuttle/turbolift/secondary
	name = "secondary turbolift"

/area/shuttle/turbolift/tertiary
	name = "tertiary turbolift"

/area/shuttle/turbolift/quaternary
	name = "quaternary turbolift"

/area/shuttle/turbolift/quinary
	name = "quinary turbolift"

/area/shuttle/turbolift/senary
	name = "senary turbolift"

/area/shuttle/turbolift/septenary
	name = "septenary turbolift"

/area/shuttle/turbolift/octonary
	name = "octonary turbolift"

/area/shuttle/turbolift/nonary
	name = "nonary turbolift"

/area/shuttle/turbolift/denary //If you need more than 10 elevators what are you doing?
	name = "denary turbolift"
