/datum/design/rld
	name = "Rapid Light Dispenser"
	desc = "Adds the Rapid Light Dispenser capable of constructing light fixtures and synthesising glowsticks."
	id = "rld"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/uranium = 200, /datum/material/glass = 1000)
	build_path = /obj/item/construction/rld
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SERVICE

/datum/techweb_node/rld
	id = "rld"
	display_name = "Advanced Lamp Construction"
	description = "No more wasting time making lamps!"
	prereq_ids = list("janitor")
	design_ids = list("rld")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 2000
