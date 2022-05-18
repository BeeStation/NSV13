/datum/squad
	var/name = ""
	var/desc = "nope"
	var/id = null
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
		/datum/job/captain, /datum/job/hop, /datum/job/bridge, \
		/datum/job/master_at_arms, /datum/job/pilot, /datum/job/munitions_tech, /datum/job/air_traffic_controller, \
		/datum/job/hos, /datum/job/warden, /datum/job/officer, \
		/datum/job/cmo, /datum/job/doctor, /datum/job/emt, /datum/job/brig_phys, \
		/datum/job/chief_engineer, /datum/job/engineer, \
		/datum/job/assistant)
	var/list/allowed_jobs = null //Do you want this squad to be locked to one role?
	var/datum/component/simple_teamchat/radio_dependent/squad/squad_channel = null
	var/squad_channel_type
	var/weapons_clearance = FALSE //Are they cleared for firearms?

/datum/squad/New()
	. = ..()
	generate_channel()

/datum/squad/proc/generate_channel()
	var/stripped = replacetext(name, " Squad", "")
	squad_channel_type = text2path("/datum/component/simple_teamchat/radio_dependent/squad/[stripped]") //This is OOP sin.
	squad_channel = AddComponent(squad_channel_type)
	squad_channel.squad = src

/datum/squad/proc/retask(task)
	if(id == task)
		return
	id = task
	broadcast(src, "ATTENTION: Your squad has been re-assigned as a [id]. Report to squad vendors to obtain your new equipment.", list('nsv13/sound/effects/notice2.ogg'))
	primary_objective = GLOB.squad_manager.role_verb_map[id]
	access = GLOB.squad_manager.role_access_map[id]

/**
	Checks your access.
*/
/datum/squad/proc/GetAccess()
	return (access_enabled) ? access : list()

/datum/squad/proc/broadcast(mob/living/carbon/human/sender, message, list/sounds)
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
	var/my_exp = H.client?.calc_exp_type(EXP_TYPE_CREW) || 0
	if(my_exp > 1200)
		if(!leader)
			leader = H
	equip(H, give_items)
	handle_hud(H, TRUE)

	to_chat(H, "<span class='sciradio'>You are a member of [name] squad! \n[desc] \n[primary_objective]</span>")
	broadcast(src,"[H.name] has been assigned to your squad.", list('nsv13/sound/effects/notice2.ogg'))


/datum/squad/proc/remove_member(mob/living/carbon/human/H)
	handle_hud(H, FALSE)
	//If we're changing into a new squad.
	if(H.squad == src)
		H.squad = null
	broadcast(src,"[H.name] has been reassigned from your squad.", list('nsv13/sound/effects/notice2.ogg')) //Change order of this when done testing.

/datum/squad/proc/equip(mob/living/carbon/human/H, give_items)
	var/datum/squad/oldSquad = H.squad
	H.squad = src
	oldSquad?.remove_member(H)

	//If they're a new-spawn, give them their gear.
	if(give_items)
		var/obj/item/storage/backpack/bag = H.get_item_by_slot(ITEM_SLOT_BACK)
		new /obj/item/squad_pager(bag, src)
		new /obj/item/clothing/neck/squad(bag, src)

/datum/squad/able
	name = ABLE_SQUAD
	desc = "Able squad is the ship's marine squad. Able Squad can be activated to commandeer / loot enemy vessels, though by default they are expected to help munitions with wartime ship operation."
	id = DC_SQUAD
	colour = "#e61919"
	access = list(ACCESS_HANGAR, ACCESS_BRIG, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS)
	allowed_jobs = list(/datum/job/assistant)
	disallowed_jobs = list()

/datum/squad/baker
	name = BAKER_SQUAD
	desc = "Baker squad is the ship's reservist squad. They specialise in damage control and medical care, comprised mostly of engineering and medical specialists."
	id = MEDICAL_SQUAD
	colour = "#4148c8"
	access = list(ACCESS_MUNITIONS, ACCESS_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_ENGINE, ACCESS_EXTERNAL_AIRLOCKS)

//Backup squads for the XO to use.

/datum/squad/charlie
	name = CHARLIE_SQUAD
	desc = "Charlie squad is the ship's secondary marine squad. They are usually activated during highly complex boarding operations when Able becomes overcrowded."
	id = DC_SQUAD
	colour = "#ffc32d"
	access = list(ACCESS_HANGAR, ACCESS_BRIG, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS)
	hidden = TRUE

/datum/squad/duff
	name = DUFF_SQUAD
	desc = "Duff squad is comprised of conscripts and deserters. While they're a band of rogues, they can be useful when munitions is understaffed. Give them access to weapons at your own risk."
	id = MUNITIONS_SUPPORT
	colour = "#c864c8"
	access = list(ACCESS_MUNITIONS, ACCESS_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_ENGINE, ACCESS_EXTERNAL_AIRLOCKS)
	hidden = TRUE
