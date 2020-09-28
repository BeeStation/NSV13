/datum/trader
	var/name = "Dodgy dan the cryptocurrency trader"
	var/desc = "Only the finest cryptocurrency investments."
	var/list/stonks = list() //The trader's inventory.
	var/faction_type = null //What faction does the dude belong to.

/datum/trader_item
	var/name = "Stonks"
	var/desc = "Invest in crypto."
	var/price = 0
	var/unlock_path = null

/datum/trader_item/proc/on_purchase(obj/structure/overmap/OM)
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
	var/atom/movable/toLaunch = new unlock_type
	new /obj/effect/DPtarget(LZ, toLaunch)
	return TRUE

/datum/trader_item/ship_repair
	name = "Quick n' ez ship repair"
	desc = "We'll patch your ship up without a care, with our special ingredients: Duct tape and prayer! (Copyright CzanekCorp 2258, all rights reserved)"
	var/failure_chance = 20 //Chance of the repair going wrong. You get what you pay for.
	var/repair_amount = 50 //% of health this repair will heal up.

/datum/trader_item/ship_repair/on_purchase(obj/structure/overmap/OM)
	OM.repair_all_quadrants

//Arms dealers.
/datum/trader/whiterapids
	name = "WhiteRapids munitions depot (and resort)"
	desc = "Only the finest "
	faction_type = FACTION_ID_NT

/datum/trader/donkco
	name = "DonkCo warcrime emporium"
	desc = "Only the finest weapons guaranteed to violate the geneva convention!"
	faction_type = FACTION_ID_SYNDICATE

//Repairs
/datum/trader/czanekcorp
	name = "CzanekCorp shipyards"
	desc = "Ship repairing deeds done cheap (for a price)"
	faction_type = FACTION_ID_NT

/datum/trader/minsky
	name = "Minsky Heavy Engineering"
	desc = "Corporate approved aftermarket ship repairs dealer."
	faction_type = FACTION_ID_NT

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
