
// List of specifically defined cargo_objective types so the objective knows how to handle them 

/datum/cargo_item_type
	// target is an arbitrary number to track how many units have been delivered. 
	// target can be an amount of objects, a count of minerals, or a unit of reagents 
	var/target = 0 
	// tally is an arbitrary number that represents a percent of target 
	var/tally = 0 

/datum/cargo_item_type/proc/check_contents( var/obj/container ) 
	// This is a default item type, it has no item information to compare! 
	// Stations call this proc, the cargo_item_type datum handles the rest 
	// PLEASE do not put areas inside freight torps this WILL cause problems! 
	return FALSE 

/datum/cargo_item_type/reagent 
	var/reagent = null
	var/containers = list( // We're not accepting chemicals in food 
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/chemtank,
	)
	target = 30 

/datum/cargo_item_type/reagent/check_contents( var/obj/container )
	// var/objects = locate( item ) in container

/datum/cargo_item_type/reagent/blood 
	reagent = /datum/reagent/blood
	var/blood_type = null
	containers = list(
		/obj/item/reagent_containers/blood
	)
	target = 30 

/datum/cargo_item_type/generic 
	var/item = null 
	target = 1

/datum/cargo_item_type/generic/check_contents( var/obj/container )
	// var/objects = locate( item ) in container

/datum/cargo_item_type/generic/mineral 
	var/mineral = null 
	target = 50
