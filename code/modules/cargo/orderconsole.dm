/obj/machinery/computer/cargo
	name = "supply console"
	desc = "Used to order supplies, approve requests, and control the shuttle."
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/cargo

	//Can the supply console send the shuttle back and forth? Used in the UI backend.
	var/can_send = TRUE
	var/requestonly = FALSE
	//Can you approve requests placed for cargo? Works differently between the app and the computer.
	var/can_approve_requests = TRUE
	var/contraband = FALSE
	var/self_paid = FALSE
	var/safety_warning = "For safety and ethical reasons, the automated supply shuttle \
		cannot transport live organisms, human remains, classified nuclear weaponry, \
		homing beacons, mail, or machinery housing any form of artificial intelligence."
	var/blockade_warning = "Bluespace instability detected. Shuttle movement impossible."
	/// radio used by the console to send messages on supply channel
	var/obj/item/radio/headset/radio
	/// var that tracks message cooldown
	var/message_cooldown
	COOLDOWN_DECLARE(order_cooldown)

	light_color = "#E2853D"//orange

/obj/machinery/computer/cargo/request
	name = "supply request console"
	desc = "Used to request supplies from cargo."
	icon_screen = "request"
	circuit = /obj/item/circuitboard/computer/cargo/request
	can_send = FALSE
	can_approve_requests = FALSE
	requestonly = TRUE

/obj/machinery/computer/cargo/Initialize(mapload)
	. = ..()
	radio = new /obj/item/radio/headset/headset_cargo(src)
	var/obj/item/circuitboard/computer/cargo/board = circuit
	contraband = board.contraband
	if (board.obj_flags & EMAGGED)
		obj_flags |= EMAGGED
	else
		obj_flags &= ~EMAGGED

/obj/machinery/computer/cargo/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/computer/cargo/proc/get_export_categories()
	. = EXPORT_CARGO
	if(contraband)
		. |= EXPORT_CONTRABAND
	if(obj_flags & EMAGGED)
		. |= EXPORT_EMAG

/obj/machinery/computer/cargo/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	user.visible_message("<span class='warning'>[user] swipes a suspicious card through [src]!</span>",
	"<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")

	obj_flags |= EMAGGED
	contraband = TRUE

	// This also permamently sets this on the circuit board
	var/obj/item/circuitboard/computer/cargo/board = circuit
	board.contraband = TRUE
	board.obj_flags |= EMAGGED
	update_static_data(user)


/obj/machinery/computer/cargo/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/cargo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Cargo")
		ui.open()
		ui.set_autoupdate(TRUE) // Account balance, shuttle status

/obj/machinery/computer/cargo/ui_data()
	var/list/data = list()
	data["department"] = "Cargo" // Hardcoded here, for customization in budgetordering.dm AKA NT IRN //NSV13
	data["location"] = SSshuttle.supply.getStatusText()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		data["points"] = D.account_balance
	data["away"] = SSshuttle.supply.getDockedId() == "supply_away"
	data["self_paid"] = self_paid
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	data["can_send"] = can_send
	data["can_approve_requests"] = can_approve_requests
	var/message = "Remember to stamp and send back the supply manifests."
	if(SSshuttle.centcom_message)
		message = SSshuttle.centcom_message
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	data["message"] = message
	//NSV13 - Cargo Sleaker UI - Start
	var/cart_list = list()
	for(var/datum/supply_order/order in SSshuttle.shoppinglist)
		if(cart_list[order.pack.name])
			cart_list[order.pack.name][1]["amount"]++
			cart_list[order.pack.name][1]["cost"] += order.get_final_cost()
			if(!isnull(order.paying_account))
				cart_list[order.pack.name][1]["paid"]++
			continue

		cart_list[order.pack.name] = list(list(
			"object" = order.pack.name,
			"cost" = order.get_final_cost(),
			"id" = order.id,
			"amount" = 1,
			"orderer" = order.orderer,
			"paid" = !isnull(order.paying_account) ? 1 : 0, //number of orders purchased privatly
		))
	data["cart"] = list()
	for(var/item_id in cart_list)
		data["cart"] += cart_list[item_id]
	//NSV13 - Cargo Sleaker UI - Stop

	data["requests"] = list()
	for(var/datum/supply_order/SO in SSshuttle.requestlist)
		data["requests"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.get_cost(),
			"orderer" = SO.orderer,
			"reason" = SO.reason,
			"id" = SO.id
		))

	return data

/obj/machinery/computer/cargo/ui_static_data(mob/user)
	var/list/data = list()
	data["requestonly"] = requestonly
	data["supplies"] = list()
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && !(obj_flags & EMAGGED)) || (P.contraband && !contraband) || (P.special && !P.special_enabled) || P.DropPodOnly)
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.get_cost(),
			"id" = pack,
			"desc" = P.desc || P.name, // If there is a description, use it. Otherwise use the pack's name.
			"small_item" = P.small_item,
			"access" = P.access
		))
	return data

/obj/machinery/computer/cargo/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				say(safety_warning)
				return
			if(SSshuttle.supplyBlocked)
				say(blockade_warning)
				return
			//NSV13 - Cargo Sleaker UI - Start
			//Make an copy of the cart before its cleared by the shuttle
			var/list/cart_list = list()
			for(var/datum/supply_order/order in SSshuttle.shoppinglist)
				if(cart_list[order.pack.name])
					cart_list[order.pack.name]["amount"]++
					continue
				cart_list[order.pack.name] = list(
					"order" = order,
					"amount" = 1
				)
			//NSV13 - Cargo Sleaker UI - Stop
			if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.supply.export_categories = get_export_categories()
				SSshuttle.moveShuttle("supply", "supply_away", TRUE)
				say("The supply shuttle is departing.")
				investigate_log("[key_name(usr)] sent the supply shuttle away.", INVESTIGATE_CARGO)
			else
				investigate_log("[key_name(usr)] called the supply shuttle.", INVESTIGATE_CARGO)
				say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle("supply", "supply_home", TRUE)
			//NSV13 - Cargo Sleaker UI - Start
			if(!length(cart_list))
				return TRUE

			//create the paper from the cart list
			var/obj/item/paper/requisition_paper = new(get_turf(src))
			requisition_paper.name = "requisition form"
			requisition_paper.info += "<h2>[GLOB.station_name] Supply Requisition</h2>"
			requisition_paper.info += "<hr/>"
			requisition_paper.info += "Time of Order: [station_time_timestamp()]<br/>"
			for(var/order_name in cart_list)
				var/datum/supply_order/order = cart_list[order_name]["order"]
				requisition_paper.info += "[cart_list[order_name]["amount"]] [order.pack.name]("
				requisition_paper.info += "Access Restrictions: [get_access_desc(order.pack.access)])</br>"
			requisition_paper.update_icon()
			//NSV13 - Cargo Sleaker UI - Stop
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			if(SSshuttle.supplyBlocked)
				say(blockade_warning)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != "supply_away")
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				say("The supply shuttle has been loaned to CentCom.")
				. = TRUE
		if("add")
			if(!COOLDOWN_FINISHED(src, order_cooldown))
				return
			//NSV13 - Cargo Sleaker UI - Start
			return add_item(params)
		if("add_by_name")
			var/supply_pack_id = name_to_id(params["order_name"])
			if(!supply_pack_id)
				return
			return add_item(list("id" = supply_pack_id, "amount" = 1))
		if("remove")
			var/order_name = params["order_name"]
			//try removing atleast one item with the specified name.
			//also we create an copy of the cart list else we would get runtimes when removing & iterating over the same SSshuttle.shoppinglist
			var/list/shopping_cart = SSshuttle.shoppinglist.Copy()
			for(var/datum/supply_order/order in shopping_cart)
				if(order.pack.name != order_name)
					continue
				if(remove_item(list("id" = order.id)))
					return TRUE
			return TRUE
		if("modify")
			var/order_name = params["order_name"]
			//clear out all orders with the above mentioned order_name name to make space for the new amount
			var/list/shopping_cart = SSshuttle.shoppinglist.Copy() //we operate on the list copy else we would get runtimes when removing & iterating over the same SSshuttle.shoppinglist
			for(var/datum/supply_order/order in shopping_cart) //find corresponding order id for the order name
				if(order.pack.name == order_name)
					remove_item(list("id" = "[order.id]"))
			//now add the new amount stuff
			var/amount = text2num(params["amount"])
			if(amount == 0)
				return TRUE
			var/supply_pack_id = name_to_id(order_name) //map order name to supply pack id for adding
			if(!supply_pack_id)
				return
			return add_item(list("id" = supply_pack_id, "amount" = amount))
		if("clear")
			//create copy of list else we will get runtimes when iterating & removing items on the same list SSshuttle.shoppinglist
			var/list/shopping_cart = SSshuttle.shoppinglist.Copy()
			for(var/datum/supply_order/cancelled_order in shopping_cart)
				remove_item(list("id" = "[cancelled_order.id]")) //remove order
			//NSV13 - Cargo Sleaker UI - Stop
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					SSshuttle.shoppinglist += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					. = TRUE
					break
		if("denyall")
			SSshuttle.requestlist.Cut()
			. = TRUE
		if("toggleprivate")
			self_paid = !self_paid
			. = TRUE
	if(.)
		post_signal("supply")

/obj/machinery/computer/cargo/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	frequency.post_signal(src, status_signal)

//NSV13 - Cargo Sleaker UI - Start
/**
 * adds an supply pack to the checkout cart
 * * params - an list with id of the supply pack to add to the cart as its only element
 */
/obj/machinery/computer/cargo/proc/add_item(params)
	var/id = params["id"]
	id = text2path(id) || id
	var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
	if(!istype(pack))
		CRASH("Unknown supply pack id given by order console ui. ID: [params["id"]]")
	if((pack.hidden && !(obj_flags & EMAGGED)) || (pack.contraband && !contraband) || pack.DropPodOnly || (pack.special && !pack.special_enabled))
		return

	var/name = "*None Provided*"
	var/rank = "*None Provided*"
	var/ckey = usr.ckey
	if(ishuman(usr))
		var/mob/living/carbon/human/human = usr
		name = human.get_authentification_name()
		rank = human.get_assignment(hand_first = TRUE)
	else if(issilicon(usr))
		name = usr.real_name
		rank = "Silicon"

	var/datum/bank_account/account
	if(self_paid && isliving(usr))
		var/mob/living/living_user = usr
		var/obj/item/card/id/id_card = living_user.get_idcard(TRUE)
		if(!istype(id_card))
			say("No ID card detected.")
			return
		account = id_card.registered_account
		if(!istype(account))
			say("Invalid bank account.")
			return

	var/reason = ""
	if(requestonly && !self_paid)
		reason = tgui_input_text(usr, "Reason", name)
		if(isnull(reason))
			return

	var/amount = params["amount"]
	for(var/count in 1 to amount)
		var/datum/supply_order/SO = new(pack = pack, orderer = name, orderer_rank = rank, orderer_ckey = ckey, reason = reason, paying_account = account)
		if(requestonly && !self_paid)
			SSshuttle.requestlist += SO
		else
			SSshuttle.shoppinglist += SO

	if(self_paid)
		say("Order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
	if(requestonly && message_cooldown < world.time)
		var/message = amount == 1 ? "A new order has been requested." : "[amount] order has been requested."
		radio.talk_into(src, message, RADIO_CHANNEL_SUPPLY)
		message_cooldown = world.time + 30 SECONDS
	. = TRUE

/**
 * removes an item from the checkout cart
 * * params - an list with the id of the cart item to remove as its only element
 */
/obj/machinery/computer/cargo/proc/remove_item(params)
	var/id = text2num(params["id"])
	for(var/datum/supply_order/order in SSshuttle.shoppinglist)
		if(order.id != id)
			continue
		SSshuttle.shoppinglist -= order
		. = TRUE
		break

/**
 * maps the ordename displayed on the ui to its supply pack id
 * * order_name - the name of the order
 */
/obj/machinery/computer/cargo/proc/name_to_id(order_name)
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/supply = SSshuttle.supply_packs[pack]
		if(order_name == supply.name)
			return pack
	return null
//NSV13 - Cargo Sleaker UI - Stop
