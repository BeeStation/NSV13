///Ore filtration mesh, to be put inside of ore filters to filter out ores at specific efficiencies.
/obj/item/ore_filtration_mesh
	name = "generic ore filtration mesh"
	desc = "used in ore filters to filter impurities from rocks and leave only useful materials behind"
	icon = 'icons/obj/ore_filters.dmi'
	icon_state = "basic_filter"
	var/list/filtration_efficiencies = list(MAT_CATEGORY_SEDIMENT = 0.15, MAT_CATEGORY_COMMON = 1, MAT_CATEGORY_UNCOMMON = 1, MAT_CATEGORY_RARE = 1, MAT_CATEGORY_PLASMA = 1)


/obj/item/ore_filtration_mesh/examine(mob/user)
	. = ..()
	var/efficiency_message = ""
	for(var/i in filtration_efficiencies)
		if(i == MAT_CATEGORY_SEDIMENT) //literaly noone cares about sand libtard
			continue
		efficiency_message += "[i]: [filtration_efficiencies[i] * 100]% "
	. += "<span class='notice'>It seems to have the following filtration qualities: [efficiency_message]</span>"

/obj/item/ore_filtration_mesh/uncommon
	name = "uncommon ore filtration mesh"
	icon_state = "basic_filter"
	filtration_efficiencies = list(MAT_CATEGORY_SEDIMENT = 0.15, MAT_CATEGORY_COMMON = 0.5, MAT_CATEGORY_UNCOMMON = 1.5, MAT_CATEGORY_RARE = 1, MAT_CATEGORY_PLASMA = 1)	