
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

// Supplying a list on constructor assumes it is for freight_types only, to simply creating cargo objectives from scratch
// If you want nested freight_type_groups be ready to get your hands dirty
/datum/freight_type/group/New( var/list/list )
	freight_types = list

/datum/freight_type/group/require/all

/datum/freight_type/group/require/any
	require = REQUIRE_ANY

/datum/freight_type/group/require/one
	require = REQUIRE_ONE

/datum/freight_type/group/check_contents( var/datum/freight_type_check/freight_type_check )
	if ( freight_type_check.group_status == TRUE )
		var/success = FALSE
		switch ( require )
			if ( REQUIRE_ALL )
				success = TRUE
				for ( var/datum/freight_type/F in freight_types )
					var/result = F.check_contents( freight_type_check )
					if ( !result )
						success = FALSE

			if ( REQUIRE_ANY )
				if ( !success )
					for ( var/datum/freight_type/F in freight_types )
						var/result = F.check_contents( freight_type_check )
						if ( result )
							success = TRUE
							break

			if ( REQUIRE_ONE )
				if ( success == FALSE )
					for ( var/datum/freight_type/F in freight_types )
						var/result = F.check_contents( freight_type_check )
						if ( result )
							if ( success )
								success = "toomany"
								break
							success = TRUE

				if ( success == "toomany" )
					success = FALSE

		freight_type_check.group_status = success // If one group of freight_types fails to validate, we stop checking the rest

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
