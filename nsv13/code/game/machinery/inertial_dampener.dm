
/obj/machinery/inertial_dampener 
	name = "inertial dampener"
	icon = 'nsv13/icons/obj/machinery/inertial_dampener.dmi'
	icon_state = "machine_inactive"
	circuit = /obj/item/circuitboard/machine/inertial_dampener
	dir = 4
	use_power = IDLE_POWER_USE
	idle_power_usage = 2000
	active_power_usage = 200000
	
	var/strengthMultiplier = 0.5
	var/maxRange = 10

/obj/machinery/inertial_dampener/Initialize()
	. = ..()
	RefreshParts()
	
/obj/machinery/atmospherics/components/binary/magnetic_constrictor/update_icon()
	cut_overlays()
	if(panel_open)
		icon_state = "machine_maintenance"
	else if( use_power == ACTIVE_POWER_USE )
		icon_state = "machine_active"
	else
		icon_state = "machine_inactive"
	
/obj/machinery/atmospherics/components/binary/magnetic_constrictor/attack_hand(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, "<span class='notice'>You must turn close the panel on [src] before turning it on.</span>")
		return
	to_chat(user, "<span class='notice'>You press [src]'s power button.</span>")
	if ( use_power == IDLE_POWER_USE ) 
		use_power = ACTIVE_POWER_USE
	else 
		use_power = IDLE_POWER_USE
	update_icon()

/obj/machinery/inertial_dampener/screwdriver_act(mob/user, obj/item/tool)
	if(..())
		return TRUE
	if( use_power == ACTIVE_POWER_USE )
		to_chat(user, "<span class='notice'>You must turn off [src] before opening the panel.</span>")
		return FALSE
	panel_open = !panel_open
	tool.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You [panel_open?"open":"close"] the panel on [src].</span>")
	update_icon()
	return TRUE

/obj/machinery/inertial_dampener/crowbar_act(mob/user, obj/item/tool)
	default_deconstruction_crowbar(tool)
	return TRUE

/obj/machinery/inertial_dampener/RefreshParts()
	message_admins( english_list( component_parts ) )

/obj/machinery/inertial_dampener/proc/reduceStrength( distance, strength = 0 )
	if ( distance && ( distance < maxRange ) ) 
		return ( strength * strengthMultiplier )
	else 
		return strength 

// Techwebs 

/datum/design/board/magnetic_constrictor
	name = "Machine Design (inertial dampener board)"
	desc = "The circuit board for an inertial dampener."
	id = "area_inerts"
	build_path = /obj/item/circuitboard/machine/inertial_dampener
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/techweb_node/magnetic_constrictor
	id = "area_inerts"
	display_name = "Inertial Dampeners"
	description = "Mitigation of hull vibrations."
	prereq_ids = list("adv_engi", "adv_power")
	design_ids = list("area_inerts")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000
