/obj/item/ship_weapon/ammunition/torpedo //CREDIT TO CM FOR THIS SPRITE
	name = "\improper NTP-2 530mm torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "standard"
	desc = "A fairly standard torpedo which is designed to cause massive structural damage to a target. It is fitted with a basic homing mechanism to ensure it always hits the mark."
	density = TRUE
	climbable = TRUE //No shenanigans
	climb_time = 40
	climb_stun = 5
	w_class = WEIGHT_CLASS_GIGANTIC
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	interaction_flags_item = 0 // -INTERACT_ITEM_ATTACK_HAND_PICKUP
	projectile_type = /obj/item/projectile/guided_munition/torpedo //What torpedo type we fire
	pixel_x = -17
	volatility = 3 //Very volatile.
	explode_when_hit = TRUE //Yeah, this can't ever end well for you.
	var/claimable_gulag_points = 75

/obj/item/ship_weapon/ammunition/torpedo/examine(mob/user)
	. = ..()
	if(claimable_gulag_points)
		. += "<span class='notice'>It has [claimable_gulag_points] unclaimed gulag reward points!</span>"

/obj/item/ship_weapon/ammunition/torpedo/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/card/id/gulag))
		var/obj/item/card/id/gulag/P = I
		P.points += claimable_gulag_points
		to_chat(user, "<span class='boldnotice'>You claim [claimable_gulag_points] from [src]... Your balance is now: [P.points]</span>")
		//This one's been claimed!
		claimable_gulag_points = 0

/obj/item/ship_weapon/ammunition/torpedo/examine(mob/user)
	. = ..()
	. += "<span class='warning'>It's far too cumbersome to carry, and dragging it around might set it off!</span>"

/obj/item/ship_weapon/ammunition/torpedo/attack_hand(mob/user)
	return FALSE

//High damage torp. Use this when youve exhausted their flak.
/obj/item/ship_weapon/ammunition/torpedo/hull_shredder
	name = "\improper NTP-4 'BNKR' 430mm Armour Pentetrating Torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "hull_shredder"
	desc = "A heavy torpedo which is enriched with depleted uranium, allowing it to penetrate heavy armour plates."
	projectile_type = /obj/item/projectile/guided_munition/torpedo/shredder

//A dud missile designed to exhaust flak
/obj/item/ship_weapon/ammunition/torpedo/decoy
	name = "\improper NTP-0x 'DCY' 530mm electronic countermeasure"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "decoy"
	desc = "A simple electronic countermeasure packed inside a standard torpedo casing. This model excels at diverting enemy PDC emplacements away from friendly ships, or even another barrage of missiles."
	projectile_type = /obj/item/projectile/guided_munition/torpedo/decoy

/obj/item/ship_weapon/ammunition/torpedo/hellfire
	name = "\improper NTP-6 'HLLF' 600mm Plasma Incendiary Torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "incendiary"
	desc = "A plasma enriched incendiary torpedo, designed for maximum subsystem damage."
	projectile_type = /obj/item/projectile/guided_munition/torpedo/hellfire/player_version
	volatile_type = /datum/component/volatile/helltorp
	volatility = 4

/obj/item/ship_weapon/ammunition/torpedo/plushtide
	name = "\improper NTP-00 'FREN' 600mm emotional support torpedo"
	icon_state = "plush"
	desc = "A simple torpedo with a frankly concerning amount of plushies crammed into it. For when what your enemy needs really is just a hug."
	projectile_type = /obj/item/projectile/guided_munition/torpedo/plushtide
	volatility = 0

/obj/item/ship_weapon/ammunition/torpedo/plushtide/attack_hand(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(living_user.a_intent != INTENT_HELP)
		return
	living_user.visible_message("<span class='notice'>[living_user] hugs [src].</span>","<span class='notice'>You hug [src].</span>")
	playsound(src, pick('sound/items/toysqueak1.ogg', 'sound/items/toysqueak2.ogg', 'sound/items/toysqueak3.ogg'), 30, 1, -1)
	SEND_SIGNAL(living_user, COMSIG_ADD_MOOD_EVENT, "torphug", /datum/mood_event/torphug)

/obj/item/ship_weapon/ammunition/torpedo/proto_disruption
	name = "\improper NTP-I1x 'EMP' 400mm Disruption Torpedo"
	icon_state = "disruption"
	desc = "A torpedo with an EMP payload designed for wreaking havoc in ship electronics."
	projectile_type = /obj/item/projectile/guided_munition/torpedo/disruptor/prototype
	volatility = 2
	volatile_type = /datum/component/volatile/emptorp

/* Retired for the moment, this will return in a new flavour
//The alpha torpedo
/obj/item/ship_weapon/ammunition/torpedo/nuke
	name = "\improper NTNK 'Oncoming Storm' 700mm thermonuclear warhead"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "nuke"
	desc = "The NTX-class IV nuclear torpedo carries a fissionable payload which is capable of inflicting catastrophic damage against enemy ships, stations or dense population centers. These weapons are utterly without mercy and will annihilate indiscriminately, use with EXTREME caution."
	projectile_type = /obj/item/projectile/guided_munition/torpedo/nuclear
	volatility = 5
*/

/obj/item/ship_weapon/ammunition/torpedo/hellfire/antonio
	name = "Antonio"

/obj/item/ship_weapon/ammunition/torpedo/hellfire/antonio/examine(mob/user)
	.=..()
	. += "<span class='notice'> This is Antonio, the MAA's loyal companion.</span>"

/obj/item/ship_weapon/ammunition/torpedo/hellfire/fabio
	name = "Fabio"

/obj/item/ship_weapon/ammunition/torpedo/hellfire/fabio/examine(mob/user)
	.=..()
	. += "<span class='notice'> This is Fabio, Antonio's Evil Brother.</span>"

/obj/item/ship_weapon/ammunition/torpedo/freight
	name = "\improper NTP-F 530mm freight torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "post_pod"
	desc = "A letterbox with engines strapped to it and plenty of space inside. Designed as a quick and lazy way to deliver supplies to an allied ship."
	projectile_type = /obj/item/projectile/guided_munition/torpedo/post
	var/max_stuff = 4 //Maximum amount of stuff that we can cram into it
	var/breaking_out = FALSE

/obj/item/ship_weapon/ammunition/torpedo/freight/crowbar_act(mob/living/user, obj/item/I)
	if(!contents?.len)
		to_chat(user, "<span class='warning'>[src] has nothing loaded in it!</span>")
		return FALSE
	if(do_after(user, 5 SECONDS, target = src))
		to_chat(user, "<span class='warning'>You pry [src] open!</span>")
		for(var/atom/X in contents)
			unload(X)
	return FALSE

/obj/item/ship_weapon/ammunition/torpedo/freight/MouseDrop_T(atom/dropping, mob/user)
	. = ..()
	if(!isliving(user))
		return FALSE
	try_load(dropping, user)

/obj/item/ship_weapon/ammunition/torpedo/freight/proc/try_load(atom/movable/what, mob/user)
	if(length(contents) >= max_stuff)
		to_chat(user, "<span class='warning'>[src] is already full!</span>")
		return
	if(isturf(what) || what.anchored || what.move_resist > user.move_force)
		to_chat(user, "<span class='warning'>[what] is too heavy for you to lift into [src]!</span>")
		return
	visible_message("<span class='danger'>[user] starts to stuff [what] into [src]!</span>",\
		"<span class='italics'>You start to stuff [user] into [src]...</span>")
	if(do_after(user, 5 SECONDS, target = src))
		if(length(contents) >= max_stuff)
			to_chat(user, "<span class='warning'>[src] is already full!</span>")
			return
		if(isitem(what))
			if(!user.transferItemToLoc(what, src))
				return FALSE
		else
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

/obj/item/projectile/guided_munition/torpedo/post
	name = "freight torpedo"
	icon_state = "torpedo_post"
	homing_turn_speed = 0
	damage = 0

/obj/item/projectile/guided_munition/torpedo/post/windup() // As we can not lock onto a target, this just causes the torp to do a 180.
	return

/obj/item/projectile/guided_munition/torpedo/post/proc/foo()
	new /mob/living/carbon/human(src)
	for(var/obj/structure/overmap/OM in orange(5, src))
		var/angle = get_angle(src, OM)
		setup_collider()
		fire(angle)

/obj/item/projectile/guided_munition/torpedo/post/check_faction(atom/movable/A)
	var/obj/structure/overmap/OM = A
	if(!istype(OM))
		return TRUE
	if(OM != overmap_firer)
		deliver_freight(OM) //Bang.
		qdel(src)
		return TRUE

/obj/structure/closet/supplypod/freight_pod
	name = "Freight pod"
	explosionSize = list(0,0,0,0)

/obj/item/projectile/guided_munition/torpedo/post/proc/deliver_freight(obj/structure/overmap/OM)
	var/area/landingzone = null
	for(var/atom/a in GetAllContents()) //Send the cargo signal to our contents
		SEND_SIGNAL(OM, COMSIG_CARGO_DELIVERED, a)
	if(OM.role == MAIN_OVERMAP)
		landingzone = GLOB.areas_by_type[/area/quartermaster/warehouse]
	else
		if(!OM.linked_areas.len) // The cargo is now lost. clean it up
			qdel(src)
			return
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
	var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/supplypod_temp_holding]
	toLaunch.forceMove(shippingLane)
	for(var/atom/movable/O in contents)
		O.forceMove(toLaunch) //forceMove any atom/moveable into the supplypod
		new /obj/effect/pod_landingzone(LZ, toLaunch)
	qdel(src)

/obj/item/projectile/guided_munition/torpedo/post/Destroy()
	if(contents.len)
		var/list/all_contents = GetAllContents() - src //Get all contents returns the torp itself. remove the torp from the list
		QDEL_LIST(all_contents) //Delete all contents of the torp.
	. = ..()

//A probe that science builds to scan anomalies. This is a chad move.
/obj/item/ship_weapon/ammunition/torpedo/probe
	name = "\improper NTX 'Voyager' astrological probe"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "probe"
	desc = "A chemically propelled probe with a highly sensitive avionics and sensor package at its nosecone. These probes are able to scan astrological phenomena and relay data back to a remote location."
	projectile_type = /obj/item/projectile/bullet/torpedo/probe

/obj/item/projectile/bullet/torpedo/probe
	icon_state = "probe"
	damage = 5
