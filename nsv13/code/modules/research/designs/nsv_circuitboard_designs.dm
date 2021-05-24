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

//FTL Navigation Console
/datum/design/board/navigation
	name = "Computer Design (FTL Navigation console)"
	desc = "Allows for the construction of a FTL Navigation console."
	id = "navigation_console_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/diamond = 1000)
	build_path = /obj/item/circuitboard/computer/ship/navigation
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
