#define WRIST_LOCK_COMBO "DDG" //Wrist Lock - drops items
#define ENTERING_THROW_COMBO "DHG" //Entering Throw - knockdown and stamina dmg
#define EYE_STRIKE_COMBO "HDD" //Eye Strike - short confusion and blurred eyes
#define FINISHER_COMBO "HDH" //Finisher - bonus stamina damage if target isn't standing

/datum/martial_art/nanojutsu
	name = "Nanojutsu"
	id = MARTIALART_NANOJUTSU
	block_chance = 20
	help_verb = /mob/living/carbon/human/proc/nanojutsu_help

/datum/martial_art/nanojutsu/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,WRIST_LOCK_COMBO))
		streak = ""
		wristLock(A,D)
		return 1
	if(findtext(streak,ENTERING_THROW_COMBO))
		streak = ""
		enteringThrow(A,D)
		return 1
	if(findtext(streak,EYE_STRIKE_COMBO))
		streak = ""
		eyeStrike(A,D)
		return 1
	if(findtext(streak,FINISHER_COMBO))
		streak = ""
		finisher(A,D)
		return 1
	return 0

//Wrist Lock - drops items
/datum/martial_art/nanojutsu/proc/wristLock(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "used a wrist lock (Nanojutsu) on")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='warning'>[A] grabs [D]'s wrist and wrenches it sideways!</span>", \
						  "<span class='userdanger'>[A] grabs your wrist and wrenches it to the side!</span>")
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		D.emote("scream")
		D.dropItemToGround(D.get_active_held_item())
		D.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		D.Stun(30)
		return 1
	return basic_hit(A,D)

//Entering Throw - brief knockdown and stamina dmg
/datum/martial_art/nanojutsu/proc/enteringThrow(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "used an entering throw (Nanojutsu) on")
		D.visible_message("<span class='warning'>[A] tripped [D] and pinned them to the floor!</span>", \
							"<span class='userdanger'>[A] tripped you and pinned you to the floor!</span>", null, COMBAT_MESSAGE_RANGE)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		D.emote("gasp")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.apply_damage(20, STAMINA, BODY_ZONE_CHEST, def_check)
		D.Knockdown(10)
		return 1
	return basic_hit(A,D)

//Eye Strike - short confusion and blurred eyes
/datum/martial_art/nanojutsu/proc/eyeStrike(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		if(D.is_eyes_covered())
			return basic_hit(A,D)
		log_combat(A, D, "used an eye strike (Nanojutsu) on")
		D.visible_message("<span class='warning'>[A] struck [D] in the eyes!</span>", \
							"<span class='userdanger'>[A] struck you in the eyes!</span>", null, COMBAT_MESSAGE_RANGE)
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 75, 1, -1)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.blur_eyes(10)
		D.confused += 2
		D.Jitter(20)
		return 1
	return basic_hit(A,D)

//Finisher - bonus stamina damage if target isn't standing
/datum/martial_art/nanojutsu/proc/finisher(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	if(!can_use(A))
		return FALSE
	if(!(D.mobility_flags & MOBILITY_STAND))
		log_combat(A, D, "used the finisher (Nanojutsu) on")
		D.visible_message("<span class='warning'>[A] kicked [D] in the abdomen!</span>", \
							"<span class='userdanger'>[A] kicked you in the abdomen!</span>", null, COMBAT_MESSAGE_RANGE)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.apply_damage(10, A.dna.species.attack_type, BODY_ZONE_CHEST, def_check)
		D.apply_damage(20, STAMINA, BODY_ZONE_CHEST, def_check)
		return 1
	return basic_hit(A,D)

/datum/martial_art/nanojutsu/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	return ..()

/datum/martial_art/nanojutsu/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1
	return ..()

/datum/martial_art/nanojutsu/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	return ..()

/mob/living/carbon/human/proc/nanojutsu_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of Nanojutsu."
	set category = "Nanojutsu"

	to_chat(usr, "<span class='danger'>LOADING README.TXT...</span>")

	to_chat(usr, "<span class='warning'>WRISTLOCK.EXE</span>: Disarm Disarm Grab. Forces opponent to drop item in hand.")
	to_chat(usr, "<span class='warning'>ENTERINGTHROW.EXE</span>: Disarm Harm Grab. Knocks your opponent down briefly and deals stamina damage.")
	to_chat(usr, "<span class='warning'>EYESTRIKE.EXE</span>: Harm Disarm Disarm. Very briefly confuses your opponent and blurs their vision.")
	to_chat(usr, "<span class='warning'>FINISHER.EXE</span>: Harm Disarm Harm. Deals bonus stamina damage if your opponent isn't standing up.")
