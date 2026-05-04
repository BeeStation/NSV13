/obj/machinery/ship_weapon/energy/ams
	name = "\improper Laser Anti Missile System"
	desc = "A coaxial laser system, capable of firing controlled laser bursts at a target."
	icon ='nsv13/icons/obj/energy_weapons.dmi'
	icon_state = "missile_cannon"
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo
	circuit = /obj/item/circuitboard/machine/laser_ams
	bound_width = 64
	pixel_x = -32
	pixel_y = -32
	maintainable = TRUE //AMS requires some form of maintenance to operate
	safety = FALSE //Ready to go right from the start.
	idle_power_usage = 2500
	active = FALSE
	charge = 0
	max_heat = 800
	heat_per_shot = 100
	heat_rate = 30
	storage_rate = 100
	freq_max = 4
	thermal = 0


	// Hitscan antimissile laser, charges relatively quickly, but can't hold a decent buffer!
	charge_rate = 1500000 // At power level 2, requires 3MW per tick to charge
	charge_per_shot = 3000000 // At power level 2, requires 6MW total to fire, takes about 3 seconds to gain 1 charge
	max_charge = 6000000 // Store 2 charge

	power_modifier = 0 //Power you're inputting into this thing.
	power_modifier_cap = 2
	weapon_datum_type = /datum/overmap_ship_weapon/laser_ams

/obj/machinery/ship_weapon/energy/ams/fire(atom/target, shots = linked_overmap_ship_weapon.burst_size, manual = TRUE)
	var/list/amm_targets = linked.torpedoes_to_target.Copy(1, min(length(linked.torpedoes_to_target), 10))
	if (!length(amm_targets))
		visible_message("<span class=userdanger>burst canceled</span>")
		return
	if(can_fire(target, shots))
		if(manual)
			linked.last_fired = overlay
		for(var/i = 0, i < shots, i++)
			do_animation()
			local_fire()
			target = pick(amm_targets)
			visible_message("<span class=userdanger>[target] targeted</span>")
			overmap_fire(target)
			charge -= charge_per_shot
			if(maintainable)
				heat += heat_per_shot
			after_fire()
			. = TRUE
			if(shots > 1)
				sleep(linked_overmap_ship_weapon.burst_fire_delay)
		return TRUE
	return FALSE
