/obj/machinery/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	product_slogans = "Smacznego.;Wystraczająco kalorii by wesprzeć intensywną pracę.;Wystarczająco zdrowe.;Wydajnie produkowane tofu!;Mmm! Jakie dobre!;Częstuj się.;Potrzebujesz jedzenia, by żyć!;Spróbuj naszych nowych lodów!;Pamiętaj: racje żywnościowe ratują życie, żołnierzu!;Nie wierz kłamstwom na temat racji żywnościowych.; Racje żywnościowe: ręcznie przygotowane dla gustów kosmicznych ludzików!" //NSV13 added lines referencing ration packs
	product_ads = "Smacznego.;Wystraczająco kalorii by wesprzeć intensywną pracę.;Wystarczająco zdrowe.;Wydajnie produkowane tofu!;Mmm! Jakie dobre!;Częstuj się.;Potrzebujesz jedzenia, by żyć!;Spróbuj naszych nowych lodów!;Pamiętaj: racje żywnościowe ratują życie, żołnierzu!;Nie wierz kłamstwom na temat racji żywnościowych.; Racje żywnościowe: ręcznie przygotowane dla gustów kosmicznych ludzików!" //NSV13 added lines referencing ration packs
	icon_state = "sustenance"
	light_color = LIGHT_COLOR_BLUEGREEN
	products = list(/obj/item/reagent_containers/food/snacks/tofu/prison = 12, //NSV13 halved available tofu
					/obj/item/reagent_containers/food/snacks/rationpack = 12, //NSV13 added ration packs
					/obj/item/reagent_containers/food/drinks/ice/prison = 12,
					/obj/item/reagent_containers/food/snacks/candy_corn/prison = 6)
	contraband = list(/obj/item/kitchen/knife = 6,
					  /obj/item/reagent_containers/food/drinks/coffee = 12,
					  /obj/item/tank/internals/emergency_oxygen = 6,
					  /obj/item/clothing/mask/breath = 6)
	refill_canister = /obj/item/vending_refill/sustenance
	default_price = 0
	extra_price = 0
	payment_department = NO_FREEBIES

/obj/item/vending_refill/sustenance
	machine_name = "Sustenance Vendor"
	icon_state = "refill_snack"
