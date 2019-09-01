///Filters rocks to turn them into ore at a specific efficiency
/obj/machinery/mineral/ore_filter
	name = "ore filter"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = TRUE
	input_dir = SOUTH
	output_dir = NORTH
	var/obj/item/ore_filtration_mesh/ore_filtration_mesh

///Adds the material container to the filter
/obj/machinery/mineral/ore_filter/Initialize(mapload)
	. = ..()
	var/list/material_type_list = list()
	for(var/i in SSmaterials.materials_by_category[MAT_CATEGORY_ORE])
		var/datum/material/M = i
		material_type_list += M.type
	AddComponent(/datum/component/material_container, material_type_list, 2000000, TRUE, /obj/item/rock)

///Takes any of the rocks at the input into the machine
/obj/machinery/mineral/ore_filter/process()
	var/atom/input = get_step(src, input_dir)

	for(var/obj/item/rock/R in input)
		process_rock(R)
	
	output_ores()

/obj/machinery/mineral/ore_filter/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/ore_filtration_mesh))
		return ..()
	if(ore_filtration_mesh)
		to_chat(user, "<span class='notice'>There is already a filtration mesh inside of [src].</span>")
		return
	to_chat(user, "<span class='notice'>You install [I] into [src].</span>")
	ore_filtration_mesh = I
	ore_filtration_mesh.forceMove(src)
	
/obj/machinery/mineral/ore_filter/attack_hand(mob/living/user)
	if(ore_filtration_mesh)
		to_chat(user, "<span class='notice'>You take [ore_filtration_mesh] out of [src]</span>")
		user.put_in_hands(ore_filtration_mesh)
		ore_filtration_mesh = null
	else
		return ..()

///Filters all the rocks inside of the machine
/obj/machinery/mineral/ore_filter/proc/output_ores()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/i in materials.materials)
		var/datum/material/mat = i
		var/sheets_to_remove = (materials.materials[mat] >= (MINERAL_MATERIAL_AMOUNT * 2) ) ? 2 : round(materials.materials[mat] /  MINERAL_MATERIAL_AMOUNT)
		var/out = get_step(src, output_dir)
		materials.retrieve_ores(sheets_to_remove, mat, out)

///Process the rock and turn it into materials
/obj/machinery/mineral/ore_filter/proc/process_rock(obj/item/rock/R)
	if(!ore_filtration_mesh)
		return
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	R.forceMove(src) //boulder vore time
	R.materials = get_filtered_materials(R)
	materials.insert_item(R)
	qdel(R)

///Goes through all the materials in a rock and returns a dictionary of the materials left post filtration.
/obj/machinery/mineral/ore_filter/proc/get_filtered_materials(obj/item/rock/R)
	var/list/filtered_materials = list()
	for(var/i in R.custom_materials)
		var/datum/material/M = i
		var/material_amount = R.custom_materials[i]
		for(var/rarity in ore_filtration_mesh.filtration_efficiencies) //Loop through all rarities in the efficiencies list until we hit the right one, then break.
			if(!M.categories[rarity])
				continue
			material_amount *= ore_filtration_mesh.filtration_efficiencies[rarity]
			break
		filtered_materials[M] += material_amount 
	return filtered_materials





