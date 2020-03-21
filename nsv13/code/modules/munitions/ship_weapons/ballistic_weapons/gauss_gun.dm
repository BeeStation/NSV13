/obj/machinery/ship_weapon/gauss_gun
	name = "NT-BSG Gauss Turret"
	desc = "A large ship to ship weapon designed to provide a constant barrage of fire over a long distance. It has a small cockpit for a gunner to control it manually."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "gauss"
	bound_width = 96
	bound_height = 96
	pixel_x = -44

	fire_mode = FIRE_MODE_GAUSS
	weapon_type = new/datum/ship_weapon/gauss
	ammo_type = /obj/item/ship_weapon/ammunition/gauss

	semi_auto = TRUE
	max_ammo = 4 //Until you have to manually load it back up again. Battleships IRL have 3-4 shots before you need to reload the rack
	firing_sound = 'nsv13/sound/effects/ship/gauss.ogg'
	fire_animation_length = 1 SECONDS
	var/mob/living/carbon/human/gunner = null

/obj/machinery/ship_weapon/gauss_gun/verb/show_computer()
	set name = "Access internal computer"
	set category = "Gauss gun"
	set src = usr.loc

	if(gunner.incapacitated() || !isliving(gunner))
		return
	linked_computer.attack_hand(gunner)
	to_chat(gunner, "<span class='notice'>You reach for [src]'s control panel.</span>")

/obj/machinery/ship_weapon/gauss_gun/Initialize()
	. = ..()
	linked_computer = new /obj/machinery/computer/ship/munitions_computer(src)
	linked_computer.SW = src

/obj/machinery/ship_weapon/gauss_gun/attack_hand(mob/user)
	if(gunner)
		to_chat(user, "<span class='notice'>Someone is already in this turret!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You start to climb into [src]...</span>")
	if(do_after(user, 3 SECONDS, target=src))
		user.forceMove(src)
		gunner = user
		linked_computer.attack_hand(user)
		linked.start_piloting(user, "observer")

/obj/machinery/ship_weapon/gauss_gun/proc/remove_gunner()
	gunner.forceMove(get_turf(src))
	gunner = null

/obj/machinery/ship_weapon/gauss_gun/north
	dir = NORTH

/obj/machinery/ship_weapon/gauss_gun/east
	dir = EAST

/obj/machinery/ship_weapon/gauss_gun/west
	dir = WEST