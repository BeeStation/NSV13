//Mag-cat console
/datum/design/board/fighter_launcher
	name = "Computer Design (Mag-cat control console)"
	desc = "Allows for the construction of a Mag-cat control console."
	id = "fighter_launcher_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/fighter_launcher
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING|DEPARTMENTAL_FLAG_CARGO

//Fighter control console
/datum/design/board/fighter_controller
	name = "Computer Design (Fighter Control Console)"
	desc = "Allows for the construction of a fighter control console."
	id = "fighter_computer_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/fighter_controller
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

//Ordenance computer
/datum/design/board/ord_circuit
	name = "Computer Design (Ordnance Computer)"
	desc = "Allows for the construction of a ordnance monitoring console."
	id = "ordnance_comp_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/ordnance_computer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING|DEPARTMENTAL_FLAG_MUNITIONS

//Broadside Packer Table
/datum/design/board/broadside_packer
	name = "Machine Design (Broadside Shell Packer)"
	desc = "Allows for the construction of a broadside shell packer."
	id = "broadside_packer"
	build_path = /obj/item/circuitboard/machine/broadside_shell_packer
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200)
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//FTL Navigation Console
/datum/design/board/navigation
	name = "Computer Design (FTL Navigation console)"
	desc = "Allows for the construction of a FTL Navigation console."
	id = "navigation_console_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/diamond = 1000)
	build_path = /obj/item/circuitboard/computer/ship/navigation
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

//DRADIS Console
/datum/design/board/dradis_console
	name = "Computer Design (DRADIS console)"
	desc = "Allows for the construction of a DRADIS console."
	id = "dradis_console"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/diamond = 1000)
	build_path = /obj/item/circuitboard/computer/ship/dradis
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/cargo_dradis_console
	name = "Computer Design (Cargo Delivery console)"
	desc = "Allows for the construction of a cargo delivery console."
	id = "cargo_dradis_console"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/diamond = 1000)
	build_path = /obj/item/circuitboard/computer/ship/dradis/cargo
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

//Helm console
/datum/design/board/helm_circuit
	name = "Computer Design (Helm Computer)"
	desc = "Allows for the construction of a helm control console."
	id = "helm_circuit"
	materials = list(/datum/material/glass = 5000, /datum/material/copper = 500, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/helm
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

//TAC console
/datum/design/board/tac_circuit
	name = "Computer Design (Tactical Computer)"
	desc = "Allows for the construction of a tactical control console."
	id = "tactical_comp_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/tactical_computer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

//Astrometrics console
/datum/design/board/astrometrics
	name = "Computer Design (Astrometrics computer)"
	desc = "Allows for the construction of circuit boards used to build a new astrometrics computer."
	id = "astrometrics_console"
	build_path = /obj/item/circuitboard/computer/astrometrics
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//Autoinjector
/datum/design/board/autoinjector
	name = "Machine Design (Autoinjector Printer)"
	desc = "Allows for the construction of circuit boards used to build a new autoinjector printer"
	id = "autoinjector"
	build_path = /obj/item/circuitboard/machine/autoinject_printer
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/refillable_chem_dispenser
	name = "Machine Design (Refillable Chem Dispenser Board)"
	desc = "The circuit board for a refillable chem dispenser."
	id = "refillable_chem_dispenser"
	build_path = /obj/item/circuitboard/machine/refillable_chem_dispenser
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL
	category = list ("Medical Machinery")

//GLORIOUS COFFEEMAKER
/datum/design/board/coffeemaker
	name = "Machine Design (Coffeemaker)"
	desc = "The circuit board for a coffeemaker."
	id = "coffeemaker"
	build_path = /obj/item/circuitboard/machine/coffeemaker
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/navbeacon
	name = "Machine Design (Bot Navigational Beacon)"
	desc = "The circuit board for a beacon that aids bot navigation."
	id = "botnavbeacon"
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/machine/navbeacon
	category = list ("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// Ammo sorter circuit designs
/datum/design/board/ammo_sorter_computer
	name = "Ammo sorter console (circuitboard)"
	desc = "The central control console for ammo sorters.."
	id = "ammo_sorter_computer"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/computer/ammo_sorter
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/ammo_sorter
	name = "Ammo sorter (circuitboard)"
	desc = "A helpful storage unit that allows for mass storage of ammunition, with the ability to retrieve it all from a central console."
	id = "ammo_sorter"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/ammo_sorter
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS
