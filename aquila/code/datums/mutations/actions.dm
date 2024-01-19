/datum/mutation/human/tentacle
	name = "Tentacle Arm"
	desc = "A horrific mutation that gives the user the abilitiy to turn their arm into tentacle made out of muscle and tendons."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = "<span class='notice'>Your arms feel stretchy.</span>"
	text_lose_indication = "<span class='warning'>Your arms feel solid again.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/targeted/conjure_item/tentacle

/obj/effect/proc_holder/spell/targeted/conjure_item/tentacle
	name = "Tentacle"
	desc = "A fleshy tentacle that can stretch out and grab things or people, just like in the chinesee cartoons."
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "tentacle"
	charge_max = 50
	cooldown_min = 50
	clothes_req = FALSE
	item_type = /obj/item/gun/magic/tentacle_mutation

/obj/item/gun/magic/tentacle_mutation
	name = "tentacle"
	desc = "A fleshy tentacle that can stretch out and grab things or people."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "tentacle"
	item_state = "tentacle"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL | NOBLUDGEON
	flags_1 = NONE
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = NONE
	ammo_type = /obj/item/ammo_casing/magic/tentacle
	fire_sound = 'sound/effects/splat.ogg'
	force = 0
	max_charges = 1
	fire_delay = 1
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	requires_wielding = FALSE

/obj/item/gun/magic/tentacle_mutation/Initialize(mapload, silent)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "genetics")
	if(ismob(loc))
		if(!silent)
			loc.visible_message("<span class='warning'>[loc.name]\'s arm starts stretching inhumanly!</span>", "<span class='warning'>Your arm twists and mutates, transforming it into a tentacle.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
		else
			to_chat(loc, "<span class='notice'>You prepare to extend a tentacle.</span>")

/obj/item/gun/magic/tentacle_mutation/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='warning'>The [name] is not ready yet.</span>")

/obj/item/gun/magic/tentacle_mutation/process_chamber()
	. = ..()
	if(charges == 0)
		qdel(src)

/obj/item/gun/magic/tentacle_mutation/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] coils [src] tightly around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/***************************************\
|***********ARMBLADE MUTATION***********|
\***************************************/
/datum/mutation/human/armblade
	name = "Arm Blade"
	desc = "A horrific mutation that gives user the ability to turn their arm into a grotesque blade made of bone and flesh."
	locked = TRUE
	text_gain_indication = "<span class='warning'>You feel bones in your arm painfully reforming!</span>"
	text_lose_indication = "<span class='warning'>Your arms painfully reform back to normal.</span>"
	instability = 35
	power = /obj/effect/proc_holder/spell/targeted/conjure_item/armblade

/obj/effect/proc_holder/spell/targeted/conjure_item/armblade
	name = "Arm Blade"
	desc = "Reform one of your arms into a deadly blade."
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "armblade"
	charge_max = 50
	cooldown_min = 20
	item_type = /obj/item/melee/arm_blade_mut

/obj/item/melee/arm_blade_mut //nowy obiekt, bo bazowanie klasy o /obj/item/melee/arm_blade jest w chuj nieporęczne. wymagałoby nadpisania kilku funkcji w bardzo nieprzyjemny sposób
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter. This one doesn't look sturdy enough to force an airlock."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	w_class = WEIGHT_CLASS_HUGE
	force = 20 //this is an undroppable melee weapon. should not be better than the fireaxe
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	block_power = 20
	block_level = 1
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	sharpness = IS_SHARP

/obj/item/melee/arm_blade_mut/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "genetics")
	AddComponent(/datum/component/butchering, 60, 80)

/obj/item/melee/arm_blade_mut/equipped(mob/user, slot)
	. = ..()
	user.visible_message("<span class='warning'>A grotesque blade forms around [user.name]\'s arm!</span>", "<span class='warning'>Your arm twists and mutates, transforming it into a deadly blade.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
	playsound(user, 'sound/effects/blobattack.ogg', 30, 1)

/obj/item/melee/arm_blade_mut/dropped(mob/user, slot)
	. = ..()
	user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms [user.p_their()] blade into an arm!</span>", "<span class='notice'>You assimilate the blade back into your body.</span>", "<span class='italics>You hear organic matter ripping and tearing!</span>")
	playsound(user, 'sound/effects/blobattack.ogg', 30, 1)

/*************************************\
|***********VORE MUTATION*************|
\*************************************/
/datum/mutation/human/vore //ta mutacja to nie byl moj pomysl, miejcie pretensje do jokura
	name = "Matter Eater"
	desc = "A mutation that gives a subject the ability to eat anything around them whole."
	quality = POSITIVE
	text_gain_indication = "<span class='warning'>You feel extremely hungry!</span>"
	text_lose_indication = "<span class='notice'>You feel satied once again.</span>"
	difficulty = 14
	instability = 35
	power = /obj/effect/proc_holder/spell/targeted/vore

/obj/effect/proc_holder/spell/targeted/vore
	name = "Eat Matter"
	desc = "Eat the item you're currently holding or puke out the item you ate."
	action_icon = 'aquila/icons/mob/actions/actions_spells.dmi'
	action_icon_state = "stomach"
	charge_max = 40
	cooldown_min = 20
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	var/obj/item/eaten_item = null

/obj/effect/proc_holder/spell/targeted/vore/cast(mob/living/user = usr)
	var/obj/item/helditem = user.get_active_held_item()
	if(eaten_item && eaten_item.loc == src)
		eaten_item.forceMove(user.loc)
		user.visible_message("<span class='notice'>[user] spits [eaten_item] out!</span>", "<span class='notice'>You spit [eaten_item] out!</span>")
		playsound(user, 'sound/effects/splat.ogg', 50, 1)
		eaten_item = null
		return
	if(helditem && helditem.w_class > WEIGHT_CLASS_NORMAL)
		user.visible_message("<span class='notice'>[user] tries to put [helditem] into their mouth, but fails miserably!</span>", "<span class='warning'>[helditem] is too big for you to eat!</span>")
		return
	if(helditem)
		eaten_item = helditem
		helditem.forceMove(src)
		user.visible_message("<span class='notice'>[user] swallows [eaten_item] whole!</span>", "<span class='notice'>You swallow [eaten_item] whole!</span>")
		playsound(user, 'sound/effects/attackblob.ogg', 50, 1)
		return
	to_chat(user,"<span class='warning'>You're not holding anything.</span>")

/obj/effect/proc_holder/spell/targeted/vore/Destroy()
	if(eaten_item)
		eaten_item.forceMove(usr.loc)
		usr.visible_message("<span class='notice'>[usr] spits [eaten_item] out!</span>", "<span class='notice'>You spit [eaten_item] out!</span>")
		playsound(usr, 'sound/effects/splat.ogg', 50, 1)
	return ..()

