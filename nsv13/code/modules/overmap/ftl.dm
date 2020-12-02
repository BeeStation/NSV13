#define FTL_STATE_IDLE 1
#define FTL_STATE_SPOOLING 2
#define FTL_STATE_READY 3
#define FTL_STATE_JUMPING 4

/datum/star_system/proc/add_ship(obj/structure/overmap/OM)
	system_contents += OM
	if(!occupying_z && OM.z) //Does this system have a physical existence? if not, we'll set this now so that any inbound ships jump to the same Z-level that we're on.
		occupying_z = OM.z
		if(OM.role == MAIN_OVERMAP) //As these events all happen to the main ship, let's check that it's not say, the nomi that's triggering this system load...
			try_spawn_event()
		if(fleets.len)
			for(var/datum/fleet/F in fleets)
				if(!F.current_system)
					F.current_system = src
				F.encounter(OM)
		restore_contents()
	var/turf/destination = get_turf(locate(rand(50, world.maxx), rand(50, world.maxy), occupying_z)) //Spawn them somewhere in the system. I don't really care where.
	if(!destination)
		message_admins("WARNING: The [name] system has no exit point for ships! Something has caused this Z-level to despawn erroneously, please contact Kmc immediately!.")
		return
	var/turf/exit = get_turf(pick(orange(20, destination)))
	OM.forceMove(exit)
	if(istype(OM, /obj/structure/overmap))
		OM.current_system = src //Debugging purposes only
	after_enter(OM)

/datum/star_system/proc/after_enter(obj/structure/overmap/OM)
	return

/datum/star_system/proc/try_spawn_event()
	if(possible_events && prob(event_chance))
		if(!possible_events.len)
			return FALSE
		var/event_type = pick(possible_events)
		for(var/datum/round_event_control/E in SSevents.control)
			if(istype(E, event_type))
				SSevents.TriggerEvent(E)
				break

/datum/star_system/proc/restore_contents()
	if(enemy_queue)
		for(var/X in enemy_queue)
			SSstar_system.spawn_ship(X, src)
			enemy_queue -= X
	if(!contents_positions.len)
		return //Nothing stored, no need to restore.
	for(var/atom/movable/ship in system_contents){
		if(!contents_positions[ship])
			continue
		var/list/info = contents_positions[ship]
		ship.forceMove(get_turf(locate(info["x"], info["y"], occupying_z))) //Let's unbox that ship. Nice.
		if(istype(ship, /obj/structure/overmap))
			START_PROCESSING(SSphysics_processing, ship) //And let's stop it from processing too.
			var/obj/structure/overmap/OM = ship
			if(OM.physics2d)
				START_PROCESSING(SSphysics_processing, OM.physics2d) //Respawn this ship's collider so it can start colliding once more
	}
	contents_positions = null
	contents_positions = list()

/datum/star_system/proc/remove_ship(obj/structure/overmap/OM)
	var/list/other_player_ships = list()
	for(var/atom/X in system_contents)
		if(istype(X, /obj/structure/overmap))
			var/obj/structure/overmap/ship = X
			if(ship.occupying_levels.len && ship != OM)
				other_player_ships += ship
	if(OM.reserved_z == occupying_z && other_player_ships.len) //Alright, this is our Z-level but we're jumping out of it and there are still people here.
		var/obj/structure/overmap/ship = pick(other_player_ships)
		message_admins("Swapping [OM] and [ship]'s reserved Zs, as they overlap.")
		var/temp = ship.reserved_z
		ship.reserved_z = OM.reserved_z
		OM.reserved_z = temp
		OM.forceMove(locate(OM.x, OM.y, OM.reserved_z)) //Annnd actually kick them out of the current system.
		system_contents -= OM
		return //Early return here. This means that another player ship is already holding the system, and we really don't need to double-check for this.
	else
		message_admins("Successfully removed [OM] from [src]")
		OM.forceMove(locate(OM.x, OM.y, OM.reserved_z)) //Annnd actually kick them out of the current system.
		system_contents -= OM
	for(var/atom/movable/X in system_contents)
		if(istype(X, /obj/structure/overmap))
			var/obj/structure/overmap/ship = X
			if(ship != OM && ship.occupying_levels.len) //If there's a player ship left to hold the system, early return and keep this Z loaded.
				return
			if(ship.operators.len && !ship.ai_controlled) //Alright, now we handle the small ships. If there is no longer a large ship to hold the system, we just get caught up its wake and travel along with it.
				ship.relay("<span class='warning'>You're caught in [OM]'s bluespace wake!</span>")
				SEND_SIGNAL(ship, COMSIG_FTL_STATE_CHANGE)
				ship.forceMove(locate(ship.x, ship.y, OM.reserved_z))
				system_contents -= ship
				continue
		contents_positions[X] = list("x" = X.x, "y" = X.y) //Cache the ship's position so we can regenerate it later.
		X.moveToNullspace() //Anything that's an NPC should be stored safely in nullspace until we return.
		if(istype(X, /obj/structure/overmap))
			var/obj/structure/overmap/foo = X
			STOP_PROCESSING(SSphysics_processing, X) //And let's stop it from processing too.
			if(foo.physics2d)
				STOP_PROCESSING(SSphysics_processing, foo.physics2d) //Despawn this ship's collider, to avoid wasting time figuring out if it's colliding with things or not.
	occupying_z = 0 //Alright, no ships are holding it anymore. Stop holding the Z-level

/obj/structure/overmap/proc/begin_jump(datum/star_system/target_system)
	relay(ftl_drive.ftl_start, channel=CHANNEL_IMPORTANT_SHIP_ALERT)
	desired_angle = 90 //90 degrees AKA face EAST to match the FTL parallax.
	addtimer(CALLBACK(src, .proc/jump, target_system, TRUE), ftl_drive.ftl_startup_time)

/obj/structure/overmap/proc/force_parallax_update(ftl_start)
	if(reserved_z) //Actual overmap parallax behaviour
		var/datum/space_level/SL = SSmapping.z_list[reserved_z]
		if(ftl_start)
			SL.set_parallax("transit", EAST)
		else
			SL.set_parallax(current_system.parallax_property, null)
	for(var/datum/space_level/SL in occupying_levels)
		if(ftl_start)
			SL.set_parallax("transit", EAST)
		else
			SL.set_parallax(current_system.parallax_property, null)
	for(var/mob/M in mobs_in_ship)
		if(M && M.client && M.hud_used && length(M.client.parallax_layers))
			M.hud_used.update_parallax(force=TRUE)


/obj/structure/overmap/proc/jump(datum/star_system/target_system, ftl_start) //FTL start IE, are we beginning a jump? Or ending one?
	if(ftl_start && ftl_drive?.ftl_state != FTL_STATE_JUMPING)
		return
	relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg', null, ignore_self=TRUE)//Ships just hear a small "crack" when another one jumps
	if(reserved_z) //Actual overmap parallax behaviour
		var/datum/space_level/SL = SSmapping.z_list[reserved_z]
		if(ftl_start)
			SL.set_parallax("transit", EAST)
		else
			SL.set_parallax( (current_system != null) ?  current_system.parallax_property : target_system.parallax_property, null)
	for(var/datum/space_level/SL in occupying_levels)
		if(ftl_start)
			SL.set_parallax("transit", EAST)
		else
			SL.set_parallax( (current_system != null) ?  current_system.parallax_property : target_system.parallax_property, null)
	if(ftl_start)
		relay(ftl_drive.ftl_loop, "<span class='warning'>You feel the ship lurch forward</span>", loop=TRUE, channel = CHANNEL_SHIP_ALERT)
		var/datum/star_system/curr = SSstar_system.ships[src]["current_system"]
		SEND_SIGNAL(src, COMSIG_SHIP_DEPARTED) // Let missions know we have left the system
		curr.remove_ship(src)
		var/speed = (curr.dist(target_system) / (ftl_drive.jump_speed_factor*10)) //TODO: FTL drive speed upgrades.
		SSstar_system.ships[src]["to_time"] = world.time + speed MINUTES
		SEND_SIGNAL(src, COMSIG_FTL_STATE_CHANGE)
		if(role == MAIN_OVERMAP) //Scuffed please fix
			priority_announce("Attention: All hands brace for FTL translation. Destination: [target_system]. Projected arrival time: [station_time_timestamp("hh:mm", world.time + speed MINUTES)] (Local time)","Automated announcement") //TEMP! Remove this shit when we move ruin spawns off-z
			if(structure_crit) //Tear the ship apart if theyre trying to limp away.
				for(var/i = 0, i < rand(4,8), i++)
					var/name = pick(GLOB.teleportlocs)
					var/area/target = GLOB.teleportlocs[name]
					var/turf/T = pick(get_area_turfs(target))
					new /obj/effect/temp_visual/explosion_telegraph(T)
		SSstar_system.ships[src]["target_system"] = target_system
		SSstar_system.ships[src]["from_time"] = world.time
		SSstar_system.ships[src]["current_system"] = null
		addtimer(CALLBACK(src, .proc/jump, target_system, FALSE), speed MINUTES)
		

	else
		SSstar_system.ships[src]["target_system"] = null
		SSstar_system.ships[src]["current_system"] = target_system
		SSstar_system.ships[src]["last_system"] = target_system
		SSstar_system.ships[src]["from_time"] = 0
		SSstar_system.ships[src]["to_time"] = 0
		SEND_SIGNAL(src, COMSIG_FTL_STATE_CHANGE)
		relay(ftl_drive.ftl_exit, "<span class='warning'>You feel the ship lurch to a halt</span>", loop=FALSE, channel = CHANNEL_SHIP_ALERT)
		target_system.add_ship(src) //Get the system to transfer us to its location.
		SEND_SIGNAL(src, COMSIG_SHIP_ARRIVED) // Let missions know we have arrived in the system
	for(var/mob/M in mobs_in_ship)
		if(iscarbon(M))
			var/mob/living/carbon/L = M
			if(HAS_TRAIT(L, TRAIT_SEASICK))
				to_chat(L, "<span class='warning'>You can feel your head start to swim...</span>")
				if(prob(40)) //Take a roll! First option makes you puke and feel terrible. Second one makes you feel iffy.
					L.adjust_disgust(20)
				else
					L.adjust_disgust(10)
		shake_camera(M, 4, 1)
	force_parallax_update(ftl_start)

/obj/item/ftl_slipstream_chip
	name = "Quantum slipstream field generation matrix (tier II)"
	desc = "An upgrade to the ship's FTL computer, allowing it to benefit from cutting edge calculation technologies to result in faster jump times by changing the way in which it allows the ship to incurse into bluespace."
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "quantum_slipstream"
	var/tier = 2

/obj/item/ftl_slipstream_chip/warp
	name = "Warp drive chip"
	desc = "A highly experimental chip which appears to be able to accelerate starships to ludicrous speeds without the use of bluespace. Further testing required."
	icon_state = "warpchip"
	tier = 3

/datum/design/ftl_slipstream_chip
	name = "Quantum slipstream field generation matrix"
	desc = "An upgrade for FTL drive computers which allows for much more efficient FTL translations."
	id = "ftl_slipstream_chip"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma = 25000,/datum/material/diamond = 15000, /datum/material/silver = 20000)
	build_path = /obj/item/ftl_slipstream_chip
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/ftl_slipstream
	id = "ftl_slipstream"
	display_name = "Quantum slipstream technology"
	description = "Cutting edge upgrades for the FTL drive computer, allowing for more efficient FTL travel."
	prereq_ids = list("base")
	design_ids = list("ftl_slipstream_chip")
	research_costs = list(TECHWEB_POINT_TYPE_WORMHOLE = 5000) //You need to have fully probed a wormhole to unlock this.
	export_price = 15000 //This is EXTREMELY valuable to NT because it'll let their ships go super fast.

/obj/machinery/computer/ship/ftl_computer
	name = "Seegson FTL drive computer"
	desc = "A supercomputer which is capable of calculating incalculably complex vectors which are interpreted into a simplified 4-dimensional course through which ships are able to travel. It takes some time to spool up between uses"
	icon = 'nsv13/goonstation/icons/ftlcomp.dmi'
	icon_state = "ftl_off"
	bound_height = 96
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	icon_screen = null
	icon_keyboard = null
	req_access = list(ACCESS_ENGINE_EQUIP)
	var/tier = 1
	var/faction = "nanotrasen" //For ship tracking. The tracking feature of the FTL compy is entirely so that antagonists can hunt the NT ships down
	var/jump_speed_factor = 2 //How quickly do we jump? Larger is faster.
	var/ftl_state = FTL_STATE_IDLE //Mr Gaeta, spool up the FTLs.
	var/obj/item/radio/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/engineering_channel = "Engineering"
	var/active = FALSE
	var/progress = 0 SECONDS
	var/progress_rate = 1 SECONDS
	var/spoolup_time = 45 SECONDS //Make sure this is always longer than the ftl_startup_time, or you can seriously bug the ship out with cancel jump spam.
	var/screen = 1
	var/can_cancel_jump = TRUE //Defaults to true. TODO: Make emagging disable this
	var/max_range = 30000 //max jump range. This is _very_ long distance
	var/list/tracking = list() //What ships are we tracking, if any? Used for antag FTLs so they can always find you.
	var/ftl_loop = 'nsv13/sound/effects/ship/FTL_loop.ogg'
	var/ftl_start = 'nsv13/sound/effects/ship/FTL_long.ogg'
	var/ftl_exit = 'nsv13/sound/effects/ship/freespace2/warp_close.wav'
	var/ftl_startup_time = 30 SECONDS
	var/auto_spool = FALSE //For lazy admins

/obj/machinery/computer/ship/ftl_computer/attackby(obj/item/I, mob/user) //Allows you to upgrade dradis consoles to show asteroids, as well as revealing more valuable ones.
	. = ..()
	if(istype(I, /obj/item/ftl_slipstream_chip))
		var/obj/item/ftl_slipstream_chip/FI = I
		if(FI.tier > tier)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
			to_chat(user, "<span class='notice'>You slot [I] into [src], updating its vector calculation systems.</span>")
			tier = FI.tier
			qdel(FI)
			upgrade()
		else
			to_chat(user, "<span class='notice'>[src] has already been upgraded to a higher tier than [FI] can offer.</span>")

/obj/machinery/computer/ship/ftl_computer/proc/upgrade()
	switch(tier)
		if(1)
			return
		if(2)
			name = "Quantum slipstream drive computer"
			desc = "A supercomputer using absolutely cutting edge wormhole research. It is able to project a streamlined field of constrained wormhole particles to cut through bluespace cleanly. This drive eliminates the lengthy FTL charge up process, and can see a ship jump almost instantaneously, after it generates a suitable wormhole."
			ftl_loop = 'nsv13/sound/effects/ship/slipstream.ogg'
			ftl_start = 'nsv13/sound/effects/ship/slipstream_start.ogg'
			ftl_startup_time = 6 SECONDS
			spoolup_time = 30 SECONDS
			jump_speed_factor = 3

		if(3) //Admin only so I can test things more easily, or maybe dropped from an EXTREMELY RARE, copyright free ruin.
			name = "Warp drive computer"
			desc = "A computer that is impossibly advanced for this time period. It uses unknown technology harvested by unknown means to accelerate a starship to unheard of speeds. Ardata operatives have as yet been unable to ascertain how it functions, but field testing shows that this eliminates the need for spooling entirely in favour of distorting space."
			ftl_loop = 'nsv13/sound/effects/ship/warp_loop.ogg'
			ftl_start = 'nsv13/sound/effects/ship/warp.ogg'
			ftl_exit = 'nsv13/sound/effects/ship/warp_exit.ogg'
			ftl_startup_time = 5 SECONDS
			spoolup_time = 10 SECONDS
			auto_spool = TRUE
			jump_speed_factor = 5

	max_range = initial(max_range) * 2
/*
Preset classes of FTL drive with pre-programmed behaviours
*/

/obj/machinery/computer/ship/ftl_computer/preset/Initialize()
	. = ..()
	upgrade()

/obj/machinery/computer/ship/ftl_computer/preset/slipstream
	tier = 2

/obj/machinery/computer/ship/ftl_computer/preset/warp
	tier = 3

/obj/machinery/computer/ship/ftl_computer/syndicate
	name = "Syndicate FTL computer"
//	jump_speed_factor = 2 //Twice as fast as NT's shit so they can hunt the ship down or get ahead of them to set up an ambush of raptors
	radio_key = /obj/item/encryptionkey/syndicate
	engineering_channel = "Syndicate"
	faction = "syndicate"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/ship/ftl_computer/mining
	name = "Mining FTL computer"
	radio_key = /obj/item/encryptionkey/headset_mining
	engineering_channel = "Supply"
	req_access = null
	req_one_access_txt = "31;48"

/obj/machinery/computer/ship/ftl_computer/Initialize()
	. = ..()
	start_monitoring(get_overmap()) //I'm a lazy hack that can't actually be assed to deal with an if statement in react right now.

/obj/machinery/computer/ship/ftl_computer/syndicate/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ship/ftl_computer/syndicate/LateInitialize()
	. = ..()
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.role > NORMAL_OVERMAP && OM.faction != faction)
			start_monitoring(OM)

//Tell the FTL computer to start tracking a ship, regardless of how far apart you both are.
/obj/machinery/computer/ship/ftl_computer/proc/start_monitoring(obj/structure/overmap/OM)
	tracking[OM] = list("ship" = OM, "name" = OM.name, "current_system" = OM.starting_system, "target_system" = null)
	RegisterSignal(OM, COMSIG_FTL_STATE_CHANGE, .proc/announce_jump)

/*
A way for syndies to track where the player ship is going in advance, so they can get ahead of them and hunt them down.
*/

/obj/machinery/computer/ship/ftl_computer/proc/announce_jump()
	radio.talk_into(src, "TRACKING: FTL signature detected. Tracking information updated.",engineering_channel)
	for(var/list/L in tracking)
		var/obj/structure/overmap/target = L["ship"]
		var/datum/star_system/target_system = SSstar_system.ships[target]["target_system"]
		var/datum/star_system/current_system = SSstar_system.ships[target]["current_system"]
		tracking[target] = list("name" = target.name, "current_system" = current_system.name, "target_system" = target_system.name)

/obj/machinery/computer/ship/ftl_computer/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/has_overmap), 5 SECONDS)
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/computer/ship/ftl_computer/process()
	if(!is_operational())
		depower()
		return
	if(progress < spoolup_time)
		icon_state = "ftl_charging"
		use_power = 500 //Eats up a fuckload of power as it takes 2 minutes to spool up.
		progress += progress_rate
		ftl_state = FTL_STATE_SPOOLING
		return
	else
		ready_ftl()
		use_power = 300 //Keeping the FTL spooled requires a fair bit of power
		return PROCESS_KILL

/obj/machinery/computer/ship/ftl_computer/has_overmap()
	. = ..()
	if(linked)
		linked.ftl_drive = src

/obj/machinery/computer/ship/ftl_computer/attack_hand(mob/user)
	if(!has_overmap())
		return
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/ftl_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "FTLComputer", name, 560, 350, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/ftl_computer/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!has_overmap())
		return
	playsound(src, 'nsv13/sound/effects/computer/scroll_start.ogg', 100, 1)
	switch(action)
		if("toggle_power")
			active = !active
			ftl_state = FTL_STATE_IDLE
			progress = 0
			check_active(active)
		if("show_tracking")
			screen = 2
		if("go_back")
			screen = 1
		if("jump")
			if(ftl_state != FTL_STATE_READY)
				visible_message("<span class='warning'>[icon2html(src, viewers(src))] Unable to comply. FTL vector calculation still in progress. 'Blind' FTL jumps are prohibited by the system administrative policy.</span>")
				return
			var/target_name = params["target"]
			for(var/datum/star_system/S in SSstar_system.systems)
				if(S.visitable && S.name == target_name)
					jump(S)
					check_active(FALSE)
					break

/obj/machinery/computer/ship/ftl_computer/ui_data(mob/user)
	var/list/data = list()
	data["powered"] = active
	data["progress"] = progress
	data["goal"] = spoolup_time
	data["ready"] = (ftl_state == FTL_STATE_READY) ? TRUE : FALSE
	data["mode"] = screen
	data["systems"] = list()
	var/list/ships = list()
	for(var/X in tracking)
		var/list/ship_info = list()
		ship_info["name"] = tracking[X]["name"]
		ship_info["current_system"] = tracking[X]["current_system"]
		ship_info["target_system"] = tracking[X]["target_system"]
		ships[++ships.len] = ship_info
	data["tracking"] = ships
	for(var/datum/star_system/S in SSstar_system.systems)
		if(S.visitable && S != linked.current_system)
			data["systems"] += list(list("name" = S.name, "distance" = "2 minutes"))
	return data

/obj/machinery/computer/ship/ftl_computer/proc/check_active(state)
	if(state)
		spoolup()
		START_PROCESSING(SSmachines, src)
	else
		depower()
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/computer/ship/ftl_computer/proc/jump(datum/star_system/target_system)
	if(!target_system)
		radio.talk_into(src, "ERROR. Specified star_system no longer exists.", engineering_channel)
		return
	linked?.begin_jump(target_system)
	playsound(src, 'nsv13/sound/voice/ftl_start.wav', 100, FALSE)
	radio.talk_into(src, "Initiating FTL translation.", engineering_channel)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/computer/escape.wav', 100, 1)
	visible_message("<span class='notice'>Initiating FTL jump.</span>")
	ftl_state = FTL_STATE_JUMPING
	addtimer(CALLBACK(src, .proc/depower), ftl_startup_time)

/obj/machinery/computer/ship/ftl_computer/proc/ready_ftl()
	ftl_state = FTL_STATE_READY
	progress = 0
	icon_state = "ftl_ready"
	playsound(src, 'nsv13/sound/voice/ftl_ready.wav', 100, FALSE)
	radio.talk_into(src, "FTL vectors calculated. Ready to commence FTL translation.", engineering_channel)
	playsound(src, 'nsv13/sound/effects/ship/freespace2/computer/escape.wav', 100, 1)

/obj/machinery/computer/ship/ftl_computer/proc/spoolup()
	if(ftl_state == FTL_STATE_IDLE)
		playsound(src, 'nsv13/sound/effects/computer/hum3.ogg', 100, 1)
		playsound(src, 'nsv13/sound/voice/ftl_spoolup.wav', 100, FALSE)
		radio.talk_into(src, "FTL spoolup initiated.", engineering_channel)
		icon_state = "ftl_charging"
		ftl_state = FTL_STATE_SPOOLING

/obj/machinery/computer/ship/ftl_computer/proc/cancel_ftl()
	if(depower())
		playsound(src, 'nsv13/sound/voice/ftl_cancelled.wav', 100, FALSE)
		radio.talk_into(src, "FTL translation cancelled.", engineering_channel)
		return TRUE
	return FALSE


/obj/machinery/computer/ship/ftl_computer/Initialize()
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()

/obj/machinery/computer/ship/ftl_computer/update_icon()
	return //Override computer updates

/obj/machinery/computer/ship/ftl_computer/proc/depower()
	if(ftl_state > FTL_STATE_IDLE)
		var/list/timers = active_timers
		active_timers = null
		for(var/thing in timers)
			var/datum/timedevent/timer = thing
			if (timer.spent)
				continue
			qdel(timer)
		active = FALSE
		icon_state = "ftl_off"
		ftl_state = FTL_STATE_IDLE
		progress = 0
		use_power = 0
		if(auto_spool)
			active = TRUE
			spoolup()
			START_PROCESSING(SSmachines, src)
		return TRUE
	return FALSE

/*

#define PYLON_STATE_STARTING 1
#define PYLON_STATE_WARMUP 2
#define PYLON_STATE_SPOOLING 3
#define PYLON_STATE_SHUTDOWN 4
#define CORE_MAXIMUM_CHARGE 1000

#define PYLON_STATE_OFFLINE 0

///FTL DRIVE PYLON///
/obj/machinery/atmospherics/components/unary/ftl_drive_pylon
	name = "FTL Drive Pylon"
	desc = "Words about the spinny boy"
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon"
	pixel_x = -16
	density = TRUE
	anchored = TRUE
	idle_power_usage = 250
	active_power_usage = 5000 // peak usage - this gets changed per state
	var/pylon_state = 0
	var/capacitor = 0

/obj/machinery/atmospherics/components/unary/ftl_drive_pylon/process()
	if(!on)
		return
	if(on)
		switch(pylon_state)
			if(PYLON_STATE_OFFLINE) //here we begin the startup proceedure
				active_power_usage = 250
			if(PYLON_STATE_STARTING) //pop the lid
				active_power_usage = 500
			if(PYLON_STATE_WARMUP) //start the spin
				var/datum/gas_mixture/air1 = airs[1]
				var/ftl_fuel = air1.get_moles(/datum/gas/nucleium)
				if(ftl_fuel < 0.01)
					//link chat to whichever obj we are looking at
					pylon_state = PYLON_STATE_STARTING
					update_icon()
					return
				else
					air1.adjust_moles(/datum/gas/nucleium, -0.01)
					if(prob(5))
						var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
						s.set_up(6, 0, src)
						s.start()
					update_icon()
					active_power_usage = 2000

			if(PYLON_STATE_SPOOLING) //spinning intensifies
				var/datum/gas_mixture/air1 = airs[1]
				var/ftl_fuel = air1.get_moles(/datum/gas/nucleium)
				if(ftl_fuel < 0.25)
					if(capacitor > 0)
						capacitor --
						return
					else if(capacitor <= 0)
					//link chat to whichever obj we are looking at
						pylon_state = PYLON_STATE_STARTING
						update_icon()
						return
				else
					air1.adjust_moles(/datum/gas/nucleium, -0.25)
					update_icon()
					active_power_usage = 5000
					if(capacitor < 5)
						capacitor ++
						update_icon()
						return
					else if(capacitor >= 5)
					//here is there bit where we zap the core to make it go
						return
			if(PYLON_STATE_SHUTDOWN) //halt the spinning, close the lid
				active_power_usage = 500

/obj/machinery/atmospherics/components/unary/ftl_drive_pylon/proc/handle_power_transfer()
	var/obj/machinery/power/ftl_drive_core/FDC = locate(/obj/machinery/power/ftl_drive_core in orange(4, src))
	if(FDC)
		//beam zap
		playsound(src, 'sound/weapons/emitter.ogg', 100, 1)
		FDC.capacitor_charge += 5
		if(FDC.capacitor_charge > CORE_MAXIMUM_CHARGE)
			FDC.capacitor_charge = CORE_MAXIMUM_CHARGE
		capacitor = 0
	else if(!FDC)
		tesla_zap(src, 4,  1000)


//FTL DRIVE CORE - zappy core where the FTL charge builds
/obj/machinery/power/ftl_drive_core
	name = "FTL Drive Core"
	desc = "Words about the core"
	icon = 'nsv13/icons/obj/machinery/FTL_drive.dmi'
	icon_state = "core_idle"
	pixel_x = -64
	density = TRUE
	anchored = TRUE
	var/capacitor_charge = 0
	var/decay_delay = 10
	var/decay_cycle = 0

/obj/machinery/power/ftl_drive_core/process()
	decay_cycle ++
	if(decay_cycle >=10)
		capacitor_charge -= max(round(decay_cycle / 25), 1)

//FTL DRIVE SILO - reinforced storage tank for FTL fuel
/obj/machinery/atmospherics/components/binary/ftl_drive_silo
	name = "FTL Drive Silo"
	desc = "Words about the vat"
	icon = 'nsv13/icons/obj/machinery/FTL_silo.dmi'
	icon_state = "silo"
	pixel_x = -32
	density = TRUE
	anchored = TRUE
	idle_power_usage = 50
	active_power_usage = 250
	max_integrity = 1000
	var/volume = 10000

/obj/machinery/atmospherics/components/binary/ftl_drive_silo/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.volume = volume
	update_parents()

//FTL DRIVE MANIFOLD - required for normal use - TRAITOR TARGET - should not be touched unless in epsilon protocol - starts in the floor
/obj/machinery/ftl_drive_manifold
	name = "FTL Drive Manifold"
	desc = "Words about the manifold"
	icon = 'nsv13/icons/obj/machinery/FTL_pylon.dmi'
	icon_state = "pylon"
	density = FALSE
	anchored = TRUE

#undef PYLON_STATE_OFFLINE
#undef PYLON_STATE_STARTING
#undef PYLON_STATE_WARMUP
#undef PYLON_STATE_SPOOLING
#undef PYLON_STATE_SHUTDOWN
*/
