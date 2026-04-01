/obj/item/fighter_component/primary/utility/refuel
	name = "air to air refueling kit"
	desc = "A large hose line which can allow a utility craft to perform air to air refuelling and battery jumpstarts."
	icon_state = "resupply_tier1"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/fighters/refuel.ogg')
	fire_delay = 4 SECONDS
	bypass_safety = TRUE
	var/datum/beam/current_beam
	var/next_fuel = 0
	var/is_fuelling = TRUE
	var/is_charging = TRUE
	var/battery_recharge_amount = 500
	var/minimum_fuel_to_keep = 250
	var/fuel_transfer_rate = 50
	var/refuel_range = 10

/obj/item/fighter_component/primary/utility/refuel/on_install(obj/structure/overmap/target)
	. = ..()
	RegisterSignal(target, COMSIG_TARGET_LOCKED, PROC_REF(on_target_lock))

/obj/item/fighter_component/primary/utility/refuel/remove_from(obj/structure/overmap/target)
	. = ..()
	UnregisterSignal(target, COMSIG_TARGET_LOCKED)

/obj/item/fighter_component/primary/utility/refuel/proc/on_target_lock(obj/structure/overmap/us, obj/structure/overmap/target)
	is_fuelling = TRUE
	is_charging = TRUE

/obj/item/fighter_component/primary/utility/refuel/get_ammo()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return 0
	return F.get_fuel()

/obj/item/fighter_component/primary/utility/refuel/get_max_ammo()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return 0
	return F.get_max_fuel()

/obj/item/fighter_component/primary/utility/refuel/tier2
	name = "upgraded air to air resupply kit"
	icon_state = "resupply_tier2"
	fire_delay = 3 SECONDS
	tier = 2

/obj/item/fighter_component/primary/utility/refuel/tier3
	name = "super air to air resupply kit"
	icon_state = "resupply_tier3"
	fire_delay = 2 SECONDS
	tier = 3

/obj/item/fighter_component/primary/utility/refuel/proc/cancel_action(obj/structure/overmap/us, obj/structure/overmap/them, message)
	// Remove beam
	QDEL_NULL(current_beam)
	// Remove targeting
	if(us && LAZYFIND(us.target_painted, them))
		us.dump_lock(them)
	if(us && us.gunner && message)
		to_chat(us.gunner, message)

/obj/item/fighter_component/primary/utility/refuel/process()
	if(!..())
		return
	if(world.time < next_fuel)
		return
	// The component isn't installed, we're not on that mode, or we have no potential targets
	var/obj/structure/overmap/small_craft/us = loc
	if(!us || !istype(us) || !length(us.target_painted))
		return
	// The target isn't an overmap somehow, we're targeting ourselves, or they're an enemy
	var/obj/structure/overmap/small_craft/them = us.target_lock
	if(!them || !istype(them) || (them == us) || (them.faction != us.faction))
		cancel_action(us, them)
		return
	// We're out of range
	if(overmap_dist(us, them) > refuel_range)
		cancel_action(us, them, "<span class='warning'>Target out of range.</span>")
		return

	// Getting here means we should actually try refueling them
	next_fuel = world.time + fire_delay

	if(is_fuelling)
		var/fuel_message = transfer_fuel(us, them)
		if(fuel_message)
			to_chat(us.gunner, fuel_message)
			is_fuelling = FALSE

	if(is_charging)
		var/charge_message = jump_battery(us, them)
		if(charge_message)
			to_chat(us.gunner, charge_message)
			is_charging = FALSE

	if(!is_fuelling && !is_charging)
		cancel_action(us, them, "<span class='notice'>All operations complete. Disconnecting transfer equipment.</span>")
		return

	// See if we need to make a new beam. Comes after the refuel so we can not do this if we fail any checks.
	if(QDELETED(current_beam))
		current_beam = new(us,them,beam_icon='nsv13/icons/effects/beam.dmi',time=INFINITY,maxdistance = INFINITY,beam_icon_state="hose",btype=/obj/effect/ebeam/fuel_hose)
		INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))

// These procs handle transferring fuel/charge. If a string is returned, it means we're done. If FALSE is returned, we're not done.
/obj/item/fighter_component/primary/utility/refuel/proc/transfer_fuel(obj/structure/overmap/small_craft/us, obj/structure/overmap/small_craft/them)
	var/transfer_amount = CLAMP((them.get_max_fuel() - them.get_fuel()), 0, fuel_transfer_rate)
	if(transfer_amount <= 0)
		return "<span class='notice'>Target craft is fully fueled.</span>"
	if(us.get_fuel() <= minimum_fuel_to_keep) // Don't give away ALL our fuel
		return "<span class='warning'>Fuel levels below minimum safe transfer level.</span>"
	var/obj/item/fighter_component/fuel_tank/ourTank = us.loadout.get_slot(HARDPOINT_SLOT_FUEL)
	var/obj/item/fighter_component/fuel_tank/theirTank = them.loadout.get_slot(HARDPOINT_SLOT_FUEL)
	us.relay('nsv13/sound/effects/fighters/refuel.ogg')
	them.relay('nsv13/sound/effects/fighters/refuel.ogg')
	ourTank.reagents.trans_to(theirTank, transfer_amount)
	return

/obj/item/fighter_component/primary/utility/refuel/proc/jump_battery(obj/structure/overmap/small_craft/us, obj/structure/overmap/small_craft/them)
	var/obj/item/fighter_component/battery/ourBattery = us.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	if(!ourBattery || !istype(ourBattery))
		return "<span class='warning'>This craft has no battery installed!</span>"
	var/obj/item/fighter_component/battery/theirBattery = them.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	if(!theirBattery || !istype(theirBattery))
		return "<span class='warning'>The target has no battery installed!</span>"
	if(ourBattery.charge < (battery_recharge_amount * 2))
		return "<span class='warning'>Battery charge is below minimum safe transfer level.</span>"
	if(!(theirBattery.charge < theirBattery.maxcharge))
		return "<span class='notice'>Target craft is fully charged.</span>"
	theirBattery.give(battery_recharge_amount) //Jumpstart their battery
	ourBattery.use_power(battery_recharge_amount)
	return
