/obj/machinery/ship_weapon/plasma_caster
	name = "\improper Magnetic Phoron 'Vintergatan' Acceleration Caster"
	icon = 'nsv13/icons/obj/plasma_gun.dmi' //Temp Sprite
	icon_state = "plasma_gun" //Temp Sprite
	desc = "Retrieve the lamp, Torch, for the Dominion, and the Light!"
	anchored = TRUE
	max_integrity = 1200 //Try to give it a chance to survive a plasmaflood

	density = TRUE
	safety = TRUE

	bound_width = 128
	bound_height = 64
	ammo_type = /obj/item/ship_weapon/ammunition/plasma_core
	circuit = /obj/item/circuitboard/machine/plasma_caster

	fire_mode = FIRE_MODE_PHORON

	auto_load = FALSE
	semi_auto = FALSE
	maintainable = TRUE
	max_ammo = 1
	feeding_sound = 'nsv13/sound/effects/ship/freespace2/m_load.wav' //TEMP, CHANGE LATER
	fed_sound = null //TEMP, CHANGE LATER
	chamber_sound = null //TEMP, CHANGE LATER

	load_delay = 20
	unload_delay = 20
	fire_animation_length = 1 SECONDS //Maybe? We'll see how I feel about a long firing animations.

	feed_delay = 0
	chamber_delay_rapid = 0
	chamber_delay = 0
	bang = FALSE

	var/obj/machinery/atmospherics/components/unary/plasma_loader/loader
	var/plasma_fire_moles = 250 //TEMPORARY PROBABLY
	var/plasma_mole_amount = 0 //How much plasma gas is in the gun
	var/alignment = 100 //Stealing this from hybrid railguns
	var/field_integrity = 100 //Degrades over time when safety's off, don't let it reach zero
	var/next_warning = 0 //Helps keep warning spam away
	processing_flags = START_PROCESSING_ON_INIT

/obj/machinery/ship_weapon/plasma_caster/toggle_safety()
	. = ..()
	if(!safety)
		begin_processing()
	else if(field_integrity == 100)
		end_processing()

/obj/machinery/ship_weapon/plasma_caster/process(delta_time)
	if(!safety)
		field_integrity = max(field_integrity - delta_time, 0)
	else
		field_integrity = min(field_integrity + delta_time, 100)
	switch(field_integrity)
		if(100)
			if(next_warning == 1)
				next_warning --
				say("Local phoron containment field fully stabilized.")
		if(76 to 99)
			if(next_warning == 0)
				next_warning ++
				say("Localized phoron containment field disengaged, preparing to fire.")
			else if(next_warning == 2)
				next_warning --
				say("Phoron containment field stabilized to ideal levels.")
		if(51 to 75)
			if(next_warning == 1)
				next_warning ++
				say("Phoron containment field at 75%, stability decreasing.")
			else if(next_warning == 3)
				say("Integrity at 50%, continuing stabilization process...")
				next_warning --
		if(26 to 50)
			if(next_warning == 2)
				next_warning ++
				say("WARNING! Containment field 50% and falling.")
			else if(next_warning == 4)
				next_warning --
				say("Restored field integrity above critical levels.")
		if(1 to 25)
			if(next_warning == 3)
				next_warning ++
				say("WARNING! 25% Integrity! Containment Failure Imminent!")
		if(0)
			misfire()
			safety = TRUE
			field_integrity = 100
			next_warning = 0
			return PROCESS_KILL

/obj/machinery/ship_weapon/plasma_caster/Initialize(mapload)
	. = ..()
	loader = locate(/obj/machinery/atmospherics/components/unary/plasma_loader) in orange(1, src)
	loader.linked_gun = src

/obj/machinery/ship_weapon/plasma_caster/can_fire(shots = weapon_type.burst_size)
	if((state < STATE_CHAMBERED) || !chambered)
		return FALSE
	if(state >= STATE_FIRING)
		return FALSE
	if(maintainable && malfunction) //Do we need maintenance?
		return FALSE
	if(plasma_mole_amount < plasma_fire_moles) //Is there enough Plasma Gas to fire?
		say("DANGER! Not enough phoron to safely dischard core! Please ensure enough gas is present before firing!")
		return FALSE
	if(loader.on)
		say("DANGER! Phoron Gas Regulator back pressure surge avoided! Ensure the regulator is off before operating!")
		return FALSE
	if(alignment < 90)
		if(prob(10))
			misfire()
		return FALSE
	if(alignment < 75)
		if(prob(25))
			misfire()
		return FALSE
	if(alignment < 50)
		if(prob(50))
			misfire()
		return FALSE
	if(alignment < 25)
		misfire()
		return FALSE
	else
		return TRUE

/obj/machinery/ship_weapon/plasma_caster/animate_projectile(atom/target)
	return linked.fire_projectile(weapon_type.default_projectile_type, target, homing = TRUE, speed = 2, lateral=weapon_type.lateral)

/obj/machinery/ship_weapon/plasma_caster/proc/misfire()
	say("WARNING! Phoron containment field failure, ejecting gas!")
	if(prob(25))
		do_sparks(4, FALSE, src)
	if(prob(10))
		makedarkpurpleslime()
	atmos_spawn_air("plasma=[plasma_mole_amount];TEMP=293")
	alignment -= rand(1,30)
	field_integrity -= rand(20,50)
	plasma_mole_amount = 0

/obj/machinery/ship_weapon/plasma_caster/after_fire()
	alignment -= rand(5,60)
	plasma_mole_amount -= 250
	field_integrity -= 20
	..()

/obj/machinery/ship_weapon/plasma_caster/default_deconstruction_crowbar(obj/item/I, ignore_panel)
	if(plasma_mole_amount > 0)
		misfire()

	var/mob/living/Jim = usr
	to_chat(usr, "<span class='danger'>Burning Plasma starts to vent from the gun which chars your body!</span>")
	Jim.adjustFireLoss(rand(300, 1000)) // OwO no Deconning ever
	return

/obj/machinery/ship_weapon/plasma_caster/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(maint_state == 0)
		to_chat(user, "<span class='notice'>You must first open the maintenance panel before unwrenching the protective casing!</span>")
	if(maint_state == 1)
		to_chat(user, "<span class='notice'>You must unbolt the protective casing before tuning the magnetic frequency!</span>")
	else
		to_chat(user, "<span class='notice'>You being tuning the magnetic frequency.</span>")
		while(alignment < 100)
			if(!do_after(user, 5, target = src))
				return
			alignment += rand(1,2)
			if(alignment >= 100)
				alignment = 100
				break

/**
 * Unload magazine or just-loaded rounds.
 */
/obj/machinery/ship_weapon/plasma_caster/attack_hand(mob/user)
	ui_interact(user)
	return

/obj/machinery/ship_weapon/plasma_caster/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlasmaGun")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/ship_weapon/plasma_caster/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["field_integrity"] = field_integrity
	data["alignment"] = alignment
	data["plasma_moles"] = plasma_mole_amount
	data["plasma_moles_max"] = plasma_fire_moles
	data["safety"] = safety
	data["loaded"] = (state > STATE_LOADED) ? TRUE : FALSE
	data["chambered"] = (state > STATE_FED) ? TRUE : FALSE
	data["ammo"] = ammo?.len || 0
	data["max_ammo"] = max_ammo
	return data

/obj/machinery/ship_weapon/plasma_caster/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle_load")
			if(state == STATE_LOADED)
				feed()
			else
				unload()
		if("chamber")
			chamber()
		if("toggle_safety")
			toggle_safety()
	return

/obj/machinery/atmospherics/components/unary/plasma_loader
	name = "phoron gas regulator"
	desc = "The gas regulator that pumps gaseous phoron into the Plasma Caster"
	icon = 'nsv13/icons/obj/machinery/reactor_parts.dmi' //Temp Sprite
	icon_state = "constrictor" //Temp Sprite
	pixel_y = 5 //So it lines up with layer 3 piping
	layer = OBJ_LAYER
	density = FALSE //Change to True when done testing
	dir = WEST
	initialize_directions = WEST
	pipe_flags = PIPING_ONE_PER_TURF
	active_power_usage = 200
	var/obj/machinery/ship_weapon/plasma_caster/linked_gun
	var/naughty = FALSE
	var/heretical_gases = list(
		GAS_CO2,
		GAS_BZ,
		GAS_O2,
		GAS_N2,
		GAS_H2O,
		GAS_HYPERNOB,
		GAS_NITROUS,
		GAS_TRITIUM,
		GAS_NITRYL,
		GAS_STIMULUM,
		GAS_PLUOXIUM,
		GAS_CONSTRICTED_PLASMA,
		GAS_NUCLEIUM,
	)

/obj/machinery/atmospherics/components/unary/plasma_loader/on_construction()
	var/obj/item/circuitboard/machine/thermomachine/board = circuit
	if(board)
		piping_layer = board.pipe_layer
	..(dir, piping_layer)

/obj/machinery/atmospherics/components/unary/plasma_loader/attack_hand(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, "<span class='notice'>You must turn close the panel on [src] before turning it on.</span>")
		return
	to_chat(user, "<span class='notice'>You press [src]'s power button.</span>")
	on = !on
	update_icon()

//TEMPORARY
/obj/machinery/atmospherics/components/unary/plasma_loader/update_icon()
	cut_overlays()
	if(panel_open)
		icon_state = "constrictor_screw"
	else if(on)
		icon_state = "constrictor_active"
	else
		icon_state = "constrictor"

/obj/machinery/atmospherics/components/unary/plasma_loader/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS )

/obj/machinery/atmospherics/components/unary/plasma_loader/process_atmos()
	..()
	if(!on)
		return
	if(!linked_gun)
		return

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/environment = loc.return_air()

	if(air1.get_moles(GAS_PLASMA) > 5 && linked_gun.plasma_mole_amount < linked_gun.plasma_fire_moles)
		air1.adjust_moles(GAS_PLASMA, -5)
		linked_gun.plasma_mole_amount += 5
	for(var/gas in heretical_gases)
		if(air1.get_moles(gas))
			var/air1_pressure = air1.return_pressure()

			var/transfer_moles = air1_pressure*environment.return_volume()/(air1.return_temperature() * R_IDEAL_GAS_EQUATION)
			loc.assume_air_moles(air1, transfer_moles)
			air_update_turf(1)

			//WORKS FOR ME
			//WHY IS THIS HERE
			naughty = TRUE //Someone tried to do something naughty~

	if(naughty)
		say("Non-Phoron gas detected! Venting gas!") //BURN THEM ALL
		on = !on
		update_icon()
		naughty = FALSE
	update_parents()

/obj/item/circuitboard/machine/plasma_loader
	name = "Phoron Gas Regulator (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/plasma_loader
	var/pipe_layer = PIPING_LAYER_DEFAULT
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1)


/obj/item/circuitboard/machine/plasma_caster
	name = "circuit board (plasma caster)"
	desc = "My faithful...stand firm!"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 50,
		/obj/item/stack/sheet/iron = 100,
		/obj/item/stack/sheet/mineral/uranium = 20,
		/obj/item/stock_parts/manipulator = 10,
		/obj/item/stock_parts/capacitor = 10,
		/obj/item/stock_parts/matter_bin = 10,
		/obj/item/assembly/igniter = 1,
		/obj/item/ship_weapon/parts/firing_electronics = 1
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	build_path = /obj/machinery/ship_weapon/plasma_caster

/datum/ship_weapon/plasma_caster
	name = "MPAC"
	burst_size = 1
	fire_delay = 1 SECONDS //Change to 180 SECONDS when done testing
	range = 25000 //Make this last for an obscene amount of time
	default_projectile_type = /obj/item/projectile/bullet/plasma_caster
	select_alert = "<span class='notice'>Charging magnetic accelerator...</span>"
	failure_alert = "<span class='warning'>Magnetic Accelerator not ready!</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/broadside.ogg') //Make custom sound, thgwop
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_load_unjam.ogg' //Make custom sound, charging maybe?
	weapon_class = WEAPON_CLASS_HEAVY
	ai_fire_delay = 180 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_GUNNER
	lateral = FALSE

/obj/item/ship_weapon/ammunition/plasma_core
	name = "\improper Condensed Phoron Core"
	desc = "A heavy, condensed ball of plasma coated in a thick shell to prevent accidents."
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "plasma_core"
	projectile_type = /obj/item/projectile/bullet/plasma_caster

/datum/design/plasma_core
	name = "Condensed Phoron Core"
	desc = "Allows you to synthesize condensed phoron cores for the MPAC"
	id = "plasma_core"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma=40000, /datum/material/iron=10000)
	build_path = /obj/item/ship_weapon/ammunition/plasma_core
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/obj/item/projectile/bullet/plasma_caster
	name = "plasma ball"
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "plasma_ball" //Really bad test sprite, animate and globulate later
	homing = TRUE
	range = 25000 //Maybe this will make it go far
	homing_turn_speed = 180
	damage = 150
	obj_integrity = 500
	flag = "overmap_heavy"
	speed = 8
	projectile_piercing = ALL

/obj/item/projectile/bullet/plasma_caster/process_hit(turf/T, atom/target, atom/bumped, hit_something)
	. = ..()
	impacted[target] = FALSE

/obj/item/projectile/bullet/plasma_caster/fire()
	. = ..()
	if(!homing_target)
		find_target()
		return
	RegisterSignal(homing_target, COMSIG_PARENT_QDELETING, .proc/find_target)

/obj/item/projectile/bullet/plasma_caster/proc/find_target()
	SIGNAL_HANDLER
	if(homing_target)
		UnregisterSignal(homing_target, COMSIG_PARENT_QDELETING)
	if(!overmap_firer)
		return
	var/obj/structure/overmap/target_lock
	var/target_distance
	var/datum/star_system/target_system = SSstar_system.find_system(overmap_firer)
	var/list/targets = target_system.system_contents
	for(var/obj/structure/overmap/ship in targets)
		if(QDELETED(ship))
			continue
		if(overmap_firer.warcrime_blacklist[ship.type])
			continue
		if(ship.faction == faction)
			continue
		if(ship.essential)
			continue
		if(ship.z != z)
			continue
		var/new_target_distance = overmap_dist(src, ship)
		if(target_distance && new_target_distance > target_distance)
			continue
		target_lock = ship
		target_distance = new_target_distance
	if(!target_lock)
		return
	set_homing_target(target_lock)
	RegisterSignal(homing_target, COMSIG_PARENT_QDELETING, .proc/find_target)

//For FIRE proc, make animation play FIRST, prob with sleep proc

/obj/machinery/ship_weapon/plasma_caster/proc/makedarkpurpleslime()
	if(plasma_mole_amount > 0)
		var/turf/open/T = get_turf(src)
		var/mob/living/simple_animal/slime/S = new(T, "dark purple")
		S.rabid = TRUE
		S.amount_grown = SLIME_EVOLUTION_THRESHOLD
		S.Evolve()
		S.flavor_text = FLAVOR_TEXT_EVIL
		S.set_playable()
