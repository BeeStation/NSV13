/obj/item/clothing/head/helmet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wallframe/camera))
		if(builtInCamera)
			to_chat(user, "<span class='warning'>[src] already has a camera.</span>")
			return FALSE
		if(src == user.get_item_by_slot(ITEM_SLOT_HEAD)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return FALSE
		if(do_after(user, 5, target = src))
			install_camera(I, src)
			to_chat(user, "<span class='notice'>You successfully attach the camera to [src].</span>")
			return TRUE
	else if(I.tool_behaviour == TOOL_WIRECUTTER)
		if(!builtInCamera)
			to_chat(user, "<span class='warning'>[src] has no camera installed.</span>")
			return FALSE
		if(src == user.get_item_by_slot(ITEM_SLOT_HEAD))
			to_chat(user, "<span class='warning'>You cannot remove the camera from [src] while wearing it.</span>")
			return FALSE

		new /obj/item/wallframe/camera(drop_location())
		QDEL_NULL(builtInCamera)
		to_chat(user, "<span class='notice'>You successfully remove the camera from [src].</span>")
		return TRUE
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
			builtInCamera.forceMove(equipper) //I hate this. But, it's necessary.
			RegisterSignal(equipper, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))

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
		addtimer(CALLBACK(src, PROC_REF(do_camera_update), oldLoc), SILICON_CAMERA_BUFFER)
#undef SILICON_CAMERA_BUFFER

/obj/item/clothing/head/helmet/proc/install_camera(obj/item/I, mob/user, faction)
	if(builtInCamera) //You already have a camera
		return FALSE
	if(!I || !user) //The camera isn't being placed by a person
		builtInCamera = new /obj/machinery/camera(src)
		builtInCamera.c_tag = "Helmet Cam #[rand(0,999)]"
		builtInCamera.internal_light = FALSE
		if(faction == "Syndicate")
			builtInCamera.network = list("syndicate")
		else
			builtInCamera.network = list("ss13")
		return TRUE
	user.transferItemToLoc(I, src)
	builtInCamera = new /obj/machinery/camera(src)
	builtInCamera.c_tag = "Helmet Cam #[rand(0,999)]"
	if(length(user.faction & "Syndicate") || faction == "Syndicate") //If a syndicate agent puts it on, it's a syndie camera now
		builtInCamera.network = list("syndicate")
	else
		builtInCamera.network = list("ss13")
	builtInCamera.internal_light = FALSE
	QDEL_NULL(I)
	return TRUE
