
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
	var/static/list/blacklist = list(/datum/job/captain, /datum/job/hop, /datum/job/chief_engineer, /datum/job/cargo_tech,/datum/job/mining, /datum/job/qm, /datum/job/ai, /datum/job/cyborg, /datum/job/munitions_tech, /datum/job/pilot, /datum/job/master_at_arms, /datum/job/rd, /datum/job/air_traffic_controller, /datum/job/warden, /datum/job/hos, /datum/job/officer, /datum/job/chief_engineer, /datum/job/bridge)
	var/list/access = list()
	var/datum/component/simple_teamchat/radio_dependent/squad/squad_channel = null
	var/squad_channel_type

/datum/squad/proc/get_squad_channel()
	return squad_channel_type

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
