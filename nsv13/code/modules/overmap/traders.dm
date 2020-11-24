/datum/trader
	var/name = "Drug Mcdonalds"
	var/desc = "Son, we forgot the crack."
	var/shortname = "DM" //Used in Brazil.
	var/list/stonks = list() //The trader's inventory.
	var/list/sold_items = list()
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
	var/list/possible_mission_types = list( // List of possible missions this trader may have
		/datum/nsv_mission/explore=10,
		/datum/nsv_mission/kill_ships=10,
		/datum/nsv_mission/kill_ships/waves=8,
		/datum/nsv_mission/kill_ships/system=6,
		/datum/nsv_mission/cargo=10,
		/datum/nsv_mission/cargo/high_risk=7,
		/datum/nsv_mission/cargo/nuke=1)
	var/obj/structure/overmap/current_location = null
	var/datum/star_system/system = null
	var/max_missions = 5

/datum/trader/New()
	SSstar_system.traders += src

//Method to stock a trader with items. This happens every so often and you have little control over it.
/datum/trader/proc/stock_items()
	for(var/datum/trader_item/item in stonks)
		qdel(item)
	stonks = list() //Reset our stores of supplies
	for(var/itemPath in sold_items)
		var/datum/trader_item/TI = new itemPath()
		TI.price = rand(TI.price/2, TI.price*4)
		TI.stock = rand(TI.stock/2, TI.stock*2) //How much we got in stock boys
		stonks += TI
	return FALSE

/datum/trader_item
	var/name = "Stonks"
	var/desc = "Invest in crypto."
	var/price = 1000 //What's the going rate for this item? The prices are slightly randomized.
	var/unlock_path = null
	var/stock = 1 //How many of these items are usually stocked, this is randomized

/datum/trader_item/proc/on_purchase(obj/structure/overmap/OM)
	OM.send_supplypod(unlock_path)

/obj/structure/overmap/proc/send_supplypod(unlock_path)
	RETURN_TYPE(/atom/movable)
	var/area/landingzone = null
	var/obj/structure/overmap/OM = src
	var/turf/LZ = null
	//If you wanna specify WHERE cargo is dropped. Otherwise we guess.
	if(!trader_beacons || !trader_beacons.len)
		if(OM.role == MAIN_OVERMAP)
			landingzone = GLOB.areas_by_type[/area/quartermaster/warehouse]

		else
			if(!OM.linked_areas.len)
				OM = OM.last_overmap //Handles fighters going out and buying things on the ship's behalf
				if(OM.linked_areas.len)
					goto foundareas
				return FALSE
			foundareas:
			landingzone = pick(OM.linked_areas)
		var/list/empty_turfs = list()
		for(var/turf/open/floor/T in landingzone.contents)//uses default landing zone
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
	if(dradis && dradis.beacon && !QDELETED(dradis.beacon) && dradis.usingBeacon)
		LZ = get_turf(dradis.beacon)
	if(!LZ)
		LZ = pick(landingzone.contents) //If we couldn't find an open floor, just throw it somewhere
	var/obj/structure/closet/supplypod/centcompod/toLaunch = new /obj/structure/closet/supplypod/centcompod
	var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/flyMeToTheMoon]
	toLaunch.forceMove(shippingLane)
	var/atom/movable/theItem = new unlock_path
	theItem.forceMove(toLaunch)
	new /obj/effect/DPtarget(LZ, toLaunch)
	return theItem

/datum/trader/proc/generate_missions()
	for(var/a in 1 to max_missions)
		var/m = pickweightAllowZero(possible_mission_types)
		possible_mission_types[m] --
		missions += new m(current_location)



//Arms dealers.
/datum/trader/armsdealer
	name = "WhiteRapids Munitions (And Resort)"
	desc = "Corporate approved arms dealer specialising in ballistic weapon deployment."
	shortname = "WR(R)"
	faction_type = FACTION_ID_NT
	system_type = "nanotrasen"
	image = "https://cdn.discordapp.com/attachments/701841640897380434/764557336684527637/unknown.png"
	sold_items = list(/datum/trader_item/torpedo, /datum/trader_item/missile, /datum/trader_item/mac, /datum/trader_item/railgun, /datum/trader_item/c45, /datum/trader_item/pdc)

/datum/trader/armsdealer/syndicate
	name = "DonkCo Warcrime Emporium"
	desc = "Only the finest weapons guaranteed to violate the geneva convention! (We'll sell to anyone.. but don't get too close!)"
	shortname = "DWE"
	faction_type = FACTION_ID_SYNDICATE
	system_type = "syndicate"
	//Top tier trader with the best items available.
	sold_items = list(/datum/trader_item/nuke,/datum/trader_item/torpedo, /datum/trader_item/missile, /datum/trader_item/mac, /datum/trader_item/railgun, /datum/trader_item/c20r, /datum/trader_item/c45, /datum/trader_item/stechkin, /datum/trader_item/pdc, /datum/trader_item/flak, /datum/trader_item/fighter/syndicate, /datum/trader_item/overmap_shields)
	station_type = /obj/structure/overmap/trader/syndicate
	image = "https://cdn.discordapp.com/attachments/728055734159540244/764570187357093928/unknown.png"
	greetings = list("You've made it pretty far in, huh? We won't tell if you're buying...", "Freedom isn't free, buy a gun to secure yours.", "Excercise your right to bear arms now!")
	possible_mission_types = list(
		/datum/nsv_mission/cargo/nuke/syndicate=1,
		/datum/nsv_mission/kill_ships/waves/syndicate=1,
		/datum/nsv_mission/kill_ships/system/syndicate=3,
		/datum/nsv_mission/kill_ships/syndicate=1)
	max_missions = 6

/datum/trader/armsdealer/syndicate/New()
	. = ..()
	name = pick(name, "Gorlex Marauders Weapons Co.", "Syndi-dyne Gun Fiesta", "Dolos Dealers")

//Repairs
/datum/trader/czanekcorp
	name = "CzanekCorp shipyards"
	desc = "Ship construction deeds done cheap (for a price)"
	shortname = "CZC"
	faction_type = FACTION_ID_NT
	greetings = list("Welcome to CzanekCorp, we take cash, credit, and charge. What’cha need?",\
	"CzanekCorp here. We got a new shipment in, you down for talking turkey?",\
	"CzanekCorp, we got repairs and goods on a budget, you in?")
	on_purchase = list("Yes, we know the tazers aren’t the safest, but if you don’t like ‘em, stop buying ‘em, eh?", "Good doing business with you. Good luck out there, killer.", "About time we got somebody who knows what they’re doing. Here, free shipping!", "No refunds, no returns!")
	sold_items = list(/datum/trader_item/ship_repair,/datum/trader_item/fighter/light,/datum/trader_item/fighter/heavy,/datum/trader_item/fighter/utility, /datum/trader_item/taser, /datum/trader_item/taser_ammo )
	station_type = /obj/structure/overmap/trader/shipyard
	image = "https://cdn.discordapp.com/attachments/701841640897380434/764540586732421120/unknown.png"

/datum/trader/minsky
	name = "Minsky Heavy Engineering"
	desc = "Corporate approved aftermarket shipyard."
	shortname = "MHE"
	faction_type = FACTION_ID_NT
	sold_items = list(/datum/trader_item/ship_repair/tier2, /datum/trader_item/flak,/datum/trader_item/fighter/light,/datum/trader_item/fighter/heavy,/datum/trader_item/fighter/utility, /datum/trader_item/fighter/judgement, /datum/trader_item/fighter/prototype)
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
		qdel(x)
	sold_items = list()
	while(iter)
		iter--
		var/datum/trader_item/item = new
		var/obj/item/a_gift/anything/generator = new
		var/initialtype = generator.get_gift_type()
		var/obj/item/soldtype = new initialtype
		item.unlock_path = initialtype
		item.name = soldtype.name
		item.desc = soldtype.desc
		item.price = rand(1000, 100000000)
		item.stock = 2
		item.stock = rand(item.stock/2, item.stock*2)
		qdel(soldtype)
		sold_items += item

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
	data["theme"] = (faction_type == FACTION_ID_NT) ? "ntos" : "syndicate"
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
	return data

/datum/trader/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/datum/trader_item/target = locate(params["target"])
	var/mob/living/user = usr
	var/dist = get_dist(user.get_overmap(), current_location)
	if(!current_location.z || dist >= 30)
		to_chat(user, "<span class='warning'>Out of bi-directional comms range.</span>")
		return FALSE
	if(action == "purchase")
		if(!target)
			return
		attempt_purchase(target, usr)
	if(action == "mission")
		give_mission(usr)

/datum/trader/proc/give_mission(mob/living/user)
	if(!isliving(user))
		return

	var/list/valid_missions = list()

	for(var/m in missions) // Get all valid missions the crew qualifies for
		var/datum/nsv_mission/mission = m
		if(mission.check_eligible(user.get_overmap()))
			valid_missions += mission
	if(!valid_missions.len)
		SEND_SOUND(user, 'nsv13/sound/effects/ship/freespace2/computer/textdraw.wav')
		to_chat(user, "<span class='boldnotice'>We don't have any work for you I'm afraid.</span>")
		return FALSE

	var/datum/nsv_mission/theJob = pick(valid_missions)
	theJob.pre_register(user.get_overmap())
	to_chat(user, "<span class='boldnotice'>[pick(on_mission_give)]</span>")
	user.get_overmap().hail("Mission details as follows: [theJob.desc]", src)
	return TRUE

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

/datum/trader/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state=GLOB.not_incapacitated_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/starmap)
		assets.send(user)
		ui = new(user, src, ui_key, "Trader", name, 750, 750, master_ui, state)
		ui.open()
