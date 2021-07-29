
/obj/machinery/inertial_dampener 
	name = "inertial dampener"
	icon = 'nsv13/icons/obj/machinery/inertial_dampener.dmi'
	icon_state = "machine_inactive"
	desc = "This machine generates waves with equal amplitude and inverted phase to reduce hull vibrations"
	circuit = /obj/item/circuitboard/machine/inertial_dampener
	density = 1
	dir = 4
	use_power = NO_POWER_USE
	var/on = FALSE
	var/power_input = 100000
	var/radiationAmountOnProcess = 16
	var/obj/structure/cable/C = null
	var/emagged = FALSE
	
	var/strengthMultiplier = 1
	var/maxRange = 10

/obj/machinery/inertial_dampener/Initialize()
	. = ..()
	RefreshParts()
	
/obj/machinery/inertial_dampener/proc/try_use_power()
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if ( C?.surplus() > power_input )
		C.powernet.load += power_input
		return TRUE
	return FALSE

/obj/machinery/inertial_dampener/process()
	if ( on )
		if( power_input > 0 && try_use_power() )
			radiation_pulse( src, radiationAmountOnProcess ) // Let's turn one form of energy into another form of energy. Using science! 
		else 
			on = FALSE
			update_icon()

/obj/machinery/inertial_dampener/update_icon()
	cut_overlays()
	if(panel_open)
		icon_state = "machine_maintenance"
	else if( on )
		icon_state = "machine_active"
	else
		icon_state = "machine_inactive"

/obj/machinery/inertial_dampener/examine(mob/user)
	. = ..()
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if ( C?.surplus() > power_input )
		. += "<span class='notice'>Its LED display states: [power_input / 1000]kW</span>"
	else 
		. += "<span class='warning'>Its LED display flashes: [power_input / 1000]kW</span>"
	
/obj/machinery/inertial_dampener/attack_hand(mob/user)
	. = ..()
	if( panel_open )
		to_chat(user, "<span class='notice'>You must close the panel on [src] before turning it on.</span>")
		return
	to_chat(user, "<span class='notice'>You press [src]'s power button.</span>")
	toggle_machine()
		
/obj/machinery/inertial_dampener/attack_ai(mob/user)
	. = ..()
	if( panel_open )
		return
	to_chat(user, "<span class='notice'>You remotely activate [src].</span>")
	toggle_machine()

/obj/machinery/inertial_dampener/attack_robot(mob/user)
	. = ..()
	if( panel_open )
		return
	to_chat(user, "<span class='notice'>You remotely activate [src].</span>")
	toggle_machine()

/obj/machinery/inertial_dampener/emag_act(mob/user)
	if ( !emagged )
		log_game("[key_name(user)] emagged [src].")
		// Emagging amplifies vibrations instead of reducing them!
		to_chat(user, "<span class='warning'>[src] inverts its manipulators, producing sparks!</span>")
		playsound(src.loc, "sparks", 50, 1)
		do_sparks(4, FALSE, src)
		emagged = TRUE
		recalculatePartEfficiency()

/obj/machinery/inertial_dampener/proc/toggle_machine()
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if ( on || C?.surplus() > power_input )
		on = !on
		update_icon()

/obj/machinery/inertial_dampener/screwdriver_act(mob/user, obj/item/tool)
	if(..())
		return TRUE
	if( on )
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
	if ( on ) 
		toggle_machine()
	recalculatePartEfficiency()

/obj/machinery/inertial_dampener/proc/recalculatePartEfficiency()
	strengthMultiplier = 1
	maxRange = 0

	var/totalManipulatorRating = 0
	for ( var/obj/item/stock_parts/manipulator/M in component_parts ) 
		totalManipulatorRating += M.rating
	// strengthMultiplier = ( ( 6 * 0.9 ) / totalManipulatorRating )
	strengthMultiplier = ( -0.041 * ( totalManipulatorRating - 6 ) + 0.749 )

	var/totalScannerRating
	for ( var/obj/item/stock_parts/scanning_module/S in component_parts ) 
		totalScannerRating += S.rating
	maxRange = ( 2.5 * ( totalScannerRating ) )

	update_power_usage()

	if ( emagged )
		strengthMultiplier = strengthMultiplier ** -1

/obj/machinery/inertial_dampener/proc/update_power_usage()
	power_input = 0

	var/capacitorRating = 0
	for ( var/obj/item/stock_parts/capacitor/C in component_parts ) 
		capacitorRating += C.rating 
	if ( capacitorRating > 0 )
		// Increasing dampening strength or affected range will consume more power. 
		// Install better capacitors to compensate  
		power_input = round( ( strengthMultiplier ** -1 ) * ( ( maxRange ** 2 ) / 2 ) * ( 4000 * ( 1 / capacitorRating ) ) )
		
		if ( power_input < 0 ) // Negative strength multiplier will produce a negative power input, but I'm lazy 
			power_input = INFINITY

/obj/machinery/inertial_dampener/proc/reduceStrength( distance, strength = 0 )
	if ( emagged )
		playsound(src.loc, "sparks", 50, 1)
		do_sparks(1, FALSE, src)

	if ( distance && ( distance < maxRange ) )
		var/result = ( strength * strengthMultiplier )
		
		if ( strengthMultiplier > 0.6 ) 
			result = ( result * ( rand( 8, 12 ) / 10 ) ) // Poor component rating, produce a small deviation from the expected mitigated result 

		if ( result < 0 ) 
			return 0
		else
			return result // Return the calculated strength reduction 
	else
		return strength 

/obj/machinery/inertial_dampener/proc/reduceNausea( distance, strength = 0 ) 
	// Special proc that might handle nausea differently in the future. For now it's just a wrapper 
	return reduceStrength( distance, strength )

// Techwebs 

/datum/design/board/inertial_dampener
	name = "Machine Design (Inertial Dampener Board)"
	desc = "The circuit board for an inertial dampener."
	id = "area_inerts"
	build_path = /obj/item/circuitboard/machine/inertial_dampener
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/inertial_dampener
	id = "area_inerts"
	display_name = "Inertial Dampeners"
	description = "Anti-shake technology for hull vibrations."
	prereq_ids = list("practical_bluespace","high_efficiency", "adv_power")
	design_ids = list("area_inerts")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000
