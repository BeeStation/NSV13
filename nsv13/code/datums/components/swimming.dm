//Component used to show that a mob is swimming, and force them to swim a lil' bit slower. Components are actually really based!

/datum/component/swimming
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/lengths = 0 //How far have we swum?
	var/lengths_for_bonus = 25 //If you swim this much, you'll count as having "excercised" and thus gain a buff.
	var/list/species = list()
	var/drowning = FALSE
	var/ticks_drowned = 0
	var/slowdown = 4
	var/bob_height_min = 2
	var/bob_height_max = 5
	var/bob_tick = 0

/datum/component/swimming/Initialize()
	. = ..()
	if(!isliving(parent))
		message_admins("Swimming component erroneously added to a non-living mob ([parent]).")
		return INITIALIZE_HINT_QDEL //Only mobs can swim, like Ian...
	var/mob/M = parent
	M.visible_message("<span class='notice'>[parent] starts splashing around in the water!</span>")
	M.add_movespeed_modifier(MOVESPEED_ID_SWIMMING, update=TRUE, priority=50, multiplicative_slowdown=slowdown, movetypes=GROUND)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/onMove)
	RegisterSignal(parent, COMSIG_CARBON_SPECIESCHANGE, .proc/onChangeSpecies)
	RegisterSignal(parent, COMSIG_MOB_ATTACK_HAND_TURF, .proc/try_leave_pool)
	START_PROCESSING(SSprocessing, src)
	enter_pool()

/datum/component/swimming/proc/onMove()
	lengths ++
	if(lengths > lengths_for_bonus)
		var/mob/living/L = parent
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "exercise", /datum/mood_event/exercise)
		L.apply_status_effect(STATUS_EFFECT_EXERCISED) //Swimming is really good excercise!
		lengths = 0

//Damn edge cases
/datum/component/swimming/proc/onChangeSpecies()
	var/mob/living/carbon/C = parent
	var/component_type = /datum/component/swimming
	if(istype(C))
		if(C.dna.species.type in GLOB.species_swimming_components)
			component_type = GLOB.species_swimming_components[C.dna.species.type]
		else if(iscatperson(C))	//Why is this not it's own species, that is really annoying
			component_type = /datum/component/swimming/felinid
	var/mob/M = parent
	RemoveComponent()
	M.AddComponent(component_type)

/datum/component/swimming/proc/try_leave_pool(datum/source, turf/clicked_turf)
	var/mob/living/L = parent
	if(!L.can_interact_with(clicked_turf))
		return
	if(is_blocked_turf(clicked_turf))
		return
	if(istype(clicked_turf, /turf/open/indestructible/sound/pool))
		return
	to_chat(parent, "<span class='notice'>You start to climb out of the pool...</span>")
	if(do_after(parent, 1 SECONDS, target=clicked_turf))
		L.forceMove(clicked_turf)
		L.visible_message("<span class='notice'>[parent] climbs out of the pool.</span>")
		RemoveComponent()

/datum/component/swimming/UnregisterFromParent()
	exit_pool()
	var/mob/M = parent
	if(drowning)
		stop_drowning(M)
	if(bob_tick)
		M.pixel_y = 0
	M.remove_movespeed_modifier(MOVESPEED_ID_SWIMMING)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_CARBON_SPECIESCHANGE)
	UnregisterSignal(parent, COMSIG_MOB_ATTACK_HAND_TURF)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/component/swimming/process()
	var/mob/living/L = parent
	var/floating = FALSE
	var/obj/item/helditem = L.get_active_held_item()
	if(helditem && helditem.check_float())
		bob_tick ++
		animate(L, time=9.5, pixel_y = (L.pixel_y == bob_height_max) ? bob_height_min : bob_height_max)
		floating = TRUE
	else
		if(bob_tick)
			animate(L, time=5, pixel_y = 0)
			bob_tick = 0
	if(!floating && is_drowning(L))
		if(!drowning)
			start_drowning(L)
			drowning = TRUE
		drown(L)
	else
		if(drowning)
			stop_drowning(L)
			drowning = FALSE
	L.adjust_fire_stacks(-1)

/datum/component/swimming/proc/is_drowning(mob/living/victim)
	var/obj/item/helditem = victim.get_active_held_item()
	if(helditem)
		if(!helditem.check_float())
			return
	return ((!(victim.mobility_flags & MOBILITY_STAND)) && (!HAS_TRAIT(victim, TRAIT_NOBREATH)))

/datum/component/swimming/proc/drown(mob/living/victim)
	if(victim.losebreath < 1)
		victim.losebreath += 1
	ticks_drowned ++
	if(prob(20))
		victim.emote("cough")
	else if(prob(25))
		victim.emote("gasp")
	if(ticks_drowned > 20)
		if(prob(10))
			victim.visible_message("<span class='warning'>[victim] falls unconcious for a moment!</span>")
			victim.Unconscious(10)

/datum/component/swimming/proc/start_drowning(mob/living/victim)
	to_chat(victim, "<span class='userdanger'>Water fills your lungs and mouth, you can't breathe!</span>")
	ADD_TRAIT(victim, TRAIT_MUTE, "pool")

/datum/component/swimming/proc/stop_drowning(mob/living/victim)
	victim.emote("cough")
	to_chat(victim, "<span class='notice'>You cough up the last of the water, regaining your ability to speak and breathe clearly!</span>")
	REMOVE_TRAIT(victim, TRAIT_MUTE, "pool")
	ticks_drowned = 0

/datum/component/swimming/proc/enter_pool()
	return

//Essentially the same as remove component, but easier for overiding
/datum/component/swimming/proc/exit_pool()
	return

//dissolving
/datum/component/swimming/disolve
	var/start_alpha = 0

/datum/component/swimming/disolve/enter_pool()
	var/mob/living/L = parent
	start_alpha = L.alpha
	to_chat(parent, "<span class='userdanger'>You begin disolving into the pool, get out fast!</span>")

/datum/component/swimming/disolve/process()
	..()
	var/mob/living/L = parent
	var/mob/living/carbon/human/H = L
	if(istype(H))
		if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing))
			var/obj/item/clothing/CH = H.wear_suit
			if (CH.clothing_flags & THICKMATERIAL)
				return
	L.adjustCloneLoss(1)
	L.alpha = ((L.health-HEALTH_THRESHOLD_DEAD) / (L.maxHealth - HEALTH_THRESHOLD_DEAD)) * 255
	if(L.stat == DEAD)
		L.visible_message("<span class='warning'>[L] dissolves into the pool!</span>")
		var/obj/item/organ/brain = L.getorgan(/obj/item/organ/brain)
		brain.Remove(L)	//Maybe making them completely unrecoverable is too far
		brain.forceMove(get_turf(L))
		qdel(L)

/datum/component/swimming/disolve/exit_pool()
	animate(parent, alpha=start_alpha, time=20)

//Ethereals
/datum/component/swimming/ethereal
	var/obj/machinery/pool_filter/linked_filter

/datum/component/swimming/ethereal/enter_pool()
	var/mob/living/L = parent
	L.visible_message("<span class='warning'>Sparks of energy being coursing around the pool!</span>")
	var/turf/open/indestructible/sound/pool/water = get_turf(parent)
	for(var/obj/machinery/pool_filter/PF in GLOB.pool_filters)
		if(PF.id == water.id)
			linked_filter = PF
			break

/datum/component/swimming/ethereal/process()
	..()
	if(!linked_filter)
		return
	var/mob/living/L = parent
	if(prob(2) && L.nutrition > NUTRITION_LEVEL_FED)
		L.adjust_nutrition(-50)
		linked_filter.reagents.add_reagent_list(list(/datum/reagent/teslium = 5, /datum/reagent/water = 5))	//Creates a tesla spawn

//Felenids
/datum/component/swimming/felinid/enter_pool()
	var/mob/living/L = parent
	L.emote("scream")
	to_chat(parent, "<span class='userdanger'>You get covered in water and start panicking!</span>")

/datum/component/swimming/felinid/process()
	..()
	var/mob/living/L = parent
	var/obj/item/helditem = L.get_active_held_item()
	if(helditem && helditem.check_float())
		return
	switch(rand(1, 100))
		if(1 to 4)
			to_chat(parent, "<span class='userdanger'>You can't touch the bottom!</span>")
			L.emote("scream")
		if(5 to 11)
			if(L.confused < 5)
				L.confused += 1
		if(12 to 16)
			L.shake_animation()
		if(17 to 22)
			shake_camera(L, 15, 1)
			L.emote("whimper")
			L.Paralyze(10)
			to_chat(parent, "<span class='userdanger'>You feel like you are never going to get out...</span>")

//Golems
/datum/component/swimming/golem/enter_pool()
	var/mob/living/M = parent
	M.Paralyze(60)
	M.visible_message("<span class='warning'>[M] crashed violently into the ground!</span>",
		"<span class='warning'>You sink like a rock!</span>")
	playsound(get_turf(M), 'sound/effects/picaxe1.ogg')

/datum/component/swimming/golem/is_drowning()
	return FALSE

//Squids
/datum/component/swimming/squid
	slowdown = 0.8

/datum/component/swimming/squid/enter_pool()
	to_chat(parent, "<span class='notice'>You feel at ease in your natural habitat!</span>")

/datum/component/swimming/squid/is_drowning(mob/living/victim)
	return FALSE
