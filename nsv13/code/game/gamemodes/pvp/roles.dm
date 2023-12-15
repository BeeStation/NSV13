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

/datum/syndicate_job_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/syndicate_job_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SyndieJobSelect")
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
	banning_key = ROLE_SYNDI_CREW
	tips = "galactic_conquest"
	give_objectives = FALSE //Their objective is to win the game

/datum/antagonist/nukeop/syndi_crew/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are a crewman aboard a Syndicate vessel!</span>")
	to_chat(owner, "<span class='warning'>Ensure the destruction of [station_name()], no matter what. Eliminate Nanotrasen's presence in the Abassi Ridge before they can establish a foothold. The fleet is counting on you!</span>")
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
	var/count = 0
	var/max_count = 1 //What's the player limit on this role?

/datum/syndicate_crew_role/proc/assign(datum/mind/candidate)
	if(count >= max_count)
		return FALSE
	count ++
	candidate.add_antag_datum(antag_datum_type)
	return TRUE

//Priority 1: Captain. We _always_ need a captain! Anything from this point on is in DESCENDING ORDER of priority! With autofill being the absolute last.

/datum/syndicate_crew_role/captain
	name = "Syndicate Captain"
	desc = "Wield the might of an advanced Syndicate battlecruiser and ensure Nanotrasen's presence in this sector is severely diminished. Primary duties: Lead the ship into battle, coordinate with the strategist and enact any maneuvers they see fit, outperform your Nanotrasen counterpart."
	preference_flag = CONQUEST_ROLE_CAPTAIN
	antag_datum_type = /datum/antagonist/nukeop/leader/syndi_crew

//Special behaviour for assigning the captain. Ensures that the nuke team is always ready.
/datum/syndicate_crew_role/captain/assign(datum/mind/candidate)
	if(count >= max_count)
		return FALSE
	count ++
	var/datum/antagonist/nukeop/L = candidate.add_antag_datum(antag_datum_type)
	var/datum/game_mode/pvp/theGame = SSticker.mode
	if(istype(theGame))
		theGame.nuke_team = L.nuke_team
	return TRUE

//Syndicate ID card that isn't the agent card for the crew
/obj/item/card/id/syndi_crew
	name = "\improper Syndicate ID Card"
	icon_state = "syndicate"
	item_state = "syndicate_id"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE)
	assignment = "Crew"

/obj/item/card/id/syndi_crew/captain
	name = "\improper Captain's ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_ENGINEERING, ACCESS_SYNDICATE_REQUISITIONS, ACCESS_SYNDICATE_MARINE_ARMOURY)
	assignment = JOB_NAME_CAPTAIN

/obj/item/card/id/syndi_crew/admiral
	name = "\improper Strategist's ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_ENGINEERING, ACCESS_SYNDICATE_REQUISITIONS, ACCESS_SYNDICATE_MARINE_ARMOURY)
	assignment = "Strategist"

/obj/item/card/id/syndi_crew/requisitions_officer
	name = "\improper Requisitions Officer's ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_REQUISITIONS)
	assignment = "Requisitions Officer"

/obj/item/card/id/syndi_crew/bridge
	name = "\improper Bridge Crew's ID"
	assignment = "Bridge Crew"

/obj/item/card/id/syndi_crew/technician
	name = "\improper Ship Technician's ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_ENGINEERING)
	assignment = "Ship Technician"

/obj/item/card/id/syndi_crew/cag
	name = "\improper Commander Air Group's ID"
	assignment = "Commander Air Group"

/obj/item/card/id/syndi_crew/pilot
	name = "\improper Pilot's ID"
	assignment = JOB_NAME_PILOT

/obj/item/card/id/syndi_crew/marine_sergeant
	name = "\improper Marine Sergeant's ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_MARINE_ARMOURY)

/obj/item/card/id/syndi_crew/chef
	name = "\improper Line Cook's ID"
	assignment = "Line Cook"

/obj/item/card/id/syndi_crew/marine
	name = "\improper Marine's ID"
	assignment = JOB_NAME_ASSISTANT

//Syndicate crew outfits

/datum/outfit/syndicate/no_crystals/syndi_crew/post_equip(mob/living/carbon/human/H)
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_SYNDICATE)
	R.freqlock = TRUE
	if(command_radio)
		R.command = TRUE
	H.faction += "Syndicate"
	var/obj/item/card/id/W = H.wear_id
	implants = list(/obj/item/implant/weapons_auth)
	W.registered_name = H.real_name
	W.update_label()

/datum/antagonist/nukeop/leader/syndi_crew
	name = "Syndicate captain"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/leader
	tips = "galactic_conquest"

/datum/outfit/syndicate/no_crystals/syndi_crew/leader
	name = "Syndicate Captain"
	id = /obj/item/card/id/syndi_crew/captain
	r_hand = /obj/item/ship_loadout_selector
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	neck = /obj/item/clothing/neck/cloak/syndcap
	//r_hand = /obj/item/nuclear_challenge //Not made my mind up on this one yet...
	head = /obj/item/clothing/head/helmet/space/beret
	suit = /obj/item/clothing/suit/space/officer
	backpack_contents = list(
		/obj/item/storage/box/syndie = 1,
		/obj/item/kitchen/knife/combat/survival = 1
	)
	command_radio = TRUE
	implants = list()
	uplink_type = null //Nope :) Go to the req officer you ungas.

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
	addtimer(CALLBACK(src, PROC_REF(nuketeam_name_assign)), 1)
	owner.announce_objectives()

//Syndicate crew roles, defined in order of priority.
/datum/syndicate_crew_role/strategist
	name = "Syndicate Strategist"
	desc = "Syndicate strategists are specialist admirals assigned to assist Captains with making tactical decisions in the heat of battle. Although the captain has the final say in decisions, your job is to think strategically and suggest possible strategies to the crew."
	preference_flag = CONQUEST_ROLE_ADMIRAL
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/strategist
	essential = FALSE

/datum/antagonist/nukeop/syndi_crew/strategist
	name = "Syndicate Strategist"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/strategist
	banning_key = ROLE_SYNDI_CREW

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
	command_radio = TRUE
	id = /obj/item/card/id/syndi_crew/admiral

/datum/antagonist/nukeop/syndi_crew/strategist/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are a Syndicate Strategist!</span>")
	to_chat(owner, "<span class='warning'>You have been assigned to oversee the operations of an advanced Syndicate cruiser. Despite your rank of admiral, you serve solely as an advisor to the captain, and can dictate strategy or suggested approaches, however you serve on their ship and are not to overrule them.</span>")
	owner.announce_objectives()

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

/datum/outfit/syndicate/no_crystals/syndi_crew/requisitions
	name = "Syndicate requisitions officer"
	head = /obj/item/clothing/head/soft/assistant_soft
	suit = /obj/item/clothing/suit/ship/syndicate_crew/syndicate_requisitions
	glasses = /obj/item/clothing/glasses/meson/engine
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/utility/full/engi
	uniform = /obj/item/clothing/under/ship/syndicate_tech
	id = /obj/item/card/id/syndi_crew/requisitions_officer
	l_pocket = /obj/item/card/id/departmental_budget/syndicate

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
	id = /obj/item/card/id/syndi_crew/bridge

/datum/syndicate_crew_role/technician
	name = "Syndicate Technician"
	desc = "Shipside techs are engineers who specialise in supplying a ship with power, maintaining its weapons, and launching its fighters."
	preference_flag = CONQUEST_ROLE_TECHNICIAN
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/technician
	max_count = 4

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
	id = /obj/item/card/id/syndi_crew/technician

/datum/syndicate_crew_role/cag
	name = "Syndicate CAG"
	desc = "The commander of air group leads the air assault wing into battle. The pilots all look to you for orders, so stay frosty, however you'll often find yourself performing ATC duties if there are no techs available."
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
	id = /obj/item/card/id/syndi_crew/cag

/datum/syndicate_crew_role/pilot
	name = "Syndicate Fighter Pilot"
	desc = "Syndicate fighter pilots have shorter average life expectancies than WW1 biplane pilots and are assigned to fly the Syndicate's fighter jets in close air support of their carrier ship under the command of the CAG."
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
	id = /obj/item/card/id/syndi_crew/pilot

/datum/syndicate_crew_role/sergeant
	name = "Syndicate Marine Sergeant"
	desc = "Syndicate Sergeants lead Syndicate shipside security forces in repelling boarders, or conducting sabotage against enemy ships. This role coordinates with requisitions to arm up boarding parties, or enforce ship law."
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
	id = /obj/item/card/id/syndi_crew/marine_sergeant

/datum/syndicate_crew_role/clown
	name = "Syndicate Clown"
	desc = "Because what ship would be complete without its beloved clown. Keep the crew entertained through wacky exploits, and turn into a hyper-competent killing machine when called upon."
	preference_flag = CONQUEST_ROLE_CLOWN
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/clown
	essential = FALSE //No, just no

/datum/antagonist/nukeop/syndi_crew/clown
	name = "Syndicate Clown"
	nukeop_outfit = /datum/outfit/syndicate/clownop/no_crystals/jojo_reference
	banning_key = ROLE_SYNDI_CREW

/datum/antagonist/nukeop/syndi_crew/clown/give_alias()
	owner.current.fully_replace_character_name(owner.current.real_name, owner.current.client.prefs.active_character.custom_names["clown"])

/datum/outfit/syndicate/clownop/no_crystals/jojo_reference
	name = "Syndicate Clown (Jojo Reference)"
	suit = /obj/item/clothing/suit/ship/delinquent
	head = /obj/item/clothing/head/delinquent

/datum/syndicate_crew_role/line_cook
	name = "Syndicate Line Cook"
	desc = "Syndicate line cooks are non-combat personnel who ensure that the crew stays fed and morale is high. Unlike your NT counterpart, Syndicate cooks also get free reign of botany and the bar and are expected to be self sufficient in feeding and maintaining the crew's welfare."
	preference_flag = CONQUEST_ROLE_LINECOOK
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/line_cook
	essential = FALSE

/datum/antagonist/nukeop/syndi_crew/line_cook
	name = "Syndicate Line Cook"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/line_cook

/datum/outfit/syndicate/no_crystals/syndi_crew/line_cook
	name = "Syndicate Line Cook"
	head = /obj/item/clothing/head/chefhat
	suit = /obj/item/clothing/suit/ship/syndicate_crew
	uniform = /obj/item/clothing/under/rank/civilian/chef
	id = /obj/item/card/id/syndi_crew/chef

/datum/syndicate_crew_role/marine
	name = "Autofill"
	desc = "Let the game randomly assign you to a job. This usually relegates you to doing grunt security or boarding work under the Sergeant!"
	preference_flag = CONQUEST_ROLE_GRUNT
	antag_datum_type = /datum/antagonist/nukeop/syndi_crew/marine
	max_count = INFINITY

/obj/item/clothing/suit/space/syndicate/odst/marine
	icon_state = "syndiemarine"
	item_state = "syndiemarine"

/obj/item/clothing/head/helmet/space/syndicate/odst/marine
	icon_state = "syndiemarine"
	item_state = "syndiemarine"

/datum/antagonist/nukeop/syndi_crew/marine
	name = "Syndicate Marine"
	nukeop_outfit = /datum/outfit/syndicate/no_crystals/syndi_crew/marine

/datum/outfit/syndicate/no_crystals/syndi_crew/marine
	name = "Syndicate Grunt"
	head = /obj/item/clothing/suit/space/syndicate/odst/marine
	mask = /obj/item/clothing/mask/gas/syndicate
	suit = /obj/item/clothing/head/helmet/space/syndicate/odst/marine
	uniform = /obj/item/clothing/under/ship/pilot/syndicate
	id = /obj/item/card/id/syndi_crew/marine

//Allows you to see faction statuses
/mob/proc/get_stat_tab_faction()
	var/list/tab_data = list()
	for(var/datum/faction/F in SSstar_system.factions)
		if(F) //No nulls!
			tab_data["[F.name]"] = list(
				text = "[F.tickets]",
				type = STAT_TEXT
			)
	return tab_data

/datum/team/nuclear/roundend_report()
	if(istype(SSticker.mode, /datum/game_mode/pvp))
		var/datum/game_mode/pvp/mode = SSticker.mode
		var/list/parts = list()
		parts += "<span class='header'>[syndicate_name] Crewmen:</span>"

		var result = get_result()
		//First off, did they manage to nuke the ship?
		if(result == NUKE_RESULT_NUKE_WIN)
			parts += "<span class='greentext big'>Syndicate Major Victory!</span>"
			parts += "<b>The crew of [station_name()] were annihilated by [syndicate_name] operatives in nuclear hellfire.</b>"
		else
			switch(mode.winner.id)
				if(FACTION_ID_NT)
					parts += "<span class='redtext big'>Nanotrasen Major Victory!</span>"
					parts += "<b>The crew of [station_name()] were able to put a stop to the SSV Nebuchadnezzar's efforts of galactic conquest, weakening the Syndicate's position in the Abassi Ridge.</b>"

				if(FACTION_ID_PIRATES)
					parts += "<span class='greentext'>Pirate Major Victory!</span>"
					parts += "<b>The Tortuga Raiders were able to use the chaos created by the Syndicate to establish a strong footing in the Abassi ridge.</b>"

				if(FACTION_ID_SYNDICATE)
					parts += "<span class='greentext big'>Syndicate Victory!</span>"
					parts += "<b>The crew of the SSV Nebuchadnezzar were able to weaken NT's presence in the Abassi ridge significantly!</b>"
				//Default victory for undefined factions.
				else
					parts += "<span class='redtext'>Stalemate!</span>"
					parts += "<b>[mode.winner] was able to secure the most influence, NT and the Syndicate took equal casualties.</b>"


		var/text = "<br><span class='header'>The syndicate crewmen were:</span>"
		var/purchases = ""
		var/TC_uses = 0
		LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
		for(var/I in members)
			var/datum/mind/syndicate = I
			var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[syndicate.key]
			if(H)
				TC_uses += H.total_spent
				purchases += H.generate_render(show_key = FALSE)
		text += printplayerlist(members)
		text += "<br>"
		text += "(Syndicates used [TC_uses] TC) [purchases]"
		if(TC_uses == 0 && SSticker.mode.station_was_nuked && !operatives_dead())
			text += "<BIG>[icon2html('icons/badass.dmi', world, "badass")]</BIG>"

		parts += text

		return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

	else
		return ..()

/client/proc/create_syndie_job_icons()
	set name = "Generate syndicate crew icons"
	set category = "Mapping"
	var/icon/final = icon()
	var/mob/living/carbon/human/dummy/D = new(locate(1,1,1)) //spawn on 1,1,1 so we don't have runtimes when items are deleted
	D.setDir(SOUTH)
	for(var/job in subtypesof(/datum/syndicate_crew_role))
		var/datum/syndicate_crew_role/role = new job
		for(var/obj/item/I in D)
			qdel(I)
		randomize_human(D)
		var/datum/antagonist/nukeop/syndi_crew/foo = new role.antag_datum_type
		var/datum/outfit/O = new foo.nukeop_outfit
		O.equip(D)
		COMPILE_OVERLAYS(D)
		var/icon/I = icon(getFlatIcon(D), frame = 1)
		final.Insert(I, role.name)
	qdel(D)
	/*
	//Also add the x
	for(var/x_number in 1 to 4)
		final.Insert(icon('icons/mob/screen_gen.dmi', "x[x_number == 1 ? "" : x_number]"), "x[x_number == 1 ? "" : x_number]")
	*/
	fcopy(final, "nsv13/icons/mob/syndicate_roles.dmi")

#define DEPT_SYNDICATE 6

//Ultra stripped down ID console for assigning secondary ship accesses.
/obj/machinery/computer/secondary_ship_id_console
	name = "secondary ship ID console"
	circuit = /obj/item/circuitboard/computer/card/secondary_ship_id_console
	icon_screen = "idhos"
	light_color = LIGHT_COLOR_RED
	req_one_access = null //If this
	var/list/target_accesses = list() //Format: K = Title to display this access as, V = the access itself, as an assoc list.
	var/obj/item/card/id/modifying = null
	var/theme = "ntos"

/obj/machinery/computer/secondary_ship_id_console/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/card/id))
		if(!do_after(user, 0.5 SECONDS, target=src))
			return FALSE
		if(modifying)
			eject()
		modifying = I
		I.forceMove(src)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		return TRUE

/obj/machinery/computer/secondary_ship_id_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "SecondaryID")
	ui.open()

/obj/machinery/computer/secondary_ship_id_console/ui_data(mob/user)
	var/list/data = list()
	var/list/accessData = list()
	for(var/title in target_accesses)
		var/access = target_accesses[title]
		accessData[++accessData.len] = list("title"=title, "access"=access, "hasAccess"=modifying && (access in modifying.access))
	data["theme"] = theme
	data["accessList"] = accessData
	data["modifying"] = (modifying) ? TRUE : FALSE
	return data

/obj/machinery/computer/secondary_ship_id_console/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("eject")
			eject()
		if("accessMod")
			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>You are not authorised to use this console.</span>")
				return FALSE
			var/access = text2num(params["access"])
			if(access in modifying.access)
				modifying.access -= access
			else
				modifying.access += access
			playsound(src, "terminal_type", 50, 0)
		if("modifyName")
			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>You are not authorised to use this console.</span>")
				return FALSE
			if(!modifying)
				return FALSE
			var/newName = stripped_input(usr, "Enter a new assigned name for this ID.", "[src]", null)
			if(!newName)
				return FALSE
			modifying.registered_name = newName
			modifying.update_label()
		if("modifyAssignment")
			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>You are not authorised to use this console.</span>")
				return FALSE
			if(!modifying)
				return FALSE
			var/newOccupation = stripped_input(usr, "Enter a new assigned job for this ID.", "[src]", null)
			if(!newOccupation)
				return FALSE
			modifying.assignment = newOccupation
			modifying.update_label()


/obj/machinery/computer/secondary_ship_id_console/proc/eject()
	if(!modifying)
		return FALSE
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	modifying.forceMove(get_turf(src))
	modifying = null

/obj/machinery/computer/secondary_ship_id_console/syndicate
	name = "Syndicate Navy ID console"
	target_accesses = list("General Syndicate Access" = ACCESS_SYNDICATE, "Syndicate Engineering" = ACCESS_SYNDICATE_ENGINEERING, "Syndicate Captain" = ACCESS_SYNDICATE_LEADER, "Syndicate Armoury" = ACCESS_SYNDICATE_MARINE_ARMOURY, "Syndicate Requisitions" = ACCESS_SYNDICATE_REQUISITIONS)
	req_one_access = list(ACCESS_SYNDICATE_LEADER) //Syndicate captain does the XO's job.
	theme = "syndicate"
	circuit = /obj/item/circuitboard/computer/card/secondary_ship_id_console/syndicate

/obj/machinery/computer/security/syndicate
	name = "Syndicate Camera Console"
	network = list("syndicate") //I hate all of you
	circuit = /obj/item/circuitboard/computer/security/syndicate
