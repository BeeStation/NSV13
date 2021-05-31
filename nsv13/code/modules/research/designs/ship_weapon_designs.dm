//General weapons stuff
/datum/design/board/munitions_computer_circuit
	name = "Computer Design (Munitions Computer)"
	desc = "Allows for the construction of a munitions control console."
	id = "munitions_computer_circuit"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/munitions_computer
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/ship_firing_electronics
	name = "Firing Electronics"
	desc = "Controls the firing mechanism for ship-sized weaponry."
	id = "ship_firing_electronics"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/diamond = 100, /datum/material/titanium = 300, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/ship_weapon/parts/firing_electronics
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//50 Cal.
/datum/design/board/fiftycal
	name = "Machine Design (.50 cal deck turret)"
	desc = "Allows for the construction of a crew served, 50 cal deck turret."
	id = "fiftycal"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 2000, /datum/material/gold = 5000)
	build_path = /obj/item/circuitboard/machine/fiftycal
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/fiftycal/super
	name = "Machine Design (.50 cal deck turret)"
	desc = "Allows for the construction of a crew served, super 50 cal pompom turret."
	id = "fiftycal_super"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 2000, /datum/material/gold = 5000)
	build_path = /obj/item/circuitboard/machine/fiftycal/super
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/fiftycalcomp
	name = "Computer Design (.50 cal deck turret control console)"
	desc = "Allows for the construction of a control console for .50 cal deck guns."
	id = "fiftycalcomp"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 2000, /datum/material/gold = 5000)
	build_path = /obj/item/circuitboard/computer/fiftycal
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Naval artillery
/datum/design/board/naval_artillery
	name = "Machine Design (Deck Gun Frame)"
	desc = "Allows for the construction of a naval artillery gun frame."
	id = "deck_gun"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/titanium = 12000,/datum/material/iron = 15000, /datum/material/glass = 5000, /datum/material/copper = 5000)
	build_path = /obj/structure/ship_weapon/mac_assembly/artillery_frame
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/naval_artillery_triple
	name = "Machine Design (Triple Deck Gun Frame)"
	desc = "Allows for the construction of a triple barreled naval cannon frame."
	id = "deck_gun_dual"
	materials = list(/datum/material/titanium = 30000,/datum/material/iron = 25000, /datum/material/diamond = 15000, /datum/material/copper = 35000)
	build_path = /obj/structure/ship_weapon/mac_assembly/artillery_frame/mega
	category = list("Advanced Munitions")
	build_type = PROTOLATHE | AUTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/naval_artillery_comp
	name = "Machine Design (Deck Gun Computer)"
	desc = "Allows for the construction of a naval artillery control console."
	id = "naval_artillery_comp"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500, /datum/material/diamond=5000)
	build_path = /obj/item/circuitboard/computer/deckgun
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/artillery_loader
	name = "Machine Design (Deck Gun Core)"
	desc = "Allows for the construction of a naval artillery core."
	id = "artillery_loader"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500, /datum/material/diamond=5000)
	build_path = /obj/item/circuitboard/machine/deck_gun
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/powder_loader
	name = "Machine Design (Deck Gun Powder Gate)"
	desc = "Allows for the construction of a naval artillery powder gate."
	id = "powder_loader"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/deck_gun/powder
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/payload_gate
	name = "Machine Design (Deck Gun Payload Gate)"
	desc = "Allows for the construction of a naval artillery payload gate."
	id = "payload_gate"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/deck_gun/payload
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/deck_gun_autorepair
	name = "Machine Design (Deck Gun Autorepair upgrade)"
	desc = "A machine which can upgrade the deck gun to let it self-repair."
	id = "deck_gun_autorepair"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/deck_gun/autorepair
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/deck_gun_autoelevator
	name = "Machine Design (Deck Gun Auto-elevator)"
	desc = "A machine which can upgrade the deck gun to drastically reduce load times."
	id = "deck_gun_autoelevator"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 5000, /datum/material/titanium = 15000, /datum/material/diamond = 5000)
	build_path = /obj/item/circuitboard/machine/deck_gun/autoelevator
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Missile system (factory parts in munitions_designs.dm)
/datum/design/board/vls_tube
	name = "Machine Design (VLS Tube)"
	desc = "Allows for the construction of a VLS launch tube (control computer not included)."
	id = "vls_tube"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/vls
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/ams_console
	name = "Machine Design (AMS Control Console)"
	desc = "Allows for the construction of an AMS control console."
	id = "ams_console"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/computer/ams
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Misc
/datum/design/railgun_rail
	name = "Railgun Rail"
	desc = "A reinforced electromagnetic rail for a railgun."
	id = "railgun_rail"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 1000, /datum/material/plasma = 1000) //Duranium ingredients
	construction_time=100
	build_path = /obj/item/ship_weapon/parts/railgun_rail
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/gauss_dispenser_circuit
	name = "Machine Design (Gauss Dispenser)"
	desc = "Allows you to construct a machine that lets you access the ship's internal ammo stores to retrieve gauss gun ammunition."
	id = "gauss_dispenser_circuit"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/gauss_dispenser
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS
