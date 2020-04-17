/obj/item/ship_weapon/parts/missile/warhead
	name = "missile warhead"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "warhead_highvelocity"
	desc = "A lightweight warhead designed to be fitted to a missile. It's currently inert."
	w_class = WEIGHT_CLASS_HUGE
	var/payload = null

/obj/item/ship_weapon/parts/missile/guidance_system
	name = "missile guidance system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "guidance"
	desc = "A guidance module for a missile which allows them to lock onto a target inside their operational range. The microcomputer inside it is capable of performing thousands of calculations a second."
	w_class = WEIGHT_CLASS_NORMAL
	var/accuracy = null

/obj/item/ship_weapon/parts/missile/propulsion_system
	name = "missile propulsion system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "propulsion"
	desc = "A gimballed thruster with an attachment nozzle, designed to be mounted in missile."
	w_class = WEIGHT_CLASS_BULKY
	var/speed = 1

/obj/item/ship_weapon/parts/missile/iff_card //This should be abuseable via emag
	name = "missile IFF card"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff"
	desc = "An IFF chip which allows a missile to distinguish friend from foe. The electronics contained herein are relatively simple, but they form a crucial part of any good missile."
	w_class = WEIGHT_CLASS_SMALL
	var/calibrated = FALSE

/obj/item/ship_weapon/parts/missile/iff_card/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	user.visible_message("<span class='warning'>[user] shorts out [src]!</span>",
						"<span class='notice'>You short out the IFF protocols on [src].</span>",
						"Bzzzt.")

///// Techweb and Designs /////
/datum/techweb_node/basic_torpedo_components
	id = "basic_missile_components"
	display_name = "Basic Missile Components"
	description = "A how-to guide of fabricating missiles while out in the depths of space."
	prereq_ids = list("explosive_weapons")
	design_ids = list("missile_warhead","missile_guidance_system", "missile_propulsion_system", "missile_iff_card")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/design/missile_warhead
	name = "Missile Warhead"
	desc = "The stock standard warhead design for missiles"
	id = "missile_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/plasma = 2000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/missile_guidance_system
	name = "Missile Guidance System"
	desc = "The stock standard guidance system design for missiles"
	id = "missile_guidance_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 2500, /datum/material/copper = 2500)
	build_path = /obj/item/ship_weapon/parts/missile/guidance_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/missile_propulsion_system
	name = "Missile Propulsion System"
	desc = "The stock standard propulsion system design for missiles"
	id = "missile_propulsion_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/plasma = 500)
	build_path = /obj/item/ship_weapon/parts/missile/propulsion_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/iff_card
	name = "Missile IFF Card"
	desc = "The stock standard IFF card design for missiles"
	id = "missile_iff_card"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 3000, /datum/material/copper = 1000)
	build_path = /obj/item/ship_weapon/parts/missile/iff_card
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO