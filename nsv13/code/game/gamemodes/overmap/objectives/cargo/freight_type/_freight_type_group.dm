
#define REQUIRE_ALL 0
#define REQUIRE_ONE 1

// A special datum for handling grouped checks on freight types
// This datum can be recursive, such that a freight_type_group appears in the freight_types list!

/datum/freight_type_group
	var/list/freight_types = list()
	var/require = REQUIRE_ALL

/datum/freight_type_group/require/all

/datum/freight_type_group/require/one
	require = REQUIRE_ONE

/datum/freight_type_group/proc/check_contents
	switch ( require )
		if ( REQUIRE_ALL )

		if ( REQUIRE_ONE )
