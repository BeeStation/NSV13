
// Generic object for storing delivery data
// A datum was used instead of a list in case cargo missions need refactored later

/datum/freight_delivery_receipt
	var/obj/structure/overmap/vessel = null
	var/mob/living/courier = null
	var/obj/shipment = null
	var/list/completed_objectives = list()
	// If an incomplete shipment was sent, the fuzzy_incomplete_objective will store which objective was closest to completion, for the players to debug
	var/datum/overmap_objective/cargo/fuzzy_incomplete_objective
