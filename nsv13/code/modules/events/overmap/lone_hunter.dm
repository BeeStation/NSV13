//OVERMAP Event - This will alter the state of the OVERMAP Z-LEVELS
//This event will spawn a single syndicate cruiser on the same overmap z-level as the main "hero" ship
//This event should only fire through the overmap handler

/datum/round_event_control/lone_hunter
	name = "OVERMAP: Lone Hunter"
	typepath = /datum/round_event/lone_hunter
	weight = 0
	max_occurrences = 0
	min_players = 5

/datum/round_event/lone_hunter

/datum/round_event/lone_hunter/start()
	var/opponent = /obj/structure/overmap/syndicate/ai //generic bad guy
	var/target = SSstar_system.find_main_overmap() //find the "hero" ship
	var/datum/star_system/current_sys = SSstar_system.find_system(target)
	minor_announce("Bluespace Signature Detected", "DRADIS Uplink") //Hot Drop
	sleep(rand(3 SECONDS, 6 SECONDS)) // 3 to 6 seconds to spill your coffee all over the weapons console
	SSstar_system.spawn_ship(opponent, current_sys)
