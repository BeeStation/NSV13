/datum/keybinding/overmap
		category = CATEGORY_OVERMAP
		weight = WEIGHT_OVERMAP

/datum/keybinding/overmap/toggle_inertia
	key = "X"
	name = "toggle_inertia"
	full_name = "Toggle Inertia"
	description = ""

/datum/keybinding/overmap/toggle_inertia/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.get_overmap()
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
	full_name = "Toggle Movement Mode"
	description = ""

/datum/keybinding/overmap/toggle_move_mode/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.get_overmap()
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

/datum/keybinding/overmap/cycle_firemode/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.get_overmap()
	if(!OM) return

	if(M != OM.gunner) return
	OM.cycle_firemode()
	if(OM.tactical && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(OM.tactical, sound, 100, 1)
	return TRUE

/datum/keybinding/overmap/suppress_drop
	key = "Q"
	name = "suppress_drop"
	full_name = "Suppress Drop"
	description = "Intercepts the drop action"

/datum/keybinding/overmap/suppress_drop/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.get_overmap()
	if(!OM) return

	if(M != OM.pilot) return
	return TRUE

// Small craft - safeties and countermeasures
/datum/keybinding/overmap/toggle_safety
	key = "Capslock"
	name = "toggle_safety"
	full_name = "Toggle Safeties"
	description = ""

/datum/keybinding/overmap/toggle_safety/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/small_craft/OM = M.get_overmap()
	if(!istype(OM)) return

	if(M != OM.gunner) return
	OM.toggle_safety()
	if(OM.helm && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(OM.helm, sound, 100, 1)
	return TRUE

/datum/keybinding/overmap/deploy_countermeasure
	key = "5"
	name = "deploy_countermeasure"
	full_name = "Deploy Countermeasure"
	description = ""

/datum/keybinding/overmap/deploy_countermeasure/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/small_craft/OM = M.get_overmap()
	if(!istype(OM)) return

	if(M != OM.pilot) return
	OM.countermeasure()
	return TRUE

// Keys that are held down in other binding modes need both a down and an up to override correctly
/datum/keybinding/overmap/boost
	key = "Shift"
	name = "boost"
	full_name = "Boost"
	description = ""

/datum/keybinding/overmap/boost/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.get_overmap()
	if(!OM) return

	if(M != OM.pilot) return
	OM.boost(NORTH)
	return TRUE

/datum/keybinding/overmap/boost/up(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.get_overmap()
	if(!OM) return

	if(M != OM.pilot) return
	return TRUE

/datum/keybinding/overmap/toggle_brakes
	key = "Alt"
	name = "toggle_brakes"
	full_name = "Toggle Brakes"
	description = ""

/datum/keybinding/overmap/toggle_brakes/down(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.get_overmap()
	if(!OM) return

	if(M != OM.pilot) return
	OM.toggle_brakes()
	if(OM.helm && prob(80))
		var/sound = pick(GLOB.computer_beeps)
		playsound(OM.helm, sound, 100, 1)
	return TRUE

/datum/keybinding/overmap/toggle_brakes/up(client/user)
	if(!user.mob) return
	var/mob/M = user.mob
	var/obj/structure/overmap/OM = M.get_overmap()
	if(!OM) return

	if(M != OM.pilot) return
	return TRUE
