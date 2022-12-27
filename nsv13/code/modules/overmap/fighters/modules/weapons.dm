//Primary Weapons

/obj/item/fighter_component/primary/cannon
	name = "20mm Vulcan Cannon"
	icon_state = "lightcannon"
	accepted_ammo = /obj/item/ammo_box/magazine/nsv/light_cannon
	burst_size = 2
	fire_delay = 0.25 SECONDS
	weapon_datum = /datum/ship_weapon/light_cannon

/obj/item/fighter_component/primary/cannon/heavy
	name = "30mm BRRRRTT Cannon"
	icon_state = "heavycannon"
	accepted_ammo = /obj/item/ammo_box/magazine/nsv/heavy_cannon
	weight = 2 //Sloooow down there.
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/BRRTTTTTT.ogg')
	burst_size = 3
	fire_delay = 0.5 SECONDS
	weapon_datum = /datum/ship_weapon/heavy_cannon

//Secondary Weapons

//Todo: make fighters use these.
/obj/item/fighter_component/secondary/ordnance_launcher
	name = "fighter missile rack"
	desc = "A huge fighter missile rack capable of deploying missile based weaponry."
	icon_state = "missilerack_tier1"

/obj/item/fighter_component/secondary/ordnance_launcher/tier2
	name = "upgraded fighter missile rack"
	icon_state = "missilerack_tier2"
	tier = 2
	max_ammo = 5

/obj/item/fighter_component/secondary/ordnance_launcher/tier3
	name = "\improper A-11 'Spacehog' Cluster-Freedom Launcher"
	icon_state = "missilerack_tier3"
	tier = 3
	max_ammo = 15
	weight = 1
	burst_size = 2
	fire_delay = 0.10 SECONDS

//Specialist item for the superiority fighter.
/obj/item/fighter_component/secondary/ordnance_launcher/railgun
	name = "fighter railgun"
	desc = "A scaled down railgun designed for use in fighters."
	icon_state = "railgun"
	weight = 1
	accepted_ammo = /obj/item/ship_weapon/ammunition/railgun_ammo
	overmap_firing_sounds = list('nsv13/sound/effects/ship/railgun_fire.ogg')
	burst_size = 1
	fire_delay = 0.2 SECONDS
	max_ammo = 10
	tier = 1
	weapon_datum = /datum/ship_weapon/railgun

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo
	name = "fighter torpedo launcher"
	desc = "A heavy torpedo rack which allows fighters to fire torpedoes at targets"
	icon_state = "torpedorack"
	accepted_ammo = /obj/item/ship_weapon/ammunition/torpedo
	max_ammo = 2
	weight = 1

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier2
	name = "enhanced torpedo launcher"
	icon_state = "torpedorack_tier2"
	tier = 2
	max_ammo = 4

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier3
	name = "\improper FR33-8IRD torpedo launcher"
	icon_state = "torpedorack_tier3"
	desc = "A massive torpedo launcher capable of deploying enough ordnance to level several small, oil-rich nations."
	tier = 3
	max_ammo = 10
	weight = 2
	burst_size = 2

/obj/item/fighter_component/secondary/ordnance_launcher/wireguided_torpedo
	name = "katana wireguided torpedo launcher"
	desc = "A heavy torpedo rack for holding the Katana's primary guided munitions"
	icon_state = "torpedorack_tier3"
	accepted_ammo = /obj/item/ship_weapon/ammunition/torpedo
	max_ammo = 4
	weight = 2
	tier = 1
	slot = HARDPOINT_SLOT_DUAL_PRIMARY
	weapon_datum = /datum/ship_weapon/wire_guided_torpedo_launcher

/obj/item/fighter_component/secondary/ordnance_launcher/wireguided_torpedo/fire(obj/structure/overmap/target)
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE
	if(!ammo.len)
		F.relay('sound/weapons/gun_dry_fire.ogg')
		return FALSE

	var/obj/item/ship_weapon/ammunition/torpedo/ST = pick_n_take(ammo) //We pick a torp from our rack
	var/obj/structure/overmap/small_craft/SC = loc //Use a jank method to gather info
	var/obj/structure/overmap/torpedo/OMT = new(SC.loc) //Generate the new torpedo

	//Assign properties
	OMT.OM = SC
	OMT.angle = SC.angle
	OMT.faction = SC.faction
	OMT.warhead = ST.projectile_type //make a default type if no warhead
	var/obj/item/projectile/guided_munition/torpedo/PT = new OMT.warhead()
	OMT.name = PT.name
	OMT.icon_state = PT.icon_state
	OMT.damage_amount = PT.damage
	OMT.damage_type = PT.damage_type
	OMT.damage_penetration = PT.armour_penetration
	OMT.damage_flag = PT.flag
	OMT.relayed_projectile = PT.relay_projectile_type
	OMT.detonation = PT.impact_effect_type

	if(SC.ai_controlled) //If for some reason this is AI controlled
		OMT.ai_driven = TRUE
		OMT.ai_behaviour = AI_AGGRESSIVE
		OMT.ai_flags = AI_FLAG_MUNITION
		OMT.current_system = SC.current_system

	else //Here we move our gunner mob's overmap control into the torpedo
		var/mob/living/carbon/C = SC.gunner
		SC.stop_piloting(C, FALSE)
		OMT.start_piloting(C, OVERMAP_USER_ROLE_PILOT)

	//Clean up
	qdel(ST)
	qdel(PT)

	return TRUE
