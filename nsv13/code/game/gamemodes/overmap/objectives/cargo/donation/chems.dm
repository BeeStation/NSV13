/datum/overmap_objective/cargo/donation/chems
	name = "Donate medical chemicals"
	desc = "Donate 1 or more chemical bottles"
	pick_same_destination = TRUE
	var/list/chemicals = list()

/datum/overmap_objective/cargo/donation/chems/New( var/datum/reagent/medicine/medicine )
	message_admins( "chems instance" )

	if ( medicine ) 
		cargo_item_types += new /datum/cargo_item_type/reagent( new medicine() )
		chemicals += medicine 
	else // Haven't picked one yet? Don't worry, we got you covered! 
		get_random_chems() 

/datum/overmap_objective/cargo/donation/chems/proc/get_random_chems() 
	var/list/possible_chemicals = list()
	var/chem_types_min = 1
	var/chem_types_max = 3

	for( var/D in subtypesof( /datum/chemical_reaction ) )
		var/datum/chemical_reaction/C = new D()
		if ( C.id )
			if ( ispath( C.id, /datum/reagent/medicine ) )
				possible_chemicals += C.id

	var/attempts = 0
	var/get_max = rand( chem_types_min, chem_types_max ) 

	if ( get_max && length( possible_chemicals ) )
		if ( length( chemicals ) < get_max )
			while( length( chemicals ) < get_max ) 
				attempts++
				if ( attempts > 100 ) 
					get_max = 0 // Stop, just stop 
					
				var/datum/reagent/medicine/picked = pick( possible_chemicals )
				if ( !( locate( picked ) in chemicals ) )
					var/datum/cargo_item_type/reagent/O = new /datum/cargo_item_type/reagent( new picked() )
					cargo_item_types += O
					chemicals += picked 
