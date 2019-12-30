/datum/techweb_node/ship_laser_cannon
	id = "ship_laser_cannon"
	display_name = "Ship Laser Weaponry"
	description = "A powerful experimental laser for ship-to-ship combat."
	prereq_ids = list("beam_weapons", "basic_torpedo_components", "comptech", "adv_power")
	design_ids = list("laser_cannon_circuit", "laser_cannon_cell", "laser_cannon_computer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	export_price = 8000

/datum/design/board/laser_cannon
	name = "Machine Design (Laser Cannon)"
	desc = "Allows for the construction of a ship-to-ship laser cannon."
	id = "laser_cannon_circuit"
	build_path = /obj/item/circuitboard/machine/laser_cannon
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/laser_cannon_computer
	name = "Computer Design (Laser Cannon)"
	desc = "Allows for the construction of a ship-to-ship laser cannon."
	id = "laser_cannon_circuit"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/circuitboard/machine/laser_cannon
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/laser_cannon_cell
	name = "Power Cell (Laser Cannon)"
	desc = "Allows for the construction of a ship-to-ship laser cannon."
	id = "laser_cannon_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 800, /datum/material/gold = 120, /datum/material/glass = 160, \
					 /datum/material/diamond = 160, /datum/material/titanium = 300, /datum/material/bluespace = 100, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/laser_cannon
	category = list("Power Designs","Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE