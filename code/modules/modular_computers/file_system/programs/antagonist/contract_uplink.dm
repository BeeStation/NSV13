/datum/computer_file/program/contract_uplink
<<<<<<< HEAD
	filename = "contractor uplink"
	filedesc = "Syndicate Contractor Uplink"
	program_icon_state = "assign"
=======
	filename = "contract uplink"
	filedesc = "Syndicate Contract Uplink"
	program_icon_state = "hostile"
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
	extended_desc = "A standard, Syndicate issued system for handling important contracts while on the field."
	size = 10
	requires_ntnet = 0
	available_on_ntnet = 0
	unsendable = 1
	undeletable = 1
	tgui_id = "synd_contract"
	ui_style = "syndicate"
	ui_x = 600
	ui_y = 600
	var/error = ""
	var/page = CONTRACT_UPLINK_PAGE_CONTRACTS
<<<<<<< HEAD
	var/assigned = FALSE
=======
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36

/datum/computer_file/program/contract_uplink/run_program(var/mob/living/user)
	. = ..(user)

/datum/computer_file/program/contract_uplink/ui_act(action, params)
	if(..())
		return 1

	var/mob/living/user = usr
	var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = computer.all_components[MC_HDD]

	switch(action)
		if("PRG_contract-accept")
			var/contract_id = text2num(params["contract_id"])

			// Set as the active contract
<<<<<<< HEAD
			hard_drive.traitor_data.contractor_hub.assigned_contracts[contract_id].status = CONTRACT_STATUS_ACTIVE
			hard_drive.traitor_data.contractor_hub.current_contract = hard_drive.traitor_data.contractor_hub.assigned_contracts[contract_id]
			
			program_icon_state = "single_contract"
=======
			hard_drive.traitor_data.assigned_contracts[contract_id].status = CONTRACT_STATUS_ACTIVE
			hard_drive.traitor_data.current_contract = hard_drive.traitor_data.assigned_contracts[contract_id]
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
			return 1
		if("PRG_login")
			var/datum/antagonist/traitor/traitor_data = user.mind.has_antag_datum(/datum/antagonist/traitor)

<<<<<<< HEAD
			// Bake their data right into the hard drive, or we don't allow non-antags gaining access to an unused
=======
			// Bake their data right into the hard drive, or we don't allow non-antags gaining access to unused
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
			// contract system.
			// We also create their contracts at this point.
			if (traitor_data)
				// Only play greet sound, and handle contractor hub when assigning for the first time.
<<<<<<< HEAD
				if (!traitor_data.contractor_hub)
=======
				if (!traitor_data.assigned_contracts.len)
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
					user.playsound_local(user, 'sound/effects/contractstartup.ogg', 100, 0)
					traitor_data.contractor_hub = new
					traitor_data.contractor_hub.create_hub_items()

<<<<<<< HEAD
				// Stops any topic exploits such as logging in multiple times on a single system.
				if (!assigned)
					traitor_data.contractor_hub.create_contracts(traitor_data.owner)

					hard_drive.traitor_data = traitor_data

					program_icon_state = "contracts"
					assigned = TRUE
			return 1
		if("PRG_call_extraction")
			if (hard_drive.traitor_data.contractor_hub.current_contract.status != CONTRACT_STATUS_EXTRACTING)
				if (hard_drive.traitor_data.contractor_hub.current_contract.handle_extraction(user))
					user.playsound_local(user, 'sound/effects/confirmdropoff.ogg', 100, 1)
					hard_drive.traitor_data.contractor_hub.current_contract.status = CONTRACT_STATUS_EXTRACTING

					program_icon_state = "extracted"
=======
				traitor_data.create_contracts()

				hard_drive.traitor_data = traitor_data
			return 1
		if("PRG_call_extraction")
			if (hard_drive.traitor_data.current_contract.status != CONTRACT_STATUS_EXTRACTING)
				if (hard_drive.traitor_data.current_contract.handle_extraction(user))
					user.playsound_local(user, 'sound/effects/confirmdropoff.ogg', 100, 1)
					hard_drive.traitor_data.current_contract.status = CONTRACT_STATUS_EXTRACTING
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
				else
					user.playsound_local(user, 'sound/machines/uplinkerror.ogg', 50)
					error = "Either both you or your target aren't at the dropoff location, or the pod hasn't got a valid place to land. Clear space, or make sure you're both inside."
			else 
				user.playsound_local(user, 'sound/machines/uplinkerror.ogg', 50)
				error = "Already extracting... Place the target into the pod. If the pod was destroyed, you will need to cancel this contract."

			return 1
		if("PRG_contract_abort")
<<<<<<< HEAD
			var/contract_id = hard_drive.traitor_data.contractor_hub.current_contract.id

			hard_drive.traitor_data.contractor_hub.current_contract = null
			hard_drive.traitor_data.contractor_hub.assigned_contracts[contract_id].status = CONTRACT_STATUS_ABORTED

			program_icon_state = "contracts"

			return 1
		if("PRG_redeem_TC")
			if (hard_drive.traitor_data.contractor_hub.contract_TC_to_redeem)
				var/obj/item/stack/telecrystal/crystals = new /obj/item/stack/telecrystal(get_turf(user), 
															hard_drive.traitor_data.contractor_hub.contract_TC_to_redeem)
=======
			var/contract_id = hard_drive.traitor_data.current_contract.id

			hard_drive.traitor_data.current_contract = null
			hard_drive.traitor_data.assigned_contracts[contract_id].status = CONTRACT_STATUS_ABORTED

			return 1
		if("PRG_redeem_TC")
			if (hard_drive.traitor_data.contract_TC_to_redeem)
				var/obj/item/stack/telecrystal/crystals = new /obj/item/stack/telecrystal(get_turf(user), 
															hard_drive.traitor_data.contract_TC_to_redeem)
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					if(H.put_in_hands(crystals))
						to_chat(H, "<span class='notice'>Your payment materializes into your hands!</span>")
					else
						to_chat(user, "<span class='notice'>Your payment materializes onto the floor.</span>")

<<<<<<< HEAD
				hard_drive.traitor_data.contractor_hub.contract_TC_payed_out += hard_drive.traitor_data.contractor_hub.contract_TC_to_redeem
				hard_drive.traitor_data.contractor_hub.contract_TC_to_redeem = 0
=======
				hard_drive.traitor_data.contract_TC_payed_out += hard_drive.traitor_data.contract_TC_to_redeem
				hard_drive.traitor_data.contract_TC_to_redeem = 0
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
				return 1
			else
				user.playsound_local(user, 'sound/machines/uplinkerror.ogg', 50)
			return 1
		if ("PRG_clear_error")
			error = ""
		if("PRG_contractor_hub")
			page = CONTRACT_UPLINK_PAGE_HUB
<<<<<<< HEAD
			program_icon_state = "store"
		if ("PRG_hub_back")
			page = CONTRACT_UPLINK_PAGE_CONTRACTS
			program_icon_state = "contracts"
=======
		if ("PRG_hub_back")
			page = CONTRACT_UPLINK_PAGE_CONTRACTS
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
		if ("buy_hub")
			if (hard_drive.traitor_data.owner.current == user)
				var/item = params["item"]

				for (var/datum/contractor_item/hub_item in hard_drive.traitor_data.contractor_hub.hub_items)
					if (hub_item.name == item)
						hub_item.handle_purchase(hard_drive.traitor_data.contractor_hub, user)
			else
				error = "Invalid user... You weren't recognised as the user of this system."

/datum/computer_file/program/contract_uplink/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = computer.all_components[MC_HDD]
<<<<<<< HEAD
	var/screen_to_be = null
=======
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36

	if (hard_drive && hard_drive.traitor_data != null)
		var/datum/antagonist/traitor/traitor_data = hard_drive.traitor_data
		data = get_header_data()

<<<<<<< HEAD
		if (traitor_data.contractor_hub.current_contract)
			data["ongoing_contract"] = TRUE
			screen_to_be = "single_contract"
			if (traitor_data.contractor_hub.current_contract.status == CONTRACT_STATUS_EXTRACTING)
				data["extraction_enroute"] = TRUE
				screen_to_be = "extracted"
		
		data["logged_in"] = TRUE
		data["station_name"] = GLOB.station_name
		data["redeemable_tc"] = traitor_data.contractor_hub.contract_TC_to_redeem
=======
		if (traitor_data.current_contract)
			data["ongoing_contract"] = TRUE
			if (traitor_data.current_contract.status == CONTRACT_STATUS_EXTRACTING)
				data["extraction_enroute"] = TRUE
		
		data["logged_in"] = TRUE
		data["station_name"] = GLOB.station_name
		data["redeemable_tc"] = traitor_data.contract_TC_to_redeem
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
		data["contract_rep"] = traitor_data.contractor_hub.contract_rep

		data["page"] = page

		data["error"] = error

		for (var/datum/contractor_item/hub_item in traitor_data.contractor_hub.hub_items)
			data["contractor_hub_items"] += list(list(
				"name" = hub_item.name,
				"desc" = hub_item.desc,
				"cost" = hub_item.cost,
				"limited" = hub_item.limited,
				"item_icon" = hub_item.item_icon
			))

<<<<<<< HEAD
		for (var/datum/syndicate_contract/contract in traitor_data.contractor_hub.assigned_contracts)
			data["contracts"] += list(list(
				"target" = contract.contract.target,
				"target_rank" = contract.target_rank,
=======
		for (var/datum/syndicate_contract/contract in traitor_data.assigned_contracts)
			data["contracts"] += list(list(
				"target" = contract.contract.target,
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
				"payout" = contract.contract.payout,
				"payout_bonus" = contract.contract.payout_bonus,
				"dropoff" = contract.contract.dropoff,
				"id" = contract.id,
				"status" = contract.status
			))

		var/direction
<<<<<<< HEAD
		if (traitor_data.contractor_hub.current_contract)
=======
		if (traitor_data.current_contract)
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
			var/turf/curr = get_turf(user)
			var/turf/dropoff_turf 
			data["current_location"] = "[get_area_name(curr, TRUE)]"
			
<<<<<<< HEAD
			for (var/turf/content in traitor_data.contractor_hub.current_contract.contract.dropoff.contents)
=======
			for (var/turf/content in traitor_data.current_contract.contract.dropoff.contents)
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
				if (isturf(content))
					dropoff_turf = content
					break

			if(curr.z == dropoff_turf.z) //Direction calculations for same z-level only
				direction = uppertext(dir2text(get_dir(curr, dropoff_turf))) //Direction text (East, etc). Not as precise, but still helpful.
<<<<<<< HEAD
				if(get_area(user) == traitor_data.contractor_hub.current_contract.contract.dropoff)
=======
				if(get_area(user) == traitor_data.current_contract.contract.dropoff)
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
					direction = "LOCATION CONFIRMED"
			else
				direction = "???"

			data["dropoff_direction"] = direction
<<<<<<< HEAD

		if (page == CONTRACT_UPLINK_PAGE_HUB)
			screen_to_be = "store"
		
		if (!screen_to_be)
			screen_to_be = "contracts"
	else
		data["logged_in"] = FALSE
		
	if (!screen_to_be)
		screen_to_be = "assign"

	program_icon_state = screen_to_be
	update_computer_icon()
=======
	else
		data["logged_in"] = FALSE
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
	return data
