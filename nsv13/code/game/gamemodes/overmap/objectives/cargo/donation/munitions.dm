/datum/overmap_objective/cargo/donation/munitions
	name = "Donate munitions"
	desc = "Donate munitions"
	var/list/possible_munitions = list(
		/obj/item/ship_weapon/ammunition/missile,
		/obj/item/powder_bag/plasma,
		/obj/item/ship_weapon/ammunition/naval_artillery,
		/obj/item/ship_weapon/parts/missile/warhead/probe,
	)
	crate_name = "Surplus Munitions crate"

/datum/overmap_objective/cargo/donation/munitions/New()
	var/picked = pick( possible_munitions )
	var/datum/freight_type/single/object/C = new( picked )
	C.target = rand( 6, 12 )
	freight_type_group = new( list( C ) )
