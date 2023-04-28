/datum/keybinding/overmap
		category = CATEGORY_OVERMAP
		weight = WEIGHT_OVERMAP


// Strafing AND turning? It's more likely than you think!
/datum/keybinding/overmap/rotate_left
	key = "Q"
	name = "rotate_left"
	full_name = "Rotate Left"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_ROTATELEFT_DOWN

/datum/keybinding/overmap/rotate_left/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	if(OM.move_by_mouse) return
	OM.keyboard_delta_angle_left = -15
	return TRUE

/datum/keybinding/overmap/rotate_left/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	if(OM.move_by_mouse) return
	OM.keyboard_delta_angle_left = 0
	return TRUE

/datum/keybinding/overmap/rotate_right
	key = "E"
	name = "rotate_right"
	full_name = "Rotate Right"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_ROTATERIGHT_DOWN

/datum/keybinding/overmap/rotate_right/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	if(OM.move_by_mouse) return
	OM.keyboard_delta_angle_right = 15
	return TRUE

/datum/keybinding/overmap/rotate_right/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	if(OM.move_by_mouse) return
	OM.keyboard_delta_angle_right = 0
	return TRUE

// Keys that are held down in other binding modes need both a down and an up to override correctly
/datum/keybinding/overmap/boost
	key = "Shift"
	name = "boost"
	full_name = "Boost"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_BOOST_DOWN

/datum/keybinding/overmap/boost/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	OM.boost(NORTH)
	return TRUE

/datum/keybinding/overmap/boost/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	return TRUE

/datum/keybinding/overmap/toggle_brakes
	key = "Alt"
	name = "toggle_brakes"
	full_name = "Toggle Brakes"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_TOGGLEBRAKES_DOWN

/datum/keybinding/overmap/toggle_brakes/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	OM.toggle_brakes()
	if(OM.helm && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(OM.helm, sound, 100, 1)
	return TRUE

/datum/keybinding/overmap/toggle_brakes/up(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	return TRUE

// Other ship controls
/datum/keybinding/overmap/toggle_inertia
	key = "X"
	name = "toggle_inertia"
	full_name = "Toggle Inertial Assistance"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_TOGGLEINERTIA_DOWN

/datum/keybinding/overmap/toggle_inertia/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	OM.toggle_inertia()
	if(OM.helm && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(OM.helm, sound, 100, 1)
	return TRUE

/datum/keybinding/overmap/toggle_move_mode
	key = "C"
	name = "toggle_move_mode"
	full_name = "Toggle Mouse Movement"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_TOGGLEMOUSEMOVE_DOWN

/datum/keybinding/overmap/toggle_move_mode/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.pilot) return
	OM.toggle_move_mode()
	if(OM.helm && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(OM.helm, sound, 100, 1)
	return TRUE

/datum/keybinding/overmap/cycle_firemode
	key = "Space"
	name = "cycle_firemode"
	full_name = "Cycle Firemode"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_CYCLEFIREMODE_DOWN

/datum/keybinding/overmap/cycle_firemode/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.gunner) return
	OM.cycle_firemode()
	if(OM.tactical && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(OM.tactical, sound, 100, 1)
	return TRUE

// Small craft - safeties and countermeasures

/datum/keybinding/overmap/deploy_countermeasure
	key = "5"
	name = "deploy_countermeasure"
	full_name = "Deploy Countermeasure"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_COUNTERMEASURE_DOWN

/datum/keybinding/overmap/deploy_countermeasure/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/small_craft/OM = M.overmap_ship
	if(!istype(OM)) return

	if(M != OM.pilot) return
	OM.countermeasure()
	return TRUE

/datum/keybinding/overmap/toggle_safety
	key = "Capslock"
	name = "toggle_safety"
	full_name = "Toggle Safeties"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_TOGGLESAFETY_DOWN

/datum/keybinding/overmap/toggle_safety/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/small_craft/OM = M.overmap_ship
	if(!istype(OM)) return

	if(M != OM.gunner) return
	OM.toggle_safety()
	if(OM.helm && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(OM.helm, sound, 100, 1)
	return TRUE

// Weapon selection - this is overly complicated but probably useful as a proof of concept
/datum/keybinding/overmap/weapon_1
	key = "1"
	name = "weapon_1"
	full_name = "Weapon 1"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_WEAPON1_DOWN

/datum/keybinding/overmap/weapon_1/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.gunner) return
	OM.select_weapon(1)
	return TRUE

/datum/keybinding/overmap/weapon_2
	key = "2"
	name = "weapon_2"
	full_name = "Weapon 2"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_WEAPON2_DOWN

/datum/keybinding/overmap/weapon_2/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.gunner) return
	OM.select_weapon(2)
	return TRUE

/datum/keybinding/overmap/weapon_3
	key = "3"
	name = "weapon_3"
	full_name = "Weapon 3"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_WEAPON3_DOWN

/datum/keybinding/overmap/weapon_3/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.gunner) return
	OM.select_weapon(3)
	return TRUE

/datum/keybinding/overmap/weapon_4
	key = "4"
	name = "weapon_4"
	full_name = "Weapon 4"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_WEAPON4_DOWN

/datum/keybinding/overmap/weapon_4/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.gunner) return
	OM.select_weapon(4)
	return TRUE

/datum/keybinding/overmap/unlock
	key = "6"
	name = "unlock"
	full_name = "Unlock All Targets"
	description = ""
	keybind_signal = COMSIG_KB_OVERMAP_UNLOCK_DOWN

/datum/keybinding/overmap/unlock/down(client/user)
	. = ..()
	if(.)
		return
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.overmap_ship
	if(!OM) return

	if(M != OM.gunner) return
	OM.dump_locks()
	return TRUE
