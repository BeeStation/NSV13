/obj/machinery/computer/stockexchange
	name = "stock exchange computer"
	desc = "A console that connects to the galactic stock market. Stocks trading involves substantial risk of loss and is not suitable for every cargo technician."
	icon = 'icons/obj/computer.dmi'
	icon_state = "stockmarket"
	icon_screen = "stocks"
	icon_keyboard = "stockmarket_key"
	var/logged_in = "Cargo Department"
	var/vmode = 1

	var/screen = "stocks"
	var/datum/stock/current_stock = null


	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/stockexchange/Initialize()
	. = ..()
	logged_in = "Cargo Department"

/obj/machinery/computer/stockexchange/attack_hand(mob/user)
	if(..(user))
		return

	//if(!ai_control && issilicon(user))
	//	to_chat(user, SPAN_WARNING("Access Denied."))
	//	return TRUE

	ui_interact(user)

/obj/machinery/computer/stockexchange/proc/balance()
	if(!logged_in)
		return FALSE
	return SSshuttle.points

//! ## MAIN TGUI SCREEN ## !//

/obj/machinery/computer/stockexchange/ui_act(action, params, datum/tgui/ui)
	if(..())
		return TRUE

	switch(action)
		if("logout")
			logged_in = null

		if("stocks_buy")
			var/datum/stock/S = locate(params["share"]) in GLOB.stockExchange.stocks
			if(S)
				buy_some_shares(S, usr)

		if("stocks_sell")
			var/datum/stock/S = locate(params["share"]) in GLOB.stockExchange.stocks
			if(S)
				sell_some_shares(S, usr)

		if("stocks_check")
			screen = "logs"

		if("stocks_archive")
			var/datum/stock/S = locate(params["share"])
			if(S)
				current_stock = S
			//if (logged_in && logged_in != "")
			//	var/list/LR = GLOB.stockExchange.last_read[S]
			//	LR[logged_in] = world.time
				screen = "archive"
		if("stocks_history")
			var/datum/stock/S = locate(params["share"]) in GLOB.stockExchange.stocks
			if(S)
				//current_stock = S
				//screen = "graph"
				S.displayValues(usr)

		if("stocks_backbutton")
			current_stock = null
			screen = "stocks"

		if("stocks_cycle_view")
			vmode++
			if(vmode > 1)
				vmode = 0

/obj/machinery/computer/stockexchange/ui_data(mob/user)
	var/list/data = list()

	data["stationName"] = GLOB.station_name
	data["balance"] = balance()
	data["screen"] = screen

	switch(screen)
		// Main Stocks List
		if("stocks")
			if(vmode)
				data["viewMode"] = "Full"
			else
				data["viewMode"] = "Compressed"

			for(var/datum/stock/S in GLOB.stockExchange.last_read)
				var/list/LR = GLOB.stockExchange.last_read[S]
				if (!(logged_in in LR))
					LR[logged_in] = 0

			data["stocks"] = list()

			if (vmode)
				for (var/datum/stock/S in GLOB.stockExchange.stocks)
					var/mystocks = 0
					if (logged_in && (logged_in in S.shareholders))
						mystocks = S.shareholders[logged_in]

					var/value = 0
					if (!S.bankrupt)
						value = S.current_value

					data["stocks"] += list(list(
						"REF" = REF(S),
						"valueChange" = S.disp_value_change, // > 0 is +, < 0 is -, else its =
						"bankrupt" = S.bankrupt,
						"ID" = S.short_name,
						"Name" = S.name,
						"Value" = value,
						"Owned" = mystocks,
						"Avail" = S.available_shares,
						"Products" = S.products,
					))

					var/news = 0
					if (logged_in)
						var/list/LR = GLOB.stockExchange.last_read[S]
						var/lrt = LR[logged_in]
						for (var/datum/article/A in S.articles)
							if (A.ticks > lrt)
								news = 1
								break
						if (!news)
							for (var/datum/stockEvent/E in S.events)
								if (E.last_change > lrt && !E.hidden)
									news = 1
			else
				for (var/datum/stock/S in GLOB.stockExchange.stocks)
					var/mystocks = 0
					if (logged_in && (logged_in in S.shareholders))
						mystocks = S.shareholders[logged_in]

					var/unification = 0
					if (S.last_unification)
						unification = DisplayTimeText(world.time - S.last_unification)

					data["stocks"] += list(list(
						"REF" = REF(S),
						"bankrupt" = S.bankrupt,
						"ID" = S.short_name,
						"Name" = S.name,
						"Owned" = mystocks,
						"Avail" = S.available_shares,
						"Unification" = unification,
						"Products" = S.products,
					))

					var/news = 0
					if (logged_in)
						var/list/LR = GLOB.stockExchange.last_read[S]
						var/lrt = LR[logged_in]
						for (var/datum/article/A in S.articles)
							if (A.ticks > lrt)
								news = 1
								break
						if (!news)
							for (var/datum/stockEvent/E in S.events)
								if (E.last_change > lrt && !E.hidden)
									news = 1
									break

		// Stocks Logs Screen
		if("logs")
			data["logs"] = list()

			for(var/D in GLOB.stockExchange.logs)
				var/datum/stock_log/L = D

				if (istype(L, /datum/stock_log/buy))
					data["logs"] += list(list(
							"type" = "transaction_bought",
							"time" = L.time,
							"user_name" = L.user_name,
							"stocks" = L.stocks,
							"shareprice" = L.shareprice,
							"money" = L.money,
							"company_name" = L.company_name,
					))
				else if (istype(L, /datum/stock_log/sell))
					data["logs"] += list(list(
							"type" = "transaction_sold",
							"time" = L.time,
							"user_name" = L.user_name,
							"stocks" = L.stocks,
							"shareprice" = L.shareprice,
							"money" = L.money,
							"company_name" = L.company_name,
					))
				else if (istype(L, /datum/stock_log/borrow))
					data["logs"] += list(list(
							"type" = "borrow",
							"time" = L.time,
							"user_name" = L.user_name,
							"stocks" = L.stocks,
							"money" = L.money,
							"company_name" = L.company_name,
					))

		// Archive Screen
		if("archive")
			data["name"] = current_stock.name
			data["events"] = list()
			data["articles"] = list()

			for (var/datum/stockEvent/E in current_stock.events)
				if (E.hidden)
					continue
				data["events"] += list(list(
						"current_title" = E.current_title,
						"current_desc" = E.current_desc,
				))

			for (var/datum/article/A in current_stock.articles)
				data["articles"] += list(list(
						"headline" = A.headline,
						"subtitle" = A.subtitle,
						"article" = A.article,
						"author" = A.author,
						"spacetime" = A.spacetime,
						"outlet" = A.outlet,
				))

		// Stock Graph
		if("graph")
			data["name"] = current_stock.name
			data["maxValue"] = 100
			data["values"] = current_stock.values

	return data

/obj/machinery/computer/stockexchange/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StockExchange")
		ui.set_autoupdate(TRUE)
		ui.open()

//! ## PROCS ## !//

/obj/machinery/computer/stockexchange/proc/sell_some_shares(datum/stock/S, mob/user)
	if(!user || !S)
		return

	var/li = logged_in
	if(!li)
		to_chat(user, "<span class='danger'>No active account on the console!</span>")
		return
	var/b = SSshuttle.points
	var/avail = S.shareholders[logged_in]
	if(!avail)
		to_chat(user, "<span class='danger'>This account does not own any shares of [S.name]!</span>")
		return
	var/price = S.current_value
	var/amt = round(input(user, "How many shares? \n(Have: [avail], unit price: [price])", "Sell shares in [S.name]", 0) as num|null)
	amt = min(amt, S.shareholders[logged_in])

	if(!user || (!(user in range(1, src)) && iscarbon(user)))
		return
	if(!amt)
		return
	if(li != logged_in)
		return
	b = SSshuttle.points
	if(!isnum(b))
		to_chat(user, "<span class='danger'>No active account on the console!</span>")
		return

	var/total = amt * S.current_value
	if(!S.sellShares(logged_in, amt))
		to_chat(user, "<span class='danger'>Could not complete transaction.</span>")
		return
	to_chat(user, "<span class='notice'>Sold [amt] shares of [S.name] at [S.current_value] a share for [total] credits.</span>")
	GLOB.stockExchange.add_log(/datum/stock_log/sell, user.name, S.name, amt, S.current_value, total)

/obj/machinery/computer/stockexchange/proc/buy_some_shares(var/datum/stock/S, var/mob/user)
	if(!user || !S)
		return

	var/li = logged_in
	if(!li)
		to_chat(user, "<span class='danger'>No active account on the console!</span>")
		return
	var/b = balance()
	if(!isnum(b))
		to_chat(user, "<span class='danger'>No active account on the console!</span")
		return
	var/avail = S.available_shares
	var/price = S.current_value
	var/canbuy = round(b / price)
	var/amt = round(input(user, "How many shares? \n(Available: [avail], unit price: [price], can buy: [canbuy])", "Buy shares in [S.name]", 0) as num|null)
	if(!user || (!(user in range(1, src)) && iscarbon(user)))
		return
	if(li != logged_in)
		return
	b = balance()
	if(!isnum(b))
		to_chat(user, "<span class='danger'>No active account on the console!</span>")
		return

	amt = min(amt, S.available_shares, round(b / S.current_value))
	if(!amt)
		return
	if(!S.buyShares(logged_in, amt))
		to_chat(user, "<span class='danger'>Could not complete transaction.</span>")
		return

	var/total = amt * S.current_value
	to_chat(user, "<span class='notice'>Bought [amt] shares of [S.name] at [S.current_value] a share for [total] credits.</span>")
	GLOB.stockExchange.add_log(/datum/stock_log/buy, user.name, S.name, amt, S.current_value,  total)

/obj/machinery/computer/stockexchange/proc/do_borrowing_deal(var/datum/borrow/B, var/mob/user)
	if(B.stock.borrow(B, logged_in))
		to_chat(user, "<span class='notice'>You successfully borrowed [B.share_amount] shares. Deposit: [B.deposit].</span>")
		GLOB.stockExchange.add_log(/datum/stock_log/borrow, user.name, B.stock.name, B.share_amount, B.deposit)
	else
		to_chat(user, "<span class='danger'>Could not complete transaction. Check your account balance.</span>")

/obj/machinery/computer/stockexchange/Topic(href, href_list)
	if(..())
		return TRUE

	if(!usr || (!(usr in range(1, src)) && iscarbon(usr)))
		usr.machine = src

	src.add_fingerprint(usr)
	src.updateUsrDialog()
