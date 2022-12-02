/obj/machinery/camera/tv_camera
	name = "TV Show Camera"
	network = list("tv")
	c_tag = "TV Show"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	var/obj/item/radio/internal_radio
	var/radio_key = /obj/item/encryptionkey/tv

/obj/machinery/camera/tv_camera/Initialize(mapload)
	. = ..()
	internal_radio = new /obj/item/radio(src)
	internal_radio.keyslot = new radio_key
	internal_radio.set_frequency(FREQ_TV)
	internal_radio.canhear_range = 10
	internal_radio.broadcasting = TRUE
	internal_radio.listening = FALSE

/obj/machinery/camera/tv_camera/Destroy()
	. = ..()
	QDEL_NULL(internal_radio)


/obj/item/device/pocket_tvcamera
	name = "camera drone"
	desc = "A Ward-Takahashi EyeBuddy media streaming hovercam. Weapon of choice for war correspondents and reality show cameramen."
	icon = 'nsv13/icons/obj/television.dmi'
	worn_icon = 'nsv13/icons/obj/television_worn.dmi'
	lefthand_file = 'nsv13/icons/obj/television_left.dmi'
	righthand_file = 'nsv13/icons/obj/television_right.dmi'
	item_state = "camcorder"
	icon_state = "camcorder"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron = 200, /datum/material/glass = 50, /datum/material/gold=100, /datum/material/plastic = 800, /datum/material/bluespace = 50)
	var/obj/machinery/camera/tv_camera = null
	var/obj/item/radio/internal_radio = null
	var/radio_key = /obj/item/encryptionkey/tv
	var/updating = FALSE
	var/on = FALSE
	var/sensitivity = 3
	var/annonceReload = FALSE
	var/access_required = list(ACCESS_LIBRARY)

/obj/item/device/pocket_tvcamera/Initialize(mapload)
	. = ..()

/obj/item/device/pocket_tvcamera/examine()
	. = ..()
	. += "Drone Camera. A little drone, a little camera."
	. += "Recording indicator light [on ? "on" : "off"]"
	. += "Microphone sensitivity is set to: [sensitivity]. Ctrl + Click changes the sensitivity."
	. += "Alt + click allows you to make an announcement about the start of a broadcast."

/obj/item/device/pocket_tvcamera/Destroy()
	. = ..()
	QDEL_NULL(tv_camera)
	QDEL_NULL(internal_radio)

/obj/item/device/pocket_tvcamera/attack_self(mob/user)
	. = ..()
	if(check_id(user))
		if(!on)
			camera_on(user)
		else
			camera_off(user)
		playsound(user, on ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 40, TRUE)
	else
		to_chat(user, "<span class='warning'>You don't have access to do that.</span>")

/obj/item/device/pocket_tvcamera/proc/camera_on(mob/user)
	if(tv_camera == null)
		tv_camera = new /obj/machinery/camera(src)
		tv_camera.c_tag = "Broadcast TV Cam #[rand(0,999)]"
		tv_camera.use_power = NO_POWER_USE
		tv_camera.network = list("tv")
		tv_camera.internal_light = FALSE
		tv_camera.status = 1
		tv_camera.forceMove(user) //I hate this. But, it's necessary.
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/update_camera_location)
	else
		tv_camera.status = 1
	if(internal_radio == null)
		internal_radio = new /obj/item/radio(src)
		internal_radio.keyslot = new radio_key
		internal_radio.set_frequency(FREQ_TV)
		if (sensitivity != 0)
			internal_radio.broadcasting = TRUE
		internal_radio.listening = FALSE
	else
		internal_radio.broadcasting = TRUE
	on = TRUE
	update_icon()
	to_chat(usr, "Broadcast is on.")

/obj/item/device/pocket_tvcamera/proc/camera_off(mob/user)
	if(tv_camera != null)
		tv_camera.status = 0
	if(internal_radio != null)
		internal_radio.broadcasting = FALSE
	on = FALSE
	update_icon()
	to_chat(usr, "Broadcast is off.")

/obj/item/device/pocket_tvcamera/proc/check_id(mob/living/user)
	if(IsAdminGhost(user))
		return TRUE
	if(!access_required) // No requirements to access it.
		return TRUE

	var/obj/item/card/id/used_id = user.get_idcard(TRUE)

	if(!used_id || !used_id.access)
		return FALSE

	for(var/requested_access in access_required)
		if(requested_access in used_id.access)
			return TRUE
	return FALSE

/obj/item/device/pocket_tvcamera/CtrlClick(mob/user)
	. = ..()
	if(check_id(user))
		switch (sensitivity)
			if(0)
				sensitivity = 3
				internal_radio.canhear_range = 3
			if(3)
				sensitivity = 5
				internal_radio.canhear_range = 5
			if(5)
				sensitivity = 8
				internal_radio.canhear_range = 8
			else
				sensitivity = 0
				internal_radio.canhear_range = 0
				internal_radio.broadcasting = FALSE
		if (sensitivity != 0)
			internal_radio.broadcasting = TRUE
		to_chat(usr, "The sensitivity wheel is set to [sensitivity]")
	else
		to_chat(user, "<span class='warning'>You don't have access to do that.</span>")

/obj/item/device/pocket_tvcamera/AltClick(mob/user)
	if(check_id(user))
		if (!annonceReload)
			var/str = stripped_input(user, "Enter an announcement about the beginning of the TV show.", "Announcement", , 128)
			if(!str)
				to_chat(user, "<span class='warning'>Invalid text!</span>")
				return
			else
				for(var/obj/machinery/computer/security/telescreen/entertainment/TV in GLOB.machines)
					TV.announcement(str)
				for(var/obj/machinery/computer/security/wooden_tv/tv/TV_WOODEN in GLOB.machines)
					TV_WOODEN.announcement(str)
				to_chat(user, "Announcement successfully completed")
				annonceReload = TRUE
			addtimer(VARSET_CALLBACK(src, annonceReload, FALSE), 256 SECONDS)
		else
			to_chat(user, "<span class='warning'>You can't make announcements that often!</span>")
	else
		to_chat(user, "<span class='warning'>You don't have access to do that.</span>")

/obj/item/device/pocket_tvcamera/update_icon()
	. = ..()
	if(on)
		item_state = "camcorder_on"
		icon_state = "camcorder_on"
	else
		item_state = "camcorder"
		icon_state = "camcorder"

/obj/item/device/pocket_tvcamera/equipped(mob/equipper, slot)
	. = ..()
	if(ishuman(equipper))
		var/mob/living/carbon/human/H = equipper

		if(tv_camera && H)
			tv_camera.forceMove(equipper) //I hate this. But, it's necessary.
			RegisterSignal(equipper, COMSIG_MOVABLE_MOVED, .proc/update_camera_location)

/obj/item/device/pocket_tvcamera/dropped(mob/user)
	. = ..()
	if(!QDELETED(tv_camera))
		if(!in_inventory(user))
			UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
			update_camera_location(get_turf(src))
			if(on)
				camera_off()
				on = FALSE
				to_chat(usr, "Tracking error. The broadcast is automatically turned off.")
			tv_camera.forceMove(src) //Snap the camera back into us.

/obj/item/device/pocket_tvcamera/proc/do_camera_update(oldLoc)
	if(!QDELETED(tv_camera) && oldLoc != get_turf(loc))
		GLOB.cameranet.updatePortableCamera(tv_camera)
	updating = FALSE

#define CAMERA_BUFFER 10
/obj/item/device/pocket_tvcamera/proc/update_camera_location(oldLoc)
	if(!oldLoc)
		oldLoc = get_turf(loc)
	if(!QDELETED(tv_camera) && !updating)
		updating = TRUE
		addtimer(CALLBACK(src, .proc/do_camera_update, oldLoc), CAMERA_BUFFER)
#undef CAMERA_BUFFER

/obj/item/device/pocket_tvcamera/proc/in_inventory(mob/user)
	for(var/content in user.contents)
		if(istype(content, /obj/item/device/pocket_tvcamera))
			return TRUE
