/obj/machinery/cooling
	name = "subspace unit"
	desc = "A subspace unit."
	icon = 'nsv13/icons/obj/subspace.dmi'
	icon_state = "cooler"
	circuit = /obj/item/circuitboard/machine
	bound_width = 32
	pixel_x = 0
	pixel_y = 0
	idle_power_usage =  2000
	var/obj/machinery/ship_weapon/energy/parent
	var/on = FALSE
	density = TRUE
	critical_machine = TRUE

/obj/machinery/cooling/cooler
	name = "subspace cooling unit"
	desc = "A cooling unit that dumps the massive amounts of heat energy weapons generate into subspace."
	circuit = /obj/item/circuitboard/machine/cooling



/obj/machinery/cooling/cooler/Initialize(mapload)
	. = ..()
	var/obj/machinery/ship_weapon/energy/E = locate(/obj/machinery/ship_weapon/energy) in orange(1, src) //I have no idea what I'm doing and this causes errors so
	E.coolers |= src
	parent = E

/obj/machinery/cooling/storage/Initialize(mapload)
	. = ..()
	var/obj/machinery/ship_weapon/energy/E = locate(/obj/machinery/ship_weapon/energy) in orange(1, src)
	E.storages |= src
	parent = E


/obj/machinery/cooling/cooler/Destroy()
  parent.coolers -= src
  . = ..()

/obj/machinery/cooling/storage/Destroy()
  parent.storages -= src
  . = ..()

/obj/machinery/cooling/attack_hand(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, "<span class='notice'>You must turn close the panel on [src] before turning it on.</span>")
		return
	to_chat(user, "<span class='notice'>You press [src]'s power button.</span>")
	on = !on
	update_icon()

/obj/machinery/cooling/examine()
	. = ..()
	if(on)
		. += "The power is on"
	if(parent)
		. += "The thermal subspace transcever is linked"
	else
		. += "it's completely inactive"


/obj/machinery/cooling/update_icon()
	cut_overlays()
	if(panel_open)
//		icon_state = "smes-o"
	if(on && parent)
//		add_overlay("smes-op1")
	if(on)
//		add_overlay("smes-oc1")
	else
//		add_overlay("smes-op0")


/obj/machinery/cooling/multitool_act(mob/living/user, obj/item/multitool/I)
	if(!multitool_check_buffer(user, I))
		return
	var/obj/item/multitool/P = I

	if(istype(P.buffer, /obj/machinery/ship_weapon/energy))
		if(get_area(P.buffer) != get_area(src))
			to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. %-</font color>")
			return

		parent = P.buffer
		if(istype(src,/obj/machinery/cooling/cooler))
			.=TRUE
			parent.coolers |= src
			to_chat(user, "<font color = #666633>-% Successfully linked [P.buffer] with [src] %-</font color>")
		if(istype(src,/obj/machinery/cooling/storage))
			.=TRUE
			parent.storages |= src
			to_chat(user, "<font color = #666633>-% Successfully linked [P.buffer] with [src] %-</font color>")
		if(length(parent.storages)+length(parent.coolers) >= 10)
			var/E = pick(parent.storages+parent.coolers)
			explosion(get_turf(E), 0, 1, 3, 5, flame_range = 4)
			return

		return


/obj/machinery/cooling/storage
	name = "subspace heatsink unit"
	desc = "A cooling unit that stores the massive amounts of heat energy weapons generate in subspace."
	icon_state = "cooler"
	circuit = /obj/item/circuitboard/machine/cooling/storage

