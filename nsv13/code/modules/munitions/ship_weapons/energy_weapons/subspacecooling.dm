/obj/machinery/cooling
	name = "subspace cooling unit"
	desc = "A cooling unit that dumps the massive amounts of heat energy weapons generate into subspace."
	icon ='nsv13/icons/obj/energy_weapons.dmi'
	icon_state = "phase_cannon"
	circuit = /obj/item/circuitboard/machine/burst_phaser
	bound_width = 32
	pixel_x = -32
	pixel_y = -32
	idle_power_usage =  2000
	var/active = FALSE
	var/obj/ship_weapons/energy/parent


	/obj/machinery/cooling/Initialize(mapload)
		 = ..()
		parent = locate(/obj/ship_weapons/energy) in orange(1, src)

	/obj/machinery/cooling/process(delta_time)
		 = ..()
		if(parent.heat > 0)
			parent.heat = max(parent.heat-50, 0)
