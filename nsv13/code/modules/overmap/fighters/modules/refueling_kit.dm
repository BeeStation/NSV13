/obj/item/fighter_component/secondary/utility/refuel
	name = "air to air refueling kit"
	desc = "A large hose line which can allow a utility craft to perform air to air refuelling and battery jumpstarts."
	icon_state = "resupply_tier1"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/fighters/refuel.ogg')
	fire_delay = 6 SECONDS
	bypass_safety = TRUE
	var/datum/beam/current_beam
	var/next_fuel = 0
	var/battery_recharge_amount = 500
	var/minimum_fuel_to_keep = 200
	var/fuel_transfer_rate = 100

/obj/item/fighter_component/secondary/utility/refuel/get_ammo()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return 0
	return F.get_fuel()

/obj/item/fighter_component/secondary/utility/refuel/get_max_ammo()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return 0
	return F.get_max_fuel()

/obj/item/fighter_component/secondary/utility/refuel/tier2
	name = "upgraded air to air resupply kit"
	icon_state = "resupply_tier2"
	fire_delay = 5 SECONDS
	tier = 2

/obj/item/fighter_component/secondary/utility/refuel/tier3
	name = "super air to air resupply kit"
	icon_state = "resupply_tier3"
	fire_delay = 3 SECONDS
	tier = 3

/obj/item/fighter_component/secondary/utility/refuel/process()
	if(!..())
		return
	var/obj/structure/overmap/small_craft/F = loc
	if((!istype(F) || !F.autofire_target || F.fire_mode != fire_mode) && current_beam)
		QDEL_NULL(current_beam)
		return FALSE
	if(world.time < next_fuel)
		return FALSE
	var/obj/structure/overmap/small_craft/them = F.autofire_target
	if(!istype(them) || them == F) //No self targeting
		return FALSE
	next_fuel = world.time + fire_delay
	if(QDELETED(current_beam))
		current_beam = new(F,them,beam_icon='nsv13/icons/effects/beam.dmi',time=INFINITY,maxdistance = INFINITY,beam_icon_state="hose",btype=/obj/effect/ebeam/fuel_hose)
		INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)

	transfer_fuel(them)
	jump_battery(them)

/obj/item/fighter_component/secondary/utility/refuel/proc/transfer_fuel(obj/structure/overmap/small_craft/them)
	var/obj/structure/overmap/small_craft/F = loc
	if(!F || !istype(F))
		return
	var/transfer_amount = CLAMP((them.get_max_fuel() - them.get_fuel()), 0, fuel_transfer_rate)
	if(!transfer_amount)
		to_chat(F.gunner, "<span class='notice'>Fuel tank is full.</span>")
		return
	if(F.get_fuel() <= minimum_fuel_to_keep) // Don't give away ALL our fuel
		to_chat(F.gunner, "<span class='warning'>Fuel is below minimum safe transfer level.</span>")
		return
	var/obj/item/fighter_component/fuel_tank/fuel = F.loadout.get_slot(HARDPOINT_SLOT_FUEL)
	var/obj/item/fighter_component/fuel_tank/theirFuel = them.loadout.get_slot(HARDPOINT_SLOT_FUEL)
	F.relay('nsv13/sound/effects/fighters/refuel.ogg')
	them.relay('nsv13/sound/effects/fighters/refuel.ogg')
	fuel.reagents.trans_to(theirFuel, transfer_amount)

/obj/item/fighter_component/secondary/utility/refuel/proc/jump_battery(obj/structure/overmap/small_craft/friendly)
	var/obj/structure/overmap/small_craft/self = loc
	var/obj/item/fighter_component/battery/ourBattery = self.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	if(!ourBattery || !istype(ourBattery) || ourBattery.charge < (battery_recharge_amount * 2))
		to_chat(self.gunner, "<span class='warning'>Battery charge is below minimum safe transfer level.</span>")
		return
	var/obj/item/fighter_component/battery/theirBattery = friendly.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	if(!theirBattery || !istype(theirBattery) || !(theirBattery.charge < battery_recharge_amount))
		to_chat(self.gunner, "<span class='notice'>Battery levels nominal.</span>")
		return
	theirBattery.give(battery_recharge_amount) //Jumpstart their battery
	ourBattery.use_power(battery_recharge_amount)
