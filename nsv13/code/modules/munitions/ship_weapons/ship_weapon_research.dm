/datum/techweb_node/macro_ballistics
	id = "macro_ballistics"
	display_name = "Macro-Ballistics"
	description = "Asking important questions, like what if we made even bigger guns?"
	prereq_ids = list("ballistic_weapons", "basic_torpedo_components")
	design_ids = list("vls_tube", "naval_shell", "naval_shell_ap", "ams_console","powder_bag","plasma_accelerant", "fiftycal", "fiftycal_super", "fiftycalcomp","deck_gun","naval_artillery_comp","artillery_loader","powder_loader","payload_gate","deck_gun_autorepair", "deck_gun_autoelevator", "munitions_computer_circuit", "ship_firing_electronics")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 20000

/datum/design/naval_shell
	name = "Naval Artillery Round"
	desc = "A high caliber round that can be fired out of a deck gun. (WARNING: Requires a trolley to move!)"
	id = "naval_shell"
	materials = list(/datum/material/iron = 10000, /datum/material/titanium=5000, /datum/material/copper=500)
	build_path = /obj/item/ship_weapon/ammunition/naval_artillery
	category = list("Advanced Munitions")
	build_type = PROTOLATHE | AUTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/naval_shell_ap
	name = "Naval Artillery Round (Armour Piercing)"
	desc = "A diamond tipped AP round that can be fired out of a deck gun. (WARNING: Requires a trolley to move!)"
	id = "naval_shell_ap"
	materials = list(/datum/material/iron = 10000, /datum/material/titanium=5000, /datum/material/diamond=2000)
	build_path = /obj/item/ship_weapon/ammunition/naval_artillery/ap
	category = list("Advanced Munitions")
	build_type = PROTOLATHE | AUTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/powder_bag
	name = "Powder Bag"
	desc = "A bag of explosives for use with deck guns."
	id = "powder_bag"
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/powder_bag
	category = list("Advanced Munitions")
	build_type = PROTOLATHE | AUTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plasma_accelerant
	name = "Plasma-Based Kinetic Accelerant"
	desc = "A powerful powder charge for use in deck guns, which can propel a round to insane speeds."
	id = "plasma_accelerant"
	materials = list(/datum/material/iron = 1000, /datum/material/plasma = 1500)
	build_path = /obj/item/powder_bag/plasma
	category = list("Advanced Munitions")
	build_type = PROTOLATHE | AUTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/naval_artillery
	name = "Machine Design (Deck Gun Frame)"
	desc = "Allows for the construction of a naval artillery gun frame."
	id = "deck_gun"
	materials = list(/datum/material/titanium = 12000,/datum/material/iron = 15000, /datum/material/glass = 5000, /datum/material/copper = 5000)
	build_path = /obj/structure/ship_weapon/mac_assembly/artillery_frame
	category = list("Advanced Munitions")
	build_type = PROTOLATHE | AUTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/naval_artillery_comp
	name = "Machine Design (Deck Gun Computer)"
	desc = "Allows for the construction of a naval artillery control console."
	id = "naval_artillery_comp"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500, /datum/material/diamond=5000)
	build_path = /obj/item/circuitboard/computer/deckgun
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/artillery_loader
	name = "Machine Design (Deck Gun Core)"
	desc = "Allows for the construction of a naval artillery core."
	id = "artillery_loader"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500, /datum/material/diamond=5000)
	build_path = /obj/item/circuitboard/machine/deck_gun
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/powder_loader
	name = "Machine Design (Deck Gun Powder Gate)"
	desc = "Allows for the construction of a naval artillery powder gate."
	id = "powder_loader"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/deck_gun/powder
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE


/datum/design/board/vls_tube
	name = "Machine Design (VLS Tube)"
	desc = "Allows for the construction of a VLS launch tube (control computer not included)."
	id = "vls_tube"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/vls
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/ams_console
	name = "Machine Design (AMS Control Console)"
	desc = "Allows for the construction of an AMS control console."
	id = "ams_console"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/computer/ams
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/payload_gate
	name = "Machine Design (Deck Gun Payload Gate)"
	desc = "Allows for the construction of a naval artillery payload gate."
	id = "payload_gate"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/deck_gun/payload
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/deck_gun_autorepair
	name = "Machine Design (Deck Gun Autorepair upgrade)"
	desc = "A machine which can upgrade the deck gun to let it self-repair."
	id = "deck_gun_autorepair"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/deck_gun/autorepair
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/deck_gun_autoelevator
	name = "Machine Design (Deck Gun Auto-elevator)"
	desc = "A machine which can upgrade the deck gun to drastically reduce load times."
	id = "deck_gun_autoelevator"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 5000, /datum/material/titanium = 15000, /datum/material/diamond = 5000)
	build_path = /obj/item/circuitboard/machine/deck_gun/autoelevator
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

/datum/design/board/gauss_dispenser_circuit
	name = "Machine Design (Gauss Dispenser)"
	desc = "Allows you to construct a machine that lets you access the ship's internal ammo stores to retrieve gauss gun ammunition."
	id = "gauss_dispenser_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/gauss_dispenser
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE
