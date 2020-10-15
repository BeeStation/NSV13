///////Munitions Related Misc Machinery Goes Here//////

///////TELECOMMS//////

/obj/machinery/telecomms/server/presets/munitions
	id = "Munitions Server"
	freq_listening = list(FREQ_MUNITIONS)
	autolinkers = list("munitions")

//////SUIT STORAGE//////

/obj/machinery/suit_storage_unit/pilot
	suit_type = /obj/item/clothing/suit/space/hardsuit/pilot
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double


///////WARDROBE///////

/obj/machinery/vending/wardrobe/muni_wardrobe //Missing so many icons
	name = "MuniDrobe"
	desc = "A vending machine for dispensing Munitions department uniforms and gear."
	icon = 'nsv13/icons/obj/custom_vendors.dmi'
	icon_state = "munidrobe"
	product_ads = "High-vis, while retaining stylish black!;Orange is the new Puce!" //cringe, someone send help from marketing
	vend_reply = "Thank you for using the MuniDrobe!"
	light_color = LIGHT_COLOR_ORANGE
	products = list(/obj/item/storage/backpack/duffelbag/munitions = 3,
					/obj/item/storage/backpack/munitions = 3,
					/obj/item/storage/backpack/satchel/munitions = 3,
					/obj/item/clothing/under/ship/decktech = 3,
					/obj/item/clothing/under/rank/munitions_tech = 3,
					/obj/item/clothing/under/ship/pilot = 3,
					/obj/item/clothing/suit/hazardvest = 3,
					/obj/item/clothing/suit/ship/munitions_jacket = 3,
					/obj/item/clothing/shoes/jackboots = 5,
					/obj/item/clothing/gloves/color/black = 5)
	premium = list(/obj/item/clothing/head/helmet/decktech = 3,
					/obj/item/clothing/head/beret/ship/pilot = 3,
					/obj/item/clothing/ears/earmuffs = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/muni_wardrobe
	payment_department = ACCOUNT_MUN
/obj/item/vending_refill/wardrobe/muni_wardrobe
	machine_name = "MuniDrobe"
