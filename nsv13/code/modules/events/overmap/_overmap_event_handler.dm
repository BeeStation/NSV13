//OVERMAP Event - This will alter the state of the OVERMAP Z-LEVELS
//This is the event controller that handles and selects overmap events when triggered by SSsystem
//TODO - Expand this controller to have different difficulty categories and probablities

/datum/round_event_control/_overmap_event_handler
	name = "OVERMAP: Event Handler"
	typepath = /datum/round_event/_overmap_event_handler
	weight = 0
	max_occurrences = 50
	min_players = 5

/datum/round_event/_overmap_event_handler

/datum/round_event/_overmap_event_handler/start() //Include overmap events in the list below
	var/datum/round_event_control/event_selection = pick(	/datum/round_event_control/belt_rats, \
															/datum/round_event_control/lone_hunter)
	var/datum/round_event_control/E = new event_selection()
	E.runEvent()
	//SSstar_system.modifier = 0 //Reset overmap spawn modifier
	var/datum/round_event_control/_overmap_event_handler/OEH = locate(/datum/round_event_control/_overmap_event_handler) in SSevents.control
	OEH.weight = 0 //Reset controller weighting
