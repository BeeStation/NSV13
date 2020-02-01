/*

HOW 2 stormdrive?!

0: Assemble all the machines with a toolbox (they start incomplete)

1: Open valves from atmos -> magnetic constrictor.
2: Activate constrictor
3: Turn on all the pumps
4: When reactor is filled, activate the particle accelerator to kickstart the storm
5: Open reactor release valve via the reactor console
5a: (Optional) Set up rad collectors to get even more power
6: Once the reactor starts to glow, quickly shut off the PA to prevent power waste. Alternatively, use the PA to micromanage power production but I won't tell you how to do that here :^)
7: Set the rods to position 2 if you want optimal power, but you can leave them on default if you don't want to swap out the rods at all.
Key: Blue = Safe, but not as many rads and less plasma is outputted
Orange = Moderate. Heat is staying steady, but producing a shitload of plasma which is ultra hot.

FTL:
FTL requires plasma that's at least 5000 degrees hot. Anything below this and it won't work.

What everything does:

Storm drive reactor: - Most of this is now outdated. KS~
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

#define WARNING_STATE_NONE 0
#define WARNING_STATE_OVERHEAT 1
#define WARNING_STATE_MELTDOWN 2

//////Stormdrive///////

/obj/machinery/power/stormdrive_reactor
	name = "class IV nuclear storm drive"
	desc = "This monstrosity is what we got when nanotrasen engineers decided to inject magnetically constricted plasma into a nuclear reactor. It's able of outputting an ungodly amount of super-heated plasma, radiation, and fire... But god help you if it ever melts down."
	icon = 'nsv13/goonstation/icons/reactor.dmi'
	icon_state = "reactor_off"
	pixel_x = -16
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_color = LIGHT_COLOR_CYAN
	var/obj/machinery/atmospherics/components/binary/pump/pipe
	var/start_threshold = 20 //N mol of constricted plasma to fire it up. N heat to start it up
	var/heat = 0 //How hot are we? In Celcius
	var/target_heat = REACTOR_HEAT_NORMAL //For control rods. How hot do we want the reactor to get? We'll attempt to cool the reactor to this temperature.
	var/cooling_power = 10 //How much heat we can drain per tick. Matches up with target_heat
	var/control_rod_percent = 100 //Handles the insertion depth of the control rods into the reactor
	var/heat_gain = 5
	var/warning_state = WARNING_STATE_NONE //Are we warning people about a meltdown already? If we are, don't spam them with sounds. Also works for when it's actually exploding
	var/reaction_rate = 0 //N mol of constricted plasma / tick to keep the reaction going, if you shut this off, the reactor will cool.
	var/target_reaction_rate = 0
	var/delta_reaction_rate = 0
	var/power_loss = 2 //For subtypes, if you want a less efficient reactor
	var/input_power_modifier = 1
	var/state = REACTOR_STATE_IDLE
	var/rod_integrity = 100 //Control rods take damage over time
	var/obj/item/radio/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/engineering_channel = "Engineering"
	var/can_alert = TRUE //Prevents spamming up the radio channels.
	var/alert_cooldown = 20 SECONDS
	var/last_power_produced = 0 //For UI tracking. Shows your power output.
	var/theoretical_maximum_power = 100000 //Placeholder.


/obj/machinery/power/stormdrive_reactor/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sheet/plasteel) && user.a_intent != INTENT_HARM)
		if(state != REACTOR_STATE_MAINTENANCE)
			to_chat(user, "<span class='danger'>[src] is not in maintenance mode! opening the lid on an active nuclear reaction would probably be fatal...</span>")
			return FALSE
		var/obj/item/stack/sheet/S = I
		var/repair_power = 10 //10 rod integrity per 1 sheet of plasteel.
		if(rod_integrity >= 100)
			to_chat(user, "<span class='notice'>[src]'s control rods wouldn't benefit from any additional lining right now.</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to line [src]'s control rods with a reinforced plasteel sheathe...</span>")
		if(do_after(user,50, target = src))
			rod_integrity += min(repair_power, 100-rod_integrity)
			S.use(1)
			to_chat(user,"<span class='notice'>You reinforce [src]'s control rods.</span>")
			if(rod_integrity == 100)
				to_chat(user,"<span class='notice'>[src]'s control rods are fully lined.</span>")
			return TRUE
	. = ..()

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
	if(state == REACTOR_STATE_RUNNING)
		send_alert("Fission reaction terminated. Reactor now off-line.")
	icon_state = initial(icon_state)
	heat = 0
	last_power_produced = 0 //Update UI to show that it's not making power now
	reaction_rate = 0
	state = REACTOR_STATE_IDLE //Force reactor restart.
	set_light(0)
	var/area/AR = get_area(src)
	AR.looping_ambience = 'nsv13/sound/ambience/shipambience.ogg'

/obj/machinery/power/stormdrive_reactor/Initialize()
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()
	find_pipe()

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
			heat = start_threshold+10 //Avoids it getting heated up to 10000 by the PA, then turning it on, then getting insta meltdown.
			cached_gases[/datum/gas/constricted_plasma][MOLES] -= start_threshold //Here, we subtract the plasma
			visible_message("<span class='danger'>[src] starts to glow an ominous blue!</span>")
			icon_state = "reactor_on"
			START_PROCESSING(SSmachines,src)
			state = REACTOR_STATE_RUNNING
			set_light(5)
			var/startup_sound = pick('nsv13/sound/effects/ship/reactor/startup.ogg', 'nsv13/sound/effects/ship/reactor/startup2.ogg')
			playsound(loc, startup_sound, 100)
			send_alert("Fission reaction initiated. Reactor now on-line.", override=TRUE)
			var/area/AR = get_area(src)
			AR.looping_ambience = 'nsv13/sound/ambience/engineering.ogg'
			return TRUE
	return FALSE

/obj/machinery/power/stormdrive_reactor/proc/find_pipe()
	pipe = locate(/obj/machinery/atmospherics/components/binary/pump) in get_turf(src)

/obj/machinery/power/stormdrive_reactor/proc/check_meltdown_warning()
	if(warning_state >= WARNING_STATE_OVERHEAT)
		if(heat <= REACTOR_HEAT_VERYHOT) //This implies that we've now stopped melting down.
			var/obj/structure/overmap/OM = get_overmap()
			OM?.stop_relay(CHANNEL_REACTOR_ALERT)
			warning_state = 0
			send_alert("Nuclear meltdown averted. Manual reactor inspection is strongly advised", override=TRUE)
		return FALSE
	if(heat >= REACTOR_HEAT_VERYHOT)
		send_alert("DANGER: Reactor core overheating. Nuclear meltdown imminent", override=TRUE)
		warning_state = WARNING_STATE_OVERHEAT
		var/sound = 'nsv13/sound/effects/ship/reactor/core_overheating.ogg'
		var/obj/structure/overmap/OM = get_overmap()
		OM?.relay(sound, null, loop=TRUE, channel = CHANNEL_REACTOR_ALERT)
		return TRUE

/obj/machinery/power/stormdrive_reactor/proc/lazy_startup() //Admin only command to instantly start a reactor
	if(!pipe)
		find_pipe()
	heat = start_threshold+10
	var/datum/gas_mixture/air1 = pipe.airs[1]
	air1.assert_gas(/datum/gas/constricted_plasma) //Yeet some plasma into the pipe so it can run for a while
	air1.gases[/datum/gas/constricted_plasma][MOLES] += 300
	try_start()

/obj/machinery/power/stormdrive_reactor/proc/juice_up(var/juice) //Admin command to add a specified amount of CPlas to the drive
	var/datum/gas_mixture/air1 = pipe.airs[1]
	air1.assert_gas(/datum/gas/constricted_plasma)
	air1.gases[/datum/gas/constricted_plasma][MOLES] += juice

/obj/machinery/power/stormdrive_reactor/proc/start_meltdown()
	if(warning_state >= WARNING_STATE_MELTDOWN)
		return
	rod_integrity = 0 //Burn through the control rods if we haven't already.
	send_alert("ERROR IN MODULE FISSREAC0 AT ADDRESS 0x12DF. CONTROL RODS HAVE FAILED. IMMEDIATE INTERVENTION REQUIRED.", override=TRUE)
	warning_state = WARNING_STATE_MELTDOWN
	var/sound = 'nsv13/sound/effects/ship/reactor/meltdown.ogg'
	addtimer(CALLBACK(src, .proc/meltdown), 18 SECONDS)
	var/obj/structure/overmap/OM = get_overmap()
	OM?.relay(sound, null, loop=FALSE, channel = CHANNEL_REACTOR_ALERT)

/obj/machinery/power/stormdrive_reactor/proc/meltdown()
	if(heat >= REACTOR_HEAT_MELTDOWN)
		state = REACTOR_STATE_MELTDOWN
		var/sound = 'nsv13/sound/effects/ship/reactor/explode.ogg'
		var/obj/structure/overmap/OM = get_overmap()
		OM?.relay(sound, null, loop=FALSE, channel = CHANNEL_REACTOR_ALERT)
		cut_overlays()
		flick("meltdown", src)
		do_meltdown_effects()
		sleep(10)
		icon_state = "broken"
	else
		warning_state = WARNING_STATE_NONE

/obj/machinery/power/stormdrive_reactor/proc/do_meltdown_effects()
	explosion(get_turf(src), 5, 10, 19, 10, TRUE, TRUE)
	var/obj/structure/overmap/OM = get_overmap()
	if(OM?.main_overmap) //Irradiate the shit out of the player ship
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
	if(can_cool()) //If control rods aren't destroyed.
		switch(round(control_rod_percent))
			if(0 to 24)
				add_overlay("rods_1")
			if(25 to 49)
				add_overlay("rods_2")
			if(50 to 74)
				add_overlay("rods_3")
			if(75 to 100)
				add_overlay("rods_4")
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
				set_light(5)
			if(REACTOR_HEAT_NORMAL+10 to REACTOR_HEAT_VERYHOT)
				icon_state = "reactor_hot"
			if(REACTOR_HEAT_VERYHOT to REACTOR_HEAT_MELTDOWN) //Final warning
				icon_state = "reactor_overheat"
				light_color = LIGHT_COLOR_RED
				set_light(5)
			if(REACTOR_HEAT_MELTDOWN to INFINITY)
				icon_state = "reactor_overheat"
				light_color = LIGHT_COLOR_RED
				set_light(5)
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
	if(cached_gases[/datum/gas/plasma] && heat >= REACTOR_HEAT_HOT)
		cached_gases[/datum/gas/plasma][MOLES] -= reaction_rate*2 //If there's any plasma in the reactor, burn it off if theyre running the reactor hot. If it's too cold, the reaction gets poisoned by the plasma as constricted plasma can't fill up the chamber.
		air1.garbage_collect()
	if(cached_gases[/datum/gas/constricted_plasma])
		var/moles = cached_gases[/datum/gas/constricted_plasma][MOLES]
		if(moles >= reaction_rate)
			cached_gases[/datum/gas/constricted_plasma][MOLES] -= reaction_rate //Here, we subtract the plasma
			heat_gain = initial(heat_gain)+reaction_rate
			air1.garbage_collect()
		else
			heat_gain = -5 //No plasma to react, so the reaction slowly dies off.
			radiation_pulse(src, 10, 10) //reaction bleedoff
			if(prob(10))
				grav_pull()
				playsound(loc, 'sound/effects/empulse.ogg', 100)
				for(var/mob/living/M in view(10, src))
					to_chat(M, "<span class='danger'>The reactor hungers!</span>")
					shake_camera(M, 2, 1)
			else if(prob(5))
				var/growl = pick('sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg', 'sound/hallucinations/growl3.ogg')
				playsound(loc, growl, 100)
				for(var/mob/living/M in view(10, src))
					to_chat(M, "<span class='danger'>The reactor growls!</span>")
					shake_camera(M, 2, 1)
					M.hallucination += 30
	input_power_modifier = (heat/150)**3
	var/base_power = 1000000
	var/power_produced = base_power
	last_power_produced = power_produced*input_power_modifier
	theoretical_maximum_power = power_produced*(REACTOR_HEAT_VERYHOT/100) //Used to show your power output vs peak power output in the UI.
	add_avail(last_power_produced)
	handle_reaction_rate()
	handle_heat()
	update_icon()
	radiation_pulse(src, heat, 2)
	ambient_temp_bleed()

/obj/machinery/power/stormdrive_reactor/proc/grav_pull() //HUNGRY!
	for(var/obj/O in orange(6, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in orange(6, src))
		if(!M.mob_negates_gravity())
			step_towards(M,src)
			M.Knockdown(40) //Knockdown prey so it can't get away!

/obj/machinery/power/stormdrive_reactor/proc/ambient_temp_bleed()
	var/turf/open/L = get_turf(src)
	if(!istype(L) || !(L.air))
		return
	var/datum/gas_mixture/env = L.return_air()
	var/heat_kelvin = heat + 273.15
	if(env.temperature <= heat_kelvin)
		var/delta_env = heat_kelvin - env.temperature
		env.temperature += delta_env / 2
		air_update_turf()

/obj/machinery/power/stormdrive_reactor/proc/can_cool()
	if(heat > REACTOR_HEAT_NORMAL+10) //Only start melting the rods if theyre running it hot. We have a "safe" mode which doesn't need you to check in on the reactor at all.
		rod_integrity -= input_power_modifier/60 //Assuming youre running it at hot, rods will melt every 30 minutes.
		if(rod_integrity < 0)
			rod_integrity = 0
			send_alert("DANGER: Primary control rods have failed!")
			message_admins("Stormdrive control rods are at 0% integrity.")
			return FALSE
		if(rod_integrity <= 10 && warning_state <= WARNING_STATE_NONE) //If there isn't a more important thing to notify them about, engineers should be told that their rods are failing.
			send_alert("WARNING: Reactor control rods failing at [rod_integrity]% integrity, intervention required to avoid possible meltdown.")
	if(rod_integrity > 0)
		return TRUE //TODO: Check control rod health
	else
		return FALSE

/obj/machinery/power/stormdrive_reactor/proc/handle_heat()
	heat += heat_gain
	target_heat = (-1)+2**(0.1*(100-control_rod_percent)) //Let there be math
	if(heat > target_heat+(cooling_power-heat_gain)) //If it's hotter than the desired temperature, + our cooling power, we need to cool it off.
		if(can_cool())
			heat -= cooling_power

/obj/machinery/power/stormdrive_reactor/proc/handle_reaction_rate()
	target_reaction_rate = 0.5+(1e-03*(100-control_rod_percent)**2) + 1e-05*(heat**2) //let the train derail!
	delta_reaction_rate = target_reaction_rate - reaction_rate
	reaction_rate += delta_reaction_rate/2

/obj/machinery/power/stormdrive_reactor/proc/send_alert(message, override=FALSE)
	if(!message)
		return
	if(can_alert || override) //We have an override to ignore continuous alerts like control rod reports in favour of screaming that the reactor is about to go nuclear.
		can_alert = FALSE
		radio.talk_into(src, message, engineering_channel)
		addtimer(VARSET_CALLBACK(src, can_alert, TRUE), alert_cooldown)

//////Reactor Computer//////

/obj/machinery/computer/ship/reactor_control_computer
	name = "Seegson model RBMK reactor control console"
	desc = "A state of the art terminal which is linked to a nuclear storm drive reactor. It has several buttons labelled 'AZ' on the keyboard."
	icon = 'nsv13/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "rodconsole"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/computer/stormdrive_reactor_control
	var/obj/machinery/power/stormdrive_reactor/reactor //Our parent reactor
	req_access = list(ACCESS_ENGINE_EQUIP)

/obj/machinery/computer/ship/reactor_control_computer/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/reactor_control_computer/attack_ai(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/ship/reactor_control_computer/attack_robot(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/ship/reactor_control_computer/Initialize()
	. = ..()
	var/atom/adjacent = locate(/obj/machinery/power/stormdrive_reactor) in get_area(src) //Locate via area
	if(adjacent && istype(adjacent, /obj/machinery/power/stormdrive_reactor))
		reactor = adjacent

/obj/machinery/computer/ship/reactor_control_computer/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!in_range(src, usr) || !reactor) //Topic check
		return
	if(!reactor.pipe)
		reactor.find_pipe()
	var/tune = params["tune"]
	var/adjust = text2num(params["adjust"])
	if(action == "control_rod_percent")
		if(tune == "input")
			var/min = 0
			var/max = 100
			tune = input("Tune control rod insertion percentage: ([min]-[max]):", name, reactor.control_rod_percent) as num
			if(tune > 100)
				tune = 100
			if(tune <0)
				tune = 0
			reactor.control_rod_percent = tune
		if(adjust && isnum(adjust))
			if(reactor.control_rod_percent >= 100)
				reactor.control_rod_percent = 100
				return
			if(reactor.control_rod_percent <= 0)
				reactor.control_rod_percent = 0
				return
			reactor.control_rod_percent += adjust
	switch(action)
		if("rods_1")
			reactor.control_rod_percent = 0
			message_admins("[key_name(usr)] has fully raised reactor control rods in [get_area(usr)] [ADMIN_JMP(usr)]")
			reactor.update_icon()
		if("rods_2")
			reactor.control_rod_percent = 25
			reactor.update_icon()
		if("rods_3")
			reactor.control_rod_percent = 33.6 //Safe mode?
			reactor.update_icon()
		if("rods_4")
			reactor.control_rod_percent = 75
			reactor.update_icon()
		if("rods_5")
			reactor.control_rod_percent = 100
			reactor.update_icon()
			to_chat(usr, "<span class='danger'>SCRAM protocols engaged. Attempting reactor shutdown!</span>")
		if("maintenance")
			if(reactor.state == REACTOR_STATE_MAINTENANCE)
				reactor.disengage_maintenance()
				to_chat(usr, "<span class='danger'>Maintenance protocols disengaged.</span>")
				attack_hand(usr)
				return
			if(reactor.state == REACTOR_STATE_IDLE)
				reactor.engage_maintenance()
				to_chat(usr, "<span class='danger'>Maintenance protocols engaged.</span>")
				attack_hand(usr)
				return
			else
				to_chat(usr, "<span class='danger'>DANGER! Maintenance protocols cannot be initiated while the reactor is active</span>")
		if("pipe")
			if(reactor.pipe?.on)
				reactor.pipe?.on = FALSE
				reactor.pipe?.target_pressure = ONE_ATMOSPHERE
				reactor.pipe?.update_icon()
				to_chat(usr, "<span class='notice'>Reactor outlet gate disengaged.</span>")
				attack_hand(usr)
				return
			else
				reactor.pipe?.on = TRUE
				reactor.pipe?.target_pressure = MAX_OUTPUT_PRESSURE
				reactor.pipe?.update_icon()
				to_chat(usr, "<span class='notice'>Reactor outlet gate engaged.</span>")
				attack_hand(usr)
				return

/obj/machinery/computer/ship/reactor_control_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "stormdrive_console", name, 560, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/reactor_control_computer/ui_data(mob/user)
	var/list/data = list()
	data["heat"] = reactor.heat
	data["rod_integrity"] = reactor.rod_integrity
	data["control_rod_percent"] = reactor.control_rod_percent
	data["pipe_open"] = reactor.pipe.on
	data["last_power_produced"] = reactor.last_power_produced
	data["theoretical_maximum_power"] = reactor.theoretical_maximum_power
	data["reaction_rate"] = reactor.reaction_rate
	if(reactor.state == REACTOR_STATE_MAINTENANCE)
		data["reactor_maintenance"] = TRUE
	else
		data["reactor_maintenance"] = FALSE
	var/moles = 0
	if(reactor.pipe)
		var/datum/gas_mixture/air1 = reactor.pipe.airs[1]
		var/list/cached_gases = air1.gases
		if(cached_gases[/datum/gas/constricted_plasma])
			moles = cached_gases[/datum/gas/constricted_plasma][MOLES]
			if(moles < 0)
				moles = 0
	data["fuel"] = moles
	return data

/obj/item/circuitboard/computer/stormdrive_reactor_control
	name = "Stormdrive Reactor Control Console (Computer Board)"
	build_path = /obj/machinery/computer/ship/reactor_control_computer

/datum/design/board/stormdrive_reactor_control
	name = "Computer Design (Stormdrive Reactor Control Console)"
	desc = "Allows for the construction of circuit boards used to build a new stormdrive reactor control console."
	id = "sd_r_c_c"
	build_path = /obj/item/circuitboard/computer/stormdrive_reactor_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/techweb_node/stormdrive_reactor_control
	id = "sd_r_c_c"
	display_name = "Seegson RBMK RCC"
	description = "Seegson's latest and greatest (within your budget range) reactor control design!"
	prereq_ids = list("adv_engi", "adv_power")
	design_ids = list("sd_r_c_c")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

//////Reactor Manifold//////

/obj/machinery/atmospherics/components/binary/pump/reactor_manifold
	name = "Reactor Manifold"
	desc = "The manifold connection for the stormdrive."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	can_unwrench = FALSE

//////Magnetic Constrictors//////

/obj/machinery/atmospherics/components/binary/magnetic_constrictor //This heats the plasma up to acceptable levels for use in the reactor.
	name = "magnetic constrictor"
	desc = "A large magnet which is capable of pressurizing plasma into a more energetic state. It is able to self-regulate its plasma input valve, as long as plasma is supplied to it."
	icon = 'nsv13/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "constrictor"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/magnetic_constrictor
	active_power_usage = 200
	var/constriction_rate = 0 //SSAtmos is 4x faster than SSMachines aka the reactor
	var/max_output_pressure = 0

/obj/machinery/atmospherics/components/binary/magnetic_constrictor/RefreshParts()
	var/A
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		A += C.rating
	constriction_rate = 0.9 + (0.1 * A)
	var/B
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		B += M.rating
	max_output_pressure = 100 + (100 * B)

/obj/machinery/atmospherics/components/binary/magnetic_constrictor/attack_hand(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, "<span class='notice'>You must turn close the panel on [src] before turning it on.</span>")
		return
	to_chat(user, "<span class='notice'>You press [src]'s power button.</span>")
	on = !on
	update_icon()

/obj/machinery/atmospherics/components/binary/magnetic_constrictor/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS )

/obj/machinery/atmospherics/components/binary/magnetic_constrictor/process_atmos()
	..()
	if(!on)
		return
	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]
	var/output_starting_pressure = air2.return_pressure()
	if(output_starting_pressure >= max_output_pressure)
		return
	var/list/cached_gases = air1.gases
	if(cached_gases[/datum/gas/plasma])
		var/plasma_moles = cached_gases[/datum/gas/plasma][MOLES]
		var/plasma_transfer_moles = min(constriction_rate, plasma_moles)
		air2.assert_gas(/datum/gas/constricted_plasma)
		air2.gases[/datum/gas/constricted_plasma][MOLES] += plasma_transfer_moles
		air2.temperature = air1.temperature
		air1.gases[/datum/gas/plasma][MOLES] -= plasma_transfer_moles
		air1.garbage_collect()
		update_parents()

/obj/machinery/atmospherics/components/binary/magnetic_constrictor/crowbar_act(mob/user, obj/item/I)
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/atmospherics/components/binary/magnetic_constrictor/screwdriver_act(mob/user, obj/item/I)
	if(..())
		return TRUE
	if(on)
		to_chat(user, "<span class='notice'>You must turn off [src] before opening the panel.</span>")
		return FALSE
	panel_open = !panel_open
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You [panel_open?"open":"close"] the panel on [src].</span>")
	update_icon()
	return TRUE

/obj/machinery/atmospherics/components/binary/magnetic_constrictor/update_icon()
	cut_overlays()
	if(panel_open)
		icon_state = "constrictor_screw"
	else if(on)
		icon_state = "constrictor_active"
	else
		icon_state = "constrictor"

/obj/item/circuitboard/machine/magnetic_constrictor
	name = "Magnetic Constrictor (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/binary/magnetic_constrictor
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1)

/datum/design/board/magnetic_constrictor
	name = "Machine Design (Magnetic Constrictor Board)"
	desc = "The circuit board for a Magnetic Constrictor."
	id = "mag_cons"
	build_path = /obj/item/circuitboard/machine/magnetic_constrictor
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/techweb_node/magnetic_constrictor
	id = "mag_cons"
	display_name = "Magnetic Constriction of Plasma"
	description = "Beating plasma into submission - a guide."
	prereq_ids = list("adv_engi", "adv_power")
	design_ids = list("mag_cons")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

//////Constricted Plasma//////

/datum/gas/constricted_plasma
	id = "constricted_plasma"
	specific_heat = 700
	name = "Constricted plasma"
	gas_overlay = "constricted_plasma"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 1000

/obj/machinery/atmospherics/components/trinary/filter/atmos/constricted_plasma
	name = "constricted plasma filter"
	filter_type = "constricted_plasma"

/obj/machinery/atmospherics/components/trinary/filter/atmos/constricted_plasma/flipped
	icon_state = "filter_on_f"
	flipped = TRUE

/obj/machinery/atmospherics/components/trinary/filter/atmos/plasma/flipped
	icon_state = "filter_on_f"
	flipped = TRUE

/obj/machinery/portable_atmospherics/canister/constricted_plasma
	name = "constricted plasma canister"
	desc = "Highly volatile plasma which has been magnetically constricted. The fuel which nuclear storm drives run off of."
	icon_state = "orange"
	gas_type = /datum/gas/constricted_plasma

//////MELTDOWN//////

/obj/effect/decal/nuclear_waste
	name = "Plutonium sludge"
	desc = "A writhing pool of heavily irradiated, spent reactor fuel. You probably shouldn't step through this..."
	icon = 'nsv13/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "nuclearwaste"
	alpha = 150
	light_color = LIGHT_COLOR_CYAN
	color = "#ff9eff"

/obj/effect/decal/nuclear_waste/Initialize()
	. = ..()
	set_light(3)

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
	for(var/turf/open/floor in orange(range, get_turf(src)))
		if(prob(35)) //Scatter the sludge, don't smear it everywhere
			new /obj/effect/decal/nuclear_waste (floor)
			floor.acid_act(200, 100)
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

/obj/effect/decal/nuclear_waste/attackby(obj/item/tool, mob/user)
	if(tool.tool_behaviour == TOOL_SHOVEL)
		radiation_pulse(src, 1000, 5) //MORE RADS
		to_chat(user, "<span class='notice'>You start to clear [src]...</span>")
		if(tool.use_tool(src, user, 50, volume=100))
			to_chat(user, "<span class='notice'>You clear [src]. </span>")
			qdel(src)
			return
	. = ..()

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
	weather_sound = 'nsv13/sound/effects/ship/reactor/falloutwind.ogg'
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

#undef REACTOR_HEAT_NORMAL
#undef REACTOR_HEAT_HOT
#undef REACTOR_HEAT_VERYHOT
#undef REACTOR_HEAT_MELTDOWN
#undef REACTOR_STATE_MAINTENANCE
#undef REACTOR_STATE_IDLE
#undef REACTOR_STATE_RUNNING
#undef REACTOR_STATE_MELTDOWN
#undef WARNING_STATE_NONE
#undef WARNING_STATE_OVERHEAT
#undef WARNING_STATE_MELTDOWN