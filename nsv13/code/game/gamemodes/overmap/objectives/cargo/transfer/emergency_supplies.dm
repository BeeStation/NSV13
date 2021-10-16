/datum/overmap_objective/cargo/transfer/emergency_supplies
	name = "Deliver emergency supplies"
	desc = "Deliver emergency supplies"

/datum/overmap_objective/cargo/transfer/emergency_supplies/New() 
	var/datum/cargo_item_type/object/oxygen = new /datum/cargo_item_type/object( new /obj/machinery/portable_atmospherics/canister/oxygen(), 5 )
	oxygen.prepackage_item = TRUE
	oxygen.overmap_objective = src
	cargo_item_types += oxygen

	var/datum/cargo_item_type/object/suit = new /datum/cargo_item_type/object( new /obj/item/clothing/suit/space/eva() )
	suit.prepackage_item = TRUE
	suit.overmap_objective = src
	cargo_item_types += suit

	var/datum/cargo_item_type/object/helm = new /datum/cargo_item_type/object( new /obj/item/clothing/head/helmet/space/eva() )
	helm.prepackage_item = TRUE
	helm.overmap_objective = src
	cargo_item_types += helm

	var/datum/cargo_item_type/object/mask = new /datum/cargo_item_type/object( new /obj/item/clothing/mask/breath() )
	mask.prepackage_item = TRUE
	mask.overmap_objective = src
	cargo_item_types += mask
