//Missile factory
/datum/design/missilebuilder
	name = "Missile autowrencher"
	desc = "A machine that can perform part of the missile construction process."
	id = "missilebuilder"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/missilewelder
	name = "Missile autowelder"
	desc = "A machine that can perform part of the missile construction process."
	id = "missilewelder"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder/welder
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/missilescrewer
	name = "Missile autoscrewer"
	desc = "A machine that can perform part of the missile construction process."
	id = "missilescrewer"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder/screwdriver
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/missilewirer
	name = "Missile autowirer"
	desc = "A machine that can perform part of the missile construction process."
	id = "missilewirer"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder/wirer
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/missileassembler
	name = "Missile assembler"
	desc = "A specialist robotic arm that can fit missile casings with components held in storage."
	id = "missileassembler"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder/assembler
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/slowconveyor
	name = "Low Speed Conveyor"
	desc = "A specialist 'fire and forget' conveyor tuned to run at the exact speed that missile construction machines operate at."
	id = "slowconveyor"
	build_type = PROTOLATHE|AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/stack/conveyor/slow
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS

//Parts that fit Torps and Missiles

/datum/design/guidance_system
	name = "Guided Munition Guidance System"
	desc = "The stock standard guidance system design for guided munitions"
	id = "guidance_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 250, /datum/material/gold = 300, /datum/material/copper = 250)
	build_path = /obj/item/ship_weapon/parts/missile/guidance_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/propulsion_system
	name = "Guided Munition Propulsion System"
	desc = "The stock standard propulsion system design for guided munitions"
	id = "propulsion_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/titanium = 250, /datum/material/plasma = 250)
	build_path = /obj/item/ship_weapon/parts/missile/propulsion_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/iff_card
	name = "Guided Munition IFF Card"
	desc = "The stock standard IFF card design for guided munitions"
	id = "iff_card"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 500, /datum/material/gold = 500)
	build_path = /obj/item/ship_weapon/parts/missile/iff_card
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Missile Parts

/datum/design/missile_warhead
	name = "Standard Missile Warhead"
	desc = "The stock standard warhead design for missiles"
	id = "missile_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500, /datum/material/copper = 500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS	


//Torp Parts

/datum/design/warhead
	name = "Torpedo Warhead"
	desc = "The stock standard warhead design for torpedos"
	id = "warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/plasma = 4000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/torpedo
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/bb_warhead
	name = "Bunker Buster Torpedo Warhead"
	desc = "A bunker buster warhead design for torpedos"
	id = "bb_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/plasma = 5000, /datum/material/gold = 2000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/bunker_buster
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/decoy_warhead
	name = "Decoy Torpedo Warhead"
	desc = "A decoy warhead design for torpedos"
	id = "decoy_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500, /datum/material/copper = 1000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/decoy
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/freight_warhead
	name = "Freight Torpedo Warhead"
	desc = "A hollowed out nosecone that allows torpedoes to carry freight."
	id = "freight_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000, /datum/material/copper = 500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/freight
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/nuclear_warhead
	name = "Nuclear Torpedo Warhead"
	desc = "A nuclear warhead design for torpedos"
	id = "nuke_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/copper = 1000, /datum/material/plasma = 7500, /datum/material/gold = 1500, /datum/material/uranium = 10000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/nuclear
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/probe_warhead
	name = "Astrometrics probe warhead"
	desc = "A sensor suite that can turn a torpedo casing into an advanced probe for use in astrometrics research."
	id = "probe_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000, /datum/material/copper = 1500, /datum/material/titanium= 1000, /datum/material/gold=1000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/probe
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

//Naval Cannons
/datum/design/naval_shell
	name = "Naval Artillery Round"
	desc = "A high caliber round that can be fired out of a deck gun. (WARNING: Requires a trolley to move!)"
	id = "naval_shell"
	materials = list(/datum/material/iron = 10000, /datum/material/titanium=5000, /datum/material/copper=500)
	build_path = /obj/item/ship_weapon/ammunition/naval_artillery
	category = list("Advanced Munitions")
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/naval_shell_ap
	name = "Naval Artillery Round (Armour Piercing)"
	desc = "A diamond tipped AP round that can be fired out of a deck gun. (WARNING: Requires a trolley to move!)"
	id = "naval_shell_ap"
	materials = list(/datum/material/iron = 10000, /datum/material/titanium=1000, /datum/material/diamond=2000)
	build_path = /obj/item/ship_weapon/ammunition/naval_artillery/ap
	category = list("Advanced Munitions")
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/powder_bag
	name = "Powder Bag"
	desc = "A bag of explosives for use with deck guns."
	id = "powder_bag"
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/powder_bag
	category = list("Advanced Munitions")
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/plasma_accelerant
	name = "Plasma-Based Kinetic Accelerant"
	desc = "A powerful powder charge for use in deck guns, which can propel a round to insane speeds."
	id = "plasma_accelerant"
	materials = list(/datum/material/iron = 500, /datum/material/plasma = 1500)
	build_path = /obj/item/powder_bag/plasma
	category = list("Advanced Munitions")
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Railgun Because you can still get the funny from missions
/datum/design/railgun_round
	name = "M4 NTRS 400mm teflon coated tungsten railgun slug"
	desc = "Allows you to construct railgun ammunition"
	id = "railgun_round"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=5000, /datum/material/titanium=5000, /datum/material/silver=1000,)
	build_path = /obj/item/ship_weapon/ammunition/railgun_ammo
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS