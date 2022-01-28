/datum/overmap_objective/cargo/donation/chems
	name = "Donate medical chemicals"
	desc = "Donate 1 or more chemical bottles"
	pick_same_destination = TRUE
	var/list/chemicals = list()
	crate_name = "Chemicals crate"

/datum/overmap_objective/cargo/donation/chems/New( var/datum/reagent/medicine )
	if ( medicine ) 
		freight_types += new /datum/freight_type/reagent( new medicine() )
		chemicals += medicine 
	else // Haven't picked one yet? Don't worry, we got you covered! 
		get_random_chems() 

/datum/overmap_objective/cargo/donation/chems/proc/get_random_chems() 
	var/list/possible_chemicals = list()

	for( var/D in subtypesof( /datum/chemical_reaction ) )
		var/datum/chemical_reaction/C = new D()
		if ( C.id )
			if ( ispath( C.id, /datum/reagent/medicine ) )
				possible_chemicals += C.id
	
	var/numberOfChemicals = rand( 1, 3 )
	for( var/i = 0; i < numberOfChemicals; i++ ) 
		var/datum/reagent/medicine/picked = pick_n_take( possible_chemicals )
		var/datum/freight_type/reagent/R = new /datum/freight_type/reagent( picked )
		R.target = ( 90 / numberOfChemicals )
		freight_types += R
		chemicals += picked 
		
