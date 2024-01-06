/obj/machinery/vending/hydronutrients
	name = "\improper NutriMax"
	desc = "A plant nutrients vendor."
	product_slogans = "Nie jesteś zadowolony, że nie musisz nawozić w sposób naturalny?;Teraz tylko 50% smrodu!;Rośliny to też ludzie!"
	product_ads = "Lubimy rośliny!;Nie chcesz trochę?;Najzieleńsze kciuki jakie się da.;Lubimy duże rośliny.;Miękka gleba..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	light_color = LIGHT_COLOR_GREEN
	products = list(/obj/item/reagent_containers/glass/bottle/nutrient/ez = 30,
					/obj/item/reagent_containers/glass/bottle/nutrient/l4z = 20,
					/obj/item/reagent_containers/glass/bottle/nutrient/rh = 10,
					/obj/item/reagent_containers/spray/pestspray = 20,
					/obj/item/reagent_containers/syringe = 5,
					/obj/item/storage/bag/plants = 5,
					/obj/item/cultivator = 3,
					/obj/item/shovel/spade = 3,
					/obj/item/plant_analyzer = 4)
	contraband = list(/obj/item/reagent_containers/glass/bottle/ammonia = 10,
					  /obj/item/reagent_containers/glass/bottle/diethylamine = 5)
	refill_canister = /obj/item/vending_refill/hydronutrients
	default_price = 10
	extra_price = 50
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/hydronutrients
	machine_name = "NutriMax"
	icon_state = "refill_plant"
