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

/datum/overmap_objective/cargo/donation/blood/New()
	cargo_item_types += new /datum/cargo_item_type/reagent/blood( pick( possible_blood_types ) )
	
