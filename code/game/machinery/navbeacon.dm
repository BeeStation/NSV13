// Navigation beacon for AI robots
// No longer exists on the radio controller, it is managed by a global list.

/obj/machinery/navbeacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0" //NSV13 - Navbeacon Refactor
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	level = 1		// underfloor
	layer = UNDER_CATWALK
	max_integrity = 500
	armor = list("melee" = 70, "bullet" = 70, "laser" = 70, "energy" = 70, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "stamina" = 0)

	//NSV13 - Start
	circuit = /obj/item/circuitboard/machine/navbeacon
	/// true if controls are locked
	var/controls_locked = TRUE
	/// true if cover is locked
	var/cover_locked = TRUE
	/// location response text
	var/location = ""
	/// original location name, to allow resets
	var/original_location = ""
	/// associative list of transponder codes
	var/list/codes
	/// codes as set on map: "tag1;tag2" or "tag1=value;tag2=value"
	var/codes_txt = ""
	var/obj/structure/overmap/linked //NSV13 - DIFFERENCE BETWEEN CODEBASE
	//NSV13 - Stop

	req_one_access = list(ACCESS_ENGINE, ACCESS_ROBOTICS)

/obj/machinery/navbeacon/Initialize(mapload)
	. = ..()

	original_location = location //NSV13 - Navbeacon Refactor
	set_codes()

	var/turf/T = loc
	hide(T.intact)
	//NSV13 - Start - Navbeacon Refactor
	glob_lists_register(init=TRUE)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/navbeacon/LateInitialize()
	has_overmap()

/obj/machinery/navbeacon/proc/has_overmap()
	linked = get_overmap()
	if(linked)
		set_position(linked)
	return linked

/obj/machinery/navbeacon/proc/set_position(obj/structure/overmap/OM)
	OM.beacons_in_ship += src
	return

/obj/machinery/navbeacon/Destroy()
	if (linked.beacons_in_ship)
		linked.beacons_in_ship -= src
	glob_lists_deregister()
	//NSV13 - Navbeacon Refactor - Stop
	return ..()

/obj/machinery/navbeacon/onTransitZ(old_z, new_z)
	if (GLOB.navbeacons["[old_z]"])
		GLOB.navbeacons["[old_z]"] -= src
	if (GLOB.navbeacons["[new_z]"])
		GLOB.navbeacons["[new_z]"] += src
	..()

//NSV13 - Navbeacon Refactor - Start
/obj/machinery/navbeacon/on_construction(mob/user)
	var/turf/our_turf = loc
	if(!isfloorturf(our_turf))
		return
	var/turf/open/floor/floor = our_turf
	floor.remove_tile(null, silent = TRUE, make_tile = TRUE)


///Set the transponder codes assoc list from codes_txt during initialization, or during reset
/obj/machinery/navbeacon/proc/set_codes()
	codes = list()
	if(!codes_txt)
		return

	var/list/entries = splittext(codes_txt, ";") // entries are separated by semicolons

	for(var/entry in entries)
		var/index = findtext(entry, "=") // format is "key=value"
		if(index)
			var/key = copytext(entry, 1, index)
			var/val = copytext(entry, index + length(entry[index]))
			codes[key] = val
		else
			codes[entry] = "[TRUE]"

//NSV13 - Navbeacon Refactor - Start
///Removes the nav beacon from the global beacon lists
/obj/machinery/navbeacon/proc/glob_lists_deregister()
	if (GLOB.navbeacons["[z]"])
		GLOB.navbeacons["[z]"] -= src //Remove from beacon list, if in one.
	GLOB.deliverybeacons -= src
	GLOB.deliverybeacontags -= location

///Registers the navbeacon to the global beacon lists
/obj/machinery/navbeacon/proc/glob_lists_register(var/init=FALSE)
	if(!init)
		glob_lists_deregister()
	if(codes?[NAVBEACON_PATROL_MODE])
		if(!GLOB.navbeacons["[z]"])
			GLOB.navbeacons["[z]"] = list()
		GLOB.navbeacons["[z]"] += src //Register with the patrol list!
	if(codes?[NAVBEACON_DELIVERY_MODE])
		GLOB.deliverybeacons += src
		GLOB.deliverybeacontags += location

/obj/machinery/navbeacon/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/navbeacon/screwdriver_act(mob/living/user, obj/item/tool)
	if(!panel_open && cover_locked)
		balloon_alert(user, "hatch locked!")
		return TRUE
	return default_deconstruction_screwdriver(user, "navbeacon1","navbeacon0",tool)

/obj/machinery/navbeacon/attackby(obj/item/attacking_item, mob/user, params)
	var/turf/our_turf = loc
	if(our_turf.intact)
		return // prevent intraction when T-scanner revealed

	if(attacking_item.GetID())
		if(!panel_open)
			if (allowed(user))
				controls_locked = !controls_locked
				balloon_alert(user, "controls [controls_locked ? "locked" : "unlocked"]")
				SStgui.update_uis(src)
			else
				balloon_alert(user, "access denied")
		else
			balloon_alert(user, "panel open!")
		return

	return ..()
//NSV13 - Navbeacon Refactor - Stop

// called when turf state changes
// hide the object if turf is intact
/obj/machinery/navbeacon/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon()


/obj/machinery/navbeacon/attack_ai(mob/user)
	interact(user) //NSV13 - Navbeacon Refactor

/obj/machinery/navbeacon/attack_paw()
	return

//NSV13 - Navbeacon Refactor - Start
/obj/machinery/navbeacon/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	var/turf/our_turf = loc
	if(our_turf.intact)
		return // prevent intraction when T-scanner revealed

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NavBeacon")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/navbeacon/ui_data(mob/user)
	var/list/data = list()
	var/list/controls = list()

	controls["location"] = location
	controls["patrol_enabled"] = codes[NAVBEACON_PATROL_MODE] ? TRUE : FALSE
	controls["patrol_next"] = codes[NAVBEACON_PATROL_NEXT]
	controls["delivery_enabled"] = codes[NAVBEACON_DELIVERY_MODE] ? TRUE : FALSE
	controls["delivery_direction"] = dir2text(text2num(codes[NAVBEACON_DELIVERY_DIRECTION]))
	controls["cover_locked"] = cover_locked

	data["locked"] = controls_locked
	data["siliconUser"] = issilicon(user)
	data["controls"] = controls

	return data

/obj/machinery/navbeacon/ui_static_data(mob/user)
	var/list/data = list()
	var/list/static_controls = list()
	var/static/list/direction_options = list("none", dir2text(EAST), dir2text(NORTH), dir2text(SOUTH), dir2text(WEST))

	static_controls["direction_options"] = direction_options
	static_controls["has_codes"] = codes_txt ? TRUE : FALSE

	data["static_controls"] = static_controls
	return data

/obj/machinery/navbeacon/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "lock" && allowed(usr))
		controls_locked = !controls_locked
		return TRUE

	if(controls_locked && !issilicon(usr))
		return

	switch(action)
		if("reset_codes")
			glob_lists_deregister()
			location = original_location
			set_codes()
			glob_lists_register() //NSV13 - Navbeacon Refactor
			return TRUE
		if("toggle_cover")
			cover_locked = !cover_locked
			return TRUE
		if("toggle_patrol")
			toggle_code(NAVBEACON_PATROL_MODE)
			return TRUE
		if("toggle_delivery")
			toggle_code(NAVBEACON_DELIVERY_MODE)
			return TRUE
		if("set_location")
			var/input_text = tgui_input_text(usr, "Enter the beacon's location tag", "Beacon Location", location, 20)
			if (!input_text || location == input_text)
				return
			glob_lists_deregister()
			location = input_text
			glob_lists_register() //NSV13 - Navbeacon Refactor
			return TRUE
		if("set_patrol_next")
			var/next_patrol = codes[NAVBEACON_PATROL_NEXT]
			var/input_text = tgui_input_text(usr, "Enter the tag of the next patrol location", "Beacon Location", next_patrol, 20)
			if (!input_text || location == input_text)
				return
			codes[NAVBEACON_PATROL_NEXT] = input_text
			return TRUE
		if("set_delivery_direction")
			codes[NAVBEACON_DELIVERY_DIRECTION] = "[text2dir(params["direction"])]"
			return TRUE

///Adds or removes a specific code
/obj/machinery/navbeacon/proc/toggle_code(code)
	if(codes[code])
		codes.Remove(code)
	else
		codes[code]="[TRUE]"
	glob_lists_register()
//NSV13 - Navbeacon Refactor - Stop

