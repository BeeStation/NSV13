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

/datum/overmap_objective/cargo/donation/minerals/New()
	var/picked = pick( possible_minerals )
	var/atom/P = new picked()
	freight_type_group = new( list( new /datum/freight_type/single/object/mineral( picked ) ) )
	crate_name = "Surplus [P.name] crate"

/datum/overmap_objective/cargo/donation/minerals/pick_station()
	// Pick a random existing station to give this objective to
	var/list/ntstations = list()
	var/list/ntstations_expecting_cargo = list()
	for ( var/trader in SSstar_system.traders )
		var/datum/trader/T = trader
		if ( T.faction_type == FACTION_ID_NT )
			// Don't pick mineral type traders to deliver minerals
			if ( !istype( T.type, /datum/trader/shallowstone ) )
				var/obj/structure/overmap/S = T.current_location
				ntstations += S

				if ( length( S.expecting_cargo ) )
					ntstations_expecting_cargo += S

	var/obj/structure/overmap/S
	if ( pick_same_destination && length( ntstations_expecting_cargo ) )
		S = pick( ntstations_expecting_cargo )
	else
		S = pick( ntstations )

	// Assign this objective directly to the station, so the station can track it
	destination = S
	S.add_objective( src )
