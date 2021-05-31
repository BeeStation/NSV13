
//Credit goes to cdey for these sprites (Thanks!)
/obj/structure/overmap/trader
	name = "Trade Station"
	icon = 'nsv13/icons/overmap/neutralstation.dmi'
	icon_state = "combust"
	damage_states = FALSE //Not yet implemented
	faction = "nanotrasen"//Placeholder, set by trader.
	mass = MASS_IMMOBILE
	brakes = TRUE
	obj_integrity = 3000 //Really robust, but not invincible.
	max_integrity = 3000
	bound_width = 224
	bound_height = 224
	req_one_access = list(ACCESS_CARGO, ACCESS_SYNDICATE)
	var/datum/trader/inhabited_trader = null

/obj/structure/overmap/trader/try_hail(mob/living/user)
	if(!isliving(user) || !allowed(user)) //Only cargo auth'd personnel can make purchases.
		to_chat(user, "<span class='warning'>Warning: You cannot open a communications channel without appropriate requisitions access registered to your ID card.</span>")
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

/obj/structure/overmap/trader/syndicate
	name = "Arms Depot"
	icon_state = "syndie"
	faction = "syndicate"

/obj/structure/overmap/trader/proc/set_trader(datum/trader/bob) //The love story of alice and bob continues.
	name = "[bob.name]"
	ai_controlled = FALSE //Yep, not a whole lot we can do about that.
	inhabited_trader = bob
	bob.current_location = src

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
	price = 6000
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

/datum/trader_item/fighter/light
	name = "Light Fighter"
	desc = "A pre-assembled light fighter which comes pre-equipped with everything a pilot needs to get back into the fight."
	price = 11000
	stock = 2
	unlock_path = /obj/structure/overmap/fighter/light

/datum/trader_item/fighter/utility
	name = "Utility Fighter"
	desc = "A pre-assembled utility craft, capable of restocking and repairing other fighters."
	price = 9000
	stock = 5
	unlock_path = /obj/structure/overmap/fighter/utility

/datum/trader_item/fighter/heavy
	name = "Heavy Fighter"
	desc = "A pre-assembled Scimitar class heavy fighter produced in house by our engineers."
	price = 15000
	stock = 2
	unlock_path = /obj/structure/overmap/fighter/heavy

//Trader exclusive specialty fighters
/obj/structure/overmap/fighter/light/judgement
	name = "Executive Fighter"
	icon_state = "judgement"
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/tier2,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine/tier2,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy/tier2,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery/tier2,
						/obj/item/fighter_component/primary/cannon)

/datum/trader_item/fighter/judgement
	name = "AX-49 'Classic' Custom Fighter"
	desc = "A custom built light fighter tuned to perfection, attention to detail and pride fuel this beauty."
	price = 20000
	stock = 1
	unlock_path = /obj/structure/overmap/fighter/light/judgement

/datum/trader_item/fighter/prototype
	name = "SU-148 Chelyabinsk Superiority Fighter"
	desc = "A highly experimental fighter prototype outfitted with a railgun. This absolute powerhouse balances speed, power and stealth in a package guaranteed to outclass anything the Syndicate can throw at you."
	price = 50000
	stock = 1
	unlock_path = /obj/structure/overmap/fighter/light/prototype

/obj/structure/overmap/fighter/light/prototype
	name = "SU-148 Chelyabinsk Superiority Fighter"
	icon_state = "prototype"
	components = list(/obj/item/fighter_component/fuel_tank/tier3,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/tier3,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine/tier3,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher/railgun,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy/tier2,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery/tier2,
						/obj/item/fighter_component/primary/cannon/heavy)

/datum/trader_item/fighter/syndicate
	name = "AV-41 'Corvid' Syndicate Light Fighter"
	desc = "A somewhat outdated Syndicate fighter design which may or may not be a facsimile of Nanotrasen's now defunct 'Viper' series."
	price = 7000
	stock = 5
	unlock_path = /obj/structure/overmap/fighter/light/syndicate //Good luck using these without boarder IDs

/datum/trader_item/taser
	name = "Czanek corp Taser (Patent Pending)"
	desc = "A cheap but highly reliable (and somewhat lethal) taser used by NT security forces."
	price = 1000
	stock = 5
	unlock_path = /obj/item/gun/ballistic/tazer

/datum/trader_item/taser_ammo
	name = "Czanek corp Taser Ammo (Patent Pending)"
	desc = "CC taser ammunition."
	price = 100
	stock = 5
	unlock_path = /obj/item/ammo_box/magazine/tazer_cartridge

/datum/trader_item/overmap_shields
	name = "SolGov Experimental Shielding Technology Disk"
	desc = "Stolen straight out from under their noses! Pity we don't know how to read it."
	price = 100000
	stock = 1
	unlock_path = /obj/item/disk/design_disk/overmap_shields
