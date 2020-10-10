
//Credit goes to cdey for these sprites (Thanks!)
/obj/structure/overmap/trader
	name = "Trade Station"
	icon = 'nsv13/icons/overmap/neutralstation.dmi'
	icon_state = "combust"
	damage_states = FALSE //Not yet implemented
	collision_positions = list(new /datum/vector2d(-7,73), new /datum/vector2d(-83,46), new /datum/vector2d(-106,14), new /datum/vector2d(-106,-11), new /datum/vector2d(-81,-41), new /datum/vector2d(-9,-67), new /datum/vector2d(10,-69), new /datum/vector2d(87,-35), new /datum/vector2d(107,-8), new /datum/vector2d(108,13), new /datum/vector2d(85,46), new /datum/vector2d(10,73))
	faction = "nanotrasen"//Placeholder, set by trader.
	mass = MASS_TITAN
	brakes = TRUE
	pixel_z = -96
	pixel_w = -96
	req_one_access = list(ACCESS_CARGO, ACCESS_SYNDICATE)
	var/datum/trader/inhabited_trader = null

/obj/structure/overmap/trader/try_hail(mob/living/user)
	if(!isliving(user) || !allowed(user)) //Only cargo auth'd personnel can make purchases.
		return FALSE
	if(inhabited_trader)
		inhabited_trader.greeting = pick(inhabited_trader.greetings)
		inhabited_trader.ui_interact(user)
		SEND_SOUND(user, 'nsv13/sound/effects/ship/freespace2/computer/textdraw.wav')
		to_chat(user, "<span class='boldnotice'>[pick(inhabited_trader.greetings)]</span>")

//Nope!

/obj/structure/overmap/trader/can_move()
	return FALSE

/obj/structure/overmap/trader/shipyard
	name = "Shipyard"
	icon_state = "robust"
	collision_positions = list(new /datum/vector2d(-6,87), new /datum/vector2d(-75,14), new /datum/vector2d(-76,-6), new /datum/vector2d(-8,-85), new /datum/vector2d(19,-72), new /datum/vector2d(85,-14), new /datum/vector2d(85,10), new /datum/vector2d(55,57), new /datum/vector2d(20,72))

/obj/structure/overmap/trader/syndicate
	name = "Arms Depot"
	icon_state = "syndie"
	faction = "syndicate"

/obj/structure/overmap/trader/proc/set_trader(datum/trader/bob) //The love story of alice and bob continues.
	name = "[bob.name]"
	ai_controlled = FALSE //Yep, not a whole lot we can do about that.
	inhabited_trader = bob

/obj/structure/overmap/trader/Destroy()
	qdel(inhabited_trader)
	. = ..()


//General items:

/datum/trader_item/ship_repair
	name = "Quick n' ez ship repair"
	desc = "We'll patch your ship up without a care, with our special ingredients: Duct tape and prayer! (Copyright CzanekCorp 2258, all rights reserved)"
	price = 1000
	stock = 5
	var/failure_chance = 20 //Chance of the repair going wrong. You get what you pay for.
	var/repair_amount = 35 //% of health this repair will heal up.

/datum/trader_item/ship_repair/tier2
	name = "Ship armour repair"
	desc = "A full repair of your ship's armour plating, superstructural repairs not included!"
	price = 2500
	failure_chance = 0
	repair_amount = 50
	stock = 2

/datum/trader_item/ship_repair/on_purchase(obj/structure/overmap/OM)
	OM.repair_all_quadrants(repair_amount, failure_chance)

/datum/trader_item/mac
	name = "Magnetic Accelerator Cannon Kit"
	desc = "Everything you need to build the big MAC."
	price = 10000
	stock = 1
	unlock_path = /obj/structure/closet/crate/secure/weapon/trader_arms

/obj/structure/closet/crate/secure/weapon/trader_arms
	name = "MAC Construction Kit"
	var/list/preset_contents = list(
		/obj/structure/ship_weapon/mac_assembly,\
		/obj/item/ship_weapon/parts/mac_barrel,\
		/obj/item/ship_weapon/parts/firing_electronics,\
		/obj/item/ship_weapon/parts/loading_tray,\
	)

/obj/structure/closet/crate/secure/weapon/trader_arms/PopulateContents()
	. = ..()
	for(var/X in preset_contents)
		new X(src)

/datum/trader_item/railgun
	name = "Railgun Kit"
	desc = "Everything you need to build a ship to ship railgun."
	price = 7500
	stock = 1
	unlock_path = /obj/structure/closet/crate/secure/weapon/trader_arms/railgun

/obj/structure/closet/crate/secure/weapon/trader_arms/railgun
	name = "Railgun Construction Kit"
	preset_contents = list(
		/obj/structure/ship_weapon/railgun_assembly,\
		/obj/item/ship_weapon/parts/railgun_rail,\
		/obj/item/ship_weapon/parts/firing_electronics,\
		/obj/item/ship_weapon/parts/loading_tray,\
	)

/datum/trader_item/torpedo
	name = "Standard Torpedo"
	desc = "A standard torpedo for ship to ship combat."
	price = 1000
	stock = 10
	unlock_path = /obj/item/ship_weapon/ammunition/torpedo

/datum/trader_item/missile
	name = "Standard Missile"
	desc = "A standard missile for ship to ship combat."
	price = 500
	stock = 20
	unlock_path = /obj/item/ship_weapon/ammunition/missile

/datum/trader_item/nuke
	name = "Thermonuclear Torpedo"
	desc = "The alpha and the omega, shipped to you quickly and efficiently! (WARNING: HANDLE WITH CARE)."
	price = 2500
	stock = 4
	unlock_path = /obj/item/ship_weapon/ammunition/torpedo/nuke

/datum/trader_item/c20r
	name = "Donk Co. C20R SMG."
	desc = "A highly powerful and versatile weapon used by Syndicate commando forces."
	price = 10000
	stock = 3
	unlock_path = /obj/item/gun/ballistic/automatic/c20r/unrestricted

/datum/trader_item/stechkin
	name = "Stechkin Pistol."
	desc = "A reliable lethal side-arm of Syndicate origin, better than whatever NT'll give you."
	price = 5500
	stock = 5
	unlock_path = /obj/item/gun/ballistic/automatic/pistol

/datum/trader_item/c45
	name = ".45 ACP Ammo Box"
	desc = ".45 ACP rounds for use in firearms."
	price = 1500
	stock = 5
	unlock_path = /obj/item/ammo_box/c45

/datum/trader_item/pdc
	name = "PDC Ammo Box"
	desc = "PDC rounds for use in ship to ship guns."
	price = 800
	stock = 10
	unlock_path = /obj/item/ammo_box/magazine/pdc

/datum/trader_item/flak
	name = "Flak Ammo Box"
	desc = "Flak rounds for use in ship to ship guns."
	price = 500
	stock = 10
	unlock_path = /obj/item/ammo_box/magazine/pdc/flak
