//CURRENTLY DESIGNED FOR ARMADA MODE - USE AT OWN PERAL

/datum/overmap_objective/cargo/transfer/engine_parts
	name = "Deliver critical engine parts"
	desc = "Deliver critical engine parts to a system"
	crate_name = "Critical engine parts"

/datum/overmap_objective/cargo/transfer/engine_parts/New()
	//Stormdrive components
	var/datum/freight_type/object/core = new /datum/freight_type/object( /obj/item/stormdrive_core, 1)
	core.send_prepackaged_item = TRUE
	core.overmap_objective = src
	freight_types += core

	var/datum/freight_type/object/rods = new /datum/freight_type/object( /obj/item/control_rod/superior, 5)
	rods.send_prepackaged_item = TRUE
	rods.overmap_objective = src
	freight_types += rods

	var/datum/freight_type/object/gas = new /datum/freight_type/object( /obj/machinery/portable_atmospherics/canister/constricted_plasma, 1)
	gas.send_prepackaged_item = TRUE
	gas.overmap_objective = src
	freight_types += gas

	var/datum/freight_type/object/pipe = new /datum/freight_type/object( /obj/item/pipe_dispenser, 2)
	pipe.send_prepackaged_item = TRUE
	pipe.overmap_objective = src
	freight_types += pipe


/datum/overmap_objective/cargo/transfer/engine_parts/update_brief()
	if ( length( freight_types ) )
		var/list/segments = list()
		for( var/datum/freight_type/type in freight_types )
			segments += type.get_brief_segment()

		var/obj/structure/overmap/S = destination
		desc = "(optional) Deliver critical engine parts to [S.current_system]"
		brief = "(optional) Deliver critical engine repair components to the stranded vessel in [S.current_system]. Prepackaged components include: [segments.Join( ", " )]"

/datum/overmap_objective/cargo/transfer/engine_parts/pick_station()
	//Looking for a random sector system without a trader
	var/list/candidate = list()
	for(var/datum/star_system/random/R in SSstar_system.systems)
		if(!R.trader)
			candidate += R

	//Generate the damaged ship and assign trader datum to it
	var/datum/star_system/S = pick(candidate)
	var/datum/trader/damaged_cruiser/T = new /datum/trader/damaged_cruiser
	var/obj/structure/overmap/trader/damaged_cruiser/D = SSstar_system.spawn_anomaly(T.station_type, S)
	D.starting_system = S.name
	D.current_system = S
	D.set_trader(T)
	S.trader = T

	//Set our objective
	destination = D
	D.add_objective(src)
