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

#define LOADOUT_DEFAULT_FIGHTER /datum/component/ship_loadout
#define LOADOUT_UTILITY_ONLY /datum/component/ship_loadout/utility

#define ENGINE_RPM_SPUN 8000

//Yeet the fighter
/obj/structure/overmap/fighter/proc/yeet()
	//flight_state = 6
	toggle_canopy()
	forceMove(get_turf(locate(255, y, z)))

/obj/structure/overmap/fighter
	name = "Space Fighter"
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
	max_integrity = 120 //Really really squishy!
	torpedoes = 0
	missiles = 0
	speed_limit = 7 //We want fighters to be way more maneuverable
	weapon_safety = FALSE //This happens wayy too much for my liking. Starts OFF.
	pixel_w = -16
	pixel_z = -20
	req_one_access = list(ACCESS_FIGHTER)
	collision_positions = list(new /datum/vector2d(-2,-16), new /datum/vector2d(-13,-3), new /datum/vector2d(-13,10), new /datum/vector2d(-6,15), new /datum/vector2d(8,15), new /datum/vector2d(15,10), new /datum/vector2d(12,-9), new /datum/vector2d(4,-16), new /datum/vector2d(1,-16))
	var/max_passengers = 0 //Change this per fighter.
	//Component to handle the fighter's loadout, weapons, parts, the works.
	var/loadout_type = LOADOUT_DEFAULT_FIGHTER
	var/datum/component/ship_loadout/loadout = null
	var/obj/structure/fighter_launcher/mag_lock = null //Mag locked by a launch pad. Cheaper to use than locate()
	var/obj/structure/last_overmap = null
	var/canopy_open = TRUE
	var/master_caution = FALSE //The big funny warning light on the dash.
	var/list/components = list() //What does this fighter start off with? Use this to set what engine tiers and whatever it gets.

/obj/structure/overmap/fighter/light
	name = "Su-818 Rapier"
	desc = "An Su-818 Rapier space superiorty fighter craft. Designed for high maneuvreability and maximum combat effectivness against other similar weight classes."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 30, "bomb" = 30, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 10, "overmap_heavy" = 5)
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 100 //Really really squishy!
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
	name = "Su-437 Sabre"
	desc = "A Su-437 Sabre utility vessel. Designed for robustness in deep space and as a highly modular platform, able to be fitted out for any situation. Drag and drop crates / ore boxes to load them into its cargo hold."
	icon = 'nsv13/icons/overmap/nanotrasen/carrier.dmi'
	icon_state = "carrier"
	armor = list("melee" = 70, "bullet" = 70, "laser" = 70, "energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 15, "overmap_heavy" = 0)
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 250 //Squishy!
	max_passengers = 1
	pixel_w = -16
	pixel_z = -20
	req_one_access = list(ACCESS_MUNITIONS, ACCESS_ENGINE)

	forward_maxthrust = 3
	backward_maxthrust = 3
	side_maxthrust = 3
	max_angular_acceleration = 110
//	ftl_goal = 45 SECONDS //Raptors can, by default, initiate relative FTL jumps to other ships.
	loadout_type = LOADOUT_UTILITY_ONLY
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

/obj/structure/overmap/fighter/escapepod
	name = "Escape Pod"
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
	name = "Su-410 Scimitar"
	desc = "An Su-410 Scimitar heavy attack craft. It's a lot beefier than its Rapier cousin and is designed to take out capital ships, due to the weight of its modules however, it is extremely slow."
	icon = 'nsv13/icons/overmap/nanotrasen/heavy_fighter.dmi'
	icon_state = "heavy_fighter"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 25, "overmap_heavy" = 10)
	sprite_size = 32
	damage_states = FALSE //TEMP
	max_integrity = 125 //Not so squishy!
	pixel_w = -16
	pixel_z = -20
	forward_maxthrust = 4
	backward_maxthrust = 4
	side_maxthrust = 4
	max_angular_acceleration = 110
	components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/tier2,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/secondary/ordnance_launcher/torpedo,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/cannon/heavy)

/obj/structure/overmap/fighter/LateInitialize(mapload, build_components=components)
	. = ..()
	loadout = AddComponent(loadout_type)
	dradis = new /obj/machinery/computer/ship/dradis/internal(src) //Fighters need a way to find their way home.
	dradis.linked = src
	obj_integrity = max_integrity
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/check_overmap_elegibility) //Used to smoothly transition from ship to overmap
	add_overlay(image(icon = icon, icon_state = "canopy_open", dir = SOUTH))
	var/obj/item/fighter_component/engine/engineGoesLast = null
	for(var/Ctype in build_components)
		var/obj/item/fighter_component/FC = new Ctype(get_turf(src))
		if(istype(FC, /obj/item/fighter_component/engine))
			engineGoesLast = FC
			continue
		loadout.install_hardpoint(FC.slot, FC)
	//Engines need to be the last thing that gets installed on init, or it'll cause bugs with drag.
	if(engineGoesLast)
		loadout.install_hardpoint(engineGoesLast.slot, engineGoesLast)
	set_fuel(rand(500, 1000))

/obj/structure/overmap/fighter/attackby(obj/item/W, mob/user, params)
	for(var/slot in loadout.equippable_slots)
		var/obj/item/fighter_component/FC = loadout.get_slot(slot)
		if(FC?.load(src, W))
			return FALSE
	if(istype(W, /obj/item/fighter_component))
		var/obj/item/fighter_component/FC = W
		loadout.install_hardpoint(FC.slot, FC)
		return FALSE
	..()

/obj/structure/overmap/fighter/MouseDrop_T(atom/movable/target, mob/user)
	. = ..()
	if(target != user)
		return
	for(var/slot in loadout.equippable_slots)
		var/obj/item/fighter_component/FC = loadout.get_slot(slot)
		if(FC?.load(src, target))
			return FALSE
	if(allowed(user) && isliving(user))
		if(!canopy_open)
			playsound(src, 'sound/effects/glasshit.ogg', 75, 1)
			user.visible_message("<span class='warning'>You bang on the canopy.</span>", "<span class='warning'>[user] bangs on [src]'s canopy.</span>")
			return FALSE
		if(pilot ? --operators.len : operators.len >= max_passengers)
			to_chat(user, "<span class='warning'>[src]'s passenger compartment is full!")
			return FALSE
		if(do_after(user, 2 SECONDS, target=src))
			start_piloting(user, "observer")
			enter(user)

/obj/structure/overmap/fighter/proc/enter(mob/user)
	user.forceMove(src)
	mobs_in_ship += user
	if(user?.client?.prefs.toggles & SOUND_AMBIENCE && engines_active()) //Disable ambient sounds to shut up the noises.
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
			to_chat(user, "<span class='notice'>You climb into [src]'s cockpit as a pilot.</span>")
			ui_interact(user)
			return TRUE

/obj/structure/overmap/fighter/proc/force_eject()
	brakes = TRUE
	if(!canopy_open)
		canopy_open = TRUE
		playsound(src, 'nsv13/sound/effects/fighters/canopy.ogg', 100, 1)
	for(var/mob/M in operators)
		stop_piloting(M)
		to_chat(M, "<span class='warning'>You have been remotely ejected from [src]!.</span>")

/obj/structure/overmap/fighter/attackby(obj/item/W, mob/user, params)   //fueling and changing equipment
	add_fingerprint(user)
	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda) && operators.len)
		if(!allowed(user))
			var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
			playsound(src, sound, 100, 1)
			to_chat(user, "<span class='warning'>Access denied</span>")
			return
		if(alert("Eject all current occupants from [src]?",name,"Yes","No") == "Yes" && Adjacent(user))
			to_chat(user, "<span class='warning'>Ejecting all current occupants from [src] and activating inertial dampeners...</span>")
			force_eject()
	..()

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
#define HARDPOINT_SLOT_UTILITY_PRIMARY "Primary Utility"
#define HARDPOINT_SLOT_UTILITY_SECONDARY "Secondary Utility"

#define ALL_HARDPOINT_SLOTS list(HARDPOINT_SLOT_PRIMARY, HARDPOINT_SLOT_SECONDARY,HARDPOINT_SLOT_UTILITY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR, HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY)
#define HARDPOINT_SLOTS_STANDARD list(HARDPOINT_SLOT_PRIMARY, HARDPOINT_SLOT_SECONDARY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR,HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY)
#define HARDPOINT_SLOTS_UTILITY list(HARDPOINT_SLOT_UTILITY_PRIMARY,HARDPOINT_SLOT_UTILITY_SECONDARY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR,HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY)

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

/datum/component/ship_loadout/proc/install_hardpoint(slot, obj/item/fighter_component/replacement)
	if(slot && !(slot in equippable_slots))
		replacement.visible_message("<span class='warning'>[replacement] can't fit onto [parent]")
		return FALSE
	var/obj/item/fighter_component/component = get_slot(slot)
	if(component && istype(component))
		component.remove_from(holder)
	if(slot) //Not every component has a slot per se, as some are just used for construction and can't really be interacted with.
		hardpoint_slots[slot] = replacement
	replacement.on_install(holder)

/datum/component/ship_loadout/proc/remove_hardpoint(slot)
	if(!slot)
		return FALSE
	var/obj/item/fighter_component/component = get_slot(slot)
	if(component && istype(component))
		component.remove_from(holder)
	hardpoint_slots[slot] = null

/datum/component/ship_loadout/process()
	for(var/slot in equippable_slots)
		var/obj/item/fighter_component/component = hardpoint_slots[slot]
		component?.process()

/obj/item/fighter_component
	name = "Fighter Component"
	desc = "It doesn't really do a whole lot"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	//Thanks to comxy on Discord for these lovely tiered sprites o7
	var/tier = 1 //Icon states are formatted as: armour_tier1 and so on.
	var/slot = null //Change me!
	var/weight = 0 //Some more advanced modules will weigh your fighter down some.
	var/power_usage = 0 //Does this module require power to process()?

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

/obj/item/fighter_component/proc/powered()
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F))
		return FALSE
	var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	return B?.use_power(power_usage)

/obj/item/fighter_component/process()
	if(!powered())
		return FALSE
	return TRUE

/*
If you need your hardpoint to be loaded with things by clicking the fighter
*/
/obj/item/fighter_component/proc/load(obj/structure/overmap/target, atom/movable/AM)
	return FALSE

/obj/item/fighter_component/proc/apply_drag(obj/structure/overmap/target)
	if(!weight)
		return FALSE
	target.speed_limit -= weight
	target.speed_limit = CLAMP(target.speed_limit, 0, target.speed_limit)
	target.forward_maxthrust -= weight
	target.forward_maxthrust = CLAMP(target.forward_maxthrust, 0, target.forward_maxthrust)
	target.backward_maxthrust -= weight
	target.backward_maxthrust = CLAMP(target.backward_maxthrust, 0, target.backward_maxthrust)
	target.side_maxthrust -= 0.25*weight
	target.side_maxthrust = CLAMP(target.side_maxthrust, 0, target.side_maxthrust)
	target.max_angular_acceleration -= weight*10
	target.max_angular_acceleration = CLAMP(target.max_angular_acceleration, 0, target.max_angular_acceleration)

/obj/item/fighter_component/proc/remove_from(obj/structure/overmap/target)
	forceMove(get_turf(target))
	if(!weight)
		return TRUE
	target.speed_limit += weight
	target.forward_maxthrust += weight
	target.side_maxthrust += 0.25*weight
	target.max_angular_acceleration += weight*10
	return TRUE

/obj/item/fighter_component/armour_plating
	name = "Durasteel Armour Plates"
	desc = "A set of armour plates which can afford basic protection to a fighter, however heavier plates may slow you down"
	icon_state = "armour"
	slot = HARDPOINT_SLOT_ARMOUR

/obj/item/fighter_component/armour_plating/tier2
	name = "Ultra Heavy Fighter Armour"
	desc = "An extremely thick and heavy set of armour plates. Guaranteed to weigh you down, but it'll keep you flying through brasil itself."
	tier = 2
	weight = 2

/obj/item/fighter_component/armour_plating/tier3
	name = "Nanocarbon Armour Plates"
	desc = "A lightweight set of ablative armour which balances speed and protection at the cost of the average GDP of most third world countries."
	tier = 3
	weight = 1.5

/obj/item/fighter_component/canopy
	name = "Steel-reinforced glass canopy"
	desc = "The canopy of a fighter, it can withstand a lot of bullets."
	icon_state = "canopy"
	obj_integrity = 100 //Pretty fragile, don't break it you dumblet
	max_integrity = 100
	slot = HARDPOINT_SLOT_CANOPY
	weight = 0.5 //Real pilots just wear pilot goggles and strip out their canopy.

/obj/item/fighter_component/canopy/tier2
	name = "Nanocarbon glass canopy"
	obj_integrity = 150
	max_integrity = 150
	tier = 2
	weight = 0.35

/obj/item/fighter_component/canopy/tier3
	name = "Plasma glass canopy"
	obj_integrity = 250
	max_integrity = 250
	tier = 3
	weight = 0.15

/obj/item/fighter_component/battery
	name = "Fighter Battery"
	icon_state = "battery"
	slot = HARDPOINT_SLOT_BATTERY
	var/charge = 10000
	var/max_charge = 10000
	var/self_charge = TRUE //TODO! Engine powers this.

/obj/item/fighter_component/battery/process()
	if(self_charge)
		charge += 1000

/obj/item/fighter_component/battery/proc/use_power(amount)
	charge -= amount
	charge = CLAMP(charge, 0, max_charge)
	return charge > 0

/obj/item/fighter_component/battery/tier2
	name = "Upgraded Fighter Battery"
	tier = 2
	charge = 20000
	max_charge = 20000

/obj/item/fighter_component/battery/tier3
	name = "Mega Fighter Battery"
	desc = "An electrochemical cell capable of holding a good amount of charge for keeping the fighter's radio on for longer periods without an engine."
	tier = 3
	charge = 40000
	max_charge = 40000

/obj/item/fighter_component/armour_plating/on_install(obj/structure/overmap/target)
	..()
	target.max_integrity = initial(target.max_integrity)*tier

/obj/item/fighter_component/armour_plating/remove_from(obj/structure/overmap/target)
	..()
	target.max_integrity = initial(target.max_integrity)

//Fuel
/obj/structure/overmap/fighter/proc/get_fuel()
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	. = 0
	for(var/datum/reagent/aviation_fuel/F in ft?.reagents.reagent_list)
		if(!istype(F))
			continue
		. += F.volume
	return .

/obj/structure/overmap/fighter/proc/set_fuel(amount)
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return FALSE
	ft.reagents.add_reagent(/datum/reagent/aviation_fuel, 1) //Assert that we have this reagent in the tank.
	for(var/datum/reagent/aviation_fuel/F in ft?.reagents.reagent_list)
		if(!istype(F))
			continue
		F.volume = amount
	return amount

/obj/structure/overmap/fighter/proc/engines_active()
	var/obj/item/fighter_component/engine/E = loadout.get_slot(HARDPOINT_SLOT_ENGINE)//E's are good E's are good, he's ebeneezer goode.
	return (E?.active() && get_fuel() > 0)

/obj/structure/overmap/fighter/proc/set_master_caution(state)
	var/master_caution_switch = state
	if(master_caution_switch)
		relay('nsv13/sound/effects/fighters/master_caution.ogg', null, loop=TRUE, channel=CHANNEL_HEARTBEAT)
		master_caution = TRUE
	else
		stop_relay(CHANNEL_HEARTBEAT) //CONSIDER MAKING OWN CHANNEL
		master_caution = FALSE

/obj/structure/overmap/fighter/proc/use_fuel()
	if(!engines_active()) //No fuel? don't spam them with master cautions / use any fuel
		return FALSE
	var/fuel_consumption = loadout.get_slot(HARDPOINT_SLOT_ENGINE)?.tier
	var/amount = (user_thrust_dir) ? fuel_consumption+0.25 : fuel_consumption //When you're thrusting : fuel consumption doubles. Idling is cheap.
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return FALSE
	ft.reagents.remove_reagent(/datum/reagent/aviation_fuel, amount)
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
	name = "Fighter Fuel Tank"
	desc = "The fuel tank of a fighter, upgrading this lets your fighter hold more fuel."
	icon_state = "fueltank"
	var/fuel_capacity = 1000
	slot = HARDPOINT_SLOT_FUEL

/obj/item/fighter_component/fuel_tank/Initialize()
	.=..()
	create_reagents(fuel_capacity, DRAINABLE | AMOUNT_VISIBLE)

/obj/item/fighter_component/fuel_tank/tier2
	name = "Fighter Extended Fuel Tank"
	desc = "A larger fuel tank which allows fighters to stay in combat for much longer"
	fuel_capacity = 2500
	tier = 2

/obj/item/fighter_component/fuel_tank/tier3
	name = "Massive Fighter Fuel Tank"
	desc = "A super extended capacity fuel tank, allowing fighters to stay in a warzone for hours on end."
	fuel_capacity = 4000
	tier = 3

/obj/item/fighter_component/engine
	name = "Fighter engine"
	desc = "A mighty engine capable of propelling small spacecraft to high speeds."
	icon_state = "engine"
	slot = HARDPOINT_SLOT_ENGINE
	var/rpm = ENGINE_RPM_SPUN //Todo: Fighter startup

/obj/item/fighter_component/engine/proc/active()
	return (obj_integrity > 0 && rpm >= ENGINE_RPM_SPUN)

/obj/item/fighter_component/engine/tier2
	name = "Souped up fighter engine"
	desc = "Born to zoom, forced to oom"
	tier = 2

/obj/item/fighter_component/engine/tier3
	name = "Boringheed Marty V12 Super Giga Turbofan Space Engine"
	desc = "An engine which allows a fighter to exceed the legal speed limit in most jurisdictions."
	tier = 3

/obj/item/fighter_component/engine/on_install(obj/structure/overmap/fighter/target)
	..()
	target.speed_limit = initial(target.speed_limit)*tier
	target.forward_maxthrust = initial(target.forward_maxthrust)*tier
	target.backward_maxthrust = initial(target.backward_maxthrust)*tier
	target.side_maxthrust = initial(target.side_maxthrust)*tier
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

//Atmos

/obj/item/fighter_component/oxygenator
	name = "Atmospheric Regulator"
	desc = "A device which moderates the conditions inside a fighter, it requires fuel to run."
	icon_state = "oxygenator"
	var/refill_amount = 1 //Starts off really terrible.
	slot = HARDPOINT_SLOT_OXYGENATOR
	weight = 0.5 //Wanna go REALLY FAST? Pack your own O2.
	power_usage = 200

/obj/item/fighter_component/oxygenator/t2
	name = "Upgraded Atmospheric Regulator"
	tier = 2
	refill_amount = 3
	power_usage = 300

/obj/item/fighter_component/oxygenator/t3
	name = "Super Oxygenator"
	desc = "A finely tuned atmospheric regulator to be fitted into a fighter which seems to be able to almost magically create oxygen out of nowhere."
	tier = 3
	refill_amount = 10
	power_usage = 400

/obj/item/fighter_component/oxygenator/plasmaman
	name = "Plasmaman Atmospheric Regulator"
	desc = "An atmospheric regulator to be used in fighters, it's been rigged to fill the cabin with a hospitable environment for plasmamen instead of standard oxygen."
	refill_amount = 3
	tier = 4 //unique! but it has to have a sprite to make it obvious that, yknow, this is for plasmemes.

/obj/item/fighter_component/oxygenator/process()
	//Don't waste power on already fine atmos.
	var/obj/structure/overmap/OM = loc
	if(!istype(OM))
		return FALSE
	if(OM.cabin_air.return_pressure()+refill_amount >= WARNING_HIGH_PRESSURE-(2*refill_amount))
		return FALSE //No need to add more air to an already pressurized environment
	if(!..())
		return FALSE

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
	name = "Fighter Avionics"
	desc = "Avionics for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "avionics"

/obj/item/fighter_component/apu
	name = "Fighter Auxiliary Power Unit"
	desc = "An Auxiliary Power Unit for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "apu"

/obj/item/fighter_component/countermeasure_dispenser
	name = "Fighter Countermeasure Dispenser"
	desc = "A device which allows a fighter to deploy countermeasures."
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "countermeasure"

/obj/item/fighter_component/docking_computer
	name = "Docking Computer"
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
	name = "Fuck you"
	slot = HARDPOINT_SLOT_PRIMARY
	var/fire_mode = FIRE_MODE_PDC
	var/overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	var/overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	var/accepted_ammo = /obj/item/ammo_box/magazine
	var/obj/item/ammo_box/magazine/magazine = null
	var/list/ammo = list()
	var/burst_size = 1
	var/fire_delay = 0

//Ensure we get the genericised equipment mounts.
/obj/structure/overmap/fighter/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new/datum/ship_weapon/fighter_primary(src)
	weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/fighter_secondary(src)

/obj/structure/overmap/proc/primary_fire(obj/structure/overmap/target)
	if(istype(src, /obj/structure/overmap/fighter))
		var/obj/structure/overmap/fighter/F = src
		var/obj/item/fighter_component/primary/P = F.loadout.get_slot(HARDPOINT_SLOT_PRIMARY)
		if(P)
			for(var/I = 0; I < weapon_types[P.fire_mode].burst_size; I++)
				P.fire(target)
			return TRUE
	return FALSE

/obj/structure/overmap/proc/secondary_fire(obj/structure/overmap/target)
	if(istype(src, /obj/structure/overmap/fighter))
		var/obj/structure/overmap/fighter/F = src
		var/obj/item/fighter_component/secondary/S = F.loadout.get_slot(HARDPOINT_SLOT_SECONDARY)
		if(S)
			for(var/I = 0; I < weapon_types[S.fire_mode].burst_size; I++)
				S.fire(target)
			return TRUE
	return FALSE

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

/obj/item/fighter_component/primary/proc/fire(obj/structure/overmap/target)
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

/obj/item/fighter_component/primary/cannon
	name = "40mm Vulcan Cannon"
	icon_state = "lightcannon"
	accepted_ammo = /obj/item/ammo_box/magazine/light_cannon
	burst_size = 2
	fire_delay = 0.25 SECONDS

/obj/item/fighter_component/primary/cannon/heavy
	name = "40mm Vulcan Cannon"
	icon_state = "heavycannon"
	accepted_ammo = /obj/item/ammo_box/magazine/heavy_cannon
	weight = 2 //Sloooow down there.
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/BRRTTTTTT.ogg')
	burst_size = 3
	fire_delay = 0.5 SECONDS

/obj/item/fighter_component/secondary
	name = "Fuck you"
	slot = HARDPOINT_SLOT_SECONDARY
	var/fire_mode = FIRE_MODE_TORPEDO
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

/obj/item/fighter_component/secondary/on_install(obj/structure/overmap/target)
	. = ..()
	if(!fire_mode)
		return FALSE
	var/datum/ship_weapon/SW = target.weapon_types[fire_mode]
	SW.overmap_firing_sounds = overmap_firing_sounds
	SW.overmap_select_sound = overmap_select_sound
	SW.burst_size = burst_size
	SW.fire_delay = fire_delay

//Todo: make fighters use these.
/obj/item/fighter_component/secondary/ordnance_launcher
	name = "Fighter Missile Rack"
	desc = "A huge fighter missile rack capable of deploying missile based weaponry."
	icon_state = "missilerack"

/obj/item/fighter_component/secondary/ordnance_launcher/tier2
	name = "Upgraded Fighter Missile Rack"
	tier = 2
	max_ammo = 5

/obj/item/fighter_component/secondary/ordnance_launcher/tier3
	name = "A-11 'Spacehog' Cluster-Freedom Launcher"
	tier = 3
	max_ammo = 15
	weight = 1
	burst_size = 3
	fire_delay = 0.10 SECONDS

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo
	name = "Fighter Torpedo Launcher"
	desc = "A heavy torpedo rack which allows fighters to fire torpedoes at targets"
	icon_state = "torpedorack"
	accepted_ammo = /obj/item/ship_weapon/ammunition/torpedo
	max_ammo = 2
	weight = 1

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier2
	name = "Enhanced Torpedo Launcher"
	tier = 2
	max_ammo = 4

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier3
	name = "FR33-8IRD Torpedo Launcher"
	desc = "A massive torpedo launcher capable of deploying enough ordnance to level several small, oil-rich nations."
	tier = 3
	max_ammo = 10
	weight = 2

/obj/item/fighter_component/secondary/ordnance_launcher/load(obj/structure/overmap/target, atom/movable/AM)
	if(!istype(AM, accepted_ammo))
		return FALSE
	if(ammo.len >= max_ammo)
		return FALSE
	AM.forceMove(src)
	ammo += AM
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/secondary/proc/fire(obj/structure/overmap/target)
	return FALSE //Implement me!

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
			F.fire_projectile(proj_type, target, homing = FALSE, speed=proj_speed, explosive = TRUE)
		else
			F.fire_projectile(proj_type, target, homing = TRUE, speed=proj_speed, explosive = TRUE)
	return TRUE

//Utility modules.

/obj/item/fighter_component/primary/utility/fire(obj/structure/overmap/target)
	return FALSE

/obj/item/fighter_component/primary/utility/hold
	name = "Cargo Hold"
	desc = "A cramped cargo hold for hauling light freight."
	slot = HARDPOINT_SLOT_UTILITY_PRIMARY
	icon_state = "hold"
	var/max_w_class = WEIGHT_CLASS_GIGANTIC
	var/max_freight = 5

/obj/item/fighter_component/primary/utility/hold/tier2
	name = "Expanded Cargo Hold"
	tier = 2
	max_freight = 10

/obj/item/fighter_component/primary/utility/hold/tier3
	name = "S0CC3RMUM Jumbo Sized Cargo Hold"
	desc ="Now with extra space for seating unlucky friends in the boot!"
	tier = 3
	max_freight = 20

/obj/item/fighter_component/primary/utility/hold/load(obj/structure/overmap/target, atom/movable/AM)
	if(contents && contents.len >= max_freight)
		return FALSE
	AM.forceMove(src)
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/secondary/utility
	name = "Utility Module"
	slot = HARDPOINT_SLOT_UTILITY_SECONDARY
	power_usage = 200

/obj/item/fighter_component/secondary/utility/resupply
	name = "Air to Air Resupply Kit"
	desc = "A large hose line which can allow a utility craft to perform air to air refuelling and resupply, without needing to RTB!"
	icon_state = "resupply"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/fighters/refuel.ogg')
	fire_delay = 9 SECONDS
	var/datum/beam/current_beam
	var/next_fuel = 0

/obj/item/fighter_component/secondary/utility/resupply/tier2
	name = "Upgraded Air To Air Resupply Kit"
	fire_delay = 7 SECONDS
	tier = 2

/obj/item/fighter_component/secondary/utility/resupply/tier2
	name = "Super Air To Air Resupply Kit"
	fire_delay = 6 SECONDS
	tier = 3

/obj/item/fighter_component/secondary/utility/resupply/process()
	if(!..())
		return
	var/obj/structure/overmap/fighter/F = loc
	if(!istype(F) || !F.autofire_target)
		qdel(current_beam)
		current_beam = null
		return FALSE
	if(world.time < next_fuel)
		return FALSE
	var/obj/structure/overmap/fighter/them = F.autofire_target
	if(!istype(them))
		return FALSE
	next_fuel = world.time + fire_delay
	if(!current_beam || QDELETED(current_beam))
		current_beam = new(F,them,beam_icon='nsv13/icons/effects/beam.dmi',time=INFINITY,maxdistance = INFINITY,beam_icon_state="hose",btype=/obj/effect/ebeam/fuel_hose)
		INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)

	//Firstly, try to refuel the friendly.
	var/obj/item/fighter_component/fuel_tank/fuel = F.loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!fuel || F.get_fuel() <= 0)
		say("nah no fuel!")
		goto resupplyFuel
	var/obj/item/fighter_component/fuel_tank/theirFuel = them.loadout.get_slot(HARDPOINT_SLOT_FUEL)
	var/transfer_amount = min(50, them.get_max_fuel()-them.get_fuel()) //Transfer as much as we can
	F.relay('nsv13/sound/effects/fighters/refuel.ogg')
	them.relay('nsv13/sound/effects/fighters/refuel.ogg')
	if(transfer_amount <= 0)
		say("nah no supply!")
		goto resupplyFuel
	fuel.reagents.trans_to(theirFuel, transfer_amount)
	say("Fuelled")
	resupplyFuel:
	say("Time 2 resupp")
	var/obj/item/fighter_component/primary/utility/hold = F.loadout.get_slot(HARDPOINT_SLOT_UTILITY_PRIMARY)
	if(!istype(hold))
		say("No hold")
		return FALSE
	var/obj/item/fighter_component/primary/theirGun = them.loadout.get_slot(HARDPOINT_SLOT_PRIMARY)
	var/obj/item/fighter_component/primary/theirTorp = them.loadout.get_slot(HARDPOINT_SLOT_SECONDARY)
	//Next up, try to refill the friendly's guns from whatever we have stored in cargo.
	for(var/atom/movable/AM in hold.contents)
		say("Found [AM] and")
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
	if(C.obj_integrity <= 0)
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
	if(!C || (C.obj_integrity <= 0)) //Leak air if the canopy is breached.
		var/datum/gas_mixture/removed = cabin_air.remove(5)
		qdel(removed)
		say("Leak")
	update_icon()

/obj/structure/overmap/fighter/return_air()
	if(canopy_open)
		return loc.return_air()
	return cabin_air

/obj/structure/overmap/fighter/remove_air(amount)
	return cabin_air?.remove(amount)

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

