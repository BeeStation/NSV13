/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "coin press"
	icon = 'icons/obj/economy.dmi'
	icon_state = "coinpress0"
	density = TRUE
	input_dir = EAST
	ui_x = 300
	ui_y = 250

	var/produced_coins = 0 // how many coins the machine has made in it's last cycle
	var/processing = FALSE
	var/chosen = /datum/material/iron //which material will be used to make coins
<<<<<<< HEAD
=======
	var/coinsToProduce = 10
	speed_process = TRUE
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36


/obj/machinery/mineral/mint/Initialize()
	. = ..()
<<<<<<< HEAD
	AddComponent(/datum/component/material_container, list(
		/datum/material/iron,
		/datum/material/plasma,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/uranium,
		/datum/material/titanium,
		/datum/material/diamond,
		/datum/material/bananium,
		/datum/material/plastic
	), MINERAL_MATERIAL_AMOUNT * 75, FALSE, /obj/item/stack)
	chosen = getmaterialref(chosen)
=======
	AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/plasma, /datum/material/silver, /datum/material/gold, /datum/material/uranium, /datum/material/diamond, /datum/material/bananium), MINERAL_MATERIAL_AMOUNT * 50, FALSE, /obj/item/stack)
	chosen =  getmaterialref(chosen)
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36


/obj/machinery/mineral/mint/process()
	var/turf/T = get_step(src, input_dir)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

<<<<<<< HEAD
	for(var/obj/item/stack/O in T)
		var/inserted = materials.insert_item(O)
		if(inserted)
			qdel(O)

	if(processing)
		var/datum/material/M = chosen

		if(!M)
			processing = FALSE
			icon_state = "coinpress0"
			return

		icon_state = "coinpress1"
		var/coin_mat = MINERAL_MATERIAL_AMOUNT

		for(var/sheets in 1 to 2)
			if(materials.use_amount_mat(coin_mat, chosen))
				for(var/coin_to_make in 1 to 5)
					create_coins()
					produced_coins++
			else
				var/found_new = FALSE
				for(var/datum/material/inserted_material in materials.materials)
					var/amount = materials.get_material_amount(inserted_material)
=======
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/obj/item/stack/sheet/O in T)
		materials.insert_stack(O, O.amount)

/obj/machinery/mineral/mint/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/dat = "<b>Coin Press</b><br>"

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/datum/material/M in materials.materials)
		var/amount = materials.get_material_amount(M)
		if(!amount && chosen != M)
			continue
		dat += "<br><b>[M.name] amount:</b> [amount] cm<sup>3</sup> "
		if (chosen == M)
			dat += "<b>Chosen</b>"
		else
			dat += "<A href='?src=[REF(src)];choose=[REF(M)]'>Choose</A>"

	var/datum/material/M = chosen

	dat += "<br><br>Will produce [coinsToProduce] [lowertext(M.name)] coins if enough materials are available.<br>"
	dat += "<A href='?src=[REF(src)];chooseAmt=-10'>-10</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=-5'>-5</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=-1'>-1</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=1'>+1</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=5'>+5</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=10'>+10</A> "

	dat += "<br><br>In total this machine produced <font color='green'><b>[newCoins]</b></font> coins."
	dat += "<br><A href='?src=[REF(src)];makeCoins=[1]'>Make coins</A>"
	user << browse(dat, "window=mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(processing==1)
		to_chat(usr, "<span class='notice'>The machine is processing.</span>")
		return
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(href_list["choose"])
		var/datum/material/new_material = locate(href_list["choose"])
		if(istype(new_material))
			chosen = new_material
	if(href_list["chooseAmt"])
		coinsToProduce = CLAMP(coinsToProduce + text2num(href_list["chooseAmt"]), 0, 1000)
	if(href_list["makeCoins"])
		var/temp_coins = coinsToProduce
		processing = TRUE
		icon_state = "coinpress1"
		var/coin_mat = MINERAL_MATERIAL_AMOUNT * 0.2
		var/datum/material/M = chosen
		if(!M || !M.coin_type)
			updateUsrDialog()
			return

		while(coinsToProduce > 0 && materials.use_amount_mat(coin_mat, chosen))
			create_coins(M.coin_type)
			coinsToProduce--
			newCoins++
			src.updateUsrDialog()
			sleep(5)
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36

					if(amount)
						chosen = inserted_material
						found_new = TRUE

				if(!found_new)
					processing = FALSE
	else
		icon_state = "coinpress0"

/obj/machinery/mineral/mint/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mint", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/mineral/mint/ui_data()
	var/list/data = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	for(var/datum/material/inserted_material in materials.materials)
		var/amount = materials.get_material_amount(inserted_material)

		if(!amount)
			continue

		data["inserted_materials"] += list(list(
			"material" = inserted_material.name,
			"amount" = amount
		))

		if(chosen == inserted_material)
			data["chosen_material"] = inserted_material.name

	data["produced_coins"] = produced_coins
	data["processing"] = processing

	return data;

/obj/machinery/mineral/mint/ui_act(action, params, datum/tgui/ui)
	switch(action)
		if ("startpress")
			if (!processing)
				produced_coins = 0
			processing = TRUE
		if ("stoppress")
			processing = FALSE
		if ("changematerial")
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			for(var/datum/material/mat in materials.materials)
				if (params["material_name"] == mat.name)
					chosen = mat

/obj/machinery/mineral/mint/proc/create_coins()
	var/turf/T = get_step(src,output_dir)
	var/temp_list = list()
	temp_list[chosen] = 400
	if(T)
		var/obj/item/O = new /obj/item/coin(src)
		var/obj/item/storage/bag/money/B = locate(/obj/item/storage/bag/money, T)
		O.set_custom_materials(temp_list)
		if(!B)
			B = new /obj/item/storage/bag/money(src)
			unload_mineral(B)
		O.forceMove(B)
