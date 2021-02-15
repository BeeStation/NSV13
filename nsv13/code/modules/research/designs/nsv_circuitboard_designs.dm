////CONSOLES////
//Mag-cat console
/datum/design/board/fighter_launcher
	name = "Computer Design (Mag-cat control console)"
	desc = "Allows for the construction of a Mag-cat control console."
	id = "fighter_launcher_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/fighter_launcher
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING|DEPARTMENTAL_FLAG_CARGO

//Generic Munitions console
/obj/item/circuitboard/computer/ship/munitions_computer
	name = "circuit board (munitions control computer)"
	build_path = /obj/machinery/computer/ship/munitions_computer

