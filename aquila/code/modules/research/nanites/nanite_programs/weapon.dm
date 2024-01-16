/datum/nanite_program/kunai
	name = "Kunai Form"
	desc = "When triggered, nanites attempt to gather in host's free hand, forming a Kunai knife, which disintegrates a few seconds after being thrown."
	can_trigger = TRUE
	trigger_cost = 100
	trigger_cooldown = 50
	rogue_types = list(/datum/nanite_program/skin_decay)

/datum/nanite_program/kunai/on_trigger(comm_message)
	var/obj/item/throwing_star/nanite/N = new(get_turf(host_mob))
	if(!iscarbon(host_mob))
		to_chat(host_mob, "<span class='notice'>A kunai suddenly appears below you!</span>")
		return
	var/mob/living/carbon/C = host_mob
	if(!C.put_in_hands(N))
		to_chat(C, "<span class='notice'>A kunai suddenly appears below you!</span>")
		return
	to_chat(C, "<span class='notice'>A kunai suddenly appears in your hand!</span>")

/datum/nanite_program/nanophage
	name = "Nano Swarm"
	desc = "When triggered, nanites gather in host's stomach, forming nanophages - small, pre-programmed drones, then quickly get coughed out."
	can_trigger = TRUE
	trigger_cost = 100
	trigger_cooldown = 300
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/nanophage/register_extra_settings()
	. = ..()
	extra_settings[NES_HOST_AGGRESSION] = new /datum/nanite_extra_setting/boolean(TRUE, "True", "False")

/datum/nanite_program/nanophage/on_trigger(comm_message)
	host_mob.visible_message("<span class='danger'>[host_mob] throws up a swarm of nanophages!</span>", \
					"<span class='userdanger'>You throw up a swarm of nanophages!</span>")
	playsound(host_mob, 'aquila/sound/misc/nanobirth.ogg', 50)

	var/list/factions = list()

	if(!extra_settings[NES_HOST_AGGRESSION].get_value())
		factions = host_mob.faction.Copy() //copypasta z dehydrated carpa. sprawdźmy czy zadziała
		for(var/F in factions)
			if(F == "neutral")
				factions -= F

	for(var/i in 1 to 8)
		var/mob/living/simple_animal/hostile/nanophage/nano = new /mob/living/simple_animal/hostile/nanophage(get_turf(host_mob))
		step(nano, pick(NORTH,SOUTH,EAST,WEST))
		if(!extra_settings[NES_HOST_AGGRESSION].get_value())
			nano.faction = factions
