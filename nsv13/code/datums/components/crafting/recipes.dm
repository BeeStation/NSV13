/datum/crafting_recipe/hungrypowder
	name = "Hungry Gunpowder Bag"
	result = /obj/item/powder_bag/hungry
	reqs = list(/obj/item/powder_bag = 1,
				/obj/item/reagent_containers/food/snacks/burger/plain = 1,
				/datum/reagent/uranium/radium = 5)
	time = 30
	category = CAT_MISC
	always_available = FALSE
