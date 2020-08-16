//For my sanity :))

#define COOLANT_INPUT_GATE airs[1]
#define MODERATOR_INPUT_GATE airs[2]
#define COOLANT_OUTPUT_GATE airs[3]

#define RBMK_TEMPERATURE_OPERATING 640 //Celsius
#define RBMK_TEMPERATURE_CRITICAL 800 //At this point the entire ship is alerted to a meltdown. This may need altering
#define RBMK_TEMPERATURE_MELTDOWN 900

#define RBMK_PRESSURE_OPERATING 1000 //PSI
#define RBMK_PRESSURE_CRITICAL 1469.59 //KPA

//Math. Lame.
#define KPA_TO_PSI(A) (A/6.895)
#define PSI_TO_KPA(A) (A*6.895)
#define KELVIN_TO_CELSIUS(A) (A-273.15)

//Reference: Heaters go up to 500K.
//Hot plasmaburn: 14164.95 C.

//Remember kids. If the reactor itself is not physically powered by an APC, it cannot shove coolant in!

//Helper proc to set a new looping ambience, and play it to any mobs already inside of that area.
/area/proc/set_looping_ambience(sound)
	if(looping_ambience == sound)
		return FALSE
	looping_ambience = sound
	var/list/affecting = list() //Which mobs are we about to transmit to?
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.linked_areas?.len)
			if(src in OM.linked_areas)
				affecting = OM.mobs_in_ship
	if(!affecting.len) //OK, we can't get away with the cheaper check.
		for(var/mob/L in src) //This is really really expensive, please use this proc on non-overmap supported areas sparingly!
			if(!istype(L))
				continue
			affecting += L
	for(var/mob/L in affecting)
		if(L.client && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE && L.client?.last_ambience != looping_ambience)
			L.client.ambience_playing = 1
			SEND_SOUND(L, sound(looping_ambience, repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ))
			L.client.last_ambience = looping_ambience
	return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor
	name = "Advanced Gas-Cooled Nuclear Reactor"
	desc = "A tried and tested design which can output stable power at an acceptably low risk. The moderator can be changed to provide different effects."
	icon = 'nsv13/icons/obj/machinery/rbmk.dmi'
	icon_state = "reactor_off"
	pixel_x = -32
	pixel_y = -32
	density = FALSE //It burns you if you're stupid enough to walk over it.
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_color = LIGHT_COLOR_CYAN
	dir = 8 //Less headache inducing :))
	//Variables essential to operation
	obj_integrity = 300 //The reactor will take damage when it's melting down or about to blowout. This gives you a small window to correct the error.
	max_integrity = 300
	var/temperature = 0 //Lose control of this -> Meltdown

	var/pressure = 0 //Lose control of this -> Blowout
	var/K = 0 //Rate of reaction.
	var/power = 0 //0-100%. A function of the maximum heat you can achieve within operating temperature
	var/power_modifier = 1 //Upgrade me with parts, science! Flat out increase to physical power output when loaded with plasma.
	var/list/control_rods = list()
	//Secondary variables.
	var/next_slowprocess = 0
	var/gas_absorption_effectiveness = 0.5
	var/minimum_coolant_level = 5
	var/warning = FALSE //Have we begun warning the crew of their impending death?
	var/next_warning = 0 //To avoid spam.

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/Initialize()
	. = ..()
	gas_absorption_effectiveness = rand(5, 6)/10 //All reactors are slightly different. This will result in you having to figure out what the balance is for K.

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM) && temperature > 0)
		var/mob/living/L = AM
		L.adjust_bodytemperature(CLAMP(temperature, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)) //If you're on fire, you heat up!

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/process()
	update_parents() //Update the pipenet to register new gas mixes
	if(next_slowprocess < world.time)
		slowprocess()
		next_slowprocess = world.time + 1 SECONDS //Set to wait for another second before processing again, we don't need to process more than once a second

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/slowprocess()
	//Let's get our gasses sorted out.
	var/datum/gas_mixture/coolant_input = COOLANT_INPUT_GATE
	var/datum/gas_mixture/moderator_input = MODERATOR_INPUT_GATE
	var/datum/gas_mixture/coolant_output = COOLANT_OUTPUT_GATE

	//Firstly, heat up the reactor based off of K.
	temperature += K
	var/input_moles = coolant_input.total_moles() //Firstly. Do we have enough moles of coolant?
	if(input_moles >= minimum_coolant_level)
		//Important thing to remember, once you slot in the fuel rods, this thing will not stop making heat, at least, not unless you can live to be thousands of years old which is when the spent fuel finally depletes fully.
		var/heat_delta = (KELVIN_TO_CELSIUS(coolant_input.return_temperature()) / 100) * gas_absorption_effectiveness //Take in the gas as a cooled input, cool the reactor a bit. The optimum, 100% balanced reaction sits at K=1, coolant input temp of 200K / -73 celsius.
		message_admins("Delta C: [heat_delta]")
		temperature += heat_delta
		message_admins("Temp: [temperature]")
		coolant_output.merge(coolant_input) //And now, shove the input into the output.
		coolant_input.clear() //Clear out anything left in the input gate.
		message_admins("Coolant temp: [coolant_output.return_temperature()] K")
	//Now, heat up the output and set our pressure.
	coolant_output.set_temperature(CELSIUS_TO_KELVIN(temperature)) //Heat the coolant output gas that we just had pass through us.
	pressure = KPA_TO_PSI(coolant_output.return_pressure())
	power = (temperature / RBMK_TEMPERATURE_OPERATING) * 100
	message_admins("PSI: [pressure]")
	handle_alerts() //Let's check if they're about to die, and let them know.
	update_icon()

//Method to handle sound effects, reactor warnings, all that jazz.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/handle_alerts()
	var/alert = FALSE //If we have an alert condition, we'd best let people know.
	if(K <= 0 && temperature <= 0)
		shut_down()
	//First alert condition: Overheat
	if(temperature >= RBMK_TEMPERATURE_CRITICAL)
		alert = TRUE
	else
		alert = FALSE
	//Second alert condition: Overpressurized (the more lethal one)
	if(pressure >= RBMK_PRESSURE_CRITICAL)
		alert = TRUE
		shake_animation(0.5)
		playsound(loc, 'sound/machines/clockcult/steam_whoosh.ogg', 100, TRUE)
		var/turf/T = get_turf(src)
		T.atmos_spawn_air("water_vapor=[pressure/100];TEMP=[CELSIUS_TO_KELVIN(temperature)]")
		take_damage(pressure/100)
		if(obj_integrity <= pressure/100) //It wouldn't be able to tank another hit.
			blowout()
	var/obj/structure/overmap/OM = get_overmap()
	if(!OM) //Can't be bothered to do this any other way ;)
		return
	if(warning)
		if(!alert) //Congrats! You stopped the meltdown / blowout.
			OM?.stop_relay(CHANNEL_REACTOR_ALERT)
			warning = FALSE
			set_light(0)
			light_color = LIGHT_COLOR_CYAN
			set_light(10)
	else
		if(!alert)
			return
		if(world.time < next_warning)
			return
		next_warning = world.time + 30 SECONDS //To avoid engis pissing people off when reaaaally trying to stop the meltdown or whatever.
		warning = TRUE //Start warning the crew of the imminent danger.
		OM?.relay('nsv13/sound/effects/rbmk/alarm.ogg', null, loop=TRUE, channel = CHANNEL_REACTOR_ALERT)
		set_light(0)
		light_color = LIGHT_COLOR_RED
		set_light(10)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/blowout()
	return FALSE //Not implemented just yet

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/update_icon()
	icon_state = initial(icon_state)
	switch(temperature)
		if(0 to 200)
			icon_state = "reactor_on"
		if(200 to RBMK_TEMPERATURE_OPERATING)
			icon_state = "reactor_hot"
		if(RBMK_TEMPERATURE_OPERATING to 750)
			icon_state = "reactor_veryhot"
		if(750 to RBMK_TEMPERATURE_CRITICAL) //Point of no return.
			icon_state = "reactor_overheat"
		if(RBMK_TEMPERATURE_CRITICAL to INFINITY)
			icon_state = "reactor_meltdown"
	if(K <= 0)
		icon_state = "reactor_off"


//Startup, shutdown

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/start_up()
	K = 1
	set_light(10)
	var/area/AR = get_area(src)
	AR.set_looping_ambience('nsv13/sound/effects/rbmk/reactor_hum.ogg')
	var/startup_sound = pick('nsv13/sound/effects/ship/reactor/startup.ogg', 'nsv13/sound/effects/ship/reactor/startup2.ogg')
	playsound(loc, startup_sound, 100)

//Shuts off the fuel rods, ambience, etc. Keep in mind that your temperature may still go up!
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/shut_down()
	set_light(0)
	var/area/AR = get_area(src)
	AR.set_looping_ambience('nsv13/sound/ambience/shipambience.ogg')
	K = 0
	temperature = 0
	update_icon()
