/datum/trader
	var/name = "Drug Mcdonalds"
	var/desc = "Son, we forgot the crack."
	var/shortname = "DM" //Used in Brazil.
	var/list/stonks = list() //The trader's inventory.
	var/list/sold_items = list()
	var/list/special_offers = list() //Items locked behind points
	var/faction_type = null //What faction does the dude belong to.
	var/system_type = "unaligned" //In what systems do they spawn?
	//Fluff / voice stuff
	var/greeting = "What do you want?"
	var/list/greetings = list("Welcome to our store!", "How can I help you?", "We've got everything you need...for a price.")
	var/list/on_purchase = list("Thanks for your business!", "Thank you, come again", "Thank you for your purchase!")
	var/list/on_fail = list("Did you intend to pay for that?", "I'm afraid the cheque bounced.", "Purchase not authorised.")
	var/list/on_mission_give = list("Actually, we could use a favour...", "Mission details sent.", "Thanks, we owe you one!")
	var/station_type = /obj/structure/overmap/trader //Fluff, really. Just sets what kinda station they spawn on!
	var/next_restock = 0
	var/stock_delay = 0
	var/image = "https://cdn.discordapp.com/attachments/701841640897380434/764534224291233822/unknown.png"
	var/list/missions = list() //Missions
	// var/list/possible_mission_types = list( // List of possible missions this trader may have
	// 	/datum/nsv_mission/explore=10,
	// 	/datum/nsv_mission/kill_ships=10,
	// 	/datum/nsv_mission/kill_ships/waves=8,
	// 	/datum/nsv_mission/kill_ships/system=6,
	// 	/datum/nsv_mission/cargo=10,
	// 	/datum/nsv_mission/cargo/high_risk=7,
	// 	/datum/nsv_mission/cargo/nuke=1)
	var/obj/structure/overmap/current_location = null
	var/datum/star_system/system = null
	var/max_missions = 5
	var/yellow_pages_dat = ""

/datum/trader/New()
	. = ..()
	SSstar_system.traders += src

/datum/trader/Destroy()
	SSstar_system.traders.Remove(src)
	. = ..()

//Method to stock a trader with items. This happens every so often and you have little control over it.
/datum/trader/proc/stock_items()
	for(var/datum/trader_item/item in stonks)
		qdel(item)
	stonks = list() //Reset our stores of supplies
	var/datum/faction/F = SSstar_system.faction_by_id(faction_type)
	yellow_pages_dat += "<h3>[F ? F.name : "neutral"]-aligned station [name] at [system.name]</h3>"
	yellow_pages_dat += "<font size = \"2\">"
	for(var/itemPath in sold_items)
		var/datum/trader_item/TI = new itemPath()
		TI.price = round(rand(TI.price/2, TI.price*4))
		TI.stock = round(rand(TI.stock/2, TI.stock*2)) //How much we got in stock boys
		stonks += TI
		TI.owner = src
		yellow_pages_dat += "[TI.stock]x [TI.name] ([TI.price] ea.) - <i>[TI.desc]</i><br /><br />"
	for(var/itemPath in special_offers)
		var/datum/trader_item/TI = new itemPath()
		if(system_type == SSstar_system.find_main_overmap().faction && F.tickets >= TI.special_requirement) //Right now we use faction tickets to unlock better items
			TI.name = "SPECIAL OFFER! " + TI.name //Advertising is very important
			TI.price = round(rand((2*TI.price)/3, TI.price*2)) //These will be more expensive by default already and have less chaotic prices
			TI.stock = round(rand(TI.stock/2, TI.stock*2))
			stonks += TI
			TI.owner = src
			yellow_pages_dat += "SPECIAL OFFER! [TI.stock]x [TI.name] ([TI.price] ea.) - <i>[TI.desc]</i><br /><br />"
	yellow_pages_dat += "</font>"

/datum/trader_item
	var/name = "Stonks"
	var/desc = "Invest in crypto."
	var/price = 1000 //What's the going rate for this item? The prices are slightly randomized.
	var/unlock_path = null
	var/stock = 1 //How many of these items are usually stocked, this is randomized
	var/owner = null
	var/special_requirement //How many tickets do we need to unlock this item in the store?

/datum/trader_item/proc/on_purchase(obj/structure/overmap/OM)
	return OM.send_supplypod(unlock_path)

/obj/structure/overmap/proc/send_supplypod(unlock_path, var/obj/structure/overmap/courier, isInitialized)
	RETURN_TYPE(/atom/movable)
	var/area/landingzone = null
	var/obj/structure/overmap/OM = src
	var/turf/LZ = null
	//If you wanna specify WHERE cargo is dropped. Otherwise we guess.
	if(!length(trader_beacons))
		if(OM.role == MAIN_OVERMAP)
			landingzone = GLOB.areas_by_type[/area/quartermaster/warehouse]

		if ( !landingzone ) // Main overmap may or may not have a warehouse
			landingzone = GLOB.areas_by_type[/area/quartermaster]

		if ( !landingzone ) // Main overmap may or may not have a cargobay
			if(!OM.linked_areas.len)
				OM = OM.last_overmap //Handles fighters going out and buying things on the ship's behalf
				if(length(OM?.linked_areas))
					goto foundareas
				return FALSE
			foundareas:
			landingzone = pick(OM.linked_areas)
		var/list/empty_turfs = list()
		for(var/turf/open/floor/T in landingzone)//uses default landing zone
			if(is_blocked_turf(T))
				continue
			if(empty_turfs.len >= 10)
				break //Don't bother finding any more.
			LAZYADD(empty_turfs, T)
			CHECK_TICK
		if(empty_turfs?.len)
			LZ = pick(empty_turfs)
	else
		LZ = get_turf(pick(trader_beacons))
	if(dradis && !QDELETED(dradis.beacon) && dradis.usingBeacon)
		LZ = get_turf(dradis.beacon)
	if(!LZ)
		LZ = pick(landingzone) //If we couldn't find an open floor, just throw it somewhere

	// Knowing who the deliveryman is tells us what kind of pod to send
	var/obj/structure/closet/supplypod/toLaunch
	if ( courier )
		toLaunch = new courier.supply_pod_type()
	else
		toLaunch = new /obj/structure/closet/supplypod/centcompod()

	var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/supplypod_temp_holding]
	toLaunch.forceMove(shippingLane)
	var/atom/movable/theItem
	if ( isInitialized )
		theItem = unlock_path
	else
		theItem = new unlock_path
	theItem.forceMove(toLaunch)
	new /obj/effect/pod_landingzone(LZ, toLaunch)
	return theItem

// /datum/trader/proc/generate_missions()
// 	for(var/a in 1 to max_missions)
// 		var/m = pickweightAllowZero(possible_mission_types)
// 		possible_mission_types[m] --
// 		missions += new m(current_location)



//Arms dealers.
/datum/trader/armsdealer
	name = "WhiteRapids Munitions (And Resort)"
	desc = "Corporate approved arms dealer specialising in ballistic weapon deployment."
	shortname = "WR(R)"
	faction_type = FACTION_ID_NT
	system_type = "nanotrasen"
	image = "https://cdn.discordapp.com/attachments/701841640897380434/764557336684527637/unknown.png"
	sold_items = list(/datum/trader_item/torpedo, \
	/datum/trader_item/missile, \
	/datum/trader_item/c45, \
	/datum/trader_item/pdc, \
	/datum/trader_item/pdc_circuit, \
	/datum/trader_item/deck_gun_autorepair, \
	/datum/trader_item/yellow_pages)
	special_offers = list(/datum/trader_item/firing_electronics, \
	/datum/trader_item/vls_circuit)

/datum/trader/armsdealer/syndicate
	name = "DonkCo Warcrime Emporium"
	desc = "Only the finest weapons guaranteed to violate the geneva convention! (We'll sell to anyone.. but don't get too close!)"
	shortname = "DWE"
	faction_type = FACTION_ID_SYNDICATE
	system_type = "syndicate"
	//Top tier trader with the best items available.
	sold_items = list(/datum/trader_item/hellfire, \
	/datum/trader_item/torpedo, \
	/datum/trader_item/missile, \
	/datum/trader_item/c20r, \
	/datum/trader_item/c45, \
	/datum/trader_item/stechkin, \
	/datum/trader_item/pdc, \
	/datum/trader_item/pdc_circuit, \
	/datum/trader_item/fighter/syndicate, \
	/datum/trader_item/overmap_shields, \
	/datum/trader_item/deck_gun_autoelevator, \
	/datum/trader_item/yellow_pages)
	special_offers = list(/datum/trader_item/firing_electronics, \
	/datum/trader_item/vls_circuit)
	station_type = /obj/structure/overmap/trader/syndicate
	image = "https://cdn.discordapp.com/attachments/728055734159540244/764570187357093928/unknown.png"
	greetings = list("You've made it pretty far in, huh? We won't tell if you're buying...", "Freedom isn't free, buy a gun to secure yours.", "Excercise your right to bear arms now!")
	// possible_mission_types = list(
	// 	/datum/nsv_mission/cargo/nuke/syndicate=1,
	// 	/datum/nsv_mission/kill_ships/waves/syndicate=1,
	// 	/datum/nsv_mission/kill_ships/system/syndicate=3,
	// 	/datum/nsv_mission/kill_ships/syndicate=1)
	max_missions = 6

/datum/trader/armsdealer/syndicate/attempt_purchase(datum/trader_item/item, mob/living/carbon/user)
	. = ..()
	if(!.)
		return
	if(!user.last_overmap || user.last_overmap.faction != "syndicate")
		SSovermap_mode.modify_threat_elevation(TE_SYNDISHOP_PENALTY)	//How to get a hitsquad sent at you: Buy hellfire weapons from the Syndicate.

/datum/trader/armsdealer/syndicate/New()
	. = ..()
	name = pick(name, "Gorlex Marauders Weapons Co.", "Syndi-dyne Gun Fiesta", "Dolos Dealers")

//Repairs
/datum/trader/czanekcorp
	name = "CzanekCorp shipyards"
	desc = "Ship construction deeds done cheap (for a price)"
	shortname = "CZC"
	faction_type = FACTION_ID_NT
	greetings = list("Welcome to CzanekCorp, we take cash, credit, and charge. What'cha need?",\
	"CzanekCorp here. We got a new shipment in, you down for talking turkey?",\
	"CzanekCorp, we got repairs and goods on a budget, you in?")
	on_purchase = list("Yes, we know the tazers aren't the safest, but if you don't like 'em, stop buying 'em, eh?", "Good doing business with you. Good luck out there, killer.", "About time we got somebody who knows what they're doing. Here, free shipping!", "No refunds, no returns!")
	sold_items = list(/datum/trader_item/ship_repair, \
	/datum/trader_item/fighter/light, \
	/datum/trader_item/fighter/heavy, \
	/datum/trader_item/fighter/utility, \
	/datum/trader_item/taser, \
	/datum/trader_item/taser_ammo, \
	/datum/trader_item/yellow_pages)
	station_type = /obj/structure/overmap/trader/shipyard
	image = "https://cdn.discordapp.com/attachments/701841640897380434/764540586732421120/unknown.png"

/datum/trader/shallowstone
	name = "Shallow Stone Station"
	desc = "Rock and ore coming right to your door!"
	shortname = "SSS"
	faction_type = FACTION_ID_NT
	greetings = list("Need something water drinkers?",\
	"Have you come to dig or pay?",\
	"We got minerals for you, so long as you've got a deposit for us.")
	on_purchase = list("Maybe next time, dig it up yourself lazy gits!", "Credits have been withdrawn, Supplies inbound.", "Czanek would approve of this.", "If you're too afraid to get these yourself, I'm almost scared to give them to you. But money is money.")
	sold_items = list(/datum/trader_item/mining_point_card, \
	/datum/trader_item/gold, \
	/datum/trader_item/diamond, \
	/datum/trader_item/uranium, \
	/datum/trader_item/silver, \
	/datum/trader_item/bluespace_crystal, \
	/datum/trader_item/titanium, \
	/datum/trader_item/yellow_pages)
	station_type = /obj/structure/overmap/trader
	image = "https://cdn.discordapp.com/attachments/612668662977134592/859132739147792444/unknown.png"   //I don't wanna do this but I'm also not going to break the mold as to make it hopefully easier in future to fix.

/datum/trader/shallowstone/independent
	name = "Marvin's Mineral Emporium"
	desc = "Ready to supply everyone with the finest stones and gems!"
	shortname = "MME"
	faction_type = FACTION_ID_UNALIGNED
	greetings = list("Take a look around, our stores are open to anyone!",\
	"How goes it fellow space dwellers? Care for some of the best ore in the Rosetta Cluster?")

/datum/trader/minsky
	name = "Minsky Heavy Engineering"
	desc = "Corporate approved aftermarket shipyard."
	shortname = "MHE"
	faction_type = FACTION_ID_NT
	sold_items = list(/datum/trader_item/ship_repair/tier2, \
	/datum/trader_item/flak, \
	/datum/trader_item/fighter/light, \
	/datum/trader_item/fighter/heavy, \
	/datum/trader_item/fighter/utility, \
	/datum/trader_item/fighter/judgement, \
	/datum/trader_item/fighter/prototype, \
	/datum/trader_item/railgun_disk, \
	/datum/trader_item/yellow_pages)
	special_offers = list(/datum/trader_item/ship_repair/tier3)
	station_type = /obj/structure/overmap/trader/shipyard

// HIM
/datum/trader/randy
	name = "Randy Random Corporate Enterprise"
	desc = "Chaos Incorporeal."
	shortname = "RDY"
	faction_type = FACTION_ID_PIRATES
	sold_items = null //Special offer, this time only. (Not used, Stock is randomized every cycle.)

/datum/trader/randy/stock_items()
	//Pick 5 random items and construct fresh trader_items for it.
	var/iter = 5
	for(var/x in sold_items)
		sold_items -= x
		qdel(x)
	for(var/x in stonks)
		stonks -= x
		qdel(x)
	sold_items = list()
	while(iter)
		iter--
		var/datum/trader_item/item = new
		var/obj/item/a_gift/anything/generator = new
		var/initialtype = generator.get_gift_type()
		var/obj/item/soldtype = new initialtype
		if(!soldtype) //spawned something that deleted itself, try again
			log_runtime("Randy failed to spawn [initialtype]!")
			qdel(item)
			iter++
			continue
		item.unlock_path = initialtype
		item.name = soldtype.name
		item.desc = soldtype.desc
		item.price = rand(1000, 100000000)
		item.stock = rand(1, 5)
		item.owner = src
		qdel(soldtype)
		sold_items += item

	var/datum/trader_item/yellow_pages/pages = new
	sold_items += pages

	stonks = sold_items

/datum/trader/randy/New()
	. = ..()
	stock_items()

/datum/trader/ui_data(mob/user)
	if(world.time >= next_restock)
		stock_items()
		stock_delay = rand(10, 20)
		next_restock = world.time + stock_delay MINUTES
	var/list/data = list()
	var/list/items_info = list()
	for(var/datum/trader_item/item in stonks)
		var/list/item_info = list()
		item_info["price"] = item.price //For a price for a price price, for a price, price price.
		item_info["name"] = item.name
		item_info["desc"] = "[item.price]$ - [item.desc]"
		item_info["id"] = "\ref[item]"
		item_info["stock"] = item.stock
		items_info[++items_info.len] = item_info
	data["greeting"] = greeting
	data["desc"] = desc
	data["image"] = image
	data["theme"] = (faction_type == FACTION_ID_NT || faction_type == FACTION_ID_UNALIGNED) ? "ntos" : "syndicate"
	data["items_info"] = items_info
	data["next_restock"] = "Stock: (Restocking in [round((next_restock-world.time)/600)] minutes)"
	//Syndies use syndie budget, NT use NT cargo budget
	var/obj/structure/overmap/OM = user.get_overmap()
	var/account = ACCOUNT_CAR
	if(OM)
		account = (OM.faction == "nanotrasen") ? ACCOUNT_CAR : ACCOUNT_SYN
	var/datum/bank_account/D = SSeconomy.get_dep_account(account)
	if(D)
		data["points"] = "$[D.account_balance]"
	// Extra information about what missions this station is tracking
	var/list/holding_cargo_info = list()
	for ( var/datum/overmap_objective/cargo/O in current_location.holding_cargo )
		var/list/item_info = list()
		item_info[ "name" ] = O.name
		item_info[ "brief" ] = O.brief
		item_info[ "id" ] = "\ref[O]"
		holding_cargo_info[++holding_cargo_info.len] = item_info
	data[ "holding_cargo" ] = holding_cargo_info
	if ( current_location && length( current_location.expecting_cargo ) )
		data[ "expecting_cargo" ] = length( current_location.expecting_cargo )
	return data

/datum/trader/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/datum/trader_item/target = locate(params["target"])
	var/mob/living/user = usr
	var/dist = get_dist(user.get_overmap(), current_location)
	if(!current_location.z || dist >= 30)
		to_chat(user, "<span class='warning'>Out of bi-directional comms range.</span>")
		return FALSE
	switch(action)
		if("purchase")
			if(!target)
				return
			attempt_purchase(target, usr)
		if( "receive_cargo" )
			var/datum/overmap_objective/cargo/O = locate(params["objective"])
			current_location.deliver_package( user, O )

		// if("mission")
		// 	var/list/currentMissions = list()
		// 	for(var/datum/nsv_mission/M in SSstar_system.all_missions)
		// 		if(M.owner == user.get_overmap())
		// 			if(M.stage != MISSION_COMPLETE)
		// 				currentMissions += M
		// 	if(currentMissions.len < 3) // Max number of missions
		// 		give_mission(usr)
		// 	else
		// 		to_chat(user, "<span class='boldnotice'>" + pick(
		// 			"Why don't you complete the mission we just gave you first.",
		// 			"Please complete the mission we gave you first, then come back and ask again.",
		// 			"Stop pressing the button.",
		// 			"*static*",
		// 			"We appreciate your enthusiasm, but we want to make sure this mission gets completed first.",
		// 			"What are the chances you'll actually get this mission done? Go complete it before we trust you with another one.",
		// 			"Our superiors have asked us to stop stacking critical missions on one courier.",
		// 		) + "</span>")

// /datum/trader/proc/give_mission(mob/living/user)
// 	if(!isliving(user))
// 		return
//
// 	var/list/valid_missions = list()
//
// 	for(var/m in missions) // Get all valid missions the crew qualifies for
// 		var/datum/nsv_mission/mission = m
// 		if(mission.check_eligible(user.get_overmap()))
// 			valid_missions += mission
// 	if(!valid_missions.len)
// 		SEND_SOUND(user, 'nsv13/sound/effects/ship/freespace2/computer/textdraw.wav')
// 		to_chat(user, "<span class='boldnotice'>We don't have any work for you I'm afraid.</span>")
// 		return FALSE
//
// 	var/datum/nsv_mission/theJob = pick(valid_missions)
// 	theJob.pre_register(user.get_overmap())
// 	to_chat(user, "<span class='boldnotice'>[pick(on_mission_give)]</span>")
// 	user.get_overmap().hail("Mission details as follows: [theJob.desc]", src)
// 	return TRUE

/datum/trader/proc/attempt_purchase(datum/trader_item/item, mob/living/carbon/user)
	if(!isliving(user))
		return FALSE
	//Syndies use syndie budget, NT use NT cargo budget
	var/obj/structure/overmap/OM = user.get_overmap()
	var/account = ACCOUNT_CAR
	if(OM)
		account = (OM.faction == "nanotrasen") ? ACCOUNT_CAR : ACCOUNT_SYN
	var/datum/bank_account/D = SSeconomy.get_dep_account(account)
	if(!D || D.account_balance <= item.price)
		SEND_SOUND(user, 'nsv13/sound/effects/ship/freespace2/computer/textdraw.wav')
		to_chat(user, "<span class='boldnotice'>[pick(on_fail)]</span>")
		return FALSE
	D.adjust_money(-item.price)
	if(user.overmap_ship)
		user.get_overmap().hail(pick(on_purchase), src)
	item.on_purchase(user.get_overmap())
	item.stock --
	if(item.stock <= 0)
		stonks -= item
		qdel(item)
	return TRUE

/datum/trader/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/datum/trader/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/starmap)
	assets.send(user)
	ui = new(user, src, "Trader")
	ui.open()
	ui.set_autoupdate(TRUE) // Current balance and stock updates
