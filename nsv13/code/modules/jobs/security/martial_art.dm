#define MARTIALART_JUJITSU "ju jitsu"
#define TAKEDOWN_COMBO "DD"
#define JUDO_THROW "DHHG"
#define ARMLOCK "HGG"

#define armlockstate = FALSE

/obj/item/book/granter/martial/jujitsu
	martial = /datum/martial_art/jujitsu
	name = "surviving edged weapons"
	oneuse = TRUE
	martialname = "Ju jitsu"
	icon = 'nsv13/icons/obj/library.dmi'
	icon_state = "edgedweapons"
	desc = "An instructional manual produced in the 2180s which instructs police officers in how to survive attacks by edged weapons and more. (Comes with a FREE Martian war commemorative knife!)"
	greet = "<span class='sciradio'> You suddenly feel a lot less vulnerable to knife attacks...\
	You're now able to perform grappling moves to incapacitate suspects. You can learn more about your newfound art by using the Recall police training verb in the ju-jitsu tab.</span>"
	remarks = list("A suspect with a knife can close 7 paces and deliver deadly force in less than 1 and 1/2 seconds...", "In case of satanic rituals, apply a full magazine to the perp...", "Remove his hat and visually inspect his hair without touching it during a search...", "Have your partner search the target while you restrain them...", "What's this about knife culture?...", "A minimum reactionary gap of 21 feet is required to react and deliver at least 2 rounds and to have enough time to move out of the attacker's path...")

/obj/item/book/granter/martial/jujitsu/onlearned(mob/living/carbon/user)
	..()
	if(oneuse)
		desc = "The pages are too thicky encrusted with coffee stains and donut residue to be legibile anymore..."

/datum/martial_art/jujitsu
	name = "Ju jitsu"
	id = MARTIALART_JUJITSU
	deflection_chance = 0
	no_guns = FALSE
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/jujitsu_help
	smashes_tables = FALSE
	reroute_deflection = FALSE
	var/cooldown = 5 SECONDS //While sec should be proficient at hand to hand, they shouldn't be able to simultaneously ju jitsu 10 different targets...
	var/last_move = 0

/mob/living/carbon/human/proc/jujitsu_help()
	set name = "Recall Police Training"
	set desc = "Remember your police academy martial arts training."
	set category = "Jujitsu"
	to_chat(usr, "<span class='notice'>Combos:</span>")
	to_chat(usr, "<span class='warning'><b>Disarm, Disarm</b> will perform a takedown on the target, if they have been slowed / weakened first</span>")
	to_chat(usr, "<span class='warning'><b>Disarm, Harm, Harm, Grab</b> will execute a judo throw on the target,landing you on top of them in a pinning position. Provided that you have a grab on them on the final step...</span>")
	to_chat(usr, "<span class='warning'><b>Disarm, Grab</b> will perform a disarming move on the target in which you clasp his hand and take his held item away.</span>")

/datum/martial_art/jujitsu/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,TAKEDOWN_COMBO))
		streak = ""
		takedown(A,D)
		return TRUE
	if(findtext(streak, JUDO_THROW))
		streak = ""
		judo_throw(A,D)
		return TRUE
	if(findtext(streak,ARMLOCK))
		streak = ""
		armlock(A, D)
		return TRUE
	return FALSE

/datum/martial_art/jujitsu/proc/takedown(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(world.time < last_move+cooldown)
		to_chat(A, "<span class='sciradio'>You're too fatigued to perform this move right now...</span>")
		return FALSE
	if(D.total_multiplicative_slowdown() < 2) //They have to be slowed by something
		A.visible_message("<span class='warning'>[A] tries to trip [D] up, but they sidestep the attack!</span>","<span class='warning'>[D] sidesteps your attack! Slow them down first.</span>")
		return FALSE
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	D.visible_message("<span class='userdanger'>[A] trips [D] up and pins them to the ground!</span>", "<span class='userdanger'>[A] is pinning you to the ground!</span>")
	playsound(get_turf(D), 'nsv13/sound/effects/judo_throw.ogg', 100, TRUE)
	D.Paralyze(7 SECONDS) //Equivalent to a clown PDA
	A.shake_animation(10)
	D.shake_animation(10)
	D.adjustOxyLoss(10) // you smashed him into the ground
	A.forceMove(get_turf(D))
	A.start_pulling(D, supress_message = FALSE)
	A.setGrabState(GRAB_AGGRESSIVE)
	last_move = world.time

/datum/martial_art/jujitsu/proc/judo_throw(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(world.time < last_move+cooldown)
		to_chat(A, "<span class='sciradio'>You're too fatigued to perform this move right now...</span>")
		return FALSE
	if(!A.pulling || A.pulling != D) //You have to have an active grab on them for this to work!
		A.shake_animation(10)
		var/newdir = turn(A.dir, 180)
		var/turf/target = get_turf(get_step(A, newdir))
		if(is_blocked_turf(target)) //Prevents translocation (sorry coreflare :( )
			target = get_turf(A)
		D.forceMove(target)
		A.setDir(newdir)
		A.start_pulling(D, supress_message = FALSE)
		A.setGrabState(GRAB_AGGRESSIVE)
		D.adjustOxyLoss(40) // YOU THREW HIM, THREW HIM!!
		D.Paralyze(7 SECONDS) //Equivalent to a clown PDA
		D.visible_message("<span class='userdanger'>[A] throws [D] over their shoulder and pins them down!</span>", "<span class='userdanger'>[A] throws you over their shoulder and pins you to the ground!</span>")
		playsound(get_turf(D), 'nsv13/sound/effects/judo_throw.ogg', 100, TRUE)
		last_move = world.time

// Armlock removal when out of time

/datum/martial_art/jujitsu/proc/drop_armlock()
	armlockstate = FALSE

// Armlock removal when officer stops pulling

/datum/martial_art/jujitsu/proc/armlock_set(mob/living/carbon/human/A, mob/living/carbon/human/D) // would a proc repeat if I make it ..()? I hope so
	if(!armlockstate = TRUE)
		return FALSE
	if(!D.stat || !A.stat)
		return FALSE
	if(A.stop_pulling(D))
		A.Knockdown(0) // removes knockdown of officer
		D.Paralyze(0) // removes paralyze of suspect
		D.Knockdown(20) // leaves suspecton the ground for a tiny bit to recover
		armlockstate = FALSE
	if(A.harm_act(D))
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
		//A.pain in hand selected enough to disable
	..()

// Armlock

/datum/martial_art/jujitsu/proc/armlock(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(armlockstate)
		return
	if(!can_use(A))
		return FALSE
	if(world.time < last_move+cooldown)
		to_chat(A, "<span class='sciradio'>You're too fatigued to perform this move right now...</span>")
		return FALSE
	if(!D.stat)

		D.visible_message("<span class='warning'>[A] locks [D] into a armlock position!</span>", \
							"<span class='userdanger'>[A] locks you into a armlock position!</span>")
		A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
		D.adjustStaminaLoss(30)
		A.Knockdown(100)
		D.Paralyze(100)
		A.start_pulling(D, supress_message = FALSE)
		A.setGrabState(GRAB_NECK)
		armlockstate = TRUE
		proc(armlock_set) // would this work?
		addtimer(CALLBACK(src, PROC_REF(drop_armlock)), 50, TIMER_UNIQUE)
		playsound(get_turf(D), 'nsv13/sound/effects/judo_throw.ogg', 100, TRUE)
		last_move = world.time
	return TRUE

/datum/martial_art/jujitsu/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A==D)
		return FALSE //prevents grabbing yourself
	if(A.a_intent == INTENT_GRAB)
		add_to_streak("G",D)
		if(check_streak(A,D)) //doing combos is prioritized over upgrading grabs
			return TRUE
	return FALSE

/datum/martial_art/jujitsu/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	var/bonus_damage = 0
	if((A.grab_state >= GRAB_AGGRESSIVE & MOBILITY_STAND))
		bonus_damage += 5
	D.apply_damage(rand(2) + bonus_damage, A.dna.species.attack_type, affecting, def_check) // bonus damage when grabbing at least aggressively
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/jujitsu/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.pulling == D && A.grab_state >= GRAB_NECK) // LV3 hold minimum
		D.visible_message("<span class='danger'>[A] puts [D] into a chokehold!</span>", \
							"<span class='userdanger'>[A] puts you into a chokehold!</span>")
		playsound(get_turf(D), 'nsv13/sound/weapons/chokehold.ogg', 50, 1, 1)
		D.SetSleeping(200)
		return FALSE // so you don't accidentally takedown instead of knocking out
	if(!can_use(A))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE
