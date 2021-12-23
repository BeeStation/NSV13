
/datum/design/deepcore1
	name = "Polytrinic non magnetic asteroid arrestor upgrade"
	desc = "An upgrade module for the mining ship's asteroid arrestor, allowing it to lock on to asteroids containing valuable non ferrous metals such as gold, silver, copper and plasma"
	id = "deepcore1"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000,/datum/material/titanium = 25000, /datum/material/silver = 5000)
	build_path = /obj/item/deepcore_upgrade
	category = list("Asteroid Mining")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/deepcore2
	name = "Phasic asteroid arrestor upgrade"
	desc = "An upgrade module for the mining ship's asteroid arrestor, allowing it to lock on to asteroids containing rare and valuable minerals such as diamond, uranium and the exceedingly rare bluespace crystals."
	id = "deepcore2"
	build_type = PROTOLATHE
	materials = list(/datum/material/copper = 25000,/datum/material/titanium = 25000, /datum/material/gold = 10000, /datum/material/silver = 10000, /datum/material/plasma = 10000, /datum/material/uranium = 5000, /datum/material/diamond = 5000)
	build_path = /obj/item/deepcore_upgrade/max
	category = list("Asteroid Mining")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/asteroidscanner
	name = "Tier II asteroid sensor module"
	desc = "An upgrade for dradis computers, allowing them to scan for asteroids containing valuable non ferrous metals such as gold, silver, copper and plasma"
	id = "asteroidscanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000,/datum/material/titanium = 5000, /datum/material/silver = 2000)
	build_path = /obj/item/mining_sensor_upgrade
	category = list("Asteroid Mining")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/asteroidscanner2
	name = "Tier III asteroid sensor module"
	desc = "An upgrade for dradis computers, allowing them to scan for asteroids containing rare and valuable minerals such as diamond, uranium and the exceedingly rare bluespace crystals."
	id = "asteroidscanner2"
	build_type = PROTOLATHE
	materials = list(/datum/material/copper = 25000,/datum/material/titanium = 25000, /datum/material/plasma = 2000, /datum/material/uranium = 2000, /datum/material/diamond = 2000)
	build_path = /obj/item/mining_sensor_upgrade/max
	category = list("Asteroid Mining")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE
