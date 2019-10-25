
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
			pilot = user
			show_flight_ui()
		if("gunner")
			gunner = user
		if("all_positions")
			pilot = user
			gunner = user
	operators += user
	CreateEye(user) //Your body stays there but your mind stays with me - 6 (Battlestar galactica)
	user.overmap_ship = src
	dradis?.attack_hand(user)
	LAZYOR(user.mousemove_intercept_objects, src)
	user.click_intercept = src

/obj/structure/overmap/proc/stop_piloting(mob/living/M)
	operators -= M
	LAZYREMOVE(M.mousemove_intercept_objects, src)
	if(M.click_intercept == src)
		M.click_intercept = null
	if(M == pilot)
		pilot = null
		if(helm)
			playsound(helm, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	if(M == gunner)
		if(tactical)
			playsound(tactical, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
		gunner = null
	if(M.client)
		M.client.check_view()
	M.overmap_ship = null
	M.cancel_camera()
	M.remote_control = null

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

/datum/action/innate/camera_off/overmap
	name = "Stop observing"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"
	var/mob/camera/aiEye/remote/overmap_observer/remote_eye
	var/mob/living/user

/datum/action/innate/camera_off/overmap/Activate()
	if(!target || !isliving(target))
		return
	var/obj/structure/overmap/ship = remote_eye.origin
	ship.stop_piloting(target)
	qdel(remote_eye)
	qdel(src)

/obj/structure/overmap/proc/remove_eye_control(mob/living/user)

/mob/camera/aiEye/remote/overmap_observer/relaymove(mob/user,direct)
	origin.relaymove(user,direct) //Move the ship. Means our pilots don't fucking suffocate because space is C O L D
	return

/mob/camera/aiEye/remote/overmap_observer/proc/add_relay() //Add a signal to move us
	RegisterSignal(origin, COMSIG_MOVABLE_MOVED, .proc/update)

/mob/camera/aiEye/remote/overmap_observer/proc/update()
	forceMove(get_turf(origin))