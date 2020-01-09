/obj/item/ship_weapon/parts/torpedo/warhead
	name = "NTP-2 standard torpedo warhead"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "warhead"
	desc = "A heavy warhead designed to be fitted to a torpedo. It's currently inert."
	w_class = WEIGHT_CLASS_HUGE
	var/payload = null

/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster
	name = "NTP-4 'BNKR' torpedo warhead"
	desc = "a bunker buster torpedo warhead"
	icon_state = "warhead_shredder"
	desc = "An extremely heavy warhead designed to be fitted to a torpedo. This one has an inbuilt plasma charge to amplify its damage."

/obj/item/ship_weapon/parts/torpedo/warhead/lightweight
	name = "NTP-1 'SPD' lightweight torpedo warhead"
	desc = "a lightweight torpedo warhead"
	icon_state = "warhead_highvelocity"
	desc = "A stripped down warhead designed to be fitted to a torpedo. Due to its reduced weight, torpedoes with these equipped will travel more quickly."

/obj/item/ship_weapon/parts/torpedo/warhead/decoy
	name = "NTP-0x 'DCY' electronic countermeasure torpedo payload"
	desc = "a decoy torpedo warhead"
	icon_state = "warhead_decoy"
	desc = "A simple electronic countermeasure wrapped in a metal casing. While these form inert torpedoes, they can be used to distract enemy PDC emplacements to divert their flak away from other targets."

/obj/item/ship_weapon/parts/torpedo/warhead/nuclear
	name = "nuclear torpedo warhead"
	desc = "a nuclear torpedo warhead"
	icon_state = "warhead_nuclear"
	desc = "An advanced warhead which carries a nuclear fission explosive. Torpedoes equipped with these can quickly annihilate targets with extreme prejudice, however they are extremely costly to produce."

/obj/item/ship_weapon/parts/torpedo/guidance_system
	name = "torpedo guidance system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "guidance"
	desc = "A guidance module for a torpedo which allows them to lock onto a target inside their operational range. The microcomputer inside it is capable of performing thousands of calculations a second."
	w_class = WEIGHT_CLASS_NORMAL
	var/accuracy = null

/obj/item/ship_weapon/parts/torpedo/propulsion_system
	name = "torpedo propulsion system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "propulsion"
	desc = "A gimballed thruster with an attachment nozzle, designed to be mounted in torpedoes."
	w_class = WEIGHT_CLASS_BULKY
	var/speed = 1

/obj/item/ship_weapon/parts/torpedo/iff_card //This should be abuseable via emag
	name = "torpedo IFF card"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff"
	desc = "An IFF chip which allows a torpedo to distinguish friend from foe. The electronics contained herein are relatively simple, but they form a crucial part of any good torpedo."
	w_class = WEIGHT_CLASS_SMALL
	var/calibrated = FALSE

/obj/item/ship_weapon/parts/torpedo/iff_card/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	user.visible_message("<span class='warning'>[user] shorts out [src]!</span>",
						"<span class='notice'>You short out the IFF protocols on [src].</span>",
						"Bzzzt.")

///// Techweb and Designs /////
/datum/techweb_node/basic_torpedo_components
	id = "basic_torpedo_components"
	display_name = "Basic Torpedo Components"
	description = "A how-to guide of fabricating torpedos while out in the depths of space."
	prereq_ids = list("explosive_weapons")
	design_ids = list("warhead", "bb_warhead", "lw_warhead", "decoy_warhead", "nuke_warhead", "guidance_system", "propulsion_system", "iff_card")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/design/warhead
	name = "Torpedo Warhead"
	desc = "The stock standard warhead design for torpedos"
	id = "warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 5000)
	build_path = /obj/item/ship_weapon/parts/torpedo/warhead
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/bb_warhead
	name = "Bunker Buster Torpedo Warhead"
	desc = "A bunker buster warhead design for torpedos"
	id = "bb_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/plasma = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/lw_warhead
	name = "Lightweight Torpedo Warhead"
	desc = "A lightweight warhead design for torpedos"
	id = "lw_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500)
	build_path = /obj/item/ship_weapon/parts/torpedo/warhead/lightweight
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/decoy_warhead
	name = "Decoy Torpedo Warhead"
	desc = "A decoy warhead design for torpedos"
	id = "decoy_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/ship_weapon/parts/torpedo/warhead/decoy
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/nuclear_warhead
	name = "Nuclear Torpedo Warhead"
	desc = "A nuclear warhead design for torpedos"
	id = "nuke_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 10000, /datum/material/uranium = 5000)
	build_path = /obj/item/ship_weapon/parts/torpedo/warhead/nuclear
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/guidance_system
	name = "Torpedo Guidance System"
	desc = "The stock standard guidance system design for torpedos"
	id = "guidance_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000)
	build_path = /obj/item/ship_weapon/parts/torpedo/guidance_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/propulsion_system
	name = "Torpedo Propulsion System"
	desc = "The stock standard propulsion system design for torpedos"
	id = "propulsion_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000)
	build_path = /obj/item/ship_weapon/parts/torpedo/propulsion_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/iff_card
	name = "Torpedo IFF Card"
	desc = "The stock standard IFF card design for torpedos"
	id = "iff_card"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 20000, /datum/material/iron = 5000)
	build_path = /obj/item/ship_weapon/parts/torpedo/iff_card
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO