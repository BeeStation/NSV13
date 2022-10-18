//NSV-related mech tools
/obj/item/mecha_parts/mecha_equipment/extinguisher/hull_repair_juice
	name = "exosuit hull foam dispenser"
	desc = "Equipment for engineering exosuits. Used to rapidly dispense hull foam."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	ext_chem = /datum/reagent/hull_repair_juice
	ext_tank_type = /obj/structure/reagent_dispensers/foamtank/hull_repair_juice
	ext_range = 6
	precise = TRUE
	range = MECHA_MELEE|MECHA_RANGED
