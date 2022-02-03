
/obj/structure/overmap/space_ruin
	name = "Space Ruin"
	desc = "A space oddity. One man's trash is another man's treasure!"
	obj_integrity = 100
	max_integrity = 100
	required_tier = 1
	bound_width = 224
	bound_height = 224
	dockable_poi = TRUE
	armor = list("overmap_light" = 25, "overmap_medium" = 25, "overmap_heavy" = 25)
	overmap_deletion_traits = DELETE_UNOCCUPIED_ON_DEPARTURE | DAMAGE_DELETES_UNOCCUPIED | DAMAGE_STARTS_COUNTDOWN | FIGHTERS_ARE_OCCUPANTS
	deletion_teleports_occupants = TRUE

/obj/structure/overmap/space_ruin/station
	icon = 'nsv13/icons/overmap/neutralstation.dmi'
	desc = "A space installation in complete disrepair for one of a myriad of reasons. One man's trash is another man's treasure!"

/obj/structure/overmap/space_ruin/station/robust
	icon_state = "ruin_robust"

/obj/structure/overmap/space_ruin/station/combust
	icon_state = "ruin_combust"

/obj/structure/overmap/space_ruin/station/combust2
	icon_state = "ruin_combust2"

/obj/structure/overmap/space_ruin/choose_interior(map_path_override)
	message_admins( "choose_interior" )
	message_admins( "length: [length( subtypesof( /datum/map_template/ruin/space ) )] " )
	if(map_path_override)
		boarding_interior = new/datum/map_template(map_path_override)
	else
		var/list/picked_ruin = pick( subtypesof( /datum/map_template/ruin/space ) )
		message_admins( picked_ruin )
		boarding_interior = new picked_ruin
