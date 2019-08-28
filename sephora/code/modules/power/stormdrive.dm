/*

HOW 2 stormdrive?!

0: Assemble all the machines with a toolbox (they start incomplete)

1: Open valves from atmos -> magnetic constrictor.
2: Activate constrictor
3: Allow stormdrive chamber to fill with at least 100 mol of constricted plasma (absolute minimum)
3a: DO NOT LET THE REACTOR OVERFILL. It cannot start if it's loaded with more than 200 mol, meaning you have to drain it and start again.
4: When reactor is filled, activate the particle accelerator to kickstart the storm
5: (Optional) Set up rad collectors to get even more power
6: Once the reactor starts to glow, quickly shut off the injector to prevent power waste, and let the heat rise a bit.
Key: Blue = Safe, but not as many rads and less plasma is outputted
Orange = Moderate. Heat is staying steady, but producing a shitload of plasma which is ultra hot.

FTL:
FTL requires plasma that's at least 5000 degrees hot. Anything below this and it won't work.

What everything does:

Storm drive reactor:
Takes  plasma and outputs superheated plasma and a shitload of radiation.
-You can set it to """"""""""""""safe"""""""""""""" mode by leaving the control rods lowered, allowing you to basically ignore it. You'll get low amounts of plasma, and adequate power
-You can set it to "moderate" mode by half raising the control rods. This will mean that the control rods are worn down over time, but you double your power. Doing this means you have to be able to maintain it, and be able to shut the thing off to swap out its control rods. (every 30 mins)
-You can set it to "chad" mode by fucking completely raising the control rods. This will irradiate the everloving shit out of everything, but give you more plasma than you could ever possibly need EVER. This will stop the control rods from getting damaged whilst also allowing the heat to rise uncontrollably, but allow you to rapidly charge your FTL.
-Meltdowns occur when the rods are eaten away. You have about 3 minutes to correct a meltdown by performing a shutdown.
-To shut it down, you need to drain the reactor vessel of all plasma. Cut off the constrictor and its plasma supply, then let the engine burn itself out by putting it on "moderate" or "CHAD" mode for a while.
-If you fail to correct the meltdown within 3 minutes, the reactor goes nuclear and the storm escapes, annihilating everything in its path. You won't be able to step anywhere on the ship, because EVERYTHING will be irradiated.

*/

//Reactor variables

#define REACTOR_HEAT_NORMAL 100
#define REACTOR_HEAT_HOT 200
#define REACTOR_HEAT_VERYHOT 250
#define REACTOR_HEAT_MELTDOWN 500
#define REACTOR_STATE_MAINTENANCE 1
#define REACTOR_STATE_IDLE 2
#define REACTOR_STATE_RUNNING 3
#define REACTOR_STATE_MELTDOWN 4

#define RODS_RAISED 1
#define RODS_HALFRAISED 2
#define RODS_HALFLOWERED 3
#define RODS_LOWERED 4

//Constrictor construction steps

#define CONSTRICTOR_NOTBUILT 0
#define CONSTRICTOR_WRENCHED 1
#define CONSTRICTOR_SCREWED 2
#define CONSTRICTOR_WELDED 3


/obj/machinery/power/stormdrive_reactor
	name = "class IV nuclear storm drive"
	desc = "This monstrosity is what we got when nanotrasen engineers decided to inject magnetically constricted plasma into a nuclear reactor. It's able of outputting an ungodly amount of super-heated plasma, radiation, and fire... But god help you if it ever melts down."
	icon = 'sephora/goonstation/icons/reactor.dmi'
	icon_state = "reactor_off"
	pixel_x = -16
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_color = LIGHT_COLOR_CYAN
	var/obj/machinery/atmospherics/components/binary/pump/pipe
	var/start_threshold = 40 //N mol of constricted plasma to fire it up. N heat to start it up
	var/heat = 0 //How hot are we?
	var/target_heat = REACTOR_HEAT_NORMAL //For control rods. How hot do we want the reactor to get? We'll attempt to cool the reactor to this temperature.
	var/cooling_power = 10 //How much heat we can drain per tick. Matches up with target_heat
	var/control_rod_state = 3 //Rods start out to raise the heat. Position 1 is considered DANGEROUS, 2 is OK, 3 is safe, 4 is if you want to shut it off.
	var/heat_gain = 5
	var/warning_state = 0 //Are we warning people about a meltdown already? If we are, don't spam them with sounds. Also works for when it's actually exploding
	var/reaction_rate = 5 //5 constricted plasma / tick to keep the reaction going, if you shut this off, the reactor will cool.
	var/power_loss = 2 //For subtypes, if you want a less efficient reactor
	var/input_power_modifier = 1
	var/state = REACTOR_STATE_IDLE
	var/rod_integrity = 100 //Control rods take damage over time

/obj/machinery/power/stormdrive_reactor/proc/engage_maintenance()
	if(state == REACTOR_STATE_IDLE)
		deactivate()
		state = REACTOR_STATE_MAINTENANCE
		update_icon()

/obj/machinery/power/stormdrive_reactor/proc/disengage_maintenance()
	if(state == REACTOR_STATE_MAINTENANCE)
		state = REACTOR_STATE_IDLE
		icon_state = initial(icon_state)

/obj/machinery/power/stormdrive_reactor/proc/deactivate()
	icon_state = initial(icon_state)
	heat = 0
	state = REACTOR_STATE_IDLE //Force reactor restart.
	set_light(0)

/obj/structure/reactor_control_computer
	name = "Seegson model RBMK reactor control console"
	desc = "A state of the art terminal which is linked to a nuclear storm drive reactor. It has several buttons labelled 'AZ' on the keyboard."
	icon = 'sephora/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "rodconsole"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/power/stormdrive_reactor/reactor //Our parent reactor
	req_access = list(ACCESS_ENGINE_EQUIP)

/obj/structure/reactor_control_computer/Initialize()
	. = ..()
	var/atom/adjacent = locate(/obj/machinery/power/stormdrive_reactor) in get_area(src) //Locate via area
	if(adjacent && istype(adjacent, /obj/machinery/power/stormdrive_reactor))
		reactor = adjacent

/obj/structure/reactor_control_computer/attack_hand(mob/user)
	. = ..()
	if(!reactor)
		return
	if(!allowed(user))
		var/sound = pick('sephora/sound/effects/computer/error.ogg','sephora/sound/effects/computer/error2.ogg','sephora/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	var/dat
	dat += "<h2> ---Available reactor operations:--- </h2>"
	dat += "<A href='?src=\ref[src];rods_1=1'>AZ-1: Fully raise control rods</font></A><BR>"
	dat += "<A href='?src=\ref[src];rods_2=1'>AZ-2 Raise control rods to position 2</font></A><BR>"
	dat += "<A href='?src=\ref[src];rods_3=1'>AZ-3: Lower control rods to position 3</font></A><BR>"
	if(reactor.state != REACTOR_STATE_MAINTENANCE)
		dat += "<A href='?src=\ref[src];maintenance=1'>AZ-4: Initiate reactor maintenance protocols</font></A><BR>"
	else
		dat += "<A href='?src=\ref[src];maintenance=1'>AZ-4: Disengage reactor maintenance protocols</font></A><BR>"
	dat += "<A href='?src=\ref[src];rods_4=1'>AZ-5: Initiate controlled reactor shutdown (SCRAM)</font></A><BR>" //AZ5 machine broke
	dat += "<h2> ---Statistics:--- </h2>"
	dat += "<A href='?src=\ref[src];reactorplaceholder=1'> Last recorded temperature: [reactor?.heat] (°C)</A><BR>"
	dat += "<A href='?src=\ref[src];reactorplaceholder=1'> Reported control rod health: [reactor?.rod_integrity] %</A>"
	var/datum/browser/popup = new(user, "Reactor control systems", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/structure/reactor_control_computer/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(href_list["rods_1"])
		reactor?.control_rod_state = RODS_RAISED
		reactor?.update_icon()
	if(href_list["rods_2"])
		reactor?.control_rod_state = RODS_HALFRAISED
		reactor?.update_icon()
	if(href_list["rods_3"])
		reactor?.control_rod_state = RODS_HALFLOWERED
		reactor?.update_icon()
	if(href_list["rods_4"])
		reactor?.control_rod_state = RODS_LOWERED
		reactor?.update_icon()
	if(href_list["maintenance"])
		if(reactor.state == REACTOR_STATE_MAINTENANCE)
			reactor.disengage_maintenance()
			to_chat(usr, "<span class='danger'>Maintenance protocols disengaged.</span>")
			return
		if(reactor.state == REACTOR_STATE_IDLE)
			reactor.engage_maintenance()
			to_chat(usr, "<span class='danger'>Maintenance protocols engaged.</span>")
			return
		else
			to_chat(usr, "<span class='danger'>DANGER! Maintenance protocols cannot be initiated while the reactor is active</span>")
	attack_hand(usr)

/obj/machinery/power/stormdrive_reactor/proc/try_start()
	if(!pipe)
		find_pipe()
		return FALSE
	if(state == REACTOR_STATE_RUNNING || state == REACTOR_STATE_MELTDOWN || state == REACTOR_STATE_MAINTENANCE)
		return FALSE
	icon_state = "reactor_starting"
	var/datum/gas_mixture/air1 = pipe.airs[1]
	var/list/cached_gases = air1.gases
	if(cached_gases[/datum/gas/constricted_plasma])
		var/moles = cached_gases[/datum/gas/constricted_plasma][MOLES]
		if(moles >= start_threshold && heat >= start_threshold)
			cached_gases[/datum/gas/constricted_plasma][MOLES] -= start_threshold //Here, we subtract the plasma
			visible_message("<span class='danger'>[src] starts to glow an ominous blue!</span>")
			icon_state = "reactor_on"
			START_PROCESSING(SSmachines,src)
			state = REACTOR_STATE_RUNNING
			set_light(5)
			var/startup_sound = pick('sephora/sound/effects/ship/reactor/startup.ogg', 'sephora/sound/effects/ship/reactor/startup2.ogg')
			playsound(loc, startup_sound, 100)
			return TRUE
	return FALSE

/obj/machinery/power/stormdrive_reactor/proc/find_pipe()
	pipe = locate(/obj/machinery/atmospherics/components/binary/pump) in get_turf(src)

/obj/machinery/power/stormdrive_reactor/proc/check_meltdown_warning()
	if(warning_state >= 1)
		if(heat <= REACTOR_HEAT_VERYHOT) //This implies that we've now stopped melting down.
			get_overmap()?.stop_relay(CHANNEL_REACTOR_ALERT)
			warning_state = 0
		return FALSE
	if(heat >= REACTOR_HEAT_VERYHOT)
		warning_state = 1
		var/sound = 'sephora/sound/effects/ship/reactor/core_overheating.ogg'
		get_overmap()?.relay(sound, null, loop=TRUE, channel = CHANNEL_REACTOR_ALERT)
		return TRUE

/obj/machinery/power/stormdrive_reactor/proc/lazy_startup() //Admin only command to instantly start a reactor
	if(!pipe)
		find_pipe()
	heat = start_threshold+10
	var/datum/gas_mixture/air1 = pipe.airs[1]
	air1.assert_gas(/datum/gas/constricted_plasma) //Yeet some plasma into the pipe so it can run for a while
	air1.gases[/datum/gas/constricted_plasma][MOLES] += 300
	try_start()

/obj/machinery/power/stormdrive_reactor/proc/start_meltdown()
	if(warning_state >= 2)
		return
	warning_state = 2
	var/sound = 'sephora/sound/effects/ship/reactor/meltdown.ogg'
	addtimer(CALLBACK(src, .proc/meltdown), 18 SECONDS)
	get_overmap()?.relay(sound, null, loop=FALSE, channel = CHANNEL_REACTOR_ALERT)

/obj/machinery/power/stormdrive_reactor/proc/meltdown()
	if(heat >= REACTOR_HEAT_MELTDOWN)
		state = REACTOR_STATE_MELTDOWN
		var/sound = 'sephora/sound/effects/ship/reactor/explode.ogg'
		get_overmap()?.relay(sound, null, loop=FALSE, channel = CHANNEL_REACTOR_ALERT)
		cut_overlays()
		flick("meltdown", src)
		do_meltdown_effects()
		sleep(10)
		icon_state = "broken"
	else
		warning_state = 0

/obj/machinery/power/stormdrive_reactor/proc/do_meltdown_effects()
	explosion(get_turf(src), 5, 10, 19, 10, TRUE, TRUE)
	if(get_overmap().main_overmap) //Irradiate the shit out of the player ship
		SSweather.run_weather("nuclear fallout")
	for(var/X in GLOB.landmarks_list)
		if(istype(X, /obj/effect/landmark/nuclear_waste_spawner))
			var/obj/effect/landmark/nuclear_waste_spawner/WS = X
			if(shares_overmap(src, WS)) //If the spawner's overmap ship is the same as ours, LET LOOSE THE SLUDGE
				spawn(0)
					WS.fire()
	for(var/a in GLOB.apcs_list)
		var/obj/machinery/power/apc/A = a
		if(shares_overmap(src, a) && prob(70)) //Are they on our ship?
			A.overload_lighting()

/obj/machinery/power/stormdrive_reactor/update_icon()
	if(state == REACTOR_STATE_MELTDOWN)
		icon_state = "broken"
		return
	cut_overlays()
	add_overlay("rods_[control_rod_state]")
	if(state == REACTOR_STATE_MAINTENANCE)
		icon_state = "reactor_maintenance" //If we're in maint, don't make it appear hot.
		return
	if(state == REACTOR_STATE_RUNNING)
		icon_state = "reactor_on" //Default to being on.
		check_meltdown_warning()
		switch(heat)
			if(0 to REACTOR_HEAT_NORMAL)
				icon_state = "reactor_on"
				light_color = LIGHT_COLOR_CYAN
			if(REACTOR_HEAT_NORMAL+10 to REACTOR_HEAT_VERYHOT)
				icon_state = "reactor_hot"
			if(REACTOR_HEAT_VERYHOT to REACTOR_HEAT_MELTDOWN) //Final warning
				icon_state = "reactor_overheat"
				light_color = LIGHT_COLOR_RED
			if(REACTOR_HEAT_MELTDOWN to INFINITY)
				icon_state = "reactor_overheat"
				light_color = LIGHT_COLOR_RED
				start_meltdown() //you're gigafucked

/obj/machinery/power/stormdrive_reactor/process()
	if(state == REACTOR_STATE_MELTDOWN)
		radiation_pulse(src, 1000, 10)
		return
	if(state != REACTOR_STATE_RUNNING || heat <= start_threshold)
		deactivate()
		return ..() //Stop processing if we're not activated, start processing when we're activated.
	if(!pipe)
		find_pipe()
		return
	var/datum/gas_mixture/air1 = pipe.airs[1]
	var/list/cached_gases = air1.gases
	if(cached_gases[/datum/gas/constricted_plasma])
		var/moles = cached_gases[/datum/gas/constricted_plasma][MOLES]
		if(moles >= reaction_rate)
			cached_gases[/datum/gas/constricted_plasma][MOLES] -= reaction_rate //Here, we subtract the plasma
			heat_gain = reaction_rate
		else
			heat_gain = -5 //No plasma to react, so the reaction slowly dies off.
	input_power_modifier = heat/100 //"Safe" mode gives a power mod of "1". Run it hotter for more power and stop being such a bitch.
	var/base_power = 1000000 //A starting point. By default, on super safe mode, the reactor gives 1 MW per tick
	var/power_produced = powernet ? base_power / power_loss : base_power
	add_avail(power_produced*input_power_modifier)
	handle_heat()
	update_icon()
	radiation_pulse(src, heat, 2)

/obj/machinery/power/stormdrive_reactor/proc/can_cool()
	return TRUE //TODO: Check control rod health

/obj/machinery/power/stormdrive_reactor/proc/handle_heat()
	heat += heat_gain
	switch(control_rod_state)
		if(RODS_RAISED)
			target_heat = REACTOR_HEAT_MELTDOWN*2
		if(RODS_HALFRAISED)
			target_heat = REACTOR_HEAT_HOT
		if(RODS_HALFLOWERED)
			target_heat = REACTOR_HEAT_NORMAL
		if(RODS_LOWERED)
			target_heat = 0
	if(heat > target_heat+(cooling_power-heat_gain)) //If it's hotter than the desired temperature, + our cooling power, we need to cool it off.
		if(can_cool())
			heat -= cooling_power

/obj/machinery/power/magnetic_constrictor //This heats the plasma up to acceptable levels for use in the reactor.
	name = "magnetic constrictor"
	desc = "A large magnet which is capable of pressurizing plasma into a more energetic state. It is able to self-regulate its plasma input valve, as long as plasma is supplied to it."
	icon = 'sephora/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "constrictor_assembly"
	density = TRUE
	anchored = FALSE
	var/obj/machinery/atmospherics/components/binary/pump/inlet
	var/state = CONSTRICTOR_NOTBUILT
	var/on = FALSE //Active?

/obj/machinery/power/magnetic_constrictor/attack_hand(mob/user)
	. = ..()
	if(state != CONSTRICTOR_WELDED)
		to_chat(user, "<span class='notice'>[src] isn't finished yet!</span>")
		return ..()
	to_chat(user, "<span class='notice'>You press [src]'s power button.</span>")
	on = !on

/obj/machinery/power/magnetic_constrictor/Initialize()
	. = ..()
	find_pipes()

/obj/machinery/power/magnetic_constrictor/proc/find_pipes()
	inlet = locate(/obj/machinery/atmospherics/components/binary/pump) in get_turf(src) //Look for the inlet in our turf

/obj/machinery/power/magnetic_constrictor/process()
	if(state != CONSTRICTOR_WELDED)
		return ..() //Kill the process if it's not built yet.
	if(!on)
		icon_state = "constrictor"
		return
	if(!inlet || inlet?.loc != get_turf(src))
		inlet = null //If not inlet, or inlet's not in our turf, abort.
		icon_state = initial(icon_state)
		find_pipes()
		return
	update_icon()
	var/datum/gas_mixture/air1 = inlet.airs[1]
	var/list/cached_gases = air1.gases
	if(cached_gases[/datum/gas/plasma])
		var/moles = cached_gases[/datum/gas/plasma][MOLES]
		if(moles >= 0)
			air1.assert_gas(/datum/gas/constricted_plasma) //Add some constricted plasma
			air1.gases[/datum/gas/constricted_plasma][MOLES] += moles //Transfer the plasma into constricted plasma.
			cached_gases[/datum/gas/plasma][MOLES] = 0 //Here, we subtract the plasma
			air1.garbage_collect()

/datum/gas/constricted_plasma
	id = "constricted_plasma"
	specific_heat = 700
	name = "Constricted plasma"
	gas_overlay = "constricted_plasma"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 1000

/obj/machinery/portable_atmospherics/canister/constricted_plasma
	name = "constricted plasma canister"
	desc = "Highly volatile plasma which has been magnetically constricted. The fuel which nuclear storm drives run off of."
	icon_state = "orange"
	gas_type = /datum/gas/constricted_plasma

/obj/machinery/power/magnetic_constrictor/examine(mob/user) //No better guide than an in-game play-by-play guide
	. = ..()
	switch(state)
		if(CONSTRICTOR_NOTBUILT)
			. += "<span class='notice'>The device lies in pieces on the ground, it must be assembled and the bolts wrenched to secure it into place.</span>"
		if(CONSTRICTOR_WRENCHED)
			. += "<span class='notice'>The devices internal wire harnesses must be connected and screwed into place. You could also use a crowbar to dismantle it.</span>"
		if(CONSTRICTOR_SCREWED)
			. += "<span class='notice'>Per specifications, the maintenance hatches must be welded shut, normally this device is not tampered with once assembled.</span>"
		if(CONSTRICTOR_WELDED)
			. += "<span class='notice'>You can use a welder to open the device to begin disassembly, or to access its securing bolts.</span>"

/obj/machinery/power/magnetic_constrictor/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(CONSTRICTOR_NOTBUILT)
			to_chat(user, "<span class='notice'>You start assembly on [src], securing its components into place with bolts...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You complete initial assembly on [src]. </span>")
				anchored = TRUE
				state = CONSTRICTOR_WRENCHED
				update_icon()
			return TRUE
		if(CONSTRICTOR_WRENCHED to CONSTRICTOR_SCREWED)
			return default_unfasten_wrench(user, tool, 20)

/obj/machinery/power/magnetic_constrictor/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	if(state == CONSTRICTOR_WRENCHED)
		to_chat(user, "<span class='notice'>You start to disassemble [src] into sheets of metal...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You complete disassembly on [src]. </span>")
			var/obj/item/stack/sheet/metal/M = new (loc, 15)
			M.add_fingerprint(user)
			qdel(src)
		return TRUE

/obj/machinery/power/magnetic_constrictor/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(CONSTRICTOR_WRENCHED)
			to_chat(user, "<span class='notice'>You start running wires and securing wire harnesses on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You have assembled the wiring on [src]. </span>")
				state = CONSTRICTOR_SCREWED
				update_icon()
			return TRUE
		if(CONSTRICTOR_SCREWED)
			to_chat(user, "<span class='notice'>You start unsecuring wiring harnesses and re-coiling wires on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You undo the wiring of [src]. </span>")
				state = CONSTRICTOR_WRENCHED
				update_icon()
			return TRUE

/obj/machinery/power/magnetic_constrictor/welder_act(mob/user, obj/item/tool)
	. = FALSE
	switch(state)
		if(CONSTRICTOR_SCREWED)
			to_chat(user, "<span class='notice'>You start securing the maintenance hatches on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure the maintenance hatches on [src].</span>")
				state = CONSTRICTOR_WELDED
				update_icon()
				START_PROCESSING(SSmachines,src) //Start processing once it's built. If it doesn't have the required components, it shuts off.
			return TRUE
		if(CONSTRICTOR_WELDED)
			to_chat(user, "<span class='notice'>You start unwelding the maintenance hatches on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'You unweld the maintenance hatches on [src], exposing its anchoring bolts.</span>")
				state = CONSTRICTOR_SCREWED
				update_icon()
			return TRUE

/obj/machinery/power/magnetic_constrictor/update_icon()
	cut_overlays()
	switch(state)
		if(CONSTRICTOR_NOTBUILT)
			icon_state = "constrictor_assembly"
		if(CONSTRICTOR_WRENCHED)
			icon_state = "constrictor_wrench"
		if(CONSTRICTOR_SCREWED)
			icon_state = "constrictor_screw"
		if(CONSTRICTOR_WELDED)
			if(on)
				icon_state = "constrictor_active"
			else
				icon_state = "constrictor"


/obj/effect/decal/nuclear_waste
	name = "Plutonium sludge"
	desc = "A writhing pool of heavily irradiated, spent reactor fuel. You probably shouldn't step through this..."
	icon = 'sephora/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "nuclearwaste"
	alpha = 150

/obj/effect/decal/nuclear_waste/epicenter //The one that actually does the irradiating. This is to avoid every bit of sludge PROCESSING
	name = "Dense nuclear sludge"

/obj/effect/landmark/nuclear_waste_spawner //Clean way of spawning nuclear gunk after a reactor core meltdown.
	name = "Nuclear waste spawner"
	var/range = 5 //5 tile radius to spawn goop

/obj/effect/landmark/nuclear_waste_spawner/strong
	range = 10

/obj/effect/landmark/nuclear_waste_spawner/proc/fire()
	playsound(loc, 'sound/effects/gib_step.ogg', 100)
	new /obj/effect/decal/nuclear_waste/epicenter(get_turf(src))
	for(var/X in orange(range, get_turf(src)))
		if(istype(X, /turf/open/floor))
			var/turf/T = X
			new /obj/effect/decal/nuclear_waste (get_turf(T))
	qdel(src)

/obj/effect/decal/nuclear_waste/epicenter/Initialize()
	. = ..()
	AddComponent(/datum/component/radioactive, 1500, src, 0)

/obj/effect/decal/nuclear_waste/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		playsound(loc, 'sound/effects/gib_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 20 : 50, 1)
	radiation_pulse(src, 500, 5) //MORE RADS

/datum/weather/nuclear_fallout
	name = "nuclear fallout"
	desc = "Irradiated dust falls down everywhere."
	telegraph_duration = 50
	telegraph_message = "<span class='boldwarning'>The air suddenly becomes dusty..</span>"
	weather_message = "<span class='userdanger'><i>You feel a wave of hot ash fall down on you.</i></span>"
	weather_overlay = "fallout"
	telegraph_overlay = "fallout"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"
	telegraph_sound = null
	weather_sound = 'sephora/sound/effects/ship/reactor/falloutwind.ogg'
	end_duration = 100
	area_type = /area
	protected_areas = list(/area/maintenance, /area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai, /area/storage/emergency/starboard, /area/storage/emergency/port, /area/shuttle)
	target_trait = ZTRAIT_STATION
	end_message = "<span class='notice'>The ash stops falling.</span>"
	immunity_type = "rad"

/datum/weather/nuclear_fallout/weather_act(mob/living/L)
	L.rad_act(100)

/datum/weather/nuclear_fallout/telegraph()
	..()
	status_alarm(TRUE)

/datum/weather/nuclear_fallout/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return

	var/datum/signal/signal = new
	if (active)
		signal.data["command"] = "alert"
		signal.data["picture_state"] = "radiation"
	else
		signal.data["command"] = "shuttle"

	var/atom/movable/virtualspeaker/virt = new(null)
	frequency.post_signal(virt, signal)

/datum/weather/nuclear_fallout/end()
	if(..())
		return
	status_alarm(FALSE)


#undef CONSTRICTOR_NOTBUILT
#undef CONSTRICTOR_WRENCHED
#undef CONSTRICTOR_SCREWED
#undef CONSTRICTOR_WELDED
#undef REACTOR_HEAT_NORMAL
#undef REACTOR_HEAT_HOT
#undef REACTOR_HEAT_VERYHOT
#undef REACTOR_HEAT_MELTDOWN
#undef REACTOR_STATE_MAINTENANCE
#undef REACTOR_STATE_IDLE
#undef REACTOR_STATE_RUNNING
#undef REACTOR_STATE_MELTDOWN
#undef RODS_RAISED
#undef RODS_HALFRAISED
#undef RODS_HALFLOWERED
#undef RODS_LOWERED