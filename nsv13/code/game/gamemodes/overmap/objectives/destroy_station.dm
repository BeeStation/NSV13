/datum/overmap_objective/destroy_station
	name = "Station Destruction"
	desc = "Destroy the syndicate listening post in selected_system"
	brief = "Destroy the syndicate listening post in selected_system"
	var/datum/star_system/selected_system

/datum/overmap_objective/destroy_station/instance()
	//Search for an empty syndicate system
	var/list/candidate = list()
	for(var/datum/star_system/S in SSstar_system.systems)
		if(S.alignment == "syndicate")
			candidate += S.name

	//Not a special system
	candidate -= "Dolos Remnants"
	candidate -= "Abassi"
	candidate -= "Oasis Fidei"
	var/datum/star_system/M = pick(candidate)
	selected_system = SSstar_system.system_by_id(M)

	//Generate the station entity and set signal
	var/datum/trader/syndi_listening_post/T = new /datum/trader/syndi_listening_post
	var/obj/structure/overmap/trader/syndi_listening_post/S = SSstar_system.spawn_anomaly(T.station_type, selected_system)
	S.starting_system = selected_system.name
	S.current_system = selected_system
	S.set_trader(T)
	selected_system.trader = T
	RegisterSignal(S, COMSIG_STATION_DESTROYED, .proc/station_destroyed)

	//Set signal for player arriving in starsystem
	RegisterSignal(SSstar_system.main_overmap, COMSIG_SHIP_ARRIVED, .proc/stage_encounter)

	//Update description
	desc = "(optional) Destroy the syndicate listening post in [selected_system]"
	brief = "(optional) Intellegence indicates a key weakness in the Syndicate invasion plan, travel to [selected_system] and destroy the listening post."

/datum/overmap_objective/destroy_station/proc/stage_encounter()
	if(status)
		return

	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	if(OM.current_system == selected_system)
		UnregisterSignal(SSstar_system.main_overmap, COMSIG_SHIP_ARRIVED)

		priority_announce("Destroy that station!")

		var/datum/fleet/F = new /datum/fleet/defensive()
		selected_system.fleets += F
		F.current_system = selected_system
		F.assemble(selected_system)

/datum/overmap_objective/destroy_station/proc/station_destroyed()
	status = 1
	priority_announce("Reports indicate that the Syndicate station has been destroyed, assess your condition and continue your primary objective.")
