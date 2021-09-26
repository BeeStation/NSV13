/datum/overmap_objective/cargo/donation/chems
	name = "Donate medical chemicals"
	desc = "Donate 1 or more chemical bottles"
	
	// Must define the chems so we don't get things like adminordrazine
	// TODO Hook onto /datum/chemical_reaction in medical.dm to instead generate a list from any craftable chemical 
	var/list/possible_chemicals = list(
		/datum/reagent/medicine/spaceacillin,
		/datum/reagent/medicine/inacusiate,
		/datum/reagent/medicine/oculine,
		/datum/reagent/medicine/synaptizine,
		/datum/reagent/medicine/charcoal,
		/datum/reagent/medicine/synthflesh,
		/datum/reagent/medicine/styptic_powder,
		/datum/reagent/medicine/calomel,
		/datum/reagent/medicine/potass_iodide,
		/datum/reagent/medicine/pen_acid,
		/datum/reagent/medicine/sal_acid,
		/datum/reagent/medicine/salbutamol,
		/datum/reagent/medicine/perfluorodecalin,
		/datum/reagent/medicine/cryoxadone,
		/datum/reagent/medicine/epinephrine,
		/datum/reagent/medicine/neurine,
		/datum/reagent/medicine/tricordrazine,
	)
	var/chem_types_min = 2
	var/chem_types_max = 4

	var/list/chemicals = list()

/datum/overmap_objective/cargo/donation/chems/instance()
	. = ..()
	
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
