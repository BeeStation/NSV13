/**
 * This file contains ALL the Replicator recipes.
 * If you want to add a new recipe to the Replicator, add it here.
 *
 * Category Explanation:
 * * "initial" is the category that will be unlocked by default.
 * * "Nutritional Supplements" is the category for all the recipes that are basically Tier 1 stuff, IE: A microwaved egg, things that don't need outside information to make.
 * * "Basic Dishes" is the category for all the recipes that are basically Tier 2 stuff, IE: A burger or a steak, things that need some thought to make but anyone can easily figure it out.
 * * "Complex Dishes" is the category for all the recipes that are basically Tier 3 stuff, IE: A pizza, things that need a lot of thought put into producing it.
 * * "Exotic Dishes" is the category for all the exotic recipes.
 */

/datum/design/replicator
	var/cost
	var/list/alt_name = list()

/datum/design/replicator/tier1/boiledegg
	name = "Boiled egg"
	id = "boiledegg"
	alt_name = list("egg")
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/boiledegg
	category = list("initial", "Nutritional Supplements")

/datum/design/replicator/tier1/boiledrice
	name = "Boiled rice"
	id = "boiledrice"
	alt_name = list("rice")
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/salad/boiledrice
	category = list("initial", "Nutritional Supplements")

/datum/design/replicator/tier1/rationpack
	name = "Ration pack"
	id = "rationpack"
	alt_name = list("nutrients", "nutritional supplement")
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/rationpack
	category = list("initial", "Nutritional Supplements")

/datum/design/replicator/tier1/drinkingglass
	name = "Drinking glass"
	id = "drinkingglass"
	alt_name = list("glass")
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass
	category = list("initial", "Nutritional Supplements")

/datum/design/replicator/tier1/rawegg
	name = "Raw egg"
	id = "rawegg"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/egg
	category = list("initial", "Nutritional Supplements")

/datum/design/replicator/tier1/tea
	name = "Tea Earl Grey"
	id = "tea"
	build_type = REPLICATOR
	category = list("initial", "Nutritional Supplements")

/datum/design/replicator/tier1/surprise
	name = "Surprise me"
	id = "surprise"
	alt_name = list("you choose", "something", "i dont care")
	build_type = REPLICATOR
	category = list("initial", "Nutritional Supplements")

/datum/design/replicator/tier1/tier2disk
	name = "Pattern Upgrade disk (Tier 2)"
	id = "tier2disk"
	build_type = REPLICATOR
	build_path = /obj/item/disk/design_disk/replicator/tier2
	cost = 2000 // 2000 Biomass in order to unlock the Tier 2 recipes
	category = list("initial", "Nutritional Supplements")

/datum/design/replicator/tier2/dough
	name = "Dough"
	id = "dough"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/dough
	category = list("Basic Dishes")

/datum/design/replicator/tier2/milk
	name = "Milk"
	id = "milkies"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/condiment/milk
	category = list("Basic Dishes")

/datum/design/replicator/tier2/soymilk
	name = "Soy milk"
	id = "soymilk"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/condiment/soymilk
	category = list("Basic Dishes")

/datum/design/replicator/tier2/burger
	name = "Burger"
	id = "burger"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/burger/plain
	category = list("Basic Dishes")

/datum/design/replicator/tier2/tofuburger
	name = "Tofu burger"
	id = "tofuburger"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/burger/tofu
	category = list("Basic Dishes")

/datum/design/replicator/tier2/flour
	name = "Flour"
	id = "flour"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/condiment/flour
	category = list("Basic Dishes")

/datum/design/replicator/tier2/steak
	name = "Steak"
	id = "steak"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/meat/steak/plain
	category = list("Basic Dishes")

/datum/design/replicator/tier2/fries
	name = "Fries"
	id = "fries"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/fries
	category = list("Basic Dishes")

/datum/design/replicator/tier2/onionrings
	name = "Onion rings"
	id = "onionrings"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/onionrings
	category = list("Basic Dishes")

/datum/design/replicator/tier2/friedeggs
	name = "Fried eggs"
	id = "friedeggs"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/friedegg
	category = list("Basic Dishes")

/datum/design/replicator/tier2/pancakes
	name = "Pancakes"
	id = "pancakes"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/pancakes
	category = list("Basic Dishes")

/datum/design/replicator/tier2/coffee
	name = "Coffee"
	id = "coffee"
	build_type = REPLICATOR
	category = list("Basic Dishes")

/datum/design/replicator/tier2/meatslab
	name = "Meat slab"
	id = "meatslab"
	alt_name = list("slab of meat")
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/meat/slab
	category = list("Basic Dishes")

/datum/design/replicator/tier2/tier3disk
	name = "Pattern Upgrade disk (Tier 3)"
	id = "tier3disk"
	build_type = REPLICATOR
	build_path = /obj/item/disk/design_disk/replicator/tier3
	cost = 3000 // 3000 Biomass in order to unlock the Tier 3 recipes
	category = list("Basic Dishes")

/datum/design/replicator/tier3/cakebatter
	name = "Cake batter"
	id = "cakebatter"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/cakebatter
	category = list("Complex Dishes")

/datum/design/replicator/tier3/enzymes
	name = "Enzymes"
	id = "enzymes"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/condiment/enzyme
	category = list("Complex Dishes")

/datum/design/replicator/tier3/cheesewheel
	name = "Cheese wheel"
	id = "cheesywheely"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/store/cheesewheel
	category = list("Complex Dishes")

/datum/design/replicator/tier3/cheesepizza
	name = "Cheese pizza"
	id = "cheesepizza"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/pizzaslice/margherita
	category = list("Complex Dishes")

/datum/design/replicator/tier3/meatpizza
	name = "Meat pizza"
	id = "meatpizza"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/pizzaslice/meat
	category = list("Complex Dishes")

/datum/design/replicator/tier3/mushroompizza
	name = "Mushroom pizza"
	id = "mushroompizza"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/pizzaslice/mushroom
	category = list("Complex Dishes")

/datum/design/replicator/tier3/veggiepizza
	name = "Vegetable pizza"
	id = "veggiepizza"
	alt_name = list("veggie pizza")
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/pizzaslice/vegetable
	category = list("Complex Dishes")

/datum/design/replicator/tier3/pineapplepizza
	name = "Pineapple pizza"
	id = "pineapplepizza"
	alt_name = list("an insult to pizza")
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/pizzaslice/pineapple
	category = list("Complex Dishes")

/datum/design/replicator/tier3/donkpizza
	name = "Donkpocket pizza"
	id = "donkpizza"
	alt_name = list("donk pizza")
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/pizzaslice/donkpocket
	category = list("Complex Dishes")

/datum/design/replicator/tier3/tier4disk
	name = "Pattern Upgrade disk (Tier 4)"
	id = "tier4disk"
	build_type = REPLICATOR
	build_path = /obj/item/disk/design_disk/replicator/tier4
	cost = 4000 // 4000 Biomass in order to unlock the Tier 3 recipes
	category = list("Complex Dishes")

/datum/design/replicator/tier4/honkdae
	name = "Honkdae"
	id = "honkdae"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/honkdae
	category = list("Exotic Dishes")

/datum/design/replicator/tier4/wingfangchu
	name = "Wing fang chu"
	id = "wingfangchu"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/soup/wingfangchu
	category = list("Exotic Dishes")

/datum/design/replicator/tier4/clownstears
	name = "Clown's tears"
	id = "clownstears"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/soup/clownstears
	category = list("Exotic Dishes")

/datum/design/replicator/tier4/mimeburger
	name = "Mime burger"
	id = "mimeburger"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/burger/mime
	category = list("Exotic Dishes")

/datum/design/replicator/tier4/clownburger
	name = "Clown burger"
	id = "clownburger"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/burger/clown
	category = list("Exotic Dishes")

/datum/design/replicator/tier4/spellburger
	name = "Magic burger"
	id = "magicburger"
	build_type = REPLICATOR
	build_path = /obj/item/reagent_containers/food/snacks/burger/spell
	category = list("Exotic Dishes")

/datum/design/replicator/tier4/active_iguana
	name = "Activate iguana"
	id = "activeiguana"
	build_type = REPLICATOR
	category = list("Exotic Dishes")

/datum/design/replicator/tier4/deactive_iguana
	name = "Deactivate iguana"
	id = "deactiveiguana"
	build_type = REPLICATOR
	category = list("Exotic Dishes")
