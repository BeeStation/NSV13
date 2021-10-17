/datum/overmap_objective/cargo/donation/munitions 
	name = "Donate munitions"
	desc = "Donate munitions"
	var/list/possible_munitions = list(
		/obj/item/ship_weapon/ammunition/missile,
		/obj/item/ship_weapon/ammunition/torpedo,
		/obj/item/ship_weapon/ammunition/torpedo/probe,
		/obj/item/ship_weapon/ammunition/torpedo/nuke,
		/obj/item/ship_weapon/ammunition/naval_artillery,
	)
	crate_name = "Surplus Munitions crate"

/datum/overmap_objective/cargo/donation/munitions/New() 
	var/picked = pick( possible_munitions )
	var/datum/cargo_item_type/object/C = new /datum/cargo_item_type/object( new picked() )
	C.target = rand( 3, 5 )
	cargo_item_types += C
