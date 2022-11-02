#define EfficiencyToStrength(part_efficiency) (-0.041 * ((part_efficiency) - 6 ) + 0.749)
#define StrengthToEfficiency(strength) ((((strength) - 0.749) / -0.041) + 6)
#define EfficiencyToRange(part_efficiency) (2.5 * (part_efficiency))
#define RangeToEfficiency(range) ((range) / 2.5)

GLOBAL_LIST_EMPTY(inertia_dampeners)

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
	///Maximum total component rating for the manipulators
	var/max_manipulator_rating = 6
	///Minimum total component rating for the manipulators if the component rating is 1 (<-basic T1)
	var/min_manipulator_rating = 6
	///Maximum total component rating for the scanners
	var/max_scanner_rating = 2
	///Minimum total component rating for the scanners if the component rating is 1 (<-basic T1)
	var/min_scanner_rating = 2
	///A setting to pretend the total componing rating of all manipulators
	var/manipulator_setting = 6
	///A setting to pretend the total componing rating of all scanners
	var/scanner_setting = 2

	var/strengthMultiplier = 1
	var/maxRange = 10

/obj/machinery/inertial_dampener/Initialize(mapload)
	. = ..()
	GLOB.inertia_dampeners += src
	RefreshParts()

/obj/machinery/inertial_dampener/Destroy()
	GLOB.inertia_dampeners -= src
	return ..()

/obj/machinery/inertial_dampener/proc/try_use_power()
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if(C?.surplus() > power_input)
		C.powernet.load += power_input
		return TRUE
	return FALSE

/obj/machinery/inertial_dampener/process()
	if(on)
		if(power_input > 0 && try_use_power())
			radiation_pulse( src, radiationAmountOnProcess ) // Let's turn one form of energy into another form of energy. Using science!
		else
			on = FALSE
			update_visuals()

/obj/machinery/inertial_dampener/proc/update_visuals()
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
		. += "<span class='notice'>Its LED display states: [display_power(power_input)]</span>"
	else
		. += "<span class='warning'>Its LED display flashes: [display_power(power_input)]</span>"

/obj/machinery/inertial_dampener/emag_act(mob/user)
	if ( !emagged )
		log_game("[key_name(user)] emagged [src].")
		// Emagging amplifies vibrations instead of reducing them!
		to_chat(user, "<span class='warning'>[src] inverts its manipulators, producing sparks!</span>")
		playsound(src.loc, "sparks", 50, 1)
		do_sparks(4, FALSE, src)
		emagged = TRUE
		recalculatePartEfficiency()

/obj/machinery/inertial_dampener/ui_data(mob/user)
	var/list/data = list()
	data["max_strength"] = (1 - EfficiencyToStrength(max_manipulator_rating)) * 100
	data["min_strength"] = (1 - EfficiencyToStrength(min_manipulator_rating)) * 100
	data["strength"] = (1 - EfficiencyToStrength(manipulator_setting)) * 100
	data["max_range"] = EfficiencyToRange(max_scanner_rating)
	data["min_range"] = EfficiencyToRange(min_scanner_rating)
	data["range"] = EfficiencyToRange(scanner_setting)
	data["power_usage"] = display_power(power_input)
	data["on"] = on
	return data


/obj/machinery/inertial_dampener/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(panel_open)
		return TRUE
	switch(action)
		if("strength")
			manipulator_setting = clamp(StrengthToEfficiency(1 - (params["value"] / 100)), min_manipulator_rating, max_manipulator_rating)
			RefreshParts()
			return TRUE
		if("range")
			scanner_setting = clamp(RangeToEfficiency(params["value"]), min_scanner_rating, max_scanner_rating)
			RefreshParts()
			return TRUE
		if("toggle_on")
			toggle_machine()
			return TRUE
	return FALSE

/obj/machinery/inertial_dampener/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InertialDampener")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/emergency_shuttle/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/inertial_dampener/proc/toggle_machine()
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if ( on || C?.surplus() > power_input )
		on = !on
		update_visuals()

/obj/machinery/inertial_dampener/screwdriver_act(mob/user, obj/item/tool)
	if(..())
		return TRUE
	if( on )
		to_chat(user, "<span class='notice'>You must turn off [src] before opening the panel.</span>")
		return FALSE
	panel_open = !panel_open
	tool.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You [panel_open?"open":"close"] the panel on [src].</span>")
	update_visuals()
	return TRUE

/obj/machinery/inertial_dampener/crowbar_act(mob/user, obj/item/tool)
	default_deconstruction_crowbar(tool)
	return TRUE

/obj/machinery/inertial_dampener/RefreshParts()
	if ( on )
		toggle_machine()

	max_manipulator_rating = 0
	min_manipulator_rating = 0
	for ( var/obj/item/stock_parts/manipulator/M in component_parts )
		max_manipulator_rating += M.rating
		min_manipulator_rating++
	manipulator_setting = clamp(manipulator_setting, 1, max_manipulator_rating)

	max_scanner_rating = 0
	min_scanner_rating = 0
	for ( var/obj/item/stock_parts/scanning_module/S in component_parts )
		max_scanner_rating += S.rating
		min_scanner_rating++
	scanner_setting = clamp(scanner_setting, 1, max_scanner_rating)

	recalculatePartEfficiency()

/obj/machinery/inertial_dampener/proc/recalculatePartEfficiency()

	strengthMultiplier = EfficiencyToStrength(manipulator_setting)
	maxRange = EfficiencyToRange(scanner_setting)

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

#undef EfficiencyToStrength
#undef StrengthToEfficiency
#undef EfficiencyToRange
#undef RangeToEfficiency
