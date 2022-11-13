// Laser PD system control console
/obj/machinery/computer/laser_pd
	name = "point-defense laser console"
	desc = "A computer that allows you to control a connected point-defense."
	icon_screen = "50cal"
	circuit = /obj/item/circuitboard/computer/laser_pd
	var/obj/machinery/ship_weapon/energy/laser_pd/turret

/obj/machinery/computer/laser_pd/Initialize(mapload)
	. = ..()
	turret = locate(/obj/machinery/ship_weapon/energy/laser_pd) in get_step(src, dir)

/obj/machinery/computer/laser_pd/attack_robot(mob/user)
	. = ..()
	return attack_hand(user)

/obj/machinery/computer/laser_pd/attack_ai(mob/user)
	. = ..()
	return attack_hand(user)

/obj/machinery/computer/laser_pd/multitool_act(mob/living/user, obj/item/multitool/tool)
	..()
	. = TRUE
	var/obj/machinery/ship_weapon/energy/laser_pd/stored_gun = tool.buffer
	if(stored_gun && istype(stored_gun))
		turret = stored_gun
		to_chat(user, "<span class='warning'>Successfully linked [src] to [turret].")
	else
		to_chat(user, "<span class='warning'>No compatible weapon type found in buffer.")

/obj/machinery/computer/laser_pd/attack_hand(mob/user)
	. = ..()
	if(!turret)
		to_chat(user, "<span class='warning'>This computer is not linked to a laser turret! You can link it with a multitool.</span>")
		return
	turret.start_gunning(user)

// Overmap gunning component for laser PD
/datum/component/overmap_gunning/laser_pd
	fire_mode = FIRE_MODE_LASER_PD
	fire_delay = 1 SECONDS

// The laser PD turret itself
/obj/machinery/ship_weapon/energy/laser_pd
	name = "laser point defense turret"
	desc = "A low-wattage laser designed to provide close-combat relief to large ships."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "gauss"
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	pixel_x = -44
	obj_integrity = 500
	max_integrity = 500

	fire_mode = FIRE_MODE_LASER_PD
	energy_weapon_type = /datum/ship_weapon/phaser_pd
	charge = 0
	charge_rate = 330000 //How quickly do we charge?
	charge_per_shot = 660000 //How much power per shot do we have to use?

	circuit = /obj/item/circuitboard/machine/laser_pd
	var/gunning_component_type = /datum/component/overmap_gunning/laser_pd
	var/mob/gunner = null
	var/next_sound = 0

/obj/machinery/ship_weapon/energy/laser_pd/proc/start_gunning(mob/user)
	if(gunner)
		remove_gunner()
	gunner = user
	user.AddComponent(gunning_component_type, src, TRUE)

/obj/machinery/ship_weapon/energy/laser_pd/proc/remove_gunner()
	get_overmap().stop_piloting(gunner)
