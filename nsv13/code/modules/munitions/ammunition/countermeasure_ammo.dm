/obj/item/ship_weapon/ammunition/countermeasure_charge //A single use of the countermeasure system
	name = "Countermeasure Tri-Charge" //temp
	desc = "A tri-charge of countermeasure chaff for a fighter" //temp
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff" //temp
	w_class = 4

/obj/item/ship_weapon/ammunition/countermeasure_charge/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)

/datum/techweb_node/countermeasure_charge
	id = "countermeasure_charge"
	display_name = "Countermeasure Charge Fabrication"
	description = "Instructional information on how to correctly wrap countermeasures."
	prereq_ids = list("explosive_weapons")
	design_ids = list("countermeasure_charge")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/design/countermeasure_charge
	name = "Countermeasure Tri-Charge"
	desc = "A tri-charge of countermeasure chaff for a fighter"
	id = "countermeasure_charge"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/titanium = 500)
	build_path = /obj/item/ship_weapon/ammunition/countermeasure_charge
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO
