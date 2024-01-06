/obj/machinery/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"
	icon_deny = "boozeomat-deny"
	light_color = LIGHT_COLOR_BLUEGREEN
	products = list(/obj/item/reagent_containers/food/drinks/drinkingglass = 30,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass = 12,
					/obj/item/reagent_containers/food/drinks/flask = 3,
					/obj/item/reagent_containers/food/drinks/ice = 10,
					/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/cream = 4,
					/obj/item/reagent_containers/food/drinks/soda_cans/cola = 8,
					/obj/item/reagent_containers/food/drinks/soda_cans/tonic = 8,
					/obj/item/reagent_containers/food/drinks/soda_cans/sodawater = 15,
					/obj/item/reagent_containers/food/drinks/bottle/grenadine = 4,
					/obj/item/reagent_containers/food/drinks/bottle/menthol = 4,
					/obj/item/reagent_containers/food/drinks/ale = 6,
					/obj/item/reagent_containers/food/drinks/beer = 6,
					/obj/item/reagent_containers/food/drinks/bottle/gin = 5,
		            /obj/item/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/reagent_containers/food/drinks/bottle/tequila = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vermouth = 5,
					/obj/item/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/reagent_containers/food/drinks/bottle/wine = 5,
					/obj/item/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/reagent_containers/food/drinks/bottle/kahlua = 5,
					/obj/item/reagent_containers/food/drinks/bottle/hcider = 5,
					/obj/item/reagent_containers/food/drinks/bottle/absinthe = 5,
					/obj/item/reagent_containers/food/drinks/bottle/grappa = 5,
					/obj/item/reagent_containers/food/drinks/bottle/sake = 5,
					/obj/item/reagent_containers/food/drinks/bottle/applejack = 5,
					/obj/item/reagent_containers/food/drinks/bottle/blank = 15,
					/obj/item/reagent_containers/food/drinks/bottle/blank/small = 15
					)
	contraband = list(/obj/item/reagent_containers/food/drinks/mug/tea = 12,
					 /obj/item/reagent_containers/food/drinks/bottle/fernet = 5)
	premium = list(/obj/item/reagent_containers/glass/bottle/ethanol = 4,
				   /obj/item/reagent_containers/food/drinks/bottle/champagne = 5,
				   /obj/item/reagent_containers/food/drinks/bottle/trappist = 5)

	product_slogans = "Mam nadzieję, że nikt nie poprosi o cholerny kubek herbaty...;Alkohol to przyjaciel ludzkości. Ze mną się nie napijesz?;Całkiem zadowolony, że mogę ci służyć!;Czy nikt na tej stacji nie jest spragniony?"
	product_ads = "Do dna!;Gorzała jest dla ciebie dobra!;Alkohol to najlepszy przyjaciel ludzkości.;Całkiem zadowolony, że mogę ci służyć!;A może tak zimnego piwka?;Nic tak nie wyleczy jak gorzała!;Weź łyla!;Napij się!;Strzel sobie browara!;Piwo jest dla ciebie dobre!;Tylko najlepsze alkohole!;Najlepsza jakość gorzały od 2137!;Prestiżowe wino!;Maksimum alkoholu!;Człowiek kocha piwo.;Toast za postęp!"
	req_access = list(ACCESS_BAR)
	refill_canister = /obj/item/vending_refill/boozeomat
	default_price = 20
	extra_price = 50
	payment_department = ACCOUNT_SRV

/obj/machinery/vending/boozeomat/all_access
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one. This model appears to have no access restrictions."
	req_access = null

/obj/machinery/vending/boozeomat/pubby_maint //abandoned bar on Pubbystation
	products = list(/obj/item/reagent_containers/food/drinks/bottle/whiskey = 1,
			/obj/item/reagent_containers/food/drinks/bottle/absinthe = 1,
			/obj/item/reagent_containers/food/drinks/bottle/limejuice = 1,
			/obj/item/reagent_containers/food/drinks/bottle/cream = 1,
			/obj/item/reagent_containers/food/drinks/soda_cans/tonic = 1,
			/obj/item/reagent_containers/food/drinks/drinkingglass = 10,
			/obj/item/reagent_containers/food/drinks/ice = 3,
			/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass = 6,
			/obj/item/reagent_containers/food/drinks/flask = 1)
	req_access = null

/obj/machinery/vending/boozeomat/pubby_captain //Captain's quarters on Pubbystation
	products = list(/obj/item/reagent_containers/food/drinks/bottle/rum = 1,
					/obj/item/reagent_containers/food/drinks/bottle/wine = 1,
					/obj/item/reagent_containers/food/drinks/ale = 1,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 6,
					/obj/item/reagent_containers/food/drinks/ice = 1,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass = 4);
	req_access = list(ACCESS_CAPTAIN)

/obj/machinery/vending/boozeomat/syndicate_access
	req_access = list(ACCESS_SYNDICATE)

/obj/item/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"
