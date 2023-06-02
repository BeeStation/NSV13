#define FIRE_INTERCEPTED 2 //For special_fire()

//These procs should *really* not be here
/obj/structure/overmap/proc/add_weapon(obj/machinery/ship_weapon/weapon)
	if(weapon_types[weapon.fire_mode])
		var/datum/ship_weapon/SW = weapon_types[weapon.fire_mode]
		SW.add_weapon(weapon) //hand it over to the datum for sane things like adding it idk

/datum/ship_weapon
	var/name = "Ship weapon"
	var/default_projectile_type
	var/burst_size = 1
	var/fire_delay
	var/burst_fire_delay = 1
	var/range_modifier
	var/select_alert
	var/failure_alert
	var/list/overmap_firing_sounds
	var/overmap_select_sound
	var/list/weapons = list()
	var/range = 255 //Todo, change this
	var/obj/structure/overmap/holder = null
	var/requires_physical_guns = TRUE //Set this to false for any fighter weapons we may have
	var/lateral = TRUE //Does this weapon need you to face the enemy? Mostly no.
	var/special_fire_proc = null //Override this if you need to replace the firing weapons behaviour with a custom proc. See torpedoes and missiles for this.
	var/screen_shake = 0
	var/firing_arc = null //If this weapon only fires in an arc (for ai ships)
	var/weapon_class = WEAPON_CLASS_HEAVY //Do AIs need to resupply with ammo to use this weapon?
	var/miss_chance = 5 // % chance the AI intercept calculator will be off a step
	var/max_miss_distance = 4 // Maximum number of tiles the AI will miss by
	var/autonomous = FALSE // Is this a gun that can automatically fire? Keep in mind variables selectable and autonomous can both be TRUE
	var/permitted_ams_modes = list( "Anti-ship" = 1, "Anti-missile countermeasures" = 1 ) // Overwrite the list with a specific firing mode if you want to restrict its targets
	var/allowed_roles = OVERMAP_USER_ROLE_GUNNER

	var/next_firetime = 0

	var/ai_fire_delay = 0 // make it fair on the humans who have to reload and stuff

/datum/ship_weapon/New(obj/structure/overmap/source, ...)
	. = ..()
	if(!source)
		message_admins("OI! [src] doesn't have an attached overmap. Did you do new /datum/ship_weapon(src) on your ship?")
		qdel(src)
		return FALSE
	holder = source
	weapons["loaded"] = list() //Weapons that are armed and ready.
	weapons["all"] = list() //All weapons, regardless of ammo state
	if(istype(holder, /obj/structure/overmap))
		requires_physical_guns = (length(holder.occupying_levels) && !holder.ai_controlled) //AIs don't have physical guns, but anything with linked areas is very likely to.

/datum/ship_weapon/proc/add_weapon(obj/machinery/ship_weapon/weapon)
	var/list/all_weapons = weapons["all"]
	if(LAZYFIND(all_weapons, weapon)) //No just no
		return
	requires_physical_guns = TRUE //If we're adding a physical weapon, we want to shoot it.
	all_weapons += weapon //Record-keeping
	weapon.weapon_type = src
	weapon.update() //Ok is this thing loaded or what.

/datum/ship_weapon/proc/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check = FALSE)
	return (istype(source) && istype(target))

/datum/ship_weapon/proc/special_fire(atom/target, ai_aim = FALSE)
	if(fire_delay)
		next_firetime = world.time + fire_delay
	if(!requires_physical_guns)
		if(special_fire_proc)
			call_async(source=holder, proctype=special_fire_proc, arguments=list(target=target, ai_aim=ai_aim, burst=burst_size)) //WARNING: The default behaviour of this proc will ALWAYS supply the target method with the parameter "target". Override this proc if your thing doesnt have a target parameter!
		else
			weapon_sound()
			if(ai_aim && prob(miss_chance)) // Apply bad aim here so the whole burst goes the same way
				var/direction = rand(0, 359)
				target = get_turf_in_angle(direction, target, rand(min(max_miss_distance,4), max_miss_distance))
			for(var/I = 0; I < burst_size; I++)
				sleep(burst_fire_delay) //Prevents space shotgun
				holder.fire_projectile(default_projectile_type, target, lateral=src.lateral, ai_aim=ai_aim)
		return FIRE_INTERCEPTED
	return FALSE

/datum/ship_weapon/proc/weapon_sound()
	set waitfor = FALSE // is this needed
	var/sound/chosen = pick(overmap_firing_sounds)
	holder.relay(chosen)

/datum/ship_weapon/proc/reload()
	for(var/obj/machinery/ship_weapon/SW in weapons["all"])
		SW.lazyload()

/datum/ship_weapon/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("special_proctype")
			return FALSE
	return ..()

//Dumbed down proc used to allow fighters to fire their weapons in a sane way.
/datum/ship_weapon/proc/fire_fx_only(atom/target, lateral = FALSE)
	if(overmap_firing_sounds)
		var/sound/chosen = pick(overmap_firing_sounds)
		holder.relay_to_nearby(chosen)
	holder.fire_projectile(default_projectile_type, target, lateral = lateral)

/datum/ship_weapon/proc/can_fire()
	for(var/obj/machinery/ship_weapon/SW in weapons["loaded"])
		if ( SW.can_fire() ) // If any one weapon in the datum's list can fire, return
			return TRUE
	return FALSE

/datum/ship_weapon/proc/fire(atom/target, ai_aim = FALSE)
	if(next_firetime > world.time)
		return FALSE
	if(special_fire(target, ai_aim=ai_aim) == FIRE_INTERCEPTED)
		next_firetime = world.time + fire_delay
		return TRUE //Fire call was intercepted. Don't do the thing
	var/list/leftovers = list() //Assuming we can't find a fully loaded gun to fire our full burst, assemble a list of semi-loaded guns and fire all of them instead.
	var/remaining = burst_size
	for(var/obj/machinery/ship_weapon/SW in weapons["loaded"])
		if(SW.can_fire(target)) //Ok great, looks like this weapon can do all the shooting for us. Use it!
			SW.fire(target)
			next_firetime = world.time + fire_delay
			return TRUE
		for(var/I = 0; I < SW.ammo.len; I++) //If a railgun has 3 bullets, add it to the leftovers list 3 times so we know exactly how many times we can fire it.
			if(remaining)
				leftovers += SW
				remaining --
	if(!leftovers.len) //fuck I ate a pizza and there's no leftovers; shaking and crying
		return FALSE //Can't fire any of the shot. Otherwise, we may be able to get a partial burst out, which counts as a fire in my book!
	for(var/obj/machinery/ship_weapon/SW in leftovers)
		sleep(1)
		SW.fire(target, shots = 1)
	if(screen_shake)
		holder.shake_everyone(screen_shake)
	next_firetime = world.time + fire_delay
	return TRUE
