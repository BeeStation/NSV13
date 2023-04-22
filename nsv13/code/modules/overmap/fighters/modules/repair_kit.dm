/obj/item/fighter_component/primary/utility/repairer
	name = "air-to-air repair kit"
	desc = "A module which can use hull repair foam to repair other fighters in the air."
	icon_state = "repairer_tier1"
	accepted_ammo = /obj/structure/reagent_dispensers/foamtank/hull_repair_juice
	power_usage = 50
	fire_delay = 5 SECONDS
	bypass_safety = TRUE
	var/datum/beam/current_beam = null
	var/next_repair = 0

/obj/item/fighter_component/primary/utility/repairer/get_ammo()
	return magazine?.reagents.total_volume

/obj/item/fighter_component/primary/utility/repairer/get_max_ammo()
	return magazine?.reagents.maximum_volume

/obj/item/fighter_component/primary/utility/repairer/tier2
	name = "upgraded air to air repair kit"
	icon_state = "repairer_tier2"
	tier = 2
	fire_delay = 4 SECONDS

/obj/item/fighter_component/primary/utility/repairer/tier3
	name = "super air to air repair kit"
	icon_state = "repairer_tier3"
	tier = 3
	fire_delay = 3 SECONDS

/obj/item/fighter_component/primary/utility/repairer/load(obj/structure/overmap/target, atom/movable/AM)
	if(!istype(AM, accepted_ammo))
		return FALSE
	magazine?.forceMove(get_turf(target))
	if(!SSmapping.level_trait(loc.z, ZTRAIT_BOARDABLE))
		qdel(magazine)
	AM.forceMove(src)
	magazine = AM
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/primary/utility/repairer/proc/cancel_action(obj/structure/overmap/us, obj/structure/overmap/them, message)
	// Remove beam
	QDEL_NULL(current_beam)
	// Remove targeting
	if(us && LAZYFIND(us.target_painted, them))
		us.start_lockon(them)
	if(us && us.gunner && message)
		to_chat(us.gunner, message)

/obj/item/fighter_component/primary/utility/repairer/process()
	if(!..())
		return
	if(world.time < next_repair)
		return
	// The component isn't installed, we're not on that mode, or we have no potential targets
	var/obj/structure/overmap/small_craft/us = loc
	if(!us || !istype(us) || (us.fire_mode != fire_mode) || !length(us.target_painted))
		cancel_action(us)
		return
	// The target isn't an overmap somehow, we're targeting ourselves, or they're an enemy
	var/obj/structure/overmap/small_craft/them = us.target_lock
	if(!them || !istype(them) || (them == us) || (them.faction != us.faction))
		cancel_action(us, them)
		return
	// We don't have a hull foam tank
	var/obj/structure/reagent_dispensers/foamtank/hull_repair_juice/tank = magazine
	if(!tank || !istype(tank))
		cancel_action(us, them, "<span class='warning'>No tank loaded.</span>")
		return
	// We're out of juice
	if(tank.reagents.get_reagent_amount(/datum/reagent/hull_repair_juice) <= 0)
		cancel_action(us, them, "<span class='warning'>Out of repair foam.</span>")
		return
	// They're fixed
	var/obj/item/fighter_component/armour_plating/theirArmour = them.loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
	if((them.obj_integrity >= them.max_integrity) && (theirArmour.obj_integrity >= theirArmour.max_integrity))
		cancel_action(us, them, "<span class='notice'>Target fully repaired.</span>")
		return

	// Getting here means we should actually try repairing them
	next_repair = world.time + fire_delay
	// First see if we need to make a new beam
	if(QDELETED(current_beam))
		current_beam = new(us,them,beam_icon='icons/effects/beam.dmi',time=INFINITY,maxdistance = INFINITY,beam_icon_state="medbeam",btype=/obj/effect/ebeam/medical)
		INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))
	new /obj/effect/temp_visual/heal(get_turf(them), COLOR_CYAN)
	// Use some juice
	tank.reagents.remove_reagent(/datum/reagent/hull_repair_juice, 5)
	//You can repair the main ship too! However at a painfully slow rate. Higher tiers give you vastly better repairs, and bigger ships repair smaller ships way faster.
	them.try_repair(0.5+tier-(them.mass-us.mass))
	us.relay('sound/items/welder.ogg')
	them.relay('sound/items/welder2.ogg')
