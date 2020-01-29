/datum/techweb_node/macro_ballistics
	id = "macro_ballistics"
	display_name = "Macro-Ballistics"
	description = "Asking important questions, like what if we made even bigger guns?"
	prereq_ids = list("ballistic_weapons", "basic_torpedo_components")
	design_ids = list("pdc_mount_circuit", "munitions_computer_circuit", "ship_firing_electronics")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 20000

/datum/techweb_node/magnetic_acceleration
	id = "magnetic_acceleration"
	display_name = "Magnetic Acceleration"
	description = "Using opposing charges to throw things really, really fast."
	prereq_ids = list("emp_super", "macro_ballistics")
	design_ids = list("railgun_rail")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	export_price = 8000

/datum/design/board/pdc_mount_circuit
	name = "Machine Design (PDC Mount)"
	desc = "Allows for the construction of a PDC mount."
	id = "pdc_mount_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/pdc_mount
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/munitions_computer_circuit
	name = "Computer Design (Munitions Computer)"
	desc = "Allows for the construction of a munitions control console."
	id = "munitions_computer_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/munitions_computer
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/ship_firing_electronics
	name = "Firing Electronics"
	desc = "Controls the firing mechanism for ship-sized weaponry."
	id = "ship_firing_electronics"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/diamond = 100, /datum/material/titanium = 300, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/ship_weapon/parts/firing_electronics
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/railgun_rail
	name = "Railgun Rail"
	desc = "A reinforced electromagnetic rail for a railgun."
	id = "railgun_rail"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 1000, /datum/material/plasma = 1000) //Duranium ingredients
	construction_time=100
	build_path = /obj/item/ship_weapon/parts/railgun_rail
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE