/**
 * Munitions computer circuitboard
 */
/obj/item/circuitboard/computer/ship/munitions_computer
	name = "circuit board (munitions control computer)"
	build_path = /obj/machinery/computer/ship/munitions_computer

/**
 * PDC/Flak mount circuitboard
 */
/obj/item/circuitboard/machine/pdc_mount
	name = "circuit board (pdc mount)"
	desc = "You can use a screwdriver to switch between PDC and flak."
	req_components = list(
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/ship_weapon/parts/firing_electronics = 1
	)

#define PATH_PDC /obj/machinery/ship_weapon/pdc_mount
#define PATH_FLAK  /obj/machinery/ship_weapon/pdc_mount/flak

/obj/item/circuitboard/machine/pdc_mount/Initialize()
	. = ..()
	if(!build_path)
		if(prob(50))
			name = "PDC Loading Rack (Machine Board)"
			build_path = PATH_PDC
		else
			name = "Flak Loading Rack (Machine Board)"
			build_path = PATH_FLAK

/obj/item/circuitboard/machine/pdc_mount/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/obj/item/circuitboard/new_type
		var/new_setting
		switch(build_path)
			if(PATH_PDC)
				new_type = /obj/item/circuitboard/machine/pdc_mount/flak
				new_setting = "Flak"
			if(PATH_FLAK)
				new_type = /obj/item/circuitboard/machine/pdc_mount/
				new_setting = "PDC"
		name = initial(new_type.name)
		build_path = initial(new_type.build_path)
		I.play_tool_sound(src)
		to_chat(user, "<span class='notice'>You change the circuitboard setting to \"[new_setting]\".</span>")
		return
		
/obj/item/circuitboard/machine/pdc_mount
	name = "PDC Mount (Machine Board)"
	build_path = PATH_PDC

/obj/item/circuitboard/machine/pdc_mount/flak
	name = "Flak Loading Rack (Machine Board)"
	build_path = PATH_FLAK

#undef PATH_PDC
#undef PATH_FLAK

/**
 * Firing electronics - used for pdcs, torp tubes, and railguns
 */
/obj/item/ship_weapon/parts/firing_electronics
	name = "firing electronics"
	icon = 'icons/obj/module.dmi'
	icon_state = "mcontroller"

/**
 * Railgun loading tray
 */
/obj/item/ship_weapon/parts/loading_tray
	name = "loading tray"
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "railgun_tray"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/loading_tray/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)

/**
 * Railgun rail
 */
/obj/item/ship_weapon/parts/railgun_rail
	name = "rail"
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "railgun_rail"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/railgun_rail/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)
	
/**
 * MAC Barrel
 */
/obj/item/ship_weapon/parts/mac_barrel
	name = "barrel"
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "mac_barrel"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/mac_barrel/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)