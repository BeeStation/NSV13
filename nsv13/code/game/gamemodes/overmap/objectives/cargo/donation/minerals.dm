/datum/overmap_objective/cargo/donation/minerals
	name = "Donate minerals"
	desc = "Donate 1 or more minerals"
	var/list/possible_minerals = list(
		/obj/item/stack/sheet/mineral/sandstone,
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/sheet/mineral/uranium,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/sheet/mineral/silver,
		/obj/item/stack/sheet/mineral/copper,
		/obj/item/stack/sheet/mineral/titanium,
	)

/datum/overmap_objective/cargo/donation/minerals/instance() 
	cargo_item_type = new /datum/cargo_item_type/object/mineral 
	var/datum/cargo_item_type/object/mineral/C = cargo_item_type
	C.item = pick( possible_minerals )

/datum/overmap_objective/cargo/donation/minerals/pick_station()
	message_admins( "minerals pick_station" )
	// Pick a random existing station to give this objective to 
	var/list/ntstations = list()
	for ( var/trader in SSstar_system.traders )
		var/datum/trader/T = trader
		if ( T.faction_type == FACTION_ID_NT )
			// Don't pick mineral type traders to deliver minerals 
			if ( !istype( T.type, /datum/trader/shallowstone ) )
				ntstations += T 

	var/obj/structure/overmap/trader/S = pick( ntstations )

	// Assign this objective directly to the station, so the station can track it 
	destination = S 
	S.add_objective( src )
