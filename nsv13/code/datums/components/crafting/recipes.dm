/datum/crafting_recipe/hungrypowder
	name = "Hungry Gunpowder Bag"
	result = /obj/item/powder_bag/hungry
	reqs = list(/obj/item/powder_bag = 1,
				/obj/item/reagent_containers/food/snacks/burger/plain = 1,
				/datum/reagent/uranium/radium = 5)
	time = 30
	category = CAT_MISC
	always_available = FALSE

/datum/crafting_recipe/plush_warhead
	name = "Plush-filled warhead"
	result = /obj/item/ship_weapon/parts/missile/warhead/plushtide
	time = 50
	reqs = list(/obj/item/stack/sheet/iron = 10,
				/obj/item/stack/cable_coil = 10,
				/obj/item/stock_parts/matter_bin = 2,
				/obj/item/toy/plush = 8)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_WIRECUTTER, TOOL_MULTITOOL)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/medbot/catmedbot
	name = "MediKitty"
	result = /mob/living/simple_animal/bot/medbot/catmedbot
	reqs = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/firstaid = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/clothing/head/kitty = 1
	)
	time = 40
	category = CAT_ROBOT

/datum/crafting_recipe/coffee_cartridge
	name = "Bootleg Coffee Cartridge"
	result = /obj/item/coffee_cartridge/bootleg
	time = 2 SECONDS
	reqs = list(
		/obj/item/blank_coffee_cartridge = 1,
		/datum/reagent/toxin/coffeepowder = 10,
	)
	category = CAT_MISC
