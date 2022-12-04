/datum/design/pocket_tvcamera
	name = "Pocket TV Camera"
	id = "pocket_tvcamera"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 50, /datum/material/gold=100, /datum/material/plastic = 800, /datum/material/bluespace = 50)
	build_path = /obj/item/device/pocket_tvcamera
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/pocket_tv
	name = "Pocket TV monitor"
	id = "pocket_tv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 50)
	build_path = /obj/item/pocket_tv
	category = list("Electronics")

/obj/item/circuitboard/computer/wooden_tv
	name = "TV BOX"
	build_path = /obj/machinery/computer/security/wooden_tv/tv

/datum/design/board/wooden_tv
	name = "Computer Design (TV BOX)"
	desc = "Allows for the construction of circuit boards used to build a TV BOX."
	id = "tvbox"
	build_path = /obj/item/circuitboard/computer/wooden_tv
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
