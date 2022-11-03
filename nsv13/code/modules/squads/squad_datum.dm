/datum/squad
	var/name = ""
	var/desc = "nope"
	var/role = null
	var/tracking_id = null // for use with SSdirection
	var/colour = null //colour for helmets, etc.
	var/list/access = list() //Which special access do we grant them during GQ
	var/access_enabled = FALSE //Is this squad's access enabled or not?
	var/hidden = FALSE //Can you join this squad by default?
	var/lowpop_retasked = FALSE //Have we already given this squad a job? Don't pull them off of it. Only used when we're filling empty jobs at roundstart.

	//Positions...

	var/mob/living/carbon/human/leader

	var/list/members = list()
	var/max_members = 5

	var/primary_objective = null //Text strings
	var/secondary_objective = null
	var/list/disallowed_jobs = list(/datum/job/ai, /datum/job/cyborg, \
		/datum/job/captain, /datum/job/head_of_personnel, /datum/job/bridge, \
		/datum/job/master_at_arms, /datum/job/pilot, /datum/job/munitions_tech, /datum/job/air_traffic_controller, \
		/datum/job/head_of_security, /datum/job/warden, /datum/job/security_officer, \
		/datum/job/chief_medical_officer, /datum/job/medical_doctor, /datum/job/paramedic, /datum/job/brig_physician, \
		/datum/job/chief_engineer, /datum/job/station_engineer, /datum/job/atmospheric_technician, \
		/datum/job/assistant)
	var/list/allowed_jobs = null
	var/datum/component/simple_teamchat/radio_dependent/squad/squad_channel = null
	var/squad_channel_type
	var/weapons_clearance = FALSE //Are they cleared for firearms?

/datum/squad/New()
	. = ..()
	generate_channel()

/datum/squad/proc/generate_channel()
	message_admins("/datum/component/simple_teamchat/radio_dependent/squad/[name]")
	squad_channel_type = text2path("/datum/component/simple_teamchat/radio_dependent/squad/[name]") //This is OOP sin.
	squad_channel = AddComponent(squad_channel_type, override = TRUE)
	squad_channel.squad = src

/datum/squad/proc/retask(task)
	if(role == task)
		return
	LAZYREMOVEASSOC(GLOB.squad_manager.role_squad_map, role, src)
	role = task
	LAZYADDASSOCLIST(GLOB.squad_manager.role_squad_map, role, src)
	broadcast(src, "NEW ASSIGNMENT: [role]", list('nsv13/sound/effects/notice2.ogg'))
	primary_objective = GLOB.squad_manager.role_objective_map[role]
	access = GLOB.squad_manager.role_access_map[role]

/**
	Checks your access.
*/
/datum/squad/proc/GetAccess()
	return (access_enabled) ? access : list()

/datum/squad/proc/broadcast(mob/living/carbon/human/sender, message, list/sounds)
	if(length(message) > squad_channel.max_message_length)
		to_chat(usr, "<span class='warning'>Your message \"[message]\" of [length(message)] characters exceeded maximum length of [squad_channel.max_message_length].</span>")
		return FALSE
	squad_channel.send_message(sender, message, sounds)

//Joining squads, registering people to squads.
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

/datum/squad/proc/add_member(mob/living/carbon/human/H, give_items=FALSE)
	if(!ishuman(H))
		return FALSE

	members += H

	if(leader)
		var/myRank = H.compose_rank()
		var/theirRank = leader.compose_rank()
		if(check_rank_pecking_order(myRank, theirRank))
			leader = H
	else //First one in
		leader = H

	equip(H, give_items)
	handle_hud(H, TRUE)

	to_chat(H, "<span class='sciradio'>You are a member of [name] squad! \n[desc] \n[primary_objective]</span>")
	to_chat(H, "<span class='sciradio'>[primary_objective]</span>")
	if(secondary_objective)
		to_chat(H, "<span class='sciradio'>[secondary_objective]</span>")
	broadcast(src,"[H.name] assigned to squad.", list('nsv13/sound/effects/notice2.ogg'))


/datum/squad/proc/remove_member(mob/living/carbon/human/H)
	handle_hud(H, FALSE)
	//If we're changing into a new squad.
	if(H.squad == src)
		H.squad = null
	members -= H
	if(leader == H)
		unset_leader()
		assign_leader()
	broadcast(src,"[H.name] removed from squad.", list('nsv13/sound/effects/notice2.ogg')) //Change order of this when done testing.

/datum/squad/proc/assign_leader()
	//Whoever ranks highest is in charge
	if(!length(members))
		return
	var/mob/living/carbon/human/highest = members[1]
	for(var/mob/living/carbon/human/H in members)
		if(check_rank_pecking_order(H.compose_rank(), highest.compose_rank()))
			highest = H
	if(highest != leader)
		unset_leader()
		set_leader(highest)

/datum/squad/proc/equip(mob/living/carbon/human/H, give_items)
	var/datum/squad/oldSquad = H.squad
	H.squad = src
	oldSquad?.remove_member(H)

	//If they're a new-spawn, give them their gear.
	if(give_items)
		var/obj/item/storage/backpack/bag = H.get_item_by_slot(ITEM_SLOT_BACK)
		new /obj/item/squad_pager(bag, src)
		new /obj/item/clothing/neck/squad(bag, src)

/datum/squad/proc/set_leader(mob/living/carbon/human/H)
	if(leader && leader != H)
		unset_leader()
	leader = H
	if(!(LAZYFIND(members, H)))
		add_member(H)
	to_chat(H, "<span class='sciradio'>You are the squad leader of [name] Squad!. You have authority over the members of this squadron, and may direct them as you see fit. In general, you should use your squad members to help you repair damaged areas during general quarters</span>")
	broadcast(src,"[leader.name] assigned as squad leader.", list('nsv13/sound/effects/notice2.ogg'))

/datum/squad/proc/unset_leader(mob/living/carbon/human/H)
	if(!leader || (H && H != leader))
		return
	if(!H && leader) //No leader passed in but we need to demote the current one
		H = leader
	to_chat(H, "<span class='warning'>You have been demoted from your position as [name] Squad Lead.</span>")
	broadcast(src,"[H] demoted from squad lead.", list('nsv13/sound/effects/notice2.ogg'))
	leader = null

/datum/squad/able
	name = "Able"
	desc = "Able squad is the ship's high-alert squad. Able Squad can be activated to commandeer enemy vessels or deal with threats, though by default they are expected to help with combat repairs."
	role = DC_SQUAD
	colour = "#e61919"

/datum/squad/baker
	name = "Baker"
	desc = "Baker squad is the ship's reservist squad. They specialise in search-and-rescue and emergency medical care."
	role = MEDICAL_SQUAD
	colour = "#4148c8"

//Backup squads for the XO to use.

/datum/squad/charlie
	name = "Charlie"
	desc = "Charlie squad is the ship's secondary engineering squad. They are usually activated during complex boarding operations when Able becomes overcrowded."
	role = DC_SQUAD
	colour = "#ffc32d"

/datum/squad/duff
	name = "Duff"
	desc = "Duff squad is comprised of conscripts and deserters. While they're a band of rogues, they can be useful when munitions is understaffed. Give them access to weapons at your own risk."
	role = MUNITIONS_SUPPORT
	colour = "#c864c8"
