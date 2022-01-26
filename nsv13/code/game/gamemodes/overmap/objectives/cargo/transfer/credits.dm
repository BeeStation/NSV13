/datum/overmap_objective/cargo/transfer/credits 
	name = "Deliver credits"
	desc = "Deliver credits under the table"
	crate_name = "Physical Credit Transfer"

/datum/overmap_objective/cargo/transfer/credits/New() 
	var/datum/freight_type/object/credits/C = new /datum/freight_type/object/credits( rand( 3, 15 ) * 1000 )
	C.send_prepackaged_item = TRUE
	C.allow_replacements = FALSE // No. If you steal the credits you fail the objective. 
	C.overmap_objective = src
	send_to_station_pickup_point = TRUE
	freight_types += C
