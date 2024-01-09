/datum/supply_pack/emergency/syndicate
	name = "NULL_ENTRY"
	desc = "(#@&^$THIS PACKAGE CONTAINS 30TC WORTH OF SOME RANDOM SYNDICATE GEAR WE HAD LYING AROUND THE WAREHOUSE. GIVE EM HELL, OPERATIVE, BUT DON'T GET GREEDY- ORDER TOO MANY AND WE'LL BE SENDING OUR DEADLIEST ENFORCERS TO INVESTIGATE@&!*() "
	hidden = TRUE
	cost = 20000
	contains = list()
	crate_name = "emergency crate"
	crate_type = /obj/structure/closet/crate/internals
	dangerous = TRUE
	var/beepsky_chance = -1
	var/level = 1

/datum/supply_pack/emergency/syndicate/fill(obj/structure/closet/crate/C)
	var/crate_value = 30
	var/list/uplink_items = get_uplink_items(UPLINK_TRAITORS)
	beepsky_chance += min(level, 5) //1% chance per crate an item will be replaced with a beepsky and the crate stops spawning items. Doesnt act as a hardcap, making nullcrates far riskier and less predictable
	while(crate_value)
		if(prob(beepsky_chance) && prob(50))
			new /mob/living/simple_animal/bot/secbot/grievous/nullcrate(C)
			crate_value = 0
			beepsky_chance = 0
			level += 1
		var/category = pick(uplink_items)
		var/item = pick(uplink_items[category])
		var/datum/uplink_item/I = uplink_items[category][item]
		if(!I.surplus_nullcrates || prob(100 - I.surplus_nullcrates))
			continue
		if(crate_value < I.cost)
			continue
		crate_value -= I.cost
		new I.item(C)
	var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
	if(istype(loneop))
		loneop.weight += 7
		message_admins("a NULL_ENTRY crate has shipped, increasing the weight of the Lone Operative event to [loneop.weight]")
		log_game("a NULL_ENTRY crate has shipped, increasing the weight of the Lone Operative event to [loneop.weight]")
