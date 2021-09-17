
// List of specifically defined cargo_objective types so the objective knows how to handle them 

/datum/cargo_objective
	var/target = 0
	var/delivered = 0

/datum/cargo_objective/reagent 
	var/reagent = null
	target = 30 

/datum/cargo_objective/blood 
	var/blood_type = null
	target = 30 

/datum/cargo_objective/mineral 
	var/mineral = null 
	target = 50

/datum/cargo_objective/handheld 
	var/item = null 
	target = 1
