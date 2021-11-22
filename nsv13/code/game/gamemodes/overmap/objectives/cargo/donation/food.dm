/datum/overmap_objective/cargo/donation/food 
	name = "Donate food"
	desc = "Donate food"
	crate_name = "Buffet crate"

/datum/overmap_objective/cargo/donation/food/New()
	// Must create a specific list of foods. Using parent types may turn up "snack" on communications console which is misleading, and using subtypes loops may turn up uncraftable foods 
	// var/picked = get_random_food()
	var/picked = pick( list(
		/obj/item/reagent_containers/food/snacks/store/bread/plain,
		/obj/item/reagent_containers/food/snacks/store/bread/meat,
		/obj/item/reagent_containers/food/snacks/store/bread/banana,
		/obj/item/reagent_containers/food/snacks/store/bread/tofu,
		/obj/item/reagent_containers/food/snacks/store/bread/creamcheese,
		/obj/item/reagent_containers/food/snacks/store/cake/plain,
		/obj/item/reagent_containers/food/snacks/store/cake/carrot,
		/obj/item/reagent_containers/food/snacks/store/cake/cheese,
		/obj/item/reagent_containers/food/snacks/store/cake/orange,
		/obj/item/reagent_containers/food/snacks/store/cake/lemon,
		/obj/item/reagent_containers/food/snacks/store/cake/lime,
		/obj/item/reagent_containers/food/snacks/store/cake/chocolate,
		/obj/item/reagent_containers/food/snacks/store/cake/holy_cake,
		/obj/item/reagent_containers/food/snacks/store/cake/pound_cake,
		/obj/item/reagent_containers/food/snacks/burger/plain,
		/obj/item/reagent_containers/food/snacks/burger/bigbite,
		/obj/item/reagent_containers/food/snacks/burger/superbite,
		/obj/item/reagent_containers/food/snacks/omelette,
		/obj/item/reagent_containers/food/snacks/benedict,
		/obj/item/reagent_containers/food/snacks/icecreamsandwich,
		/obj/item/reagent_containers/food/snacks/sundae,
		/obj/item/reagent_containers/food/snacks/carpmeat,
		/obj/item/reagent_containers/food/snacks/enchiladas,
		/obj/item/reagent_containers/food/snacks/popcorn,
		/obj/item/reagent_containers/food/snacks/burrito,
		/obj/item/reagent_containers/food/snacks/cheesyburrito,
		/obj/item/reagent_containers/food/snacks/carneburrito,
		/obj/item/reagent_containers/food/snacks/nachos,
		/obj/item/reagent_containers/food/snacks/cheesynachos,
		/obj/item/reagent_containers/food/snacks/cubannachos,
		/obj/item/reagent_containers/food/snacks/waffles,
		/obj/item/reagent_containers/food/snacks/pie/cream,
		/obj/item/reagent_containers/food/snacks/pie/pumpkinpie,
		/obj/item/reagent_containers/food/snacks/pie/plain,
		/obj/item/reagent_containers/food/snacks/pie/applepie,
		/obj/item/reagent_containers/food/snacks/pizza/meat,
		/obj/item/reagent_containers/food/snacks/pizza/margherita,
		/obj/item/reagent_containers/food/snacks/salad/fruit,
		/obj/item/reagent_containers/food/snacks/salad/oatmeal,
		/obj/item/reagent_containers/food/snacks/deadmouse
	) )
	var/datum/freight_type/object/C = new /datum/freight_type/object( picked )
	C.target = rand( 3, 5 )
	freight_types += C
