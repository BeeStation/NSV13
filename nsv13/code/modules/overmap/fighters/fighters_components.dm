#define INELIGIBLE 2

////////Common Components///////
/obj/item/fighter_component
	name = "Fighter Component - PARENT"
	desc = "THIS IS A PARENT ITEM AND SHOULD NOT BE SPAWNED"
	icon = 'icons/obj/crates.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	var/burntout = FALSE
	var/for_chassis = 0

/obj/item/fighter_component/Initialize()
	.=..()
	AddComponent(/datum/component/twohanded/required) //These all require two hands to pick up

/obj/item/fighter_component/examine(mob/user)
	.=..()
	if(burntout)
		. += "<span class='notice'>It looks less than functional.</notice>"

/obj/item/fighter_component/proc/burn_out()
	if(burntout != FALSE)
		return
	var/prefix = pick("Burned Out", "Charred", "Singed", "Scorched", "Mangled", "Damaged", "Warped", "Corroded", "Deformed")
	name = "[prefix] [name]"
	burntout = TRUE

/obj/item/fighter_component/primary
	name = "Fighter Component Primary - PARENT"
	var/weapon_type_path_one = null
	var/weapon_type_path_two = null
	var/ammo_capacity = 0

/obj/item/fighter_component/primary/examine(mob/user)
	.=..()
	. += "<span class='notice'>This is a primary module.</span>"

/obj/item/fighter_component/secondary
	name = "Fighter Component Secondary - PARENT"
	var/missile_capacity = 0
	var/torpedo_capacity = 0

/obj/item/fighter_component/secondary/examine(mob/user)
	.=..()
	. += "<span class='notice'>This is a secondary module.</span>"

/obj/item/fighter_component/fuel_tank
	name = "Fighter Fuel Tank - PARENT"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "fueltank"
	var/fuel_capacity = 0 //Fuel Capacity

/obj/item/fighter_component/fuel_tank/Initialize()
	.=..()
	create_reagents(fuel_capacity, DRAINABLE | AMOUNT_VISIBLE)

/obj/item/fighter_component/fuel_tank/t1
	name = "Fighter Fuel Tank"
	desc = "The fuel tank of a fighter"
	fuel_capacity = 1000

/obj/item/fighter_component/fuel_tank/t2
	name = "Fighter Extended Fuel Tank"
	desc = "The extended fuel tank of a fighter"
	fuel_capacity = 1500

/obj/item/fighter_component/fuel_tank/t3
	name = "Fighter Double Fuel Tank"
	desc = "The double fuel tank fo a fighter"
	fuel_capacity = 2000

/obj/item/fighter_component/fuel_tank/escapepod
	name = "Escapepod Fuel Tank"
	desc = "The fuel tank of a escapepod"
	fuel_capacity = 250

/obj/item/fighter_component/avionics
	name = "Fighter Avionics"
	desc = "Avionics for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "avionics"

/obj/item/fighter_component/apu
	name = "Fighter Auxiliary Power Unit"
	desc = "An Auxiliary Power Unit for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "apu"

/obj/item/fighter_component/armour_plating
	name = "Fighter Armour Plating - PARENT"
	icon_state = "engi_secure_crate"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "armour"
	var/armour = 1 //HP Modifier
	burntout = INELIGIBLE

/obj/item/fighter_component/targeting_sensor
	name = "Fighter Targeting Sensors - PARENT"
	icon_state = "weaponcrate"
	var/targeting_speed = 1 //Target lock speed modifier

/obj/item/fighter_component/engine
	name = "Fighter Engine - PARENT"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "engine"
	var/speed = 0 //Speed modifier
	var/consumption = 0 //How fast we burn fuel

/obj/item/fighter_component/countermeasure_dispenser
	name = "Fighter Countermeasure Dispenser - PARENT"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "countermeasure"
	var/countermeasure_capacity = 4

/obj/item/fighter_component/countermeasure_dispenser/t1
	name = "Fighter Countermeasure Dispenser"
	desc = "A Countermeasure Dispenser for a fighter"

/obj/item/fighter_component/countermeasure_dispenser/t2
	name = "Expanded Fighter Countermeasure Dispenser"
	desc = "An Expanded Countermeasure Dispenser for a fighter"
	countermeasure_capacity = 6

/obj/item/fighter_component/countermeasure_dispenser/t3
	name = "Double Fighter Countermeasure Dispenser"
	desc = "A Double Countermeasure Dispenser for a fighter"
	countermeasure_capacity = 8

////////Light Components///////

/obj/structure/fighter_component/light_chassis_crate
	name = "Light Fighter Chassis Components Crate"
	desc = "A crate full of chassis components for an Su-818 Rapier Light Fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	anchored = FALSE
	density = TRUE
	climbable = TRUE

/obj/item/fighter_component/armour_plating/light/t1
	name = "Light Fighter Armour Plating"
	desc = "Armour Plating for a Light Fighter"
	armour = 2
	for_chassis = 1

/obj/item/fighter_component/armour_plating/light/t2
	name = "Hardened Light Fighter Armour Plating"
	desc = "Hardened Armour Plating for a Light Fighter"
	armour = 2.25
	for_chassis = 1

/obj/item/fighter_component/armour_plating/light/t3
	name = "Reinforced Light Fighter Armour Plating"
	desc = "Reinforced Armour Plating for a Light Fighter"
	armour = 3
	for_chassis = 1

/obj/item/fighter_component/targeting_sensor/light/t1
	name = "Light Fighter Targeting Sensors"
	desc = "Targening Sensors for a Light Fighter"
	for_chassis = 1

/obj/item/fighter_component/targeting_sensor/light/t2
	name = "Improved Light Fighter Targeting Sensors"
	desc = "Improved Targeting Sensors for a Light Fighter"
	targeting_speed = 1.25
	for_chassis = 1

/obj/item/fighter_component/targeting_sensor/light/t3
	name = "Enhanced Light Fighter Targeting Sensors"
	desc = "Enhanced Targeting Sensors for a Light Fighter"
	targeting_speed = 1.5
	for_chassis = 1

/obj/item/fighter_component/engine/light/t1
	name = "Light Fighter Engine"
	desc = "An engine for a Light Fighter"
	speed = 1
	consumption = 1
	for_chassis = 1

/obj/item/fighter_component/engine/light/t2
	name = "Improved Light Fighter Engine"
	desc = "An improved engine for a Light Fighter"
	speed = 1.2
	consumption = 1.4
	for_chassis = 1

/obj/item/fighter_component/engine/light/t3
	name = "Enhanced Light Fighter Engine"
	desc = "An enhanced engine for a Light Fighter"
	speed = 1.4
	consumption = 1.8
	for_chassis = 1

/obj/item/fighter_component/secondary/light/missile_rack
	name = "Light Fighter Missile Rack - PARENT"
	icon_state = "weaponcrate"
	missile_capacity = 2
	burntout = INELIGIBLE
	for_chassis = 1

/obj/item/fighter_component/secondary/light/missile_rack/t1
	name = "Light Fighter Missile Rack"
	desc = "A missile rack for a light fighter"

/obj/item/fighter_component/secondary/light/missile_rack/t2
	name = "Large Light Fighter Missile Rack"
	desc = "A large missile rack for a light fighter"
	missile_capacity = 4

/obj/item/fighter_component/secondary/light/missile_rack/t3
	name = "Extra Large Light Fighter Missile Rack"
	desc = "An extra large missile rack for a light fighter"
	missile_capacity = 6

/obj/item/fighter_component/primary/light/light_cannon
	name = "Light Fighter Light Cannon - PARENT"
	icon_state = "plasmacrate"
	weapon_type_path_one = /datum/ship_weapon/light_cannon
	var/fire_rate = 1
	ammo_capacity = 1
	var/projectile = null
	for_chassis = 1

/obj/item/fighter_component/primary/light/light_cannon/t1
	name = "Light Fighter Light Cannon"
	desc = "A light cannon for a light fighter"

/obj/item/fighter_component/primary/light/light_cannon/t2
	name = "Improved Light Fighter Light Cannon"
	desc = "An improved light cannon for a light fighter"
	fire_rate = 1.1
	ammo_capacity = 1

/obj/item/fighter_component/primary/light/light_cannon/t3
	name = "Enhanced Light Fighter Light Cannon"
	desc = "An enhanced light cannon for a light fighter"
	fire_rate = 1.2
	ammo_capacity = 2

////////Heavy Components///////

/obj/structure/fighter_component/heavy_chassis_crate
	name = "Heavy Fighter Chassis Components Crate"
	desc = "A crate full of chassis components for an A-395 Scimitar Heavy Attacker"
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	anchored = FALSE
	density = TRUE
	climbable = TRUE

/obj/item/fighter_component/armour_plating/heavy/t1
	name = "Heavy Fighter Armour Plating"
	desc = "Armour Plating for a Heavy Fighter"
	armour = 2
	for_chassis = 2

/obj/item/fighter_component/armour_plating/heavy/t2
	name = "Hardened Heavy Fighter Armour Plating"
	desc = "Hardened Armour Plating for a Heavy Fighter"
	armour = 2.25
	for_chassis = 2

/obj/item/fighter_component/armour_plating/heavy/t3
	name = "Reinforced Heavy Fighter Armour Plating"
	desc = "Reinforced Armour Plating for a Heavy Fighter"
	armour = 2.5
	for_chassis = 2

/obj/item/fighter_component/targeting_sensor/heavy/t1
	name = "Heavy Fighter Targeting Sensors"
	desc = "Targening Sensors for a Heavy Fighter"
	targeting_speed = 0.9
	for_chassis = 2

/obj/item/fighter_component/targeting_sensor/heavy/t2
	name = "Improved Heavy Fighter Targeting Sensors"
	desc = "Improved Targeting Sensors for a Heavy Fighter"
	targeting_speed = 1.15
	for_chassis = 2

/obj/item/fighter_component/targeting_sensor/heavy/t3
	name = "Enhanced Heavy Fighter Targeting Sensors"
	desc = "Enhanced Targeting Sensors for a Heavy Fighter"
	targeting_speed = 1.40
	for_chassis = 2

/obj/item/fighter_component/engine/heavy/t1
	name = "Heavy Fighter Engine"
	desc = "An engine for a Heavy Fighter"
	speed = 1
	consumption = 1
	for_chassis = 2

/obj/item/fighter_component/engine/heavy/t2
	name = "Improved Heavy Fighter Engine"
	desc = "An improved engine for a Heavy Fighter"
	speed = 1.1
	consumption = 1.2
	for_chassis = 2

/obj/item/fighter_component/engine/heavy/t3
	name = "Enhanced Heavy Fighter Engine"
	desc = "An enhanced engine for a Heavy Fighter"
	speed = 1.2
	consumption = 1.4
	for_chassis = 2

/obj/item/fighter_component/secondary/heavy/torpedo_rack
	name = "Heavy Fighter Torpedo Rack"
	icon_state = "weaponcrate"
	missile_capacity = 0
	torpedo_capacity = 2
	burntout = INELIGIBLE
	for_chassis = 2

/obj/item/fighter_component/secondary/heavy/torpedo_rack/t1
	name = "Heavy Fighter Torpedo Rack"
	desc = "A torpedo rack for a heavy fighter"

/obj/item/fighter_component/secondary/heavy/torpedo_rack/t2
	name = "Large Heavy Fighter Torpedo Rack"
	desc = "A large torpedo rack for a heavy fighter"
	missile_capacity = 1
	torpedo_capacity = 3

/obj/item/fighter_component/secondary/heavy/torpedo_rack/t3
	name = "Extra Large Heavy Fighter Torpedo Rack"
	desc = "An extra large torpedo rack for a heavy fighter"
	missile_capacity = 2
	torpedo_capacity = 4

/obj/item/fighter_component/primary/heavy/heavy_cannon
	name = "Heavy Fighter Heavy Cannon - PARENT"
	icon_state = "plasmacrate"
	weapon_type_path_one = /datum/ship_weapon/heavy_cannon
	var/fire_rate = 1
	ammo_capacity = 1
	var/projectile = null
	for_chassis = 2

/obj/item/fighter_component/primary/heavy/heavy_cannon/t1
	name = "Heavy Fighter Heavy Cannon"
	desc = "A heavy cannon for a heavy fighter"

/obj/item/fighter_component/primary/heavy/heavy_cannon/t2
	name = "Improved Heavy Fighter Heavy Cannon"
	desc = "An improved heavy cannon for a heavy fighter"
	fire_rate = 1.1
	ammo_capacity = 1

/obj/item/fighter_component/primary/heavy/heavy_cannon/t3
	name = "Enhanced Heavy Fighter Heavy Cannon"
	desc = "An enhanced heavy cannon for a heavy fighter"
	fire_rate = 1.2
	ammo_capacity = 2

////////Utility Components////////

/obj/structure/fighter_component/utility_chassis_crate
	name = "Utility Vessel Chassis Components Crate"
	desc = "A crate full of chassis components for an Su-437 Sabre Utility Vessel"
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	anchored = FALSE
	density = TRUE
	climbable = TRUE

/obj/item/fighter_component/armour_plating/utility/t1
	name = "Utility Vessel Armour Plating"
	desc = "Armour Plating for a Utility Vessel"
	armour = 2
	for_chassis = 3

/obj/item/fighter_component/armour_plating/utility/t2
	name = "Hardened Utility Vessel Armour Plating"
	desc = "Hardened Armour Plating for a Utility Vessel"
	armour = 2.25
	for_chassis = 3

/obj/item/fighter_component/armour_plating/utility/t3
	name = "Reinforced Utility Vessel Armour Plating"
	desc = "Reinforced Armour Plating for a Utility Vessel"
	armour = 2.5
	for_chassis = 3

/obj/item/fighter_component/engine/utility/t1
	name = "Utility Vessel Engine"
	desc = "An engine for a Utility Vessel"
	speed = 1
	consumption = 1
	for_chassis = 3

/obj/item/fighter_component/engine/utility/t2
	name = "Improved Utility Vessel Engine"
	desc = "An improved engine for a Utility Vessel"
	speed = 1.05
	consumption = 0.9
	for_chassis = 3

/obj/item/fighter_component/engine/utility/t3
	name = "Enhanced Utility Vessel Engine"
	desc = "An enhanced engine for a Utility Vessel"
	speed = 1.1
	consumption = 0.8
	for_chassis = 3

/obj/item/fighter_component/primary/utility/refueling_system
	name = "Utility Vessel Refueling System"
	desc = "A refueling system for a Utility Vessel"
	icon_state = "crate"
	weapon_type_path_one = /datum/ship_weapon/refueling_system
	for_chassis = 3

/obj/item/fighter_component/primary/utility/search_rescue_module
	name = "Utility Vessel Search And Rescue Module"
	desc = "A search and rescue module for a Utility vessel"
	icon_state = "crate"
	weapon_type_path_one = /datum/ship_weapon/search_rescue_scoop
	weapon_type_path_two = /datum/ship_weapon/search_rescue_extractor
	for_chassis = 3

/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank
	name = "Utility Vessel Auxiliary Fuel Tank - PARENT"
	desc = "THIS IS A PARENT ITEM AND SHOULD NOT BE SPAWNED"
	icon_state = "crate"
	var/aux_capacity = 3000
	for_chassis = 3

/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/Initialize()
	.=..()
	create_reagents(aux_capacity, DRAINABLE | AMOUNT_VISIBLE)

/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/t1
	name = "Utility Vessel Auxiliary Fuel Tank"
	desc = "An auxiliary fuel tank for a Utility Vessel"

/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/t2
	name = "Large Utility Vessel Auxiliary Fuel Tank"
	desc = "A large auxiliary fuel tank for a Utility Vessel"
	aux_capacity = 4000

/obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/t3
	name = "Extra Large Utility Vessel Auxiliary Fuel Tank"
	desc = "An extra large auxiliary fuel tank for a Utility Vessel"
	aux_capacity = 5000

/obj/item/fighter_component/primary/utility/rapid_breach_sealing_module
	name = "Rapid Breach Sealing Module"
	desc = "A rapid breach sealing module for a Utility Vessel" //welder and smart foam
	icon_state = "crate"
	weapon_type_path_one = /datum/ship_weapon/rapid_breach_sealing_welder
	weapon_type_path_two = /datum/ship_weapon/rapid_breach_sealing_foam
	for_chassis = 3

/obj/item/fighter_component/secondary/utility/rbs_reagent_tank
	name = "RBS Reagent Tank - PARENT"
	icon_state = "crate"
	var/rbs_capacity = 200
	burntout = INELIGIBLE
	for_chassis = 3

/obj/item/reagent_containers/rbs_welder_tank
	name = "Rapid Breach Sealing Welder Tank"
	reagent_flags = NO_REACT

/obj/item/reagent_containers/rbs_foamer_tank
	name = "Rapid Breach Sealing Foamer Tank"
	reagent_flags = NO_REACT

/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/Initialize()
	.=..()
	var/obj/item/reagent_containers/rbs_welder_tank/welder_reagent_tank = new(src)
	var/obj/item/reagent_containers/rbs_foamer_tank/foam_reagent_tank = new(src)
	welder_reagent_tank.reagents.maximum_volume = rbs_capacity
	foam_reagent_tank.reagents.maximum_volume = rbs_capacity

/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/t1
	name = "RBS Reagent Tank"
	desc = "A reagent tank for the RBS module for a Utility Vessel"

/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/t2
	name = "Large RBS Reagent Tank"
	desc = "A large reagent tank for the RBS module for a Utility Vessel"
	rbs_capacity = 300

/obj/item/fighter_component/secondary/utility/rbs_reagent_tank/t3
	name = "RBS Reagent Tank"
	desc = "An extra large reagent tank for the RBS module for a Utility Vessel"
	rbs_capacity = 400

/obj/item/fighter_component/secondary/utility/passenger_compartment_module
	name = "Utility Vessel Passenger Compartment Module - PARENT"
	icon_state = "crate"
	var/passenger_capacity = 4
	for_chassis = 3

/obj/item/fighter_component/secondary/utility/passenger_compartment_module/t1
	name = "Utility Vessel Passenger Compartment Module"
	desc = "A passenger compartment module and recovery system for a Utility Vessel"

/obj/item/fighter_component/secondary/utility/passenger_compartment_module/t2
	name = "Expanded Utility Vessel Passenger Compartment Module"
	desc = "An expanded passenger compartment module and recovery system for a Utility Vessel"
	passenger_capacity = 5

/obj/item/fighter_component/secondary/utility/passenger_compartment_module/t3
	name = "Extended Utility Vessel Passenger Compartment Module"
	desc = "An extended passenger compartment module and recovery system for a Utility Vessel"
	passenger_capacity = 6

/////COMPONENT TECHWEB/////

/datum/techweb_node/fighter_fabrication
	id = "fighter_fabrication"
	display_name = "Fighter Fabrication"
	description = "The precursor step into fabricating new fighter & utility craft."
	prereq_ids = list("explosive_weapons")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 1000

/datum/techweb_node/fighter_common_component_fabrication_t1
	id = "fighter_common_component_fabrication_t1"
	display_name = "Fighter Common Component Fabrication"
	description = "Access to common components required for fighter fabrication."
	prereq_ids = list("fighter_fabrication")
	design_ids = list("fuel_tank_t1", "fighter_countermeasure_dispenser_t1", "fighter_avionics", "fighter_apu")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 1000

/datum/techweb_node/fighter_common_component_fabrication_t2
	id = "fighter_common_component_fabrication_t2"
	display_name = "Improved Fighter Common Component Fabrication"
	description = "Improved common components required for fighter fabrication."
	prereq_ids = list("fighter_common_component_fabrication_t1")
	design_ids = list("fuel_tank_t2", "fighter_countermeasure_dispenser_t2")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 2000

/datum/techweb_node/fighter_common_component_fabrication_t3
	id = "fighter_common_component_fabrication_t3"
	display_name = "Enhanced Fighter Common Component Fabrication"
	description = "Enhanced common components required for fighter fabrication."
	prereq_ids = list("fighter_common_component_fabrication_t2")
	design_ids = list("fuel_tank_t3", "fighter_countermeasure_dispenser_t3")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 15000)
	export_price = 3000

/datum/techweb_node/light_fighter_fabrication
	id = "light_fighter_fabrication"
	display_name = "Light Fighter Fabrication"
	description = "Lightweight Fighters designed for space superiority duties"
	prereq_ids = list("fighter_fabrication", "fighter_common_component_fabrication_t1")
	design_ids = list("light_chassis_crate")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 1000

/datum/techweb_node/light_fighter_component_fabrication_t1
	id = "light_fighter_component_fabrication_t1"
	display_name = "Light Fighter Component Fabrication"
	description = "Access to components required for light fighter fabrication."
	prereq_ids = list("light_fighter_fabrication")
	design_ids = list("light_fighter_armour_plating_t1", "light_targeting_sensor_t1", "light_engine_t1", "fighter_missile_rack_t1", "light_fighter_light_cannon_t1")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 1000

/datum/techweb_node/light_fighter_component_fabrication_t2
	id = "light_fighter_component_fabrication_t2"
	display_name = "Improved Light Fighter Component Fabrication"
	description = "Improved components required for light fighter fabrication."
	prereq_ids = list("light_fighter_component_fabrication_t1")
	design_ids = list("light_fighter_armour_plating_t2", "light_targeting_sensor_t2", "light_engine_t2", "fighter_missile_rack_t2", "light_fighter_light_cannon_t2")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 2000

/datum/techweb_node/light_fighter_component_fabrication_t3
	id = "light_fighter_component_fabrication_t3"
	display_name = "Enhanced Light Fighter Component Fabrication"
	description = "Enhanced components required for light fighter fabrication."
	prereq_ids = list("light_fighter_component_fabrication_t2")
	design_ids = list("light_fighter_armour_plating_t3", "light_targeting_sensor_t3", "light_engine_t3", "fighter_missile_rack_t3", "light_fighter_light_cannon_t3")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 15000)
	export_price = 3000

/datum/techweb_node/heavy_fighter_fabrication
	id = "heavy_fighter_fabrication"
	display_name = "Heavy Fighter Fabrication"
	description = "Heavyweight Fighters designed for clearing soft target and hard targets alike"
	prereq_ids = list("fighter_fabrication", "fighter_common_component_fabrication_t1")
	design_ids = list("heavy_chassis_crate")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 1000

/datum/techweb_node/heavy_fighter_component_fabrication_t1
	id = "heavy_fighter_component_fabrication_t1"
	display_name = "Heavy Fighter Component Fabrication"
	description = "Access to components required for heavy fighter fabrication."
	prereq_ids = list("heavy_fighter_fabrication")
	design_ids = list("heavy_fighter_armour_plating_t1", "heavy_targeting_sensor_t1", "heavy_engine_t1", "heavy_torpedo_rack_t1", "heavy_fighter_heavy_cannon_t1")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 1000

/datum/techweb_node/heavy_fighter_component_fabrication_t2
	id = "heavy_fighter_component_fabrication_t2"
	display_name = "Improved Heavy Fighter Component Fabrication"
	description = "Improved components required for heavy fighter fabrication."
	prereq_ids = list("heavy_fighter_component_fabrication_t1")
	design_ids = list("heavy_fighter_armour_plating_t2", "heavy_targeting_sensor_t2", "heavy_engine_t2", "heavy_torpedo_rack_t2", "heavy_fighter_heavy_cannon_t2")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 2000

/datum/techweb_node/heavy_fighter_component_fabrication_t3
	id = "heavy_fighter_component_fabrication_t3"
	display_name = "Enhanced Heavy Fighter Component Fabrication"
	description = "Enhanced components required for heavy fighter fabrication."
	prereq_ids = list("heavy_fighter_component_fabrication_t2")
	design_ids = list("heavy_fighter_armour_plating_t3", "heavy_targeting_sensor_t3", "heavy_engine_t3", "heavy_torpedo_rack_t3", "heavy_fighter_heavy_cannon_t3")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 15000)
	export_price = 3000

/datum/techweb_node/utility_craft_fabrication
	id = "utility_craft_fabrication"
	display_name = "Utility Vessel Fabrication"
	description = "Utility Vessel designed for support duties"
	prereq_ids = list("fighter_fabrication", "fighter_common_component_fabrication_t1")
	design_ids = list("utility_chassis_crate")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 1000

/datum/techweb_node/utility_craft_component_fabrication_t1
	id = "utility_craft_component_fabrication_t1"
	display_name = "Utility Vessel Component Fabrication"
	description = "Access to components required for utility vessel fabrication."
	prereq_ids = list("utility_craft_fabrication", "exp_tools")
	design_ids = list("utility_craft_armour_plating_t1", "utility_engine_t1", "utility_refueling_system", "utility_auxiliary_fuel_tank_t1", "utility_passenger_compartment_module_t1", "utility_rapid_breach_sealing_module", "utility_search_rescue_module", "utility_rbs_reagent_tank_t1")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 1000

/datum/techweb_node/utility_craft_component_fabrication_t2
	id = "utility_craft_component_fabrication_t2"
	display_name = "Improved Utility Craft Component Fabrication"
	description = "Improved components required for utility vessel fabrication."
	prereq_ids = list("utility_craft_component_fabrication_t1")
	design_ids = list("utility_craft_armour_plating_t2", "utility_engine_t2", "utility_auxiliary_fuel_tank_t2", "utility_passenger_compartment_module_t2", "utility_rbs_reagent_tank_t2")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 2000

/datum/techweb_node/utility_craft_component_fabrication_t3
	id = "utility_craft_component_fabrication_t3"
	display_name = "Enhanced Utility Vessel Component Fabrication"
	description = "Enhanced components required for utility vessel fabrication."
	prereq_ids = list("utility_craft_component_fabrication_t2")
	design_ids = list("utility_craft_armour_plating_t3", "utility_engine_t3", "utility_auxiliary_fuel_tank_t3", "utility_passenger_compartment_module_t3", "utility_rbs_reagent_tank_t3")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 15000)
	export_price = 3000

/datum/techweb_node/fighter_control_console
	id = "fighter_control_console"
	display_name = "Remote Monitoring and Control of Fighters"
	description = "Pesky pilots making a mess of the hangar with their guns? Lock their weapons down with this easy one click console."
	prereq_ids = list("fighter_fabrication")
	design_ids = list("fighter_computer_circuit")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 500

/////COMPONENT DESIGNS/////

/datum/design/light_chassis_crate
	name = "Light Fighter Chassis Crate"
	desc = "A crate full of components for the construction of a light fighter chassis"
	id = "light_chassis_crate"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/titanium = 10000, /datum/material/copper = 7500, /datum/material/glass = 7500, /datum/material/plasma = 2500)
	build_path = /obj/structure/fighter_component/light_chassis_crate
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/heavy_chassis_crate
	name = "Heavy Fighter Chassis Crate"
	desc = "A crate full of components for the construction of a heavy fighter chassis"
	id = "heavy_chassis_crate"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 25000, /datum/material/copper = 17500, /datum/material/glass = 12500, /datum/material/plasma = 5000)
	build_path = /obj/structure/fighter_component/heavy_chassis_crate
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_chassis_crate
	name = "Utility Vessel Chassis Crate"
	desc = "A crate full of components for the construction of a utility vessel chassis"
	id = "utility_chassis_crate"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 12500, /datum/material/titanium = 12500, /datum/material/copper = 12500, /datum/material/glass = 17500, /datum/material/plasma = 3500)
	build_path = /obj/structure/fighter_component/utility_chassis_crate
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_fuel_tank_t1
	name = "Fighter Fuel Tank"
	desc = "A fuel tank for a fighter"
	id = "fuel_tank_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 1000, /datum/material/plasma = 500)
	build_path = /obj/item/fighter_component/fuel_tank/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_fuel_tank_t2
	name = "Extended Fuel Tank"
	desc = "An extended fuel tank for a fighter"
	id = "fuel_tank_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 2000, /datum/material/copper = 1000, /datum/material/plasma = 2500, /datum/material/silver = 2000)
	build_path = /obj/item/fighter_component/fuel_tank/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_fuel_tank_t3
	name = "Double Fuel Tank"
	desc = "A double fuel tank for a fighter"
	id = "fuel_tank_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/titanium = 2500, /datum/material/copper = 2000, /datum/material/plasma = 5000, /datum/material/silver = 4000)
	build_path = /obj/item/fighter_component/fuel_tank/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_avionics
	name = "Fighter Avionics"
	desc = "Avionics for a fighter"
	id = "fighter_avionics"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 1000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/avionics
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/fighter_apu
	name = "Fighter Auxiliary Power Unit"
	desc = "An Auxiliary Power Unit for a fighter"
	id = "fighter_apu"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 7500, /datum/material/glass = 3000, /datum/material/plasma = 1250)
	build_path = /obj/item/fighter_component/apu
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_countermeasure_dispenser_t1
	name = "Fighter Countermeasure Dispenser"
	desc = "A Countermeasure Dispenser for a fighter"
	id = "fighter_countermeasure_dispenser_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/titanium = 1000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/countermeasure_dispenser/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_countermeasure_dispenser_t2
	name = "Expanded Fighter Countermeasure Dispenser"
	desc = "An Expanded Countermeasure Dispenser for a fighter"
	id = "fighter_countermeasure_dispenser_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/titanium = 1500, /datum/material/copper = 5000, /datum/material/glass = 5000, /datum/material/gold = 2500)
	build_path = /obj/item/fighter_component/countermeasure_dispenser/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_countermeasure_dispenser_t3
	name = "Double Fighter Countermeasure Dispenser"
	desc = "A Double Fighter Countermeasure Dispenser"
	id = "fighter_countermeasure_dispenser_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/titanium = 1000, /datum/material/copper = 5000, /datum/material/glass = 5000, /datum/material/gold = 3000, /datum/material/uranium = 2000)
	build_path = /obj/item/fighter_component/countermeasure_dispenser/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/light_fighter_armour_plating_t1
	name = "Light Fighter Armour Plating"
	desc = "Armour Plating for a Light Fighter"
	id = "light_fighter_armour_plating_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 5000, /datum/material/plasma = 5000)
	build_path = /obj/item/fighter_component/armour_plating/light/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/light_fighter_armour_plating_t2
	name = "Hardened Light Fighter Armour Plating"
	desc = "Hardened Armour Plating for a Light Fighter"
	id = "light_fighter_armour_plating_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 7500, /datum/material/plasma = 7500, /datum/material/silver = 7500)
	build_path = /obj/item/fighter_component/armour_plating/light/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/light_fighter_armour_plating_t3
	name = "Reinforced Light Fighter Armour Plating"
	desc = "Reinforced Armour Plating for a Light Fighter"
	id = "light_fighter_armour_plating_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 10000, /datum/material/plasma = 10000, /datum/material/silver = 7500, /datum/material/uranium = 7500)
	build_path = /obj/item/fighter_component/armour_plating/light/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/light_targeting_sensor_t1
	name = "Light Fighter Targeting Sensors"
	desc = "Targening Sensors for a Light Fighter"
	id = "light_targeting_sensor_t1"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/targeting_sensor/light/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/light_targeting_sensor_t2
	name = "Improved Light Fighter Targeting Sensors"
	desc = "Improved Targening Sensors for a Light Fighter"
	id = "light_targeting_sensor_t2"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 6500, /datum/material/glass = 5000, /datum/material/gold = 3000)
	build_path = /obj/item/fighter_component/targeting_sensor/light/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/light_targeting_sensor_t3
	name = "Enhanced Light Fighter Targeting Sensors"
	desc = "Enhanced Targening Sensors for a Light Fighter"
	id = "light_targeting_sensor_t3"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 7000, /datum/material/glass = 5000, /datum/material/gold = 4000, /datum/material/bluespace = 2000)
	build_path = /obj/item/fighter_component/targeting_sensor/light/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/light_engine_t1
	name = "Light Fighter Engine"
	desc = "An engine for a Light Fighter"
	id = "light_engine_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000, /datum/material/titanium = 5000, /datum/material/plasma = 5000)
	build_path = /obj/item/fighter_component/engine/light/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/light_engine_t2
	name = "Improved Light Fighter Engine"
	desc = "An improved engine for a Light Fighter"
	id = "light_engine_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/copper = 4000, /datum/material/titanium = 7500, /datum/material/plasma = 10000, /datum/material/silver = 5000, /datum/material/gold = 2500)
	build_path = /obj/item/fighter_component/engine/light/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/light_engine_t3
	name = "Enhanced Light Fighter Engine"
	desc = "An enhanced engine for a Light Fighter"
	id = "light_engine_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 3000, /datum/material/titanium = 7500, /datum/material/plasma = 10000, /datum/material/silver = 5000, /datum/material/gold = 2500, /datum/material/diamond = 5000, /datum/material/uranium = 7500)
	build_path = /obj/item/fighter_component/engine/light/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_missile_rack_t1
	name = "Light Fighter Missile Rack"
	desc = "A missile rack for a light fighter"
	id = "fighter_missile_rack_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 2500, /datum/material/glass = 500)
	build_path = /obj/item/fighter_component/secondary/light/missile_rack/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_missile_rack_t2
	name = "Large Light Fighter Missile Rack"
	desc = "A large missile rack for a light fighter"
	id = "fighter_missile_rack_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 3000, /datum/material/glass = 1000)
	build_path = /obj/item/fighter_component/secondary/light/missile_rack/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/fighter_missile_rack_t3
	name = "Extra Large Light Fighter Missile Rack"
	desc = "An extra large missile rack for a light fighter"
	id = "fighter_missile_rack_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 3500, /datum/material/glass = 1500)
	build_path = /obj/item/fighter_component/secondary/light/missile_rack/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/light_fighter_light_cannon_t1
	name = "Light Fighter Light Cannon"
	desc = "A light cannon for a light fighter"
	id = "light_fighter_light_cannon_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 5000, /datum/material/copper = 1500, /datum/material/glass = 1000, /datum/material/plasma = 2000)
	build_path = /obj/item/fighter_component/primary/light/light_cannon/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/light_fighter_light_cannon_t2
	name = "Improved Light Fighter Light Cannon"
	desc = "An Improved light cannon for a light fighter"
	id = "light_fighter_light_cannon_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 6500, /datum/material/copper = 2500, /datum/material/glass = 1500, /datum/material/plasma = 2500, /datum/material/uranium = 1500)
	build_path = /obj/item/fighter_component/primary/light/light_cannon/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/light_fighter_light_cannon_t3
	name = "Enhanced Light Fighter Light Cannon"
	desc = "An enhanced light cannon for a light fighter"
	id = "light_fighter_light_cannon_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 7500, /datum/material/copper = 3500, /datum/material/glass = 2000, /datum/material/plasma = 3000, /datum/material/uranium = 2500, /datum/material/diamond = 2500)
	build_path = /obj/item/fighter_component/primary/light/light_cannon/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/heavy_fighter_armour_plating_t1
	name = "Heavy Fighter Armour Plating"
	desc = "Armour Plating for a Heavy Fighter"
	id = "heavy_fighter_armour_plating_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 7500, /datum/material/titanium = 7500, /datum/material/plasma = 7500)
	build_path = /obj/item/fighter_component/armour_plating/heavy/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/heavy_fighter_armour_plating_t2
	name = "Hardened Heavy Fighter Armour Plating"
	desc = "Hardened Armour Plating for a Heavy Fighter"
	id = "heavy_fighter_armour_plating_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 7500, /datum/material/titanium = 10000, /datum/material/plasma = 10000, /datum/material/silver = 12500)
	build_path = /obj/item/fighter_component/armour_plating/heavy/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/heavy_fighter_armour_plating_t3
	name = "Reinforced Heavy Fighter Armour Plating"
	desc = "Reinforced Armour Plating for a Heavy Fighter"
	id = "heavy_fighter_armour_plating_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 7500, /datum/material/titanium = 11500, /datum/material/plasma = 12500, /datum/material/silver = 17500, /datum/material/uranium = 7500, /datum/material/diamond = 2000)
	build_path = /obj/item/fighter_component/armour_plating/heavy/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/heavy_targeting_sensor_t1
	name = "Heavy Fighter Targeting Sensors"
	desc = "Targening Sensors for a Heavy Fighter"
	id = "heavy_targeting_sensor_t1"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/targeting_sensor/heavy/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/heavy_targeting_sensor_t2
	name = "Improved Heavy Fighter Targeting Sensors"
	desc = "Improved Targening Sensors for a Heavy Fighter"
	id = "heavy_targeting_sensor_t2"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 6500, /datum/material/glass = 5000, /datum/material/gold = 3000)
	build_path = /obj/item/fighter_component/targeting_sensor/heavy/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/heavy_targeting_sensor_t3
	name = "Enhanced Heavy Fighter Targeting Sensors"
	desc = "Enhanced Targening Sensors for a Heavy Fighter"
	id = "heavy_targeting_sensor_t3"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 7000, /datum/material/glass = 5000, /datum/material/gold = 4000, /datum/material/bluespace = 2000)
	build_path = /obj/item/fighter_component/targeting_sensor/heavy/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/heavy_engine_t1
	name = "Heavy Fighter Engine"
	desc = "An engine for a Heavy Fighter"
	id = "heavy_engine_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000, /datum/material/titanium = 5000, /datum/material/plasma = 5000)
	build_path = /obj/item/fighter_component/engine/heavy/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/heavy_engine_t2
	name = "Improved Heavy Fighter Engine"
	desc = "An improved engine for a Heavy Fighter"
	id = "heavy_engine_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/copper = 4000, /datum/material/titanium = 7500, /datum/material/plasma = 10000, /datum/material/silver = 5000, /datum/material/gold = 2500)
	build_path = /obj/item/fighter_component/engine/heavy/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/heavy_engine_t3
	name = "Enhanced Heavy Fighter Engine"
	desc = "An enhanced engine for a Heavy Fighter"
	id = "heavy_engine_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 3000, /datum/material/titanium = 7500, /datum/material/plasma = 10000, /datum/material/silver = 5000, /datum/material/gold = 2500, /datum/material/diamond = 5000, /datum/material/uranium = 7500)
	build_path = /obj/item/fighter_component/engine/heavy/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/heavy_torpedo_rack_t1
	name = "Heavy Fighter Torpedo Rack"
	desc = "A torpedo rack for a heavy fighter"
	id = "heavy_torpedo_rack_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 2500, /datum/material/glass = 500, /datum/material/titanium = 5000)
	build_path = /obj/item/fighter_component/secondary/heavy/torpedo_rack/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/heavy_torpedo_rack_t2
	name = "Large Heavy Fighter Torpedo Rack"
	desc = "A large torpedo rack for a heavy fighter"
	id = "heavy_torpedo_rack_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 3000, /datum/material/glass = 1000, /datum/material/titanium = 10000)
	build_path = /obj/item/fighter_component/secondary/heavy/torpedo_rack/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/heavy_torpedo_rack_t3
	name = "Extra Large Heavy Fighter Torpedo Rack"
	desc = "An extra large torpedo rack for a heavy fighter"
	id = "heavy_torpedo_rack_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 3500, /datum/material/glass = 1500, /datum/material/titanium = 15000)
	build_path = /obj/item/fighter_component/secondary/heavy/torpedo_rack/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/heavy_fighter_heavy_cannon_t1
	name = "Heavy Fighter Heavy Cannon"
	desc = "A heavy cannon for a heavy fighter"
	id = "heavy_fighter_heavy_cannon_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 10000, /datum/material/copper = 1500, /datum/material/glass = 1000, /datum/material/plasma = 5000)
	build_path = /obj/item/fighter_component/primary/heavy/heavy_cannon/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/heavy_fighter_heavy_cannon_t2
	name = "Improved Heavy Fighter Heavy Cannon"
	desc = "An improved heavy cannon for a heavy fighter"
	id = "heavy_fighter_heavy_cannon_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 12000, /datum/material/copper = 2500, /datum/material/glass = 1500, /datum/material/plasma = 7500, /datum/material/uranium = 2500)
	build_path = /obj/item/fighter_component/primary/heavy/heavy_cannon/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/heavy_fighter_heavy_cannon_t3
	name = "Enhanced Heavy Fighter Heavy Cannon"
	desc = "An enhanced heavy cannon for a heavy fighter"
	id = "heavy_fighter_heavy_cannon_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 14000, /datum/material/copper = 3500, /datum/material/glass = 2000, /datum/material/plasma = 10000, /datum/material/uranium = 5000, /datum/material/diamond = 5000)
	build_path = /obj/item/fighter_component/primary/heavy/heavy_cannon/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/utility_craft_armour_plating_t1
	name = "Utility Vessel Armour Plating"
	desc = "Armour Plating for a Utility Vessel"
	id = "utility_craft_armour_plating_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 5000, /datum/material/plasma = 5000)
	build_path = /obj/item/fighter_component/armour_plating/utility/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_craft_armour_plating_t2
	name = "Hardened Utility Vessel Armour Plating"
	desc = "Hardened Armour Plating for a Utility Vessel"
	id = "utility_craft_armour_plating_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 7500, /datum/material/plasma = 7500, /datum/material/silver = 7500)
	build_path = /obj/item/fighter_component/armour_plating/utility/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_craft_armour_plating_t3
	name = "Reinforced Utility Vessel Armour Plating"
	desc = "Reinforced Armour Plating for a Utility Vessel"
	id = "utility_craft_armour_plating_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 10000, /datum/material/plasma = 10000, /datum/material/silver = 7500, /datum/material/uranium = 7500)
	build_path = /obj/item/fighter_component/armour_plating/utility/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_engine_t1
	name = "Utility Vessel Engine"
	desc = "An engine for a Utility Vessel"
	id = "utility_engine_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000, /datum/material/titanium = 5000, /datum/material/plasma = 5000)
	build_path = /obj/item/fighter_component/engine/utility/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_engine_t2
	name = "Improved Utility Vessel Engine"
	desc = "An improved engine for a Utility Vessel"
	id = "utility_engine_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 8000, /datum/material/copper = 6000, /datum/material/titanium = 5000, /datum/material/plasma = 10000, /datum/material/silver = 5000, /datum/material/gold = 2500)
	build_path = /obj/item/fighter_component/engine/utility/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_engine_t3
	name = "Enhanced Utility Vessel Engine"
	desc = "An enhanced engine for a Utility Vessel"
	id = "utility_engine_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 12000, /datum/material/copper = 7000, /datum/material/titanium = 5000, /datum/material/plasma = 10000, /datum/material/silver = 5000, /datum/material/gold = 2500, /datum/material/diamond = 5000, /datum/material/uranium = 7500)
	build_path = /obj/item/fighter_component/engine/utility/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_refueling_system
	name = "Utility Vessel Refueling System"
	desc = "A refueling system for a Utility Vessel"
	id = "utility_refueling_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/titanium = 20000, /datum/material/copper = 12000, /datum/material/glass = 7500)
	build_path = /obj/item/fighter_component/primary/utility/refueling_system
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/utility_auxiliary_fuel_tank_t1
	name = "Utility Vessel Auxiliary Fuel Tank"
	desc = "An auxiliary fuel tank for a Utility Vessel"
	id = "utility_auxiliary_fuel_tank_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/copper = 5000, /datum/material/glass = 2500)
	build_path = /obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_auxiliary_fuel_tank_t2
	name = "Large Utility Vessel Auxiliary Fuel Tank"
	desc = "A large auxiliary fuel tank for a Utility Vessel"
	id = "utility_auxiliary_fuel_tank_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 30000, /datum/material/copper = 7500, /datum/material/glass = 3500, /datum/material/titanium = 1000)
	build_path = /obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_auxiliary_fuel_tank_t3
	name = "Extra Large Utility Vessel Auxiliary Fuel Tank"
	desc = "An extra large auxiliary fuel tank for a Utility Vessel"
	id = "utility_auxiliary_fuel_tank_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 40000, /datum/material/copper = 10000, /datum/material/glass = 4500, /datum/material/titanium = 2000, /datum/material/silver = 2000)
	build_path = /obj/item/fighter_component/secondary/utility/auxiliary_fuel_tank/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_search_rescue_module
	name = "Utility Vessel Search and Rescue Module"
	desc = "A search and rescue module for a Utility Vessel"
	id = "utility_search_rescue_module"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 10000, /datum/material/copper = 15000, /datum/material/glass = 10000)
	build_path = /obj/item/fighter_component/primary/utility/search_rescue_module
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/utility_passenger_compartment_module_t1
	name = "Utility Passenger Compartment Module"
	desc = "A passenger compartment module and recovery system for a Utility Vessel"
	id = "utility_passenger_compartment_module_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/titanium = 2000)
	build_path = /obj/item/fighter_component/secondary/utility/passenger_compartment_module/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_passenger_compartment_module_t2
	name = "Expanded Utility Passenger Compartment Module"
	desc = "An expanded passenger compartment module and recovery system for a Utility Vessel"
	id = "utility_passenger_compartment_module_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 30000, /datum/material/titanium = 2000, /datum/material/silver = 2000)
	build_path = /obj/item/fighter_component/secondary/utility/passenger_compartment_module/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_passenger_compartment_module_t3
	name = "Extended Utility Passenger Compartment Module"
	desc = "An Extended passenger compartment module and recovery system for a Utility Vessel"
	id = "utility_passenger_compartment_module_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 45000, /datum/material/titanium = 3000, /datum/material/silver = 3000, /datum/material/diamond = 5000)
	build_path = /obj/item/fighter_component/secondary/utility/passenger_compartment_module/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_rapid_breach_sealing_module
	name = "Utility Rapid Breach Sealing Module"
	desc = "A rapid breach sealing module for a Utility Vessel"
	id = "utility_rapid_breach_sealing_module"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 5000, /datum/material/copper = 25000, /datum/material/glass = 25000, /datum/material/gold = 10000)
	build_path = /obj/item/fighter_component/primary/utility/rapid_breach_sealing_module
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/utility_rbs_reagent_tank_t1
	name = "Utility RBS Reagent Tank"
	desc = "A reagent tank for the RBS module for a Utility Vessel"
	id = "utility_rbs_reagent_tank_t1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/titanium = 15000, /datum/material/glass = 3000, /datum/material/copper = 1500)
	build_path = /obj/item/fighter_component/secondary/utility/rbs_reagent_tank/t1
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_rbs_reagent_tank_t2
	name = "Utility Large RBS Reagent Tank"
	desc = "A large reagent tank for the RBS module for a Utility Vessel"
	id = "utility_rbs_reagent_tank_t2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/titanium = 25000, /datum/material/glass = 4500, /datum/material/copper = 3000, /datum/material/silver = 3000)
	build_path = /obj/item/fighter_component/secondary/utility/rbs_reagent_tank/t2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_rbs_reagent_tank_t3
	name = "Utility Extra Large RBS Reagent Tank"
	desc = "A extra large reagent tank for the RBS module for a Utility Vessel"
	id = "utility_rbs_reagent_tank_t3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/titanium = 35000, /datum/material/glass = 6000, /datum/material/copper = 4500, /datum/material/silver = 3000, /datum/material/bluespace = 5000)
	build_path = /obj/item/fighter_component/secondary/utility/rbs_reagent_tank/t3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

//Refueling

/datum/looping_sound/refuel
	mid_sounds = list('nsv13/sound/effects/fighters/refuel.ogg')
	mid_length = 8 SECONDS
	volume = 100

/obj/structure/reagent_dispensers/fueltank/aviation_fuel
	name = "Tyrosene fuel pump"
	desc = "A tank full of high performance aviation fuel with an inbuilt fuel pump for rapid fuel delivery"
	icon = 'nsv13/icons/obj/objects.dmi'
	icon_state = "jetfuel" //NSV13 - Modified objects.dmi to include a jet fuel container
	reagent_id = /datum/reagent/aviation_fuel
	tank_volume = 3500
	var/obj/item/jetfuel_nozzle/nozzle = null
	var/obj/structure/overmap/fighter/fuel_target
	var/datum/looping_sound/refuel/soundloop
	var/max_range = 2
	var/datum/beam/current_beam
	var/allow_refuel = FALSE

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!in_range(src, usr) && get_current_user() != usr) //Topic check
		return
	if(action == "stopfuel" && fuel_target)
		soundloop?.stop()
		visible_message("<span class='warning'>[icon2html(src)] refuelling cancelled.</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 100)
		fuel_target = null
		STOP_PROCESSING(SSobj, src)
	if(action == "transfer_mode")
		if(!allow_refuel)
			to_chat(usr, "<span class='notice'>You open [src]'s fuel inlet valve, it will now intake reagents from containers that it's hit with.</span>")
			allow_refuel = TRUE
		else
			to_chat(usr, "<span class='notice'>You close [src]'s fuel inlet valve, it will now transfer its reagents to containers that it's hit with.</span>")
			allow_refuel = FALSE

/**
* Function that will get the current wielder of "nozzle".
* @return The mob that's holding our nozzle, or null
*
*/

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/proc/get_current_user()
	var/mob/living/user = nozzle.loc
	if(!isliving(user))
		return null
	return user

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/can_interact(mob/user)
	if(user == get_current_user()) //If theyre holding the hose, bypass range checks so that they can see what they're currently fuelling.
		return TRUE
	if(!user.can_interact_with(src)) //Theyre too far away and not flying the ship
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	if(!can_interact(user))
		return
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AviationFuel", name, 400, 400, master_ui, state)
		ui.open()

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/ui_data(mob/user)
	var/list/data = list()
	if(!fuel_target)
		data["targetfuel"] = 0
		data["targetmaxfuel"] = 1000 //Default value to black out the fuel gauge.
	else
		data["targetfuel"] = fuel_target.get_fuel()
		data["targetmaxfuel"] = fuel_target.get_max_fuel()
	data["transfer_mode"] = allow_refuel
	data["fuel"] = reagents.total_volume
	data["maxfuel"] = reagents.maximum_volume
	return data

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/Initialize()
	. = ..()
	add_overlay("jetfuel_nozzle")
	nozzle = new(src)
	nozzle.parent = src
	soundloop = new(list(src), FALSE)
	reagents.flags |= REFILLABLE

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/attack_hand(mob/user)
	if(nozzle.loc == src)
		if(!user.put_in_hands(nozzle))
			to_chat(user, "<span class='warning'>You need a free hand to hold the fuel hose!</span>")
			return
		to_chat(user, "<span class='warning'>You grab [src]'s refuelling hose.</span>")
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/check_distance)
		toggle_nozzle(FALSE)
		ui_interact(user)
	else
		ui_interact(user)
		. = ..()

/obj/effect/ebeam/fuel_hose
	name = "fuel hose"
	layer = LYING_MOB_LAYER

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/proc/toggle_nozzle(state) //@param state: are you adding or removing the nozzle. True = adding, false = removing
	if(state)
		var/mob/user = get_current_user() //If they let the hose snap back in, unregister this way
		if(user)
			UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		add_overlay("jetfuel_nozzle")
		visible_message("<span class='warning'>[nozzle] snaps back into [src]!</span>")
		soundloop?.stop()
		qdel(current_beam)
		nozzle.forceMove(src)
		fuel_target = null
	else
		cut_overlay("jetfuel_nozzle")
		current_beam = new(get_current_user(),src,beam_icon='nsv13/icons/effects/beam.dmi',time=INFINITY,maxdistance = INFINITY,beam_icon_state="hose",btype=/obj/effect/ebeam/fuel_hose)
		INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/attackby(obj/item/I, mob/user, params)
	if(I == nozzle)
		to_chat(user, "<span class='warning'>You slot the fuel hose back into [src]</span>")
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED) //Otherwise unregister the signal here because they put it back cleanly
		nozzle.forceMove(src)
		toggle_nozzle(TRUE)
	if(allow_refuel)
		if(istype(I, /obj/item/reagent_containers))
			to_chat(user, "<span class='warning'>You transfer some of [I]'s contents to [src].</span>") //Put anything other than aviation fuel in here at your own risk of having to flush out the tank and possibly wreck your fighter :)
			var/obj/item/reagent_containers/X = I
			X.reagents.trans_to(X, X.amount_per_transfer_from_this, transfered_by = user)
	. = ..()

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/proc/start_fuelling(target)
	if(!target)
		return
	soundloop?.start()
	fuel_target = target
	START_PROCESSING(SSobj, src)

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/proc/check_distance()
	if(get_dist(get_current_user(), src) > max_range)// because nozzle, when in storage, will actually be in nullspace.
		toggle_nozzle(TRUE)
		STOP_PROCESSING(SSobj,src)
		return FALSE
	return TRUE

/obj/structure/reagent_dispensers/fueltank/aviation_fuel/process()
	if(!fuel_target)
		soundloop.stop()
		return PROCESS_KILL
	var/obj/item/fighter_component/fuel_tank/sft = fuel_target.get_part(/obj/item/fighter_component/fuel_tank)
	if(!sft)
		soundloop.stop()
		visible_message("<span class='warning'>[icon2html(src)] [fuel_target] does not have a fuel tank installed!</span>")
		return PROCESS_KILL
	var/transfer_amount = min(50, fuel_target.get_max_fuel()-fuel_target.get_fuel()) //Transfer as much as we can
	if(transfer_amount <= 0)
		soundloop?.stop()
		visible_message("<span class='warning'>[icon2html(src)] refuelling complete.</span>")
		playsound(src, 'sound/machines/ping.ogg', 100)
		fuel_target = null
		return PROCESS_KILL
	if(reagents.total_volume < transfer_amount)
		soundloop?.stop()
		visible_message("<span class='warning'>[icon2html(src)] insufficient fuel.</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 100)
		fuel_target = null
		return PROCESS_KILL
	reagents.trans_to(sft, transfer_amount)

/obj/item/jetfuel_nozzle
	name = "Aviation fuel delivery hose"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "atmos_nozzle"
	item_state = "nozzleatmos"
	item_flags = NOBLUDGEON | ABSTRACT  // don't put in storage
	slot_flags = 0
	var/obj/structure/reagent_dispensers/fueltank/aviation_fuel/parent

/obj/item/jetfuel_nozzle/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/jetfuel_nozzle/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(istype(target, /obj/structure/overmap/fighter))
		var/obj/structure/overmap/fighter/f16 = target
		var/obj/item/fighter_component/fuel_tank/sft = f16.get_part(/obj/item/fighter_component/fuel_tank)
		if(!sft)
			visible_message("<span class='warning'>[icon2html(src)] [f16] does not have a fuel tank installed!</span>")
			return
		if(f16.flight_state >= 6)
			to_chat(user, "<span class='notice'>[f16]'s engine is still running! Refuelling it now would be dangerous.</span>")
			playsound(src, 'sound/machines/buzz-two.ogg', 100)
			return
		if(f16.get_fuel() < f16.get_max_fuel())
			parent.start_fuelling(f16)
			to_chat(user, "<span class='notice'>You slot [src] into [f16]'s refuelling hatch.</span>")
			playsound(user, 'sound/machines/click.ogg', 60, 1)
			return
		else
			to_chat(user, "<span class='notice'>[f16]'s fuel tank is already full.</span>")
			return
#undef INELIGIBLE
