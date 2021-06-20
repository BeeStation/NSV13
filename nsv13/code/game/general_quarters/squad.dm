GLOBAL_LIST_INIT(squad_styling, list(list("Apples Squad","#C73232", 5), list("Butter Squad" , "#CFB52B", 5), list("Charlie Squad" , "#AE4CCD", 5), list("Duff Squad" , "#5998FF", INFINITY)))
GLOBAL_DATUM_INIT(squad_manager, /datum/squad_manager, new)
//"Enum" that lets you define squads. Format: Name, colour theming.

#define RADIO_SQUAD "squadcomm"
#define FREQ_SQUAD 1452

//These names ought to be self explanatory for any XO when he assigns them.
#define DC_SQUAD "Damage Control Team"
#define MEDICAL_SQUAD "Medical Team"
#define SECURITY_SQUAD "Security Fireteam"
#define COMBAT_AIR_PATROL "Combat Air Patrol"
#define MUNITIONS_SUPPORT "Munitions Support"
#define CIC_OPS "CIC Ops"
#define SQUAD_TYPES list(DC_SQUAD, MEDICAL_SQUAD, SECURITY_SQUAD, COMBAT_AIR_PATROL, MUNITIONS_SUPPORT, CIC_OPS)

/datum/squad_manager
	var/name = "Squad Manager"
	var/list/squads = list()

/datum/squad_manager/New()
	. = ..()
	for(var/I = 1; I <= GLOB.squad_styling.len; I++){
		var/datum/squad/S = new /datum/squad()
		S.name = "[GLOB.squad_styling[I][1]]"
		S.colour = GLOB.squad_styling[I][2]
		S.max_members = GLOB.squad_styling[I][3]
		squads += S
		S.generate_channel()
	}
	addtimer(CALLBACK(src, .proc/check_squad_assignments), 5 MINUTES) //Kick off a timer to check if we're on nightmare world lowpop and need to finagle some people into jobs. Ensure people have a chance to join.

///Method which runs just slightly after roundstart, and ensures that the ship has at least its BASIC roles filled
/datum/squad_manager/proc/check_squad_assignments()
	for(var/rank in list("Bridge Staff", "Munitions Technician"))
		var/datum/job/job = SSjob.GetJob(rank)
		if(!job)
			message_admins("fuck. this is bad")
			continue
		if(!job.current_positions) //Unstaffed crucial job! I count MT and BS as ESSENTIAL for ship operation, so if you have none, the game needs to step in and fix your problem for you. This is so that the ship can always keep moving, even if all the crew try and go meme roles like clown (fight me)
			var/list/possible = list()
			for(var/datum/squad/S in squads)
				if(S.members.len && S.squad_type == DC_SQUAD) //Unassigned DC squads with members are preferred. Otherwise, set up any random squad for when people join it.
					possible += S
			if(!possible.len) //Second run: If no squads are populated, we'll want to set up a squad for later.
				for(var/datum/squad/S in squads)
					if(S.squad_type == DC_SQUAD) //If we just re-assigned a squad, don't re-re-assign it because that would be stupid.
						possible += S
			var/datum/squad/victim = pick(possible)
			var/required = DC_SQUAD //Foo.
			required = (rank == "Bridge Staff") ? CIC_OPS : MUNITIONS_SUPPORT
			victim.retask(required)
			minor_announce("[victim] has been retasked as a [required] due to staffing issues", "WhiteRapids Bureaucratic Corps")

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
	var/static/list/blacklist = list(/datum/job/captain, /datum/job/hop, /datum/job/chief_engineer, /datum/job/cargo_tech,/datum/job/mining, /datum/job/qm, /datum/job/ai, /datum/job/cyborg, /datum/job/munitions_tech, /datum/job/fighter_pilot, /datum/job/master_at_arms, /datum/job/rd, /datum/job/air_traffic_controller, /datum/job/warden, /datum/job/hos, /datum/job/officer, /datum/job/chief_engineer, /datum/job/bridge, /datum/job/flight_leader)
	var/list/access = list()
	var/datum/component/simple_teamchat/radio_dependent/squad/squad_channel = null
	var/squad_channel_type

/datum/squad/proc/generate_channel()
	var/stripped = replacetext(name, " Squad", "")
	squad_channel_type = text2path("/datum/component/simple_teamchat/radio_dependent/squad/[stripped]") //This is OOP sin.
	squad_channel = AddComponent(squad_channel_type)
	squad_channel.squad = src

/datum/squad/proc/get_squad_channel()
	return squad_channel_type

/datum/squad/proc/broadcast(mob/living/carbon/human/sender, message, list/sounds)
	squad_channel.send_message(sender, message, sounds)
	//msg = "<span style=\"color:[colour];[isBold ? ";font-size:13pt" : ""]\"><b>\[[name][isLead ? " [isLead]\]" : "\]"] [display_name]</b> says, \"[msg]\"</span>"

/mob/living/carbon/human
	var/datum/squad/squad = null

/datum/squad/proc/set_leader(mob/living/carbon/human/H)
	leader = H
	to_chat(H, "<span class='sciradio'>You are the squad leader of [name]!. You have authority over the members of this squadron, and may direct them as you see fit. In general, you should use your squad members to help you repair damaged areas during general quarters</span>")
	broadcast(src,"[leader.name] has been assigned to your squad as leader.", list('nsv13/sound/effects/notice2.ogg')) //Change order of this when done testing.
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
	broadcast(src,"[H] has been demoted from squad lead.", list('nsv13/sound/effects/notice2.ogg'))
	leader = null

/datum/squad/proc/set_orders(orders)
	broadcast(src,"New standing orders received: [orders].", list('nsv13/sound/effects/notice2.ogg'))
	src.orders = orders

/datum/squad/proc/retask(task)
	if(squad_type == task)
		return
	squad_type = task
	broadcast(src, "ATTENTION: Your squad has been re-assigned as a [squad_type]. Report to squad vendors to obtain your new equipment.", list('nsv13/sound/effects/notice2.ogg'))
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
		if(COMBAT_AIR_PATROL)
			blurb = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a member of the<i>auxiliary combat air patrol</i> you are responsible for manning any available fighters. If all the fighters are manned by pilots, report to the XO for re-assignment.<br/>\
			You must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty. <br/>\
			<i>Squad vendors</i> open up during General Quarters.</span>"
			access = list(ACCESS_FIGHTER, ACCESS_MUNITIONS) //They'll need to access the fighter bay, which is usually through munitions.
		if(MUNITIONS_SUPPORT)
			blurb = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a member of the<i>munitions support crew</i> you are responsible aiding the munitions technicians with firing the guns. If there are no munitions techs, then your squad must assume command of the weapons bay and ensure the guns are firing.<br/>\
			You must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty. <br/>\
			<i>Squad vendors</i> open up during General Quarters.</span>"
			access = list(ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE) //Puce gang forever
		if(CIC_OPS) //This is a dangerous squad to hand out, but very useful on lowpop.
			blurb = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
			As a <i>CIC operations specialist</i> you are responsible for manning the ship control consoles and ensuring that the ship is able to fight back against any threats. If all the bridge stations are manned by bridge crew, report to the XO for re-assignment.<br/>\
			You must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty. <br/>\
			<i>Squad vendors</i> open up during General Quarters..</span>"
			access = list(ACCESS_HEADS, ACCESS_RC_ANNOUNCE) //Should cover those lowpop no bridge crew rounds nicely.

//Add a member to our squad.
/datum/squad/proc/operator+=(mob/living/carbon/human/H)
	to_chat(H, "<span class='boldnotice'>You have been assigned to [name]!</span>[blurb]</span>")
	members += H
	var/datum/squad/oldSquad = H.squad
	H.squad = src
	if(!oldSquad)
		var/obj/item/storage/backpack/bag = H.get_item_by_slot(ITEM_SLOT_BACK)
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
	addtimer(CALLBACK(src, .proc/register_squad, H), 5 SECONDS)

/datum/job/proc/register_squad(mob/living/H)
	if(!ishuman(H))
		return //No
	var/datum/squad/squad = (H.client && H.client?.prefs?.preferred_squad) ? GLOB.squad_manager.get_squad(H.client.prefs.preferred_squad) : GLOB.squad_manager.get_joinable_squad()
	if(squad.members.len >= squad.max_members) //Too many people! Make a new squad and pop us in it.
		squad = GLOB.squad_manager.get_joinable_squad()
	for(var/path in squad.blacklist)
		if(type == path)
			return
	if(H.client?.prefs?.be_leader)
		if(!squad.leader)
			squad.set_leader(H)
			return
		else
			for(var/datum/squad/S in GLOB.squad_manager.squads)
				if(!S.leader)
					S.set_leader(H)
					return
	squad += H

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
	tab_data["Squad Type"] = list(
			text = "[squad.squad_type || "Standard"]",
			type = STAT_TEXT
		)
	tab_data["Standing Orders"] = list(
			text = "[squad.orders || "None"]",
			type = STAT_TEXT
		)

	return tab_data