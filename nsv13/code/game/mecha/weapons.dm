//NSV-related mech equipment
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/smart_foam
	name = "\improper smart metal foam launcher"
	desc = "Launches grenades containing smart metal foam."
	icon_state = "mecha_grenadelnchr"
	projectile = /obj/item/grenade/chem_grenade/smart_metal_foam
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 6
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 60
	var/det_time = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/smart_foam/proj_init(var/obj/item/grenade/chem_grenade/smart_metal_foam/F)
	var/turf/T = get_turf(src)
	log_game("[key_name(chassis.occupant)] fired a [src] in [AREACOORD(T)]")
	addtimer(CALLBACK(F, TYPE_PROC_REF(/obj/item/grenade/chem_grenade/smart_metal_foam, prime)), det_time)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/smart_foam/can_attach(obj/mecha/working/M)
	if(..()) //combat mech
		return 1
	else if(M.equipment.len < M.max_equip && istype(M))
		return 1
	return 0
