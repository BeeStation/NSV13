
/obj/machinery/inertial_dampener 
	name = "inertial dampener"
	icon = 'nsv13/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "constrictor"
	dir = 4
	
	var/strengthMultiplier = 0.5
	var/maxRange = 10

/obj/machinery/inertial_dampener/Initialize()
	. = ..()
	RefreshParts()

/obj/machinery/inertial_dampener/screwdriver_act(mob/user, obj/item/tool)
	var/icon_state_open = "constrictor_screw"
	var/icon_state_closed = initial(icon_state)
	. = default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, tool)

/obj/machinery/inertial_dampener/crowbar_act(mob/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/inertial_dampener/RefreshParts()
	message_admins( english_list( component_parts ) )

/obj/machinery/inertial_dampener/proc/reduceStrength( distance, strength = 0 )
	if ( distance && ( distance < maxRange ) ) 
		return ( strength * strengthMultiplier )
	else 
		return strength 
