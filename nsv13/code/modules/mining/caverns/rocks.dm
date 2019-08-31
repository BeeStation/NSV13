/obj/structure/boulder
	name = "boulder"
	desc = "The pioneers used to ride these babies for miles"
	icon = 'icons/obj/rocks.dmi'
	icon_state = "boulder1"
	density = TRUE
	material_flags = MATERIAL_NO_DESC | MATERIAL_NO_COLOR

/// Set the properties of the rock with the right efficiency
/obj/structure/boulder/Initialize(mapload)
	. = ..()
	icon_state = "boulder[rand(1,4)]"

///On destroy, create 5 rocks. Base efficiency of this leaves 0.1 of the resources
/obj/structure/boulder/Destroy(force, var/efficiency = 0.1)
	drop_rocks(efficiency)
	. = ..()

/obj/structure/boulder/proc/drop_rocks(var/efficiency = 0.1)
	if(efficiency <= 0) //Dont bother with too low efficiency
		return
	var/list/rocks = list()

	var/temp_mat_list = list()
	for(var/i in custom_materials)
		temp_mat_list[i] = custom_materials[i] * efficiency / 5

	for(var/i in 1 to ROCK_COUNT_BOULDER)
		var/obj/item/rock/R = new(loc)
		R.set_custom_materials(temp_mat_list)
		rocks += R

	return rocks
	
/obj/item/rock
	name = "ore rock"
	desc = "a rock filled with all types of materials"
	icon = 'icons/obj/rocks.dmi'
	icon_state = "rock"
	material_flags = MATERIAL_NO_DESC | MATERIAL_NO_COLOR
	can_recycle = FALSE
	var/used_processors = NONE
	var/washed = FALSE //Have we gone through a cleaner? 
