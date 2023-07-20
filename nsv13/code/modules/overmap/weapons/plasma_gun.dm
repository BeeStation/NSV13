/obj/machinery/ship_weapon/plasma_caster
	name = "\improper Magnetic Phoron Acceleration Caster"
	icon = 'nsv13/icons/obj/plasma_gun.dmi'
	icon_state = "plasma_gun"
	desc = "An MPAC, a strong deterrent used by the Dominion as a method of staving off attackers. It requires a lot of maintenance."
	anchored = TRUE
	max_integrity = 1200 //It has no chance to survive a self-induced plasmafire
	obj_integrity = 1200

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

	feeding_sound = 'nsv13/sound/effects/ship/plasma_gun_load.ogg'
	load_sound = 'nsv13/sound/effects/ship/plasma_gun_feeding.ogg'
	unload_sound = 'nsv13/sound/effects/ship/plasma_gun_unload.ogg'
	chamber_sound = 'nsv13/sound/effects/ship/plasma_gun_chambering.ogg'
	firing_sound = null
	malfunction_sound = 'nsv13/sound/effects/ship/plasma_gun_malfunction.ogg'
	fed_sound = null

	load_delay = 20
	unload_delay = 20
	fire_animation_length = 2.5 SECONDS

	feed_delay = 8.3
	chamber_delay_rapid = 0
	chamber_delay = 5
	bang = FALSE

	light_system = STATIC_LIGHT
	light_range = 4
	light_power = 2
	light_on = TRUE

	var/obj/machinery/atmospherics/components/unary/plasma_loader/loader
	var/plasma_fire_moles = 500
	var/plasma_mole_amount = 0 //How much plasma gas is in the gun
	var/alignment = 100 //Stealing this from hybrid railguns
	var/field_integrity = 100 //Degrades over time when safety's off, don't let it reach zero
	var/next_warning = 0 //Helps keep warning spam away
	var/cooldown = 0 //A janky timer that keeps the weapon from being optimized too hard, it takes around 1.5 minutes between shots

	processing_flags = START_PROCESSING_ON_INIT

/obj/machinery/ship_weapon/plasma_caster/update_overlay()
	. = ..()
	if(maint_state == MSTATE_CLOSED)
		add_overlay("on")

/obj/machinery/ship_weapon/plasma_caster/screwdriver_act()
	. = ..()
	if(!safety)
		toggle_safety()

/obj/machinery/ship_weapon/plasma_caster/toggle_safety()
	. = ..()
	if(!safety)
		begin_processing()
	else if(field_integrity == 100)
		end_processing()

/obj/machinery/ship_weapon/plasma_caster/power_change()
	..()
	if(machine_stat & NOPOWER)
		set_light(FALSE)
		cut_overlays()
	else
		set_light(TRUE)
		add_overlay("on")
	update_appearance()
	return

/obj/machinery/ship_weapon/plasma_caster/process(delta_time)
	if(!powered())
		unchamber()
		unload()
		return PROCESS_KILL
	if(state == STATE_FIRING)
		cut_overlays()
		add_overlay("firing")
		light_power = max(light_power + delta_time)

	if(cooldown > 0)
		cooldown = max(cooldown - delta_time, 0)
	if(!safety)
		field_integrity = max(field_integrity - delta_time, 0)
	else
		field_integrity = min(field_integrity + delta_time, 100)
	switch(field_integrity)
		if(100)
			if(next_warning == 1)
				next_warning --
				say("Local phoron containment field fully stabilized.")
				cut_overlays()
				add_overlay("on")
		if(76 to 99)
			if(next_warning == 0)
				next_warning ++
				say("Localized phoron containment field disengaged, preparing to fire.")
				cut_overlays()
				add_overlay("integ_100")
			else if(next_warning == 2)
				next_warning --
				say("Phoron containment field stabilized to ideal levels.")
				cut_overlays()
				add_overlay("integ_100")
		if(51 to 75)
			if(next_warning == 1)
				next_warning ++
				say("Phoron containment field at 75%, stability decreasing.")
				cut_overlays()
				add_overlay("integ_75")
			else if(next_warning == 3)
				say("Integrity at 50%, continuing stabilization process...")
				next_warning --
				cut_overlays()
				add_overlay("integ_75")
		if(26 to 50)
			if(next_warning == 2)
				next_warning ++
				say("WARNING! Containment field 50% and falling.")
				cut_overlays()
				add_overlay("integ_50")
			else if(next_warning == 4)
				next_warning --
				say("Restored field integrity above critical levels.")
				cut_overlays()
				add_overlay("integ_50")
		if(1 to 25)
			if(next_warning == 3)
				next_warning ++
				say("WARNING! 25% Integrity! Containment Failure Imminent!")
				cut_overlays()
				add_overlay("integ_25")
		if(-INFINITY to 0)
			misfire()
			safety = TRUE
			field_integrity = 100
			next_warning = 0
			update_overlay()
			return PROCESS_KILL

/obj/machinery/ship_weapon/plasma_caster/Initialize(mapload)
	. = ..()
	power_change()
	loader = locate(/obj/machinery/atmospherics/components/unary/plasma_loader) in orange(1, src)
	loader.linked_gun = src

/obj/machinery/ship_weapon/plasma_caster/can_fire(shots = weapon_type.burst_size)
	if((state < STATE_CHAMBERED) || !chambered)
		return FALSE
	if(state >= STATE_FIRING)
		return FALSE
	if(cooldown > 0)
		say("DANGER! Splines unreticulated, spline reticulization process may take up to [cooldown] seconds to complete.")
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

/obj/machinery/ship_weapon/plasma_caster/local_fire()
	for(var/mob/living/M in get_hearers_in_view(7, src)) //burn out eyes in view
		if(M.stat != DEAD && M.get_eye_protection() < 2) //checks for eye protec
			M.flash_act(10)
			to_chat(M, "<span class='warning'>Your eyes burn from the brilliance of the Lämp!</span>")

/obj/machinery/ship_weapon/plasma_caster/do_animation()
	set waitfor = FALSE
	sleep(2 SECONDS)
	flick("[initial(icon_state)]_firing",src)
	sleep(fire_animation_length)
	icon_state = initial(icon_state)

/obj/machinery/ship_weapon/plasma_caster/animate_projectile(atom/target)
	return linked.fire_projectile(weapon_type.default_projectile_type, target, speed = 2, lateral=weapon_type.lateral)

/obj/machinery/ship_weapon/plasma_caster/proc/misfire()
	say("WARNING! Phoron containment field failure, ejecting gas!")
	if(prob(15))
		do_sparks(4, FALSE, src)
	if(plasma_mole_amount > 0 && prob(5))
		makedarkpurpleslime()
	atmos_spawn_air("plasma=[plasma_mole_amount];TEMP=293")
	alignment -= rand(30,90)
	if(alignment < 0)
		alignment = 0
	field_integrity -= rand(20,50)
	plasma_mole_amount = 0
	playsound(src, malfunction_sound, 100, 1)
	tesla_zap(src, 8, TESLA_MINI_POWER, TESLA_ENERGY_MINI_BALL_FLAGS)
	playsound(src,'sound/machines/defib_zap.ogg', 100, 1)
	unchamber()
	unload()

/obj/machinery/ship_weapon/plasma_caster/overmap_fire(atom/target)

	if(weapon_type?.overmap_firing_sounds)
		overmap_sound()

	if(overlay)
		overlay.do_animation()
	sleep(4 SECONDS)
	if( weapon_type )
		animate_projectile(target)

/obj/machinery/ship_weapon/plasma_caster/after_fire()
	alignment -= rand(30,60)
	if(alignment < 0)
		alignment = 0
	plasma_mole_amount = 0
	field_integrity -= 20
	cooldown = 100
	light_power = 2
	..()

/obj/machinery/ship_weapon/plasma_caster/default_deconstruction_crowbar(obj/item/I, ignore_panel)
	var/mob/living/fool = usr
	var/confirm = alert("You feel an electric tingle as you bring your crowbar close, there's an odd heat the closer you get.\
						 Are you sure this is a good idea?", "Deconstruct Phoron Caster", "Yes", "No")
	if(confirm == "Yes")
		visible_message("<span class='danger'>Burning energy and phoron starts to vent from the gun which chars [usr]!</span>")
		field_integrity -= rand(30,50)
		alignment = max(alignment - rand(50,80), 0)
		fool.adjustFireLoss(rand(50, 120)) // Don't try to deconstruct it
		fool.IgniteMob()
		playsound(usr.loc, 'sound/magic/lightningbolt.ogg', 100, 1, extrarange = 30)
		return
	else
		visible_message("<span class 'notice'>[usr] wisely lowers their crowbar.")
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
	data["cooldown"] = cooldown
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

/datum/ship_weapon/plasma_caster
	name = "MPAC"
	burst_size = 1
	fire_delay = 5 SECONDS //Everyone's right, weapon code is jank...
	range = 25000 //It will continue to
	default_projectile_type = /obj/item/projectile/bullet/plasma_caster
	select_alert = "<span class='notice'>Charging magnetic accelerator...</span>"
	failure_alert = "<span class='warning'>Magnetic Accelerator not ready!</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/plasma_gun_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/phaser_select.ogg'
	weapon_class = WEAPON_CLASS_HEAVY
	ai_fire_delay = 180 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_GUNNER
	lateral = FALSE

/obj/item/ship_weapon/ammunition/plasma_core
	name = "\improper Condensed Phoron Core"
	desc = "A heavy, condensed ball of phoron coated in a thick shell to prevent accidents."
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "plasma_core"
	projectile_type = /obj/item/projectile/bullet/plasma_caster

/obj/item/projectile/bullet/plasma_caster
	name = "plasma ball"
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "plasma_ball" //No longer bad test sprite, animated and globulated
	can_home = TRUE
	range = 25000 //Relentlessly tracks original target until the target is destroyed
	homing_turn_speed = 180
	damage = 150
	obj_integrity = 500
	max_integrity = 500
	flag = "overmap_medium"
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
	RegisterSignal(homing_target, COMSIG_PARENT_QDELETING, PROC_REF(find_target))

/obj/item/projectile/bullet/plasma_caster/proc/find_target() //Tracking Proc when the weapon initially fires
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
		if(QDELETED(ship) && ship.mass != MASS_TINY) //It destroys itself when its target is destroyed, ignoring destroyed fighters
			new /obj/effect/particle_effect/phoron_explosion(loc) //It shouldn't cause problems unless the weapon is fired at the EXACT time a ship it can target is being destroyed
			qdel(src)
			return
		if(overmap_firer.warcrime_blacklist[ship.type]) //Doesn't target asteroids, same faction, essentials, ships on diff Z Levels, or fighters
			continue
		if(ship.mass == MASS_TINY)
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
	RegisterSignal(homing_target, COMSIG_PARENT_QDELETING, PROC_REF(find_target))

/obj/machinery/ship_weapon/plasma_caster/proc/makedarkpurpleslime()
	if(plasma_mole_amount > 0)
		var/turf/open/T = get_turf(src)
		var/mob/living/simple_animal/slime/S = new(T, "dark purple")
		S.rabid = TRUE
		S.amount_grown = SLIME_EVOLUTION_THRESHOLD
		S.Evolve()
		S.flavor_text = FLAVOR_TEXT_EVIL
		S.set_playable()

/obj/item/book/manual/plasma_caster
	name = "Vintergatan Manual"
	desc = "The book is laden with actual gold trim and embelishments, a single sheet of paper is sandwiched between the cover and the first page with the translation."
	icon = 'nsv13/icons/obj/library.dmi'
	icon_state = "plasma_gun"
	author = "Fleet Presider Izatha Radiata, translated by Intern Andy Smith"
	title = "Vintergatan"
	dat = {"<html>
				<h1>Vintergatan</h1>
				<p>Hello and many thank yous for the use of the Serendipity Ship!<br>
				This deterrent is meant to ward off the hostile,<br>
				but it can be many trouble to use so super careful!<br>
				Misuse can be burning and blinding.<p>

				<h4>Step by Step</h4>

				<p>-Insert phoron core<br>
				-Condense of the mass<br>
				-Rub magnets<br>
				-Disengage container fielding<br>
				-Utilize ship console and fire<br></p>

				<h4>Maintaining</h4>
				<p>-Drive the screws counterspin wise<br>
				-Bolt the unwrench
				-Switch alignments with manytool
				-Rewrench the unbolted
				-Screws the rightspin
				-Alignment will regain

				-Leave field on to replenish integrity
				-Splines autoriticulate with time</pr>

				<h4>Warnings</h4>

				<p>-Turns the off of gas compressing before firing<br>
				-Ensure eyes are dark before firing<br>
				-Splines must be reticulate before firing<br>
				-Alignments must be highs at all time<br>
				-Do not off the fields too long<br>
				-Do not try to open with corvidbar<br>
				-Will not magnetize to tiny metal vessels<br>
				-Compressor will eject non-plasma<br>
				-Some time weapon will stop, toggle safety to stop stopping</pr>

				<p><b>Safety Moth Says: Malfires causes big fires!</b><br>
				<b>Ensure safe use of deterrents!</b></p>
				</html>
				"}
