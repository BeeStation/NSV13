
// Generic object for storing delivery data 
// A datum was used instead of a list in case cargo missions need refactored later 

/datum/freight_delivery_receipt 
	var/obj/structure/overmap/vessel = null 
	var/mob/living/courier = null
	var/obj/shipment = null 
	var/list/completed_objectives = list() 
