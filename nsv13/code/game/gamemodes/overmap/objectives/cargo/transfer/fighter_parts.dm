/datum/overmap_objective/cargo/transfer/fighter_parts
	name = "Deliver fighter parts"
	desc = "Deliver fighter parts"
	crate_name = "Experimental Fighter Parts crate"

/datum/overmap_objective/cargo/transfer/fighter_parts/New()
	var/list/possible_components = list( // Because some of the subtypes are underdeveloped and shouldn't be present on the ship
		/obj/item/fighter_component/fuel_tank,
		/obj/item/fighter_component/armour_plating,
		/obj/item/fighter_component/armour_plating/tier2,
		/obj/item/fighter_component/armour_plating/tier3,
		/obj/item/fighter_component/canopy,
		/obj/item/fighter_component/battery,
		/obj/item/fighter_component/engine,
		/obj/item/fighter_component/engine/tier2,
		/obj/item/fighter_component/engine/tier3,
		/obj/item/fighter_component/oxygenator,
		/obj/item/fighter_component/avionics,
		/obj/item/fighter_component/docking_computer,
		/obj/item/fighter_component/primary/cannon,
		/obj/item/fighter_component/primary/cannon/heavy,
		/obj/item/fighter_component/secondary/utility/hold,
		/obj/item/fighter_component/secondary/utility/hold/tier2,
		/obj/item/fighter_component/secondary/utility/hold/tier3,
		/obj/item/fighter_component/secondary/ordnance_launcher,
		/obj/item/fighter_component/secondary/ordnance_launcher/tier2,
		/obj/item/fighter_component/secondary/ordnance_launcher/tier3,
		/obj/item/fighter_component/secondary/ordnance_launcher/torpedo,
		/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier2,
		/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier3,
	)

	var/allow_replacements = pick( TRUE, FALSE ) // I just want to see someone get tempbanned for objective gambling on roundstart fighter upgrade lootboxes
	send_to_station_pickup_point = TRUE

	for ( var/i = 0; i < rand( 2, 4 ); i++ )
		var/picked = pick( possible_components )
		var/datum/freight_type/single/object/C = new( picked )
		C.send_prepackaged_item = TRUE
		C.overmap_objective = src
		C.allow_replacements = allow_replacements
		freight_type_group = new( list( C ) )
