//FOR NT EYES ONLY
//Mk1 Prototype Defence Screen Reactor

#define CATS list("https://www.sciencemag.org/sites/default/files/styles/article_main_large/public/cat_1280p_0.jpg?itok=MFUV0a-t", "https://cdn.britannica.com/91/181391-050-1DA18304/cat-toes-paw-number-paws-tiger-tabby.jpg", "https://ychef.files.bbci.co.uk/976x549/p07ryyyj.jpg")

#define REACTOR_STATE_IDLE 1
#define REACTOR_STATE_INITIALIZING 2
#define REACTOR_STATE_RUNNING 3
#define REACTOR_STATE_SHUTTING_DOWN 4
#define REACTOR_STATE_EMISSION 5

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor
	name = "mk I Prototype Defence Screen Reactor"
	desc = "A highly experimental, unstable and highly illegal nucleium driven reactor for the generation of defensive screens."
	icon = 'nsv13/icons/obj/machinery/pdsr.dmi'
	icon_state = "idle"
	pixel_x = -32
	pixel_y = -32
	density = FALSE //You can walk over it, expect death
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | FREEZE_PROOF
	light_color = LIGHT_COLOR_BLOOD_MAGIC //Dark Red
	dir = 4
	flipped = TRUE
	var/state = REACTOR_STATE_IDLE
	var/obj/structure/overmap/OM = null //Our Linked Overmap
	var/current_uptime = 0 //How long the PDSR has been running
	var/next_slowprocess = 0 //We don't need to fire more than once a second
	var/next_alarm_sfx = 0 //Time until next alarm SFX firing
	var/next_alarm_message = 0 //Time until next alarm message firing

	//Reactor Vars
	var/id = null
	var/reaction_temperature = 0 //Temperature of the reaction
	var/reaction_containment = 0 //Stability of the overall reaction
	var/reaction_polarity = 0 //Polarity of the reaction
	var/reaction_polarity_trend = 0 //Trend in the shift of polarity
	var/reaction_polarity_timer = 0 //Timer for tracking trends
	var/reaction_polarity_injection = 1 //How we are polarising our nucleium - Starts positive
	var/reaction_rate = 0 //Rate at which the reaction is occuring
	var/reaction_min_coolant_pressure = 100 //Required minimum pressure of coolant
	var/reaction_min_ambient_pressure = 101.25 //Checking to see that we haven't just vented the chamber
	var/reaction_injection_rate = 0 //Rate at which we are injecting nucleium in moles
	var/reaction_energy_output = 0 //How much energy we are producing for the !shields
	var/obj/structure/cable/C = null
	var/last_coolant_time = 0 //Last time we called to flush coolant
	var/flushing_coolant = 0 //Are we currently flushing coolant
	var/emission_tracker = 0 //Used to track emission timers

	//!Shield Vars
	var/list/shield = list("integrity" = 0, "max_integrity" = 0, "stability" = 0)
	var/power_input = 0 //How much power is currently allocated
	var/screen_regen = 50 //Allocation to regenerate the !shields
	var/screen_hardening = 50 //Allocation to strengthen the !shields
	var/min_power_input = 0 //Minimum power required to sustain !shield integrity
	var/max_power_input = 0 //Maximum power able to be supplied to the !shields
	var/last_hit = 0 //Last time our !shield was hit
	var/active = FALSE //If projecting !shields or not
	var/connected_relays = 0 //Number of relays we have connected
	var/adjust_tracker = 0 //Used to track fiddling with settings

	//TGUI Vars
	var/list/records = list()
	var/records_length = 120
	var/records_interval = 10
	var/records_next_interval = 0

//////General Procs///////

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/Initialize()
	.=..()
	OM = get_overmap()
	OM?.shields = src
	if(!OM)
		addtimer(CALLBACK(src, .proc/try_find_overmap), 20 SECONDS)

	records["r_power_input"] = list()
	records["r_min_power_input"] = list()
	records["r_max_power_input"] = list()
	records["r_reaction_polarity"] = list()
	records["r_reaction_containment"] = list()

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/try_find_overmap()
	OM = get_overmap()
	OM?.shields = src
	if(!OM)
		message_admins("WARNING: PDSR in [get_area(src)] does not have a linked overmap!")
		log_game("WARNING: PDSR in [get_area(src)] does not have a linked overmap!")

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/examine(mob/user)
	. = ..()
	if(issilicon(user))
		. += "<span class='danger'>Law -1: This object returns null and must be cleared from your memory cache under standard Nanotrasen guidelines.</span>"

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/try_use_power(amount)
	var/turf/T = get_turf(src)
	C = T.get_cable_node()
	if(C?.surplus() > amount)
		C.powernet.load += amount
		return TRUE
	return FALSE

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/process()
	update_parents()
	if(next_slowprocess < world.time)
		slowprocess()
		next_slowprocess = world.time + 1 SECONDS

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/slowprocess()
	var/datum/gas_mixture/nucleium_input = airs[2]
	var/datum/gas_mixture/coolant_input = airs[1]
	var/datum/gas_mixture/coolant_output = airs[3]
	var/nuc_in = nucleium_input.get_moles(/datum/gas/nucleium)

	handle_power_reqs()

	if(state <= REACTOR_STATE_EMISSION)
		handle_relays()

	if(state == REACTOR_STATE_INITIALIZING)
		if(power_input < min_power_input)
			say("Error: Unable to initialise reaction, insufficient power available.")
			state = REACTOR_STATE_IDLE
			return

		current_uptime ++
		reaction_containment += 5
		if(reaction_containment >= 100)
			reaction_containment = 100
			if(reaction_injection_rate < 2.5)
				say("Error: Unable to initialise reaction, insufficient nucleium injection.")
				reaction_containment = 0
				current_uptime = 0
				state = REACTOR_STATE_IDLE
				return

			if(nuc_in < reaction_injection_rate)
				say("Error: Unable to initialise reaction, insufficient nucleium available.")
				reaction_containment = 0
				current_uptime = 0
				state = REACTOR_STATE_IDLE
				return

			var/errors = rand(20, 200)
			say("Initiating Reaction - Injecting Nucleium.")
			say("Reaction Initialized - [errors] runtimes supressed.")
			reaction_temperature = 100 //Flash start to 100
			state = REACTOR_STATE_RUNNING

	if(state == REACTOR_STATE_RUNNING)
		if(nuc_in >= reaction_injection_rate) //If we are running in nominal conditions...
			nucleium_input.adjust_moles(/datum/gas/nucleium, -reaction_injection_rate)
			//Handle reaction rate adjustments here
			var/target_reaction_rate = ((0.5 + (1e-03 * (reaction_injection_rate ** 2))) + (current_uptime / 2000)) * 16
			var/delta_reaction_rate = target_reaction_rate - reaction_rate
			reaction_rate += delta_reaction_rate / 2 //Function goes here
			reaction_temperature += reaction_rate * 0.35 //Function goes
			handle_polarity(TRUE)

		else if(nuc_in < reaction_injection_rate) //If we are running without sufficient nucleium...
			if(nuc_in <= 0) //...and none at all
				var/target_reaction_rate = 0
				var/delta_reaction_rate = target_reaction_rate - reaction_rate
				reaction_rate += delta_reaction_rate / 2 //Function goes here
				reaction_temperature += reaction_rate * 0.55
				handle_polarity(FALSE)

			else //...and has some nucleium but not sufficient nucleium for a stable reaction
				nucleium_input.adjust_moles(/datum/gas/nucleium, -nuc_in) //Use whatever is in there
				//Handle reaction rate adjustments here WITH PENALTIES
				var/target_reaction_rate = (0.5 + (1e-03 * (reaction_injection_rate ** 2))) + (current_uptime / 1000) *  5
				var/delta_reaction_rate = target_reaction_rate - reaction_rate
				reaction_rate += delta_reaction_rate / 2 //Function goes here
				reaction_temperature += reaction_rate * 0.45 //Heat Penalty
				//Handle polarity here
				handle_polarity(TRUE)

		if(reaction_rate > 5) //TEMP USE FUNCTIONS
			reaction_energy_output = (reaction_rate + (reaction_injection_rate / 2)) * (2 - (current_uptime / 20000)) //FUNCTIONS
			radiation_pulse(src, reaction_energy_output)

		else
			reaction_energy_output = 0

		if(coolant_input.total_moles() >= (reaction_rate * 3))
			var/delta_coolant = (KELVIN_TO_CELSIUS(coolant_input.return_temperature()) / 40)  //no longer whole sale stolen :) - Yeah I was correct the first time; MAP PROBLEM, NOT CODE PROBLEM
			reaction_temperature += delta_coolant
			coolant_output.merge(coolant_input)
			coolant_output.set_temperature(CELSIUS_TO_KELVIN(reaction_temperature))
			coolant_input.clear()

			if(flushing_coolant)
				if(world.time <= (last_coolant_time + 20 SECONDS))
					src.atmos_spawn_air("water_vapor=5;TEMP=[reaction_temperature]")
					reaction_temperature -= 15 //300C total
					current_uptime += 5 //This is costly, you really don't want to attempt to manage your temperature this way

				else if(world.time >= (last_coolant_time + 120 SECONDS))
					flushing_coolant = FALSE //Reset our cooldown here

			if(reaction_temperature <= 0)
				reaction_temperature = 0
				if(min_power_input <= 1e+6)
					say("Reaction Terminated - Dumping screen caches and cycling containment generators.")
					state = REACTOR_STATE_SHUTTING_DOWN
				else
					say("Error: Reaction Prematurely Terminated - Inspect all systems for damage.")
					state = REACTOR_STATE_IDLE
					for(var/I = 0, I < 3, I++) //Overload Three Relays
						var/list/overload_candidate = list()
						for(var/obj/machinery/defence_screen_relay/DSR in GLOB.machines)
							if(DSR.powered() && DSR.overloaded == FALSE)
								overload_candidate += DSR
								if(overload_candidate.len > 0)
									var/obj/machinery/defence_screen_relay/DSRC = pick(overload_candidate)
									DSRC.overload()

					depower_shield()
					OM.take_quadrant_hit(rand(100, 200), "forward_port")
					OM.take_quadrant_hit(rand(100, 200), "forward_starboard")
					OM.take_quadrant_hit(rand(100, 200), "aft_port")
					OM.take_quadrant_hit(rand(100, 200), "aft_starboard")

		handle_screens()
		handle_temperature()
		handle_containment()
		handle_atmos_check()
		current_uptime ++


	if(state == REACTOR_STATE_SHUTTING_DOWN)
		reaction_rate = 0
		reaction_temperature -= reaction_temperature / 4
		handle_temperature()
		if(reaction_temperature <= 10)
			handle_shutdown()

	if(state == REACTOR_STATE_EMISSION)
		if(world.time >= (emission_tracker + 10 SECONDS))
			handle_emission_release()
		else
			handle_emission_buildup()


	handle_alarm()
	handle_records()
	update_icon()

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/attackby(obj/item/I, mob/living/carbon/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		M.buffer = src
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer loaded</span>")

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_records()
	if(world.time >= records_next_interval)
		records_next_interval = world.time + records_interval

		var/list/r_power_input = records["r_power_input"]
		r_power_input += power_input
		if(r_power_input.len > records_length)
			r_power_input.Cut(1, 2)
		var/list/r_min_power_input = records["r_min_power_input"]
		r_min_power_input += min_power_input
		if(r_min_power_input.len > records_length)
			r_min_power_input.Cut(1, 2)
		var/list/r_max_power_input = records["r_max_power_input"]
		r_max_power_input += max_power_input
		if(r_max_power_input.len > records_length)
			r_max_power_input.Cut(1, 2)
		var/list/r_reaction_polarity = records["r_reaction_polarity"]
		r_reaction_polarity += reaction_polarity
		if(r_reaction_polarity.len > records_length)
			r_reaction_polarity.Cut(1,2)
		var/list/r_reaction_containment = records["r_reaction_containment"]
		r_reaction_containment += reaction_containment
		if(r_reaction_containment.len > records_length)
			r_reaction_containment.Cut(1,2)

//////Reactor Procs//////

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_containment() //We manage poweruse and containment here
	if(try_use_power(power_input))
		if(power_input > max_power_input && power_input <= 1.25 * max_power_input) //Overloading Containment - Rapid Rise
			var/overloading_containment = reaction_containment
			if(overloading_containment < 25)
				overloading_containment = 25
			var/overloading_function = ((382 * NUM_E **(0.0764 * overloading_containment)) / ((50 + NUM_E ** (0.0764 * overloading_containment)) ** 2)) * 14
			reaction_containment += overloading_function * (power_input / max_power_input)
			current_uptime ++ //Overloading has a cost

		else if(power_input >= min_power_input && power_input <= max_power_input) //Nominal Containment - Maintain Containment
			var/containment_function = ((382 * NUM_E **(0.0764 * reaction_containment)) / ((50 + NUM_E ** (0.0764 * reaction_containment)) ** 2)) * 10
			reaction_containment += containment_function * (power_input / max_power_input)

		else if(power_input < min_power_input && power_input >= 0.75 * min_power_input) //Insufficient Power for Containment - Slow Loss
			var/loss_function = ((382 * NUM_E **(0.0764 * reaction_containment)) / ((50 + NUM_E ** (0.0764 * reaction_containment)) ** 2)) * 4
			reaction_containment += loss_function * (power_input / max_power_input)

	if(reaction_containment > 100)
		reaction_containment = 100

	if(reaction_containment < 0)
		reaction_containment = 0
		emission_tracker = world.time
		say("Error: Catatstropic Containment Failure - Initializing Emergency Termination Protocols")
		playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, 0, 15, 10, 10) //Replace me later?
		state = REACTOR_STATE_EMISSION //Whoops

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_power_reqs() //How much power is required
	min_power_input = max(1e+6, (reaction_temperature * (reaction_rate ** 2) * 225))
	max_power_input = 10e+6 + (2e+6 * connected_relays)
	if(min_power_input > max_power_input)
		min_power_input = max_power_input

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_alarm()
	if(reaction_containment < 33 && state == REACTOR_STATE_RUNNING)
		if(next_alarm_sfx < world.time)
			next_alarm_sfx = world.time + 3 SECONDS
			playsound(src, 'nsv13/sound/effects/ship/pdsr_warning.ogg', 100, 0, 10, 10)
		if(next_alarm_message < world.time)
			next_alarm_message = world.time + 15 SECONDS
			say("DANGER: Reaction Containment Critical. Emission Imminent.")

	if(state == REACTOR_STATE_EMISSION)
		if(next_alarm_sfx < world.time)
			next_alarm_sfx = world.time + 3 SECONDS
			playsound(src, 'nsv13/sound/effects/ship/pdsr_warning.ogg', 100, 0, 10, 10)

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_polarity(var/injecting = FALSE)
	if(reaction_polarity_timer < world.time) //Handle the trend
		reaction_polarity_timer = world.time + rand(20 SECONDS, 40 SECONDS)
		reaction_polarity_trend = pick(-0.02, -0.025, 0.02, 0.025) //We either trend up or down

	reaction_polarity += reaction_polarity_trend

	if(injecting)
		if(reaction_polarity_injection)
			reaction_polarity += 0.027
		else
			reaction_polarity -= 0.027

	if(reaction_polarity > 1)
		reaction_polarity = 1

	if(reaction_polarity < -1)
		reaction_polarity = -1

	var/polarity_function = abs(0.5 * (reaction_polarity ** 2)) //RECHECK THIS WHEN NOT DEAD
	reaction_containment -= polarity_function
	reaction_temperature += polarity_function * max(1, (current_uptime / 4000))

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_emission_buildup()
	if(prob(50)) //Seizure warning
		radiation_pulse(src, reaction_energy_output * 2)
		for(var/mob/living/M in orange(12, src))
			if(in_view_range(M, src))
				to_chat(M, "<span class='warning'>A stream of particles erupts from the [src]!</span>")
				M.flash_act(1, 0, 1)
				playsound(src, 'sound/magic/repulse.ogg', 100, 0, 5, 5)
	//more goes here

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_emission_release()
	for(var/obj/machinery/defence_screen_relay/DSR in GLOB.machines)
		if(DSR.powered() && DSR.overloaded == FALSE)
			DSR.overload()

	var/emission_energy = reaction_energy_output * (1 + (current_uptime / 1000))
	radiation_pulse(src, emission_energy ** 2, 10, 1, 1)

	for(var/mob/living/M in OM.mobs_in_ship)
		if(M.client)
			M.flash_act((emission_energy / 10), 0 , 1)
			M.Knockdown(emission_energy / 10)
			M.adjust_disgust(rand(20, 50))
			to_chat(M, "<span class='warning'>A wash of radiation passes through you!</span>")

	depower_shield()
	OM.take_quadrant_hit((emission_energy ** 2) / 2, "forward_port")
	OM.take_quadrant_hit((emission_energy ** 2) / 2, "forward_starboard")
	OM.take_quadrant_hit((emission_energy ** 2) / 2, "aft_port")
	OM.take_quadrant_hit((emission_energy ** 2) / 2, "aft_starboard")

	handle_shutdown() //And reset

	say("Emergency Termination Protocols Enabled - Reaction Halted.")
	say("Inspect all systems for damage.")

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_temperature()
	var/turf/open/L = get_turf(src)
	if(!istype(L) || !(L.air))
		return
	var/datum/gas_mixture/env = L.return_air()
	var/heat_kelvin = reaction_temperature + 273.15
	if(env.return_temperature() <= heat_kelvin)
		var/delta_env = heat_kelvin - env.return_temperature()
		var/temperature = env.return_temperature()
		env.set_temperature(temperature += delta_env / 2)
		air_update_turf()

	reaction_containment -= (reaction_temperature / 50) + (current_uptime / 2000)

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_atmos_check()
	for(var/obj/machinery/defence_screen_relay/DSR in GLOB.machines)
		if(DSR.powered() && DSR.overloaded == FALSE)
			DSR.atmos_check()

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_shutdown()
	state = REACTOR_STATE_IDLE
	current_uptime = 0
	reaction_temperature = 0
	reaction_containment = 0
	reaction_polarity = 0
	reaction_rate = 0
	flushing_coolant = 0
	reaction_energy_output = 0
	emission_tracker = 0
	depower_shield()

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/update_icon()
	switch(state)
		if(REACTOR_STATE_EMISSION)
			icon_state = "emission"
			set_light(4)
			return
		if(REACTOR_STATE_SHUTTING_DOWN)
			icon_state = "shutdown"
			return
		if(REACTOR_STATE_RUNNING)
			icon_state = "running"
			return
		if(REACTOR_STATE_INITIALIZING)
			icon_state = "initializing"
			return
		if(REACTOR_STATE_IDLE)
			icon_state = "idle"
			set_light(0)
			return

//////Shield Procs//////

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/absorb_hit(damage)
	if(!active)
		return FALSE //!shields not raised

	if(shield["integrity"] >= damage)
		shield["integrity"] -= damage //Deduct from !shield
		var/current_hit = world.time
		if(current_hit <= last_hit + 10) //1 Second
			shield["stability"] -= rand((damage / 10), (damage / 5)) //Rapid hits will reduce stability greatly

		else
			shield["stability"] -= rand((damage / 50), (damage / 25)) //Reduce !shield stability

		last_hit = current_hit //Set our last hit
		check_stability()
		return TRUE

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/check_stability()
	if(shield["stability"] <= 0)
		shield["stability"] = 0
		active = FALSE //Collapse !shield
		var/sound = 'nsv13/sound/effects/ship/ship_hit_shields_down.ogg'
		var/obj/structure/overmap/OM = get_overmap()
		OM?.relay(sound, null, loop=FALSE, channel = CHANNEL_SHIP_FX)
		current_uptime += 5
		var/list/overload_candidate = list()
		for(var/obj/machinery/defence_screen_relay/DSR in GLOB.machines)
			if(DSR.powered() && DSR.overloaded == FALSE)
				overload_candidate += DSR
				if(overload_candidate.len > 0)
					var/obj/machinery/defence_screen_relay/DSRC = pick(overload_candidate)
					DSRC.overload()

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_screens()
	if(!active)
		shield["stability"] += 10 //Realign the screen manifold - 10 seconds
		if(shield["stability"] >= 100)
			shield["stability"] = 100
			active = TRUE //Renable !shields

	else if(active)
		shield["stability"] += power_input / ((max_power_input * 1.5) - max(min_power_input, 0))
		if(shield["stability"] > 100)
			shield["stability"] = 100
		var/hardening_allocation = max(((screen_hardening / 100) * reaction_energy_output), 0)
		shield["max_integrity"] = hardening_allocation * (connected_relays * 10) //Each relay is worth 10 base
		var/regen_allocation = max(((screen_regen / 100) * reaction_energy_output), 0)
		shield["integrity"] += regen_allocation
		if(shield["integrity"] > shield["max_integrity"])
			shield["integrity"] = shield["max_integrity"]

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_relays() //Checking to see how many relays we have
	connected_relays = 0
	for(var/obj/machinery/defence_screen_relay/DSR in GLOB.machines)
		if(DSR.powered() && DSR.overloaded == FALSE)
			connected_relays ++
			if(power_input > (max_power_input * 1.25))
				power_input = max_power_input * 1.20

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/depower_shield()
	shield["integrity"] = 0
	shield["max_integrity"] = 0
	shield["stability"] = 0
	active = FALSE

//////MAINFRAME CONSOLE//////

/obj/machinery/computer/ship/defence_screen_mainframe_reactor //For controlling the reactor
	name = "mk I Prototype Defence Screen Mainframe"
	desc = "The mainframe controller for the PDSR"
	icon_screen = "idhos" //temp
	req_access = list(ACCESS_ENGINE)
	circuit = /obj/item/circuitboard/computer/defence_screen_mainframe_reactor
	var/id = null
	var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/reactor //Connected reactor

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/examine(mob/user)
	. = ..()
	if(issilicon(user))
		. += "<span class='danger'>Law -1: This object returns null and must be cleared from your memory cache under standard Nanotrasen guidelines.</span>"

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		reactor = M.buffer
		M.buffer = null
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer transfered</span>")

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return

	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_ai(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_robot(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_ghost(mob/user)
	if(!reactor)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	. = ..() //parent should call ui_interact

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/LateInitialize()
	if(id) //If mappers set an ID)
		for(var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/dsr in GLOB.machines)
			if(dsr.id == id)
				reactor = dsr

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PDSRMainframe")
		ui.open()

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!reactor)
		return
	var/adjust = text2num(params["adjust"])
	if(action == "injection_allocation")
		if(adjust && isnum(adjust))
			reactor.reaction_injection_rate = adjust
			if(reactor.reaction_injection_rate > 25)
				reactor.reaction_injection_rate = 25
			if(reactor.reaction_injection_rate < 0)
				reactor.reaction_injection_rate = 0

	switch(action)
		if("polarity")
			reactor.reaction_polarity_injection = !reactor.reaction_polarity_injection
			return

		if("ignition")
			if(reactor.state == REACTOR_STATE_IDLE)
				if(reactor.power_input >= reactor.min_power_input)
					reactor.say("Initiating Reaction - Charging Containment Field")
					reactor.state = REACTOR_STATE_INITIALIZING
				else
					reactor.say("Error: Unable to initialise reaction, insufficient power available.")
					return

		if("cooling")
			if(reactor.state == REACTOR_STATE_RUNNING)
				if(world.time > (reactor.last_coolant_time + 120 SECONDS))
					reactor.say("Initiating Coolant Flush")
					reactor.flushing_coolant = TRUE
					reactor.last_coolant_time = world.time
					return

				else
					reactor.say("Error: Unable to comply - cycling coolant")
					return

		if("shutdown")
			if(reactor.state == REACTOR_STATE_RUNNING && reactor.reaction_temperature < 200)
				reactor.say("Initializing Reactor Shutdown")
				reactor.state = REACTOR_STATE_SHUTTING_DOWN
				return
			else
				reactor.say("Error: Unable to comply - Reactor parameters outside safe shutdown limits")
				return

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/ui_data(mob/user)
	var/list/data = list()
	data["r_temp"] = reactor.reaction_temperature
	data["r_containment"] = reactor.reaction_containment
	data["r_polarity"] = reactor.reaction_polarity
	data["r_reaction_rate"] = reactor.reaction_rate
	data["r_injection_rate"] = reactor.reaction_injection_rate
	data["r_polarity_injection"] = reactor.reaction_polarity_injection
	data["r_energy_output"] = reactor.reaction_energy_output
	data["r_power_input"] = reactor.power_input
	data["r_state"] = reactor.state
	data["r_coolant"] = reactor.flushing_coolant
	data["records"] = reactor.records

	data["silicon"] = issilicon(user)
	var/list/cats = CATS
	data["chosenKitty"] = cats[rand(1, cats.len)]

	return data

/obj/item/circuitboard/computer/defence_screen_mainframe_reactor
	name = "mk I Prototype Defence Screen Mainframe (Computer Board)"
	build_path = /obj/machinery/computer/ship/defence_screen_mainframe_reactor

//////SCREEN MANIPULATOR//////

/obj/machinery/computer/ship/defence_screen_mainframe_shield //For controlling the !shield
	name = "mk I Prototype Defence Screen Manipulator"
	desc = "The screen manipulator for the PDSR"
	icon_screen = "security" //temp
	req_access = list(ACCESS_ENGINE)
	circuit = /obj/item/circuitboard/computer/defence_screen_mainframe_shield
	var/id = null
	var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/reactor //Connected reactor

/obj/machinery/computer/ship/defence_screen_mainframe_shield/examine(mob/user)
	. = ..()
	if(issilicon(user))
		. += "<span class='danger'>Law -1: This object returns null and must be cleared from your memory cache under standard Nanotrasen guidelines.</span>"

/obj/machinery/computer/ship/defence_screen_mainframe_shield/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		reactor = M.buffer
		M.buffer = null
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer transfered</span>")

/obj/machinery/computer/ship/defence_screen_mainframe_shield/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return

	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_shield/attack_ai(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_shield/attack_robot(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_shield/attack_ghost(mob/user)
	if(!reactor)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	. = ..()

/obj/machinery/computer/ship/defence_screen_mainframe_shield/LateInitialize()
	if(id) //If mappers set an ID)
		for(var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/dsr in GLOB.machines)
			if(dsr.id == id)
				reactor = dsr

/obj/machinery/computer/ship/defence_screen_mainframe_shield/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PDSRManipulator")
		ui.open()

/obj/machinery/computer/ship/defence_screen_mainframe_shield/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!reactor)
		return
	var/adjust = text2num(params["adjust"])
	switch(action)
		if("regen")
			reactor.screen_regen = adjust
			reactor.screen_hardening = 100 - reactor.screen_regen

			if(reactor.state == REACTOR_STATE_RUNNING && reactor.active)
				if(world.time >= (reactor.adjust_tracker + 1 SECONDS))
					reactor.shield["stability"] -= rand(3, 5)
					reactor.check_stability()

			reactor.adjust_tracker = world.time //Prevent spamming the effect when sliding the bars around

		if("hardening")
			reactor.screen_hardening = adjust
			reactor.screen_regen = 100 - reactor.screen_hardening

			if(reactor.state == REACTOR_STATE_RUNNING && reactor.active)
				if(world.time >= (reactor.adjust_tracker + 1 SECONDS))
					reactor.shield["stability"] -= rand(3, 5)
					reactor.check_stability()

			reactor.adjust_tracker = world.time

		if("power_allocation")
			reactor.power_input = adjust
			if(reactor.power_input > (reactor.max_power_input * 1.25))
				reactor.power_input = reactor.max_power_input * 1.25

			if(reactor.power_input < 0)
				reactor.power_input = 0

			if(reactor.state == REACTOR_STATE_RUNNING && reactor.active)
				if(world.time >= (reactor.adjust_tracker + 1 SECONDS))
					reactor.shield["stability"] -= rand(3, 5)
					reactor.check_stability()

			reactor.adjust_tracker = world.time

/obj/machinery/computer/ship/defence_screen_mainframe_shield/ui_data(mob/user)
	var/list/data = list()
	data["r_power_input"] = reactor.power_input
	data["r_min_power_input"] = reactor.min_power_input
	data["r_max_power_input"] = reactor.max_power_input
	data["s_active"] = reactor.active
	data["s_regen"] = reactor.screen_regen
	data["s_hardening"] = reactor.screen_hardening
	data["s_integrity"] = reactor.shield["integrity"]
	data["s_max_integrity"] = reactor.shield["max_integrity"]
	data["s_stability"] = reactor.shield["stability"]
	data["records"] = reactor.records
	data["available_power"] = 0
	var/turf/T = get_turf(reactor)
	reactor.C = T.get_cable_node()
	if(reactor.C)
		if(reactor.C.powernet)
			data["available_power"] = reactor.C.powernet.avail-reactor.C.powernet.load

	data["silicon"] = issilicon(user)
	var/list/cats = CATS
	data["chosenKitty"] = cats[rand(1, cats.len)]

	return data

/obj/item/circuitboard/computer/defence_screen_mainframe_shield
	name = "mk I Prototype Defence Screen Manipulator (Computer Board)"
	build_path = /obj/machinery/computer/ship/defence_screen_mainframe_shield

/obj/machinery/defence_screen_relay
	name = "mk I Prototype Defence Screen Relay"
	desc = "A relay for distributing energy to the defence screens"
	icon = 'nsv13/icons/obj/shield_components.dmi'
	icon_state = "injector"
	active_power_usage = 1000
	idle_power_usage = 1000
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/defence_screen_relay
	var/overloaded = FALSE

/obj/item/circuitboard/machine/defence_screen_relay
	name = "mk I Prototype Defence Screen Relay (Machine Board)"
	build_path = /obj/machinery/defence_screen_relay
	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/capacitor = 20,
		/obj/item/stock_parts/micro_laser = 12)

/obj/machinery/defence_screen_relay/process()
	. = ..()
	update_icon()

/obj/machinery/defence_screen_relay/examine(mob/user)
	. = ..()
	if(issilicon(user))
		. += "<span class='danger'>Law -1: This object returns null and must be cleared from your memory cache under standard Nanotrasen guidelines.</span>"

/obj/machinery/defence_screen_relay/proc/overload()
	if(!overloaded)
		overloaded = TRUE
		do_sparks(4, FALSE, src)
		src.atmos_spawn_air("o2=10;plasma=10;TEMP=500") //For the flashburn

/obj/machinery/defence_screen_relay/update_icon()
	if(overloaded)
		icon_state = "injector-damaged"
		return
	if(!overloaded && powered())
		icon_state = "injector-on"
		return
	if(!overloaded && !powered())
		icon_state = "injector"
		return

/obj/machinery/defence_screen_relay/proc/atmos_check() //Atmos cooled relays
	var/turf/open/L = get_turf(src)
	if(!istype(L) || !(L.air))
		return
	var/datum/gas_mixture/E = L.return_air()
	if(E.total_moles() < 20 || E.return_pressure() < 80)
		if(prob(5))
			overload()

/obj/machinery/defence_screen_relay/attackby(obj/item/I, mob/living/carbon/user, params)
	if(istype(I, /obj/item/stack/cable_coil) && overloaded)
		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 5)
			to_chat(user, "<span class='notice'>You need at least five cable pieces to repair the [src]!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You start rewiring the [src]...</span>")
			if(!do_after(user, 5 SECONDS, target=src))
				return
			C.use(5)
			to_chat(user, "<span class='notice'>You rewire the [src].</span>")
			overloaded = FALSE

/obj/machinery/defence_screen_relay/welder_act(mob/living/user, obj/item/I)
	. = ..()
	while(obj_integrity < max_integrity)
		if(!do_after(user, 5, target = src))
			return
		obj_integrity += rand(1,2)
		if(obj_integrity >= max_integrity)
			obj_integrity = max_integrity
			break

/obj/machinery/syndicatebomb/self_destruct/pdsr
	name = "NT-7624 'scorched earth' localised self-destruct terminal"
	desc = "A terminal which contains a powerful explosive device capable of destroying all evidence in a room around it. In times of dire need, do not forget your duty."
	icon = 'nsv13/icons/obj/machines/nuke_terminal.dmi'
	icon_state = "syndicate-bomb"
	anchored = TRUE
	can_be_unanchored = FALSE
	density = TRUE
	can_unanchor = FALSE
	//Only the CE can make this call...
	req_one_access = list(ACCESS_CE)

/obj/machinery/syndicatebomb/self_destruct/pdsr/interact(mob/user)
	wires.interact(user)
	//Anti Jeff mechanism
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		visible_message("<span class='warning'>[icon2html(src, viewers(src.loc))] ACCESS DENIED.</span>")
		return FALSE
	if(!open_panel)
		if(!active)
			settings(user)
		else if(anchored)
			to_chat(user, "<span class='warning'>The bomb is bolted to the floor!</span>")

#undef REACTOR_STATE_IDLE
#undef REACTOR_STATE_INITIALIZING
#undef REACTOR_STATE_RUNNING
#undef REACTOR_STATE_SHUTTING_DOWN
#undef REACTOR_STATE_EMISSION
#undef CATS
