#define BEAN_CAPACITY 10
/*
 * pendulum coffee maker
 * its supposed to be a premium line product, so its cargo-only, the board cant be therefore researched
 */

/obj/machinery/coffeemaker/pendulum
	name = "pendulum coffeemaker"
	desc = "An industry-grade Pendulum Modello 5 Coffeemaker of the Piccionaia Home Appliances premium coffeemakers product line. Makes coffee from fresh dried whole beans."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "coffeemaker_pendulum"
	circuit = /obj/item/circuitboard/machine/coffeemaker/pendulum
	initial_cartridge = null		//no cartridge, just coffee beans
	brew_time = 15 SECONDS			//industrial grade, its faster than the regular one
	density = TRUE
	pass_flags = PASSTABLE

	var/coffee_amount = 0
	//this type of coffeemaker takes fresh whole beans insted of cartidges
	var/list/coffee = list()

/obj/machinery/coffeemaker/pendulum/Initialize(mapload)
	. = ..()
	if(mapload)
		coffeepot = new /obj/item/reagent_containers/glass/coffeepot(src)
		cartridge = null


/obj/machinery/coffeemaker/pendulum/Destroy()
	QDEL_NULL(coffeepot)
	QDEL_NULL(coffee)
	return ..()

/obj/machinery/coffeemaker/pendulum/Exited(atom/movable/gone, direction)
	if(gone == coffeepot)
		coffeepot = null
	if(gone == coffee)
		coffee = null
	return ..()

/obj/machinery/coffeemaker/pendulum/examine(mob/user)
	. = ..()
	if(coffee)
		. += "<span class='notice'The internal grinder conatins [coffee.len] scoop\s of coffee beans.</span>"
	return

/obj/machinery/coffeemaker/pendulum/update_overlays()
	. = ..()
	. += overlay_checks()

/obj/machinery/coffeemaker/pendulum/overlay_checks()
	. = list()
	if(coffeepot)
		if(coffeepot.reagents.total_volume > 0)
			. += "pot_full"
		else
			. += "pot_empty"
	if(coffee_cups > 0)
		if(coffee_cups >= max_coffee_cups/3)
			if(coffee_cups > max_coffee_cups/1.5)
				. += "cups_3"
			else
				. += "cups_2"
		else
			. += "cups_1"
	if(sugar_packs)
		. += "extras_1"
	if(creamer_packs)
		. += "extras_2"
	if(sweetener_packs)
		. += "extras_3"
	if(coffee_amount)
		if(coffee_amount < 0.7*BEAN_CAPACITY)
			. += "grinder_half"
		else
			. += "grinder_full"
	return

/obj/machinery/coffeemaker/pendulum/handle_atom_del(atom/A)
	. = ..()
	if(A == coffeepot)
		coffeepot = null
	if(A == coffee)
		coffee.Cut()
	update_icon()

/obj/machinery/coffeemaker/pendulum/can_brew()
	if(coffee_amount <= 0)
		balloon_alert_to_viewers("no coffee beans added!")
		return FALSE
	if(!coffeepot)
		balloon_alert_to_viewers("no coffeepot inside!")
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN) )
		balloon_alert_to_viewers("machine unpowered!")
		return FALSE
	if(coffeepot.reagents.total_volume >= coffeepot.reagents.maximum_volume)
		balloon_alert_to_viewers("the coffeepot is already full!")
		return FALSE
	return TRUE

/obj/machinery/coffeemaker/pendulum/attackby(obj/item/attack_item, mob/user, params)
	//You can only screw open empty coffeemakers
	if(!coffeepot && default_deconstruction_screwdriver(user, icon_state, icon_state, attack_item))
		return

	if(default_deconstruction_crowbar(attack_item))
		return

	if(panel_open) //Can't insert objects when its screwed open
		return TRUE

	if(istype(attack_item, /obj/item/reagent_containers/glass/coffeepot) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/glass/coffeepot/new_pot = attack_item
		if(!user.transferItemToLoc(new_pot, src))
			return TRUE
		replace_pot(user, new_pot)
		update_icon()
		return TRUE

	if(istype(attack_item, /obj/item/reagent_containers/food/drinks/coffee/empty) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/food/drinks/coffee/empty/new_cup = attack_item
		if(new_cup.reagents.total_volume > 0)
			balloon_alert(user, "the cup must be empty!")
			return TRUE
		if(coffee_cups >= max_coffee_cups)
			balloon_alert(user, "the cup holder is full!")
			return TRUE
		if(!user.transferItemToLoc(attack_item, src))
			return TRUE
		coffee_cups++
		update_icon()
		return TRUE

	if(istype(attack_item, /obj/item/reagent_containers/food/condiment/pack/sugar))
		var/obj/item/reagent_containers/food/condiment/pack/sugar/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "the pack must be full!")
			return TRUE
		if(sugar_packs >= max_sugar_packs)
			balloon_alert(user, "the sugar compartment is full!")
			return TRUE
		if(!user.transferItemToLoc(attack_item, src))
			return TRUE
		sugar_packs++
		update_icon()
		return TRUE

	if(istype(attack_item, /obj/item/reagent_containers/food/condiment/creamer))
		var/obj/item/reagent_containers/food/condiment/creamer/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "the pack must be full!")
			return TRUE
		if(creamer_packs >= max_creamer_packs)
			balloon_alert(user, "the creamer compartment is full!")
			return TRUE
		if(!user.transferItemToLoc(attack_item, src))
			return TRUE
		creamer_packs++
		update_icon()
		return TRUE

	if(istype(attack_item, /obj/item/reagent_containers/food/condiment/pack/astrotame))
		var/obj/item/reagent_containers/food/condiment/pack/astrotame/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "the pack must be full!")
			return TRUE
		if(sweetener_packs >= max_sweetener_packs)
			balloon_alert(user, "the sweetener compartment is full!")
			return TRUE
		if(!user.transferItemToLoc(attack_item, src))
			return TRUE
		sweetener_packs++
		update_icon()
		return TRUE

	if(istype(attack_item, /obj/item/reagent_containers/food/snacks/grown/coffee) && !(attack_item.item_flags & ABSTRACT))
		if(coffee_amount >= BEAN_CAPACITY)
			balloon_alert(user, "the coffee container is full!")
			return TRUE
		var/obj/item/reagent_containers/food/snacks/grown/coffee/new_coffee = attack_item
		if(!(new_coffee.dry))
			balloon_alert(user, "coffee beans must be dry!")
			return TRUE
		if(!user.transferItemToLoc(new_coffee, src))
			return TRUE
		coffee += new_coffee
		coffee_amount++
		balloon_alert(user, "added coffee")

	if (istype(attack_item, /obj/item/storage/box/coffeepack))
		if(coffee_amount >= BEAN_CAPACITY)
			balloon_alert(user, "the coffee container is full!")
			return TRUE
		var/obj/item/storage/box/coffeepack/new_coffee_pack = attack_item
		for(var/obj/item/reagent_containers/food/snacks/grown/coffee/new_coffee in new_coffee_pack.contents)
			if(!(new_coffee.dry))
				if(coffee_amount < BEAN_CAPACITY)
					if(user.transferItemToLoc(new_coffee, src))
						coffee += new_coffee
						coffee_amount++
						new_coffee.forceMove(src)
						balloon_alert(user, "added coffee")
						update_icon()
					else
						return TRUE
				else
					return TRUE
			else
				balloon_alert(user, "non-dried beans inside the coffee pack!")
				return TRUE
		return TRUE

	return ..()

/obj/machinery/coffeemaker/pendulum/take_cup(mob/user)
	if(!coffee_cups)
		balloon_alert(user, "no cups left!")
		return
	balloon_alert_to_viewers("took cup")
	var/obj/item/reagent_containers/food/drinks/coffee/empty/new_cup = new(get_turf(src))
	user.put_in_hands(new_cup)
	coffee_cups--
	update_icon()

/obj/machinery/coffeemaker/pendulum/toggle_steam()
	QDEL_NULL(particles)
	if(brewing)
		particles = new /particles/smoke/steam/mild/pendulum()

/obj/machinery/coffeemaker/pendulum/brew()
	power_change()
	if(!can_brew())
		return
	operate_for(brew_time)
	coffeepot.reagents.add_reagent_list(list(/datum/reagent/consumable/coffee = 120)) //Not Navy Coffee, only garbage Coffee
	coffee.Cut(1,2)
	coffee_amount--
	update_icon()
