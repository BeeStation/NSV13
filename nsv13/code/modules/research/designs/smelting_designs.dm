/datum/design/nanocarbon_glass
	name = "Nanocarbon glass"
	id = "nanocarbon_glass"
	build_type = SMELTER | PROTOLATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/nanocarbon_glass
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50

/datum/design/durasteel
	name = "Durasteel alloy"
	id = "durasteel"
	build_type = SMELTER | PROTOLATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/titanium = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/durasteel
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50

/datum/design/duranium
	name = "Duranium alloy"
	id = "duranium"
	build_type = SMELTER | PROTOLATHE
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT, /datum/material/titanium = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/duranium
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50