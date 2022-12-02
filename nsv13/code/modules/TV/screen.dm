/obj/machinery/computer/security/telescreen/entertainment
	name = "TV monitor"
	desc = "Humans call it a zombie screen. Sometimes they show Japanese cartoons on it"
	icon = 'nsv13/icons/obj/television.dmi'
	icon_state = "entertainment"
	network = list("tv","thunder")
	var/obj/item/radio/internal_radio
	var/radio_key = /obj/item/encryptionkey/tv
	var/sound = TRUE

/obj/machinery/computer/security/telescreen/entertainment/Initialize(mapload)
	. = ..()
	internal_radio = new /obj/item/radio(src)
	internal_radio.keyslot = new radio_key
	internal_radio.set_frequency(FREQ_TV)

/obj/machinery/computer/security/telescreen/entertainment/examine()
	. = ..()
	. += "Ctrl + click toggles the sound. Sound indicator lights [sound ? "green" : "red"]"

/obj/machinery/computer/security/telescreen/entertainment/CtrlClick(mob/user)
	. = ..()
	sound = !sound
	internal_radio.set_frequency(FREQ_TV)
	to_chat(user, "You have turned [sound ? "on" : "off"] the sound")

/obj/machinery/computer/security/telescreen/entertainment/proc/announcement(var/message)
	say(message)
	icon_state = "entertainment_on"
	addtimer(VARSET_CALLBACK(src, icon_state, "entertainment"), 15 SECONDS)

/obj/machinery/computer/security/telescreen/entertainment/Destroy()
	. = ..()
	QDEL_NULL(internal_radio)

/obj/machinery/computer/security/wooden_tv/tv
	name = "Old TV Monitor"
	desc = "Humans call it a zombie screen. Sometimes they show Japanese cartoons on it"
	circuit = /obj/item/circuitboard/computer/wooden_tv
	network = list("tv","thunder")
	var/obj/item/radio/internal_radio
	var/radio_key = /obj/item/encryptionkey/tv
	var/sound = TRUE

/obj/machinery/computer/security/wooden_tv/tv/Initialize(mapload)
	. = ..()
	internal_radio = new /obj/item/radio(src)
	internal_radio.keyslot = new radio_key
	internal_radio.set_frequency(FREQ_TV)

/obj/machinery/computer/security/wooden_tv/tv/examine()
	. = ..()
	. += "Ctrl + click toggles the sound. Sound indicator lights [sound ? "green" : "red"]"

/obj/machinery/computer/security/wooden_tv/tv/CtrlClick(mob/user)
	. = ..()
	sound = !sound
	internal_radio.set_frequency(FREQ_TV)
	to_chat(user, "You have turned [sound ? "on" : "off"] the sound")

/obj/machinery/computer/security/wooden_tv/tv/proc/announcement(var/message)
	say(message)

/obj/machinery/computer/security/wooden_tv/tv/Destroy()
	. = ..()
	QDEL_NULL(internal_radio)

/obj/item/pocket_tv
	name = "Pocket TV monitor"
	desc = "A version of TV that you can put in your pocket. Wait, Nanotrazen made TVs out of our old PDAs!?"
	icon = 'nsv13/icons/obj/television.dmi'
	icon_state = "pda"
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron = 200, /datum/material/glass = 50)
	var/obj/item/radio/internal_radio
	var/radio_key = /obj/item/encryptionkey/tv
	var/sound = TRUE
	var/list/network = list("tv","thunder")
	var/obj/machinery/camera/active_camera
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	var/list/concurrent_users = list()

	// Stuff needed to render the map
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/list/cam_plane_masters
	var/atom/movable/screen/background/cam_background

/obj/item/pocket_tv/Initialize(mapload)
	. = ..()
	internal_radio = new /obj/item/radio(src)
	internal_radio.keyslot = new radio_key
	internal_radio.set_frequency(FREQ_TV)
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
	map_name = "camera_console_[REF(src)]_map"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += lowertext(i)
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/camera_static)
		var/atom/movable/screen/plane_master/instance = new plane()
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/obj/item/pocket_tv/examine()
	. = ..()
	. += "Ctrl + click toggles the sound. Sound indicator lights [sound ? "green" : "red"]"

/obj/item/pocket_tv/proc/announcement(var/message)
	say(message)

/obj/item/pocket_tv/CtrlClick(mob/user)
	. = ..()
	sound = !sound
	internal_radio.set_frequency(FREQ_TV)
	to_chat(user, "You have turned [sound ? "on" : "off"] the sound")

/obj/item/pocket_tv/Destroy()
	. = ..()
	QDEL_NULL(internal_radio)
	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(cam_background)

/obj/item/pocket_tv/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)

	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	if(!ui)
		var/user_ref = REF(user)
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			concurrent_users += user_ref
		// Turn on the console
		if(length(concurrent_users) == 1 && is_living)
			playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
		// Register map objects
		user.client.register_map_obj(cam_screen)
		for(var/plane in cam_plane_masters)
			user.client.register_map_obj(plane)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "CameraConsole", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/item/pocket_tv/ui_status(mob/user)
	. = ..()
	if(. == UI_DISABLED)
		return UI_CLOSE
	return .

/obj/item/pocket_tv/ui_data()
	var/list/data = list()
	data["network"] = network
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	return data

/obj/item/pocket_tv/ui_static_data()
	var/list/data = list()
	data["mapRef"] = map_name
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
		))

	return data

/obj/item/pocket_tv/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/c_tag = format_text(params["name"])
		var/list/cameras = get_available_cameras()
		var/obj/machinery/camera/selected_camera = cameras[c_tag]
		active_camera = selected_camera
		playsound(src, get_sfx("terminal_type"), 25, FALSE)

		if(!selected_camera)
			return TRUE

		update_active_camera_screen()

		return TRUE

/obj/item/pocket_tv/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// Is this camera located in or attached to a living thing? If so, assume the camera's loc is the living thing.
	var/cam_location = isliving(active_camera.loc) ? active_camera.loc : active_camera

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	var/newturf = get_turf(cam_location)
	if(last_camera_turf == newturf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = get_turf(cam_location)

	var/list/visible_things = active_camera.isXRay() ? range(active_camera.view_range, cam_location) : view(active_camera.view_range, cam_location)

	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/item/pocket_tv/ui_close(mob/user)
	. = ..()
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	user.client.clear_map(map_name)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		active_camera = null
		playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)

/obj/item/pocket_tv/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, 15, 15)

// Returns the list of cameras accessible from this computer
/obj/item/pocket_tv/proc/get_available_cameras()
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if((is_away_level(z) || is_away_level(C.z)) && (C.z != z))//if on away mission, can only receive feed from same z_level cameras
			continue
		L.Add(C)
	var/list/D = list()
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			D["[C.c_tag]"] = C
	return D
