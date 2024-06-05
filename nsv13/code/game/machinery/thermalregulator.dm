#define COOLANT_INPUT_GATE airs[1]
#define COOLANT_OUTPUT_GATE airs[2]

/obj/machinery/atmospherics/components/binary/thermalregulator
	name = "thermal regulator"
	desc = "The heat regulator that helps cool energy weapons"
	icon = 'nsv13/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "plasma_condenser"
	pixel_y = 5 //So it lines up with layer 3 piping
	layer = OBJ_LAYER
	density = TRUE
	dir = WEST
	initialize_directions = WEST
	pipe_flags = PIPING_ONE_PER_TURF
	active_power_usage = 200
	var/obj/machinery/ship_weapon/energy/linked_gun
	var/temperature = 0
	var/gas_absorption_effectiveness = 0.5
	var/gas_absorption_constant = 0.5
	var/last_coolant_temperature = 0
	var/last_output_temperature = 0
	var/last_heat_delta = 0
	var/minimum_coolant_level = 5
	var/next_slowprocess = 0

/obj/machinery/atmospherics/components/binary/thermalregulator/on_construction()
	var/obj/item/circuitboard/machine/thermomachine/board = circuit
	if(board)
		piping_layer = board.pipe_layer
	..(dir, piping_layer)

/obj/machinery/atmospherics/components/binary/thermalregulator/attack_hand(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, "<span class='notice'>You must turn close the panel on [src] before turning it on.</span>")
		return
	to_chat(user, "<span class='notice'>You press [src]'s power button.</span>")
	on = !on
	update_icon()

/obj/machinery/atmospherics/components/binary/thermalregulator/update_icon()
	cut_overlays()
	if(panel_open)
		icon_state = "plasma_condenser_screw"
	else if(on)
		icon_state = "plasma_condenser_active"
	else
		icon_state = "plasma_condenser"

/obj/machinery/atmospherics/components/binary/thermalregulator/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS )
	gas_absorption_effectiveness = rand(5, 6)/10 //All reactors are slightly different. This will result in you having to figure out what the balance is for K.
	gas_absorption_constant = gas_absorption_effectiveness //And set this up for the rest of the round.


/obj/machinery/atmospherics/components/binary/thermalregulator/process()
	update_parents() //Update the pipenet to register new gas mixes
	if(!on)
		return
	if(!linked_gun)
		return

	//Let's get our gasses sorted out.
	var/datum/gas_mixture/coolant_input = COOLANT_INPUT_GATE
	var/datum/gas_mixture/coolant_output = COOLANT_OUTPUT_GATE

	temperature = linked_gun.heat

	//Firstly, heat up the reactor based off of K.
	var/input_moles = coolant_input.total_moles() //Firstly. Do we have enough moles of coolant?
	if(input_moles >= minimum_coolant_level)
		last_coolant_temperature = KELVIN_TO_CELSIUS(coolant_input.return_temperature())
		//Important thing to remember, once you slot in the fuel rods, this thing will not stop making heat, at least, not unless you can live to be thousands of years old which is when the spent fuel finally depletes fully.
		var/heat_delta = (KELVIN_TO_CELSIUS(coolant_input.return_temperature()) / 50) * gas_absorption_effectiveness //Take in the gas as a cooled input, cool the reactor a bit. The optimum, 100% balanced reaction sits at K=1, coolant input temp of 200K / -73 celsius.
		last_heat_delta = heat_delta
		temperature += heat_delta
		coolant_output.merge(coolant_input) //And now, shove the input into the output.
		coolant_input.clear() //Clear out anything left in the input gate.


	//Now, heat up the output and set our pressure.
	coolant_output.set_temperature(CELSIUS_TO_KELVIN(temperature)) //Heat the coolant output gas that we just had pass through us.
	last_output_temperature = KELVIN_TO_CELSIUS(coolant_output.return_temperature())

	linked_gun.heat = temperature
