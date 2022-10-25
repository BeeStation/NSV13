/obj/machinery/coffeemaker
	name = "coffeemaker"
	desc = "A Modello 3 Coffeemaker that brews coffee and holds it at the perfect temperature of 176 fahrenheit. Made by Piccionaia Home Appliances."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "coffeemaker_nopot_nocart"
	var/base_icon_state = "coffeemaker"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/coffeemaker
	pixel_y = 4 //needed to make it sit nicely on tables
	var/obj/item/reagent_containers/glass/coffeepot/coffeepot = null
	var/brewing = FALSE
	var/brew_time = 20 SECONDS
	var/speed = 1
	/// The coffee cartridge to make coffee from. In the future, coffee grounds are like printer ink.
	var/obj/item/coffee_cartridge/cartridge = null
	/// The type path to instantiate for the coffee cartridge the device initially comes with, eg. /obj/item/coffee_cartridge
	var/initial_cartridge = /obj/item/coffee_cartridge
	/// The number of cups left
	var/coffee_cups = 20
	/// The amount of sugar packets left
	var/sugar_packs = 20
	/// The amount of sweetener packets left
	var/sweetener_packs = 20
	/// The amount of creamer packets left
	var/creamer_packs = 20

	var/static/radial_examine = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_examine")
	var/static/radial_brew = image(icon = 'nsv13/icons/effects/radial_coffee.dmi', icon_state = "radial_brew")
	var/static/radial_eject_pot = image(icon = 'nsv13/icons/effects/radial_coffee.dmi', icon_state = "radial_eject_pot")
	var/static/radial_eject_cartridge = image(icon = 'nsv13/icons/effects/radial_coffee.dmi', icon_state = "radial_eject_cartridge")
	var/static/radial_take_cup = image(icon = 'nsv13/icons/effects/radial_coffee.dmi', icon_state = "radial_take_cup")
	var/static/radial_take_sugar = image(icon = 'nsv13/icons/effects/radial_coffee.dmi', icon_state = "radial_take_sugar")
	var/static/radial_take_sweetener = image(icon = 'nsv13/icons/effects/radial_coffee.dmi', icon_state = "radial_take_sweetener")
	var/static/radial_take_creamer = image(icon = 'nsv13/icons/effects/radial_coffee.dmi', icon_state = "radial_take_creamer")

/obj/machinery/coffeemaker/Initialize(mapload)
	. = ..()
	if(mapload)
		coffeepot = new /obj/item/reagent_containers/glass/coffeepot(src)
		cartridge = new /obj/item/coffee_cartridge(src)
		update_icon()

/obj/machinery/coffeemaker/deconstruct(disassembled)
	coffeepot?.forceMove(drop_location())
	cartridge?.forceMove(drop_location())
	return ..()

/obj/machinery/coffeemaker/Destroy()
	QDEL_NULL(coffeepot)
	QDEL_NULL(cartridge)
	return ..()

/obj/machinery/coffeemaker/Exited(atom/movable/gone, direction)
	if(gone == coffeepot)
		coffeepot = null
	if(gone == cartridge)
		cartridge = null
	return ..()

/obj/machinery/coffeemaker/RefreshParts()
	. = ..()
	speed = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		speed += laser.rating

/obj/machinery/coffeemaker/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += "<span class='warning'>You're too far away to examine [src]'s contents and display!</span>"
		return

	if(brewing)
		. += "<span class='warning'>\The [src] is brewing.</span>"
		return

	if(panel_open)
		. += "<span class='warning'>[src]'s maintenance hatch is open!</span>"
		return

	if(coffeepot || cartridge)
		. += "<span class='notice'>\The [src] contains:</span>"
		if(coffeepot)
			. += "<span class='notice'>- \A [coffeepot].</span>"
		if(cartridge)
			. += "<span class='notice'>- \A [cartridge].</span>"

	if(!(stat & (NOPOWER|BROKEN)))
		. += "<span class='notice'>The status display reads:</span>\n"+\
		"<span class='notice'>- Brewing coffee at <b>[speed*100]%</b>.</span>"
		if(coffeepot)
			for(var/datum/reagent/consumable/cawfee as anything in coffeepot.reagents.reagent_list)
				. += "<span class='notice>- [cawfee.volume] units of coffee in pot.</span>"
		if(cartridge)
			if(cartridge.charges < 1)
				. += "<span class='notice'>- grounds cartridge is empty.</span>"
			else
				. += "<span class='notice'>- grounds cartridge has [cartridge.charges] charges remaining.</span>"

	if(coffee_cups >= 1)
		. += "<span class='notice'>There [coffee_cups == 1 ? "is" : "are"] [coffee_cups] coffee cup[coffee_cups != 1 && "s"] left.</span>"
	else
		. += "<span class='notice'>There are no cups left.</span>"

	if(sugar_packs >= 1)
		. += "<span class='notice'>There [sugar_packs == 1 ? "is" : "are"] [sugar_packs] packet[sugar_packs != 1 && "s"] of sugar left.</span>"
	else
		. += "<span class='notice'>There is no sugar left.</span>"

	if(sweetener_packs >= 1)
		. += "<span class='notice'>There [sweetener_packs == 1 ? "is" : "are"] [sweetener_packs] packet[sweetener_packs != 1 && "s"] of sweetener left.</span>"
	else
		. += "<span class='notice'>There is no sweetener left.</span>"

	if(creamer_packs > 1)
		. += "<span class='notice'>There [creamer_packs == 1 ? "is" : "are"] [creamer_packs] packet[creamer_packs != 1 && "s"] of creamer left.</span>"
	else
		. += "<span class='notice'>There is no creamer left.</span>"

/obj/machinery/coffeemaker/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(brewing)
		return

/obj/machinery/coffeemaker/handle_atom_del(atom/A)
	. = ..()
	if(A == coffeepot)
		coffeepot = null
	if(A == cartridge)
		cartridge = null
	update_icon()

/obj/machinery/coffeemaker/update_icon_state()
	icon_state = "[base_icon_state][coffeepot ? "_pot" : "_nopot"][cartridge ? "_cart": "_nocart"]"
	return ..()

/obj/machinery/coffeemaker/proc/replace_pot(mob/living/user, obj/item/reagent_containers/glass/coffeepot/new_coffeepot)
	if(!user)
		return FALSE
	if(coffeepot)
		if(Adjacent(usr) && !issilicon(usr))
			usr.put_in_hands(coffeepot)
		else
			coffeepot.forceMove(drop_location())
		coffeepot = null
	if(new_coffeepot)
		coffeepot = new_coffeepot
	update_icon()
	return TRUE

/obj/machinery/coffeemaker/proc/replace_cartridge(mob/living/user, obj/item/coffee_cartridge/new_cartridge)
	if(!user)
		return FALSE
	if(cartridge)
		if(Adjacent(usr) && !issilicon(usr))
			usr.put_in_hands(cartridge)
		else
			cartridge.forceMove(drop_location())
		cartridge = null
	if(new_cartridge)
		cartridge = new_cartridge
	update_icon()
	return TRUE

/obj/machinery/coffeemaker/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, 20)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/coffeemaker/attackby(obj/item/attack_item, mob/living/user, params)
	//You can only screw open empty coffeemakers
	if(!coffeepot && default_deconstruction_screwdriver(user, icon_state, icon_state, attack_item))
		return

	if(default_deconstruction_crowbar(attack_item))
		return

	if(panel_open) //Can't insert objects when its screwed open
		return TRUE

	if(istype(attack_item, /obj/item/reagent_containers/glass/coffeepot) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/glass/coffeepot/new_pot = attack_item
		. = TRUE
		if(!user.transferItemToLoc(new_pot, src))
			return TRUE
		replace_pot(user, new_pot)
		balloon_alert(user, "added pot")
		update_icon()
		return TRUE

	if(istype(attack_item, /obj/item/coffee_cartridge) && !(attack_item.item_flags & ABSTRACT))
		var/obj/item/coffee_cartridge/new_cartridge = attack_item
		. = TRUE
		if(!user.transferItemToLoc(new_cartridge, src))
			return TRUE
		replace_cartridge(user, new_cartridge)
		balloon_alert(user, "added cartridge")
		update_icon()
		return TRUE

/obj/machinery/coffeemaker/ui_interact(mob/user) // The microwave Menu //I am reasonably certain that this is not a microwave //I am positively certain that this is not a microwave
	. = ..()

	if(brewing || !user.canUseTopic(src, !issilicon(user)))
		return

	var/list/options = list()

	if(coffeepot)
		options["Eject Pot"] = radial_eject_pot

	if(cartridge)
		options["Eject Cartridge"] = radial_eject_cartridge

	if(coffeepot && cartridge && cartridge.charges > 0)
		options["Brew"] = radial_brew

	if(coffee_cups > 0)
		options["Take Cup"] = radial_take_cup

	if(sugar_packs > 0)
		options["Take Sugar"] = radial_take_sugar

	if(sweetener_packs > 0)
		options["Take Sweetener"] = radial_take_sweetener

	if(creamer_packs > 0)
		options["Take Creamer"] = radial_take_creamer

	if(isAI(user))
		if(stat & NOPOWER)
			return
		options["Examine"] = radial_examine

	var/choice

	if(length(options) < 1)
		return
	if(length(options) == 1)
		choice = options[1]
	else
		choice = show_radial_menu(user, src, options, require_near = !issilicon(user))

	// post choice verification
	if(brewing || (isAI(user) && stat & NOPOWER) || !user.canUseTopic(src, !issilicon(user)))
		return

	switch(choice)
		if("Brew")
			brew(user)
		if("Eject Pot")
			eject_pot(user)
		if("Eject Cartridge")
			eject_cartridge(user)
		if("Examine")
			examine(user)
		if("Take Cup")
			take_cup(user)
		if("Take Sugar")
			take_sugar(user)
		if("Take Sweetener")
			take_sweetener(user)
		if("Take Creamer")
			take_creamer(user)

/obj/machinery/coffeemaker/proc/eject_pot(mob/user)
	if(coffeepot)
		replace_pot(user)

/obj/machinery/coffeemaker/proc/eject_cartridge(mob/user)
	if(cartridge)
		replace_cartridge(user)

/obj/machinery/coffeemaker/proc/take_cup(mob/user)
	if(!coffee_cups) //shouldn't happen, but we all know how stuff manages to break
		balloon_alert("no cups left!")
		return
	balloon_alert_to_viewers("took cup")
	var/obj/item/reagent_containers/glass/coffee_cup/new_cup = new(get_turf(src))
	user.put_in_hands(new_cup)
	coffee_cups--

/obj/machinery/coffeemaker/proc/take_sugar(mob/user)
	if(!sugar_packs)
		balloon_alert("no sugar left!")
		return
	balloon_alert_to_viewers("took sugar packet")
	var/obj/item/reagent_containers/food/condiment/pack/sugar/new_pack = new(get_turf(src))
	user.put_in_hands(new_pack)
	sugar_packs--

/obj/machinery/coffeemaker/proc/take_sweetener(mob/user)
	if(!sweetener_packs)
		balloon_alert("no sweetener left!")
		return
	balloon_alert_to_viewers("took sweetener packet")
	var/obj/item/reagent_containers/food/condiment/pack/astrotame/new_pack = new(get_turf(src))
	user.put_in_hands(new_pack)
	sweetener_packs--

/obj/machinery/coffeemaker/proc/take_creamer(mob/user)
	if(!creamer_packs)
		balloon_alert("no creamer left!")
		return
	balloon_alert_to_viewers("took creamer packet")
	var/obj/item/reagent_containers/food/condiment/pack/creamer/new_pack = new(get_turf(src))
	user.put_in_hands(new_pack)
	creamer_packs--

/obj/machinery/coffeemaker/proc/operate_for(time, silent = FALSE)
	brewing = TRUE
	if(!silent)
		playsound(src, 'nsv13/sound/machines/coffeemaker_brew.ogg', 20, vary = TRUE)
	use_power(active_power_usage * time * 0.1) // .1 needed here to convert time (in deciseconds) to seconds such that watts * seconds = joules
	addtimer(CALLBACK(src, .proc/stop_operating), time / speed)

/obj/machinery/coffeemaker/proc/stop_operating()
	brewing = FALSE

/obj/machinery/coffeemaker/proc/brew()
	power_change()
	if(!coffeepot || stat & (NOPOWER|BROKEN) || coffeepot.reagents.total_volume >= coffeepot.reagents.maximum_volume)
		return
	operate_for(brew_time)
	coffeepot.reagents.add_reagent_list(cartridge.drink_type)
	cartridge.charges--

//Coffee Cartridges: like toner, but for your coffee!
/obj/item/coffee_cartridge
	name = "coffeemaker cartridge - Navy Coffee"
	desc = "A coffee cartridge manufactured by Piccionaia Coffee, for use with the Modello 3 system."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "cartridge_basic"
	var/charges = 4
	var/list/drink_type = list(/datum/reagent/consumable/navy_coffee = 120)
//To-Do Later, make a new reagent called Navy Coffee which gives a moodboost to people who drink it,
//and make it so that the Navy Coffee cartridge gives you Navy Coffee instead of regular coffee.

/obj/item/coffee_cartridge/examine(mob/user)
	. = ..()
	if(charges)
		. += "<span class='warning'>The cartridge has [charges] portions of grounds remaining.</span>"
	else
		. += "<span class='warning'>The cartridge has no unspent grounds remaining.</span>"

/obj/item/coffee_cartridge/fancy
	name = "coffeemaker cartridge - Caffè Fantasioso"
	desc = "A fancy coffee cartridge manufactured by Piccionaia Coffee, for use with the Modello 3 system."
	icon_state = "cartridge_blend"
	drink_type = list(/datum/reagent/consumable/cafe_latte = 120)

//Here's the joke before I get 50 issue reports: they're all the same, and that's intentional
//Not today, Navy Coffee is not the same as the fancy coffee
/obj/item/coffee_cartridge/fancy/Initialize(mapload)
	. = ..()
	var/coffee_type = pick("blend", "blue_mountain", "kilimanjaro", "mocha")
	switch(coffee_type)
		if("blend")
			name = "coffeemaker cartridge - Miscela di Piccione"
			icon_state = "cartridge_blend"
		if("blue_mountain")
			name = "coffeemaker cartridge - Montagna Blu"
			icon_state = "cartridge_blue_mtn"
		if("kilimanjaro")
			name = "coffeemaker cartridge - Kilimangiaro"
			icon_state = "cartridge_kilimanjaro"
		if("mocha")
			name = "coffeemaker cartridge - Moka Arabica"
			icon_state = "cartridge_mocha"

/obj/item/coffee_cartridge/decaf
	name = "coffeemaker cartridge - Caffè Decaffeinato"
	desc = "A decaf coffee cartridge manufactured by Piccionaia Coffee, for use with the Modello 3 system."
	icon_state = "cartridge_decaf"
	drink_type = list(/datum/reagent/consumable/soy_latte = 120)

// no you can't just squeeze the juice bag into a glass!
/obj/item/coffee_cartridge/bootleg
	name = "coffeemaker cartridge - Botany Blend"
	desc = "A jury-rigged coffee cartridge. Should work with a Modello 3 system, though it might void the warranty."
	icon_state = "cartridge_bootleg"
	drink_type = list(/datum/reagent/consumable/coffee = 120)

// blank cartridge for crafting's sake, can be made at the service lathe
/obj/item/blank_coffee_cartridge
	name = "blank coffee cartridge"
	desc = "A blank coffee cartridge, ready to be filled with coffee paste."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "cartridge_blank"

//now, how do you store coffee carts? well, in a rack, of course!
/obj/item/storage/fancy/coffee_cart_rack
	name = "coffeemaker cartridge rack"
	desc = "A small rack for storing coffeemaker cartridges."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "coffee_cartrack"
	icon_type = "coffee cartridge"
	spawn_type = /obj/item/coffee_cartridge

/obj/item/storage/fancy/coffee_cart_rack/Initialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 4
	var/static/list/can_hold = typecacheof(list(/obj/item/coffee_cartridge))
	STR.can_hold = can_hold

/obj/item/storage/fancy/coffee_cart_rack/update_icon()
	if(!contents.len)
		icon_state = initial(icon_state)
	else
		icon_state = " [initial(icon_state)][contents.len]"
