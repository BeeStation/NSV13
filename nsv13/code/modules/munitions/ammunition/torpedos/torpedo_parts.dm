/obj/item/ship_weapon/parts/missile/warhead/torpedo
	name = "NTP-2 guided torpedo payload"
	desc = "A payload that makes a standard torpedo payload"
	icon_state = "warhead"
	desc = "An extremely heavy warhead designed to be fitted to a torpedo. This one has an inbuilt plasma charge to amplify its damage."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo
/obj/item/ship_weapon/parts/missile/warhead/bunker_buster
	name = "NTP-4 'BNKR' guided munition payload"
	desc = "a bunker buster torpedo warhead"
	icon_state = "warhead_shredder"
	desc = "An extremely heavy warhead designed to be fitted to a torpedo. This one has an inbuilt plasma charge to amplify its damage."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/hull_shredder

/obj/item/ship_weapon/parts/missile/warhead/probe
	name = "NTX 'Voyager' astrological probe payload"
	desc = "An advanced sensor suite specially kitted to collect information about astrological phenomena."
	icon_state = "warhead_probe"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/probe
/obj/item/ship_weapon/parts/missile/warhead/freight
	name = "NTP-F 530mm freight torpedo"
	desc = "A hollowed out nosecone that allows torpedoes to carry freight instead of an actual payload."
	icon_state = "warhead_freight"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/freight

/obj/item/ship_weapon/parts/missile/warhead/nuclear
	name = "nuclear torpedo warhead"
	desc = "a nuclear torpedo warhead"
	icon_state = "warhead_nuclear"
	desc = "An advanced warhead which carries a nuclear fission explosive. Torpedoes equipped with these can quickly annihilate targets with extreme prejudice, however they are extremely costly to produce."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/nuke


///// Techweb and Designs /////
/datum/techweb_node/basic_torpedo_components
	id = "basic_torpedo_components"
	display_name = "Guided Munitions I"
	description = "Parts to construct explosive, guided ordnance."
	prereq_ids = list("explosive_weapons")
	design_ids = list("warhead", "bb_warhead","missile_warhead", "decoy_warhead", "nuke_warhead", "probe_warhead", "freight_warhead", "guidance_system", "propulsion_system", "iff_card")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/design/warhead
	name = "Torpedo Warhead"
	desc = "The stock standard warhead design for torpedos"
	id = "warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/bb_warhead
	name = "Bunker Buster Torpedo Warhead"
	desc = "A bunker buster warhead design for torpedos"
	id = "bb_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 20000, /datum/material/gold = 2500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/bunker_buster
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/decoy_warhead
	name = "Decoy Torpedo Warhead"
	desc = "A decoy warhead design for torpedos"
	id = "decoy_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/copper = 2500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/decoy
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/missile_warhead
	name = "Standard Missile Warhead"
	desc = "A decoy warhead design for torpedos"
	id = "missile_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/copper = 2500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/decoy
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/freight_warhead
	name = "Freight Torpedo Warhead"
	desc = "A hollowed out nosecone that allows torpedoes to carry freight."
	id = "freight_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/copper = 2500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/freight
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/nuclear_warhead
	name = "Nuclear Torpedo Warhead"
	desc = "A nuclear warhead design for torpedos"
	id = "nuke_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 5000, /datum/material/copper = 5000, /datum/material/plasma = 20000, /datum/material/gold = 5000, /datum/material/uranium = 10000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/nuclear
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/probe_warhead
	name = "Astrometrics probe warhead"
	desc = "A sensor suite that can turn a torpedo casing into an advanced probe for use in astrometrics research."
	id = "probe_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 5000, /datum/material/titanium=10000, /datum/material/gold=1000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/probe
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/guidance_system
	name = "Torpedo Guidance System"
	desc = "The stock standard guidance system design for torpedos"
	id = "guidance_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 2500, /datum/material/gold = 3000, /datum/material/copper = 2500)
	build_path = /obj/item/ship_weapon/parts/missile/guidance_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/propulsion_system
	name = "Torpedo Propulsion System"
	desc = "The stock standard propulsion system design for torpedos"
	id = "propulsion_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000, /datum/material/titanium = 2500, /datum/material/plasma = 2500)
	build_path = /obj/item/ship_weapon/parts/missile/propulsion_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/iff_card
	name = "Torpedo IFF Card"
	desc = "The stock standard IFF card design for torpedos"
	id = "iff_card"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 20000, /datum/material/copper = 5000, /datum/material/gold = 5000)
	build_path = /obj/item/ship_weapon/parts/missile/iff_card
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO
