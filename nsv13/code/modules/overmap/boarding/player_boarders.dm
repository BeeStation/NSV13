#define SYNDICATE_BOARDER_TEAMS list("Noble", "Helljumper","Red", "Black", "Crimson","Osiris", "Apex", "Apollo", "Thrace", "Galactica", "Valkyrie", "Recon", "Gamma", "Alpha", "Bravo", "Charlie", "Delta", "Indigo", "Sol's fist", "Abassi", "Cartesia", "Switchback", "Majestic", "Mountain", "Shadow", "Shrike", "Sterling", "FTL", "Belter", "Moya", "Crichton")
#define TYPEPATH2NAME(path) reverseList(splittext(path, "/"))[1]

/**Configuration for a type of player boarder.
*/
/datum/player_boarder_type
	var/leader_callsign = "Leader"
	var/datum/outfit/leader_outfit

	var/outfits = list()
	var/datum/antagonist/antag_datum
	var/role = "Boarder"

	var/sound = 'nsv13/sound/effects/ship/boarding_pod.ogg'
	var/announcement = "<span class='userdanger'>You can hear several tethers attaching to the ship.</span>"
	var/datum/map_template/boarding_pod


/datum/player_boarder_type/proc/generate_callsign(var/num)
	return "Boarder"


/datum/player_boarder_type/proc/select_outfit(var/num)
	if(num == 0 && leader_outfit)
		return leader_outfit
	else
		return pick(outfits)

/datum/player_boarder_type/syndicate
	antag_datum = /datum/antagonist/traitor/boarder
	outfits = list(/datum/outfit/syndicate/odst/smg, /datum/outfit/syndicate/odst/shotgun,
	          /datum/outfit/syndicate/odst/medic)

	leader_outfit = /datum/outfit/syndicate/odst/smg
	boarding_pod = /datum/map_template/syndicate_boarding_pod
	var/static/team_names = list("Noble", "Helljumper","Red", "Black", "Crimson",
							"Osiris", "Apex", "Apollo", "Thrace", "Galactica",
							"Valkyrie", "Recon", "Gamma", "Alpha", "Bravo",
							"Charlie", "Delta", "Indigo", "Sol's fist", "Abassi",
							"Cartesia", "Switchback", "Majestic", "Mountain",
							"Shadow", "Shrike", "Sterling", "FTL", "Belter",
							"Moya", "Crichton")

/datum/player_boarder_type/syndicate/generate_callsign(var/num = 0, var/team_name)
	var/callsign = ""
	if(team_name)
		callsign = "[team_name]-"
	else
		callsign = "Drop Trooper "
	if(num == 0)
		return callsign + "Lead"
	return callsign + num2text(num)


#undef SYNDICATE_BOARDER_TEAMS
#undef TYPEPATH2NAME
