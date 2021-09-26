/datum/overmap_objective/cargo/donation/blood
	name = "Donate blood types"
	desc = "Donate 1 or more blood types"
	var/list/possible_blood_types = list(
		"O-",
		"O+",
		"B-",
		"B+",
		"A-",
		"A+",
		"AB-",
		"AB+",
		"L",
		// We don't have enough ethereal or oozling players to donate blood if the ship does not spawn with any 
		// "LE",
		// "OZ",
	)

/datum/overmap_objective/cargo/donation/blood/instance()
	cargo_item_type = new /datum/cargo_item_type/reagent/blood()
	var/datum/cargo_item_type/reagent/blood/C = cargo_item_type
	C.blood_type = pick( possible_blood_types )
	
