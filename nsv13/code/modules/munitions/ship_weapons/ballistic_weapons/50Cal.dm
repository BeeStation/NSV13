// The point defense system! A neat crew served weapon which replaces the .50 cal
// This file has so much borrowed code and name swaps from previous iterations of PDC
/obj/machinery/ship_weapon/anti_air
	name = "\improper AA turret"
	desc = "A formidable weapon operated by a gunner below deck, extremely effective at anti-fighter defense though they struggle to damage larger targets."
	icon = 'nsv13/icons/obj/munitions/deck_gun.dmi'
	icon_state = "deck_gun"
	magazine_type = /obj/item/ammo_box/magazine/nsv/anti_air
	safety = FALSE
	auto_load = TRUE
	semi_auto = TRUE
	maintainable = FALSE
	fire_mode = FIRE_MODE_ANTI_AIR
	max_ammo = 300
	circuit = /obj/item/circuitboard/machine/anti_air
	var/gunning_component_type = /datum/component/overmap_gunning/anti_air
	var/mob/living/gunner

/obj/machinery/ship_weapon/anti_air/examine(mob/user)
	. = ..()
	. += "<span class ='notice'>It has [get_ammo()]/[get_max_ammo()] rounds loaded.</span>"


/obj/machinery/ship_weapon/anti_air/heavy
	name = "\improper HAA turret"
	desc = "For when you need more bullets spat out more quickly."
	icon_state = "deck_gun_super"
	circuit = /obj/item/circuitboard/machine/anti_air/heavy
	gunning_component_type = /datum/component/overmap_gunning/anti_air/heavy

/obj/machinery/ship_weapon/anti_air/proc/start_gunning(mob/user)
	if(gunner)
		remove_gunner()
	gunner = user
	user.AddComponent(gunning_component_type, src, TRUE)

/obj/machinery/ship_weapon/anti_air/proc/remove_gunner()
	get_overmap().stop_piloting(gunner)

//Unifying component for gauss / 50 cal gunning
/datum/component/overmap_gunning
	var/fire_mode = FIRE_MODE_GAUSS
	var/automatic = FALSE
	var/mob/living/holder = null
	var/atom/movable/autofire_target
	var/next_fire = 0
	var/fire_delay = 2 SECONDS
	var/obj/machinery/ship_weapon/fx_target = null
	var/special_fx = FALSE

/datum/component/overmap_gunning/anti_air
	fire_mode = FIRE_MODE_ANTI_AIR
	fire_delay = 0.25 SECONDS
	automatic = TRUE

/datum/component/overmap_gunning/anti_air/heavy
	fire_mode = FIRE_MODE_ANTI_AIR
	fire_delay = 0.1 SECONDS

/datum/component/overmap_gunning/Initialize(obj/machinery/ship_weapon/fx_target)
	. = ..()
	if(!istype(parent, /mob/living)) //Needs at least this base prototype.
		return COMPONENT_INCOMPATIBLE
	src.fx_target = fx_target
	holder = parent
	start_gunning()

/datum/component/overmap_gunning/proc/apply_settings(special_fx=FALSE, automatic=FALSE) //Until we have named variables, this should work
	if(!isnull(special_fx))
		src.special_fx = special_fx
	if(!isnull(automatic))
		src.automatic = automatic

/datum/component/overmap_gunning/proc/start_gunning()
	var/obj/structure/overmap/OM = holder.loc.get_overmap()
	if(!OM)
		RemoveComponent() //Uh...OK?
		CRASH("Overmap gunning component created with no attached overmap.")
	OM.gauss_gunners.Add(holder)
	OM.start_piloting(holder, OVERMAP_USER_ROLE_SECONDARY_GUNNER)
	if(automatic)
		START_PROCESSING(SSfastprocess, src)

/datum/component/overmap_gunning/proc/onClick(atom/movable/target, location, params)
	if(!autofire_target)
		autofire_target = target //When we start firing, we start firing at whatever you clicked on initially. When the user drags their mouse, this shall change.
	if(world.time < next_fire || !autofire_target)
		return FALSE
	var/obj/structure/overmap/OM = holder.loc.get_overmap()
	next_fire = world.time + fire_delay
	if(special_fx)
		fx_target.setDir(get_dir(OM, target))  //Makes the gun turn and shoot the target, wow!
	fx_target.fire(target)//You can only fire your gun, not someone else's.   //.fire_weapon(target, fire_mode)

/datum/component/overmap_gunning/process()
	if(!autofire_target || !automatic)
		return
	onClick(autofire_target)

/datum/component/overmap_gunning/proc/onMouseUp(object, location, params, mob)
	autofire_target = null

/datum/component/overmap_gunning/proc/onMouseDown(object, location, params)
	if(!autofire_target)
		autofire_target = object //When we start firing, we start firing at whatever you clicked on initially. When the user drags their mouse, this shall change.

/datum/component/overmap_gunning/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	. = ..()
	autofire_target = over_object

/datum/component/overmap_gunning/proc/end_gunning()
	autofire_target = null
	var/obj/structure/overmap/OM = holder.loc.get_overmap()
	OM.gauss_gunners.Remove(holder)
	STOP_PROCESSING(SSfastprocess, src)
	var/obj/machinery/ship_weapon/gauss_gun/G = holder.loc
	if(istype(G))
		G.remove_gunner()
	RemoveComponent()
	return

/obj/machinery/computer/anti_air
	name = "anti-air turret console"
	desc = "A computer that allows you to control an anti-air turret, when paired with a compatible turret directly above deck."
	icon_screen = "50cal"
	circuit = /obj/item/circuitboard/computer/anti_air
	var/obj/machinery/ship_weapon/anti_air/turret

/obj/machinery/computer/anti_air/examine(mob/user)
	. = ..()
	. += "<span class ='notice'>Its ammo counter reads [turret.get_ammo()]/[turret.get_max_ammo()]. </span>"

/obj/machinery/computer/anti_air/Initialize(mapload)
	. = ..()
	turret = locate(/obj/machinery/ship_weapon/anti_air) in SSmapping.get_turf_above(src)

/obj/machinery/computer/anti_air/attack_robot(mob/user)
	. = ..()
	return attack_hand(user)

/obj/machinery/computer/anti_air/attack_ai(mob/user)
	. = ..()
	return attack_hand(user)

/obj/machinery/computer/anti_air/multitool_act(mob/living/user, obj/item/multitool/I)
	..()
	. = TRUE
	turret = locate(/obj/machinery/ship_weapon/anti_air) in SSmapping.get_turf_above(src)
	if ( turret )
		to_chat(user, "<span class='warning'>Successfully linked [src] to [turret].")
	else
		to_chat(user, "<span class='warning'>Unable to locate a compatible turret above this deck! Try relocating the turret construction.")

/obj/machinery/computer/anti_air/attack_hand(mob/user)
	. = ..()
	if(!turret)
		to_chat(user, "<span class='warning'>This computer is not linked to a gun turret! You can link it with a multitool.</span>")
		return
	turret.start_gunning(user)
