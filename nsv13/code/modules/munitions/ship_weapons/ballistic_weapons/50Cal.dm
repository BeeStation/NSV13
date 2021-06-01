//The .50 cal! A neat crew served weapon which replaces PDC.
/obj/machinery/ship_weapon/fiftycal
	name = ".50 cal autocannon"
	desc = "A formidable weapon operated by a gunner below deck, extremely effective at point defense though they struggle to damage larger targets."
	icon = 'nsv13/icons/obj/munitions/deck_gun.dmi'
	icon_state = "deck_gun"
	magazine_type = /obj/item/ammo_box/magazine/pdc/fiftycal
	safety = FALSE
	auto_load = TRUE
	semi_auto = TRUE
	maintainable = FALSE
	fire_mode = FIRE_MODE_50CAL
	max_ammo = 200
	circuit = /obj/item/circuitboard/machine/fiftycal
	var/gunning_component_type = /datum/component/overmap_gunning/fiftycal
	var/mob/living/gunner

/obj/machinery/ship_weapon/fiftycal/examine(mob/user)
	. = ..()
	. += "<span class ='notice'>It has [get_ammo()]/[get_max_ammo()] rounds loaded.</span>"


/obj/machinery/ship_weapon/fiftycal/super
	name = ".50 cal super pom pom turret"
	desc = "For when you need more bullets spat out more quickly."
	icon_state = "deck_gun_super"
	circuit = /obj/item/circuitboard/machine/fiftycal/super
	gunning_component_type = /datum/component/overmap_gunning/fiftycal/super

/obj/machinery/ship_weapon/fiftycal/proc/start_gunning(mob/user)
	if(gunner)
		remove_gunner()
	gunner = user
	user.AddComponent(gunning_component_type, src, TRUE)

/obj/machinery/ship_weapon/fiftycal/proc/remove_gunner()
	get_overmap().stop_piloting(gunner)

//Unifying component for gauss / 50 cal gunning
/datum/component/overmap_gunning
	var/fire_mode = FIRE_MODE_GAUSS
	var/mob/living/holder = null
	var/atom/movable/autofire_target
	var/next_fire = 0
	var/fire_delay = 2 SECONDS
	var/obj/machinery/ship_weapon/fx_target = null
	var/special_fx = FALSE

/datum/component/overmap_gunning/fiftycal
	fire_mode = FIRE_MODE_50CAL
	fire_delay = 0.25 SECONDS

/datum/component/overmap_gunning/fiftycal/super
	fire_mode = FIRE_MODE_50CAL
	fire_delay = 0.1 SECONDS

/datum/component/overmap_gunning/Initialize(obj/machinery/ship_weapon/fx_target, special_fx=FALSE)
	. = ..()
	if(!istype(parent, /mob/living)) //Needs at least this base prototype.
		return COMPONENT_INCOMPATIBLE
	src.special_fx = special_fx
	src.fx_target = fx_target
	holder = parent
	start_gunning()

/datum/component/overmap_gunning/proc/start_gunning()
	var/obj/structure/overmap/OM = holder.loc.get_overmap()
	if(!OM)
		RemoveComponent() //Uh...OK?
		CRASH("Overmap gunning component created with no attached overmap.")
	OM.gauss_gunners.Add(holder)
	OM.start_piloting(holder, "secondary_gunner")
	START_PROCESSING(SSfastprocess, src)

/datum/component/overmap_gunning/proc/onClick(atom/movable/target)
	if(world.time < next_fire || !autofire_target)
		return FALSE
	var/obj/structure/overmap/OM = holder.loc.get_overmap()
	next_fire = world.time + fire_delay
	if(special_fx)
		fx_target.setDir(get_dir(OM, target))  //Makes the gun turn and shoot the target, wow!
	fx_target.fire(target)//You can only fire your gun, not someone else's.   //.fire_weapon(target, fire_mode)

/datum/component/overmap_gunning/process()
	if(!autofire_target)
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

/obj/machinery/computer/fiftycal
	name = ".50 cal autocannon console"
	desc = "A computer that allows you to control a .50 cal deck gun, when paired with a turret above deck."
	icon_screen = "50cal"
	circuit = /obj/item/circuitboard/computer/fiftycal
	var/obj/machinery/ship_weapon/fiftycal/turret

/obj/machinery/computer/fiftycal/examine(mob/user)
	. = ..()
	. += "<span class ='notice'>Its ammo counter reads [turret.get_ammo()]/[turret.get_max_ammo()]. </span>"

/obj/machinery/computer/fiftycal/Initialize()
	. = ..()
	turret = locate(/obj/machinery/ship_weapon/fiftycal) in SSmapping.get_turf_above(src)

/obj/machinery/computer/fiftycal/attack_robot(mob/user)
	. = ..()
	return attack_hand(user)

/obj/machinery/computer/fiftycal/attack_ai(mob/user)
	. = ..()
	return attack_hand(user)

/obj/machinery/computer/fiftycal/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if(!istype(I))
		return FALSE
	if(I.buffer && istype(I.buffer, /obj/machinery/ship_weapon/fiftycal))
		turret = I.buffer
		to_chat(user, "<span class='warning'>Successfully linked [src] to [I.buffer].")
		I.buffer = null

/obj/machinery/computer/fiftycal/attack_hand(mob/user)
	. = ..()
	if(!turret)
		to_chat(user, "<span class='warning'>This computer is not linked to a gun turret! You can link it with a multitool.</span>")
		return
	turret.start_gunning(user)

/obj/item/ammo_box/magazine/pdc/fiftycal
	name = "50 caliber rounds"
	ammo_type = /obj/item/ammo_casing/fiftycal
	caliber = "mm50pdc"
	max_ammo = 200

/obj/item/ammo_box/magazine/pdc/fiftycal/examine(mob/user)
	. = ..()
	. += "<span class ='notice'>It has [ammo_count()] bullets left.</span>"

/obj/item/ammo_box/magazine/pdc/fiftycal/update_icon()
	if(ammo_count() > 10)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_empty"

/obj/item/ammo_casing/fiftycal
	name = "50mm round casing"
	desc = "A 50mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/fiftycal
	caliber = "mm50pdc"

/obj/item/projectile/bullet/fiftycal
	icon_state = "50cal"
	name = ".50 cal round"
	damage = 17
	flag = "overmap_light"
	speed = 2
