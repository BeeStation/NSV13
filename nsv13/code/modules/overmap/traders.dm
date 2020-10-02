/datum/trader
	var/name = "Dodgy dan the cryptocurrency trader"
	var/desc = "Only the finest cryptocurrency investments."
	var/list/stonks = list() //The trader's inventory.
	var/list/sold_items = list()
	var/faction_type = null //What faction does the dude belong to.
	var/system_type = "unaligned" //In what systems do they spawn?
	//Fluff / voice stuff
	var/list/greetings = list("Welcome to our store!", "How can I help you?", "We've got everything you need...for a price.")
	var/list/on_purchase = list("Thanks for your business!", "Thank you, come again", "Thank you for your purchase!")

//Method to stock a trader with items. This happens every so often and you have little control over it.
/datum/trader/proc/stock_items()
	for(var/datum/trader_item/item in stonks)
		qdel(item)
	stonks = list() //Reset our stores of supplies
	for(var/itemPath in sold_items)
		var/datum/trader_item/TI = new itemPath()
		TI.price = rand(TI.price/2, TI.price*2)
		TI.stock = rand(TI.stock/2, TI.stock*2) //How much we got in stock boys
		stonks += TI
	return FALSE

/datum/trader_item
	var/name = "Stonks"
	var/desc = "Invest in crypto."
	var/price = 1000 //What's the going rate for this item? The prices are slightly randomized.
	var/unlock_path = null
	var/stock = 1 //How many of these items are usually stocked, this is randomized

/datum/trader_item/proc/on_purchase(obj/structure/overmap/OM, datum/trader_item/unlock_type)
	var/area/landingzone = null
	if(OM.role == MAIN_OVERMAP)
		landingzone = GLOB.areas_by_type[/area/quartermaster/warehouse]
	else
		if(!OM.linked_areas.len)
			return FALSE
		landingzone = pick(OM.linked_areas)
	var/list/empty_turfs = list()
	var/turf/LZ = null
	for(var/turf/open/floor/T in landingzone.contents)//uses default landing zone
		if(is_blocked_turf(T))
			continue
		if(empty_turfs.len >= 10)
			break //Don't bother finding any more.
		LAZYADD(empty_turfs, T)
		CHECK_TICK
	if(empty_turfs?.len)
		LZ = pick(empty_turfs)
	var/obj/structure/closet/supplypod/freight_pod/toLaunch = new /obj/structure/closet/supplypod/freight_pod
	var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/flyMeToTheMoon]
	toLaunch.forceMove(shippingLane)
	var/atom/movable/theItem = new unlock_type.unlock_path
	theItem.forceMove(toLaunch)
	new /obj/effect/DPtarget(LZ, toLaunch)
	return TRUE

/datum/trader_item/ship_repair
	name = "Quick n' ez ship repair"
	desc = "We'll patch your ship up without a care, with our special ingredients: Duct tape and prayer! (Copyright CzanekCorp 2258, all rights reserved)"
	price = 1000
	stock = 5
	var/failure_chance = 20 //Chance of the repair going wrong. You get what you pay for.
	var/repair_amount = 35 //% of health this repair will heal up.

/datum/trader_item/ship_repair/tier2
	name = "Ship armour repair"
	desc = "A full repair of your ship's armour plating, superstructural repairs not included!"
	price = 2500
	failure_chance = 0
	repair_amount = 50
	stock = 2

/datum/trader_item/ship_repair/on_purchase(obj/structure/overmap/OM)
	OM.repair_all_quadrants(repair_amount, failure_chance)

//Arms dealers.
/datum/trader/armsdealer
	name = "WhiteRapids Munitions (And Resort)"
	desc = "Corporate approved arms dealer specialising in ballistic weapon deployment."
	faction_type = FACTION_ID_NT
	system_type = "nanotrasen"

/datum/trader/armsdealer/syndicate
	name = "DonkCo Warcrime Emporium"
	desc = "Only the finest weapons guaranteed to violate the geneva convention! (We'll sell to anyone!)"
	faction_type = FACTION_ID_SYNDICATE
	system_type = "syndicate"

/datum/trader/armsdealer/syndicate/New()
	. = ..()
	name = pick(name, "Gorlex Marauders Weapons Co.", "Syndi-dyne Gun Fiesta", "Dolos Dealers")

//Repairs
/datum/trader/czanekcorp
	name = "CzanekCorp shipyards"
	desc = "Ship construction deeds done cheap (for a price)"
	faction_type = FACTION_ID_NT
	greetings = list("Welcome to CzanekCorp, we take cash, credit, and charge. What’cha need?",\
	"CzanekCorp here. We got a new shipment in, you down for talking turkey?",\
	"CzanekCorp, we got repairs and goods on a budget, you in?")
	on_purchase = list("Yes, we know the tazers aren’t the safest, but if you don’t like ‘em, stop buying ‘em, eh?", "Good doing business with you. Good luck out there, killer.", "About time we got somebody who knows what they’re doing. Here, free shipping!", "No refunds, no returns!")
	sold_items = list(/datum/trader_item/ship_repair)

/datum/trader/minsky
	name = "Minsky Heavy Engineering"
	desc = "Corporate approved aftermarket ship repairs dealer."
	faction_type = FACTION_ID_NT
	sold_items = list(/datum/trader_item/ship_repair/tier2)

/datum/trader/ui_data(mob/user)
	var/list/data = list()
	var/list/items_info = list()
	for(var/datum/trader_item/item in stonks)
		var/list/item_info = list()
		item_info["price"] = stonks[item] //For a price for a price price, for a price, price price.
		item_info["name"] = item.name
		item_info["desc"] = item.desc
	data["name"] = name
	data["desc"] = desc
	data["theme"] = (faction_type == FACTION_ID_NT) ? "ntos" : "syndicate"
	data["items_info"] = items_info
	return data

/datum/trader/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/starmap)
		assets.send(user)
		ui = new(user, src, ui_key, "Trader", name, 800, 660, master_ui, state)
		ui.open()
