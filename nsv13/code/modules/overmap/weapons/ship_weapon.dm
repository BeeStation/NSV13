#define FIRE_INTERCEPTED 2 //For special_fire()

/obj/structure/overmap/proc/add_weapon(obj/machinery/ship_weapon/weapon)
	if(weapon_types[weapon.fire_mode])
		var/datum/ship_weapon/SW = weapon_types[weapon.fire_mode]
		SW.add_weapon(weapon) //hand it over to the datum for sane things like adding it idk

/datum/ship_weapon
	var/name = "Ship weapon"
	var/default_projectile_type
	var/burst_size = 1
	var/fire_delay
	var/range_modifier
	var/select_alert
	var/failure_alert
	var/list/overmap_firing_sounds
	var/overmap_select_sound
	var/list/weapons = list()
	var/range = 100 //Todo, change this
	var/obj/structure/overmap/holder = null
	var/requires_physical_guns = TRUE //Set this to false for any fighter weapons we may have
	var/lateral = TRUE //Does this weapon need you to face the enemy? Mostly no.
	var/special_fire_proc = null //Override this if you need to replace the firing weapons behaviour with a custom proc. See torpedoes and missiles for this.
	var/selectable = TRUE //Is this a gun you can manually fire? Or do you want it for example, be an individually manned thing..?
	var/screen_shake = 0

/datum/ship_weapon/torpedo_launcher
	special_fire_proc = /obj/structure/overmap/proc/fire_torpedo
	lateral = FALSE

/datum/ship_weapon/missile_launcher
	special_fire_proc = /obj/structure/overmap/proc/fire_missile
	lateral = FALSE

/datum/ship_weapon/proc/add_weapon(obj/machinery/ship_weapon/weapon)
	var/list/all_weapons = weapons["all"]
	if(LAZYFIND(all_weapons, weapon)) //No just no
		return
	requires_physical_guns = TRUE //If we're adding a physical weapon, we want to shoot it.
	all_weapons += weapon //Record-keeping
	weapon.weapon_type = src
	weapon.update() //Ok is this thing loaded or what.

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
		requires_physical_guns = (holder.linked_areas?.len && !holder.ai_controlled) //AIs don't have physical guns, but anything with linked areas is very likely to.

/obj/structure/overmap/proc/fire_weapon(atom/target, mode=fire_mode, lateral=(mass > MASS_TINY), mob/user_override=null) //"Lateral" means that your ship doesnt have to face the target
	var/datum/ship_weapon/SW = weapon_types[mode]
	if(weapon_safety)
		return FALSE
	if(SW?.fire(target))
		return TRUE
	else
		if(gunner && SW) //Tell them we failed
			if(world.time < next_firetime) //Silence, SPAM.
				return FALSE
			to_chat(gunner, SW.failure_alert)
	return FALSE

/datum/ship_weapon/proc/special_fire(atom/target)
	if(fire_delay)
		holder.next_firetime = world.time + fire_delay
	if(!requires_physical_guns)
		if(special_fire_proc)
			CallAsync(source=holder, proctype=special_fire_proc, arguments=list(target=target)) //WARNING: The default behaviour of this proc will ALWAYS supply the target method with the parameter "target". Override this proc if your thing doesnt have a target parameter!
		else
			weapon_sound()
			if(lateral)
				for(var/I = 0; I < burst_size; I++)
					sleep(1) //Prevents space shotgun
					holder.fire_lateral_projectile(default_projectile_type, target)
			else
				for(var/I = 0; I < burst_size; I++)
					sleep(1)
					holder.fire_projectile(default_projectile_type, target)
		return FIRE_INTERCEPTED
	return FALSE

/datum/ship_weapon/proc/weapon_sound()
	set waitfor = FALSE
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
/datum/ship_weapon/proc/fire_fx_only(atom/target)
	if(overmap_firing_sounds)
		var/sound/chosen = pick(overmap_firing_sounds)
		holder.relay_to_nearby(chosen)
	holder.fire_projectile(default_projectile_type, target)

/datum/ship_weapon/proc/fire(atom/target)
	if(special_fire(target) == FIRE_INTERCEPTED)
		return TRUE //Fire call was intercepted. Don't do the thing
	var/list/leftovers = list() //Assuming we can't find a fully loaded gun to fire our full burst, assemble a list of semi-loaded guns and fire all of them instead.
	var/remaining = burst_size
	for(var/obj/machinery/ship_weapon/SW in weapons["loaded"])
		if(SW.can_fire()) //Ok great, looks like this weapon can do all the shooting for us. Use it!
			SW.fire(target)
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
	return TRUE
