

/datum/outfit/syndicate/no_crystals
	implants = list()

/datum/outfit/syndicate/no_crystals/syndi_crew
	name = "Syndicate crewmate"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	suit = /obj/item/clothing/suit/ship/syndicate_crew
	uniform = /obj/item/clothing/under/ship/pilot/syndicate
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black

/obj/item/pvp_nuke_spawner
	name = "Nuclear summon device"
	desc = "A small device that will summon the Hammurabi's nuclear warhead to your location. Click it in your hand to use it."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-green"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	req_one_access_txt = "150"

/obj/item/pvp_nuke_spawner/attack_self(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!is_station_level(user.z))
		to_chat(user, "<span class='notice'>A message crackles in your ear: Operative. You have not yet reached [station_name()], ensure you are on the enemy ship before you attempt to summon a nuke.</span>")
		return
	if(alert("Are you sure you want to summon a nuke to your location?",name,"Yes","No") == "Yes")
		to_chat(user, "<span class='notice'>You press a button on [src] and a nuke appears.</span>")
		var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in GLOB.nuke_list
		nuke.visible_message("<span class='warning'>[src] fizzles out of existence!</span>")
		nuke?.forceMove(get_turf(user))
		do_sparks(1, TRUE, src)
		qdel(src)

/datum/antagonist/nukeop/syndi_crew/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.syndi_crew_spawns))

/datum/antagonist/nukeop/leader/syndi_crew/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.syndi_crew_leader_spawns))

/obj/effect/landmark/start/nukeop/syndi_crew
	name = "Syndicate crew"

/obj/effect/landmark/start/nukeop/syndi_crew/Initialize()
	..()
	GLOB.syndi_crew_spawns += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop/syndi_crew_leader
	name = "Syndicate captain"

/obj/effect/landmark/start/nukeop/syndi_crew_leader/Initialize()
	..()
	GLOB.syndi_crew_leader_spawns += loc
	return INITIALIZE_HINT_QDEL
