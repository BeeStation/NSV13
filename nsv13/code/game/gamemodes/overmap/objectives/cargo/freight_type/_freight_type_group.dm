
#define REQUIRE_ALL 0
#define REQUIRE_ONE 1

// A special datum for handling grouped checks on freight types
// This datum can be recursive, such that a freight_type_group appears in the freight_types list
// Reminder! Freight torpedoes can only hold 4 slots worth of items! This means cargo objectives should not be requiring more than 4 prepackaged item types

/datum/freight_type_group
	var/list/freight_types = list()
	var/list/freight_type_groups = list()
	var/require = REQUIRE_ALL

/datum/freight_type_group/require/all

/datum/freight_type_group/require/one
	require = REQUIRE_ONE

/datum/freight_type_group/proc/check_contents()
	switch ( require )
		if ( REQUIRE_ALL )
			for ( var/datum/freight_type/F in freight_types )
				if ( !F.check_contents() )
					return FALSE
			for ( var/datum/freight_type_group/G in freight_type_groups )
				if ( !G.check_contents() )
					return FALSE
			return TRUE

		if ( REQUIRE_ONE )
			for ( var/datum/freight_type/F in freight_types )
				if ( F.check_contents() )
					return TRUE
			for ( var/datum/freight_type_group/G in freight_type_groups )
				if ( G.check_contents() )
					return TRUE
			return FALSE

/datum/freight_type_group/proc/get_target()
	var/target = 0
	if ( length( freight_types ) )
		for( var/datum/freight_type/T in freight_types )
			target += T.target
		for ( var/datum/freight_type_group/G in freight_type_groups )
			target += G.get_target()
	return target

/datum/freight_type_group/proc/deliver_package()
	var/status = TRUE
	for ( var/datum/freight_type/T in freight_types )
		if ( !T.deliver_package() )
			status = FALSE
	for ( var/datum/freight_type_group/G in freight_type_groups )
		if ( !G.deliver_package() )
			status = FALSE
	return status
