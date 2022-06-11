/datum/overmap_objective/cargo/transfer/gun
	name = "Deliver a gun"
	desc = "Deliver a gun"
	crate_name = "Gun crate"
	send_to_station_pickup_point = TRUE

/datum/overmap_objective/cargo/transfer/gun/New()
	..()

	freight_type_group = new( list(
		new /datum/freight_type/single/object(
			item_type = pick( subtypesof( /obj/item/gun/ballistic ) ),
			item_name = "prototype gun",
			// allow_replacements = pick( TRUE, FALSE ) // See fighter_parts.dm
			allow_replacements = FALSE,
			send_prepackaged_item = TRUE,
			approve_inner_contents = TRUE // Guns have firing pins and ammo clips inside them
		)
	) )
