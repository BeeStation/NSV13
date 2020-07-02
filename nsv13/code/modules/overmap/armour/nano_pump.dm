//PUMP GOES HERE
#define OFFLINE 0
#define ONLINE 1

/obj/machinery/armour_plating_nanorepair_pump
	name = "Armour Plating Nano-repair Pump"
	desc = "AP thingies that link to the Well"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 50
	active_power_usage = 1000 //temp
	var/obj/machinery/armour_plating_nanorepair_well/apnw //parent device
	var/state = 0
	var/quadrant = 0
	var/quadrant_armour_current = 0
	var/quadrant_armour_max = 0
	var/armour_allocation = 0
	var/structure_allocation = 0
	var/apnw_id = 0

/obj/machinery/armour_plating_nanorepair_pump/forward_port
	quadrant = 1

/obj/machinery/armour_plating_nanorepair_pump/aft_port
	quadrant = 2

/obj/machinery/armour_plating_nanorepair_pump/aft_starboard
	quadrant = 3

/obj/machinery/armour_plating_nanorepair_pump/forward_port
	quadrant = 4

/obj/machinery/armour_plating_nanorepair_pump/Initialize()

/obj/machinery/armour_plating_nanorepair_pump/LateInitialize()
	if(apnw_id) //If mappers set an ID)
		for(var/obj/machinery/armour_plating_nanorepair_well/W in GLOB.machines)
			if(W.apnw_id == apnw_id)
				apnw = W
/*
/obj/machinery/armour_plating_nanorepair_pump/examine(mob/user)
	.=..()
	. += "<span class='notice'>This APNP is aligned to [quadrant.designation]</span>"
*/

/obj/machinery/armour_plating_nanorepair_pump/process()
	if(state == OFFLINE)
		return
	else if(state == ONLINE)
		if(quadrant_armour_current <= quadrant_armour_max) //Basic Implementation
			var/repair_amount = min(((1 / 0.01 + (NUM_E ** (((quadrant_armour_current/quadrant_armour_max) * -100) / 2))) * apnw.repair_efficiency * armour_allocation), quadrant_armour_max - quadrant_armour_current) //Math time
			if(apnw.repair_resources >= repair_amount)
				quadrant_armour_current += repair_amount
				apnw.repair_resources -= repair_amount
				active_power_usage = repair_amount * 100 //test case

#undef OFFLINE
#undef ONLINE