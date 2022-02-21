
#define REQUIRE_ALL 0 // Requires all freight_types check_contents to return TRUE for this group to return TRUE
#define REQUIRE_ANY 1 // Requires one of any freight_types check_contents to return TRUE
#define REQUIRE_ONE 2 // Requres one and only one freight_type to return TRUE. Otherwise returns FALSE

// A special datum for handling grouped checks on freight types
// This datum can be recursive, such that a freight_type_group appears in the freight_types list
// Reminder! Freight torpedoes can only hold 4 slots worth of items!
// This means the entire cargo objective (all freight types under the objective) should not be requiring more than 4 prepackaged item types

/datum/freight_type/group
	var/list/freight_types = list()
	var/require = REQUIRE_ALL

	// Grouped freight types should NOT add duplicate approved contents to the freight type check when handling recursion! Only single freight types can do this
	add_approved_contents_to_check = FALSE

// Supplying a list on constructor assumes it is for freight_types only, to simply creating cargo objectives from scratch
// If you want nested freight_type_groups be ready to get your hands dirty
/datum/freight_type/group/New( var/list/list )
	freight_types = list

/datum/freight_type/group/set_objective( var/datum/overmap_objective/cargo/O )
	. = ..()
	for ( var/datum/freight_type/F in freight_types )
		F.set_objective( O )

/datum/freight_type/group/require/all

/datum/freight_type/group/require/any
	require = REQUIRE_ANY

/datum/freight_type/group/require/one
	require = REQUIRE_ONE

/datum/freight_type/group/check_contents( var/datum/freight_type_check/freight_type_check )
	var/list/itemTargets = list()

	if ( freight_type_check.group_status == TRUE )
		var/success = FALSE
		switch ( require )
			if ( REQUIRE_ALL )
				success = TRUE
				for ( var/datum/freight_type/F in freight_types )
					var/result = F.check_contents( freight_type_check )
					if ( result )
						itemTargets += result
						if( F.add_approved_contents_to_check )
							freight_type_check.untracked_contents -= result
							freight_type_check.approved_contents += result
					else
						success = FALSE

			if ( REQUIRE_ANY )
				if ( !success )
					for ( var/datum/freight_type/F in freight_types )
						var/result = F.check_contents( freight_type_check )
						if ( result )
							itemTargets += result
							if ( F.add_approved_contents_to_check )
								freight_type_check.untracked_contents -= result
								freight_type_check.approved_contents += result
							success = TRUE

			if ( REQUIRE_ONE )
				if ( success == FALSE )
					for ( var/datum/freight_type/F in freight_types )
						var/result = F.check_contents( freight_type_check )
						if ( result )
							itemTargets += result
							if ( F.add_approved_contents_to_check )
								freight_type_check.untracked_contents -= result
								freight_type_check.approved_contents += result
							switch( success )
								if ( FALSE )
									success = TRUE
								if ( TRUE )
									success = "toomany"

				if ( success == "toomany" )
					success = FALSE

		if ( !success )
			freight_type_check.groups_refused += src // This group failed to find its desired contents in the last shipment
		freight_type_check.group_status = success // If one group of freight_types fails to validate, we stop checking the rest

		if ( success )
			return itemTargets

	return FALSE

/datum/freight_type/group/get_target()
	var/target = 0
	if ( length( freight_types ) )
		for( var/datum/freight_type/T in freight_types )
			target += T.get_target()
	return target

/datum/freight_type/group/deliver_package()
	var/status = TRUE
	for ( var/datum/freight_type/T in freight_types )
		if ( !T.deliver_package() )
			status = FALSE
	return status

/datum/freight_type/group/get_supply_request_form_segment()
	var/info = ""

	switch( require )
		if ( REQUIRE_ALL )
			info += "<li><p>All in group:</p></li>"
		if ( REQUIRE_ANY )
			info += "<li><p>One or more in group:</p></li>"
		if ( REQUIRE_ONE )
			info += "<li><p>One and only one in group:</p></li>"

	info += "<ul>"

	for ( var/datum/freight_type/T in freight_types )
		var/item = T.get_item_name()
		if ( item )
			info += "<li>Item: [item]</li>"
			info += "<li>Quantity: [T.get_target()] units</li>"
		if ( T.send_prepackaged_item )
			if ( objective.send_to_station_pickup_point )
				info += "<span>Prepackaged: Freight contents are prepackaged and delivered to [objective.pickup_destination]. Navigate to [objective.pickup_destination.current_system] and contact the station to receive the package.</span>"
			else
				info += "<span>Prepackaged: Freight contents are prepackaged and delivered to your cargo supplypod droppoint.</span>"
		info += T.get_supply_request_form_segment()

	info += "</ul>"

	return info
