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
		"L",
		// We don't have enough ethereal or oozling players to donate blood if the ship does not spawn with any 
		// "LE",
		// "OZ",
	)
	crate_name = "Blood Packs crate"

/datum/overmap_objective/cargo/donation/blood/New()
	var/datum/freight_type/reagent/blood/C = new /datum/freight_type/reagent/blood( pick( possible_blood_types ) )
	freight_types += C
	
