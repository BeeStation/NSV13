/datum/supply_pack/emergency/syndicate
	name = "NULL_ENTRY"
	desc = "(#@&^$THIS PACKAGE CONTAINS 30TC WORTH OF SOME RANDOM SYNDICATE GEAR WE HAD LYING AROUND THE WAREHOUSE. GIVE EM HELL, OPERATIVE, BUT DON'T GET GREEDY- ORDER TOO MANY AND WE'LL BE SENDING OUR DEADLIEST ENFORCERS TO INVESTIGATE@&!*() "
	hidden = TRUE
	cost = 20000
	contains = list()
	crate_name = "emergency crate"
	crate_type = /obj/structure/closet/crate/internals
	dangerous = TRUE
	var/beepsky_chance = -1
	var/level = 1

/datum/supply_pack/emergency/syndicate/fill(obj/structure/closet/crate/C)
	var/crate_value = 30
	var/list/uplink_items = get_uplink_items(UPLINK_TRAITORS)
	beepsky_chance += min(level, 5) //1% chance per crate an item will be replaced with a beepsky and the crate stops spawning items. Doesnt act as a hardcap, making nullcrates far riskier and less predictable
	while(crate_value)
		if(prob(beepsky_chance) && prob(50))
			new /mob/living/simple_animal/bot/secbot/grievous/nullcrate(C)
			crate_value = 0
			beepsky_chance = 0
			level += 1
		var/category = pick(uplink_items)
		var/item = pick(uplink_items[category])
		var/datum/uplink_item/I = uplink_items[category][item]
		if(!I.surplus_nullcrates || prob(100 - I.surplus_nullcrates))
			continue
		if(crate_value < I.cost)
			continue
		crate_value -= I.cost
		new I.item(C)
	var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
	if(istype(loneop))
		loneop.weight += 7
		message_admins("a NULL_ENTRY crate has shipped, increasing the weight of the Lone Operative event to [loneop.weight]")
		log_game("a NULL_ENTRY crate has shipped, increasing the weight of the Lone Operative event to [loneop.weight]")

/datum/supply_pack/organic/kremowka
	name = "Kremówki"
	desc = "Skrzynia pełna kremówek prosto z piekarni w Wadowicach."
	cost = 2137
	crate_type = /obj/structure/closet/crate
	contains = list(
		/obj/item/reagent_containers/food/snacks/pie/kremowka,
		/obj/item/reagent_containers/food/snacks/pie/kremowka,
		/obj/item/reagent_containers/food/snacks/pie/kremowka,
		/obj/item/reagent_containers/food/snacks/pie/kremowka,
		/obj/item/reagent_containers/food/snacks/pie/kremowka
		)
	crate_name = "skrzynia kremowek"

/datum/supply_pack/service/party
	contains = list(/obj/item/storage/box/drinkingglasses,
				/obj/item/reagent_containers/food/drinks/shaker,
				/obj/item/reagent_containers/food/drinks/bottle/patron,
				/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
				/obj/item/reagent_containers/food/drinks/ale,
				/obj/item/reagent_containers/food/drinks/ale,
				/obj/item/reagent_containers/food/drinks/beer,
				/obj/item/reagent_containers/food/drinks/beer,
				/obj/item/reagent_containers/food/drinks/beer,
				/obj/item/reagent_containers/food/drinks/beer,
				/obj/item/flashlight/glowstick,
				/obj/item/flashlight/glowstick/red,
				/obj/item/flashlight/glowstick/blue,
				/obj/item/flashlight/glowstick/cyan,
				/obj/item/flashlight/glowstick/orange,
				/obj/item/flashlight/glowstick/yellow,
				/obj/item/flashlight/glowstick/pink,
				/obj/item/survivalcapsule/party,
				/obj/item/survivalcapsule/party,
				/obj/item/reagent_containers/food/drinks/soda_cans/mocnyfull,
				/obj/item/reagent_containers/food/drinks/soda_cans/mocnyfull,
				/obj/item/reagent_containers/food/drinks/soda_cans/mocnyfull,
				/obj/item/reagent_containers/food/drinks/soda_cans/mocnyfull)

/datum/supply_pack/science/monkey_helmets
	name = "Monkey Mind Magnification Helmet Crate"
	desc = "Some research is best done with monkeys, yet sometimes they're just too dumb to complete more complicated tasks. These helmets should help."
	cost = 1500
	contains = list(/obj/item/clothing/head/monkey_sentience_helmet,
					/obj/item/clothing/head/monkey_sentience_helmet)
	crate_name = "monkey mind magnification crate"
