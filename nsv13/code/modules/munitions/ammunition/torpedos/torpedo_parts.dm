/obj/item/ship_weapon/parts/missile/warhead/torpedo
	name = "\improper NTP-2 standard torpedo payload"
	icon_state = "warhead"
	desc = "An extremely heavy warhead designed to be fitted to a torpedo. This one contains a standard explosive charge."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo

/obj/item/ship_weapon/parts/missile/warhead/decoy
	name = "\improper NTP-0x 'DCY' electronic countermeasure torpedo payload"
	icon_state = "warhead_decoy"
	desc = "A simple electronic countermeasure wrapped in a metal casing. While these form inert torpedoes, they can be used to distract enemy defenses to divert their flak away from other targets."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/decoy

/obj/item/ship_weapon/parts/missile/warhead/bunker_buster
	name = "\improper NTP-4 'BNKR' torpedo payload"
	icon_state = "warhead_shredder"
	desc = "An extremely heavy warhead designed to be fitted to a torpedo. This one has an inbuilt plasma charge to amplify its damage."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/hull_shredder

/obj/item/ship_weapon/parts/missile/warhead/probe
	name = "\improper NTX 'Voyager' astrological probe payload"
	desc = "An advanced sensor suite specially kitted to collect information about astrological phenomena."
	icon_state = "warhead_probe"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/probe

/obj/item/ship_weapon/parts/missile/warhead/freight
	name = "\improper NTP-F 530mm freight torpedo payload"
	//icon_state = "warhead_freight"
	desc = "A hollowed out nosecone that allows torpedoes to carry freight instead of an actual payload."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/freight

/obj/item/ship_weapon/parts/missile/warhead/nuclear
	name = "nuclear torpedo warhead"
	icon_state = "warhead_nuclear"
	desc = "An advanced warhead which carries a nuclear fission explosive. Torpedoes equipped with these can quickly annihilate targets with extreme prejudice, however they are extremely costly to produce."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/nuke
