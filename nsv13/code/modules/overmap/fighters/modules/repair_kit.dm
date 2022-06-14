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

/obj/item/fighter_component/primary/utility/repairer/process()
	if(!..())
		return
	var/obj/structure/overmap/small_craft/us = loc
	if(!us || !istype(us) || !us.autofire_target || (us.fire_mode != fire_mode))
		QDEL_NULL(current_beam)
		return
	var/obj/structure/overmap/them = us.autofire_target
	if(!them || !istype(them) || (them == us))
		QDEL_NULL(current_beam)
		return
	var/obj/structure/reagent_dispensers/foamtank/hull_repair_juice/tank = magazine
	if(!tank || !istype(tank))
		QDEL_NULL(current_beam)
		return
	if(world.time < next_repair)
		return
	next_repair = world.time + fire_delay
	if(them.obj_integrity >= them.max_integrity)
		to_chat(us.gunner, "<span class='notice'>Target fully repaired.</span>")
		return
	if(QDELETED(current_beam))
		current_beam = new(us,them,beam_icon='icons/effects/beam.dmi',time=INFINITY,maxdistance = INFINITY,beam_icon_state="medbeam",btype=/obj/effect/ebeam/medical)
		INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
	new /obj/effect/temp_visual/heal(get_turf(them), COLOR_CYAN)
	tank.reagents.remove_reagent(/datum/reagent/hull_repair_juice, 5)
	//You can repair the main ship too! However at a painfully slow rate. Higher tiers give you vastly better repairs, and bigger ships repair smaller ships way faster.
	them.try_repair(0.5+tier-(them.mass-us.mass))
	//Generals sat from the lines at the back
	us.relay('sound/items/welder.ogg')
	them.relay('sound/items/welder2.ogg')
