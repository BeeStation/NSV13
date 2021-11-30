/datum/overmap_objective/defend_station
	name = "Station Defence"
	desc = "Travel to a designated system and defend a friendly station"
	brief = "Travel to a designated system and defend a friendly station"
	var/datum/star_system/selected_system
	var/waves
	var/random_faction
	var/last_wave = FALSE

/datum/overmap_objective/defend_station/instance()
	//Again we look for an empty random system
	var/list/candidate = list()
	for(var/datum/star_system/random/R in SSstar_system.systems)
		if(!R.trader)
			candidate += R

	selected_system = pick(candidate)

	//Generate the station entity and setup its destruction signal
	var/datum/trader/nt_staging_post/T = new /datum/trader/nt_staging_post
	var/obj/structure/overmap/trader/nt_staging_post/A = SSstar_system.spawn_anomaly(T.station_type, selected_system)
	A.starting_system = selected_system.name
	A.current_system = selected_system
	A.set_trader(T)
	selected_system.trader = T
	RegisterSignal(A, COMSIG_STATION_DESTROYED, .proc/station_destroyed)

	//Signal the players arriving
	RegisterSignal(SSstar_system.main_overmap, COMSIG_SHIP_ARRIVED, .proc/stage_encounter)

	//Update description
	desc = "Travel to [selected_system] and defend a friendly station"
	brief = "Intellegence indicates a hostile fleet enroute to one of our staging posts in [selected_system], head there and ensure the station survives the assault."

/datum/overmap_objective/defend_station/proc/stage_encounter()
	if(status != 0)
		return

	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	if(OM.current_system == selected_system)
		UnregisterSignal(SSstar_system.main_overmap, COMSIG_SHIP_ARRIVED)

		priority_announce("Just in time, bluespace signatures detected!")

		waves = rand(1,3) //How many waves?
		random_faction = rand(1,2) //Which faction is attacking?

		send_fleet()

/datum/overmap_objective/defend_station/proc/send_fleet()
	waves --
	var/list/fleets = list()
	switch(random_faction)
		if(1) //Syndicate
			fleets = list(
				/datum/fleet/neutral,
				/datum/fleet/boarding,
				/datum/fleet/wolfpack,
				/datum/fleet/elite
			)

		if(2) //Space Pirates
			fleets = list(
				/datum/fleet/pirate,
				/datum/fleet/pirate/raiding
			)

	var/datum/fleet/P = pick(fleets)
	var/datum/fleet/F = new P
	selected_system.fleets += F
	F.current_system = selected_system
	F.assemble(selected_system)

	if(waves >= 1)
		addtimer(CALLBACK(src, .proc/send_fleet), 3 MINUTES) //Small interval between waves

	if(waves < 1)
		last_wave = TRUE //Unlock possible victory

/datum/overmap_objective/defend_station/proc/station_destroyed()
	status = 2
	priority_announce("Reports indicate that staging post's reactor went critical, search for survivors if possible and continue your primary objective.")

/datum/overmap_objective/defend_station/check_completion()
	if(!last_wave)
		return

	if(selected_system.enemies_in_system.len == 0)
		priority_announce("Station defended, continue with your primary objective.")
		status = 1
