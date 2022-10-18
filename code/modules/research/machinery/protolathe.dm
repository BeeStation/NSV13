/obj/machinery/rnd/production/protolathe
	name = "protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/protolathe
	categories = list(
								"Power Designs",
								"Medical Designs",
								"Bluespace Designs",
								"Stock Parts",
								"Equipment",
								"Tool Designs",
								"Mining Designs",
								"Electronics",
								"Weapons",
								"Ammo",
								"Firing Pins",
								"Computer Parts",
								"Advanced Munitions", //NSV13
								"Asteroid Mining", //NSV13
								"Ship Components", //NSV13
								"Vehicles", //NSV13
								"Circuitry"
								)
	production_animation = "protolathe_n"
	allowed_buildtypes = PROTOLATHE
	consoleless_interface = TRUE
	requires_console = FALSE
//nsv13 added Advanced Munitions, Ship Components, Vehicles Asteroid Mining list above

/obj/machinery/rnd/production/protolathe/disconnect_console()
	linked_console.linked_lathe = null
	..()
