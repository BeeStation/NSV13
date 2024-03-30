/datum/overmap_objective/cargo/transfer/emergency_supplies
	name = "Deliver emergency supplies"
	desc = "Deliver emergency supplies"
	crate_name = "Surplus EVA suits crate"

/datum/overmap_objective/cargo/transfer/emergency_supplies/New()
	var/datum/freight_type/single/object/oxygen = new /datum/freight_type/single/object( /obj/item/tank/internals/oxygen, 5 )
	oxygen.send_prepackaged_item = TRUE
	oxygen.overmap_objective = src

	var/datum/freight_type/single/object/suit = new /datum/freight_type/single/object( /obj/item/clothing/suit/space/eva, 5 )
	suit.send_prepackaged_item = TRUE
	suit.overmap_objective = src

	var/datum/freight_type/single/object/helm = new /datum/freight_type/single/object( /obj/item/clothing/head/helmet/space/eva, 5 )
	helm.send_prepackaged_item = TRUE
	helm.overmap_objective = src

	var/datum/freight_type/single/object/mask = new /datum/freight_type/single/object( /obj/item/clothing/mask/breath, 5 )
	mask.send_prepackaged_item = TRUE
	mask.overmap_objective = src

	freight_type_group = new( list( oxygen, suit, helm, mask ) )
