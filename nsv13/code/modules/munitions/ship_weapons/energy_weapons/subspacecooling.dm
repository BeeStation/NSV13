/obj/machinery/cooling
	name = "subspace cooling unit"
	desc = "A cooling unit that dumps the massive amounts of heat energy weapons generate into subspace."
	icon ='nsv13/icons/obj/energy_weapons.dmi'
	icon_state = "phase_cannon"
	circuit = /obj/item/circuitboard/machine/cooling
	bound_width = 32
	pixel_x = -32
	pixel_y = -32
	idle_power_usage =  2000
	var/obj/ship_weapons/energy/parent
	var/function = heat


/obj/machinery/cooling/Initialize(mapload)
	 = ..()
	parent = locate(/obj/ship_weapons/energy) in orange(1, src)

/obj/machinery/cooling/process(delta_time)
	 = ..()
	 if(!on)
		return
	if(!parent)
		return
	if(parent.[function] > 0)
		parent.[function] = max(parent.[function]-50, 0)

/obj/machinery/cooling/attack_hand(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, "<span class='notice'>You must turn close the panel on [src] before turning it on.</span>")
		return
	to_chat(user, "<span class='notice'>You press [src]'s power button.</span>")
	on = !on
	update_icon()



/obj/machinery/cooling/storage
	name = "subspace heatsink unit"
	desc = "A cooling unit that stores the massive amounts of heat energy weapons generate in subspace."
	icon ='nsv13/icons/obj/energy_weapons.dmi'
	icon_state = "phase_cannon"
	circuit = /obj/item/circuitboard/machine/cooling/storage
	function = max_heat
