//FOR NT EYES ONLY
//Mk1 Prototype Defence Screen Reactor

#define CATS list("https://www.sciencemag.org/sites/default/files/styles/article_main_large/public/cat_1280p_0.jpg?itok=MFUV0a-t", "https://cdn.britannica.com/91/181391-050-1DA18304/cat-toes-paw-number-paws-tiger-tabby.jpg", "https://ychef.files.bbci.co.uk/976x549/p07ryyyj.jpg")

#define REACTOR_STATE_IDLE 1
#define REACTOR_STATE_INITIALIZING 2
#define REACTOR_STATE_RUNNING 3
#define REACTOR_STATE_SHUTTING_DOWN 4
#define REACTOR_STATE_EMISSION 5

#define DENSITY_LOW 0 //! Deflects only heavy hits.
#define DENSITY_HIGH 1 //! Deflects all hits.

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor
	name = "mk II Prototype Defence Screen Reactor"
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
	///Time when our reactor was last shutdown.
	var/powerdown_time = 0
	///If this is already detonating
	var/detonating = FALSE

	//!Shield Vars
	var/list/shield = list("integrity" = 0, "max_integrity" = 0, "stability" = 0, "density" = DENSITY_HIGH)
	var/power_input = 0 //How much power is currently allocated
	///Did we get enough power last power tick?
	var/power_demand_met = FALSE
	///How much power did we use during the power tick?
	var/last_power_use = 0
	///How much power was in the grid during power tick?
	var/last_avail_power = 0
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

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/Initialize(mapload)
	.=..()
	OM = get_overmap()
	OM?.shields = src
	if(!OM)
		addtimer(CALLBACK(src, PROC_REF(try_find_overmap)), 20 SECONDS)

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
	if(C?.surplus() >= amount)
		C.powernet.load += amount
		last_power_use = amount
		power_demand_met = TRUE
		last_avail_power = C?.surplus()
		return TRUE
	power_demand_met = FALSE
	last_power_use = 0
	last_avail_power = C?.surplus()
	return FALSE

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/process_atmos()
	update_parents()
	if(next_slowprocess <= world.time)
		slowprocess()
		next_slowprocess = world.time + 1 SECONDS

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/process()
	if(state == REACTOR_STATE_IDLE)
		return
	try_use_power(power_input)

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/slowprocess()
	var/datum/gas_mixture/nucleium_input = airs[2]
	var/datum/gas_mixture/coolant_input = airs[1]
	var/datum/gas_mixture/coolant_output = airs[3]
	var/nuc_in = nucleium_input.get_moles(GAS_NUCLEIUM)

	handle_power_reqs()

	if(state <= REACTOR_STATE_EMISSION)
		handle_relays()

	if(state == REACTOR_STATE_INITIALIZING)
		if(power_input < min_power_input)
			say("Error: Unable to initialise reaction, insufficient power available.")
			state = REACTOR_STATE_IDLE
			return

		current_uptime ++
		reaction_containment += 20 // ~5 seconds as opposed to 20 for core start.
		if(reaction_containment >= 100)
			reaction_containment = 100
			if(reaction_injection_rate < 2.5)
				say("Error: Unable to initialise reaction, insufficient nucleium injection.")
				handle_shutdown()
				return

			if(nuc_in < reaction_injection_rate)
				say("Error: Unable to initialise reaction, insufficient nucleium available.")
				handle_shutdown()
				return
			if(!power_demand_met)
				say("Error: Power allocation exceeding grid capacity. Failed to initiate reaction.")
				handle_shutdown()
				return

			var/errors = rand(20, 199)
			say("Initiating Reaction - Injecting Nucleium.")
			say("Reaction Initialized - [errors] runtimes supressed.")
			reaction_temperature = 100 //Flash start to 100
			shield["stability"] = 50 //begin at 50 during startup.
			state = REACTOR_STATE_RUNNING

	if(state == REACTOR_STATE_RUNNING)
		if(nuc_in >= reaction_injection_rate && reaction_injection_rate >= 2.5) //If we are running in nominal conditions...
			nucleium_input.adjust_moles(GAS_NUCLEIUM, -reaction_injection_rate)
			//Handle reaction rate adjustments here
			var/target_reaction_rate = ((0.5 + (1e-03 * (reaction_injection_rate ** 2))) + (current_uptime / 2000)) * 16
			var/delta_reaction_rate = target_reaction_rate - reaction_rate
			reaction_rate += delta_reaction_rate / 2 //Function goes here
			reaction_temperature += reaction_rate * 0.35 //Function goes
			handle_polarity(TRUE)

		else //If we are running without sufficient nucleium...
			if(nuc_in <= 0) //...and none at all
				var/target_reaction_rate = 0
				var/delta_reaction_rate = target_reaction_rate - reaction_rate
				reaction_rate += delta_reaction_rate / 2 //Function goes here
				reaction_temperature += reaction_rate * 0.55
				handle_polarity(FALSE)

			else //...and has some nucleium but not sufficient nucleium for a stable reaction
				nucleium_input.adjust_moles(GAS_NUCLEIUM, -nuc_in) //Use whatever is in there
				//Handle reaction rate adjustments here WITH PENALTIES
				var/target_reaction_rate = (0.5 + (1e-03 * (reaction_injection_rate ** 2))) + (current_uptime / 1000) *  5
				var/delta_reaction_rate = target_reaction_rate - reaction_rate
				reaction_rate += delta_reaction_rate / 2 //Function goes here
				reaction_temperature += reaction_rate * 0.45 //Heat Penalty
				//Handle polarity here
				handle_polarity(TRUE)

		if(reaction_rate > 5) //TEMP USE FUNCTIONS
			reaction_energy_output = (reaction_rate + (min(nuc_in, reaction_injection_rate) / 2)) * (2 - (current_uptime / 20000)) //FUNCTIONS
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
					var/list/overload_candidate = list()
					for(var/obj/machinery/defence_screen_relay/DSR in GLOB.machines)
						if(DSR.powered() && DSR.overloaded == FALSE)
							overload_candidate += DSR
					for(var/I = 0, I < 3, I++) //Overload Three Relays
						if(overload_candidate.len > 0)
							var/obj/machinery/defence_screen_relay/DSRC = pick_n_take(overload_candidate)
							DSRC.overload()

					depower_shield()
					OM.take_quadrant_hit(rand(100, 200), "forward_port")
					OM.take_quadrant_hit(rand(100, 200), "forward_starboard")
					OM.take_quadrant_hit(rand(100, 200), "aft_port")
					OM.take_quadrant_hit(rand(100, 200), "aft_starboard")
					state = REACTOR_STATE_SHUTTING_DOWN

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
	if(power_demand_met)
		if(last_power_use > max_power_input && last_power_use <= 1.25 * max_power_input) //Overloading Containment - Rapid Rise
			var/overloading_containment = reaction_containment
			if(overloading_containment < 25)
				overloading_containment = 25
			var/overloading_function = ((382 * NUM_E **(0.0764 * overloading_containment)) / ((50 + NUM_E ** (0.0764 * overloading_containment)) ** 2)) * 14
			reaction_containment += overloading_function * (last_power_use / max_power_input)
			current_uptime ++ //Overloading has a cost

		else if(last_power_use >= min_power_input && last_power_use <= max_power_input) //Nominal Containment - Maintain Containment
			var/containment_function = ((382 * NUM_E **(0.0764 * reaction_containment)) / ((50 + NUM_E ** (0.0764 * reaction_containment)) ** 2)) * 10
			reaction_containment += containment_function * (last_power_use / max_power_input)

		else if(last_power_use < min_power_input && last_power_use >= 0.75 * min_power_input) //Insufficient Power for Containment - Slow Loss
			var/loss_function = ((382 * NUM_E **(0.0764 * reaction_containment)) / ((50 + NUM_E ** (0.0764 * reaction_containment)) ** 2)) * 4
			reaction_containment += loss_function * (last_power_use / max_power_input)


	if(reaction_containment > 100)
		reaction_containment = 100

	if(reaction_containment < 0)
		reaction_containment = 0
		emission_tracker = world.time
		say("Error: Catatstropic Containment Failure - Initializing Emergency Termination Protocols")
		playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, FALSE, 15) //Replace me later?
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
			playsound(src, 'nsv13/sound/effects/ship/pdsr_warning.ogg', 100, FALSE, 10)
		if(next_alarm_message < world.time)
			next_alarm_message = world.time + 15 SECONDS
			say("DANGER: Reaction Containment Critical. Emission Imminent.")

	if(state == REACTOR_STATE_EMISSION)
		if(next_alarm_sfx < world.time)
			next_alarm_sfx = world.time + 3 SECONDS
			playsound(src, 'nsv13/sound/effects/ship/pdsr_warning.ogg', 100, FALSE, 10)

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

	reaction_polarity = clamp(reaction_polarity, -1, 1)

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
				playsound(src, 'sound/magic/repulse.ogg', 100, FALSE, 5)
	//more goes here

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_emission_release()
	for(var/obj/machinery/defence_screen_relay/DSR in GLOB.machines)
		if(DSR.powered() && DSR.overloaded == FALSE)
			DSR.overload()

	var/emission_energy = max(10, reaction_energy_output) * (1 + (current_uptime / 1000))
	radiation_pulse(src, emission_energy ** 2, 10, 1, 1)

	for(var/mob/living/M in OM.mobs_in_ship)
		if(M.client)
			M.flash_act(clamp(emission_energy, 30, 100), TRUE, TRUE)
			M.Knockdown(clamp(emission_energy, 20, 100))
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
	reaction_containment -= (reaction_temperature / 50) + (current_uptime / 2000)
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
	powerdown_time = world.time
	last_power_use = 0
	power_demand_met = FALSE
	last_avail_power = 0
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

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/absorb_hit(obj/item/projectile/proj)
	var/damage = proj.damage
	if(!active)
		return SHIELD_NOEFFECT //!shields not raised

	if(shield["density"] == DENSITY_LOW && (proj.flag != "overmap_heavy" || proj.damage_type == BURN)) //Low density mode does not get hit by low impact projectiles, but also does not help vs. energy weapons.
		return SHIELD_NOEFFECT

	if(shield["integrity"] >= damage)
		shield["integrity"] -= damage //Deduct from !shield
		var/current_hit = world.time
		if(current_hit <= last_hit + 1 SECONDS) //1 Second
			shield["stability"] -= min(30, rand((damage / 10), (damage / 5))) //Rapid hits will reduce stability greatly

		else
			shield["stability"] -= min(10, rand((damage / 50), (damage / 25))) //Reduce !shield stability

		last_hit = current_hit //Set our last hit
		check_stability()
		return SHIELD_FORCE_DEFLECT

	return SHIELD_NOEFFECT

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
		var/hardening_allocation = max(((screen_hardening / 100) * reaction_energy_output), 0)
		shield["max_integrity"] = hardening_allocation * (connected_relays * 10) //Each relay is worth 10 base
		var/regen_allocation = max(((screen_regen / 100) * reaction_energy_output), 0)

		var/stability_recovery = last_power_use / ((max_power_input * 1.5) - max(min_power_input, 0))
		if(screen_regen == 100) //Stopping field emission entirely helps with stabilization.
			stability_recovery *= 5
		shield["stability"] += stability_recovery
		if(shield["stability"] > 100)
			shield["stability"] = 100
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

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/ex_act(severity, target)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	if(QDELETED(src))
		return
	if(detonating)
		return
	detonating = TRUE
	visible_message("<span class='boldwarning'>[src] destabilizes violently.</span>")
	radiation_pulse(src, 5000)
	explosion(get_turf(src), 5, 8, 0, 10, ignorecap = TRUE, flame_range = 10)
	qdel(src)




//////MAINFRAME CONSOLE//////

/obj/machinery/computer/ship/defence_screen_mainframe_reactor //For controlling the reactor
	name = "mk II Prototype Defence Screen Mainframe"
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
		playsound(src, sound, 100, TRUE)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, TRUE)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return

	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_ai(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, TRUE)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_robot(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, TRUE)
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
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!reactor)
		return
	var/adjust = text2num(params["adjust"])
	if(action == "injection_allocation")
		if(isnum(adjust))
			reactor.reaction_injection_rate = clamp(adjust, 0, 25)

	switch(action)
		if("polarity")
			reactor.reaction_polarity_injection = !reactor.reaction_polarity_injection
			return

		if("ignition")
			if(world.time < reactor.powerdown_time + 30 SECONDS)
				reactor.say("Realigning Particle Emitter - Field Unavailable.")
				return
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
	name = "mk II Prototype Defence Screen Mainframe (Computer Board)"
	build_path = /obj/machinery/computer/ship/defence_screen_mainframe_reactor

//////SCREEN MANIPULATOR//////

/obj/machinery/computer/ship/defence_screen_mainframe_shield //For controlling the !shield
	name = "mk II Prototype Defence Screen Manipulator"
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
		playsound(src, sound, 100, TRUE)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, TRUE)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return

	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_shield/attack_ai(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, TRUE)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_shield/attack_robot(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, TRUE)
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
		ui.set_autoupdate(TRUE)

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
			reactor.power_input = clamp(adjust, 0, reactor.max_power_input * 1.25)

			if(reactor.state == REACTOR_STATE_RUNNING && reactor.active)
				if(world.time >= (reactor.adjust_tracker + 1 SECONDS))
					reactor.shield["stability"] -= rand(3, 5)
					reactor.check_stability()

			reactor.adjust_tracker = world.time
		if("density")
			reactor.shield["density"] = !(reactor.shield["density"])
			if(reactor.state == REACTOR_STATE_RUNNING && reactor.active)
				if(world.time >= (reactor.adjust_tracker + 1 SECONDS))
					reactor.shield["stability"] -= rand(5, 10)
					reactor.check_stability()
			reactor.adjust_tracker = world.time

/obj/machinery/computer/ship/defence_screen_mainframe_shield/ui_data(mob/user)
	var/list/data = list()
	data["r_relay_count"] = reactor.connected_relays
	data["r_has_enough_power"] = reactor.power_demand_met
	data["r_temp"] = reactor.reaction_temperature
	data["r_power_input"] = reactor.power_input
	data["r_min_power_input"] = reactor.min_power_input
	data["r_max_power_input"] = reactor.max_power_input
	data["s_active"] = reactor.active
	data["s_regen"] = reactor.screen_regen
	data["s_hardening"] = reactor.screen_hardening
	data["s_integrity"] = reactor.shield["integrity"]
	data["s_max_integrity"] = reactor.shield["max_integrity"]
	data["s_stability"] = reactor.shield["stability"]
	data["s_density"] = reactor.shield["density"]
	data["records"] = reactor.records
	data["available_power"] = 0
	var/turf/T = get_turf(reactor)
	reactor.C = T.get_cable_node()

	if(reactor.last_power_use || reactor.last_avail_power)
		data["available_power"] = reactor.last_avail_power
	else if(reactor.C)
		data["available_power"] = reactor.C.surplus()
	else
		data["available_power"] = 0


	data["silicon"] = issilicon(user)
	var/list/cats = CATS
	data["chosenKitty"] = cats[rand(1, cats.len)]

	return data

/obj/item/circuitboard/computer/defence_screen_mainframe_shield
	name = "mk II Prototype Defence Screen Manipulator (Computer Board)"
	build_path = /obj/machinery/computer/ship/defence_screen_mainframe_shield

/obj/machinery/defence_screen_relay
	name = "mk II Prototype Defence Screen Relay"
	desc = "A relay for distributing energy to the defence screens"
	icon = 'nsv13/icons/obj/shield_components.dmi'
	icon_state = "injector"
	active_power_usage = 1000
	idle_power_usage = 1000
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/defence_screen_relay
	///If currently overloaded. Needs wires and welding to fix.
	var/overloaded = FALSE
	///If this has suffered critical damage. Needs plasteel & followup repairs.
	var/critical_damage = FALSE

/obj/item/circuitboard/machine/defence_screen_relay
	name = "mk II Prototype Defence Screen Relay (Machine Board)"
	build_path = /obj/machinery/defence_screen_relay
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5,
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
	else
		if(critical_damage)
			. += "<span class='warning'>Its protective housing is almost unrecognizable.. Maybe you could jury-rig a fix with some plasteel?</span>"
		else if(overloaded)
			. += "<span class='warning'>Its wiring has seen better days..</span>"

/obj/machinery/defence_screen_relay/proc/overload()
	if(!overloaded)
		overloaded = TRUE
		do_sparks(4, FALSE, src)
		src.atmos_spawn_air("o2=10;plasma=10;TEMP=500") //For the flashburn
		update_icon()

/obj/machinery/defence_screen_relay/update_icon()
	if(critical_damage)
		icon_state = "injector-broken" //Scrungled..
		return
	if(overloaded)
		icon_state = "injector-damaged"
		return
	if(powered())
		icon_state = "injector-on"
		return
	icon_state = "injector"
	return

/obj/machinery/defence_screen_relay/proc/atmos_check() //Atmos cooled relays
	var/turf/open/L = get_turf(src)
	if(!istype(L) || !(L.air))
		return
	var/datum/gas_mixture/E = L.return_air()
	if(E.total_moles() < 50)
		if(prob(5))
			overload()

/obj/machinery/defence_screen_relay/obj_destruction()
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	if(critical_damage)
		return
	ENABLE_BITFIELD(resistance_flags, INDESTRUCTIBLE)
	critical_damage = TRUE
	obj_integrity = 1
	if(!overloaded)
		overload()
	visible_message("<span class='warning'>[src]'s protective housing melts into an unrecognizable mess.</span>")
	update_icon()
	return


/obj/machinery/defence_screen_relay/attackby(obj/item/I, mob/living/carbon/user, params)
	if(istype(I, /obj/item/stack/cable_coil) && overloaded && !critical_damage)
		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 5)
			to_chat(user, "<span class='notice'>You need at least five cable pieces to repair the [src]!</span>")
			return
		to_chat(user, "<span class='notice'>You start rewiring the [src]...</span>")
		if(!do_after(user, 5 SECONDS, target=src))
			return
		if(!overloaded || critical_damage)
			return
		if(!C.use(5))
			return
		to_chat(user, "<span class='notice'>You rewire the [src].</span>")
		overloaded = FALSE
		update_icon()
		return

	if(istype(I, /obj/item/stack/sheet/plasteel) && critical_damage)
		var/obj/item/stack/sheet/plasteel/emergency_fix = I
		if(emergency_fix.get_amount() < 10)
			to_chat(user, "<span class='notice'>You need at least ten plasteel sheets to have any chance at fixing this mess!</span>")
			return
		to_chat(user, "<span class='notice'>You start improvised housing repairs on [src]</span>")
		if(!do_after(user, 8 SECONDS, target=src))
			return
		if(!critical_damage)
			return
		if(!emergency_fix.use(10))
			return
		to_chat(user, "<span class='notice'>You repair [src]'s housing.. Hopefully that thing won't explode in your face.</span>")
		critical_damage = FALSE
		obj_integrity = 1
		DISABLE_BITFIELD(resistance_flags, INDESTRUCTIBLE)
		update_icon()
		return

/obj/machinery/defence_screen_relay/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(critical_damage)
		to_chat(user, "<span class='warning'>You will need to replace this mess of a housing first before making any further repairs. Maybe some plasteel would help?</span>")
		return
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
		playsound(src, sound, 100, TRUE)
		visible_message("<span class='warning'>[icon2html(src, viewers(src.loc))] ACCESS DENIED.</span>")
		return FALSE
	if(!open_panel)
		if(!active)
			settings(user)
		else if(anchored)
			to_chat(user, "<span class='warning'>The bomb is bolted to the floor!</span>")

//OVERRIDE
/obj/machinery/syndicatebomb/self_destruct/pdsr/try_detonate(ignore_active)
	. = (payload in src) && (active || ignore_active)
	if(.)
		var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/goodbye = locate() in (orange(10, get_turf(src)))
		DISABLE_BITFIELD(goodbye.resistance_flags, INDESTRUCTIBLE)
		payload.detonate()


#undef DENSITY_LOW
#undef DENSITY_HIGH

#undef REACTOR_STATE_IDLE
#undef REACTOR_STATE_INITIALIZING
#undef REACTOR_STATE_RUNNING
#undef REACTOR_STATE_SHUTTING_DOWN
#undef REACTOR_STATE_EMISSION
#undef CATS
