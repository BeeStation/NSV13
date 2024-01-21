/datum/design/board/bluespace_miner
	name = "Machine Design (Bluespace Miner)"
	desc = "The circuit board for a Bluespace Miner."
	id = "bluespace_miner"
	build_path = /obj/item/circuitboard/machine/bluespace_miner
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO
/datum/design/board/clonepod_experimental
	name = "Machine Design (Experimental Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build an Experimental Cloning Pod."
	id = "clonepod_experimental"
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	build_path = /obj/item/circuitboard/machine/clonepod/experimental
	category = list("Medical Machinery")

/datum/design/board/clonecontrol_prototype
	name = "Computer Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Prototype Cloning Machine console."
	id = "clonecontrol_prototype"
	build_path = /obj/item/circuitboard/computer/cloning/prototype
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	category = list("Medical Machinery")
