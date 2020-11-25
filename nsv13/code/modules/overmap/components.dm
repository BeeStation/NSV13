GLOBAL_LIST_INIT(computer_beeps, list('nsv13/sound/effects/computer/beep.ogg','nsv13/sound/effects/computer/beep2.ogg','nsv13/sound/effects/computer/beep3.ogg','nsv13/sound/effects/computer/beep4.ogg','nsv13/sound/effects/computer/beep5.ogg','nsv13/sound/effects/computer/beep6.ogg','nsv13/sound/effects/computer/beep7.ogg','nsv13/sound/effects/computer/beep8.ogg','nsv13/sound/effects/computer/beep9.ogg','nsv13/sound/effects/computer/beep10.ogg','nsv13/sound/effects/computer/beep11.ogg','nsv13/sound/effects/computer/beep12.ogg'))

#define MAX_FLAK_RANGE 75 //Stops resource waste

/obj/machinery/computer/ship
	name = "A ship component"
	icon_keyboard = "helm_key"
	var/obj/structure/overmap/linked
	var/position = null
	var/can_sound = TRUE //Warning sound placeholder
	var/sound_cooldown = 10 SECONDS //For big warnings like enemies firing on you, that we don't want repeating over and over
	req_access = list(ACCESS_HEADS)

/obj/machinery/computer/ship/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ship/LateInitialize()
	has_overmap()

/obj/machinery/computer/ship/proc/relay_sound(sound, message)
	if(!can_sound)
		return
	if(message)
		visible_message(message)
	if(sound)
		playsound(src, sound, 100, 1)
		can_sound = FALSE
		addtimer(CALLBACK(src, .proc/reset_sound), sound_cooldown)

/obj/machinery/computer/ship/proc/reset_sound()
	can_sound = TRUE

/obj/machinery/computer/ship/proc/has_overmap()
	var/obj/structure/overmap/OM = get_overmap()
	linked = OM
	if(OM)
		set_position(OM)
	return linked

/obj/machinery/computer/ship/proc/set_position(obj/structure/overmap/OM)
	return

/obj/machinery/computer/ship/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return FALSE
	if(!isliving(user))
		return FALSE
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return FALSE
	playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
	if(!position)
		return TRUE
	return linked.start_piloting(user, position)

/datum/techweb_node/ship_circuits
	id = "ship_circuitry"
	display_name = "Ship computer circuitry"
	description = "Allows you to rebuild the CIC when it inevitably gets bombed."
	prereq_ids = list("base")
	design_ids = list("helm_circuit", "tactical_comp_circuit", "dradis_circuit", "mining_dradis_circuit")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 2000

/obj/item/circuitboard/computer/ship/helm
	name = "circuit board (helm computer)"
	build_path = /obj/machinery/computer/ship/helm

/datum/design/board/helm_circuit
	name = "Computer Design (Helm Computer)"
	desc = "Allows for the construction of a helm control console."
	id = "helm_circuit"
	materials = list(/datum/material/glass = 5000, /datum/material/copper = 500, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/helm
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/obj/machinery/computer/ship/helm
	name = "Seegson model HLM flight control console"
	desc = "A computerized ship piloting package which allows a user to set a ship's speed, attitude, bearing and more!"
	icon_screen = "helm"
	position = "pilot"
	circuit = /obj/item/circuitboard/computer/ship/helm

/obj/machinery/computer/ship/helm/set_position(obj/structure/overmap/OM)
	OM.helm = src
	return

/obj/item/circuitboard/computer/ship/tactical_computer
	name = "circuit board (tactical computer)"
	build_path = /obj/machinery/computer/ship/tactical

/datum/design/board/tac_circuit
	name = "Computer Design (Tactical Computer)"
	desc = "Allows for the construction of a tactical control console."
	id = "tactical_comp_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/tactical_computer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/obj/machinery/computer/ship/tactical
	name = "Seegson model TAC tactical systems control console"
	desc = "In ship-to-ship combat, most ship systems are digitalized. This console is networked with every weapon system that its ship has to offer, allowing for easy control. There's a section on the screen showing an exterior gun camera view with a rangefinder."
	icon_screen = "tactical"
	position = "gunner"
	circuit = /obj/item/circuitboard/computer/ship/tactical_computer

/obj/machinery/computer/ship/tactical/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return
	ui_interact(user)
	playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
	if(!linked.gunner && isliving(user))
		return linked.start_piloting(user, position)

/obj/machinery/computer/ship/tactical/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "TacticalConsole", name, 560, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/tactical/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!linked)
		return
	switch(action)
		if("target_lock")
			linked.target_lock = null
		if("target_ship")
			var/target_name = params["target"]
			for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
				if(OM.name == target_name)
					linked.start_lockon(OM)
					break

/obj/machinery/computer/ship/tactical/ui_data(mob/user)
	if(!linked)
		return
	var/list/data = list()
	data["flakrange"] = linked.get_flak_range(linked.last_target)
	data["integrity"] = linked.obj_integrity
	data["max_integrity"] = linked.max_integrity
	data["quadrant_fs_armour_current"] = linked.armour_quadrants["forward_starboard"]["current_armour"]
	data["quadrant_fs_armour_max"] = linked.armour_quadrants["forward_starboard"]["max_armour"]
	data["quadrant_as_armour_current"] = linked.armour_quadrants["aft_starboard"]["current_armour"]
	data["quadrant_as_armour_max"] = linked.armour_quadrants["aft_starboard"]["max_armour"]
	data["quadrant_ap_armour_current"] = linked.armour_quadrants["aft_port"]["current_armour"]
	data["quadrant_ap_armour_max"] = linked.armour_quadrants["aft_port"]["max_armour"]
	data["quadrant_fp_armour_current"] = linked.armour_quadrants["forward_port"]["current_armour"]
	data["quadrant_fp_armour_max"] = linked.armour_quadrants["forward_port"]["max_armour"]
	data["weapons"] = list()
	data["target_name"] = (linked.target_lock) ? linked.target_lock.name : "none"
	var/scan_range = (linked?.dradis) ? linked.dradis.sensor_range : 45 //hide targets that are outside of sensor range to avoid cheese.
	for(var/datum/ship_weapon/SW_type in linked.weapon_types)
		var/ammo = 0
		var/max_ammo = 0
		var/thename = SW_type.name
		for(var/obj/machinery/ship_weapon/SW in SW_type.weapons["all"])
			if(!SW)
				continue
			max_ammo += SW.get_max_ammo()
			ammo += SW.get_ammo()
		data["weapons"] += list(list("name" = thename, "ammo" = ammo, "maxammo" = max_ammo))
	data["ships"] = list()
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z == linked.z && OM.faction != linked.faction && get_dist(linked, OM) <= scan_range && OM.is_sensor_visible(linked) >= SENSOR_VISIBILITY_TARGETABLE)
			data["ships"] += list(list("name" = OM.name, "integrity" = OM.obj_integrity, "max_integrity" = OM.max_integrity, "faction" = OM.faction))
	return data

/obj/machinery/computer/ship/tactical/set_position(obj/structure/overmap/OM)
	OM.tactical = src
	return

/obj/machinery/computer/ship/ordnance
	name = "Seegson model ORD ordnance systems monitoring console"
	desc = "This console provides a succinct overview of the ship-to-ship weapons."
	icon_screen = "tactical"
	req_access = list(ACCESS_MUNITIONS)
	circuit = /obj/item/circuitboard/computer/ship/ordnance_computer

/obj/item/circuitboard/computer/ship/ordnance_computer
	name = "circuit board (ordnance computer)"
	build_path = /obj/machinery/computer/ship/ordnance

/datum/design/board/ord_circuit
	name = "Computer Design (Ordnance Computer)"
	desc = "Allows for the construction of a ordnance monitoring console."
	id = "ordnance_comp_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/ordnance_computer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/obj/machinery/computer/ship/ordnance/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/ordnance/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "OrdnanceConsole", name, 560, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/ordnance/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	for(var/datum/ship_weapon/SW_type in linked.weapon_types)
		var/ammo = 0
		var/max_ammo = 0
		var/thename = SW_type.name
		for(var/obj/machinery/ship_weapon/SW in SW_type.weapons["all"])
			if(!SW)
				continue
			max_ammo += SW.get_max_ammo()
			ammo += SW.get_ammo()
		data["weapons"] += list(list("name" = thename, "ammo" = ammo, "maxammo" = max_ammo))
	return data

/datum/techweb_node/maa_circuits
	id = "maa_circuitry"
	display_name = "Master-At-Arms computer circuitry"
	description = "Allows you to rebuild the Master-At-Arms computer terminals after they suffer railgun ventilation."
	prereq_ids = list("base")
	design_ids = list("fighter_computer_circuit", "ordnance_comp_circuit")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 2000

/obj/machinery/computer/ship/viewscreen
	name = "Seegson model M viewscreen"
	desc = "A large CRT monitor which shows an exterior view of the ship."
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "viewscreen"
	idle_power_usage = 15
	mouse_over_pointer = MOUSE_HAND_POINTER
	pixel_y = 26
	density = FALSE
	anchored = TRUE
	req_access = null

/obj/machinery/computer/ship/viewscreen/examine(mob/user)
	. = ..()
	if(!has_overmap())
		return
	if(isobserver(user))
		var/mob/dead/observer/O = user
		O.ManualFollow(linked)
		return
	playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	linked.start_piloting(user, "observer")

/obj/machinery/computer/ship/viewscreen/attack_hand(mob/user)
	. = ..()
	if(!has_overmap())
		return
	if(isobserver(user))
		var/mob/dead/observer/O = user
		O.ManualFollow(linked)
		return
	playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	linked.start_piloting(user, "observer")

/obj/machinery/computer/ship/salvage
	name = "Seegson model SCRP salvage console"
	desc = "A relatively simple console which allows ships to dock to other ships."
	icon_screen = "salvage"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/max_salvage_range = 20 //must stay within N tiles of range to salvage a ship.
	var/obj/structure/overmap/salvage_target = null //What are we currently salvaging?
	var/can_salvage = TRUE //Cooldown
	var/salvage_cooldown = 5 MINUTES
	var/obj/item/radio/radio //For alerts.
	var/radio_key = /obj/item/encryptionkey/headset_com
	var/radio_channel = RADIO_CHANNEL_COMMAND
	var/datum/beam/current_beam = null //Salvage armatures

/obj/machinery/computer/ship/salvage/Initialize()
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()

/obj/machinery/computer/ship/salvage/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate thrust parameters, no registered ship stored in microprocessor.</span>")
		return
	playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
	var/dat = ""
	var/dist = get_dist(linked, salvage_target)
	if(!salvage_target)
		dat += "<h2>Available salvage targets:</h2><br>"
		for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
			if(get_dist(linked, OM) <= max_salvage_range && OM.wrecked)
				dat += "<A href='?src=\ref[src];salvage=\ref[OM]'>[OM]</A><BR>"
	else
		dat += "<h2> Salvage protocols: Target locked: [salvage_target].</h2><br>"
		dat += "<A href='?src=\ref[src];blank=1'>Current range: [dist]KM / [max_salvage_range]KM</A><BR>"
		dat += "<A href='?src=\ref[src];cancel_salvage=1'>Terminate salvage operations</A><BR>"
	playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, 1)
	var/datum/browser/popup = new(user, "Salvage console", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/salvage/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	var/obj/structure/overmap/salvage = locate(href_list["salvage"])
	if(salvage)
		salvage_target = salvage
		salvage()
	if(href_list["cancel_salvage"])
		cancel_salvage()
	attack_hand(usr)

/obj/effect/ebeam/chain //Blame bee disabling but not removing the guardian shit inside the mob folder
	name = "lightning chain"
	layer = LYING_MOB_LAYER

/obj/machinery/computer/ship/salvage/proc/salvage()
	if(!salvage_target || !can_salvage)
		salvage_target = null
		return
	can_salvage = FALSE
	addtimer(VARSET_CALLBACK(src, can_salvage, TRUE), salvage_cooldown)
	salvage_target.relay_to_nearby('nsv13/sound/effects/ship/boarding_pod.ogg')
	radio.talk_into(src, "Deploying structural stabilization lines...", radio_channel)
	current_beam = new(linked,salvage_target,time=INFINITY,maxdistance=max_salvage_range,beam_icon_state="salvage_beam",btype=/obj/effect/ebeam/chain)
	INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
	if(salvage_target.load_interior())
		radio.talk_into(src, "SUCCESS: Docking tethers locking onto [salvage_target]. Structural integrity: ACCEPTABLE. Structural reinforcements are effective at close ranges only!.", radio_channel)
		salvage_target.brakes = TRUE //Lock it in place.
		RegisterSignal(linked, COMSIG_MOVABLE_MOVED, .proc/update_salvage_target) //Add a listener on ship move. If you move out of range of the salvage target, it explodes because youre not there to stabilize it anymore.
		for(var/datum/X in salvage_target.active_timers) //Cancel detonation
			qdel(X)
	else //This only ever fails if there isn't a place to spawn the interior.
		radio.talk_into(src, "WARNING: Docking tethers failed to attach to [salvage_target]. Further salvage attempts futile.", radio_channel)
		cancel_salvage()

/obj/machinery/computer/ship/salvage/proc/update_salvage_target()
	if(!salvage_target)
		return
	var/dist = get_dist(linked, salvage_target)
	if(dist >= max_salvage_range)
		radio.talk_into(src, "DANGER: Unable to maintain salvage armatures on [salvage_target]! Structural integrity failure imminent!", radio_channel)
		cancel_salvage()

/obj/machinery/computer/ship/salvage/proc/cancel_salvage()
	if(salvage_target)
		if(current_beam)
			qdel(current_beam)
			current_beam = null
		radio.talk_into(src, "Salvage armatures retracted. Aborting salvage operations.", radio_channel)
		salvage_target.explode() //Ship loses stability. It's literally just us that's holding it together.
		UnregisterSignal(linked, COMSIG_MOVABLE_MOVED, .proc/update_salvage_target)
		salvage_target = null

/obj/structure/hull_plate
	name = "nanolaminate reinforced hull plating"
	desc = "A heavy piece of hull plating designed to reinforced the ship's superstructure. The Nanotrasen official starship operational manual states that any damage sustained can be patched up temporarily with a welder."
	icon = 'nsv13/icons/obj/structures/ship_structures.dmi'
	icon_state = "tgmc_outerhull"
	anchored = TRUE
	density = FALSE
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	obj_integrity = 200
	max_integrity = 200
	var/obj/structure/overmap/parent = null
	var/armour_scale_modifier = 4
	var/armour_broken = FALSE
	var/tries = 2 //How many times do we try and locate our parent before giving up? Here to avoid infinite recursion timers.

/obj/structure/hull_plate/end
	icon_state = "tgmc_outerhull_dir"

/obj/structure/hull_plate/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/hull_plate/LateInitialize()
	try_find_parent()

/**

Method to try locate an overmap object that we should attach to. Recursively calls if we can't find one.

*/

/obj/structure/hull_plate/proc/try_find_parent()
	if(tries <= 0)
		message_admins("Hull plates in [get_area(src)] have no overmap object!")
		qdel(src) //This should be enough of a hint....
		return
	parent = get_overmap()
	if(!parent)
		tries --
		addtimer(CALLBACK(src, .proc/try_find_parent), 10 SECONDS)
		return
	parent.armour_plates ++
	parent.max_armour_plates ++
	RegisterSignal(parent, COMSIG_DAMAGE_TAKEN, .proc/relay_damage)

/obj/structure/hull_plate/Destroy()
	parent?.armour_plates --
	. = ..()

/datum/reagent/hull_repair_juice
	name = "Hull Repair Juice"
	description = "Repairs hull plating rapidly."
	reagent_state = LIQUID
	color = "#CC8899"
	metabolization_rate = 4
	taste_description = "metallic hull repair juice"
	process_flags = ORGANIC | SYNTHETIC

//Hull repair juice -> stabilizing agent, iron, carbon

/obj/effect/particle_effect/foam/hull_repair_juice
	name = "Hull Repair Foam"
	slippery_foam = FALSE
	color = "#CC8899"

/obj/structure/reagent_dispensers/foamtank/hull_repair_juice
	name = "hull repair juice tank"
	desc = "A tank full of hull repair foam."
	icon_state = "foam"
	reagent_id = /datum/reagent/hull_repair_juice
	tank_volume = 1500 //I NEED A LOT OF FOAM OK.

/obj/item/extinguisher/advanced/hull_repair_juice
	name = "hull damage extinguisher"
	desc = "For when the hull plates just won't STOP."
	icon = 'nsv13/icons/obj/inflatable.dmi'
	chem = /datum/reagent/hull_repair_juice
	tanktype = /obj/structure/reagent_dispensers/foamtank/hull_repair_juice

/datum/chemical_reaction/hull_repair_juice
	name = "Hull Repair Juice"
	id = /datum/reagent/hull_repair_juice
	results = list(/datum/reagent/hull_repair_juice = 10)
	required_reagents = list(/datum/reagent/stabilizing_agent = 1, /datum/reagent/iron = 1,/datum/reagent/carbon = 1)

/datum/reagent/hull_repair_juice/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return

	if(reac_volume >= 1)
		var/obj/effect/particle_effect/foam/F = (locate(/obj/effect/particle_effect/foam) in T)
		if(!F)
			F = new(T)
		else if(istype(F))
			F.lifetime = initial(F.lifetime) //reduce object churn a little bit when using smoke by keeping existing foam alive a bit longer

	for(var/obj/structure/hull_plate/HP in T.contents)
		if(!istype(HP))
			continue
		HP.try_repair(HP.max_integrity)

/obj/structure/hull_plate/proc/relay_damage(datum/source, amount)
	if(!amount)
		return //No 0 damage
	if(prob(amount/5)) //magic number woo!
		take_damage(amount)

/obj/structure/hull_plate/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = FALSE)
	if(damage_amount >= 15)
		shake_animation(3)
	if(obj_integrity <= damage_amount)
		obj_integrity = 1
		if(!armour_broken)
			parent?.armour_plates --
			armour_broken = TRUE
		update_icon()
		return FALSE
	. = ..()
	update_icon()

/obj/structure/hull_plate/proc/try_repair(amount, mob/user)
	obj_integrity = (obj_integrity + amount < max_integrity) ? obj_integrity + amount : max_integrity
	update_icon()
	if(obj_integrity <= max_integrity)
		if(user)
			to_chat(user, "<span class='warning'>You have fully repaired [src].</span>")
		obj_integrity = max_integrity
		update_icon()
		if(armour_broken)
			parent?.armour_plates ++
			armour_broken = FALSE
		return

/obj/structure/hull_plate/update_icon()
	var/progress = obj_integrity
	var/goal = max_integrity
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 25)//Round it down to 25%. We now apply visual damage
	icon_state = "[initial(icon_state)][progress]"

/obj/structure/overmap/proc/check_armour() //Get the "max" armour plates value when all the armour plates have been initialized.
	if(!linked_areas || !linked_areas.len)
		return
	if(armour_plates <= 0)
		addtimer(CALLBACK(src, .proc/check_armour), 20 SECONDS) //Recursively call the function until we've generated the armour plates value to account for lag / late initializations.
		return
	max_armour_plates = armour_plates

/obj/structure/overmap/slowprocess()
	. = ..()
	if(istype(src, /obj/structure/overmap/asteroid)) //Shouldn't be repairing over time
		return
	if(mass > MASS_TINY) //Prevents fighters regenerating
		if(!use_armour_quadrants) //Checking to see if we are using the armour quad system
			try_repair(get_repair_efficiency() / 25) //Scale the value. If you have 80% of your armour plates repaired, the ship takes about 7.5 minutes to fully repair. If you only have 25% of your plates operational, it will take half an hour to fully repair the ship.

/obj/structure/hull_plate/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_WELDER)
		var/obj/item/weldingtool/WT = W
		if(obj_integrity >= max_integrity)
			if(user)
				to_chat(user, "<span class='warning'>[src] is not in need of repair.</span>")
			return FALSE
		var/fuel_required = 1
		var/list/plates = list()
		plates += src
		for(var/obj/structure/hull_plate/S in orange(1, src))
			if(S.obj_integrity < S.max_integrity)
				plates += S
				fuel_required ++
		if(!W.tool_start_check(user, amount=fuel_required))
			to_chat(user, "<span class='notice'>You need [fuel_required-WT.get_fuel()] more units of welding fuel to repair this hull segment.</span>")
			return ..()
		to_chat(user, "<span class='notice'>You begin fixing some of the dents in [src] and the surrounding hull segment...</span>")
		if(do_after(user, 4 SECONDS, target = src))
			if(W.use_tool(src, user, 0, volume=100, amount=fuel_required))
				to_chat(user, "<span class='notice'>You fix some of the dents in [src] and the surrounding hull segment.</span>")
				for(var/obj/structure/hull_plate/S in plates)
					S.try_repair(100, user)
		return FALSE
	. = ..()

/obj/structure/overmap/proc/get_repair_efficiency()
	if(max_armour_plates <= 0)
		return 10 //Very slow heal for AIs, considering they can stop off at a supply post to heal back up.
	return (max_armour_plates > 0) ? 100*(armour_plates/max_armour_plates) : 100

#undef MAX_FLAK_RANGE
