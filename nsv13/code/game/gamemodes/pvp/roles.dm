//SSV nebuchadnezzar?

/client/proc/select_syndie_role() //Lets you pick your Syndicate roles!
	set name = "Select Syndicate Role"
	set desc = "Set your syndicate role prefs"
	set category = "OOC"
	var/datum/syndicate_job_menu/js  = new(usr)//create the datum
	js.ui_interact(usr)//datum has a tgui component, here we open the window

/datum/syndicate_job_menu
	var/client/holder = null

/datum/syndicate_job_menu/New(H)//H can either be a client or a mob due to byondcode(tm)
	. = ..()
	if (istype(H,/client))
		var/client/C = H
		holder = C //if its a client, assign it to holder
	else
		return FALSE

/datum/syndicate_job_menu/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state=GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SyndieJobSelect", "Syndicate Job Selection", 500, 500, master_ui, state)
		ui.open()

/datum/syndicate_job_menu/ui_data(mob/user)
	var/list/data = list()
	var/client/C = (istype(user, /client)) ? user : user.client
	data["selected_role"] = C.prefs.preferred_syndie_role
	var/list/roles = list()
	for(var/datum/syndicate_crew_role/role in GLOB.conquest_role_handler.roles)
		var/list/role_info = list()
		role_info["name"] = role.name
		role_info["desc"] = role.desc
		role_info["id"] = "\ref[role]"
		roles[++roles.len] = role_info
	data["roles"] = roles
	return data

/datum/syndicate_job_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/datum/syndicate_crew_role/role = locate(params["role_id"])
	if(!role)
		return
	var/client/C = (istype(usr, /client)) ? usr : usr.client
	C.prefs.preferred_syndie_role = role.preference_flag
	C.prefs.save_preferences()

/datum/antagonist/nukeop/syndi_crew
	name = "Syndicate crew"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew
	job_rank = ROLE_SYNDI_CREW

/datum/antagonist/nukeop/syndi_crew/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are a crewman aboard a Syndicate vessel!</span>")
	to_chat(owner, "<span class='warning'>Ensure the destruction of [station_name()], no matter what. Eliminate Nanotrasen's presence in the Abassi ridge before they can establish a foothold. The fleet is counting on you!</span>")
	owner.announce_objectives()


/**
Singleton to handle conquest roles. This exists to populate the roles list and nothing else.
*/
/datum/conquest_role_handler
	var/list/roles = list()

/datum/conquest_role_handler/proc/get_job(slot)
	RETURN_TYPE(/datum/syndicate_crew_role)
	for(var/datum/syndicate_crew_role/role in roles)
		if(role.preference_flag == slot)
			return role

/datum/conquest_role_handler/New()
	. = ..()
	for(var/ctype in subtypesof(/datum/syndicate_crew_role))
		roles += new ctype()

//Example only, never instantiated.
/datum/syndicate_crew_role
	var/name = "Syndicate Shipside Crew"
	var/desc = "Do your job"
	var/preference_flag = null
	var/antag_datum_type = /datum/antagonist/nukeop/syndi_crew
	var/essential = TRUE //Does this role _need_ to be filled? 90% of them do!
	var/max_count = 1 //What's the player limit on this role?

/datum/syndicate_crew_role/proc/assign(datum/mind/candidate)
	candidate.add_antag_datum(antag_datum_type)

//Priority 1: Captain. We _always_ need a captain! Anything from this point on is in DESCENDING ORDER of priority! With autofill being the absolute last.

/datum/syndicate_crew_role/captain
	name = "Syndicate Captain"
	desc = "Wield the might of an advanced Syndicate battlecruiser and ensure Nanotrasen's presence in this sector is severely diminished. Primary duties: Lead the ship into battle, coordinate with the admiral and enact any maneuvers they see fit, outperform your Nanotrasen counterpart."
	preference_flag = CONQUEST_ROLE_CAPTAIN
	antag_datum_type = /datum/antagonist/nukeop/leader/syndi_crew

//Special behaviour for assigning the captain. Ensures that the nuke team is always ready.
/datum/syndicate_crew_role/captain/assign(datum/mind/candidate)
	var/datum/antagonist/nukeop/L = candidate.add_antag_datum(antag_datum_type)
	var/datum/game_mode/pvp/theGame = SSticker.mode
	if(istype(theGame))
		theGame.nuke_team = L.nuke_team

/datum/antagonist/nukeop/leader/syndi_crew
	name = "Syndicate captain"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/leader

/datum/outfit/syndicate/no_crystals/syndi_crew/leader
	name = "Syndicate captain"
	id = /obj/item/card/id/syndicate/nuke_leader
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	neck = /obj/item/clothing/neck/cloak/syndcap
	//r_hand = /obj/item/nuclear_challenge //Not made my mind up on this one yet...
	head = /obj/item/clothing/head/helmet/space/beret
	suit = /obj/item/clothing/suit/space/officer
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
	/obj/item/kitchen/knife/combat/survival=1,)
	command_radio = TRUE
	implants = list()

/datum/antagonist/nukeop/leader/syndi_crew/give_alias()
	title = pick("Captain", "Commander", "Commodore")
	if(nuke_team && nuke_team.syndicate_name)
		owner.current.real_name = "[nuke_team.syndicate_name] [title]"
	else
		owner.current.real_name = "Syndicate [title]"

/datum/antagonist/nukeop/leader/syndi_crew/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are a [title] in the Syndicate navy. Your ship is a highly advanced modular battlecruiser, choose a ship loadout wisely, and consult with your crew! <br> You are second only to the <b>admiral</b>, but you have autonomy over the ship unless otherwise ordered.</span>")
	to_chat(owner, "<span class='warning'>Diminish Nanotrasen's presence in this sector by destroying NT fleets and claiming systems with your lighthouse beacon. Destruction of the [station_name()] via superstructure crit or nuclear detonation are also options. For Abassi!</span>")
	addtimer(CALLBACK(src, .proc/nuketeam_name_assign), 1)
	owner.announce_objectives()


//Syndicate crew roles, defined in order of priority.
/datum/syndicate_crew_role/strategist
	name = "Syndicate Strategist"
	desc = "Syndicate strategists are specialist admirals assigned to assist Captains with making tactical decisions in the heat of battle."
	preference_flag = CONQUEST_ROLE_ADMIRAL
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/strategist
	essential = FALSE

/datum/antagonist/nukeop/syndi_crew/strategist
	name = "Syndicate Strategist"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/strategist
	job_rank = ROLE_SYNDI_CREW

/datum/outfit/syndicate/no_crystals/syndi_crew/strategist
	name = "Syndicate Strategist"
	belt = /obj/item/storage/belt/sabre
	head = /obj/item/clothing/head/helmet/space/beret
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate/admiral
	suit_store = /obj/item/gun/ballistic/shotgun/automatic/pistol
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	neck = /obj/item/clothing/neck/cloak/syndadmiral
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	l_pocket = /obj/item/lighter
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	shoes = /obj/item/clothing/shoes/combat/swat
	backpack_contents = list(/obj/item/storage/box/survival=1,/obj/item/clipboard=1,/obj/item/ammo_box/shotgun_lethal=3)

/datum/antagonist/nukeop/syndi_crew/strategist/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are a Syndicate Strategist!</span>")
	to_chat(owner, "<span class='warning'>You have been assigned to oversee the operations of an advanced Syndicate cruiser. Despite your rank of admiral, you serve solely as an advisor to the captain, and can dictate strategy or suggested approaches, however you serve on their ship and are not to overrule them.</span>")
	owner.announce_objectives()

/datum/syndicate_crew_role/bridge
	name = "Syndicate Bridge Staff"
	desc = "Syndicate bridge operatives are responsible for flying the ship and eliminating enemy targets."
	preference_flag = CONQUEST_ROLE_BRIDGE
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/bridge
	max_count = 2

/datum/antagonist/nukeop/syndi_crew/bridge
	name = "Syndicate Bridge Staff"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/bridge

/datum/outfit/syndicate/no_crystals/syndi_crew/bridge
	name = "Syndicate Bridge Staff"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	suit = /obj/item/clothing/suit/ship/syndicate_crew
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/laceup

/datum/syndicate_crew_role/requisitions_officer
	name = "Syndicate Requisitions Officer"
	desc = "As the defacto master at arms / Quartermaster aboard Syndicate vessels, the requisitions officer is authorised to use the ship's budget to keep weaponry loaded and the crew effective. This is mostly done by communicating with traders."
	preference_flag = CONQUEST_ROLE_REQUISITIONS
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/requisitions_officer

/datum/antagonist/nukeop/syndi_crew/requisitions_officer
	name = "Syndicate requisitions officer"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/requisitions

/obj/item/clothing/suit/ship/syndicate_crew/syndicate_requisitions
	name = "Syndicate Requisitions Officer's Jacket"
	desc = "A suit worn by the man who decides whether the ship has enough budget to buy another fighter because you exploded yours."
	icon_state = "syndicate_requisitions"
	item_color = "syndicate_requisitions"

/datum/outfit/syndicate/no_crystals/syndi_crew/requisitions
	name = "Syndicate requisitions officer"
	head = /obj/item/clothing/head/soft/assistant_soft
	suit = /obj/item/clothing/suit/ship/syndicate_crew/syndicate_requisitions
	glasses = /obj/item/clothing/glasses/meson/engine
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/utility/full/engi
	uniform = /obj/item/clothing/under/ship/syndicate_tech
	id = /obj/item/card/id/syndicate/requisitions_officer

//Keeps the plebs outta req
/obj/item/card/id/syndicate/requisitions_officer/Initialize()
	access += ACCESS_SYNDICATE_REQUISITIONS
	. = ..()

/datum/syndicate_crew_role/technician
	name = "Syndicate Technician"
	desc = "Shipside techs are engineers who specialise in supplying a ship with power, maintaining its weapons, and launching its fighters."
	preference_flag = CONQUEST_ROLE_TECHNICIAN
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/technician
	max_count = 5

/datum/antagonist/nukeop/syndi_crew/technician
	name = "Syndicate technician"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/technician

/datum/outfit/syndicate/no_crystals/syndi_crew/technician
	name = "Syndicate technician"
	head = /obj/item/clothing/head/hardhat/red
	glasses = /obj/item/clothing/glasses/meson/engine
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/utility/full/engi
	uniform = /obj/item/clothing/under/ship/syndicate_tech
	id = /obj/item/card/id/syndicate/technician
//Keeps the plebs outta engi
/obj/item/card/id/syndicate/technician/Initialize()
	access += ACCESS_SYNDICATE_ENGINEERING
	. = ..()

/datum/syndicate_crew_role/cag
	name = "Syndicate CAG"
	desc = "The commander of air group leads the air assault wing into battle."
	preference_flag = CONQUEST_ROLE_CAG
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/cag

/datum/antagonist/nukeop/syndi_crew/cag
	name = "Syndicate CAG"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/cag

/datum/outfit/syndicate/no_crystals/syndi_crew/cag
	name = "Syndicate CAG"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	glasses = /obj/item/clothing/glasses/sunglasses
	suit = /obj/item/clothing/suit/ship/syndicate_crew
	uniform = /obj/item/clothing/under/ship/pilot/syndicate

/datum/syndicate_crew_role/pilot
	name = "Syndicate Fighter Pilot"
	desc = "The commander of air group."
	preference_flag = CONQUEST_ROLE_PILOT
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/pilot
	max_count = 4

/datum/antagonist/nukeop/syndi_crew/pilot
	name = "Syndicate Pilot"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/pilot

/datum/outfit/syndicate/no_crystals/syndi_crew/pilot
	name = "Syndicate Pilot"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	suit = /obj/item/clothing/suit/ship/syndicate_crew
	uniform = /obj/item/clothing/under/ship/pilot/syndicate

/datum/syndicate_crew_role/sergeant
	name = "Syndicate Marine Sergeant"
	desc = "Syndicate Sergeants lead Syndicate shipside security forces in repelling boarders, or conducting sabotage against enemy ships."
	preference_flag = CONQUEST_ROLE_SERGEANT
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/sergeant

/datum/antagonist/nukeop/syndi_crew/sergeant
	name = "Syndicate Sergeant"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/sergeant

/datum/outfit/syndicate/no_crystals/syndi_crew/sergeant
	name = "Syndicate Sergeant"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	mask = /obj/item/clothing/mask/gas/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	uniform = /obj/item/clothing/under/ship/pilot/syndicate

/datum/syndicate_crew_role/marine
	name = "Autofill"
	desc = "Let the game randomly assign you to a job. This usually relegates you to doing grunt security or boarding work under the Sergeant!"
	preference_flag = CONQUEST_ROLE_GRUNT
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/marine
	max_count = INFINITY

/obj/item/clothing/suit/space/syndicate/odst/marine
	icon_state = "syndiemarine"
	item_state = "syndiemarine"
	item_color = "syndiemarine"

/obj/item/clothing/head/helmet/space/syndicate/odst/marine
	icon_state = "syndiemarine"
	item_state = "syndiemarine"
	item_color = "syndiemarine"

/datum/antagonist/nukeop/syndi_crew/marine
	name = "Syndicate Marine"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/marine

/datum/outfit/syndicate/no_crystals/syndi_crew/marine
	name = "Syndicate Marine"
	head = /obj/item/clothing/suit/space/syndicate/odst/marine
	mask = /obj/item/clothing/mask/gas/syndicate
	suit = /obj/item/clothing/head/helmet/space/syndicate/odst/marine
	uniform = /obj/item/clothing/under/ship/pilot/syndicate
