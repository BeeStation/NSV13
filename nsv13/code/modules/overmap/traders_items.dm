
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
	req_one_access = list(ACCESS_CARGO, ACCESS_SYNDICATE, ACCESS_HEADS)
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

/obj/structure/overmap/trader/can_move()
	//Nope!
	return FALSE

/obj/structure/overmap/trader/shipyard
	name = "Shipyard"
	icon_state = "robust"

/obj/structure/overmap/trader/syndicate
	name = "Arms Depot"
	icon_state = "syndie"
	faction = "syndicate"
	supply_pod_type = /obj/structure/closet/supplypod/syndicate_odst

/obj/structure/overmap/trader/independent
	faction = "unaligned" //TODO: make this actually do something
	supply_pod_type = /obj/structure/closet/supplypod

/obj/structure/overmap/trader/proc/set_trader(datum/trader/bob) //The love story of alice and bob continues.
	name = "[bob.name]"
	ai_controlled = FALSE //Yep, not a whole lot we can do about that.
	inhabited_trader = bob
	bob.current_location = src

/obj/structure/overmap/trader/Destroy()
	qdel(inhabited_trader)
	. = ..()

/obj/structure/overmap/trader/LateInitialize()
	. = ..()
	if((datum_flags & DF_ISPROCESSING) && (!current_system || !current_system.occupying_z))
		STOP_PROCESSING(SSphysics_processing, src)


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

/datum/trader_item/ship_repair/tier3
	name = "Deluxe ship repair"
	desc = "A complete repair job of all of your ship's hull and armour, because you've earned it!"
	price = 2000
	failure_chance = 0
	repair_amount = 100
	stock = 1
	special_requirement = 400 //Prove those scars are worth the cost

/datum/trader_item/ship_repair/on_purchase(obj/structure/overmap/OM)
	OM.repair_all_quadrants(repair_amount, failure_chance)

/datum/trader_item/mining_point_card
	name = "Mining point card"
	desc = "A mining point transfer card worth 500 at your local equipment vendor."
	price = 500                                    //1:1 price because 2000 points can turn into 1000 credits.
	stock = 5
	unlock_path = /obj/item/card/mining_point_card

/datum/trader_item/titanium
	name = "Titanium"
	desc = "A necessary part of any competent combat vessels armour."
	price = 700                             //Price for minerals is roughly 6x their export value
	stock = 30
	unlock_path = /obj/item/stack/sheet/mineral/titanium

/datum/trader_item/silver
	name = "Silver"
	desc = "Shiny, and affordable!."
	price = 600
	stock = 10
	unlock_path = /obj/item/stack/sheet/mineral/silver

/datum/trader_item/diamond
	name = "Diamond"
	desc = "Unlike some other places these don't come covered in blood. Only lots of sweat and tears."
	price = 2000
	stock = 4
	unlock_path = /obj/item/stack/sheet/mineral/diamond

/datum/trader_item/uranium
	name = "Uranium"
	desc = "Slightly radioactive, handle with care."
	price = 650
	stock = 8
	unlock_path = /obj/item/stack/sheet/mineral/uranium

/datum/trader_item/gold
	name = "Gold"
	desc = "Conducts electricity wonderfully! Just ask Steve."
	price = 800
	stock = 5
	unlock_path = /obj/item/stack/sheet/mineral/gold

/datum/trader_item/bluespace_crystal
	name = "Bluespace crystal"
	desc = "A wonder material which bent our world view, now it'll bend your wallet if you want some."
	price = 8000
	stock = 3
	unlock_path = /obj/item/stack/ore/bluespace_crystal

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

/datum/trader_item/vls_circuit
	name = "VLS tube circuit board"
	desc = "The critical component for expanding your missile complement!"
	price = 5000
	stock = 10
	unlock_path = /obj/item/circuitboard/machine/vls
	special_requirement = 100 //At least put some effort into it

/datum/trader_item/firing_electronics
	name = "Firing Electronics"
	desc = "Essential electronics for building most modern naval weapons."
	price = 20000
	stock = 2
	unlock_path = /obj/item/ship_weapon/parts/firing_electronics
	special_requirement = 500 //Kick their ass!!!

/datum/trader_item/pdc_circuit
	name = "PDC mount circuit board"
	desc = "Not enough point defense? Just build more!"
	price = 2500
	stock = 4
	unlock_path = /obj/item/circuitboard/machine/pdc_mount

/datum/trader_item/torpedo
	name = "Standard Torpedo"
	desc = "A standard torpedo for ship to ship combat."
	price = 900 //Price is 1000 per in cargo
	stock = 15
	unlock_path = /obj/item/ship_weapon/ammunition/torpedo

/datum/trader_item/missile
	name = "Standard Missile"
	desc = "A standard missile for ship to ship combat."
	price = 500 //Price in cargo is 833 per, this is a real steal
	stock = 20
	unlock_path = /obj/item/ship_weapon/ammunition/missile

/datum/trader_item/hellfire
	name = "Plasma Incendiary Torpedo"
	desc = "The alpha and the omega, shipped to you quickly and efficiently! (WARNING: HANDLE WITH CARE)."
	price = 2500
	stock = 4
	unlock_path = /obj/item/ship_weapon/ammunition/torpedo/hellfire

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
	price = 175 //cost of buying in cargo is 200 per box
	stock = 20
	unlock_path = /obj/item/ammo_box/magazine/nsv/pdc

/datum/trader_item/anti_air
	name = "Anti-air Gun Ammo Box"
	desc = "Anti-air rounds for use in ship to ship guns."
	price = 800
	stock = 10
	unlock_path = /obj/item/ammo_box/magazine/nsv/pdc

/datum/trader_item/flak
	name = "Flak Ammo Box"
	desc = "Flak rounds for use in ship to ship guns."
	price = 500
	stock = 10
	unlock_path = /obj/item/ammo_box/magazine/nsv/flak

/datum/trader_item/fighter/light
	name = "Light Fighter"
	desc = "A pre-assembled light fighter which comes pre-equipped with everything a pilot needs to get back into the fight."
	price = 11000
	stock = 2
	unlock_path = /obj/structure/overmap/small_craft/combat/light

/datum/trader_item/fighter/utility
	name = "Utility Fighter"
	desc = "A pre-assembled utility craft, capable of restocking and repairing other fighters."
	price = 9000
	stock = 5
	unlock_path = /obj/structure/overmap/small_craft/transport/sabre

/datum/trader_item/fighter/heavy
	name = "Heavy Fighter"
	desc = "A pre-assembled Scimitar class heavy fighter produced in house by our engineers."
	price = 15000
	stock = 2
	unlock_path = /obj/structure/overmap/small_craft/combat/heavy

//Trader exclusive specialty fighters
/obj/structure/overmap/small_craft/combat/light/judgement
	name = "executive fighter"
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
	unlock_path = /obj/structure/overmap/small_craft/combat/light/judgement

/datum/trader_item/fighter/prototype
	name = "SU-148 Chelyabinsk Superiority Fighter"
	desc = "A highly experimental fighter prototype outfitted with a railgun. This absolute powerhouse balances speed, power and stealth in a package guaranteed to outclass anything the Syndicate can throw at you. Ammo blueprints sold seperately!"
	price = 50000
	stock = 1
	unlock_path = /obj/structure/overmap/small_craft/combat/light/prototype

/obj/structure/overmap/small_craft/combat/light/prototype
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

/datum/trader_item/railgun_disk
	name = "Outdated Railgun Slug Design Disk"
	desc = "A disk containing railgun slug blueprints."
	price = 5000
	stock = 1
	unlock_path = /obj/item/disk/design_disk/hybrid_rail_slugs

/datum/trader_item/fighter/syndicate
	name = "AV-41 'Corvid' Syndicate Light Fighter"
	desc = "A somewhat outdated Syndicate fighter design which may or may not be a facsimile of Nanotrasen's now defunct 'Viper' series."
	price = 7000
	stock = 5
	unlock_path = /obj/structure/overmap/small_craft/combat/light/syndicate //Good luck using these without boarder IDs

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

/datum/trader_item/deck_gun_autoelevator
	name = "Experimental Naval Artillery Cannon Autoelevator Technology Disk"
	desc = "A machine which can upgrade the naval artillery cannon to drastically reduce load times."
	price = 10000
	stock = 1
	unlock_path = /obj/item/disk/design_disk/deck_gun_autoelevator

/datum/trader_item/deck_gun_autorepair
	name = "Experimental Naval Artillery Cannon Autorepair Technology Disk"
	desc = "A machine which can upgrade the naval artillery cannon to let it self-repair."
	price = 8000
	stock = 1
	unlock_path = /obj/item/disk/design_disk/deck_gun_autorepair

/datum/trader_item/yellow_pages
	name = "Space Yellow Pages"
	desc = "A book full of useful information about nearby space stations"
	price = 1000
	stock = 1
	unlock_path = /obj/item/book/space_yellow_pages

/datum/trader_item/yellow_pages/on_purchase(obj/structure/overmap/OM)
	. = ..()
	var/obj/item/book/space_yellow_pages/book = .
	book.set_basic_info(owner)
