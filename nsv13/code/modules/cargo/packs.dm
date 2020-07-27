/datum/supply_pack/munitions
	group = "Munitions"
	access = ACCESS_MUNITIONS
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/munitions/railgun
	name = "300mm railgun slugs (x10)"
	desc = "A set of 10 tungsten railgun slugs, guaranteed to pierce through enemy hulls or your money back!"
	cost = 2500
	contains = list(/obj/item/ship_weapon/ammunition/railgun_ammo,
					/obj/item/ship_weapon/ammunition/railgun_ammo,
					/obj/item/ship_weapon/ammunition/railgun_ammo,
					/obj/item/ship_weapon/ammunition/railgun_ammo,
					/obj/item/ship_weapon/ammunition/railgun_ammo,
					/obj/item/ship_weapon/ammunition/railgun_ammo,
					/obj/item/ship_weapon/ammunition/railgun_ammo,
					/obj/item/ship_weapon/ammunition/railgun_ammo,
					/obj/item/ship_weapon/ammunition/railgun_ammo,
					/obj/item/ship_weapon/ammunition/railgun_ammo)
	crate_name = "Railgun ammunition"

/datum/supply_pack/munitions/pdc
	name = "PDC rounds (x5)"
	desc = "5 boxes of PDC ammunition. Typically used to keep small enemy ships from harassing capital ships."
	cost = 1000
	contains = list(/obj/item/ammo_box/magazine/pdc,
					/obj/item/ammo_box/magazine/pdc,
					/obj/item/ammo_box/magazine/pdc,
					/obj/item/ammo_box/magazine/pdc,
					/obj/item/ammo_box/magazine/pdc)
	crate_name = "PDC ammunition crate"

/datum/supply_pack/munitions/flak
	name = "Flak rounds crate (x5)"
	desc = "5 boxes of flak ammunition. Typically used to shoot down oncoming ordnance."
	cost = 1000
	contains = list(/obj/item/ammo_box/magazine/pdc/flak,
					/obj/item/ammo_box/magazine/pdc/flak,
					/obj/item/ammo_box/magazine/pdc/flak,
					/obj/item/ammo_box/magazine/pdc/flak,
					/obj/item/ammo_box/magazine/pdc/flak)
	crate_name = "Flak ammunition crate"

/datum/supply_pack/munitions/trolley
	name = "Replacement munitions trolley (x1)"
	desc = "A munitions trolley for hauling ammunition. Ordnance sold separately."
	cost = 2000
	contains = list(/obj/structure/munitions_trolley)
	crate_name = "Munitions trolley crate"

/datum/supply_pack/munitions/torpedo_construction
	name = "Torpedo construction kit"
	desc = "Due to the volatility of torpedoes, we are unable to offer pre-built munitions, however this kit contains common torpedo parts and some casings to put them in. Included: 2x standard warhead, 1x decoy warhead, 3x torpedo casings (trolley sold separately), 3x guidance system modules, 3x propulsion modules, 3x IFF cards."
	cost = 9000
	contains = list(/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead/decoy,
					/obj/item/ship_weapon/parts/torpedo/guidance_system,
					/obj/item/ship_weapon/parts/torpedo/guidance_system,
					/obj/item/ship_weapon/parts/torpedo/guidance_system,
					/obj/item/ship_weapon/parts/torpedo/propulsion_system,
					/obj/item/ship_weapon/parts/torpedo/propulsion_system,
					/obj/item/ship_weapon/parts/torpedo/propulsion_system,
					/obj/item/ship_weapon/parts/torpedo/iff_card,
					/obj/item/ship_weapon/parts/torpedo/iff_card,
					/obj/item/ship_weapon/parts/torpedo/iff_card)
	crate_name = "Basic torpedo construction kit"

/datum/supply_pack/munitions/torpedo_casings
	name = "Torpedo casings"
	desc = "A set of 5 torpedo casings, prebuilt but not pre-assembled. Ideal when used with our line of torpedo components."
	cost = 1500
	contains = list(/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing)
	crate_name = "Blank torpedo casings"

/datum/supply_pack/munitions/torpedo_construction
	name = "Torpedo components"
	desc = "A set of torpedo guidance modules, propulsion units and IFF cards. Warheads sold separately!"
	cost = 1500
	contains = list(/obj/item/ship_weapon/parts/torpedo/guidance_system,
					/obj/item/ship_weapon/parts/torpedo/guidance_system,
					/obj/item/ship_weapon/parts/torpedo/guidance_system,
					/obj/item/ship_weapon/parts/torpedo/propulsion_system,
					/obj/item/ship_weapon/parts/torpedo/propulsion_system,
					/obj/item/ship_weapon/parts/torpedo/propulsion_system,
					/obj/item/ship_weapon/parts/torpedo/iff_card,
					/obj/item/ship_weapon/parts/torpedo/iff_card,
					/obj/item/ship_weapon/parts/torpedo/iff_card)
	crate_name = "Torpedo components"

/datum/supply_pack/munitions/standard_warheads
	name = "Torpedo warheads (standard)"
	desc = "A pack of 5 standard torpedo warheads with a 40 isotonne yield, ideal for general usage."
	cost = 3000
	contains = list(/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead)
	crate_name = "Standard torpedo warheads"

/datum/supply_pack/munitions/bb_warheads
	name = "Torpedo warheads (armour piercing)"
	desc = "A pack of 5 armour piercing torpedo warheads with a 80 isotonne combined yield, these warheads excel at dealing massive damage to a target."
	cost = 9000
	contains = list(/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster)
	crate_name = "Armour piercing torpedo warheads"

/datum/supply_pack/munitions/decoy_warheads
	name = "Torpedo warheads (decoy)"
	desc = "A pack of 5 electronic countermeasure warheads which excel at distracting enemy PDC emplacements."
	cost = 1500
	contains = list(/obj/item/ship_weapon/parts/torpedo/warhead/decoy,
					/obj/item/ship_weapon/parts/torpedo/warhead/decoy,
					/obj/item/ship_weapon/parts/torpedo/warhead/decoy,
					/obj/item/ship_weapon/parts/torpedo/warhead/decoy,
					/obj/item/ship_weapon/parts/torpedo/warhead/decoy)
	crate_name = "Decoy torpedo warheads"

/datum/supply_pack/munitions/pilot_outfitting
	name = "Pilot Outfitting Crate"
	desc = "A full set of of gear for a new pilot"
	cost = 1500
	contains = list(/obj/item/clothing/under/ship/pilot,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/clothing/gloves/color/black,
					/obj/item/clothing/head/beret/ship/pilot,
					/obj/item/radio/headset/munitions/pilot,
					/obj/item/clothing/suit/space/hardsuit/pilot)

/datum/supply_pack/munitions/missile_construction
	name = "Missile construction kit"
	desc = "Due to the volatility of missiles, we are unable to offer pre-built munitions, however this kit contains common missile parts and some casings to put them in. Included: 3x standard warhead, 3x missile casings (trolley sold separately), 3x guidance system modules, 3x propulsion modules, 3x IFF cards."
	cost = 2500
	contains = list(/obj/item/ship_weapon/ammunition/missile/missile_casing,
					/obj/item/ship_weapon/ammunition/missile/missile_casing,
					/obj/item/ship_weapon/ammunition/missile/missile_casing,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/warhead,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/guidance_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/propulsion_system,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card,
					/obj/item/ship_weapon/parts/missile/iff_card)
	crate_name = "Basic missile construction kit"

/datum/supply_pack/munitions/countermeasure_charges
	name = "Fighter countermeasure tri-charges (x5)"
	desc = "5 tri-charges of chaff countermeasures for a fighter."
	cost = 3500
	contains = list(/obj/item/ship_weapon/ammunition/countermeasure_charge,
					/obj/item/ship_weapon/ammunition/countermeasure_charge,
					/obj/item/ship_weapon/ammunition/countermeasure_charge,
					/obj/item/ship_weapon/ammunition/countermeasure_charge,
					/obj/item/ship_weapon/ammunition/countermeasure_charge)
	crate_name = "Fighter Countermeasure Charges"

/datum/supply_pack/munitions/light_fighter_starter_kit
	name = "Light Fighter Starter Kit"
	desc = "This kit contains all the parts needed to start your own fleet like the space admiral of your dreams."
	cost = 25000
	contains = list(/obj/structure/fighter_component/light_chassis_crate,
					/obj/item/fighter_component/fuel_tank/t1,
					/obj/item/fighter_component/avionics,
					/obj/item/fighter_component/apu,
					/obj/item/fighter_component/armour_plating/light/t1,
					/obj/item/fighter_component/targeting_sensor/light/t1,
					/obj/item/fighter_component/engine/light/t1,
					/obj/item/fighter_component/countermeasure_dispenser/t1,
					/obj/item/fighter_component/secondary/light/missile_rack/t1,
					/obj/item/fighter_component/primary/light/light_cannon/t1)

/datum/supply_pack/security/peacekeeper_rifles
	name = "M2A45 pulse rifles (x5)"
	desc = "A pack of 5 M2A45 pulse rifles, preloaded with nonlethal stun slugs."
	cost = 15000
	contains = list(/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper)
	crate_name = "M2A45 pulse rifles"

/datum/supply_pack/security/glock
	name = "Glock-13s (x5)"
	desc = "A pack of 5 security glock-13s, preloaded with rubber bullets."
	cost = 8000
	contains = list(/obj/item/gun/ballistic/automatic/pistol/glock,
					/obj/item/gun/ballistic/automatic/pistol/glock,
					/obj/item/gun/ballistic/automatic/pistol/glock,
					/obj/item/gun/ballistic/automatic/pistol/glock,
					/obj/item/gun/ballistic/automatic/pistol/glock)
	crate_name = "Glock-13s"

/datum/supply_pack/security/edged_weapons
	name = "Surviving edged weapons: Informational manual"
	desc = "A manual which can help you learn jujitsu!"
	cost = 7000
	contains = list(/obj/item/book/granter/martial/jujitsu)
	crate_name = "Jujitsu manual crate"

/datum/supply_pack/security/glock_ammo
	name = "Glock-13 ammo (nonlethal)"
	desc = "5 magazines of nonlethal ammo for security sidearms."
	cost = 1500
	contains = list(/obj/item/ammo_box/c9mm/rubber,
					/obj/item/ammo_box/c9mm/rubber,
					/obj/item/ammo_box/c9mm/rubber,
					/obj/item/ammo_box/c9mm/rubber,
					/obj/item/ammo_box/c9mm/rubber,
					/obj/item/ammo_box/magazine/pistolm9mm/glock)
	crate_name = "Glock-13 ammunition (nonlethal)"

/datum/supply_pack/security/glock_lethal
	name = "Glock-13 ammo (lethal)"
	desc = "5 magazines of lethal ammo for security sidearms."
	cost = 1500
	contains = list(/obj/item/ammo_box/c9mm,
					/obj/item/ammo_box/c9mm,
					/obj/item/ammo_box/c9mm,
					/obj/item/ammo_box/c9mm,
					/obj/item/ammo_box/c9mm,
					/obj/item/ammo_box/magazine/pistolm9mm/glock/lethal)
	crate_name = "Glock-13 ammunition (lethal)"

/datum/supply_pack/security/ballistic_tazer
	name = "Czanek Corp Tazer Crate"
	desc = "2 Czanek Corp tazers and some ammo for them (WARNING: MAY CAUSE HEART ATTACKS)."
	cost = 5000
	contains = list(/obj/item/ammo_box/magazine/tazer_cartridge_storage,
					/obj/item/ammo_box/magazine/tazer_cartridge_storage,
					/obj/item/gun/ballistic/tazer,
					/obj/item/gun/ballistic/tazer)
	crate_name = "Czanek corp tazer crate"

/datum/supply_pack/security/peacekeeper_ammo
	name = "M2A45 pulse rifle ammo (nonlethal)"
	desc = "5 magazines of nonlethal ammo for peacekeeper rifles."
	cost = 800
	contains = list(/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper)
	crate_name = "M2A45 pulse rifle ammunition (nonlethal)"

/datum/supply_pack/security/peacekeeper_ammo_lethal
	name = "M2A45 pulse rifle ammo (lethal)"
	desc = "5 magazines of lethal ammunition for peacekeeper rifles."
	cost = 1200
	contains = list(/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal)
	crate_name = "M2A45 pulse rifle ammunition (lethal)"

/datum/supply_pack/munitions/aviation_fuel
	name = "Aviation fuel"
	desc = "One Tyrosene fuel pump, capable of fully refuelling 3 fighters."
	cost = 1500
	contains = list(/obj/structure/reagent_dispensers/fueltank/aviation_fuel)

/datum/supply_pack/engineering/control_rods
	name = "Nanocarbon Reactor Control Rods (x5)"
	desc = "5 nanocarbon reactor control rods for a stormdrive reactor."
	cost = 3000
	contains = list(/obj/item/control_rod,
					/obj/item/control_rod,
					/obj/item/control_rod,
					/obj/item/control_rod,
					/obj/item/control_rod)
	crate_name = "Nanocarbon Reactor Control Rods"

/datum/supply_pack/engineering/superior_control_rods
	name = "Crystaline Nanocarbon Reactor Control Rods (x5)"
	desc = "5 crystaline nanocarbon reactor control rods for a stormdrive reactor."
	cost = 8000
	contains = list(/obj/item/control_rod/superior,
					/obj/item/control_rod/superior,
					/obj/item/control_rod/superior,
					/obj/item/control_rod/superior,
					/obj/item/control_rod/superior)
	crate_name = "Crystaline Nanocarbon Reactor Control Rods"

/datum/supply_pack/engineering/armour_plating_nanorepair_well
	name = "Armour Plating Nano-repair Well Machine Board"
	desc = "A replacement machine board for the APNW."
	access = ACCESS_CE
	cost = 50000 //These are *really* not meant to be cheap
	contains = list(/obj/item/circuitboard/machine/armour_plating_nanorepair_well)
	crate_name = "Armour Plating Nano-repair Well Machine Board"


/datum/supply_pack/engineering/armour_plating_nanorepair_pump
	name = "Armour Plating Nano-repair Pump Machine Board"
	desc = "A replacement machine board for a APNP."
	access = ACCESS_CE
	cost = 25000 //Make sure you look after these
	contains = list(/obj/item/circuitboard/machine/armour_plating_nanorepair_pump)
	crate_name = "Armour Plating Nano-repair Pump Machine Board"