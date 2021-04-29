/////////////////////////////////////////
//////////NSV13 Borg Upgrades////////////
/////////////////////////////////////////

/datum/design/borg_upgrade_expwelder
	name = "Cyborg Upgrade (Experimental Welder)"
	id = "borg_upgrade_exwelder"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/exp_welder
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/plasma = 1500, /datum/material/uranium = 200)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/////////////////////////////////////////
//////////Mech Designs///////////////////
/////////////////////////////////////////

/datum/design/mech_foam_extinguisher
	name = "Exosuit Engineering Equipment (Hull Foam Dispenser)"
	id = "mech_foam_extinguisher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/extinguisher/hull_repair_juice
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")
