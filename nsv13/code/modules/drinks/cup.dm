/obj/item/reagent_containers/glass/coffee_cup
	name = "coffee cup"
	desc = "A heat-formed plastic coffee cup. Can theoretically be used for other hot drinks, if you're feeling adventurous."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "coffee_cup_e"
	possible_transfer_amounts = list(10)
	volume = 30
	spillable = TRUE

/obj/item/reagent_containers/cup/glass/coffee_cup/update_icon_state()
	icon_state = reagents.total_volume ? "coffee_cup" : "coffee_cup_e"
	return ..()
