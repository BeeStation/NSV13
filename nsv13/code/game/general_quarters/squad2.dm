#define SQUAD_LEAD "Squad Leader"
#define SQUAD_SERGEANT "Squad Sergeant"
#define SQUAD_MARINE "Marine"
#define SQUAD_MEDIC "Squad Medic"
#define SQUAD_ENGI "Squad Engineer"
#define ALL_SQUAD_ROLES list(SQUAD_LEAD, SQUAD_MEDIC, SQUAD_ENGI, SQUAD_MARINE)

#define ABLE_SQUAD "Able"
#define BAKER_SQUAD "Baker"
#define CHARLIE_SQUAD "Charlie"
#define DUFF_SQUAD "Duff"

/**

Squads, revision 2!

Partial code used from TerraGov marine corps

*/

GLOBAL_DATUM_INIT(squad_manager, /datum/squad_manager, new)

/datum/squad_manager
	var/name = "Squad Manager"
	var/list/squads = list()
	var/list/specialisations = ALL_SQUAD_ROLES

/datum/squad_manager/proc/get_joinable_squad(datum/job/J)
	var/list/joinable = list()
	for(var/datum/squad/squad in squads)
		if(!squad.hidden)
			if(squad.disallowed_jobs)
				if(LAZYFIND(squad.disallowed_jobs, J.type))
					continue
			if(squad.allowed_jobs)
				if(!(LAZYFIND(squad.allowed_jobs, J.type)))
					continue
			joinable += squad
	return (joinable?.len) ? pick(joinable) : null

/datum/squad_manager/New()
	. = ..()
	for(var/_type in subtypesof(/datum/squad))
		squads += new _type()

/mob/living/carbon/human
	var/datum/squad/squad = null
	var/squad_role = null
	var/squad_rank = null

/datum/squad
	var/name = ""
	var/desc = "nope"
	var/id = null
	var/tracking_id = null // for use with SSdirection
	var/colour = null //colour for helmets, etc.
	var/list/access = list() //Which special access do we grant them during GQ
	var/access_enabled = FALSE //Is this squad's access enabled or not?
	var/hidden = FALSE //Can you join this squad by default?

	//Positions...

	var/mob/living/carbon/human/leader

	var/list/engineers = list()
	var/max_engineers = 1

	var/list/medics = list()
	var/max_medics = 2

	var/list/sergeants = list()
	var/max_sergeants = 2

	var/list/grunts = list()

	var/primary_objective = null //Text strings
	var/secondary_objective = null
	var/list/disallowed_jobs = list(/datum/job/captain, /datum/job/hop, /datum/job/ai, /datum/job/cyborg, /datum/job/munitions_tech, /datum/job/master_at_arms, /datum/job/pilot, /datum/job/air_traffic_controller, /datum/job/warden, /datum/job/hos, /datum/job/bridge, /datum/job/officer, /datum/job/assistant, /datum/job/doctor, /datum/job/engineer, /datum/job/chief_engineer)
	var/list/allowed_jobs = null //Do you want this squad to be locked to one role?
	var/datum/component/simple_teamchat/radio_dependent/squad/squad_channel = null
	var/squad_channel_type
	var/weapons_clearance = FALSE //Are they cleared for firearms?

/**
	Checks your access.
*/
/datum/squad/proc/GetAccess()
	return (access_enabled) ? access : list()

/datum/squad/proc/broadcast(mob/living/carbon/human/sender, message, list/sounds)
	squad_channel.send_message(sender, message, sounds)

/datum/squad/proc/generate_channel()
	var/stripped = replacetext(name, " Squad", "")
	squad_channel_type = text2path("/datum/component/simple_teamchat/radio_dependent/squad/[stripped]") //This is OOP sin.
	squad_channel = AddComponent(squad_channel_type)
	squad_channel.squad = src

//Joining squads, registering people to squads.

/datum/squad/New()
	. = ..()
	generate_channel()

/datum/hud/human
	var/atom/movable/screen/squad_lead_finder/squad_lead_finder = null

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	squad_lead_finder = new /atom/movable/screen/squad_lead_finder()
	squad_lead_finder.hud = src
	squad_lead_finder.alpha = 0
	squad_lead_finder.invisibility = INVISIBILITY_ABSTRACT
	infodisplay += squad_lead_finder

/atom/movable/screen/squad_lead_finder
	icon = 'nsv13/icons/mob/screen_squad.dmi'
	icon_state = "leadfinder"
	name = "Squad Lead Locator"
	desc = "Allows you to track your squad leader anywhere in the world!"
	screen_loc = "EAST-1:28,CENTER-4:10"
	var/datum/squad/squad = null
	var/mob/user = null
	var/mutable_appearance/pointer

/atom/movable/screen/squad_lead_finder/examine(mob/user)
	. = ..()
	if(squad && squad.leader)
		. += "<span class='warning'>Your squad leader is: [squad.leader.real_name]</span>"

/atom/movable/screen/squad_lead_finder/proc/set_squad(datum/squad/squad, mob/living/user)
	src.squad = squad
	src.user = user
	pointer = mutable_appearance(src.icon, "arrow")
	pointer.dir = dir
	add_overlay(pointer)
	START_PROCESSING(SSobj, src)

/atom/movable/screen/squad_lead_finder/Destroy()
	if(pointer)
		cut_overlay(pointer)
		QDEL_NULL(pointer)
	STOP_PROCESSING(SSobj, src)
	return ..()

/atom/movable/screen/squad_lead_finder/process()
	var/mob/SL = squad?.leader
	if(!SL)
		return
	var/turf/Q = get_turf(SL)
	var/turf/A = get_turf(user)
	if(Q.z != A.z) //Different Z-level.
		return
	var/Qdir = get_dir(user, Q)
	var/finder_icon = "arrow" //Overlay showed when adjacent to or on top of the queen!
	if(squad.leader == user)
		finder_icon = "youaretheleader"
	pointer.dir = Qdir
	pointer.icon_state = finder_icon

/datum/squad/proc/handle_hud(mob/living/carbon/human/H, add=TRUE)
	var/datum/atom_hud/HUD = GLOB.huds[DATA_HUD_SQUAD]
	var/datum/hud/human/hud_used = H.hud_used

	if(add)
		HUD.add_hud_to(H)

		if(hud_used && hud_used.squad_lead_finder)
			hud_used.squad_lead_finder.invisibility = FALSE
			hud_used.squad_lead_finder.alpha = 255
			hud_used.squad_lead_finder.set_squad(src, H)

	else
		HUD.remove_hud_from(H)
		if(hud_used && hud_used.squad_lead_finder)
			hud_used.squad_lead_finder.invisibility = INVISIBILITY_ABSTRACT
			hud_used.squad_lead_finder.alpha = 0
	//hud_used?.show_hud(hud_used?.hud_version)
	// H.squad_hud_set_squad()

/datum/squad/proc/remove_member(mob/living/carbon/human/H)
	handle_hud(H, FALSE)
	strip_role(H)
	//If we're changing into a new squad.
	if(H.squad == src)
		H.squad_rank = null
		H.squad = null
	broadcast(src,"[H.name] has been reassigned from your squad.", list('nsv13/sound/effects/notice2.ogg')) //Change order of this when done testing.

/datum/squad/proc/apply_squad_rank(mob/living/carbon/human/H, rank)
	var/Hrank = H.compose_rank(H)
	Hrank = replacetext(Hrank, " ", "")
	if(!check_rank_pecking_order(Hrank, rank))
		return FALSE
	H.squad_rank = rank //Promotion! Congrats.

/**
	Strips a role from the target, if it finds them in any squad subsections, removes them.
*/
/datum/squad/proc/strip_role(mob/living/carbon/human/H)
	H.squad_role = null
	H.squad_rank = null
	if(H == leader)
		leader = null
	if(LAZYFIND(engineers, H))
		engineers -= H
	if(LAZYFIND(medics, H))
		medics -= H
	if(LAZYFIND(sergeants, H))
		sergeants -= H
	if(LAZYFIND(grunts, H))
		grunts -= H

/datum/squad/proc/set_role(mob/living/carbon/human/H, role)
	switch(role)
		if(SQUAD_LEAD)
			if(leader)
				return FALSE
			strip_role(H)
			leader = H
			H.squad_role = SQUAD_LEAD
			apply_squad_rank(H, "LT")
		if(SQUAD_MEDIC)
			if(medics.len >= max_medics || LAZYFIND(medics, H))
				return FALSE
			strip_role(H)
			medics += H
			H.squad_role = SQUAD_MEDIC
			apply_squad_rank(H, "SLT")
		if(SQUAD_ENGI)
			if(engineers.len >= max_engineers || LAZYFIND(engineers, H))
				return FALSE
			strip_role(H)
			engineers += H
			H.squad_role = SQUAD_ENGI
			apply_squad_rank(H, "SLT")
		if(SQUAD_MARINE)
			if(LAZYFIND(grunts, H))
				return FALSE
			strip_role(H)
			grunts += H
			H.squad_role = SQUAD_MARINE
			apply_squad_rank(H, "PFC")
	// H.squad_hud_set_squad()
	broadcast(src,"[H.name] has been re-assigned to [H.squad_role].", list('nsv13/sound/effects/notice2.ogg')) //Change order of this when done testing.


/datum/squad/proc/add_member(mob/living/carbon/human/H, give_items=FALSE)
	if(!ishuman(H))
		return FALSE
	//Check for our specialisations...
	var/pref = H.client?.prefs?.squad_specialisation || SQUAD_MARINE
	switch(pref)
		if(SQUAD_LEAD)
			if(!leader)
				leader = H
				H.squad_role = SQUAD_LEAD
				apply_squad_rank(H, "LT") //Leftenant
		if(SQUAD_MEDIC)
			if(medics.len < max_medics)
				medics += H
				H.squad_role = SQUAD_MEDIC
				apply_squad_rank(H, "SLT") //Second LT
		if(SQUAD_ENGI)
			if(engineers.len < max_engineers)
				engineers += H
				H.squad_role = SQUAD_ENGI
				apply_squad_rank(H, "SLT") //Second LT
	//They didn't get their pref :(
	if(!H.squad_role)
		var/my_exp = H.client?.calc_exp_type(EXP_TYPE_CREW) || 0
		if(my_exp > 1200)
			if(sergeants.len < max_sergeants)
				sergeants += H
				H.squad_role = SQUAD_SERGEANT
				apply_squad_rank(H, "SGT") //Sergeant
		//They didn't make SGT.
		if(!H.squad_role)
			grunts += H
			H.squad_role = SQUAD_MARINE
			apply_squad_rank(H, "PFC") //Private first class
	equip(H, give_items)
	handle_hud(H, TRUE)

	var/blurb = "As a <b>Squad Marine</b> you are the most Junior member of any squad and are expected only to follow the orders of your superiors... \n <i>Sergeants</i>, <i>Specialists</i> and the <i>Squad Leader</i> all outrank you and you are expected to follow their orders."
	switch(H.squad_role)
		if(SQUAD_LEAD)
			blurb = "As a <b>Squad Leader</b> you hold the rank of Lieutenant. You have authority over your squad, and are responsible for organising the squad to complete objectives set by your superiors. <i>You answer to the XO and HoS directly, and must carry out their orders.</i>"
		if(SQUAD_MEDIC)
			blurb = "As a <b>Squad Medic</b> you are the Squad's frontline medic and are responsible for treating the wounds of your squadmates. You answer to the <i>Squad Sergeants</i>, failing them, the <i>Squad Leader</i> directly."
		if(SQUAD_ENGI)
			blurb = "As a <b>Squad Engineer</b> you are responsible for breaching enemy ships during boarding, or repairing your own ship during GQ. You answer to the <i>Squad Sergeants</i>, failing them, the <i>Squad Leader</i> directly."
		if(SQUAD_SERGEANT)
			blurb = "As a <b>Squad Sergeant</b>, you are a seasoned veteran with command experience and thus are outranked only by the squad leader. Your experience comes with the added duty of guiding and mentoring the PFCs, however in general your duties are the same as theirs. You answer to the <i>Squad Leader</i> directly."


	to_chat(H, "<span class='sciradio'>You are a [H.squad_role] in [name] squad! \n[desc] \n[blurb]</span>")

	broadcast(src,"[H.name] has been assigned to your squad as [H.squad_role].", list('nsv13/sound/effects/notice2.ogg')) //Change order of this when done testing.

/datum/atom_hud/data/human/squad_hud
	hud_icons = list(SQUAD_HUD)

/* /mob/living/carbon/human/proc/squad_hud_set_squad()
	var/image/holder = hud_list[SQUAD_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(squad && squad_role)
		holder.icon_state = "squad_[squad.name]_[squad_role]"
	else
		holder.icon_state = "hudno_id"
		if(wear_id?.GetID())
			holder.icon_state = "hud[ckey(wear_id.GetJobName())]" */

/datum/squad/proc/equip(mob/living/carbon/human/H, give_items)
	var/datum/squad/oldSquad = H.squad
	H.squad = src
	oldSquad?.remove_member(H)

	//If they're a new-spawn, give them their gear.
	if(give_items)
		var/obj/item/storage/backpack/bag = H.get_item_by_slot(ITEM_SLOT_BACK)
		new /obj/item/squad_pager(bag, src)
		new /obj/item/clothing/neck/squad(bag, src)
		/*
		switch(H.squad_role)
			if(SQUAD_LEAD)
				new /obj/item/clothing/head/ship/squad/leader(bag, src)
				new /obj/item/clothing/suit/ship/squad(bag, src)
				return TRUE
			if(SQUAD_MEDIC)
				new /obj/item/clothing/under/ship/marine/medic(bag, src)
			if(SQUAD_ENGI)
				new /obj/item/clothing/under/ship/marine/engineer(bag, src)
		new /obj/item/clothing/suit/ship/squad(bag, src)

		if(prob(75))
			new /obj/item/clothing/head/ship/squad(bag, src)
			return TRUE
		if(prob(25))
			new /obj/item/clothing/head/ship/squad/colouronly/cap(bag, src)
			return TRUE
		new /obj/item/clothing/head/ship/squad/colouronly/headband(bag, src)
		return TRUE
		*/

/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	addtimer(CALLBACK(src, .proc/register_squad, H), 5 SECONDS)

/datum/job/proc/register_squad(mob/living/H)
	if(!ishuman(H))
		return //No
	var/datum/squad/squad = GLOB.squad_manager.get_joinable_squad(src)
	squad?.add_member(H, give_items=TRUE)


/datum/squad/able
	name = ABLE_SQUAD
	desc = "Able squad is the ship's marine squad. Able Squad can be activated to commandeer / loot enemy vessels, though by default they are expected to help munitions with wartime ship operation."
	id = ABLE_SQUAD
	colour = "#e61919"
	access = list(ACCESS_HANGAR, ACCESS_BRIG, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS)
	allowed_jobs = list(/datum/job/assistant)
	disallowed_jobs = list()

/datum/squad/baker
	name = BAKER_SQUAD
	desc = "Baker squad is the ship's reservist squad. They specialise in damage control and medical care, comprised mostly of engineering and medical specialists."
	id = BAKER_SQUAD
	colour = "#4148c8"
	access = list(ACCESS_MUNITIONS, ACCESS_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_ENGINE, ACCESS_EXTERNAL_AIRLOCKS)
	max_engineers = 4
	max_medics = 4

//Backup squads for the XO to use.

/datum/squad/charlie
	name = CHARLIE_SQUAD
	desc = "Charlie squad is the ship's secondary marine squad. They are usually activated during highly complex boarding operations when Able becomes overcrowded."
	id = CHARLIE_SQUAD
	colour = "#ffc32d"
	access = list(ACCESS_HANGAR, ACCESS_BRIG, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS)
	hidden = TRUE

/datum/squad/duff
	name = DUFF_SQUAD
	desc = "Duff squad is comprised of conscripts and deserters. While they're a band of rogues, they can be useful when munitions is understaffed. Give them access to weapons at your own risk."
	id = DUFF_SQUAD
	colour = "#c864c8"
	access = list(ACCESS_MUNITIONS, ACCESS_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_ENGINE, ACCESS_EXTERNAL_AIRLOCKS)
	hidden = TRUE

//Show relevent squad info on status panel.

/mob/living/carbon/human/proc/get_stat_tab_squad()
	var/list/tab_data = list()

	if(!squad)
		tab_data["Assigned Squad"] = list(
			text = "None",
			type = STAT_TEXT
		)
		return tab_data

	tab_data["Assigned Squad"] = list(
			text = "[squad.name || "Unassigned"]",
			type = STAT_TEXT
		)
	tab_data["Squad Leader"] = list(
			text = "[squad.leader || "None"]",
			type = STAT_TEXT
		)
	tab_data["Primary Objective"] = list(
			text = "[squad.primary_objective || "None"]",
			type = STAT_TEXT
		)
	tab_data["Secondary Objective"] = list(
			text = "[squad.secondary_objective || "None"]",
			type = STAT_TEXT
		)
	return tab_data

/obj/machinery/computer/security/telescreen/squadcam
	name = "Squad Helmet Cam Monitor"
	network = list("squad_headcam")
