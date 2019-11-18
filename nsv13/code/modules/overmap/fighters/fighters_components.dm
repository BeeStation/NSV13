//Fighter Components

/obj/structure/fighter_component/fuselage_crate
	name = "Fighter Fuselage Components"
	desc = "A crate full of fuselage components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "radiation"
	anchored = FALSE
	density = TRUE
	climbable = TRUE

/obj/item/twohanded/required/fighter_component/cockpit
	name = "Fighter Cockpit Components"
	desc = "A box of cockpit components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/twohanded/required/fighter_component/wing
	name = "Fighter Wing Components"
	desc = "A box of wing components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "medicalcrate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/twohanded/required/fighter_component/empennage
	name = "Fighter Empennage Componets"
	desc = "A box of empennage components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "engi_e_crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/twohanded/required/fighter_component/landing_gear
	name = "Fighter Landing Gear Componets"
	desc = "A box of landing gear components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "engi_crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/twohanded/required/fighter_component/armour_plating
	name = "Fighter Armour Plating"
	desc = "Armour plating for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "engi_secure_crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC
	var/armour = 1.25 //HP Modifier

/obj/item/twohanded/required/fighter_component/armour_plating/improved
	name = "Fighter Improved Armour Plating"
	desc = "Improved armour plating for a fighter"
	armour = 1.5

/obj/item/twohanded/required/fighter_component/fuel_tank
	name = "Fighter Fuel Tank"
	desc = "The fuel tank of a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "secgearcrate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC
	var/capacity = 1000 //Fuel Capacity

/obj/item/twohanded/required/fighter_component/fuel_tank/extended
	name = "Fighter Extended Fuel Tank"
	desc = "The extended fuel tank of a fighter"
	capacity = 1500

/obj/item/fighter_component/avionics
	name = "Fighter Avionics"
	desc = "Avionics for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "freezer"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/fighter_component/targeting_sensor
	name = "Fighter Targeting Sensors"
	desc = "Targeting sensors for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "weaponcrate"
	w_class = WEIGHT_CLASS_NORMAL
	var/weapon_efficiency = 1 //Primary ammo usage modifier

/obj/item/fighter_component/targeting_sensor/enhanced
	name = "Fighter Enhanced Targeting Sensors"
	desc = "Enhanced targeting sensors for a fighter"
	weapon_efficiency = 0.8

/obj/item/fighter_component/fuel_lines
	name = "Fighter Fuel Lines Kit"
	desc = "Fuel line kit for routing fuel around a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "plasmacrate"
	w_class = WEIGHT_CLASS_BULKY
	var/fuel_efficiency = 1 //Fuel usage modifier

/obj/item/fighter_component/fuel_lines/streamlined
	name = "Fighter Streamlined Fuel Lines Kit"
	desc = "Streamlined fuel line kit for routing fuel around a fighter"
	fuel_efficiency = 0.8

/obj/item/twohanded/required/fighter_component/engine
	name = "Fighter Engine"
	desc = "An engine assembly for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "hydrocrate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC
	var/speed = 1 //Speed modifier
	var/consumption = 1 //How fast we burn fuel

/obj/item/twohanded/required/fighter_component/engine/overclocked
	name = "Fighter Overclocked Engine"
	desc = "An overclocked engine assembly for a fighter"
	speed = 1.2
	consumption = 1.2

/obj/item/twohanded/required/fighter_component/primary_cannon
	name = "Fighter Cannon"
	desc = "Fighter Cannon"
	icon = 'icons/obj/crates.dmi'
	icon_state = "o2crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

//Component Fabrication

/datum/techweb_node/fighter_component_fabrication
	id = "fighter_component_fabrication"
	display_name = "Fighter Component Fabrication"
	description = "The components required for the fabrication of new fighter craft."
	prereq_ids = list("explosive_weapons")
	design_ids = list("fighter_primary_cannon_components", "fighter_engine_components", "fighter_fuel_lines_package", "fighter_targeting_sensor_package", "fighter_avionics_package", "fighter_fuel_tank", "fighter_armour_plating", "fighter_landing_gear_components", "fighter_landing_gear_components", "fighter_empennage_components", "fighter_cockpit_wing", "fighter_cockpit_components", "fighter_fuselage_crate")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/design/fighter_fuselage_crate
	name = "Fighter Fuselage Crate"
	desc = "A crate full of fuselage components for a fighter"
	id = "fighter_fuselage_crate"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/silver = 5000)
	build_path = /obj/structure/fighter_component/fuselage_crate
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_cockpit_components
	name = "Fighter Cockpit Components"
	desc = "A box full of cockpit components for a fighter"
	id = "fighter_cockpit_components"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000)
	build_path = /obj/item/twohanded/required/fighter_component/cockpit
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_wing_components
	name = "Fighter Wing Components"
	desc = "A box full of wing components for a fighter"
	id = "fighter_cockpit_wing"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/twohanded/required/fighter_component/wing
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_empennage_components
	name = "Fighter Empennage Components"
	desc = "A box full of empennage components for a fighter"
	id = "fighter_empennage_components"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/twohanded/required/fighter_component/empennage
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_landing_gear_components
	name = "Fighter Landing Gear Components"
	desc = "A box full of landing gear components for a fighter"
	id = "fighter_landing_gear_components"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/twohanded/required/fighter_component/landing_gear
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_armour_plating
	name = "Fighter Armour Plating"
	desc = "Armour plating for a fighter"
	id = "fighter_armour_plating"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/silver = 5000)
	build_path = /obj/item/twohanded/required/fighter_component/armour_plating
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_fuel_tank
	name = "Fighter Fuel Tank"
	desc = "A fuel tank for a fighter"
	id = "fighter_fuel_tank"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/twohanded/required/fighter_component/fuel_tank
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_avionics_package
	name = "Fighter Avionics Package"
	desc = "An avionics package for a fighter"
	id = "fighter_avionics_package"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/gold = 1000)
	build_path = /obj/item/fighter_component/avionics
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_targeting_sensor_package
	name = "Fighter Targeting Sensor Package"
	desc = "A targeting sensor package for a fighter"
	id = "fighter_targeting_sensor_package"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/gold = 1000)
	build_path = /obj/item/fighter_component/targeting_sensor
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_fuel_lines_package
	name = "Fighter Fuel Lines Package"
	desc = "A fuel lines package for a fighter"
	id = "fighter_fuel_lines_package"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/fighter_component/fuel_lines
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_engine_components
	name = "Fighter Engine Components"
	desc = "A box of engine components for a fighter"
	id = "fighter_engine_components"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/twohanded/required/fighter_component/engine
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_primary_cannon_components
	name = "Fighter Cannon Components"
	desc = "A box of cannon components for a fighter"
	id = "fighter_primary_cannon_components"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/silver = 5000, /datum/material/glass = 2000)
	build_path = /obj/item/twohanded/required/fighter_component/primary_cannon
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

//Fighter Fuel
/datum/chemical_reaction/plasma_spiked_fuel
	name = "Plasma Spiked Fuel"
	id = /datum/reagent/plasma_spiked_fuel
	results = list(/datum/reagent/plasma_spiked_fuel = 5)
	required_reagents = list(/datum/reagent/fuel = 5, /datum/reagent/stable_plasma = 1, /datum/reagent/hydrogen = 2, /datum/reagent/oxygen = 1)
	required_temp = 333

/datum/reagent/plasma_spiked_fuel
	name = "Plasma Spiked Fuel"
	description = "High performance engine fuel, spiked with a little plasma for an extra kick."
	reagent_state = LIQUID
	color = "#170B28"
	taste_description = "oil and bitterness"

/obj/structure/reagent_dispensers/fueltank/plasma_spiked
	name = "plasma spiked fuel tank"
	desc = "A tank full of high performance engine fuel, spiked with a little plasma for an extra kick."
	icon_state = "tank_stationairy" //temp
	reagent_id = /datum/reagent/plasma_spiked_fuel
	tank_volume = 2500