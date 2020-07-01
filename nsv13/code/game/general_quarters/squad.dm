GLOBAL_LIST_INIT(squad_styling, list(list("Apples","#C73232", 5), list("Butter" , "#CFB52B", 5), list("Charlie" , "#AE4CCD", 5), list("Duff" , "#5998FF", INFINITY)))
GLOBAL_DATUM_INIT(squad_manager, /datum/squad_manager, new)
//"Enum" that lets you define squads. Format: Name, colour theming.

#define RADIO_SQUAD "squadcomm"
#define FREQ_SQUAD 1452

/datum/squad_manager
	var/name = "Squad Manager"
	var/list/squads = list()

/datum/squad_manager/New()
	. = ..()
	for(var/I = 1; I <= GLOB.squad_styling.len; I++){
		var/datum/squad/S = new /datum/squad()
		S.name = "[GLOB.squad_styling[I][1]] Squad"
		S.colour = GLOB.squad_styling[I][2]
		S.max_members = GLOB.squad_styling[I][3]
		squads += S
	}

/datum/squad/New()
	. = ..()
	radio_connection = SSradio.add_object(src, FREQ_SQUAD , RADIO_SQUAD)

/datum/squad_manager/proc/get_squad(name)
	for(var/datum/squad/S in squads){
		if(S.name == name){
			return S
		}
	}

/datum/squad_manager/proc/get_joinable_squad()
	for(var/datum/squad/S in squads){
		if(S.members.len && S.members.len >= S.max_members){
			continue
		}
		else{
			return S
		}
	}

#define DC_SQUAD "Damage Control Team"
#define MEDICAL_SQUAD "Medical Team"
#define SECURITY_SQUAD "Security Fireteam"
#define SQUAD_TYPES list(DC_SQUAD, MEDICAL_SQUAD, SECURITY_SQUAD)

/datum/squad
	var/name = "Squad"
	var/orders = "No standing orders"
	var/squad_type = DC_SQUAD
	var/list/members = list()
	var/max_members = 5
	var/mob/living/carbon/human/leader = null
	var/colour = null
	var/blurb = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
	As a <i>damage control party member</i> you are responsible for repairing the ship and ensuring that breaches are sealed, debris is cleared from the halls, and injured people are taken to the medical bay.<br/>\
	Although your assigned duty is damage control, you must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty <br/>\
	<i>Squad vendors</i> open up during General Quarters, and allow you to acquire a kit containing tarpaulins for closing breaches, basic tools, metal foam and a distinctive uniform to tell your squad members apart.</span>"
	var/datum/radio_frequency/radio_connection
	var/static/list/blacklist = list(/datum/job/captain, /datum/job/hop, /datum/job/chief_engineer, /datum/job/cargo_tech,/datum/job/mining, /datum/job/qm, /datum/job/ai, /datum/job/cyborg, /datum/job/munitions_tech, /datum/job/fighter_pilot, /datum/job/master_at_arms, /datum/job/rd, /datum/job/air_traffic_controller, /datum/job/warden, /datum/job/hos, /datum/job/officer, /datum/job/chief_engineer, /datum/job/bridge, /datum/job/deck_tech)

/datum/squad/proc/broadcast(msg, mob/living/carbon/human/sender, sound=pick('nsv13/sound/effects/radio1.ogg','nsv13/sound/effects/radio2.ogg'), isOverwatch=FALSE)
	var/isLead = sender == leader ? "Lead" : null
	if(isOverwatch)
		isLead = "Overwatch"
	var/isBold = isOverwatch || isLead
	var/display_name = "Overwatch"
	if(sender)
		display_name = "[sender.compose_rank(sender)] " + sender.name
	msg = "<span style=\"color:[colour];[isBold ? ";font-size:13pt" : ""]\"><b>\[[name][isLead ? " [isLead]\]" : "\]"] [display_name]</b> says, \"[msg]\"</span>"

	var/datum/signal/signal = new(list("message" = msg, "squad"=src.name, "sound"=sound))
	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, sender)
		to_chat(M, "[link] [msg]")
	radio_connection.post_signal(src, signal, filter = RADIO_SQUAD)

/mob/living/carbon/human
	var/datum/squad/squad = null

/datum/squad/proc/set_leader(mob/living/carbon/human/H)
	leader = H
	to_chat(H, "<span class='sciradio'>You are the squad leader of [name]!. You have authority over the members of this squadron, and may direct them as you see fit. In general, you should use your squad members to help you repair damaged areas during general quarters</span>")
	broadcast("[leader.name] has been assigned to your squad as leader.", null, 'nsv13/sound/effects/notice2.ogg') //Change order of this when done testing.
	for(var/mob/M in members)
		if(M == H)
			return
	src += H

/datum/squad/proc/unset_leader(mob/living/carbon/human/H)
	if(!leader || (H && H != leader))
		return
	if(!H && leader)
		H = leader
	to_chat(H, "<span class='warning'>You have been demoted from your position as [name] Lead.</span>")
	broadcast("[H] has been demoted from squad lead.", null, 'nsv13/sound/effects/notice2.ogg')
	leader = null

/datum/squad/proc/set_orders(orders)
	broadcast("New standing orders received: [orders]", null, 'nsv13/sound/effects/notice2.ogg')
	src.orders = orders

/datum/squad/proc/retask(task)
	if(squad_type == task)
		return
	squad_type = task
	broadcast("ATTENTION: Your squad has been re-assigned as a [squad_type]. Report to squad vendors to obtain your new equipment.", null, 'nsv13/sound/effects/notice2.ogg')
	switch(squad_type)
		if(DC_SQUAD)
			blurb = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a <i>damage control party member</i> you are responsible for repairing the ship and ensuring that breaches are sealed, debris is cleared from the halls, and injured people are taken to the medical bay.<br/>\
			Although your assigned duty is damage control, you must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty <br/>\
			<i>Squad vendors</i> open up during General Quarters, and allow you to acquire a kit containing tarpaulins for closing breaches, basic tools, metal foam and a distinctive uniform to tell your squad members apart.</span>"
		if(MEDICAL_SQUAD)
			blurb = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a <i>medical team member</i> you are responsible for providing basic field first-aid to injured crewmen. Once the patient is out of critical condition, bring them to the medical bay.<br/>\
			Although your assigned duty is medical aid, you must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty <br/>\
			<i>Squad vendors</i> open up during General Quarters, and allow you to acquire a kit containing tarpaulins for closing breaches, basic tools, metal foam and a distinctive uniform to tell your squad members apart.</span>"
		if(SECURITY_SQUAD)
			blurb = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a <i>security fireteam member</i> you are responsible for assisting security in repelling boarders, or by partaking in boarding action.<br/>\
			You must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty. <br/>\
			<i>Squad vendors</i> open up during General Quarters, and allow you to acquire a kit containing tarpaulins for closing breaches, basic tools, metal foam and a distinctive uniform to tell your squad members apart.</span>"

//Add a member to our squad.
/datum/squad/proc/operator+=(mob/living/carbon/human/H)
	to_chat(H, "<span class='boldnotice'>You have been assigned to [name]!</span>[blurb]</span>")
	members += H
	var/datum/squad/oldSquad = H.squad
	H.squad = src
	if(!oldSquad)
		var/obj/item/storage/backpack/bag = H.get_item_by_slot(SLOT_BACK)
		new /obj/item/squad_pager(bag, src)
		new /obj/item/clothing/neck/squad(bag, src)

//Remove a member from our squad.
/datum/squad/proc/operator-=(mob/living/carbon/human/H)
	if(H == leader)
		unset_leader(H)
	members -= H
	H.squad = null

//Begin job overrides.

/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	addtimer(CALLBACK(src, .proc/register_squad, H), 2 SECONDS)

/datum/job/proc/register_squad(mob/living/H)
	if(!ishuman(H))
		return //No
	var/datum/squad/squad = GLOB.squad_manager.get_squad(H.client.prefs.preferred_squad)
	if(squad.members.len && squad.members.len >= squad.max_members) //Too many people! Make a new squad and pop us in it.
		squad = GLOB.squad_manager.get_joinable_squad()
	for(var/path in squad.blacklist)
		if(type == path)
			return
	if(H.client.prefs.be_leader)
		if(!squad.leader)
			squad.set_leader(H)
			return
		else
			for(var/datum/squad/S in GLOB.squad_manager.squads)
				if(!S.leader)
					S.set_leader(H)
					return
	squad += H

/datum/saymode/squad
	key = MODE_KEY_SQUAD
	mode = MODE_SQUAD

/datum/saymode/squad/handle_message(mob/living/carbon/human/user, message, datum/language/language)
	if(!ishuman(user))
		return
	var/obj/item/squad_pager/page = locate(/obj/item/squad_pager) in user.get_contents()
	if(!page || !page.squad)
		return
	user.say("[message]")
	page.squad.broadcast(message, user)

//Show relevent squad info on status panel.

/mob/living/carbon/human/Stat()
	..()

	if(statpanel("Squad"))
		if(!squad)
			stat(null, "You have not been assigned to a squad.")
			return
		stat(null, "Assigned Squad: [squad.name || "Unassigned"]")
		stat(null, "Squad Leader: [squad.leader || "None"]")
		stat(null, "Squad Type: [squad.squad_type || "Standard"]")
		stat(null, "Standing Orders: [squad.orders || "None"]")
