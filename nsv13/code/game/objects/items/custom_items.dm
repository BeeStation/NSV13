/obj/item/melee/classic_baton/telescopic/stunsword
	name = "MK-1 ion current sabre"
	desc = "An exceedingly rare, nigh on priceless weapon which channels a highly unstable current of ions to produce a dazzling blade of pure energy around a durasteel blade. These weapons are highly sought after, and are only given to high ranking officers with a proven track record."
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "stunsword"
	item_state = "stunsword"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	on_stun_sound = 'nsv13/sound/effects/saberhit.ogg'
	attack_verb = list("immolated", "slashed")
	hitsound = 'sound/weapons/rapierhit.ogg'
	materials = list(/datum/material/iron = 1000)
	var/stunforce_on = 60
	var/stunforce_off = 0
	var/stunforce = 60
	on_icon_state = "stunsword_active"
	off_icon_state = "stunsword"
	on_item_state = "stunsword_active"
	force_on = 1 //Youre still getting hit by a metal thing.
	force_off = 10
	var/serial_number = 1 //Fluff. Gives it a "rare" collector's feel
	var/max_serial_number = 20

/obj/item/melee/classic_baton/telescopic/stunsword/Initialize()
	. = ..()
	serial_number = rand(1,max_serial_number)

/obj/item/melee/classic_baton/telescopic/stunsword/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This blade has a serial number: [serial_number] of [max_serial_number]</span>"

/obj/item/melee/classic_baton/telescopic/stunsword/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] raises [src] and drives it into their heart! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/melee/classic_baton/telescopic/stunsword/attack_self(mob/user)
	SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	if(on)
		flick("stunsword_ignite",src)
		visible_message("<span class='warning'>[user] swings [src] around, igniting it in the process.</span>")
		playsound(user.loc, 'nsv13/sound/effects/saberon.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You ignite [src]. Your attacks with it will now stun targets nonlethally.</span>")
		icon_state = on_icon_state
		item_state = on_item_state
		force = force_on
		stunforce = stunforce_on
		attack_verb = list("sliced", "cut", "striken", "immobilized")
		hitsound = 'nsv13/sound/effects/saberhit.ogg'
		set_light(3)
		on = FALSE
		sharpness = IS_BLUNT
	else
		flick("stunsword_extinguish",src)
		visible_message("<span class='warning'>[user] swings [src] around, extinguishing it in the process.</span>")
		playsound(user.loc, 'nsv13/sound/effects/saberoff.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You extinguish [src]. It will now physically wound targets on impact.</span>")
		item_state = "stunsword_extinguish"
		icon_state = off_icon_state
		item_state = off_icon_state
		slot_flags = ITEM_SLOT_BELT
		stunforce = stunforce_off
		force = force_off
		attack_verb = list("immolated", "slashed")
		hitsound = 'sound/weapons/rapierhit.ogg'
		set_light(0)
		on = TRUE
		sharpness = IS_SHARP

	add_fingerprint(user)

/obj/item/melee/classic_baton/telescopic/stunsword/attack(mob/living/target, mob/living/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustStaminaLoss(stunforce)
		H.apply_damage(force, BRUTE)
		user.do_attack_animation(H)
		playsound(user.loc, hitsound, 100, 1)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		target.visible_message("<span class='danger'>[user] has [pick(attack_verb)] [target] with [src]!</span>", \
								"<span class='userdanger'>[user] has [pick(attack_verb)] you with [src]!</span>")
		log_combat(user, target, "stunned")
		return
	else
		.=..()

/obj/item/reagent_containers/food/drinks/solgovcup //Credit to baystation for this sprite!
	name = "solgov branded drinks cup"
	desc = "A cup with solgov's logo clearly stamped on it. 'to remind them of whom they serve'"
	icon = 'nsv13/icons/obj/drinks.dmi'
	icon_state = "solgov"
	volume = 30
	spillable = TRUE
