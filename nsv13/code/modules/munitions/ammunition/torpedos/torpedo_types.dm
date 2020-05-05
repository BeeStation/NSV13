/obj/item/ship_weapon/ammunition/torpedo //CREDIT TO CM FOR THIS SPRITE
	name = "NTP-2 530mm torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "standard"
	desc = "A fairly standard torpedo which is designed to cause massive structural damage to a target. It is fitted with a basic homing mechanism to ensure it always hits the mark."
	anchored = TRUE
	density = TRUE
	projectile_type = /obj/item/projectile/bullet/torpedo //What torpedo type we fire
	pixel_x = -17
	var/speed = 1 //Placeholder, allows upgrading speed with better propulsion

/obj/item/ship_weapon/ammunition/torpedo/CtrlClick(mob/user)
	. = ..()
	to_chat(user,"<span class='warning'>[src] is far too cumbersome to carry, and dragging it around might set it off! Load it onto a munitions trolley.</span>")

/obj/item/ship_weapon/ammunition/torpedo/examine(mob/user)
	. = ..()
	. += "<span class='warning'>It's far too cumbersome to carry, and dragging it around might set it off!</span>"

//High damage torp. Use this when youve exhausted their flak.
/obj/item/ship_weapon/ammunition/torpedo/hull_shredder
	name = "NTP-4 'BNKR' 430mm torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "hull_shredder"
	desc = "A heavy torpedo which is packed with a high energy plasma charge, allowing it to impact a target with massive force."
	projectile_type = /obj/item/projectile/bullet/torpedo/shredder

/obj/item/projectile/bullet/torpedo/shredder
	icon_state = "torpedo_shredder"
	name = "plasma charge"
	damage = 120

//Gap closer, weaker but quick.
/obj/item/ship_weapon/ammunition/torpedo/fast
	name = "NTP-1 'SPD' 430mm high velocity torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "highvelocity"
	desc = "A small torpedo which is fitted with an advanced propulsion system, allowing it to rapidly travel long distances. Due to its smaller frame however, it packs less of a punch."
	projectile_type = /obj/item/projectile/bullet/torpedo/fast
	speed = 3

/obj/item/projectile/bullet/torpedo/fast
	icon_state = "torpedo_fast"
	name = "high velocity torpedo"
	damage = 40

//A dud missile designed to exhaust flak
/obj/item/ship_weapon/ammunition/torpedo/decoy
	name = "NTP-0x 'DCY' 530mm electronic countermeasure"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "decoy"
	desc = "A simple electronic countermeasure packed inside a standard torpedo casing. This model excels at diverting enemy PDC emplacements away from friendly ships, or even another barrage of missiles."
	projectile_type = /obj/item/projectile/bullet/torpedo/decoy
	speed = 2

/obj/item/projectile/bullet/torpedo/decoy
	icon_state = "torpedo"
	damage = 0

//The alpha torpedo
/obj/item/ship_weapon/ammunition/torpedo/nuke
	name = "NTNK 'Oncoming Storm' 700mm thermonuclear warhead"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "nuke"
	desc = "The NTX-class IV nuclear torpedo carries a radiological payload which is capable of inflicting catastrophic damage against enemy ships, stations or dense population centers. These weapons are utterly without mercy and will annihilate indiscriminately, use with EXTREME caution."
	projectile_type = /obj/item/projectile/bullet/torpedo/nuclear

/obj/item/projectile/bullet/torpedo/nuclear
	icon_state = "torpedo_nuke"
	name = "thermonuclear cruise missile"
	damage = 300
	impact_effect_type = /obj/effect/temp_visual/nuke_impact
	shotdown_effect_type = /obj/effect/temp_visual/nuke_impact

//What you get from an incomplete torpedo.
/obj/item/projectile/bullet/torpedo/dud
	icon_state = "torpedo_dud"
	damage = 0

/obj/item/ship_weapon/ammunition/torpedo/freight
	name = "NTP-F 530mm freight torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "post_pod"
	desc = "A letterbox with engines strapped to it and plenty of space inside. Designed as a quick and lazy way to deliver supplies to an allied ship."
	projectile_type = /obj/item/projectile/bullet/torpedo/post
	speed = 1
	var/max_stuff = 4 //Maximum amount of stuff that we can cram into it
	var/breaking_out = FALSE

/obj/item/ship_weapon/ammunition/torpedo/freight/MouseDrop_T(atom/dropping, mob/user)
	. = ..()
	try_load(dropping, user)

/obj/item/ship_weapon/ammunition/torpedo/freight/proc/try_load(atom/movable/what, mob/user)
	if(contents?.len >= max_stuff)
		to_chat(user, "<span class='warning'>[src] is already full!</span>")
		return
	if(what.anchored || what.move_resist > user.move_force)
		to_chat(user, "<span class='warning'>[what] is too heavy for you to lift into [src]!</span>")
		return
	if(do_after(user, 5 SECONDS, target = src))
		what.forceMove(src)
		icon_state = "[initial(icon_state)]_[contents.len]"

/obj/item/ship_weapon/ammunition/torpedo/freight/proc/unload(atom/movable/what)
	what.forceMove(get_turf(src))
	icon_state = "[initial(icon_state)]_[contents.len]"

/obj/item/ship_weapon/ammunition/torpedo/freight/relaymove(mob/living/user, direction)
	if(!breaking_out)
		to_chat(user, "<span class='warning'>You start frantically shaking to try and escape [src]!</span>")
		var/offset = prob(50) ? -2 : 2
		animate(src, pixel_x = pixel_x + offset, time = 4 SECONDS) //start shaking
		addtimer(VARSET_CALLBACK(src, pixel_x, initial(pixel_x)))
		breaking_out = TRUE
		if (do_after(user, 8 SECONDS , target = src))
			user.forceMove(get_turf(src))
			visible_message("<span class='notice'>[user] breaks open [src]!</span>")
			unload(user)
			shake_animation()
		breaking_out = FALSE
	else
		return FALSE //You can't move a torp from the inside :b1:

/obj/item/projectile/bullet/torpedo/post
	icon_state = "torpedo_post"
//	mouse_opacity = TRUE
	damage = 0

/obj/item/projectile/bullet/torpedo/post/Initialize()
	. = ..()

/obj/item/projectile/bullet/torpedo/post/proc/foo()
	new /mob/living/carbon/human(src)
	for(var/obj/structure/overmap/OM in orange(5, src))
		if(istype(OM))
			var/angle = Get_Angle(src, OM)
			setup_collider()
			fire(angle)

/obj/item/projectile/bullet/torpedo/post/check_overmap_collisions()
	collider2d.set_angle(Angle) //Turn the box collider
	position._set(x * 32 + pixel_x, y * 32 + pixel_y)
	collider2d._set(position.x, position.y)
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z == z && OM.collider2d)
			if(src.collider2d.collides(OM.collider2d))
				if(OM != overmap_firer)
					deliver_freight(OM) //Bang.

/obj/structure/closet/supplypod/freight_pod
	name = "Freight pod"
	explosionSize = list(0,0,0,0)

/obj/item/projectile/bullet/torpedo/post/proc/deliver_freight(obj/structure/overmap/OM)
	var/area/landingzone = null
	if(OM.role == MAIN_OVERMAP)
		landingzone = GLOB.areas_by_type[/area/quartermaster/storage]
	else
		if(!OM.linked_areas.len)
			return FALSE
		landingzone = pick(OM.linked_areas)
	var/list/empty_turfs = list()
	var/turf/LZ = null
	for(var/turf/open/floor/T in landingzone.contents)//uses default landing zone
		if(is_blocked_turf(T))
			continue
		LAZYADD(empty_turfs, T)
		CHECK_TICK
	if(empty_turfs?.len)
		LZ = pick(empty_turfs)
	var/obj/structure/closet/supplypod/freight_pod/toLaunch = new /obj/structure/closet/supplypod/freight_pod
	var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/flyMeToTheMoon]
	toLaunch.forceMove(shippingLane)
	for (var/atom/movable/O in contents)
		O.forceMove(toLaunch) //forceMove any atom/moveable into the supplypod
		new /obj/effect/DPtarget(LZ, toLaunch)
	qdel(src)

//A probe that science builds to scan anomalies. This is a chad move.
/obj/item/ship_weapon/ammunition/torpedo/probe
	name = "NTX 'Voyager' astrological probe"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "probe"
	desc = "A chemically propelled probe with a highly sensitive avionics and sensor package at its nosecone. These probes are able to scan astrological phenomena and relay data back to a remote location."
	projectile_type = /obj/item/projectile/bullet/torpedo/probe

/obj/item/projectile/bullet/torpedo/probe
	icon_state = "probe"
	damage = 5