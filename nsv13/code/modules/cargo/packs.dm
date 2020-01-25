/datum/supply_pack/munitions
	group = "Munitions"
	access = ACCESS_MUNITIONS
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/munitions/railgun
	name = "300mm railgun slugs (x10)"
	desc = "A set of 10 tungsten railgun slugs, guaranteed to pierce through enemy hulls or your money back!"
	cost = 1000
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
	desc = "5 boxes of PDC ammunition. Typically used to shoot down oncoming ordnance."
	cost = 1000
	contains = list(/obj/item/ammo_box/magazine/pdc,
					/obj/item/ammo_box/magazine/pdc,
					/obj/item/ammo_box/magazine/pdc,
					/obj/item/ammo_box/magazine/pdc,
					/obj/item/ammo_box/magazine/pdc)
	crate_name = "PDC ammunition crate"

/datum/supply_pack/munitions/trolley
	name = "Replacement munitions trolley (x1)"
	desc = "A munitions trolley for hauling ammunition. Ordnance sold separately."
	cost = 2000
	contains = list(/obj/structure/munitions_trolley)
	crate_name = "Munitions trolley crate"

/datum/supply_pack/munitions/torpedo_construction
	name = "Torpedo construction kit"
	desc = "Due to the volatility of torpedoes, we are unable to offer pre-built munitions, however this kit contains common torpedo parts and some casings to put them in. Included: 2x standard warhead, 1x decoy warhead, 3x torpedo casings (trolley sold separately), 3x guidance system modules, 3x propulsion modules, 3x IFF cards."
	cost = 3000
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
	cost = 500
	contains = list(/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing,
					/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing)
	crate_name = "Blank torpedo casings"

/datum/supply_pack/munitions/torpedo_construction
	name = "Torpedo components"
	desc = "A set of torpedo guidance modules, propulsion units and IFF cards. Warheads sold separately!"
	cost = 1000
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
	cost = 1000
	contains = list(/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead,
					/obj/item/ship_weapon/parts/torpedo/warhead)
	crate_name = "Standard torpedo warheads"

/datum/supply_pack/munitions/lightweight_warheads
	name = "Torpedo warheads (lightweight)"
	desc = "A pack of 5 lightweight torpedo warheads with a 30 isotonne yield, ideal for long range combat, or tracking fast moving targets."
	cost = 1000
	contains = list(/obj/item/ship_weapon/parts/torpedo/warhead/lightweight,
					/obj/item/ship_weapon/parts/torpedo/warhead/lightweight,
					/obj/item/ship_weapon/parts/torpedo/warhead/lightweight,
					/obj/item/ship_weapon/parts/torpedo/warhead/lightweight,
					/obj/item/ship_weapon/parts/torpedo/warhead/lightweight)
	crate_name = "Lightweight torpedo warheads"

/datum/supply_pack/munitions/bb_warheads
	name = "Torpedo warheads (armour piercing)"
	desc = "A pack of 5 armour piercing torpedo warheads with a 80 isotonne combined yield, these warheads excel at dealing massive damage to a target."
	cost = 3000
	contains = list(/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster,
					/obj/item/ship_weapon/parts/torpedo/warhead/bunker_buster)
	crate_name = "Armour piercing torpedo warheads"

/datum/supply_pack/munitions/decoy_warheads
	name = "Torpedo warheads (decoy)"
	desc = "A pack of 5 electronic countermeasure warheads which excel at distracting enemy PDC emplacements."
	cost = 500
	contains = list(/obj/item/ship_weapon/parts/torpedo/warhead/decoy,
					/obj/item/ship_weapon/parts/torpedo/warhead/decoy,
					/obj/item/ship_weapon/parts/torpedo/warhead/decoy,
					/obj/item/ship_weapon/parts/torpedo/warhead/decoy,
					/obj/item/ship_weapon/parts/torpedo/warhead/decoy)
	crate_name = "Decoy torpedo warheads"

/datum/supply_pack/munitions/peacekeeper_rifles
	name = "M2A45 pulse rifles (x5)"
	desc = "A pack of 5 M2A45 pulse rifles, preloaded with nonlethal stun slugs."
	cost = 2000
	contains = list(/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper,
					/obj/item/gun/ballistic/automatic/peacekeeper)
	crate_name = "M2A45 pulse rifles"

/datum/supply_pack/munitions/peacekeeper_ammo
	name = "M2A45 pulse rifle ammo (nonlethal)"
	desc = "5 magazines of nonlethal ammo for peacekeeper rifles."
	cost = 500
	contains = list(/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper,
					/obj/item/ammo_box/magazine/peacekeeper)
	crate_name = "M2A45 pulse rifle ammunition (nonlethal)"

/datum/supply_pack/munitions/peacekeeper_ammo_lethal
	name = "M2A45 pulse rifle ammo (lethal)"
	desc = "5 magazines of lethal ammunition for peacekeeper rifles."
	cost = 800
	contains = list(/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal,
					/obj/item/ammo_box/magazine/peacekeeper/lethal)
	crate_name = "M2A45 pulse rifle ammunition (lethal)"

/datum/supply_pack/munitions/pilot_outfitting
	name = "Pilot Outfitting Crate"
	desc = "A full set of of gear for a new pilot"
	cost = 1500
	contains = list(/obj/item/clothing/under/ship/pilot,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/clothing/gloves/color/black,
					/obj/item/clothing/head/beret/ship/pilot,
					/obj/item/radio/headset/headset_sec/alt/pilot,
					/obj/item/clothing/suit/space/hardsuit/pilot)
