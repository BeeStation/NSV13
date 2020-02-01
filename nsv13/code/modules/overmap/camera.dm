
/client
	perspective = EYE_PERSPECTIVE //Use this perspective or else shit will break! (sometimes screen will turn black)

/client/proc/AdjustView()
	if(mob.overmap_ship)
		pixel_x = mob.overmap_ship.pixel_x
		pixel_y = mob.overmap_ship.pixel_y
		eye = mob.overmap_ship
	else
		pixel_x = 0
		pixel_y = 0
		eye = mob

/obj/structure/overmap/proc/start_piloting(mob/living/carbon/user, position)
	if(!position)
		return
	switch(position)
		if("pilot")
			if(pilot)
				to_chat(pilot, "<span class='warning'>[user] has kicked you off the ship controls!</span>")
				stop_piloting(pilot)
			pilot = user
			LAZYOR(user.mousemove_intercept_objects, src)
		if("gunner")
			if(gunner)
				to_chat(gunner, "<span class='warning'>[user] has kicked you off the ship controls!</span>")
				stop_piloting(gunner)
			gunner = user
		if("all_positions")
			pilot = user
			gunner = user
			LAZYOR(user.mousemove_intercept_objects, src)
	user.set_focus(src)
	operators += user
	CreateEye(user) //Your body stays there but your mind stays with me - 6 (Battlestar galactica)
	user.overmap_ship = src
	dradis?.attack_hand(user)
	user.click_intercept = src

/obj/structure/overmap/proc/stop_piloting(mob/living/M)
	M.focus = M
	operators -= M
	if(M.click_intercept == src)
		M.click_intercept = null
	if(pilot && M == pilot)
		LAZYREMOVE(M.mousemove_intercept_objects, src)
		pilot = null
		if(helm)
			playsound(helm, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	if(gunner && M == gunner)
		if(tactical)
			playsound(tactical, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
		gunner = null
		target_lock = null
	if(M.client)
		M.client.check_view()
	M.overmap_ship = null
	var/mob/camera/aiEye/remote/overmap_observer/eyeobj = M.remote_control
	if(eyeobj?.off_action)
		qdel(eyeobj.off_action)
	M.cancel_camera()
	return TRUE

/obj/structure/overmap/proc/CreateEye(mob/user)
	if(!user.client)
		return
	user.update_sight()
	var/mob/camera/aiEye/remote/overmap_observer/eyeobj = new(get_turf(src))
	eyeobj.origin = src
	eyeobj.off_action = new
	eyeobj.off_action.remote_eye = eyeobj
	eyeobj.eye_user = user
	eyeobj.name = "[name] observer"
	eyeobj.off_action.target = user
	eyeobj.off_action.user = user
	eyeobj.off_action.Grant(user)
	eyeobj.setLoc(eyeobj.loc)
	eyeobj.add_relay()
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)

//Now it's time to handle people observing the ship.
/mob/camera/aiEye/remote/overmap_observer
	name = "Inactive Camera Eye"
	var/datum/action/innate/camera_off/overmap/off_action
	animate_movement = 0 //Stops glitching with overmap movement
	use_static = USE_STATIC_NONE
	var/obj/structure/overmap/override_origin = null //Lets gunners lock on to their targets for accurate shooting.

/datum/action/innate/camera_off/overmap
	name = "Stop observing"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"
	var/mob/camera/aiEye/remote/overmap_observer/remote_eye
	var/mob/living/user

/datum/action/innate/camera_off/overmap/Activate()
	if(!target || !isliving(target))
		return
	if(!remote_eye?.origin)
		qdel(src)
		qdel(remote_eye)
	var/obj/structure/overmap/ship = remote_eye.origin
	if(ship.stop_piloting(target))
		qdel(remote_eye)
		qdel(src)

/obj/structure/overmap/proc/remove_eye_control(mob/living/user)

/mob/camera/aiEye/remote/overmap_observer/relaymove(mob/user,direct)
	origin.relaymove(user,direct) //Move the ship. Means our pilots don't fucking suffocate because space is C O L D
	return

/mob/camera/aiEye/remote/overmap_observer/proc/add_relay() //Add a signal to move us
	RegisterSignal(origin, COMSIG_MOVABLE_MOVED, .proc/update)

/mob/camera/aiEye/remote/overmap_observer/proc/update()
	if(override_origin)
		forceMove(override_origin) //This only happens for gunner cams
		eye_user.client.pixel_x = override_origin.pixel_x
		eye_user.client.pixel_y = override_origin.pixel_y
		return
	forceMove(get_turf(origin))
