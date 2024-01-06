/obj/machinery/vending/coffee
	name = "\improper Solar's Best Hot Drinks"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Napij się!;Do dna!;To dla ciebie dobre!;Chciałby pan kubek gorącej kawy?;Zabiłbym dla kawy!;Najlepsze ziarna w galaktyce.;Tylko najlepszy napar dla ciebie.;Mmmm. Nie ma to jak kawa.;Lubię kawę, a ty?;Kawa pomaga ci pracować!;Spróbuj trochę herbaty.;Mamy nadzieję, że lubisz najlepsze!;Spróbuj naszej nowej czekolady!;Konspiracja adminów"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	light_color = LIGHT_COLOR_BROWN
	products = list(/obj/item/reagent_containers/food/drinks/coffee = 6,
		            /obj/item/reagent_containers/food/drinks/mug/tea = 6,
		            /obj/item/reagent_containers/food/drinks/mug/cocoa = 3)
	contraband = list(/obj/item/reagent_containers/food/drinks/ice = 12)
	refill_canister = /obj/item/vending_refill/coffee
	default_price = 10
	extra_price = 25
	payment_department = ACCOUNT_SRV
/obj/item/vending_refill/coffee
	machine_name = "Solar's Best Hot Drinks"
	icon_state = "refill_joe"
