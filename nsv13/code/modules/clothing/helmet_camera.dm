/obj/item/clothing/head/helmet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wallframe/camera))
		if(builtInCamera)
			to_chat(user, "<span class='warning'>[src] already has a camera.</span>")
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_HEAD)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return
		if(user.transferItemToLoc(I, src))
			builtInCamera = new /obj/machinery/camera(src)
			builtInCamera.c_tag = "Helmet Cam #[rand(0,999)]"
			builtInCamera.network = list("headcam", "ss13")
			builtInCamera.internal_light = FALSE
			QDEL_NULL(I)
			to_chat(user, "<span class='notice'>You successfully attach the camera to [src].</span>")
			return
	else if(I.tool_behaviour == TOOL_WIRECUTTER)
		if(!builtInCamera)
			to_chat(user, "<span class='warning'>[src] has no camera installed.</span>")
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_HEAD))
			to_chat(user, "<span class='warning'>You cannot remove the camera from [src] while wearing it.</span>")
			return

		new /obj/item/wallframe/camera(drop_location())
		QDEL_NULL(builtInCamera)
		to_chat(user, "<span class='notice'>You successfully remove the camera from [src].</span>")
		return
	else
		return ..()

/obj/item/clothing/head/helmet/equipped(mob/equipper, slot)
	. = ..()
	if(ishuman(equipper))
		var/mob/living/carbon/human/H = equipper

		if(slot && slot != ITEM_SLOT_HEAD)
			on_drop(equipper)
			return
		if(builtInCamera && H)
			builtInCamera.c_tag = "Helmet Cam #[rand(0,999)]"
			builtInCamera.forceMove(equipper) //I hate this. But, it's necessary.
			RegisterSignal(equipper, COMSIG_MOVABLE_MOVED, .proc/update_camera_location)

/obj/item/clothing/head/helmet/dropped(mob/user)
	. = ..()
	on_drop(user)

/obj/item/clothing/head/helmet/proc/on_drop(mob/user)
	if(!QDELETED(builtInCamera))
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		update_camera_location(get_turf(src))
		builtInCamera.forceMove(src) //Snap the camera back into us.

/obj/item/clothing/head/helmet/proc/do_camera_update(oldLoc)
	if(!QDELETED(builtInCamera) && oldLoc != get_turf(loc))
		GLOB.cameranet.updatePortableCamera(builtInCamera)
	updating = FALSE

#define SILICON_CAMERA_BUFFER 10
/obj/item/clothing/head/helmet/proc/update_camera_location(oldLoc)
	if(!oldLoc)
		oldLoc = get_turf(loc)
	if(!QDELETED(builtInCamera) && !updating)
		updating = TRUE
		addtimer(CALLBACK(src, .proc/do_camera_update, oldLoc), SILICON_CAMERA_BUFFER)
#undef SILICON_CAMERA_BUFFER
