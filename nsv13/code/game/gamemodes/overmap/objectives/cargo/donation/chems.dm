/datum/overmap_objective/cargo/donation/chems
	name = "Donate medical chemicals"
	desc = "Donate 1 or more chemical bottles"
	
	// Must define the chems so we don't get things like adminordrazine
	var/list/possible_chemicals = list()
	var/chem_types_min = 2
	var/chem_types_max = 4

	var/list/chemicals = list()

/datum/overmap_objective/cargo/donation/chems/instance()
	message_admins( "chems instance" )
	. = ..()

	for( var/datum/chemical_reaction/D in subtypesof( /datum/chemical_reaction ) )
		if ( D.id && istype( D.id, /datum/reagent/medicine ) )
			var/datum/reagent/medicine/N = new D.id()
			possible_chemicals[D] = N
	
	message_admins( possible_chemicals )
	message_admins( length( possible_chemicals ) )

	var/attempts = 0
	if ( chem_types_max && length( possible_chemicals ) )
		if ( length( chemicals ) < chem_types_max )
			while( length( chemicals ) < chem_types_max ) 
				attempts++
				if ( attempts > 100 )
					chem_types_max = 0 // Stop, just stop 

				var/C = pick( possible_chemicals )
				if ( !( locate( C ) in chemicals ) )
					// chemicals += list(
					// 	"type" = C,
					// 	"units" = 30,
					// 	"delivered" = 0
					// )
					var/datum/cargo_item_type/reagent/O = new /datum/cargo_item_type/reagent 
					O.reagent = C 
					chemicals += O

	brief = "e"
