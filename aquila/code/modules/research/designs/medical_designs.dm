
/datum/design/implant_security_down
	name = "Security Officer Down Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_security_down"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/implantcase/security_down
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY  // available only in the seclathe to stop medbay jokers from implanting non-secs
