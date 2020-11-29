

/datum/outfit/syndicate/no_crystals
	implants = list()
	uplink_type = null //Nope :) Go to the req officer you ungas.

//Syndicate defense budget
/obj/item/card/id/departmental_budget/syndicate
	department_ID = ACCOUNT_SYN
	department_name = ACCOUNT_SYN_NAME
	icon_state = "warden" //placeholder

/obj/machinery/computer/cargo/express/syndicate
	name = "Syndicate Requisitions Console"
	req_one_access = list(ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_REQUISITIONS)
	req_access = null
	req_one_access_txt = ""
	account_type = ACCOUNT_SYN
	circuit = /obj/item/circuitboard/computer/cargo/express/syndicate

/obj/machinery/computer/cargo/express/syndicate/emag_act(mob/living/user)
	to_chat(user, "<span class='warning'>The Syndicate would probably have you killed if you tried to interfere with this console...</span>")
	return FALSE

/obj/item/circuitboard/computer/cargo/express/syndicate
	name = "Syndicate Requisitions Console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/cargo/express/syndicate

/datum/outfit/syndicate/no_crystals/syndi_crew
	name = "Syndicate crewmate"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	suit = /obj/item/clothing/suit/ship/syndicate_crew
	uniform = /obj/item/clothing/under/ship/pilot/syndicate
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black

/obj/item/pvp_nuke_spawner
	name = "Nuclear summon device"
	desc = "A small device that will summon the Nebuchadnezzar's nuclear warhead to your location. Click it in your hand to use it."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-green"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	req_one_access_txt = "150"

/obj/item/pvp_nuke_spawner/attack_self(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!is_station_level(user.z))
		to_chat(user, "<span class='notice'>A message crackles in your ear: Operative. You have not yet reached [station_name()], ensure you are on the enemy ship before you attempt to summon a nuke.</span>")
		return
	if(alert("Are you sure you want to summon a nuke to your location?",name,"Yes","No") == "Yes")
		to_chat(user, "<span class='notice'>You press a button on [src] and a nuke appears.</span>")
		var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in GLOB.nuke_list
		nuke.visible_message("<span class='warning'>[src] fizzles out of existence!</span>")
		nuke?.forceMove(get_turf(user))
		do_sparks(1, TRUE, src)
		qdel(src)

/datum/antagonist/nukeop/syndi_crew/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.syndi_crew_spawns))

/datum/antagonist/nukeop/leader/syndi_crew/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.syndi_crew_leader_spawns))

/obj/effect/landmark/start/nukeop/syndi_crew
	name = "Syndicate crew"

/obj/effect/landmark/start/nukeop/syndi_crew/Initialize()
	..()
	GLOB.syndi_crew_spawns += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop/syndi_crew_leader
	name = "Syndicate captain"

/obj/effect/landmark/start/nukeop/syndi_crew_leader/Initialize()
	..()
	GLOB.syndi_crew_leader_spawns += loc
	return INITIALIZE_HINT_QDEL

/obj/machinery/conquest_beacon
	name = "Lighthouse beacon"
	desc = "An advanced navigational beacon capable of forming jump-bridges, allowing entire fleets to jump to a system it designates without needing to use a hyperlane. These devices take an incredible amount of power to operate, and are extremely obvious when activated."
	icon = 'nsv13/icons/obj/munitions_large.dmi'
	icon_state = "lighthouse"
	req_one_access = list(ACCESS_SYNDICATE_LEADER)
	idle_power_usage = 1000 //Slight power drain.
	obj_integrity = 1000
	max_integrity = 1000
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	density = TRUE
	anchored = TRUE
	layer = 4
	var/faction_type = FACTION_ID_SYNDICATE
	var/alignment = "syndicate"
	var/points_per_capture = 50 //How many points does capturing one system net you? Since it's 1000 points to win, this will take a loooot of captures to outright win as syndies.
	var/time_left = 300 //5 min
	var/active = FALSE
	var/next_activation = 0

/obj/machinery/conquest_beacon/examine(mob/user)
	. = ..()
	. += "<span class='sciradio'>Its timer reads: [time_left] seconds remaining.</span>"

/obj/machinery/conquest_beacon/process()
	if(!powered())
		set_active(FALSE)
		return FALSE
	if(active)
		time_left -= 2
		playsound(loc, 'sound/items/timer.ogg', 100, FALSE)
		if(time_left <= 0)
			capture_system()

/obj/machinery/conquest_beacon/proc/capture_system()
	set_active(FALSE, TRUE)
	var/datum/star_system/SS = get_overmap().current_system
	var/datum/faction/ours = SSstar_system.faction_by_id(faction_type)
	if(!ours)
		message_admins("WARNING: Invalid Lighthouse beacon faction set! (no faction with ID: [faction_type])")
		return
	get_overmap().relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg')
	//Annnd send the reinforcements!
	ours.send_fleet(override=SS, force=TRUE)
	ours.gain_influence(points_per_capture)

/obj/machinery/conquest_beacon/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/conquest_beacon/LateInitialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/add_to_ship), 5 SECONDS)

/obj/machinery/conquest_beacon/proc/add_to_ship()
	RegisterSignal(get_overmap(), COMSIG_FTL_STATE_CHANGE, .proc/deactivate)

/obj/machinery/conquest_beacon/proc/deactivate()
	set_active(FALSE, FALSE)

/obj/machinery/conquest_beacon/proc/set_active(state, voluntarily=FALSE)
	if(active && !state && !voluntarily) //Great, they ran away! Good job stopping that capture crew. Now let's alert everyone.
		priority_announce("Jump bridge collapsing. Incursion halted.", "WhiteRapids EAS", 'nsv13/sound/effects/ship/lighthouse_alarm.ogg')
	active = state
	icon_state = "lighthouse[active ? "_on" : ""]"
	time_left = initial(time_left)

/obj/machinery/conquest_beacon/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/conquest_beacon/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/conquest_beacon/attack_hand(mob/user)
	. = ..()
	if(!allowed(user))
		to_chat(user, "<span class='notice'>Access denied.</span>")
		return FALSE
	if(world.time < next_activation)
		to_chat(user, "<span class='sciradio'>[src] is on cooldown.</span>")
		return FALSE
	if(!powered())
		return FALSE
	if(alert(user, "Begin calling for reinforcements with [src]? This is a loud process and will alert enemies to your location!","Confirm","Yes","No")=="No")
		return FALSE
	var/datum/star_system/SS = get_overmap().current_system
	if(SS.alignment == alignment)
		to_chat(user, "<span class='sciradio'>You can't claim systems that your faction already owns...</span>")
		return FALSE
	priority_announce("DANGER: [get_overmap()] is attempting to establish a jump bridge in [get_overmap().current_system]. Incursion underway", "WhiteRapids EAS", 'nsv13/sound/effects/ship/lighthouse_alarm.ogg')
	set_active(TRUE)
	next_activation = world.time + 7 MINUTES

/**
* Lets the captain customize the feel and role of their ship.
*/
/datum/ship_loadout
	var/name = "Evenly distribute power amongst core systems"
	var/desc = "Reroutes power to core systems, sacrificing any and all special modules. This will net a sizeable improvement to all the general stats of a ship (health, maneuverability)"

/datum/ship_loadout/proc/apply(obj/structure/overmap/OM)
	if(!OM)
		return FALSE
	OM.max_integrity *= 2
	OM.obj_integrity = OM.max_integrity
	OM.forward_maxthrust *= 1.25
	OM.backward_maxthrust *= 1.25
	OM.side_maxthrust *= 1.25
	OM.max_angular_acceleration *= 1.25
	return TRUE

/datum/ship_loadout/stealth
	name = "Stealth Drive"
	desc = "Scans have detected an inactive sensor disrupting device aboard this vessel. Activate it to mask the ship's signature from DRADIS (except at close range) and use any excess unallocated power to make the ship more maneuverable in combat and slightly more robust. This module will turn your ship into an extremely effective alpha strike platform, and allow you to slip out of combat when damaged. WARNING: Firing while cloaked will disrupt the cloak temporarily."

/datum/ship_loadout/stealth/apply(obj/structure/overmap/OM)
	if(!OM)
		return FALSE
	OM.max_integrity *= 1.25
	OM.obj_integrity = OM.max_integrity
	OM.cloak_factor = 100
	OM.forward_maxthrust *= 1.15
	OM.backward_maxthrust *= 1.15
	OM.side_maxthrust *= 1.15
	OM.max_angular_acceleration *= 1.15
	OM.handle_cloak(TRUE)
	return TRUE

/datum/ship_loadout/interceptor
	name = "Experimental Engine Modifications"
	desc = "Scans have identified an experimental speed-enhancing manifold as well as a prototype FTL drive modification in the powergrid. Activate it to vastly increase ship maneuverability and transit speed whilst also allowing the FTL computer to automatically spool itself between jumps. This module will allow you to reach targets much more quickly, and increase your maneuverability and speed substantially, though no excess power will be left for structural reinforcement."

/datum/ship_loadout/interceptor/apply(obj/structure/overmap/OM)
	if(!OM)
		return FALSE
	OM.forward_maxthrust *= 1.5
	OM.backward_maxthrust *= 1.5
	OM.side_maxthrust *= 1.5
	OM.speed_limit *= 1.5
	OM.max_angular_acceleration *= 1.5
	OM.ftl_drive.auto_spool = TRUE //Lazy sods, but yes this is a very valid option if you want to annoy NT.
	return TRUE

/obj/item/ship_loadout_selector
	name = "Ship loadout selector"
	desc = "A device which can reroute power to certain ship systems and even power up previously unactivated ones!. Click it in your hand to choose a loadout for your ship."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	req_one_access_txt = "150"
	var/list/loadouts = list()

/obj/item/ship_loadout_selector/Initialize()
	. = ..()
	for(var/theType in typecacheof(/datum/ship_loadout))
		loadouts += new theType

/obj/item/ship_loadout_selector/attack_self(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	ui_interact(user)

/obj/item/ship_loadout_selector/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state=GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ShipLoadout", "Ship Loadout Selection", 500, 500, master_ui, state)
		ui.open()

/obj/item/ship_loadout_selector/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/categories = list()
	for(var/datum/ship_loadout/SL in loadouts)
		var/list/info = list()
		info["name"] = SL.name
		info["desc"] = SL.desc
		info["id"] = "\ref[SL]"
		categories[++categories.len] = info
	data["categories"] = categories
	return data

/obj/item/ship_loadout_selector/ui_act(action, params)
	. = ..()
	if(!loc.get_overmap()) //Piss off then.
		return FALSE
	var/datum/ship_loadout/target = locate(params["target_id"])
	if(!target)
		return FALSE
	if(alert("Are you sure you want to select [target]?",name,"Yes","No") == "Yes")
		if(target.apply(loc.get_overmap()))
			qdel(src)

//Allows you to specify a delivery destination for traders.
/obj/structure/overmap
	var/list/trader_beacons = null

/obj/effect/landmark/trader_drop_point
	name = "Trader sending target"

/obj/effect/landmark/trader_drop_point/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/trader_drop_point/LateInitialize()
	..()
	addtimer(CALLBACK(src, .proc/add_to_ship), 1 MINUTES)

/obj/effect/landmark/trader_drop_point/proc/add_to_ship()
	LAZYADD(get_overmap()?.trader_beacons, src)

/area/bridge/pvp
	name = "Syndicate Bridge"

/area/bridge/pvp/secondary
	name = "Syndicate Battle Bridge"

/area/bridge/meeting_room/pvp
	name = "Syndicate Meeting Room"

/area/hallway/pvp
	name = "Syndicate Primary Hallway"

/area/crew_quarters/bar/pvp
	name = "Syndicate Bar"

/area/crew_quarters/cafeteria/pvp
	name = "Syndicate Cafeteria"

/area/hydroponics/pvp
	name = "Syndicate Hydroponics"

/area/ai_monitored/nuke_storage/pvp
	name = "Syndicate vault"

/area/medical/medbay/pvp
	name = "Syndicate Medbay"

/area/nsv/weapons/pvp
	name = "Syndicate Munitions"

/area/nsv/hanger/pvp
	name = "Syndicate Hangar"

/area/nsv/hanger/pvp/marine
	name = "Syndicate Marine Hangar"

/area/security/brig/pvp
	name = "Syndicate Brig"

/area/engine/engineering/pvp
	name = "Syndicate Engineering"

/area/engine/engine_room/pvp
	name = "Syndicate Reactor Core"

/area/quartermaster/pvp
	name = "Syndicate Requisitions Bay"

/area/science/pvp
	name = "Syndicate Science Wing"

/area/science/robotics/pvp
	name = "Syndicate Robotics"

/area/crew_quarters/pvp
	name = "Syndicate Quarters"

/area/crew_quarters/toilet/pvp
	name = "Syndicate Toilets"
/area/crew_quarters/heads/hor/pvp
	name = "Syndicate Research Office"

/area/crew_quarters/heads/hos/pvp
	name = "Syndicate HOS Office"

/area/crew_quarters/heads/chief/pvp
	name = "Syndicate CE Office"

/area/crew_quarters/heads/captain/pvp
	name = "Syndicate Captain's Office"

/area/crew_quarters/heads/captain/pvp/admiral
	name = "Syndicate Admiral's Office"

/area/maintenance/pvp
	name = "Syndicate Maintenance"

/obj/machinery/camera/syndicate
	name = "syndicate tactical camera"
	network = list("syndicate")

/obj/machinery/camera/syndicate/autoname
