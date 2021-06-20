/*
Todo:
Ammo loading
Startup sequence
Docking [X]
Unified construction
Death state / Crit mode (Canopy breach?)
Hardpoints [X]
Repair
*/


#define HARDPOINT_SLOT_PRIMARY "Primary"
#define HARDPOINT_SLOT_SECONDARY "Secondary"
#define HARDPOINT_SLOT_UTILITY "Utility"
#define HARDPOINT_SLOT_ARMOUR "Armour"
#define HARDPOINT_SLOT_DOCKING "Docking Module"
#define HARDPOINT_SLOT_CANOPY "Canopy"
#define HARDPOINT_SLOT_FUEL "Fuel Tank"
#define HARDPOINT_SLOT_ENGINE "Engine"
#define HARDPOINT_SLOT_RADAR "Radar"
#define HARDPOINT_SLOT_OXYGENATOR "Atmospheric Regulator"
#define HARDPOINT_SLOT_BATTERY "Battery"
#define HARDPOINT_SLOT_APU "APU"
#define HARDPOINT_SLOT_UTILITY_PRIMARY "Primary Utility"
#define HARDPOINT_SLOT_UTILITY_SECONDARY "Secondary Utility"

#define ALL_HARDPOINT_SLOTS list(HARDPOINT_SLOT_PRIMARY, HARDPOINT_SLOT_SECONDARY,HARDPOINT_SLOT_UTILITY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR, HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY, HARDPOINT_SLOT_APU)
#define HARDPOINT_SLOTS_STANDARD list(HARDPOINT_SLOT_PRIMARY, HARDPOINT_SLOT_SECONDARY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR,HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY, HARDPOINT_SLOT_APU)
#define HARDPOINT_SLOTS_UTILITY list(HARDPOINT_SLOT_UTILITY_PRIMARY,HARDPOINT_SLOT_UTILITY_SECONDARY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR,HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY, HARDPOINT_SLOT_APU)

#define LOADOUT_DEFAULT_FIGHTER /datum/component/ship_loadout
#define LOADOUT_UTILITY_ONLY /datum/component/ship_loadout/utility

#define ENGINE_RPM_SPUN 8000

/obj/structure/overmap/fighter/Destroy()
	throw_pilot()
	. = ..()

/obj/structure/overmap/fighter
	name = "\improper Space Fighter"
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	icon_state = "fighter"
	brakes = TRUE
	armor = list("melee" = 80, "bullet" = 50, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //temp to stop easy destruction from small arms
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	mass = MASS_TINY
	sprite_size = 32
	damage_states = TRUE
	faction = "nanotrasen"
	max_integrity = 250 //Really really squishy!
	forward_maxthrust = 3.5
	backward_maxthrust = 3.5
	side_maxthrust = 4
	max_angular_acceleration = 180
	torpedoes = 0
	missiles = 0
	speed_limit = 7 //We want fighters to be way more maneuverable
	weapon_safety = TRUE //This happens wayy too much for my liking. Starts ON.
	pixel_w = -16
	pixel_z = -20
	pixel_collision_size_x = 32
	pixel_collision_size_y = 32 //Avoid center tile viewport jank
	req_one_access = list(ACCESS_FIGHTER)
	var/start_emagged = FALSE
	var/max_passengers = 0 //Change this per fighter.
	//Component to handle the fighter's loadout, weapons, parts, the works.
	var/loadout_type = LOADOUT_DEFAULT_FIGHTER
	var/datum/component/ship_loadout/loadout = null
	var/obj/structure/fighter_launcher/mag_lock = null //Mag locked by a launch pad. Cheaper to use than locate()
	var/canopy_open = TRUE
	var/master_caution = FALSE //The big funny warning light on the dash.
	var/list/components = list() //What does this fighter start off with? Use this to set what engine tiers and whatever it gets.
	var/maintenance_mode = FALSE //Munitions level IDs can change this.
	var/dradis_type =/obj/machinery/computer/ship/dradis/internal
	var/list/fighter_verbs = list(.verb/toggle_brakes, .verb/toggle_inertia, .verb/toggle_safety, .verb/show_dradis, .verb/overmap_help, .verb/toggle_move_mode, .verb/cycle_firemode, \
								.verb/show_control_panel, .verb/change_name)

/obj/structure/overmap/fighter/verb/show_control_panel()
	set name = "Show control panel"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	ui_interact(usr)

/obj/structure/overmap/fighter/verb/change_name()
	set name = "Change name"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	var/new_name = stripped_input(usr, message="What do you want to name \
		your fighter? Keep in mind that particularly terrible names may be \
		rejected by your employers.", max_length=MAX_CHARTER_LEN)
	if(!new_name || length(new_name) <= 0)
		return
	message_admins("[key_name_admin(usr)] renamed a fighter to [new_name] [ADMIN_LOOKUPFLW(src)].")
	name = "\improper [new_name]"

/obj/structure/overmap/fighter/start_piloting(mob/living/carbon/user, position)
	user.add_verb(fighter_verbs)
	..()

/obj/structure/overmap/fighter/key_down(key, client/user)
	. = ..()
	var/mob/themob = user.mob
	switch(key)
		if("Capslock")
			if(themob == pilot)
				toggle_safety()
			if(helm && prob(80))
				var/sound = pick(GLOB.computer_beeps)
				playsound(helm, sound, 100, 1)
			return TRUE

/obj/structure/overmap/fighter/ui_state(mob/user)
	return GLOB.contained_state

/obj/structure/overmap/fighter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FighterControls")
		ui.open()

/obj/structure/overmap/fighter/ui_data(mob/user)
	var/list/data = list()
	data["obj_integrity"] = obj_integrity
	data["max_integrity"] = max_integrity
	var/obj/item/fighter_component/armour_plating/A = loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
	data["armour_integrity"] = (A) ? A.obj_integrity : 0
	data["max_armour_integrity"] = (A) ? A.max_integrity : 100

	var/obj/item/fighter_component/battery/B = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	data["battery_charge"] = B ? B.charge : 0
	data["battery_max_charge"] = B ? B.maxcharge : 0
	data["brakes"] = brakes
	data["inertial_dampeners"] = inertial_dampeners
	data["mag_locked"] = (mag_lock) ? TRUE : FALSE
	data["canopy_lock"] = canopy_open
	data["weapon_safety"] = weapon_safety
	data["master_caution"] = master_caution
	data["rwr"] = (enemies.len) ? TRUE : FALSE
	data["fuel_warning"] = get_fuel() <= get_max_fuel()*0.4
	data["fuel"] = get_fuel()
	data["max_fuel"] = get_max_fuel()
	data["hardpoints"] = list()
	data["maintenance_mode"] = maintenance_mode //Todo
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	data["docking_mode"] = DC && DC.docking_mode
	data["primary_ammo"] = 0
	data["max_primary_ammo"] = 0

	var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
	data["fuel_pump"] = APU ? APU.fuel_line : FALSE

	var/obj/item/fighter_component/battery/battery = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	data["battery"] = battery? battery.active : battery

	data["apu"] = APU.active
	var/obj/item/fighter_component/engine/engine = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
	data["ignition"] = engine ? engine.active() : FALSE
	data["rpm"] = engine? engine.rpm : 0

	for(var/slot in loadout.equippable_slots)
		var/obj/item/fighter_component/weapon = loadout.hardpoint_slots[slot]
		//Look for any "primary" hardpoints, be those guns or utility slots
		if(!weapon)
			continue
		if(weapon.fire_mode == FIRE_MODE_PDC)
			data["primary_ammo"] = weapon.get_ammo()
			data["max_primary_ammo"] = weapon.get_max_ammo()
		if(weapon.fire_mode == FIRE_MODE_TORPEDO)
			data["secondary_ammo"] = weapon.get_ammo()
			data["max_secondary_ammo"] = weapon.get_max_ammo()
	var/list/hardpoints_info = list()
	var/list/occupants_info = list()
	for(var/obj/item/fighter_component/FC in contents)
		if(isliving(FC))
			var/mob/living/L = FC
			var/list/occupant_info = list()
			occupant_info["name"] = L.name
			occupant_info["id"] = "\ref[L]"
			occupant_info["afk"] = (L.mind) ? "Active" : "Inactive (SSD)"
			occupants_info[++occupants_info.len] = occupant_info
			continue
		if(!istype(FC))
			continue
		var/list/hardpoint_info = list()
		hardpoint_info["name"] = FC.name
		hardpoint_info["desc"] = FC.desc
		hardpoint_info["id"] = "\ref[FC]"
		hardpoints_info[++hardpoints_info.len] = hardpoint_info
	data["hardpoints"] = hardpoints_info
	data["occupants_info"] = occupants_info
	return data

/obj/structure/overmap/fighter/ui_act(action, params, datum/tgui/ui)
	if(..() || usr != pilot)
		return
	var/atom/movable/target = locate(params["id"])
	switch(action)
		if("examine")
			if(!target)
				return
			to_chat(usr, "<span class='notice'>[target.desc]</span>")
		if("eject_hardpoint")
			if(!target)
				return
			var/obj/item/fighter_component/FC = target
			if(!istype(FC))
				return
			to_chat(usr, "<span class='notice'>You start uninstalling [target.name] from [src].</span>")
			if(!do_after(usr, 5 SECONDS, target=src))
				return
			to_chat(usr, "<span class='notice>You uninstall [target.name] from [src].</span>")
			loadout.remove_hardpoint(FC, FALSE)
		if("dump_hardpoint")
			if(!target)
				return
			var/obj/item/fighter_component/FC = target
			if(!istype(FC) || !FC.contents?.len)
				return
			to_chat(usr, "<span class='notice'>You start to unload [target.name]'s stored contents...</span>")
			if(!do_after(usr, 5 SECONDS, target=src))
				return
			to_chat(usr, "<span class='notice>You dump [target.name]'s contents.</span>")
			loadout.dump_contents(FC)
		if("kick")
			if(!target)
				return
			if(!allowed(usr) || usr != pilot)
				return
			var/mob/living/L = target
			to_chat(L, "<span class='warning'>You have been kicked out of [src] by the pilot.</span>")
			canopy_open = FALSE
			toggle_canopy()
			stop_piloting(L)
		if("fuel_pump")
			var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
			if(!APU)
				to_chat(usr, "<span class='warning'>You can't send fuel to an APU that isn't installed.</span>")
				return
			var/obj/item/fighter_component/engine/engine = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
			if(!engine)
				to_chat(usr, "<span class='warning'>You can't send fuel to an APU that isn't installed.</span>")
			APU.toggle_fuel_line()
			playsound(src, 'nsv13/sound/effects/fighters/warmup.ogg', 100, FALSE)
		if("battery")
			var/obj/item/fighter_component/battery/battery = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
			if(!battery)
				to_chat(usr, "<span class='warning'>[src] does not have a battery installed!</span>")
				return
			battery.toggle()
			to_chat(usr, "You flip the battery switch.</span>")
		if("apu")
			var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
			if(!APU)
				to_chat(usr, "<span class='warning'>[src] does not have an APU installed!</span>")
				return
			APU.toggle()
			playsound(src, 'nsv13/sound/effects/fighters/warmup.ogg', 100, FALSE)
		if("ignition")
			var/obj/item/fighter_component/engine/engine = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
			if(!engine)
				to_chat(usr, "<span class='warning'>[src] does not have an engine installed!</span>")
				return
			engine.try_start()
		if("canopy_lock")
			toggle_canopy()
		if("docking_mode")
			var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
			if(!DC || !istype(DC))
				to_chat(usr, "<span class='warning'>[src] does not have a docking computer installed!</span>")
				return
			to_chat(usr, "<span class='notice'>You [DC.docking_mode ? "disengage" : "engage"] [src]'s docking computer.</span>")
			DC.docking_mode = !DC.docking_mode
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("brakes")
			toggle_brakes()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("inertial_dampeners")
			toggle_inertia()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("weapon_safety")
			toggle_safety()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("target_lock")
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("mag_release")
			if(!mag_lock)
				return
			mag_lock.abort_launch()
		if("master_caution")
			set_master_caution(FALSE)
			return
		if("show_dradis")
			dradis.ui_interact(usr)
			return
	relay('nsv13/sound/effects/fighters/switch.ogg')

/obj/structure/overmap/fighter/light
	name = "Su-818 Rapier"
	desc = "An Su-818 Rapier space superiorty fighter craft. Designed for high maneuvreability and maximum combat effectivness against other similar weight classes."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 30, "bomb" = 30, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 10, "overmap_heavy" = 5)
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 200 //Really really squishy!
	max_angular_acceleration = 200
	speed_limit = 10
	pixel_w = -16
	pixel_z = -20
	components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/cannon)

//FL gets a hotrod
/obj/structure/overmap/fighter/light/flight_leader
	req_one_access = list(ACCESS_FL)
	icon_state = "ace"
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/tier2,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine/tier2,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/cannon)

/obj/structure/overmap/fighter/utility
	name = "\improper Su-437 Sabre"
	desc = "A Su-437 Sabre utility vessel. Designed for robustness in deep space and as a highly modular platform, able to be fitted out for any situation. Drag and drop crates / ore boxes to load them into its cargo hold."
	icon = 'nsv13/icons/overmap/nanotrasen/carrier.dmi'
	icon_state = "carrier"
	armor = list("melee" = 70, "bullet" = 70, "laser" = 70, "energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 15, "overmap_heavy" = 0)
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 250 //Tanky
	max_passengers = 6
	pixel_w = -16
	pixel_z = -20
	req_one_access = list(ACCESS_MUNITIONS, ACCESS_ENGINE, ACCESS_FIGHTER)

	forward_maxthrust = 5
	backward_maxthrust = 5
	side_maxthrust = 5
	max_angular_acceleration = 100
	speed_limit = 6
//	ftl_goal = 45 SECONDS //Raptors can, by default, initiate relative FTL jumps to other ships.
	loadout_type = LOADOUT_UTILITY_ONLY
	dradis_type = /obj/machinery/computer/ship/dradis/internal/awacs //Sabres can send radar pulses
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/utility/hold,
						/obj/item/fighter_component/secondary/utility/resupply,
						/obj/item/fighter_component/countermeasure_dispenser)

/obj/structure/overmap/fighter/utility/mining
	icon = 'nsv13/icons/overmap/nanotrasen/carrier_mining.dmi'
	req_one_access = list(ACCESS_CARGO, ACCESS_MINING, ACCESS_MUNITIONS, ACCESS_ENGINE, ACCESS_FIGHTER)

/obj/structure/overmap/fighter/escapepod
	name = "\improper Escape Pod"
	desc = "An escape pod launched from a space faring vessel. It only has very limited thrusters and is thus very slow."
	icon = 'nsv13/icons/overmap/nanotrasen/escape_pod.dmi'
	icon_state = "escape_pod"
	damage_states = FALSE
	bound_width = 32 //Change this on a per ship basis
	bound_height = 32
	pixel_z = 0
	pixel_w = 0
	max_integrity = 50 //Able to withstand more punishment so that people inside it don't get yeeted as hard
	speed_limit = 2 //This, for reference, will feel suuuuper slow, but this is intentional
	loadout_type = LOADOUT_UTILITY_ONLY
	components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/countermeasure_dispenser)

/obj/structure/overmap/fighter/heavy
	name = "\improper Su-410 Scimitar"
	desc = "An Su-410 Scimitar heavy attack craft. It's a lot beefier than its Rapier cousin and is designed to take out capital ships, due to the weight of its modules however, it is extremely slow."
	icon = 'nsv13/icons/overmap/nanotrasen/heavy_fighter.dmi'
	icon_state = "heavy_fighter"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 25, "overmap_heavy" = 10)
	sprite_size = 32
	damage_states = FALSE //TEMP
	max_integrity = 300 //Not so squishy!
	pixel_w = -16
	pixel_z = -20
	speed_limit = 8
	forward_maxthrust = 8
	backward_maxthrust = 8
	side_maxthrust = 7.75
	max_angular_acceleration = 80
	components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/secondary/ordnance_launcher/torpedo,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/cannon/heavy)

//Syndie counterparts.
/obj/structure/overmap/fighter/light/syndicate //PVP MODE
	name = "\improper Syndicate Light Fighter"
	desc = "The Syndicate's answer to Nanotrasen's light fighter craft, this fighter is designed to maintain aerial supremacy."
	icon = 'nsv13/icons/overmap/syndicate/syn_viper.dmi'
	req_one_access = ACCESS_SYNDICATE
	faction = "syndicate"
	start_emagged = TRUE
/obj/structure/overmap/fighter/utility/syndicate //PVP MODE
	name = "\improper Syndicate Utility Vessel"
	desc = "A boarding craft for rapid troop deployment."
	icon = 'nsv13/icons/overmap/syndicate/syn_raptor.dmi'
	req_one_access = ACCESS_SYNDICATE
	faction = "syndicate"
	start_emagged = TRUE

/obj/structure/overmap/fighter/Initialize(mapload, list/build_components=components)
	. = ..()
	apply_weapons()
	loadout = AddComponent(loadout_type)
	dradis = new dradis_type(src) //Fighters need a way to find their way home.
	dradis.linked = src
	obj_integrity = max_integrity
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/check_overmap_elegibility) //Used to smoothly transition from ship to overmap
	add_overlay(image(icon = icon, icon_state = "canopy_open", dir = SOUTH))
	var/obj/item/fighter_component/engine/engineGoesLast = null
	if(build_components.len)
		for(var/Ctype in build_components)
			var/obj/item/fighter_component/FC = new Ctype(get_turf(src))
			if(istype(FC, /obj/item/fighter_component/engine))
				engineGoesLast = FC
				continue
			loadout.install_hardpoint(FC)
	//Engines need to be the last thing that gets installed on init, or it'll cause bugs with drag.
	if(engineGoesLast)
		loadout.install_hardpoint(engineGoesLast)
	obj_integrity = max_integrity //Update our health to reflect how much armour we've been given.
	set_fuel(rand(500, 1000))
	if(start_emagged)
		obj_flags ^= EMAGGED

/obj/structure/overmap/fighter/attackby(obj/item/W, mob/user, params)
	if(operators && LAZYFIND(operators, user))
		to_chat(user, "<span class='warning'>You can't reach [src]'s exterior from in here..</span>")
		return FALSE
	for(var/slot in loadout.equippable_slots)
		var/obj/item/fighter_component/FC = loadout.get_slot(slot)
		if(FC?.load(src, W))
			return FALSE
	if(istype(W, /obj/item/fighter_component))
		var/obj/item/fighter_component/FC = W
		loadout.install_hardpoint(FC)
		return FALSE
	..()

/obj/structure/overmap/fighter/MouseDrop_T(atom/movable/target, mob/user)
	. = ..()
	if(!isliving(user))
		return FALSE
	for(var/slot in loadout.equippable_slots)
		var/obj/item/fighter_component/FC = loadout.get_slot(slot)
		if(FC?.load(src, target))
			return FALSE
	if(allowed(user))
		if(!canopy_open)
			playsound(src, 'sound/effects/glasshit.ogg', 75, 1)
			user.visible_message("<span class='warning'>You bang on the canopy.</span>", "<span class='warning'>[user] bangs on [src]'s canopy.</span>")
			return FALSE
		if(operators.len >= max_passengers)
			to_chat(user, "<span class='warning'>[src]'s passenger compartment is full!")
			return FALSE
		to_chat(target, "[(user == target) ? "You start to climb into [src]'s passenger compartment" : "[user] starts to lift you into [src]'s passenger compartment"]")
		if(do_after(user, 2 SECONDS, target=src))
			start_piloting(user, "observer")
			enter(user)
	else
		to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/structure/overmap/fighter/proc/enter(mob/user)
	user.forceMove(src)
	mobs_in_ship += user
	if((user.client?.prefs.toggles & SOUND_AMBIENCE) && user.can_hear_ambience() && engines_active()) //Disable ambient sounds to shut up the noises.
		SEND_SOUND(user, sound('nsv13/sound/effects/fighters/cockpit.ogg', repeat = TRUE, wait = 0, volume = 50, channel=CHANNEL_SHIP_ALERT))

/obj/structure/overmap/fighter/stop_piloting(mob/living/M, force=FALSE)
	if(!canopy_open && !force)
		to_chat(M, "<span class='warning'>[src]'s canopy isn't open.</span>")
		if(prob(50))
			playsound(src, 'sound/effects/glasshit.ogg', 75, 1)
			to_chat(M, "<span class='warning'>You bump your head on [src]'s canopy.</span>")
			visible_message("<span class='warning'>You hear a muffled thud.</span>")
		return
	if(!SSmapping.level_trait(loc.z, ZTRAIT_BOARDABLE) && !force)
		to_chat(M, "<span class='warning'>[src] won't let you jump out of it mid flight.</span>")
		return FALSE
	mobs_in_ship -= M
	. = ..()
	M.stop_sound_channel(CHANNEL_SHIP_ALERT)
	M.forceMove(get_turf(src))
	M.remove_verb(fighter_verbs)
	return TRUE

/obj/structure/overmap/fighter/attack_hand(mob/user)
	. = ..()
	if(allowed(user))
		if(pilot)
			to_chat(user, "<span class='notice'>[src] already has a pilot.</span>")
			return FALSE
		if(do_after(user, 2 SECONDS, target=src))
			enter(user)
			start_piloting(user, "all_positions")
			to_chat(user, "<span class='notice'>You climb into [src]'s cockpit.</span>")
			ui_interact(user)
			return TRUE

/obj/structure/overmap/fighter/proc/force_eject(force=FALSE)
	RETURN_TYPE(/list)
	var/list/victims = list()
	brakes = TRUE
	if(!canopy_open)
		canopy_open = TRUE
		playsound(src, 'nsv13/sound/effects/fighters/canopy.ogg', 100, 1)
	for(var/mob/M in operators)
		stop_piloting(M, force)
		to_chat(M, "<span class='warning'>You have been remotely ejected from [src]!.</span>")
		victims += M
	return victims

//Iconic proc.
/obj/structure/overmap/fighter/proc/foo()
	set_fuel(1000)
	var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
	APU.fuel_line = TRUE
	var/obj/item/fighter_component/battery/B = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	B.active = TRUE
	B.charge = B.maxcharge
	var/obj/item/fighter_component/engine/E = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
	E.rpm = ENGINE_RPM_SPUN
	E.try_start()
	toggle_canopy()
	forceMove(get_turf(locate(world.maxx, y, z)))

/obj/structure/overmap/fighter/proc/throw_pilot() //Used when yeeting a pilot out of an exploding ship
	if(SSmapping.level_trait(z, ZTRAIT_OVERMAP)) //Check if we're on the overmap
		var/max = world.maxx-TRANSITIONEDGE
		var/min = 1+TRANSITIONEDGE

		var/list/possible_transitions = list()
		for(var/A in SSmapping.z_list)
			var/datum/space_level/D = A
			if (D.linkage == CROSSLINKED && !SSmapping.level_trait(D.z_value, ZTRAIT_OVERMAP))
				possible_transitions += D.z_value
			if(!possible_transitions.len) //Just in case there is no space z level
				for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
					possible_transitions += z

		var/_z = pick(possible_transitions)
		var/_x
		var/_y

		switch(dir)
			if(SOUTH)
				_x = rand(min,max)
				_y = max
			if(WEST)
				_x = max
				_y = rand(min,max)
			if(EAST)
				_x = min
				_y = rand(min,max)
			else
				_x = rand(min,max)
				_y = min

		var/turf/T = locate(_x, _y, _z) //Where are we putting you
		var/list/victims = force_eject(TRUE)
		for(var/mob/living/M in victims)
			M.forceMove(T)
			M.apply_damage(400) //No way you're surviving that

	else //If we're anywhere that isn't the overmap
		var/list/victims = force_eject(TRUE)
		for(var/mob/living/M in victims)
			M.apply_damage(200)

/obj/structure/overmap/fighter/attackby(obj/item/W, mob/user, params)   //fueling and changing equipment
	add_fingerprint(user)
	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda) && operators.len)
		if(!allowed(user))
			var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
			playsound(src, sound, 100, 1)
			to_chat(user, "<span class='warning'>Access denied</span>")
			return
		if(alert("What do you want to do?",name,"Eject Occupants","Maintenance Mode") == "Eject Occupants")
			if(!Adjacent(user))
				return
			to_chat(user, "<span class='warning'>Ejecting all current occupants from [src] and activating inertial dampeners...</span>")
			force_eject()
		else
			if(!Adjacent(user))
				return
			to_chat(user, "<span class='warning'>You swipe your card and [maintenance_mode ? "disable" : "enable"] maintenance protocols.</span>")
			maintenance_mode = !maintenance_mode
	..()

/obj/structure/overmap/fighter/take_damage(damage_amount, damage_type, damage_flag, sound_effect)
	var/obj/item/fighter_component/armour_plating/A = loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
	if(A && istype(A))
		A.take_damage(damage_amount, damage_type, damage_flag, sound_effect)
		if(A.obj_integrity <= 0)
			loadout.remove_hardpoint(A, TRUE)
			qdel(A) //There goes your armour!
		relay(pick('nsv13/sound/effects/ship/freespace2/ding1.wav', 'nsv13/sound/effects/ship/freespace2/ding2.wav', 'nsv13/sound/effects/ship/freespace2/ding3.wav', 'nsv13/sound/effects/ship/freespace2/ding4.wav', 'nsv13/sound/effects/ship/freespace2/ding5.wav'))
	else
		. = ..()
	var/obj/item/fighter_component/canopy/C = loadout.get_slot(HARDPOINT_SLOT_CANOPY)
	if(!C) //Riding without a canopy is not without consequences
		if(prob(30)) //Ouch!
			for(var/mob/living/M in contents)
				to_chat(M , "<span class='warning'>You feel something hit you!</span>")
				M.take_overall_damage(damage_amount/2)
		return
	if(prob(50))
		relay('sound/effects/glasshit.ogg')
		C.take_damage(damage_amount/2, damage_type, damage_flag, sound_effect)
		if(C.obj_integrity <= 0)
			canopy_breach(C)

/obj/structure/overmap/fighter/proc/canopy_breach(obj/item/fighter_component/canopy/C)
	relay('nsv13/sound/effects/ship/cockpit_breach.ogg') //We're leaking air!
	loadout.remove_hardpoint(HARDPOINT_SLOT_CANOPY, TRUE)
	qdel(C) //Pop off the canopy.
	sleep(2 SECONDS)
	relay('nsv13/sound/effects/ship/reactor/gasmask.ogg', "<span class='warning'>The air around you rushes out of the breached canopy!</span>", loop = FALSE, channel = CHANNEL_SHIP_ALERT)
	return

/obj/structure/overmap/fighter/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>[src] isn't in need of repairs.</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You start welding some dents out of [src]'s hull...</span>")
	if(I.use_tool(src, user, 4 SECONDS, volume=100))
		to_chat(user, "<span class='notice'>You weld some dents out of [src]'s hull.</span>")
		obj_integrity += min(10, max_integrity-obj_integrity)
		return TRUE
/datum/component/ship_loadout
	can_transfer = FALSE
	var/list/equippable_slots = ALL_HARDPOINT_SLOTS //What slots does this loadout support? Want to allow a fighter to have multiple utility slots?
	var/list/hardpoint_slots = list()
	var/obj/structure/overmap/holder //To get overmap class vars.

/datum/component/ship_loadout/utility
	equippable_slots = HARDPOINT_SLOTS_UTILITY

/datum/component/ship_loadout/Initialize(source)
	. = ..()
	if(!istype(parent, /obj/structure/overmap))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSobj, src)
	holder = parent
	for(var/hardpoint in equippable_slots)
		hardpoint_slots[hardpoint] = null

/datum/component/ship_loadout/proc/get_slot(slot)
	RETURN_TYPE(/obj/item/fighter_component)
	return hardpoint_slots[slot]

/datum/component/ship_loadout/proc/install_hardpoint(obj/item/fighter_component/replacement)
	var/slot = replacement.slot
	if(slot && !(slot in equippable_slots))
		replacement.visible_message("<span class='warning'>[replacement] can't fit onto [parent]")
		return FALSE
	remove_hardpoint(slot, FALSE)
	replacement.on_install(holder)
	if(slot) //Not every component has a slot per se, as some are just used for construction and can't really be interacted with.
		hardpoint_slots[slot] = replacement

/**
Method to remove a hardpoint from the loadout. It can be passed a slot as a defined flag, or slot as a physical hardpoint (as not all hardpoints have a specific slot.)
args:
slot: Either a slot or a specific component
due_to_damage: Was this called voluntarily (FALSE) or due to damage / external causes (TRUE). Is given to the remove_from() proc and modifies specifics of the removal.
*/
/datum/component/ship_loadout/proc/remove_hardpoint(slot, due_to_damage)
	if(!slot)
		return FALSE

	var/obj/item/fighter_component/component = null
	if(istype(slot, /obj/item/fighter_component))
		component = slot
		hardpoint_slots[component.slot] = null
	else
		component = get_slot(slot)
		hardpoint_slots[slot] = null

	if(component && istype(component))
		component.remove_from(holder, due_to_damage)

/datum/component/ship_loadout/proc/dump_contents(slot)
	var/obj/item/fighter_component/component = null
	if(istype(slot, /obj/item/fighter_component))
		component = slot
	else
		component = get_slot(slot)
	component.dump_contents()

/datum/component/ship_loadout/process()
	for(var/slot in equippable_slots)
		var/obj/item/fighter_component/component = hardpoint_slots[slot]
		component?.process()

/obj/item/fighter_component
	name = "\improper Fighter Component"
	desc = "It doesn't really do a whole lot"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	//Thanks to comxy on Discord for these lovely tiered sprites o7
	var/tier = 1 //Icon states are formatted as: armour_tier1 and so on.
	var/slot = null //Change me!
	var/weight = 0 //Some more advanced modules will weigh your fighter down some.
	var/power_usage = 0 //Does this module require power to process()?
	var/fire_mode = null //Used if this is a weapon style hardpoint
	var/active = TRUE

/obj/item/fighter_component/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click it to unload its contents.</span>"

/obj/item/fighter_component/proc/toggle()
	active = !active

/obj/item/fighter_component/proc/dump_contents()
	if(!contents?.len)
		return FALSE
	. = list()
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(loc))
		. += AM

/obj/item/fighter_component/proc/get_ammo()
	return FALSE

/obj/item/fighter_component/proc/get_max_ammo()
	return FALSE

/obj/item/fighter_component/Initialize()
	.=..()
	AddComponent(/datum/component/twohanded/required) //These all require two hands to pick up
	if(tier)
		icon_state = icon_state+"_tier[tier]"

//Overload this method to apply stat benefits based on your module.
/obj/item/fighter_component/proc/on_install(obj/structure/overmap/target)
	forceMove(target)
	apply_drag(target)
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	target.visible_message("<span class='notice'>[src] mounts onto [target]")
	return TRUE

//Allows you to jumpstart a fighter with an inducer.
/obj/structure/overmap/fighter/get_cell()
	return loadout.get_slot(HARDPOINT_SLOT_BATTERY)

/obj/item/fighter_component/proc/powered()
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F) || !active)
		return FALSE
	var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	return B?.use_power(power_usage)

/obj/item/fighter_component/process()
	if(!powered())
		return FALSE
	return TRUE

//Used for weapon style hardpoints
/obj/item/fighter_component/proc/fire(obj/structure/overmap/target)
	return FALSE

/*
If you need your hardpoint to be loaded with things by clicking the fighter
*/
/obj/item/fighter_component/proc/load(obj/structure/overmap/target, atom/movable/AM)
	return FALSE

/obj/item/fighter_component/proc/apply_drag(obj/structure/overmap/target)
	if(!weight)
		return FALSE
	target.speed_limit -= weight
	target.speed_limit = (target.speed_limit > 0) ? target.speed_limit : 0
	target.forward_maxthrust -= weight
	target.forward_maxthrust = (target.forward_maxthrust > 0) ? target.forward_maxthrust : 0
	target.backward_maxthrust -= weight
	target.backward_maxthrust = (target.backward_maxthrust > 0) ? target.backward_maxthrust : 0
	target.side_maxthrust -= 0.25*weight
	target.side_maxthrust = (target.side_maxthrust > 0) ? target.side_maxthrust : 0
	target.max_angular_acceleration -= weight*10
	target.max_angular_acceleration = (target.max_angular_acceleration > 0) ? target.max_angular_acceleration : 0

/*
Remove from(), a proc that forcemoves a component onto the target's tile and removes the weight penalties caused by the specific component. Usually used for removal, but doesn't actually check if it was on the target, use with care.
args:
target: The overmap structure getting the component's weight penalties removed, aswell as the component being moved to its tile.
due_to_damage: If the removal was caused voluntarily (FALSE), or if it was caused by external sources / damage (TRUE); generally influences some specifics of removal on some components.
*/
/obj/item/fighter_component/proc/remove_from(obj/structure/overmap/target, due_to_damage)
	forceMove(get_turf(target))
	if(!weight)
		return TRUE
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(target))
	target.speed_limit += weight
	target.forward_maxthrust += weight
	target.backward_maxthrust += weight
	target.side_maxthrust += 0.25*weight
	target.max_angular_acceleration += weight*10
	return TRUE

/obj/item/fighter_component/armour_plating
	name = "\improper Durasteel Armour Plates"
	desc = "A set of armour plates which can afford basic protection to a fighter, however heavier plates may slow you down"
	icon_state = "armour"
	slot = HARDPOINT_SLOT_ARMOUR
	weight = 1
	obj_integrity = 250
	max_integrity = 250
	armor = list("melee" = 50, "bullet" = 40, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //Armour's pretty tough.

//Sometimes you need to repair your physical armour plates.
/obj/item/fighter_component/armour_plating/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>[src] isn't in need of repairs.</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You start welding some dents out of [src]...</span>")
	if(I.use_tool(src, user, 4 SECONDS, volume=100))
		to_chat(user, "<span class='notice'>You weld some dents out of [src].</span>")
		obj_integrity += min(10, max_integrity-obj_integrity)
		return TRUE

/obj/item/fighter_component/armour_plating/tier2
	name = "\improper Ultra Heavy Fighter Armour"
	desc = "An extremely thick and heavy set of armour plates. Guaranteed to weigh you down, but it'll keep you flying through brasil itself."
	tier = 2
	weight = 2
	obj_integrity = 450
	max_integrity = 450

/obj/item/fighter_component/armour_plating/tier3
	name = "\improper Nanocarbon Armour Plates"
	desc = "A lightweight set of ablative armour which balances speed and protection at the cost of the average GDP of most third world countries."
	tier = 3
	weight = 1.25
	obj_integrity = 300
	max_integrity = 300

/obj/item/fighter_component/canopy
	name = "\improper Glass canopy"
	desc = "A fighter canopy made of standard glass, it's extremely fragile and is so cheaply produced that it serves as little less than a windshield."
	icon_state = "canopy"
	obj_integrity = 100 //Pretty fragile, don't break it you dumblet
	max_integrity = 100
	slot = HARDPOINT_SLOT_CANOPY
	weight = 0.25 //Real pilots just wear pilot goggles and strip out their canopy.
	tier = 0.5

/obj/item/fighter_component/canopy/reinforced
	name = "\improper Reinforced Glass Canopy"
	desc = "A glass fighter canopy that's designed to maintain atmospheric pressure inside of a fighter, this one's pretty robust."
	obj_integrity = 200
	max_integrity = 200
	tier = 1
	weight = 0.5

/obj/item/fighter_component/canopy/tier2
	name = "\improper Nanocarbon glass canopy"
	desc = "A glass fighter canopy that's designed to maintain atmospheric pressure inside of a fighter, this one's very robust."
	obj_integrity = 350
	max_integrity = 350
	tier = 2
	weight = 0.35

/obj/item/fighter_component/canopy/tier3
	name = "\improper Plasma glass canopy"
	desc = "A glass fighter canopy that's designed to maintain atmospheric pressure inside of a fighter, this one's exceptionally robust."
	obj_integrity = 450
	max_integrity = 450
	tier = 3
	weight = 0.55

/obj/item/fighter_component/battery
	name = "\improper Fighter Battery"
	icon_state = "battery"
	slot = HARDPOINT_SLOT_BATTERY
	active = FALSE
	var/charge = 10000
	var/maxcharge = 10000
	var/self_charge = FALSE //TODO! Engine powers this.

/obj/item/fighter_component/battery/process()
	if(self_charge)
		give(1000)

/obj/item/fighter_component/battery/proc/give(amount)
	if(charge >= maxcharge)
		return FALSE
	charge += amount
	charge = CLAMP(charge, 0, maxcharge)

/obj/item/fighter_component/battery/proc/use_power(amount)
	if(!active)
		return FALSE
	charge -= amount
	charge = CLAMP(charge, 0, maxcharge)
	if(charge <= 0)
		var/obj/structure/overmap/fighter/F = loc
		if(!istype(F))
			return FALSE
		if(active)
			F.set_master_caution(TRUE)
			active = FALSE
	return charge > 0

/obj/item/fighter_component/battery/tier2
	name = "\improper Upgraded Fighter Battery"
	tier = 2
	charge = 20000
	maxcharge = 20000

/obj/item/fighter_component/battery/tier3
	name = "\improper Mega Fighter Battery"
	desc = "An electrochemical cell capable of holding a good amount of charge for keeping the fighter's radio on for longer periods without an engine."
	tier = 3
	charge = 40000
	maxcharge = 40000

/obj/item/fighter_component/armour_plating/on_install(obj/structure/overmap/target)
	..()
	target.max_integrity = initial(target.max_integrity)*tier

/obj/item/fighter_component/armour_plating/remove_from(obj/structure/overmap/target, due_to_damage)
	..()
	if(due_to_damage)
		return //We don't reset our health if the plating was destroyed due to hits, or the increase would be useless. It DOES get reset once we install new armor, though.
	target.max_integrity = initial(target.max_integrity)
	//Remove any overheal.
	target.obj_integrity = CLAMP(target.obj_integrity, 0, target.max_integrity)

//Fuel
/obj/structure/overmap/fighter/proc/get_fuel()
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	. = 0
	for(var/datum/reagent/cryogenic_fuel/F in ft?.reagents.reagent_list)
		if(!istype(F))
			continue
		. += F.volume
	return .

/obj/structure/overmap/fighter/proc/set_fuel(amount)
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return FALSE
	ft.reagents.add_reagent(/datum/reagent/cryogenic_fuel, 1, reagtemp = 40) //Assert that we have this reagent in the tank.
	for(var/datum/reagent/cryogenic_fuel/F in ft?.reagents.reagent_list)
		if(!istype(F))
			continue
		F.volume = amount
	return amount

/obj/structure/overmap/fighter/proc/engines_active()
	var/obj/item/fighter_component/engine/E = loadout.get_slot(HARDPOINT_SLOT_ENGINE)//E's are good E's are good, he's ebeneezer goode.
	return (E?.active() && get_fuel() > 0)

/obj/structure/overmap/fighter/proc/set_master_caution(state)
	if(state)
		relay('nsv13/sound/effects/fighters/master_caution.ogg', null, loop=TRUE, channel=CHANNEL_HEARTBEAT)
		master_caution = TRUE
	else
		stop_relay(CHANNEL_HEARTBEAT) //CONSIDER MAKING OWN CHANNEL
		master_caution = FALSE

/obj/structure/overmap/fighter/proc/use_fuel(force=FALSE)
	if(!engines_active() && !force) //No fuel? don't spam them with master cautions / use any fuel
		return FALSE
	var/fuel_consumption = 0.5*(loadout.get_slot(HARDPOINT_SLOT_ENGINE)?.tier)
	var/amount = (user_thrust_dir) ? fuel_consumption+0.25 : fuel_consumption //When you're thrusting : fuel consumption doubles. Idling is cheap.
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return FALSE
	ft.reagents.remove_reagent(/datum/reagent/cryogenic_fuel, amount)
	if(get_fuel() >= amount)
		return TRUE
	set_master_caution(TRUE)
	return FALSE

/obj/structure/overmap/fighter/can_move()
	return (engines_active())

/obj/structure/overmap/fighter/proc/empty_fuel_tank()//Debug purposes, for when you need to drain a fighter's tank entirely.
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return FALSE
	ft.reagents.clear_reagents()

/obj/structure/overmap/fighter/proc/get_max_fuel()
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return 0
	return ft.reagents.maximum_volume

/obj/item/fighter_component/fuel_tank
	name = "\improper Fighter Fuel Tank"
	desc = "The fuel tank of a fighter, upgrading this lets your fighter hold more fuel."
	icon_state = "fueltank"
	var/fuel_capacity = 1000
	slot = HARDPOINT_SLOT_FUEL

/obj/item/fighter_component/fuel_tank/Initialize()
	.=..()
	create_reagents(fuel_capacity, DRAINABLE | AMOUNT_VISIBLE)

/obj/item/fighter_component/fuel_tank/tier2
	name = "\improper Fighter Extended Fuel Tank"
	desc = "A larger fuel tank which allows fighters to stay in combat for much longer"
	fuel_capacity = 2500
	tier = 2

/obj/item/fighter_component/fuel_tank/tier3
	name = "\improper Massive Fighter Fuel Tank"
	desc = "A super extended capacity fuel tank, allowing fighters to stay in a warzone for hours on end."
	fuel_capacity = 4000
	tier = 3

/obj/item/fighter_component/engine
	name = "\improper Fighter engine"
	desc = "A mighty engine capable of propelling small spacecraft to high speeds."
	icon_state = "engine"
	slot = HARDPOINT_SLOT_ENGINE
	active = FALSE
	var/rpm = 0
	var/flooded = FALSE

/obj/item/fighter_component/engine/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!flooded)
		return
	to_chat(user, "<span class='notice'>You start to purge [src] of its flooded fuel.</span>")
	if(do_after(user, 10 SECONDS, target=src))
		flooded = FALSE
		shake_animation()

/obj/item/fighter_component/engine/proc/active()
	return (active && obj_integrity > 0 && rpm >= ENGINE_RPM_SPUN && !flooded)

/obj/item/fighter_component/engine/process()
	var/obj/structure/overmap/fighter/F = loc
	var/obj/item/fighter_component/apu/APU = F.loadout.get_slot(HARDPOINT_SLOT_APU)
	if(!APU?.fuel_line && rpm > 0)
		rpm -= 1000 //Spool down the engine.
		if(rpm <= 0)
			playsound(loc, 'nsv13/sound/effects/ship/rcs.ogg', 100, TRUE)
			loc.visible_message("<span class='userdanger'>[src] fizzles out!</span>")
			rpm = 0
			F.stop_relay(CHANNEL_SHIP_ALERT)
			active = FALSE
			return FALSE
	if(!istype(F))
		return FALSE
	if(rpm > 3000)
		var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
		B.give(500*tier)
	if(!active())
		return FALSE

/obj/item/fighter_component/engine/proc/apu_spin(amount)
	if(flooded)
		loc.visible_message("<span class='warning'>[src] sputters uselessly.</span>")
		return
	rpm += amount
	rpm = CLAMP(rpm, 0, ENGINE_RPM_SPUN)

/obj/item/fighter_component/engine/proc/try_start()
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F))
		return FALSE
	if(rpm >= ENGINE_RPM_SPUN-200) //You get a small bit of leeway.
		active = TRUE
		rpm = ENGINE_RPM_SPUN
		playsound(loc, 'nsv13/sound/effects/fighters/startup.ogg', 100, FALSE)
		F.relay('nsv13/sound/effects/fighters/cockpit.ogg', "<span class='warning'>You hear a loud noise as [F]'s engine kicks in.</span>", loop=TRUE, channel = CHANNEL_SHIP_ALERT)
		return
	else
		playsound(loc, 'sound/machines/clockcult/steam_whoosh.ogg', 100, TRUE)
		loc.visible_message("<span class='warning'>[src] sputters slightly.</span>")
		if(prob(20)) //Don't try and start a not spun engine, flyboys.
			playsound(loc, 'nsv13/sound/effects/ship/rcs.ogg', 100, TRUE)
			loc.visible_message("<span class='userdanger'>[src] violently fizzles out!.</span>")
			F.set_master_caution(TRUE)
			rpm = 0
			flooded = TRUE
			active = FALSE

/obj/item/fighter_component/engine/tier2
	name = "\improper Souped up fighter engine"
	desc = "Born to zoom, forced to oom"
	tier = 2

/obj/item/fighter_component/engine/tier3
	name = "\improper Boringheed Marty V12 Super Giga Turbofan Space Engine"
	desc = "An engine which allows a fighter to exceed the legal speed limit in most jurisdictions."
	tier = 3

/obj/item/fighter_component/engine/on_install(obj/structure/overmap/fighter/target)
	..()
	target.speed_limit = initial(target.speed_limit)*tier
	target.forward_maxthrust = initial(target.forward_maxthrust)*tier
	target.backward_maxthrust = initial(target.backward_maxthrust)*tier
	target.side_maxthrust = initial(target.side_maxthrust)*tier
	target.max_angular_acceleration = initial(target.max_angular_acceleration)*tier
	for(var/slot in target.loadout.equippable_slots)
		var/obj/item/fighter_component/FC = target.loadout.get_slot(slot)
		FC?.apply_drag(target)

/obj/item/fighter_component/engine/remove_from(obj/structure/overmap/target)
	..()
	//No engines? No movement.
	target.speed_limit = 0
	target.forward_maxthrust = 0
	target.backward_maxthrust = 0
	target.side_maxthrust = 0
	target.max_angular_acceleration = 0

//Atmos

/obj/item/fighter_component/oxygenator
	name = "\improper Atmospheric Regulator"
	desc = "A device which moderates the conditions inside a fighter, it requires fuel to run."
	icon_state = "oxygenator"
	var/refill_amount = 1 //Starts off really terrible.
	slot = HARDPOINT_SLOT_OXYGENATOR
	weight = 0.5 //Wanna go REALLY FAST? Pack your own O2.
	power_usage = 200

/obj/item/fighter_component/oxygenator/tier2
	name = "\improper Upgraded Atmospheric Regulator"
	tier = 2
	refill_amount = 3
	power_usage = 300

/obj/item/fighter_component/oxygenator/tier3
	name = "\improper Super Oxygenator"
	desc = "A finely tuned atmospheric regulator to be fitted into a fighter which seems to be able to almost magically create oxygen out of nowhere."
	tier = 3
	refill_amount = 10
	power_usage = 400

/obj/item/fighter_component/oxygenator/plasmaman
	name = "\improper Plasmaman Atmospheric Regulator"
	desc = "An atmospheric regulator to be used in fighters, it's been rigged to fill the cabin with a hospitable environment for plasmamen instead of standard oxygen."
	refill_amount = 3
	tier = 4 //unique! but it has to have a sprite to make it obvious that, yknow, this is for plasmemes.

/obj/item/fighter_component/oxygenator/process()
	//Don't waste power on already fine atmos.
	var/obj/structure/overmap/OM = loc
	if(!istype(OM))
		return FALSE
	if(!..())
		return FALSE
	if(OM.cabin_air.return_pressure()+refill_amount >= WARNING_HIGH_PRESSURE-(2*refill_amount))
		return FALSE //No need to add more air to an already pressurized environment

	//Oxygenator just makes sure you have atmosphere. It doesn't care where it comes from.
	OM.cabin_air.set_temperature(T20C)
	//Gives you a little bit of air.
	refill(OM)
	return TRUE

/obj/item/fighter_component/oxygenator/proc/refill(obj/structure/overmap/OM)
	OM.cabin_air.adjust_moles(/datum/gas/oxygen, refill_amount*O2STANDARD)
	OM.cabin_air.adjust_moles(/datum/gas/nitrogen, refill_amount*N2STANDARD)
	OM.cabin_air.adjust_moles(/datum/gas/carbon_dioxide, -refill_amount)

/obj/item/fighter_component/oxygenator/plasmaman/refill(obj/structure/overmap/OM)
	OM.cabin_air.adjust_moles(/datum/gas/plasma, refill_amount*N2STANDARD)
	OM.cabin_air.adjust_moles(/datum/gas/oxygen, -refill_amount)
	OM.cabin_air.adjust_moles(/datum/gas/nitrogen, -refill_amount)

//Construction only components

/obj/item/fighter_component/avionics
	name = "\improper Fighter Avionics"
	desc = "Avionics for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "avionics"

/obj/item/fighter_component/apu
	name = "\improper Fighter Auxiliary Power Unit"
	desc = "An Auxiliary Power Unit for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "apu"
	slot = HARDPOINT_SLOT_APU
	tier = 1
	active = FALSE
	var/fuel_line = FALSE
	var/next_process = 0

/obj/item/fighter_component/apu/tier2
	name = "\improper Upgraded fighter APU"
	tier = 2

/obj/item/fighter_component/apu/tier3
	name = "\improper Super fighter APU"
	desc = "A small engine capable of rapidly starting a fighter."
	tier = 3

/obj/item/fighter_component/apu/proc/toggle_fuel_line()
	fuel_line = !fuel_line

/obj/item/fighter_component/apu/process()
	if(!..())
		return
	if(world.time < next_process)
		return
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F))
		return FALSE
	next_process = world.time + 4 SECONDS
	if(!fuel_line)
		return //APU needs fuel to drink
	playsound(F, 'nsv13/sound/effects/fighters/apu_loop.ogg', 70, FALSE)
	var/obj/item/fighter_component/engine/engine = F.loadout.get_slot(HARDPOINT_SLOT_ENGINE)
	F.use_fuel(2, TRUE) //APUs take fuel to run.
	if(engine.active())
		return
	engine.apu_spin(500*tier)


/obj/item/fighter_component/countermeasure_dispenser
	name = "\improper Fighter Countermeasure Dispenser"
	desc = "A device which allows a fighter to deploy countermeasures."
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "countermeasure"

/obj/item/fighter_component/docking_computer
	name = "\improper Docking Computer"
	desc = "A computer that allows fighters to easily dock to a ship"
	icon_state = "docking_computer"
	slot = HARDPOINT_SLOT_DOCKING
	tier = null //Not upgradable right now.
	var/docking_mode = FALSE
	var/docking_cooldown = FALSE

/*Weaponry!
As a rule of thumb, primaries are small guns that take ammo boxes, secondaries are big guns that require big bulky objects to be loaded into them.
Utility modules can be either one of these types, just ensure you set its slot to HARDPOINT_SLOT_UTILITY
*/
/obj/item/fighter_component/primary
	name = "\improper Fuck you" // because a proper "fuck you" would just be rude
	slot = HARDPOINT_SLOT_PRIMARY
	fire_mode = FIRE_MODE_PDC
	var/overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	var/overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	var/accepted_ammo = /obj/item/ammo_box/magazine
	var/obj/item/ammo_box/magazine/magazine = null
	var/list/ammo = list()
	var/burst_size = 1
	var/fire_delay = 0

/obj/item/fighter_component/primary/dump_contents()
	. = ..()
	for(var/atom/movable/AM in .)
		if(AM == magazine)
			magazine = null
			ammo = list()
			playsound(loc, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)

/obj/item/fighter_component/primary/get_ammo()
	return ammo?.len

/obj/item/fighter_component/primary/get_max_ammo()
	return magazine ? magazine.max_ammo : 500 //Default.

//Ensure we get the genericised equipment mounts.
/obj/structure/overmap/fighter/apply_weapons()
	if(!weapon_types[FIRE_MODE_PDC])
		weapon_types[FIRE_MODE_PDC] = new/datum/ship_weapon/fighter_primary(src)
	if(!weapon_types[FIRE_MODE_TORPEDO])
		weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/fighter_secondary(src)

/obj/structure/overmap/proc/primary_fire(obj/structure/overmap/target)
	hardpoint_fire(target, FIRE_MODE_PDC)

/obj/structure/overmap/proc/hardpoint_fire(obj/structure/overmap/target, fireMode)
	if(istype(src, /obj/structure/overmap/fighter))
		var/obj/structure/overmap/fighter/F = src
		for(var/slot in F.loadout.equippable_slots)
			var/obj/item/fighter_component/weapon = F.loadout.hardpoint_slots[slot]
			//Look for any "primary" hardpoints, be those guns or utility slots
			if(!weapon || weapon.fire_mode != fireMode)
				continue
			var/datum/ship_weapon/SW = weapon_types[weapon.fire_mode]
			for(var/I = 0; I < SW.burst_size; I++)
				weapon.fire(target)
				sleep(1)
			return TRUE
	return FALSE

/obj/structure/overmap/proc/secondary_fire(obj/structure/overmap/target)
	hardpoint_fire(target, FIRE_MODE_TORPEDO)

/obj/item/fighter_component/primary/load(obj/structure/overmap/target, atom/movable/AM)
	if(!istype(AM, accepted_ammo))
		return FALSE
	magazine?.forceMove(get_turf(target))
	if(!SSmapping.level_trait(loc.z, ZTRAIT_BOARDABLE))
		qdel(magazine) //So bullets don't drop onto the overmap.
	AM.forceMove(src)
	magazine = AM
	ammo = magazine.stored_ammo
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/primary/fire(obj/structure/overmap/target)
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F))
		return FALSE
	if(!ammo.len)
		F.relay('sound/weapons/gun_dry_fire.ogg')
		return FALSE
	var/obj/item/ammo_casing/chambered = ammo[ammo.len]
	var/datum/ship_weapon/SW = F.weapon_types[fire_mode]
	SW.default_projectile_type = chambered.projectile_type
	SW.fire_fx_only(target)
	ammo -= chambered
	qdel(chambered)
	return TRUE

/obj/item/fighter_component/primary/on_install(obj/structure/overmap/target)
	. = ..()
	if(!fire_mode)
		return FALSE
	var/datum/ship_weapon/SW = target.weapon_types[fire_mode]
	SW.overmap_firing_sounds = overmap_firing_sounds
	SW.overmap_select_sound = overmap_select_sound
	SW.burst_size = burst_size
	SW.fire_delay = fire_delay

/obj/item/fighter_component/primary/remove_from(obj/structure/overmap/target)
	. = ..()
	magazine = null
	ammo = list()

/obj/item/fighter_component/primary/cannon
	name = "30mm Vulcan Cannon"
	icon_state = "lightcannon"
	accepted_ammo = /obj/item/ammo_box/magazine/light_cannon
	burst_size = 2
	fire_delay = 0.25 SECONDS

/obj/item/fighter_component/primary/cannon/heavy
	name = "40mm BRRRRTT Cannon"
	icon_state = "heavycannon"
	accepted_ammo = /obj/item/ammo_box/magazine/heavy_cannon
	weight = 2 //Sloooow down there.
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/BRRTTTTTT.ogg')
	burst_size = 3
	fire_delay = 0.5 SECONDS

/obj/item/fighter_component/secondary
	name = "\improper Fuck you"
	slot = HARDPOINT_SLOT_SECONDARY
	fire_mode = FIRE_MODE_TORPEDO
	var/overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	var/overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	var/accepted_ammo = /obj/item/ship_weapon/ammunition/missile
	var/list/ammo = list()
	var/max_ammo = 3
	var/burst_size = 1 //Cluster torps...UNLESS?
	var/fire_delay = 0.25 SECONDS

/obj/item/fighter_component/secondary/dump_contents()
	. = ..()
	for(var/atom/movable/AM in .)
		if(AM in ammo)
			ammo -= AM
			playsound(loc, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)

/obj/item/fighter_component/secondary/get_ammo()
	return ammo.len

/obj/item/fighter_component/secondary/get_max_ammo()
	return max_ammo

/obj/item/fighter_component/secondary/on_install(obj/structure/overmap/target)
	. = ..()
	if(!fire_mode)
		return FALSE
	var/datum/ship_weapon/SW = target.weapon_types[fire_mode]
	SW.overmap_firing_sounds = overmap_firing_sounds
	SW.overmap_select_sound = overmap_select_sound
	SW.burst_size = burst_size
	SW.fire_delay = fire_delay

/obj/item/fighter_component/secondary/remove_from(obj/structure/overmap/target)
	. = ..()
	ammo = list()

//Todo: make fighters use these.
/obj/item/fighter_component/secondary/ordnance_launcher
	name = "\improper Fighter Missile Rack"
	desc = "A huge fighter missile rack capable of deploying missile based weaponry."
	icon_state = "missilerack"

/obj/item/fighter_component/secondary/ordnance_launcher/tier2
	name = "\improper Upgraded Fighter Missile Rack"
	tier = 2
	max_ammo = 5

/obj/item/fighter_component/secondary/ordnance_launcher/tier3
	name = "\improper A-11 'Spacehog' Cluster-Freedom Launcher"
	tier = 3
	max_ammo = 15
	weight = 1
	burst_size = 2
	fire_delay = 0.10 SECONDS

//Specialist item for the superiority fighter.
/obj/item/fighter_component/secondary/ordnance_launcher/railgun
	name = "\improper Fighter Railgun"
	desc = "A scaled down railgun designed for use in fighters."
	icon_state = "railgun"
	weight = 1
	accepted_ammo = /obj/item/ship_weapon/ammunition/railgun_ammo
	overmap_firing_sounds = list('nsv13/sound/effects/ship/railgun_fire.ogg')
	burst_size = 1
	fire_delay = 0.2 SECONDS
	max_ammo = 10
	tier = 1

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo
	name = "\improper Fighter Torpedo Launcher"
	desc = "A heavy torpedo rack which allows fighters to fire torpedoes at targets"
	icon_state = "torpedorack"
	accepted_ammo = /obj/item/ship_weapon/ammunition/torpedo
	max_ammo = 2
	weight = 1

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier2
	name = "\improper Enhanced Torpedo Launcher"
	tier = 2
	max_ammo = 4

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier3
	name = "\improper FR33-8IRD Torpedo Launcher"
	desc = "A massive torpedo launcher capable of deploying enough ordnance to level several small, oil-rich nations."
	tier = 3
	max_ammo = 10
	weight = 2
	burst_size = 2

/obj/item/fighter_component/secondary/ordnance_launcher/load(obj/structure/overmap/target, atom/movable/AM)
	if(!istype(AM, accepted_ammo))
		return FALSE
	if(ammo.len >= max_ammo)
		return FALSE
	AM.forceMove(src)
	ammo += AM
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/secondary/ordnance_launcher/fire(obj/structure/overmap/target)
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F))
		return FALSE
	if(!ammo.len)
		F.relay('sound/weapons/gun_dry_fire.ogg')
		return FALSE
	var/proj_type = null //If this is true, we've got a launcher shipside that's been able to fire.
	var/proj_speed = 1
	var/obj/item/ship_weapon/ammunition/americagobrr = pick_n_take(ammo)
	proj_type = americagobrr.projectile_type
	proj_speed = istype(americagobrr.projectile_type, /obj/item/projectile/guided_munition/missile) ? 5 : 1
	qdel(americagobrr)
	if(proj_type)
		var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo.ogg','nsv13/sound/effects/ship/freespace2/m_shrike.wav','nsv13/sound/effects/ship/freespace2/m_stiletto.wav','nsv13/sound/effects/ship/freespace2/m_tsunami.wav','nsv13/sound/effects/ship/freespace2/m_wasp.wav')
		F.relay_to_nearby(chosen)
		if(proj_type == /obj/item/projectile/guided_munition/missile/dud) //Refactor this to something less trash sometime I guess
			F.fire_projectile(proj_type, target, homing = FALSE, speed=proj_speed, lateral = FALSE)
		else
			F.fire_projectile(proj_type, target, homing = TRUE, speed=proj_speed, lateral = FALSE)
	return TRUE

//Utility modules.

/obj/item/fighter_component/primary/utility
	name = "\improper No :)"
	slot = HARDPOINT_SLOT_UTILITY_PRIMARY

/obj/item/fighter_component/primary/utility/fire(obj/structure/overmap/target)
	return FALSE

/obj/item/fighter_component/primary/utility/hold
	name = "\improper Cargo Hold"
	desc = "A cramped cargo hold for hauling light freight."
	icon_state = "hold"
	var/max_w_class = WEIGHT_CLASS_GIGANTIC
	var/max_freight = 5

/obj/item/fighter_component/primary/utility/hold/tier2
	name = "\improper Expanded Cargo Hold"
	tier = 2
	max_freight = 10

/obj/item/fighter_component/primary/utility/hold/tier3
	name = "\improper S0CC3RMUM Jumbo Sized Cargo Hold"
	desc ="Now with extra space for seating unlucky friends in the boot!"
	tier = 3
	max_freight = 20

/obj/item/fighter_component/primary/utility/hold/load(obj/structure/overmap/target, atom/movable/AM)
	if(contents && contents.len >= max_freight || isliving(AM) || istype(AM, /obj/item/fighter_component) || istype(AM, /obj/item/card/id) || istype(AM, /obj/item/pda) || istype(AM, /obj/structure/overmap)) //This just causess issues, trust me on this)
		return FALSE
	if((AM.move_resist > MOVE_FORCE_DEFAULT) || !AM.doMove(src))
		return //Can't put ultra heavy stuff in
	target.visible_message("[icon2html(src)] [AM] is loaded into the cargo hold")
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/primary/utility/repairer
	name = "\improper Ship-to-hip Repair Kit"
	desc = "A module which can use hull repair foam to repair other fighters in the air."
	icon_state = "repairer"
	accepted_ammo = /obj/structure/reagent_dispensers/foamtank/hull_repair_juice
	power_usage = 50
	fire_delay = 5 SECONDS
	var/datum/beam/current_beam = null
	var/next_repair = 0

/obj/item/fighter_component/primary/utility/repairer/get_ammo()
	return magazine?.reagents.total_volume

/obj/item/fighter_component/primary/utility/repairer/get_max_ammo()
	return magazine?.reagents.maximum_volume

/obj/item/fighter_component/primary/utility/repairer/tier2
	name = "\improper Upgraded Ship-to-Ship Repair Kit"
	tier = 2
	fire_delay = 4 SECONDS

/obj/item/fighter_component/primary/utility/repairer/tier3
	name = "\improper Super Ship-to-ship Repair Kit"
	tier = 3
	fire_delay = 3 SECONDS

/obj/item/fighter_component/primary/utility/repairer/load(obj/structure/overmap/target, atom/movable/AM)
	if(!istype(AM, accepted_ammo))
		return FALSE
	magazine?.forceMove(get_turf(target))
	if(!SSmapping.level_trait(loc.z, ZTRAIT_BOARDABLE))
		qdel(magazine) //So bullets don't drop onto the overmap.
	AM.forceMove(src)
	magazine = AM
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/primary/utility/repairer/process()
	if(!..())
		return FALSE
	var/obj/structure/overmap/fighter/us = loc
	if(!us || !istype(us) || us.fire_mode != fire_mode)
		qdel(current_beam)
		return FALSE
	var/obj/structure/overmap/them = us.autofire_target
	if(!them || !istype(them))
		qdel(current_beam)
		return FALSE
	var/obj/structure/reagent_dispensers/foamtank/hull_repair_juice/tank = magazine
	if(!tank || !istype(tank))
		qdel(current_beam)
		return FALSE
	if(world.time < next_repair)
		return FALSE
	next_repair = world.time + fire_delay
	new /obj/effect/temp_visual/heal(get_turf(them), COLOR_CYAN)
	tank.reagents.remove_reagent(/datum/reagent/hull_repair_juice, 5)
	//You can repair the main ship too! However at a painfully slow rate. Higher tiers give you vastly better repairs, and bigger ships repair smaller ships way faster.
	them.try_repair(0.5+tier-(them.mass-us.mass))
	//Generals sat from the lines at the back
	us.relay('sound/items/welder.ogg')
	them.relay('sound/items/welder2.ogg')
	if(!current_beam || QDELETED(current_beam))
		current_beam = new(us,them,beam_icon='icons/effects/beam.dmi',time=INFINITY,maxdistance = INFINITY,beam_icon_state="medbeam",btype=/obj/effect/ebeam/medical)
		INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)


/obj/item/fighter_component/secondary/utility
	name = "\improper Utility Module"
	slot = HARDPOINT_SLOT_UTILITY_SECONDARY
	power_usage = 200

/obj/item/fighter_component/secondary/utility/resupply
	name = "\improper Ship to Ship Resupply Kit"
	desc = "A large hose line which can allow a utility craft to perform Ship to Ship refuelling and resupply, without needing to RTB!"
	icon_state = "resupply"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/fighters/refuel.ogg')
	fire_delay = 6 SECONDS
	var/datum/beam/current_beam
	var/next_fuel = 0

/obj/item/fighter_component/secondary/utility/resupply/get_ammo()
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F))
		return 0
	return F.get_fuel()

/obj/item/fighter_component/secondary/utility/resupply/get_max_ammo()
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F))
		return 0
	return F.get_max_fuel()

/obj/item/fighter_component/secondary/utility/resupply/tier2
	name = "\improper Upgraded Ship to Ship Resupply Kit"
	fire_delay = 5 SECONDS
	tier = 2

/obj/item/fighter_component/secondary/utility/resupply/tier3
	name = "\improper Super Ship to Ship Resupply Kit"
	fire_delay = 3 SECONDS
	tier = 3

/obj/item/fighter_component/secondary/utility/resupply/process()
	if(!..())
		return
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F) || !F.autofire_target || F.fire_mode != fire_mode)
		qdel(current_beam)
		current_beam = null
		return FALSE
	if(world.time < next_fuel)
		return FALSE
	var/obj/structure/overmap/fighter/them = F.autofire_target
	if(!istype(them) || them == F) //No self targeting
		return FALSE
	next_fuel = world.time + fire_delay
	if(!current_beam || QDELETED(current_beam))
		current_beam = new(F,them,beam_icon='nsv13/icons/effects/beam.dmi',time=INFINITY,maxdistance = INFINITY,beam_icon_state="hose",btype=/obj/effect/ebeam/fuel_hose)
		INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)

	//Firstly, try to refuel the friendly.
	var/obj/item/fighter_component/fuel_tank/fuel = F.loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!fuel || F.get_fuel() <= 0)
		goto resupplyFuel
	var/obj/item/fighter_component/fuel_tank/theirFuel = them.loadout.get_slot(HARDPOINT_SLOT_FUEL)
	var/transfer_amount = min(50, them.get_max_fuel()-them.get_fuel()) //Transfer as much as we can
	transfer_amount = CLAMP(transfer_amount, 0, 100)//Don't want to overfill them
	F.relay('nsv13/sound/effects/fighters/refuel.ogg')
	them.relay('nsv13/sound/effects/fighters/refuel.ogg')
	var/obj/item/fighter_component/battery/B = them.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	if(B && istype(B))
		B.give(100) //Jumpstart their battery
	if(transfer_amount <= 0)
		goto resupplyFuel
	fuel.reagents.trans_to(theirFuel, transfer_amount)
	resupplyFuel:
	var/obj/item/fighter_component/primary/utility/hold = F.loadout.get_slot(HARDPOINT_SLOT_UTILITY_PRIMARY)
	if(!istype(hold))
		return FALSE
	var/obj/item/fighter_component/primary/theirGun = them.loadout.get_slot(HARDPOINT_SLOT_PRIMARY)
	var/obj/item/fighter_component/primary/theirTorp = them.loadout.get_slot(HARDPOINT_SLOT_SECONDARY)
	//Next up, try to refill the friendly's guns from whatever we have stored in cargo.
	for(var/atom/movable/AM in hold.contents)
		if(theirGun.load(them, AM))
			continue
		if(theirTorp.load(them, AM))
			continue

/obj/structure/overmap/fighter/update_icon()
	cut_overlays()
	..()
	var/obj/item/fighter_component/canopy/C = loadout?.get_slot(HARDPOINT_SLOT_CANOPY)
	if(!C)
		add_overlay(image(icon = icon, icon_state = "canopy_missing", dir = 1))
		return
	if(C.obj_integrity <= 20)
		add_overlay(image(icon = icon, icon_state = "canopy_breach", dir = 1))
		return
	if(canopy_open)
		add_overlay("canopy_open")

/obj/structure/overmap/fighter/slowprocess()
	..()
	if(engines_active())
		use_fuel()
		loadout.process()

	var/obj/item/fighter_component/canopy/C = loadout.get_slot(HARDPOINT_SLOT_CANOPY)

	// Leak air if the canopy is missing or broken
	// and air is in the cabin
	// and the fighter's environment isn't pressurized

	if((!C || (C.obj_integrity <= 0)) && (cabin_air && (cabin_air?.total_moles() > 0)))
		var/datum/gas_mixture/outside_air = loc?.return_air()
		var/outside_pressure = outside_air ? outside_air.return_pressure() : 0
		if(outside_pressure && (cabin_air.return_pressure() > outside_pressure))
			var/datum/gas_mixture/removed = cabin_air.remove(min(cabin_air.total_moles(), 5))
			qdel(removed)
	update_icon()

/obj/structure/overmap/fighter/return_air()
	var/obj/item/fighter_component/canopy/C = loadout.get_slot(HARDPOINT_SLOT_CANOPY)
	if(canopy_open || !C || (C.obj_integrity <= 0))
		. = loc.return_air()
	else
		. = cabin_air

/obj/structure/overmap/fighter/remove_air(amount)
	var/datum/gas_mixture/air
	. = air?.remove(amount)

/obj/structure/overmap/fighter/return_analyzable_air()
	return cabin_air

/obj/structure/overmap/fighter/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_temperature()
	return

/obj/structure/overmap/fighter/portableConnectorReturnAir()
	return return_air()

/obj/structure/overmap/fighter/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/t_air = return_air()
	return t_air.merge(giver)

/obj/structure/overmap/fighter/proc/toggle_canopy()
	canopy_open = !canopy_open
	playsound(src, 'nsv13/sound/effects/fighters/canopy.ogg', 100, 1)

/obj/structure/overmap/fighter/utility/prebuilt/carrier //This needs to be resolved properly later
