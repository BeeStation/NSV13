
/////////////////////////////////////////////////////////////////////////////////
// ACKNOWLEDGEMENTS:  Credit to yogstation (Monster860) for the movement code. //
// I had no part in writing the movement engine, that's his work               //
/////////////////////////////////////////////////////////////////////////////////

/mob
	var/obj/structure/overmap/overmap_ship //Used for relaying movement, hotkeys etc.

/obj/structure/overmap
	name = "overmap ship"
	desc = "A space faring vessel."
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "default"
	density = TRUE
	dir = NORTH
	layer = ABOVE_MOB_LAYER
	animate_movement = NO_STEPS // Override the inbuilt movement engine to avoid bouncing
	req_one_access = list(ACCESS_HEADS, ACCESS_MUNITIONS, ACCESS_SEC_DOORS, ACCESS_ENGINE) //Bridge assistants/heads, munitions techs / fighter pilots, security officers, engineering personnel all have access.

	move_resist = MOVE_FORCE_OVERPOWERING //THIS MAY BE A BAD IDEA - (okay I downgraded from INFINITE)
	anchored = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // Overmap ships represent massive craft that don't burn

	var/sprite_size = 64 //Pixels. This represents 64x64 and allows for the bullets that you fire to align properly.
	var/area_type = null //Set the type of the desired area you want a ship to link to, assuming it's not the main player ship.
	var/impact_sound_cooldown = FALSE //Avoids infinite spamming of the ship taking damage.
	var/datum/star_system/current_system //What star_system are we currently in? Used for parallax.
	var/resize = 0 //Factor by which we should shrink a ship down. 0 means don't shrink it.
	var/list/docking_points = list() //Where we can land on this ship. Usually right at the edge of a z-level.
	var/last_slowprocess = 0

	var/list/linked_areas = list() //List of all areas that we control
	var/datum/gas_mixture/cabin_air //Cabin air mix used for small ships like fighters (see overmap/fighters/fighters.dm)
	var/obj/machinery/portable_atmospherics/canister/internal_tank //Internal air tank reference. Used mostly in small ships. If you want to sabotage a fighter, load a plasma tank into its cockpit :)
	CanAtmosPass = ATMOS_PASS_YES

	// Health, armor, and damage
	max_integrity = 300 //Max internal integrity
	integrity_failure = 0
	var/armour_plates = 0 //You lose max integrity when you lose armour plates.
	var/max_armour_plates = 0
	var/list/dent_decals = list() //Ships get visibly damaged as they get shot
	var/damage_states = FALSE //Did you sprite damage states for this ship? If yes, set this to true

	var/use_armour_quadrants = FALSE //Does the object use the armour quadrant system?
	var/max_armour = 0 //Max armour amount per quad
	var/current_armour = 0 //Per quad
	var/list/armour_quadrants = list("forward_port" = list(), "forward_starboard" = list(), "aft_port" = list(), "aft_starboard" = list()) //Our four quadrants
	var/linked_apnw = null //Our linked APNW

	var/structure_crit = FALSE //Handles when the ship's integrity has failed
	var/structure_crit_no_return = FALSE //Override for handling point of no return
	var/structure_crit_init = null //Timer ID for point of no return
	var/structure_crit_alert = 0 //Incremental warning states
	var/last_critprocess = 0 //Keeper for SS Crit timing
	var/explosion_cooldown = FALSE

	//Movement Variables
	var/offset_x = 0 // like pixel_x/y but in tiles
	var/offset_y = 0
	var/angle = 0 // degrees, clockwise
	var/desired_angle = null // set by pilot moving his mouse
	var/angular_velocity = 0 // degrees per second
	var/max_angular_acceleration = 180 // in degrees per second per second
	var/speed_limit = 5 //Stops ships from going too damn fast. This can be overridden by things like fighters launching from tubes, so it's not a const.
	var/last_thrust_forward = 0
	var/last_thrust_right = 0
	var/last_rotate = 0
	var/should_open_doors = FALSE //Should we open airlocks? This is off by default because it was HORRIBLE.
	var/inertial_dampeners = TRUE

	var/user_thrust_dir = 0

	//Movement speed variables
	var/forward_maxthrust = 6
	var/backward_maxthrust = 3
	var/side_maxthrust = 1
	var/mass = MASS_SMALL //The "mass" variable will scale the movespeed according to how large the ship is.
	var/landing_gear = FALSE //Allows you to move in atmos without scraping the hell outta your ship

	var/bump_impulse = 0.6
	var/bounce_factor = 0.7 // how much of our velocity to keep on collision
	var/lateral_bounce_factor = 0.95 // mostly there to slow you down when you drive (pilot?) down a 2x2 corridor

	var/brakes = FALSE //Helps you stop the ship
	var/rcs_mode = FALSE //stops you from swivelling on mouse move
	var/move_by_mouse = TRUE //It's way easier this way, but people can choose.

	//Logging
	var/list/weapon_log = list() //Shows who did the firing thing

	// Mobs
	var/mob/living/pilot //Physical mob that's piloting us. Cameras come later
	var/mob/living/gunner //The person who fires the guns.
	var/list/gauss_gunners = list() //Anyone sitting in a gauss turret who should be able to commit pew pew against syndies.
	var/list/operators = list() //Everyone who needs their client updating when we move.
	var/list/mobs_in_ship = list() //A list of mobs which is inside the ship. This is generated by our areas.dm file as they enter / exit areas

	// Controlling equipment
	var/obj/machinery/computer/ship/helm //Relay beeping noises when we act
	var/obj/machinery/computer/ship/tactical
	var/obj/machinery/computer/ship/dradis/dradis //So that pilots can check the radar easily

	// Ship weapons
	var/list/weapon_types[MAX_POSSIBLE_FIREMODE]

	var/fire_mode = FIRE_MODE_PDC //What gun do we want to fire? Defaults to railgun, with PDCs there for flak
	var/weapon_safety = FALSE //Like a gun safety. Entirely un-used except for fighters to stop brainlets from shooting people on the ship unintentionally :)
	var/faction = null //Used for target acquisition by AIs

	var/fire_delay = 5
	var/next_firetime = 0

	var/list/weapon_overlays = list()
	var/obj/weapon_overlay/last_fired //Last weapon overlay that fired, so we can rotate guns independently
	var/atom/last_target //Last thing we shot at, used to point the railgun at an enemy.

	var/torpedoes = 2 //If this starts at above 0, then the ship can use torpedoes when AI controlled
	var/missiles = 4 //If this starts at above 0, then the ship can use missiles when AI controlled

	var/pdc_miss_chance = 20 //In %, how often do PDCs fire inaccurately when aiming at missiles. This is ignored for ships as theyre bigger targets.
	var/list/torpedoes_to_target = list() //Torpedoes that have been fired explicitly at us, and that the PDCs need to worry about.
	var/atom/target_lock = null
	var/can_lock = TRUE //Can we lock on to people or not
	var/lockon_time = 2 SECONDS

	// Railgun aim helper
	var/last_tracer_process = 0
	var/aiming = FALSE
	var/aiming_lastangle = 0
	var/lastangle = 0
	var/list/obj/effect/projectile/tracer/current_tracers
	var/mob/listeningTo

	var/uid = 0 //Unique identification code
	var/starting_system = null //Where do we start in the world?
	var/obj/machinery/computer/ship/ftl_computer/ftl_drive
	var/reserved_z = 0 //The Z level we were spawned on, and thus inhabit. This can be changed if we "swap" positions with another ship.
	var/list/occupying_levels = list() //Refs to the z-levels we own for setting parallax and that, or for admins to debug things when EVERYTHING INEVITABLY BREAKS
	var/torpedo_type = /obj/item/projectile/guided_munition/torpedo
	var/next_maneuvre = 0 //When can we pull off a fancy trick like boost or kinetic turn?
	var/flak_battery_amount = 1

	var/role = NORMAL_OVERMAP
	
	var/list/missions = list()

/**
Proc to spool up a new Z-level for a player ship and assign it a treadmill.
@return OM, a newly spawned overmap sitting on its treadmill as it ought to be.
*/

/proc/instance_overmap(_path, folder = null, interior_map_files = null, traits = null, default_traits = ZTRAITS_BOARDABLE_SHIP, midround=FALSE) //By default we apply the boardable ship traits, as they make fighters and that lark work
	if(!islist(interior_map_files))
		interior_map_files = list(interior_map_files)
	if(!_path)
		_path = /obj/structure/overmap/nanotrasen/heavy_cruiser/starter
	RETURN_TYPE(/obj/structure/overmap)
	SSmapping.add_new_zlevel("Overmap ship level [++world.maxz]", ZTRAITS_OVERMAP)
	repopulate_sorted_areas()
	smooth_zlevel(world.maxz)
	log_game("Z-level [world.maxz] loaded for overmap treadmills.")
	var/turf/exit = get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), world.maxz)) //Plop them bang in the center of the system.
	var/obj/structure/overmap/OM = new _path(exit) //Ship'll pick up the info it needs, so just domp eet at the exit turf.
	OM.current_system = SSstar_system.find_system(OM)
	if(OM.role == MAIN_OVERMAP) //If we're the main overmap, we'll cheat a lil' and apply our status to all of the Zs under "station"
		for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
			var/datum/space_level/SL = SSmapping.z_list[z]
			SL.linked_overmap = OM
			OM.occupying_levels += SL
	if(folder && interior_map_files){ //If this thing comes with an interior.
		var/previous_maxz = world.maxz //Ok. Store the current number of Zs. Anything that we add on top of this due to this proc will then be conted as decks of our ship.
		var/list/errorList = list()
		var/list/loaded = SSmapping.LoadGroup(errorList, "[OM.name] interior Z level", "[folder]", files=interior_map_files, traits = traits, default_traits=default_traits, silent=TRUE)
		if(errorList.len)	// failed to load :(
			message_admins("[_path]'s interior failed to load! Check you used instance_overmap correctly...")
			log_game("[_path]'s interior failed to load! Check you used instance_overmap correctly...")
			return OM
		for(var/datum/parsed_map/PM in loaded)
			PM.initTemplateBounds()
		repopulate_sorted_areas()
		var/list/occupying = list()
		for(var/I = ++previous_maxz; I <= world.maxz; I++){ //So let's say we started loading interior Z-levels at Z index 4 and we have 2 decks. That means that Z 5 and 6 belong to this ship's interior, so link them
			occupying += I;
			for(var/area/AR in SSmapping.areas_in_z["[I]"])
				OM.linked_areas += AR
		}
		for(var/A in SSmapping.z_list)
			var/datum/space_level/SL = A
			if(LAZYFIND(occupying, SL.z_value)) //And if the Z-level's value is one of ours, associate it.
				SL.linked_overmap = OM
				OM.occupying_levels += SL
				log_game("Z-level [SL] linked to [OM].")
		if(midround)
			overmap_lighting_force(OM)
	}
	return OM

/obj/weapon_overlay
	name = "Weapon overlay"
	layer = 4
	mouse_opacity = FALSE
	layer = WALL_OBJ_LAYER
	var/angle = 0 //Debug

/obj/weapon_overlay/proc/do_animation()
	return

/obj/weapon_overlay/railgun //Railgun sits on top of the ship and swivels to face its target
	name = "Railgun"
	icon_state = "railgun"

/obj/weapon_overlay/railgun_overlay/do_animation()
	flick("railgun_charge",src)

/obj/weapon_overlay/laser
	name = "Laser cannon"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "conduit-red"

/obj/weapon_overlay/laser/do_animation()
	flick("laser",src)

/obj/structure/overmap/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/overmap/LateInitialize()
	. = ..()
	if(role > NORMAL_OVERMAP)
		SSstar_system.add_ship(src)
		reserved_z = src.z //Our "reserved" Z will always be kept for us, no matter what. If we, for example, visit a system that another player is on and then jump away, we are returned to our own Z.
		AddComponent(/datum/component/nsv_mission_arrival_in_system) // Adds components needed to track jumps for missions
		AddComponent(/datum/component/nsv_mission_departure_from_system)
	AddComponent(/datum/component/nsv_mission_killships)
	current_tracers = list()
	GLOB.overmap_objects += src
	START_PROCESSING(SSphysics_processing, src)

	vector_overlay = new()
	vector_overlay.appearance_flags |= KEEP_APART
	vector_overlay.appearance_flags |= RESET_TRANSFORM
	vector_overlay.icon = icon
	vis_contents += vector_overlay
	update_icon()
	find_area()
	switch(mass) //Scale speed with mass (tonnage)
		if(MASS_TINY) //Tiny ships are manned by people, so they need air.
			forward_maxthrust = 4
			backward_maxthrust = 4
			side_maxthrust = 3
			max_angular_acceleration = 180
			cabin_air = new
			cabin_air.set_temperature(T20C)
			cabin_air.set_volume(200)
			cabin_air.set_moles(/datum/gas/oxygen, O2STANDARD*cabin_air.return_volume()/(R_IDEAL_GAS_EQUATION*cabin_air.return_temperature()))
			cabin_air.set_moles(/datum/gas/nitrogen, N2STANDARD*cabin_air.return_volume()/(R_IDEAL_GAS_EQUATION*cabin_air.return_temperature()))
			move_by_mouse = TRUE //You'll want this. Trust.
			inertial_dampeners = FALSE

		if(MASS_SMALL)
			forward_maxthrust = 3
			backward_maxthrust = 3
			side_maxthrust = 3
			max_angular_acceleration = 110
			bounce_factor = 0.65
			lateral_bounce_factor = 0.95

		if(MASS_MEDIUM)
			forward_maxthrust = 2
			backward_maxthrust = 2
			side_maxthrust = 2
			max_angular_acceleration = 15
			bounce_factor = 0.5
			lateral_bounce_factor = 0.8

		if(MASS_LARGE)
			forward_maxthrust = 1.85
			backward_maxthrust = 1.85
			side_maxthrust = 1.5
			max_angular_acceleration = 10
			bounce_factor = 0.45
			lateral_bounce_factor = 0.8
			flak_battery_amount = 2

		if(MASS_TITAN)
			forward_maxthrust = 0.5
			backward_maxthrust = 0.5
			side_maxthrust = 0.5
			max_angular_acceleration = 2.5
			bounce_factor = 0.35
			lateral_bounce_factor = 0.6
			flak_battery_amount = 3

	if(role == MAIN_OVERMAP)
		name = "[station_name()]"
	current_system = SSstar_system.find_system(src)
	addtimer(CALLBACK(src, .proc/force_parallax_update), 20 SECONDS)
	addtimer(CALLBACK(src, .proc/check_armour), 20 SECONDS)

	apply_weapons()

//Method to apply weapon types to a ship. Override to your liking, this just handles generic rules and behaviours
/obj/structure/overmap/proc/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = (mass > MASS_TINY) ? new/datum/ship_weapon/pdc_mount(src) : new /datum/ship_weapon/light_cannon(src)
	weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)
	if(mass > MASS_TINY || occupying_levels.len)
		weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
		weapon_types[FIRE_MODE_RAILGUN] = new/datum/ship_weapon/railgun(src)
	if(mass > MASS_MEDIUM || occupying_levels.len)
		weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src) //AI ships want to be able to use gauss too. I say let them...
		weapon_types[FIRE_MODE_MAC] = new /datum/ship_weapon/mac(src)
	if(ai_controlled)
		weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)

/obj/item/projectile/Destroy()
	if(physics2d)
		qdel(physics2d)
		physics2d = null
	. = ..()

/obj/structure/overmap/Destroy()
	SEND_SIGNAL(src,COMSIG_SHIP_KILLED)
	QDEL_LIST(current_tracers)
	if(cabin_air)
		QDEL_NULL(cabin_air)
	//Free up memory refs here.
	if(physics2d)
		qdel(physics2d)
		physics2d = null
	. = ..()

/obj/structure/overmap/proc/find_area()
	if(role == MAIN_OVERMAP) //We're the hero ship, link us to every ss13 area.
		for(var/X in GLOB.teleportlocs) //Teleportlocs = ss13 areas that aren't special / centcom
			var/area/area = GLOB.teleportlocs[X] //Pick a station area and yeet it.
			linked_areas += area

/obj/structure/overmap/proc/InterceptClickOn(mob/user, params, atom/target)
	var/list/params_list = params2list(params)
	if(user.incapacitated() || !isliving(user))
		return FALSE
	if(istype(target, /obj/machinery/button/door) || istype(target, /obj/machinery/turbolift_button))
		target.attack_hand(user)
		return FALSE
	if(weapon_safety)
		return FALSE
	if(target == src || istype(target, /obj/screen) || (target && (target in user.GetAllContents())) || params_list["alt"] || params_list["ctrl"])
		return FALSE
	if(locate(user) in gauss_gunners) //Special case for gauss gunners here. Takes priority over them being the regular gunner.
		var/obj/machinery/ship_weapon/gauss_gun/user_gun = user.loc
		if(!istype(user_gun))
			return FALSE
		if(user_gun.safety)
			to_chat(user, "<span class='warning'>Gun safeties are engaged.</span>")
			return FALSE
		user_gun.onClick(target)
		return TRUE
	if(user != gunner)
		if(user == pilot)
			var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_RAILGUN] //For annoying ships like whisp
			var/list/loaded = SW.weapons["loaded"]
			if(SW && loaded?.len)
				fire_weapon(target, FIRE_MODE_RAILGUN)
			else
				SW = weapon_types[FIRE_MODE_RED_LASER]
				if(SW)
					fire_weapon(target, FIRE_MODE_RED_LASER)
		return FALSE
	if(tactical && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(tactical, sound, 100, 1)
	if(params_list["shift"]) //Shift click to lock on to people
		start_lockon(target)
		return TRUE
	if(target_lock && mass <= MASS_TINY)
		fire(target_lock) //Fighters get an aimbot to help them out.
		return TRUE
	fire(target)
	return TRUE

/obj/structure/overmap/proc/start_lockon(atom/target)
	if(!istype(target, /obj/structure/overmap))
		return FALSE
	if(target == target_lock)
		relinquish_target_lock()
		return
	if(!can_lock)
		to_chat(gunner, "<span class='warning'>Target acquisition already in progress. Please wait.</span>")
		return
	if(target_lock)
		target_lock = null
		stop_relay(CHANNEL_IMPORTANT_SHIP_ALERT)
		if(mass > MASS_TINY)
			update_gunner_cam(src)
	can_lock = FALSE
	relay('nsv13/sound/effects/fighters/locking.ogg', message=null, loop=TRUE, channel=CHANNEL_IMPORTANT_SHIP_ALERT)
	addtimer(CALLBACK(src, .proc/finish_lockon, target), lockon_time)

/obj/structure/overmap/proc/relinquish_target_lock()
	if(!target_lock)
		return
	to_chat(gunner, "<span class='warning'>Target lock on [target_lock] cancelled. Returning manual fire control.</span>")
	update_gunner_cam(src)
	target_lock = null
	return

/obj/structure/overmap/proc/finish_lockon(atom/target)
	if(!gunner)
		return
	can_lock = TRUE
	target_lock = target
	if(mass > MASS_TINY)
		update_gunner_cam(target)
	else
		to_chat(gunner, "<span class='notice'>Target lock established. All weapons will now automatically lock on to your chosen target instead of where you specifically aim them. </span>")
	stop_relay(CHANNEL_IMPORTANT_SHIP_ALERT)
	relay('nsv13/sound/effects/fighters/locked.ogg', message=null, loop=FALSE, channel=CHANNEL_IMPORTANT_SHIP_ALERT)

/obj/structure/overmap/proc/update_gunner_cam(atom/target)
	var/mob/camera/aiEye/remote/overmap_observer/cam = gunner.remote_control
	cam.track_target(target)

/obj/structure/overmap/onMouseMove(object,location,control,params)
	if(!pilot || !pilot.client || pilot.incapacitated() || !move_by_mouse || control !="mapwindow.map" ||!can_move()) //Check pilot status, if we're meant to follow the mouse, and if theyre actually moving over a tile rather than in a menu
		return // I don't know what's going on.
	desired_angle = getMouseAngle(params, pilot)
	update_icon()

/obj/structure/overmap/proc/getMouseAngle(params, mob/M)
	var/list/params_list = params2list(params)
	var/list/sl_list = splittext(params_list["screen-loc"],",")
	if(!sl_list.len)
		return
	var/list/sl_x_list = splittext(sl_list[1], ":")
	var/list/sl_y_list = splittext(sl_list[2], ":")
	var/view_list = isnum(M.client.view) ? list("[M.client.view*2+1]","[M.client.view*2+1]") : splittext(M.client.view, "x")
	var/dx = text2num(sl_x_list[1]) + (text2num(sl_x_list[2]) / world.icon_size) - 1 - text2num(view_list[1]) / 2
	var/dy = text2num(sl_y_list[1]) + (text2num(sl_y_list[2]) / world.icon_size) - 1 - text2num(view_list[2]) / 2
	if(sqrt(dx*dx+dy*dy) > 1)
		return 90 - ATAN2(dx, dy)
	else
		return null

/obj/structure/overmap/relaymove(mob/user, direction)
	if(user != pilot || pilot.incapacitated())
		return
	user_thrust_dir = direction

//relay('nsv13/sound/effects/ship/rcs.ogg')

/obj/structure/overmap/update_icon() //Adds an rcs overlay
	apply_damage_states()
	if(last_fired) //Swivel the most recently fired gun's overlay to aim at the last thing we hit
		last_fired.icon = icon
		last_fired.setDir(get_dir(src, last_target))
	cut_overlay("rcs_left")
	cut_overlay("rcs_right")
	cut_overlay("thrust")
	if(angle == desired_angle)
		return //No RCS needed if we're already facing where we want to go
	if(prob(20) && desired_angle)
		playsound(src, 'nsv13/sound/effects/ship/rcs.ogg', 30, 1)
	var/list/left_thrusts = list()
	left_thrusts.len = 8
	var/list/right_thrusts = list()
	right_thrusts.len = 8
	var/back_thrust = 0
	for(var/cdir in GLOB.cardinals)
		left_thrusts[cdir] = 0
		right_thrusts[cdir] = 0
	if(last_thrust_right != 0)
		var/tdir = last_thrust_right > 0 ? WEST : EAST
		left_thrusts[tdir] = abs(last_thrust_right) / side_maxthrust
		right_thrusts[tdir] = abs(last_thrust_right) / side_maxthrust
	if(last_thrust_forward > 0)
		back_thrust = last_thrust_forward / forward_maxthrust
	if(last_thrust_forward < 0)
		left_thrusts[NORTH] = -last_thrust_forward / backward_maxthrust
		right_thrusts[NORTH] = -last_thrust_forward / backward_maxthrust
	if(last_rotate != 0)
		var/frac = abs(last_rotate) / max_angular_acceleration
		for(var/cdir in GLOB.cardinals)
			if(last_rotate > 0)
				right_thrusts[cdir] += frac
			else
				left_thrusts[cdir] += frac
	for(var/cdir in GLOB.cardinals)
		var/left_thrust = left_thrusts[cdir]
		var/right_thrust = right_thrusts[cdir]
		if(left_thrust)
			add_overlay("rcs_left")
		if(right_thrust)
			add_overlay("rcs_right")
	if(back_thrust)
		add_overlay("thrust")

/obj/structure/overmap/proc/apply_damage_states()
	if(!damage_states)
		return
	var/progress = obj_integrity //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = max_integrity //How much is the max hp of the shield? This is constant through all of them
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 25)//Round it down to 20%. We now apply visual damage
	icon_state = "[initial(icon_state)]-[progress]"

/obj/structure/overmap/proc/relay(var/sound, var/message=null, loop = FALSE, channel = null) //Sends a sound + text message to the crew of a ship
	for(var/X in mobs_in_ship)
		if(ismob(X))
			var/mob/mob = X
			if(sound)
				if(channel) //Doing this forbids overlapping of sounds
					SEND_SOUND(mob, sound(sound, repeat = loop, wait = 0, volume = 100, channel = channel))
				else
					SEND_SOUND(mob, sound(sound, repeat = loop, wait = 0, volume = 100))
			if(message)
				to_chat(mob, message)

/obj/structure/overmap/proc/stop_relay(channel) //Stops all playing sounds for crewmen on N channel.
	for(var/X in mobs_in_ship)
		if(ismob(X))
			var/mob/mob = X
			mob.stop_sound_channel(channel)

/obj/structure/overmap/proc/relay_to_nearby(sound, message, ignore_self=FALSE) //Sends a sound + text message to nearby ships
	for(var/obj/structure/overmap/ship in GLOB.overmap_objects)
		if(ignore_self)
			if(ship == src)
				continue
		if(get_dist(src, ship) <= 20) //Sound doesnt really travel in space, but space combat with no kaboom is LAME
			ship.relay(sound,message)

/obj/structure/overmap/proc/verb_check(require_pilot = TRUE, mob/user = null)
	if(!user)
		user = usr
	if(user != pilot)
		to_chat(user, "<span class='notice'>You can't reach the controls from here</span>")
		return FALSE
	return !user.incapacitated() && isliving(user)

/obj/structure/overmap/key_down(key, client/user)
	var/mob/themob = user.mob
	switch(key)
		if("Shift")
			if(themob == pilot)
				boost(NORTH)
		if("X")
			if(themob == pilot)
				toggle_inertia()
			if(helm && prob(80))
				var/sound = pick(GLOB.computer_beeps)
				playsound(helm, sound, 100, 1)
			return TRUE
		if("C" || "c")
			if(themob == pilot)
				toggle_move_mode()
			if(helm && prob(80))
				var/sound = pick(GLOB.computer_beeps)
				playsound(helm, sound, 100, 1)
			return TRUE
		if("Alt")
			if(themob == pilot)
				toggle_brakes()
			if(helm && prob(80))
				var/sound = pick(GLOB.computer_beeps)
				playsound(helm, sound, 100, 1)
			return TRUE
		if("Space")
			if(themob == gunner)
				cycle_firemode()
				if(tactical && prob(80))
					var/sound = pick(GLOB.computer_beeps)
					playsound(tactical, sound, 100, 1)
			return TRUE
		if("Q" || "q")
			if(!move_by_mouse)
				desired_angle -= 15
		if("E" || "e")
			if(!move_by_mouse)
				desired_angle += 15

/obj/structure/overmap/proc/boost(direction)
	if(world.time < next_maneuvre)
		to_chat(pilot, "<span class='notice'>Engines on cooldown to prevent overheat</span>")
		return FALSE
	relay('nsv13/sound/effects/ship/afterburner.ogg', message="<span class='warning'>You feel the ship lurch suddenly.</span>", loop=FALSE)
	if(helm && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(helm, sound, 100, 1)
	next_maneuvre = world.time + 15 SECONDS
	addtimer(VARSET_CALLBACK(src, forward_maxthrust, forward_maxthrust), 6 SECONDS)
	addtimer(VARSET_CALLBACK(src, backward_maxthrust, backward_maxthrust), 6 SECONDS)
	addtimer(VARSET_CALLBACK(src, side_maxthrust, side_maxthrust), 6 SECONDS)
	addtimer(VARSET_CALLBACK(src, max_angular_acceleration, max_angular_acceleration), 6 SECONDS)
	addtimer(VARSET_CALLBACK(src, speed_limit, speed_limit), 6 SECONDS)
	speed_limit += 5
	add_overlay("thrust")
	switch(direction)
		if(NORTH)
			max_angular_acceleration *= 0.5 //Kick it forward, but kill turn rate as youre going super fast
			forward_maxthrust *= 5
			backward_maxthrust *= 5
		if(SOUTH)
			max_angular_acceleration *= 0.5
			forward_maxthrust *= 5
			backward_maxthrust *= 5
		if(EAST)
			max_angular_acceleration *= 5
			max_angular_acceleration = CLAMP(max_angular_acceleration, 0, 360)
			side_maxthrust *= 5
		if(WEST)
			max_angular_acceleration *= 5
			max_angular_acceleration = CLAMP(max_angular_acceleration, 0, 360)
			side_maxthrust *= 5
	addtimer(CALLBACK(src, .proc/check_throwaround, angle, direction), 3 SECONDS)
	user_thrust_dir = direction
	shake_everyone(10)

//Check how aggressively the pilots are turning

/obj/structure/overmap/proc/check_throwaround(theAngle, direction)
	var/delta = abs(angular_velocity) //Where we started.
	if(delta >= 20) //This is the canterbury, prepare for FLIP AND BURN.
		if(!linked_areas.len)
			if(!mobs_in_ship.len)
				return
			for(var/mob/living/M in mobs_in_ship)
				//Black out viper jockies who turn too often and too hard.
				if(!istype(M))
					continue
				M.adjustStaminaLoss(30)
				switch(M.staminaloss)
					if(0 to 30)
						continue
					if(50 to 70)
						to_chat(M, "<span class='warning'>You feel slightly lightheaded.</span>")
					if(71 to 89)
						to_chat(M, "<span class='warning'>Colour starts to drain from your vision. You feel like you're starting to black out....</span>")
					if(90 to 100) //Blackout. Slow down on the turns there kid!
						to_chat(M, "<span class='userdanger'>You black out!</span>")
						M.Sleeping(5 SECONDS)
			return
		for(var/mob/living/M in mobs_in_ship)
			if(!istype(M))
				continue
			if(M.buckled) //Good for you, you strapped in!
				continue
			if(!direction)
				continue
			if(M.mob_negates_gravity()) //Wear magboots and you're good.
				continue
			var/atom/throw_target = null
			switch(direction) //Assuming that all our ships face east...
				if(NORTH)
					throw_target = get_turf(locate(M.x-10, M.y, M.z))
				if(SOUTH)
					throw_target = get_turf(locate(M.x+10, M.y, M.z))
				if(EAST)
					throw_target = get_turf(locate(M.x, M.y+10, M.z))
				if(WEST)
					throw_target = get_turf(locate(M.x, M.y-10, M.z))
			if(!throw_target)
				continue
			if(iscarbon(M))
				var/mob/living/carbon/L = M
				if(HAS_TRAIT(L, TRAIT_SEASICK))
					to_chat(L, "<span class='warning'>Your head swims as the ship violently turns!</span>")
					if(prob(40)) //Take a roll! First option makes you puke and feel terrible. Second one makes you feel iffy.
						L.adjust_disgust(20)
					else
						L.adjust_disgust(10)
			M.throw_at(throw_target, 4, 3)
			M.Knockdown(2 SECONDS)

/obj/structure/overmap/verb/toggle_brakes()
	set name = "Toggle Handbrake"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_brake())
		return
	brakes = !brakes
	to_chat(usr, "<span class='notice'>You toggle the brakes [brakes ? "on" : "off"].</span>")

/obj/structure/overmap/verb/toggle_inertia()
	set name = "Toggle IAS"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_brake())
		return
	inertial_dampeners = !inertial_dampeners
	to_chat(usr, "<span class='notice'>Inertial assistance system [inertial_dampeners ? "ONLINE" : "OFFLINE"].</span>")

/obj/structure/overmap/proc/can_change_safeties()
	return (obj_flags & EMAGGED || !is_station_level(loc.z))

/obj/structure/overmap/verb/toggle_safety()
	set name = "Toggle Gun Safeties"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_change_safeties())
		return
	weapon_safety = !weapon_safety
	to_chat(usr, "<span class='notice'>You toggle [src]'s weapon safeties [weapon_safety ? "on" : "off"].</span>")

/obj/structure/overmap/verb/show_dradis()
	set name = "Show DRADIS"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !dradis)
		return
	dradis.attack_hand(usr)

/obj/structure/overmap/proc/can_brake()
	return TRUE //See fighters.dm

/obj/structure/overmap/verb/overmap_help()
	set name = "Help"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	to_chat(usr, "<span class='warning'>=Hotkeys=</span>")
	to_chat(usr, "<span class='notice'>Use the <b>scroll wheel</b> to zoom in / out.</span>")
	to_chat(usr, "<span class='notice'>Use tab to activate hotkey mode, then:</span>")
	to_chat(usr, "<span class='notice'>Press <b>space</b> to make the ship follow your mouse (or stop following your mouse).</span>")
	to_chat(usr, "<span class='notice'>Press <b>Alt<b> to engage handbrake</span>")
	to_chat(usr, "<span class='notice'>Press <b>Ctrl<b> to cycle fire modes</span>")

/obj/structure/overmap/verb/toggle_move_mode()
	set name = "Change movement mode"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	move_by_mouse = !move_by_mouse
	to_chat(usr, "<span class='notice'>You [move_by_mouse ? "activate" : "deactivate"] [src]'s laser guided movement system.</span>")
