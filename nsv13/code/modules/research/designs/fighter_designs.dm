//Countermeasure charges
/datum/design/countermeasure_charge
	name = "Countermeasure Tri-Charge"
	desc = "A tri-charge of countermeasure chaff for a fighter"
	id = "countermeasure_charge"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/titanium = 500)
	build_path = /obj/item/ship_weapon/ammunition/countermeasure_charge
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_ENGINEERING

//Frames
/datum/design/light_frame
	name = "Light Fighter Chassis"
	desc = "A light fighter's airframe, devoid of parts. It'll require additional work to get it flying."
	id = "light_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/titanium = 10000, /datum/material/copper = 7500)
	build_path = /obj/structure/fighter_frame
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/heavy_frame
	name = "Heavy Fighter Chassis"
	desc = "A heavy fighter's airframe, devoid of parts. These fighters are extremely suited to having heavier components mounted on them."
	id = "heavy_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/titanium = 20000, /datum/material/copper = 7500)
	build_path = /obj/structure/fighter_frame/heavy
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/utility_frame
	name = "Utility Fighter Chassis"
	desc = "A utility fighter's airframe, devoid of parts. These fighters excel at forming supply lines and are able to resupply and repair other ships!."
	id = "utility_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 10000, /datum/material/copper = 5000)
	build_path = /obj/structure/fighter_frame/utility
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

//Upgradeable components
//Tier 1
/datum/design/fuel_tank
	name = "Fighter Fuel Tank"
	desc = "A tank of fuel which can keep fighters in the air."
	id = "fuel_tank"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/fighter_component/fuel_tank
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/avionics
	name = "Fighter Avionics"
	desc = "A component used in fighter construction."
	id = "avionics"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/avionics
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/apu
	name = "Fighter APU"
	desc = "A component used in fighter construction."
	id = "apu"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/apu
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/armour_plating
	name = "Fighter Armour"
	desc = "A component used in fighter construction."
	id = "armour_plating"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000)
	build_path = /obj/item/fighter_component/armour_plating
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/targeting_sensor
	name = "Fighter Targeting Sensor"
	desc = "A component used in fighter construction."
	id = "targeting_sensor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 10000)
	build_path = /obj/item/fighter_component/targeting_sensor
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_engine
	name = "Fighter Engine"
	desc = "A component used in fighter construction."
	id = "fighter_engine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/engine
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/countermeasure_dispenser
	name = "Fighter Countermeasure Dispenser"
	desc = "A component used in fighter construction."
	id = "countermeasure_dispenser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/countermeasure_dispenser
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/ordnance_launcher
	name = "Fighter Torpedo Rack"
	desc = "A component used in fighter construction."
	id = "ordnance_launcher"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/torpedo
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/fighter_missile_launcher
	name = "Fighter Missile Rack"
	desc = "A component used in fighter construction."
	id = "fighter_missile_launcher"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS


/datum/design/oxygenator
	name = "Fighter Atmospheric Regulator"
	desc = "An atmospheric regulation system for fighters which removes the need for a space suit at the cost of some power usage."
	id = "oxygenator"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/oxygenator
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/docking_computer
	name = "Fighter Docking Computer"
	desc = "An all in one docking solution for fighters. Absolutely essential for shipside ops."
	id = "docking_computer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/docking_computer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_battery
	name = "Fighter Battery"
	desc = "A specialist lead-acid battery which is required to power fighter modules like APUs, oxygenators, and more!."
	id = "fighter_battery"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 7000, /datum/material/copper = 5000, /datum/material/glass = 2000)
	build_path = /obj/item/fighter_component/battery
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/primary_cannon
	name = "Fighter Primary Cannon (Light)"
	desc = "A standard light cannon usable by most fighters, light, cheap, effective. Light cannon."
	id = "primary_cannon"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 7000, /datum/material/glass = 6000)
	build_path = /obj/item/fighter_component/primary/cannon
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/heavy_cannon
	name = "Fighter Primary Cannon (Heavy)"
	desc = "A standard fighter heavy cannon, capable of using higher caliber rounds. It weighs rather a lot more than its light counterpart but is extremely destructive."
	id = "heavy_cannon"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 7000, /datum/material/glass = 6000)
	build_path = /obj/item/fighter_component/primary/cannon/heavy
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/refuel_kit
	name = "Air to air refuel kit"
	desc = "A kit that allows utility fighters to transfer fuel, power and ammunition to another fighter."
	id = "refuel_kit"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/secondary/utility/resupply
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cargo_hold
	name = "Fighter Cargo Hold"
	desc = "A cargo hold for utility craft."
	id = "cargo_hold"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/primary/utility/hold
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/resupply
	name = "Air to Air repair kit"
	desc = "A module that allows utility craft to remotely repair fighter craft, when loaded with hull repair juice."
	id = "resupply"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/primary/utility/repairer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING
//Tier 2
/datum/design/fuel_tank_tier2
	name = "Upgraded Fighter Fuel Tank"
	desc = "A huge tank of fuel which can keep fighters in the air."
	id = "fuel_tank_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/fighter_component/fuel_tank/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/apu_tier2
	name = "Upgraded Fighter APU"
	desc = "A component used in fighter construction."
	id = "apu_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/copper = 15000)
	build_path = /obj/item/fighter_component/apu/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/armour_plating_tier2
	name = "Upgraded Fighter Armour"
	desc = "A component used in fighter construction."
	id = "armour_plating_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/armour_plating/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_engine_tier2
	name = "Upgraded Fighter Engine"
	desc = "A component used in fighter construction."
	id = "fighter_engine_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/diamond = 5000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/engine/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/ordnance_launcher_tier2
	name = "Upgraded Fighter Torpedo Rack"
	desc = "A component used in fighter construction."
	id = "ordnance_launcher_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/copper = 20000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/fighter_missile_launcher_tier2
	name = "Upgraded Fighter Missile Rack"
	desc = "A component used in fighter construction."
	id = "fighter_missile_launcher_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 12000, /datum/material/titanium = 10000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/oxygenator_tier2
	name = "Upgraded Fighter Atmospheric Regulator"
	desc = "An atmospheric regulation system for fighters which removes the need for a space suit at the cost of some power usage."
	id = "oxygenator_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 15000)
	build_path = /obj/item/fighter_component/oxygenator/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_battery_tier2
	name = "Upgraded Fighter Battery"
	desc = "A specialist lead-acid battery which is required to power fighter modules like APUs, oxygenators, and more!."
	id = "fighter_battery_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 17000, /datum/material/copper = 15000, /datum/material/glass = 12000)
	build_path = /obj/item/fighter_component/battery/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/refuel_kit_tier2
	name = "Upgraded Air to air refuel kit"
	desc = "A kit that allows utility fighters to transfer fuel, power and ammunition to another fighter."
	id = "refuel_kit_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/secondary/utility/resupply/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cargo_hold_tier2
	name = "Upgraded Fighter Cargo Hold"
	desc = "A cargo hold for utility craft."
	id = "cargo_hold_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/glass = 15000)
	build_path = /obj/item/fighter_component/primary/utility/hold/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/resupply_tier2
	name = "Upgraded Air to Air repair kit"
	desc = "A module that allows utility craft to remotely repair fighter craft, when loaded with hull repair juice."
	id = "resupply_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000)
	build_path = /obj/item/fighter_component/primary/utility/repairer/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING
//Tier 3
/datum/design/fuel_tank_tier3
	name = "Experimental Fighter Fuel Tank"
	desc = "An unreasonably large tank of fuel which can keep fighters in the air."
	id = "fuel_tank_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/titanium = 25000, /datum/material/glass = 25000)
	build_path = /obj/item/fighter_component/fuel_tank/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/apu_tier3
	name = "Experimental Fighter APU"
	desc = "A component used in fighter construction."
	id = "apu_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/copper = 15000, /datum/material/titanium = 25000)
	build_path = /obj/item/fighter_component/apu/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/armour_plating_tier3
	name = "Experimental Fighter Armour"
	desc = "A component used in fighter construction."
	id = "armour_plating_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 20000, /datum/material/diamond = 25000)
	build_path = /obj/item/fighter_component/armour_plating/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_engine_tier3
	name = "Experimental Fighter Engine"
	desc = "A component used in fighter construction."
	id = "fighter_engine_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/uranium = 15000, /datum/material/diamond = 10000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/engine/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/ordnance_launcher_tier3
	name = "Experimental Fighter Torpedo Rack"
	desc = "A component used in fighter construction."
	id = "ordnance_launcher_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma = 25000, /datum/material/copper = 20000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/fighter_missile_launcher_tier3
	name = "Experimental Fighter Missile Rack"
	desc = "A component used in fighter construction."
	id = "fighter_missile_launcher_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma = 15000, /datum/material/copper = 12000, /datum/material/titanium = 10000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/oxygenator_tier3
	name = "Experimental Fighter Atmospheric Regulator"
	desc = "An atmospheric regulation system for fighters which removes the need for a space suit at the cost of some power usage."
	id = "oxygenator_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 15000)
	build_path = /obj/item/fighter_component/oxygenator/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_battery_tier3
	name = "Experimental Fighter Battery"
	desc = "A specialist lead-acid battery which is required to power fighter modules like APUs, oxygenators, and more!."
	id = "fighter_battery_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/titanium = 15000, /datum/material/diamond = 5000)
	build_path = /obj/item/fighter_component/battery/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/refuel_kit_tier3
	name = "Experimental Air to air refuel kit"
	desc = "A kit that allows utility fighters to transfer fuel, power and ammunition to another fighter."
	id = "refuel_kit_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/copper = 7000, /datum/material/glass = 10000)
	build_path = /obj/item/fighter_component/secondary/utility/resupply/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cargo_hold_tier3
	name = "Experimental Fighter Cargo Hold"
	desc = "A cargo hold for utility craft."
	id = "cargo_hold_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/titanium = 15000)
	build_path = /obj/item/fighter_component/primary/utility/hold/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/resupply_tier3
	name = "Experimental Air to Air repair kit"
	desc = "A module that allows utility craft to remotely repair fighter craft, when loaded with hull repair juice."
	id = "resupply_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/glass = 15000, /datum/material/titanium = 5000 )
	build_path = /obj/item/fighter_component/primary/utility/repairer/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING
