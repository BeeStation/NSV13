//Handles camera stuff for all generic overmap interaction
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

/obj/structure/overmap/proc/gauss_test()
	var/mob/living/carbon/human/M = new(src)
	start_piloting(M, "gauss_gunner")

/obj/structure/overmap/proc/start_piloting(mob/living/carbon/user, position)
	if(!position || user.overmap_ship == src || LAZYFIND(operators, user))
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
		//.if("gauss_gunner")
		//	user.AddComponent(/datum/component/overmap_gunning)
			//LAZYADD(gauss_gunners, user)
		if("all_positions")
			pilot = user
			gunner = user
			LAZYOR(user.mousemove_intercept_objects, src)
	user.set_focus(src)
	LAZYADD(operators,user)
	CreateEye(user) //Your body stays there but your mind stays with me - 6 (Battlestar galactica)
	user.overmap_ship = src
	dradis?.attack_hand(user)
	user.click_intercept = src
	if(mass < MASS_MEDIUM)
		return //Don't zoom out for small ships.
	user.client.overmap_zoomout = (mass <= MASS_MEDIUM) ? 5 : 10 //Automatically zooms you out a fair bit so you can see what's even going on.
	user.client.rescale_view(user.client.overmap_zoomout, 0, ((40*2)+1)-15)

/obj/structure/overmap/proc/stop_piloting(mob/living/M)
	LAZYREMOVE(operators,M)
	M.overmap_ship = null
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
	if(LAZYFIND(gauss_gunners, M))
		var/datum/component/overmap_gunning/C = M.GetComponent(/datum/component/overmap_gunning)
		C.end_gunning()
	if(M.client)
		M.client.view_size.resetToDefault()
		M.client.overmap_zoomout = 0
	var/mob/camera/ai_eye/remote/overmap_observer/eyeobj = M.remote_control
	M.cancel_camera()
	if(M.client) //Reset px, y
		M.client.pixel_x = 0
		M.client.pixel_y = 0

	if(istype(M, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/hal = M
		hal.view_core()
		hal.remote_control = null
		qdel(eyeobj)
		qdel(eyeobj?.off_action)
		qdel(M.remote_control)
		return

	qdel(eyeobj)
	qdel(eyeobj?.off_action)
	qdel(M.remote_control)
	M.remote_control = null
	M.set_focus(M)
	M.cancel_camera()
	return TRUE

/obj/structure/overmap/proc/CreateEye(mob/user)
	if(!user.client)
		return
	if(isAI(user)) //view core nice and neatly resets their camera perspective, stops them tracking and so on.
		var/mob/living/silicon/ai/hal = user
		hal.view_core()
	user.update_sight()
	var/mob/camera/ai_eye/remote/overmap_observer/eyeobj = new(get_center())
	eyeobj.origin = src
	eyeobj.off_action = new
	eyeobj.off_action.remote_eye = eyeobj
	eyeobj.eye_user = user
	eyeobj.name = "[name] observer"
	eyeobj.off_action.target = user
	eyeobj.off_action.user = user
	eyeobj.off_action.ship = src
	eyeobj.off_action.Grant(user)
	eyeobj.setLoc(eyeobj.loc)
	eyeobj.add_relay()
	user.reset_perspective(eyeobj)
	user.remote_control = eyeobj

//Now it's time to handle people observing the ship.
/mob/camera/ai_eye/remote/overmap_observer
	name = "Inactive Camera Eye"
	var/datum/action/innate/camera_off/overmap/off_action
	animate_movement = 0 //Stops glitching with overmap movement
	use_static = USE_STATIC_NONE
	var/obj/structure/overmap/last_target = null //Lets gunners lock on to their targets for accurate shooting.

/datum/action/innate/camera_off/overmap
	name = "Stop observing"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"
	var/mob/camera/ai_eye/remote/overmap_observer/remote_eye
	var/mob/living/user
	var/obj/structure/overmap/ship = null

/datum/action/innate/camera_off/overmap/Activate()
	if(!target || !isliving(target))
		return
	if(!remote_eye?.origin)
		qdel(src)
		qdel(remote_eye)
	if(ship.stop_piloting(target))
		qdel(remote_eye)
		qdel(src)

/obj/structure/overmap/proc/remove_eye_control(mob/living/user)

/mob/camera/ai_eye/remote/overmap_observer/relaymove(mob/user,direct)
	origin?.relaymove(user,direct) //Move the ship. Means our pilots don't fucking suffocate because space is C O L D
	return

/mob/camera/ai_eye/remote/overmap_observer/proc/add_relay() //Add a signal to move us
	RegisterSignal(origin, COMSIG_MOVABLE_MOVED, .proc/update, origin)

/mob/camera/ai_eye/remote/overmap_observer/proc/set_override(state, obj/structure/overmap/override)
	if(state)
		track_target(override)
	else
		var/obj/structure/overmap/ship = origin
		to_chat(eye_user, "<span class='notice'>Target lock relinquished.</span>")
		ship.CreateEye(eye_user)
		QDEL_NULL(off_action)
		QDEL_NULL(src)

/mob/camera/ai_eye/remote/overmap_observer/proc/update(obj/structure/overmap/target)
	if(!target)
		target = origin
	last_target = target
	forceMove(target.get_center()) //This only happens for gunner cams
	if(eye_user.client)
		eye_user.client.pixel_x = origin.pixel_x
		eye_user.client.pixel_y = origin.pixel_y
	return TRUE

/mob/camera/ai_eye/remote/overmap_observer/proc/track_target(obj/structure/overmap/target)
	UnregisterSignal(last_target, COMSIG_MOVABLE_MOVED)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/update, target)
	update()
	return TRUE
