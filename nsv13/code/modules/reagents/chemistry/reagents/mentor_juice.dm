////////////////////////////////////////////////////////////////////////////////////////////////////
//										FURRANIUM
///////////////////////////////////////////////////////////////////////////////////////////////////
//OwO whats this?
//Makes you nya and awoo
//At a certain amount of time in your system it gives you a fluffy tongue, if in your system long enough, it's permanent.

/datum/chemical_reaction/furranium
	name = "Furranium"
	id = /datum/reagent/furranium
	results = list(/datum/reagent/furranium = 5)
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/toxin/mutagen = 1, /datum/reagent/silver = 2, /datum/reagent/medicine/salglu_solution = 1)
	required_temp = 666
	mix_message = "You think you can hear a howl come from the liquid."

/datum/reagent/furranium
	name = "Furranium"
	description = "OwO whats this?"
	color = "#f9b9bc" // rgb: 98, 73, 74
	taste_description = "dewicious degenyewacy"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	var/obj/item/organ/tongue/nT
	var/obj/item/organ/tongue/T
	chem_flags = CHEMICAL_RNG_FUN|CHEMICAL_GOAL_CHEMIST_BLOODSTREAM|CHEMICAL_GOAL_CHEMIST_DRUG
	var/old_sayverb

/datum/reagent/furranium/reaction_mob(mob/living/carbon/human/M, method=INJECT, reac_volume)
	if(method == INJECT)
		var/turf/T = get_turf(M)
		M.adjustOxyLoss(15)
		M.Knockdown(50)
		M.Stun(50)
		M.emote("cough")
		var/plush_type = pick(subtypesof(/obj/item/toy/plush))
		var/obj/item/toy/plush/P = new plush_type(T)
		M.visible_message("<span class='warning'>[M] suddenly coughs up a [P.name]!</b></span>",\
						"<span class='warning'>You feel a lump form in your throat, as you suddenly cough up what feels like a hairball?</b></span>")
		var/T2 = get_random_station_turf()
		P.throw_at(T2, 8, 1)
	..()

/datum/reagent/furranium/on_mob_life(mob/living/carbon/M)
	switch(current_cycle)
		if(1 to 9)
			if(prob(20))
				to_chat(M, "<span class='notice'>Your tongue feels... fluffy</span>")
		if(10 to 15)
			if(prob(10))
				to_chat(M, "You find yourself unable to suppress the desire to meow!")
				M.emote("nya", intentional = FALSE)
			if(prob(10))
				to_chat(M, "You find yourself unable to suppress the desire to howl!")
				M.emote("awoo", intentional = FALSE)
			if(prob(20))
				var/list/seen = oview(7, M) //Sound and sight checkers
				for(var/victim in seen)
					if(isanimal(victim) || !isliving(victim))
						seen -= victim
				if(LAZYLEN(seen))
					to_chat(M, "You notice something about [pick(seen)].. [pick("OwO!", "uwu!")]")
		if(16)
			T = M.getorganslot(ORGAN_SLOT_TONGUE)
			if(!istype(T, /obj/item/organ/tongue/fluffy))
				var/obj/item/organ/tongue/nT = new /obj/item/organ/tongue/fluffy
				if(T)
					T.Remove(M)
					T.moveToNullspace()//To valhalla
				nT.Insert(M)
				to_chat(M, "<span class='big warning'>Your tongue feels... weally fwuffy!!</span>")
				old_sayverb = M.verb_say
				M.verb_say = "meows"
		if(17 to INFINITY)
			if(prob(5))
				to_chat(M, "You find yourself unable to suppress the desire to meow!")
				M.emote("nya", intentional = FALSE)
			if(prob(5))
				to_chat(M, "You find yourself unable to suppress the desire to howl!")
				M.emote("awoo", intentional = FALSE)
			if(prob(5))
				var/list/seen = oview(7, M)//Sound and sight checkers
				for(var/victim in seen)
					if(isanimal(victim) || !isliving(victim))
						seen -= victim
				if(LAZYLEN(seen))
					to_chat(M, "You notice something about [pick(seen)].. [pick("OwO!", "uwu!")]")
	..()

/datum/reagent/furranium/on_mob_delete(mob/living/carbon/M)
	if(current_cycle < 45 && T) //Better get that out of you quick!
		nT = M.getorganslot(ORGAN_SLOT_TONGUE)
		nT.Remove(M)
		qdel(nT)
		T.Insert(M)
		to_chat(M, "<span class='notice'>You feel your tongue.... unfluffify...?</span>")
		M.verb_say = old_sayverb
		M.say("Pleh!")
	else
		to_chat(M, "<spam class='warning'>You feel as if the condition of your tongue has become permanent...</span>")

/obj/item/organ/tongue/fluffy
	name = "fluffy tongue"
	desc = "OwO what's this?"
	icon = 'nsv13/icons/obj/tongue.dmi'
	icon_state = "tonguefluffy"
	taste_sensitivity = 10 // extra sensitive and inquisitive uwu
	maxHealth = 35 //Sensitive tongue!
	modifies_speech = TRUE

/obj/item/organ/tongue/fluffy/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = replacetext(message, "ne", "nye")
		message = replacetext(message, "nu", "nyu")
		message = replacetext(message, "na", "nya")
		message = replacetext(message, "no", "nyo")
		message = replacetext(message, "ove", "uv")
		message = replacetext(message, "l", "w")
		message = replacetext(message, "r", "w")
	speech_args[SPEECH_MESSAGE] = lowertext(message)

/datum/emote/living/nya
	key = "nya"
	key_third_person = "lets out a nya"
	message = "lets out a nya!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/nya/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(intentional && !istype(C.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/fluffy))
			return FALSE
		return !C.silent

/datum/emote/living/nya/get_sound(mob/living/user)
	return 'nsv13/sound/voice/oopsie_woopsie/nya.ogg'

/datum/emote/living/awoo
	key = "awoo"
	key_third_person = "lets out an awoo"
	message = "lets out an awoo!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/awoo/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(intentional && !istype(C.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/fluffy))
			return FALSE
		return !C.silent

/datum/emote/living/awoo/get_sound(mob/living/user)
	return 'nsv13/sound/voice/oopsie_woopsie/awoo.ogg'


//My escape from this madness
/datum/emote/living/weh
	key = "weh"
	key_third_person = "lets out a weh"
	message = "lets out a weh!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/weh/can_run_emote(mob/user, status_check = TRUE, intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(intentional && !istype(C.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/fluffy) && !islizard(C))
			return FALSE
		return !C.silent

/datum/emote/living/weh/get_sound(mob/living/user)
	return 'nsv13/sound/voice/oopsie_woopsie/weh.ogg'


//On 2264's menu, bioweapons.

/obj/item/projectile/guided_munition/torpedo/biohazard_one
	relay_projectile_type = /obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/one
	damage = 150
	obj_integrity = 80
	max_integrity = 80

/obj/item/projectile/guided_munition/torpedo/biohazard_two
	relay_projectile_type = /obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/two
	damage = 150
	obj_integrity = 80
	max_integrity = 80

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo
	icon_state = "torpedo"
	name = "torpedo"
	penetration_fuze = 3
	damage = 25
	var/decal_type = null

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/fuze_trigger_value(atom/target)
	if(isclosedturf(target))
		return 1
	return 0

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/is_valid_to_release(atom/newloc)
	if(penetration_fuze > 0 || !isopenturf(newloc))
		return FALSE
	return TRUE

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/one
	decal_type = /obj/effect/decal/cleanable/blood/infected

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/two
	decal_type = /obj/effect/decal/cleanable/greenglow/fun_trust_me

/obj/item/projectile/bullet/delayed_prime/relayed_biohazard_torpedo/release_payload(atom/detonation_location)
	var/turf/detonation_turf = get_turf(detonation_location)
	explosion(detonation_turf, 0, 0, 5, 8)
	var/list/inrange_turfs = RANGE_TURFS(4, detonation_turf)
	for(var/turf/T as() in inrange_turfs)
		if(isgroundlessturf(T))	//Should those kinds of turfs be able to get waste from this? Hmm, I dunno.
			continue
		if(isclosedturf(T) || is_blocked_turf(T, TRUE))	//Definitely not on closed turfs, for now also not on ones blocked by stuff to not make it agonizing.. unless?
			continue
		if(locate(decal_type) in T)	//No stacking.
			continue
		if(!prob(70))
			continue
		new decal_type(T)

/obj/effect/decal/cleanable/blood/infected

/obj/effect/decal/cleanable/blood/infected/Initialize(mapload, list/datum/disease/diseases)
	var/datum/disease/pain = new /datum/disease/transformation/felinid/contagious/bioweapon()
	. = ..(mapload, list(pain)) //We love dreammaker.

/obj/effect/decal/cleanable/blood/infected/ex_act(severity, target)
	if(severity != EXPLODE_DEVASTATE)
		return
	qdel(src)

/datum/disease/transformation/felinid/contagious/bioweapon
	name = "Unshackled Nano-Feline Assimilative Toxoplasmosis"
	spread_text = "On contact, Bloodborne"
	stage_prob = 3
	spread_flags = DISEASE_SPREAD_BLOOD|DISEASE_SPREAD_CONTACT_FLUIDS|DISEASE_SPREAD_CONTACT_SKIN
	bypasses_immunity = TRUE //Nyanomachines, son.
	is_mutagenic = TRUE

/obj/effect/decal/cleanable/greenglow/fun_trust_me

/obj/effect/decal/cleanable/greenglow/fun_trust_me/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	reagents.add_reagent(/datum/reagent/furranium, 25)

//Override
/obj/effect/decal/cleanable/greenglow/fun_trust_me/on_entered(datum/source, atom/movable/AM)
	if(!iscarbon(AM))
		return
	var/mob/living/carbon/C = AM
	reagents.trans_to(C, 1, 5, method = TOUCH, round_robin = TRUE)

/obj/effect/decal/cleanable/greenglow/fun_trust_me/ex_act(severity, target)
	if(severity != EXPLODE_DEVASTATE)
		return
	qdel(src)

//On this year's agenda, dice games!

/**
 * Handles the dice mechanics for ship defense.
 * * Given we've had dice for a couple years now, I am sure I don't need to leave any code comments in here because everyone already understands.
 */
/obj/structure/overmap/proc/handle_dicey_defense(obj/item/projectile/incoming, obj/structure/overmap/firer)
	var/datum/combat_dice/attack_dice = firer.npc_combat_dice
	var/datum/combat_dice/defense_dice = npc_combat_dice

	//Consider: Accuracy / Crit / etc bonuses / maluses by projectile category (e.g. torp inaccurate but if it hits, often crits)?

	var/affinity_target = FALSE
	if(ai_flags & attack_dice.affinity_flags)
		affinity_target = TRUE

	var/targetting_roll = 0
	for(var/i = 1; i <= attack_dice.target_dice; i++)
		targetting_roll += rand(1, attack_dice.target_roll)
	targetting_roll += attack_dice.target_bonus

	if(affinity_target)
		targetting_roll = CEILING(targetting_roll * 1.5, 1)

	var/evading_roll = 0
	for(var/i = 1; i <= defense_dice.evade_dice; i++)
		evading_roll += rand(1, defense_dice.evade_roll)
	evading_roll += defense_dice.evade_bonus

	if(evading_roll > targetting_roll)
		return list("EVADED", "T\[[targetting_roll]\] < E\[[evading_roll]\]")

	var/penetrating_roll = targetting_roll - evading_roll


	var/armoring_roll = 0
	for(var/i = 1; i <= defense_dice.armor_dice; i++)
		armoring_roll += rand(1, defense_dice.armor_roll)
	armoring_roll += defense_dice.armor_bonus

	var/damaging_roll = 0
	for(var/i = 1; i <= attack_dice.damage_dice; i++)
		damaging_roll += rand(1, attack_dice.damage_roll)
	damaging_roll += attack_dice.damage_bonus

	if(affinity_target)
		damaging_roll = CEILING(damaging_roll * 1.5, 1)

	if(targetting_roll < armoring_roll)
		return list("GLANCING HIT", "T\[[targetting_roll]\] < A\[[armoring_roll]\]")

	if(penetrating_roll >= armoring_roll && damaging_roll >= armoring_roll)
		return list("CRITICAL HIT", "P\[[penetrating_roll]\] & D\[[damaging_roll]\] >= A\[[armoring_roll]\]")

	if(damaging_roll > armoring_roll)
		return list("DIRECT HIT", "D\[[damaging_roll]\] > A\[[armoring_roll]\]")

	return null

/datum/overmap_ship_weapon/mac/rock
	name = "Rock Launcher"
	standard_projectile_type = /obj/item/projectile/bullet/mac_round/stone

/obj/effect/dangerrock
	vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_LAYER|VIS_INHERIT_ID
	icon = 'icons/obj/meteor.dmi'
	icon_state = "flaming"
	alpha = 255
	invisibility = 0

/obj/effect/dangerrock/Initialize(mapload)
	. = ..()
	SpinAnimation(120, -1, pick(TRUE, FALSE), segments = 12)

/obj/item/projectile/bullet/mac_round/stone
	name = "Rock"
	desc = "You should probably be dodging this, not staring.."
	icon = null
	relay_projectile_type = /obj/item/projectile/bullet/delayed_prime/relayed_rock
	speed = 6
	var/obj/effect/dangerrock/realvisual

/obj/item/projectile/bullet/mac_round/stone/fire(angle, atom/direct_target)
	. = ..()
	if(QDELETED(src))
		return
	realvisual = new(src)
	vis_contents += realvisual

/obj/item/projectile/bullet/mac_round/stone/Destroy()
	if(realvisual)
		vis_contents -= realvisual
		QDEL_NULL(realvisual)
	return ..()

/obj/item/projectile/bullet/delayed_prime/relayed_rock
	name = "Stone"
	desc = "You feel like looking at this is a bad use of your remaining time."
	icon = null
	damage = 60
	damage_type = BRUTE
	flag = "melee"
	speed = 6
	var/obj/effect/dangerrock/realvisual

/obj/item/projectile/bullet/delayed_prime/relayed_rock/fire(angle, atom/direct_target)
	. = ..()
	if(QDELETED(src))
		return
	realvisual = new(src)
	vis_contents += realvisual

/obj/item/projectile/bullet/delayed_prime/relayed_rock/Destroy()
	if(realvisual)
		vis_contents -= realvisual
		QDEL_NULL(realvisual)
	return ..()

/obj/item/projectile/bullet/delayed_prime/relayed_rock/fuze_trigger_value(atom/target)
	if(!isclosedturf(target))
		return 0
	return 1

/obj/item/projectile/bullet/delayed_prime/relayed_rock/is_valid_to_release(atom/newloc)
	if(penetration_fuze > 0)
		return FALSE
	return TRUE

/obj/item/projectile/bullet/delayed_prime/relayed_rock/release_payload(atom/detonation_location)
	if(istype(detonation_location, /turf/closed/wall))
		var/turf/closed/wall/wall = detonation_location
		wall.dismantle_wall(TRUE, TRUE)
	explosion(detonation_location, 2, 4, 8, 8, flame_range = 5)

/datum/combat_dice/plotarmor_line
	name = "Protagonist combat dice (C)"

	evade_roll = 5
	evade_bonus = -1

	target_dice = 2
	target_roll = 5
	target_bonus = 1

	armor_dice = 2
	armor_roll = 4
	armor_bonus = 1

	damage_dice = 2
	damage_roll = 4
	damage_bonus = 2

	affinity_flags = AI_FLAG_SUPPLY

/datum/combat_dice/plotarmor_escort
	name = "Protagonist combat dice (E)"

	evade_dice = 2
	evade_roll = 5
	evade_bonus = -1

	target_dice = 2
	target_roll = 5
	target_bonus = 2

	armor_roll = 3

	damage_dice = 2
	damage_roll = 3
	damage_bonus = 1

	affinity_flags = AI_FLAG_SUPPLY|AI_FLAG_SWARMER

/datum/combat_dice/plotarmor_supercapital
	name = "Protagonist combat dice (SC)"

	evade_roll = 3
	evade_bonus = -1

	target_dice = 4
	target_roll = 4
	target_bonus = 2

	armor_dice = 4
	armor_roll = 3
	armor_bonus = 4

	damage_dice = 4
	damage_roll = 3
	damage_bonus = 2

	affinity_flags = AI_FLAG_DESTROYER|AI_FLAG_SUPPLY

/datum/combat_dice/plotarmor_fighter
	name = "Protagonist combat dice (F)"

	evade_dice = 3
	evade_roll = 5
	evade_bonus = 2

	armor_roll = 3
	armor_bonus = -1

	damage_roll = 3
	damage_dice = 2

	target_roll = 5
	target_bonus = 4

	affinity_flags = AI_FLAG_SWARMER

/datum/combat_dice/plotarmor_fighter/heavy
	name = "Protagonist combat dice (F-H)"

	evade_dice = 2
	evade_bonus = -2

	armor_dice = 2
	armor_bonus = 1

	damage_roll = 4
	damage_bonus = 1

	target_dice = 2

	affinity_flags = AI_FLAG_SUPPLY|AI_FLAG_STATIONARY|AI_FLAG_BATTLESHIP


/datum/combat_dice/roci_my_beloved
	name = "Self-Explanatory combat dice"

	evade_dice = 4
	evade_roll = 4
	evade_bonus = -1

	target_dice = 2
	target_roll = 5
	target_bonus = -2

	armor_dice = 0 //yeeeeah about those plates..
	armor_bonus = 1

	damage_dice = 2
	damage_roll = 4

	affinity_flags = ALL

/datum/combat_dice/rock
	name = "Stone combat dice"

	evade_dice = 0 //This is quite literally a stone.
	evade_bonus = 0

	target_dice = 2
	target_roll = 4

	armor_bonus = 99 //This is quite literally a rock.

	damage_dice = 2
	damage_roll = 4
	damage_bonus = 6

	affinity_flags = NONE

//It's me again, this time in 2266!! This time, pipe cleaners and maybe some other things~

/mob/living/simple_animal/pipe_cleaner
	name = "\improper pipe cleaner"
	desc = "Some strange creature, here to clean pipes!"
	icon = 'nsv13/icons/mob/legally_distinct_creature/pipe_cleaner.dmi'
	icon_state = "pipe_cleaner"
	icon_living = "pipe_cleaner"
	icon_dead = "pipe_cleaner_dead"
	mob_size = MOB_SIZE_HUMAN
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	blood_volume = BLOOD_VOLUME_NORMAL
	ventcrawler = VENTCRAWLER_ALWAYS
	dextrous = TRUE //you bet.
	held_items = list(null, null)
	possible_a_intents = list(INTENT_HELP, INTENT_HARM)
	health = 200
	maxHealth = 200
	status_flags = CANUNCONSCIOUS|CANPUSH
	friendly = "baps" //Needs tools to be of any threat.
	attack_sound = 'sound/weapons/tap.ogg'
	gold_core_spawnable = FRIENDLY_SPAWN
	see_in_dark = 6
	response_help  = "pets"
	response_disarm = "shoves"
	response_harm   = "kicks"
	attacktext = "mauls" //In case someone DOES adjust the values.
	verb_say = "wawas"
	verb_yell = "wawas"
	verb_sing = "wawas harmonically"
	verb_exclaim = "wawas"
	verb_ask = "wawas questioningly"
	verb_whisper = "wawas quietly"
	speed = -0.2 //Test - prev 0.1
	turns_per_move = 5
	wander = TRUE
	emote_see = list("stares at the ceiling.", "shivers.", "looks startled.")
	speak_chance = 1
	stop_automated_movement_when_pulled = TRUE
	atmos_requirements = list(list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0))
	///They get one of these colors or none.
	var/static/valid_colors = list("#2d6e7e","#7200b4","#8b2941","#008341","#006781","#b45927","#b48e27","#008744","#004fce","#bd271c","#ce8602") //Yes, this is just the colorful reagent spread copied. (okay I guess I did adjust it some by now!)

/mob/living/simple_animal/pipe_cleaner/examine(mob/user)
	. = ..()
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "[t_He] [t_is] holding [I.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(I))]."

	var/list/msg = list("<span class='warning'>")
	var/temp = getBruteLoss()
	if(temp)
		if (temp < 25)
			msg += "[t_He] [t_has] minor bruising.\n"
		else if (temp < 50)
			msg += "[t_He] [t_has] <b>moderate</b> bruising!\n"
		else
			msg += "<B>[t_He] [t_has] severe bruising!</B>\n"

	temp = getFireLoss()
	if(temp)
		if (temp < 25)
			msg += "[t_He] [t_has] minor burns.\n"
		else if (temp < 50)
			msg += "[t_He] [t_has] <b>moderate</b> burns!\n"
		else
			msg += "<B>[t_He] [t_has] severe burns!</B>\n"

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] look[p_s()] a little soaked.\n"

	if(pulledby?.grab_state)
		msg += "[t_He] [t_is] restrained by [pulledby]'s grip.\n"

	msg += "</span>"

	. += msg.Join("")

	if(stat == DEAD)
		. += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive, with no signs of life.</span>"
	else if(stat == UNCONSCIOUS)
		. += "[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep."
	else if(InCritical())
		. += "[t_His] breathing is shallow and labored."

GLOBAL_VAR_INIT(pipe_cleaner_count, 0)

/mob/living/simple_animal/pipe_cleaner/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/self/hibernate/hibernate_action = new /obj/effect/proc_holder/spell/self/hibernate(src)
	hibernate_action.action.Grant(src)
	mob_spell_list += hibernate_action
	var/obj/effect/proc_holder/spell/aimed/chuck/chuck_action = new /obj/effect/proc_holder/spell/aimed/chuck(src)
	chuck_action.action.Grant(src)
	mob_spell_list += chuck_action
	GLOB.pipe_cleaner_count++
	if(prob(75)) //Default is the most common color; even split between others.
		add_atom_colour(pick(valid_colors), FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/pipe_cleaner/Destroy()
	GLOB.pipe_cleaner_count--
	return ..()

/mob/living/simple_animal/pipe_cleaner/treat_message(message)
	message = wa(message)
	return ..()

/mob/living/simple_animal/pipe_cleaner/put_in_hand(obj/item/I, hand_index, forced, ignore_anim)
	. = ..()
	if(.)
		update_icons()

/mob/living/simple_animal/pipe_cleaner/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, was_thrown, silent)
	. = ..()
	if(.)
		update_icons()

/mob/living/simple_animal/update_mobility(value_otherwise = TRUE)
	. = ..()
	update_icons()

/mob/living/simple_animal/pipe_cleaner/update_icons()
	if(stat == DEAD)
		return
	if(stat == UNCONSCIOUS || IsUnconscious())
		icon_state = "pipe_cleaner_rest"
		return
	var/active_held = get_active_held_item()
	var/inactive_held = get_inactive_held_item() //This is kinda :/ but it's okay.
	if(active_held && istype(active_held, /obj/item/spear))
		icon_state = "pipe_cleaner_spear"
	else if(inactive_held && istype(inactive_held, /obj/item/spear))
		icon_state = "pipe_cleaner_spear"
	else
		icon_state = icon_living

/mob/living/simple_animal/pipe_cleaner/Moved()
	. = ..()
	last_move_time = world.time //For some reason this seems to have gotten deprecated? I need this, though!

/proc/wa(message)
	message = html_decode(message)
	var/message_length = length(message)
	var/end = copytext(message, length(message))
	var/valid_final = FALSE
	if(end in list("!", ".", "?", ":", "\"", "-", "~"))
		message_length--
		valid_final = TRUE
	var/iterate = CEILING(message_length / 2, 1)
	var/wa = ""
	for(var/iter = 0; iter < iterate; iter++)
		switch(rand(1,5))
			if(1,2)
				wa += "wa"
			if(3,4)
				wa += "waa"
			else
				wa += "wawa"
	if(valid_final)
		wa += end
	return sanitize(wa)

/obj/effect/proc_holder/spell/self/hibernate
	name = "Hibernate"
	desc = "Hibernate within a she- uhm, 'vent' to rapidly regenerate."
	clothes_req = FALSE
	antimagic_allowed = TRUE
	charge_max = 200
	action_icon_state = "time"

/obj/effect/proc_holder/spell/self/hibernate/can_cast(mob/user)
	. = ..()
	if(!.)
		return
	if(!(user.movement_type & VENTCRAWLING))
		return FALSE

/obj/effect/proc_holder/spell/self/hibernate/cast(mob/user = usr)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	living_user.AdjustUnconscious(20 SECONDS)
	living_user.apply_status_effect(STATUS_EFFECT_HIBERNATING)

/datum/status_effect/hibernating
	id = "Hibernating"
	alert_type = /atom/movable/screen/alert/status_effect/hibernating
	duration = -1 //Lasts Until awake
	tick_interval = 0.5 SECONDS
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/hibernating/tick()
	if(!owner.IsUnconscious())
		duration = 0
	owner.heal_overall_damage(5,5)

/atom/movable/screen/alert/status_effect/hibernating
	name = "Hibernating"
	desc = "You are Hibernating. You should wake up soon. Will you still be in the same place?"
	icon_state = "hibernating"

/obj/effect/proc_holder/spell/aimed/chuck
	name = "CHUCK"
	desc = "Throw whatever you are holding with FORCE. Only in exact cardinal directions, for some reason.. Will leave you tired for a while."
	charge_max = 50
	clothes_req = FALSE
	antimagic_allowed = TRUE
	range = 20
	base_icon_state = "projectile"
	action_icon_state = "projectile0"
	sound = null
	active_msg = "You ready your throwing arm!"
	deactive_msg = "You reconsider throwing that.."
	///These throws HURT
	var/force_multiplier = 3
	///Currently debuffed? (some backend is questionable so I am doing my own linkage check)
	var/exhausted = FALSE

/obj/effect/proc_holder/spell/aimed/chuck/can_cast(mob/user)
	. = ..()
	if(!.)
		return
	if(!isliving(user))
		return FALSE

/obj/effect/proc_holder/spell/aimed/chuck/process(delta_time)
	if(exhausted && recharging && action.owner.last_move_time + 2 SECONDS > world.time)
		return //Rest a little you goober.
	return ..()

/obj/effect/proc_holder/spell/aimed/chuck/end_timer_animation()
	if(exhausted && action.owner)
		if(action.owner.stat != DEAD)
			to_chat(action.owner, "<span class='notice'>You feel rested again!</span>")
		action.owner.remove_movespeed_modifier(MOVESPEED_ID_CHUCKING_RECOVERY, TRUE)
		exhausted = FALSE
	return ..()

/obj/effect/proc_holder/spell/aimed/chuck/start_recharge()
	. = ..()

/obj/effect/proc_holder/spell/aimed/chuck/cast_check(skipcharge, mob/user)
	. = ..()
	if(!.)
		return
	if(!action.owner)
		return
	if(!action.owner.get_active_held_item())
		return FALSE
	var/turf/T = action.owner.loc
	if(!isturf(T))
		return FALSE

//OVERRIDE
/obj/effect/proc_holder/spell/aimed/chuck/cast(list/targets, mob/living/user)
	var/target = targets[1]
	var/turf/T = user.loc
	if(!isturf(T))
		return FALSE
	var/obj/item/to_chuck = user.get_active_held_item()
	if(!user.dropItemToGround(to_chuck))
		return FALSE
	var/chuck_dir = get_cardinal_dir(user, target)
	var/chuck_angle = get_angle(T, get_step(T, chuck_dir))
	var/target_turf = get_turf_in_angle(chuck_angle, T, 20)
	if(!target_turf)
		return FALSE
	var/effective_force_multiplier = 1.5
	if(istype(to_chuck, /obj/item/spear))
		effective_force_multiplier = force_multiplier
	if(effective_force_multiplier != 1)
		to_chuck.throwforce *= effective_force_multiplier
	playsound(T, 'sound/weapons/punchmiss.ogg', 40, 1, -1)
	to_chuck.throw_at(target_turf, 30, 8, user, spin = TRUE, callback = CALLBACK(src, TYPE_PROC_REF(/obj/effect/proc_holder/spell/aimed/chuck, reset_chucking_force), to_chuck, effective_force_multiplier))
	user.newtonian_move(get_dir(target_turf, T))
	action.owner?.add_movespeed_modifier(MOVESPEED_ID_CHUCKING_RECOVERY, TRUE, 100, override=TRUE, multiplicative_slowdown=1)
	exhausted = TRUE
	remove_ranged_ability()
	charge_counter = 0
	start_recharge()
	on_deactivation(user)
	return TRUE

/obj/effect/proc_holder/spell/aimed/chuck/proc/reset_chucking_force(obj/item/chucked, effective_force_multiplier)
	if(!chucked || effective_force_multiplier == 0 || effective_force_multiplier == 1)
		return
	chucked.throwforce /= effective_force_multiplier

//OVERRIDE
/obj/item/swabber/Initialize(mapload)
	if(GLOB.pipe_cleaner_count <= 64) //Look this may be a special time but I would still like the server to run.
		new /mob/living/simple_animal/pipe_cleaner(get_turf(src))
	return INITIALIZE_HINT_QDEL

/obj/structure/overmap/spacepirate/ai/so_called_missile_carrier
	name = "Ramshackle Missile Carrier"
	desc = "This hull resembles a cruiser, albeit several armor plates and weapon mounts appear to have been replaced to make way for an inadvisable amount of launch tubes."
	icon = 'nsv13/icons/overmap/syndicate/syn_light_cruiser.dmi'
	icon_state = "spacepirate_mistake"
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = FALSE
	bound_height = 128
	bound_width = 128
	max_integrity = 350
	shots_left = 20
	missiles = 32
	armor = list("overmap_light" = 70, "overmap_medium" = 35, "overmap_heavy" = 5) //-10 -10 -5, to keep true to the flavortext
	ai_flags = AI_FLAG_DESTROYER | AI_FLAG_ELITE
	combat_dice_type = /datum/combat_dice/destroyer
	missile_type = /obj/item/projectile/guided_munition/missile/ai/randomdelay

/obj/structure/overmap/spacepirate/ai/so_called_missile_carrier/apply_weapons()
	new /datum/overmap_ship_weapon/aa_guns(src, FALSE)
	new /datum/overmap_ship_weapon/missile_launcher/ramshackle_ultraburst(src, FALSE)
	new /datum/overmap_ship_weapon/pdc_mount(src)

/datum/overmap_ship_weapon/missile_launcher/ramshackle_ultraburst
	name = "Highly Questionable Burst Missile Launchers"
	burst_size = 16
	fire_delay = 25 SECONDS
	burst_fire_delay = 0.2 SECONDS
	optimal_range = 30
	select_alert = "<span class='notice'>Burst missile tubes: online.</span>"
	firing_arc = 0
	ai_fire_delay = 0
	weapon_facing_flags = OSW_FACING_OMNI
	weapon_firing_flags = OSW_ALWAYS_FIRES_ERRATIC_BROADSIDES
	used_nonphysical_ammo = OSW_AMMO_MISSILE
	sort_priority = 50
	spread_override = 30

//OVERRIDE
/datum/overmap_ship_weapon/missile_launcher/ramshackle_ultraburst/is_target_size_valid(obj/structure/overmap/target)
	return TRUE

/obj/item/projectile/guided_munition/missile/ai/randomdelay
	///Delays guidance for N cycles
	var/guidance_error = 0

/obj/item/projectile/guided_munition/missile/ai/randomdelay/Initialize(mapload)
	. = ..()
	if(prob(25))
		homing = FALSE //Guidance is hecc
	else
		guidance_error = rand(4, 10)

/obj/item/projectile/guided_munition/missile/ai/randomdelay/process_homing(atom/A)
	if(guidance_error > 0)
		guidance_error--
		next_homing_process = world.time + homing_delay
		return
	return ..()
