/datum/overmap_objective/cargo/donation/chems
	name = "Donate medical chemicals"
	desc = "Donate 1 or more chemical bottles"
	pick_same_destination = TRUE
	crate_name = "Chemicals crate"
	var/chemicals = list()

/datum/overmap_objective/cargo/donation/chems/New( var/datum/reagent/medicine )
	if ( medicine )
		chemicals += medicine
	else // Haven't picked one yet? Don't worry, we got you covered!
		get_random_chems()
	setup_freight_type_group()

/datum/overmap_objective/cargo/donation/chems/proc/get_random_chems()
	var/list/possible_chemicals = list()

	for( var/D in subtypesof( /datum/chemical_reaction ) )
		var/datum/chemical_reaction/C = new D()
		if ( C.id )
			if ( ispath( C.id, /datum/reagent/medicine ) )
				possible_chemicals += C.id

	for( var/i = 0; i < rand( 1, 3 ); i++ )
		var/datum/reagent/medicine/picked = pick_n_take( possible_chemicals )
		chemicals += picked

/datum/overmap_objective/cargo/donation/chems/proc/setup_freight_type_group()
	var/list/F = list()

	for ( var/datum/reagent/picked in chemicals )
		var/datum/freight_type/single/reagent/R = new( picked )
		R.target = ( 90 / length( chemicals ) )
		F += R
		var/datum/freight_type/single/reagent/pill_patch/P = new( picked )
		P.target = R.target
		F += P

	freight_type_group = new( F )

