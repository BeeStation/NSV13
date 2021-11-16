/datum/overmap_objective/cargo/transfer/emergency_supplies
	name = "Deliver emergency supplies"
	desc = "Deliver emergency supplies"
	crate_name = "Surplus EVA suits crate"

/datum/overmap_objective/cargo/transfer/emergency_supplies/New() 
	var/datum/freight_type/object/oxygen = new /datum/freight_type/object( /obj/item/tank/internals/oxygen, 5 )
	oxygen.send_prepackaged_item = TRUE
	oxygen.overmap_objective = src
	freight_types += oxygen

	var/datum/freight_type/object/suit = new /datum/freight_type/object( /obj/item/clothing/suit/space/eva, 5 )
	suit.send_prepackaged_item = TRUE
	suit.overmap_objective = src
	freight_types += suit

	var/datum/freight_type/object/helm = new /datum/freight_type/object( /obj/item/clothing/head/helmet/space/eva, 5 )
	helm.send_prepackaged_item = TRUE
	helm.overmap_objective = src
	freight_types += helm

	var/datum/freight_type/object/mask = new /datum/freight_type/object( /obj/item/clothing/mask/breath, 5 )
	mask.send_prepackaged_item = TRUE
	mask.overmap_objective = src
	freight_types += mask
