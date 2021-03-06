//Return TRUE if the item makes you float
/obj/item/proc/check_float(mob/living/holder)
	return FALSE

/obj/item/twohanded/required/pool
	icon = 'nsv13/icons/obj/pool.dmi'
	lefthand_file = 'nsv13/icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/items_righthand.dmi'
	force = 0
	damtype = STAMINA
	force_unwielded = 0
	force_wielded = 5
	wieldsound = 'sound/weapons/tap.ogg'
	unwieldsound = 'sound/weapons/tap.ogg'
	w_class = WEIGHT_CLASS_BULKY
	block_sound = 'sound/weapons/tap.ogg'
	block_level = 1
	block_upgrade_walk = 0
	block_power = 0
	block_power_wielded = 20
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	attack_verb = list("wacked", "bonked")

/obj/item/twohanded/required/pool/Initialize()
	. = ..()
	AddComponent(/datum/component/twohanded/required, force_unwielded, force_wielded, wieldsound, unwieldsound)
	//Pick a random color
	color = pick(COLOR_YELLOW, COLOR_LIME, COLOR_RED, COLOR_BLUE_LIGHT, COLOR_CYAN, COLOR_MAGENTA, COLOR_PUCE)

/obj/item/twohanded/required/pool/check_float(mob/living/holder)
	var/wielded = SEND_SIGNAL(src, COMSIG_ITEM_IS_WIELDED) & COMPONENT_WIELDED
	if(wielded)
		return TRUE
	return FALSE

/obj/item/twohanded/required/pool/rubber_ring
	name = "inflatable ring"
	desc = "An inflatable ring used for keeping people afloat. Throw it at drowning people to save them."
	icon_state = "rubber_ring"

/obj/item/twohanded/required/pool/rubber_ring/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		//Make sure they are in a pool
		if(!istype(get_turf(H), /turf/open/indestructible/sound/pool))
			return
		//Make sure they are alive and can pick it up
		if(H.stat)
			return
		//Try shove it in their inventory
		if(H.put_in_active_hand(src))
			visible_message("<span class='notice'>The [src] lands over [H]'s head!</span>")

/obj/item/twohanded/required/pool/pool_noodle
	icon_state = "pool_noodle"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/melee_righthand.dmi'
	name = "pool noodle"
	desc = "A long noodle made of foam. Helping those with fears of swimming swim since the 1980s."
	var/suiciding = FALSE

/obj/item/twohanded/required/pool/pool_noodle/attack(mob/target, mob/living/carbon/human/user)
	. = ..()
	var/wielded  = SEND_SIGNAL(src, COMSIG_ITEM_IS_WIELDED) & COMPONENT_WIELDED
	if(wielded && prob(50))
		INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/twohanded/required/pool/pool_noodle/proc/jedi_spin(mob/living/user) //rip complex code, but this fucked up blocking
	user.emote("flip")

/obj/item/twohanded/required/pool/pool_noodle/suicide_act(mob/user)
	if(suiciding)
		return SHAME
	suiciding = TRUE
	user.visible_message("<span class='notice'>[user] begins kicking their legs to stay afloat!</span>")
	var/mob/living/L = user
	if(istype(L))
		L.Immobilize(63)
	animate(user, time=20, pixel_y=18)
	sleep(20)
	animate(user, time=10, pixel_y=12)
	sleep(10)
	user.visible_message("<span class='notice'>[user] keeps swimming higher and higher!</span>")
	animate(user, time=10, pixel_y=22)
	sleep(10)
	animate(user, time=10, pixel_y=16)
	sleep(10)
	animate(user, time=15, pixel_y=32)
	sleep(15)
	user.visible_message("<span class='suicide'>[user] suddenly realised they aren't in the water and cannot float.</span>")
	animate(user, time=1, pixel_y=0)
	sleep(1)
	user.ghostize()
	user.gib()
	suiciding = FALSE
	return MANUAL_SUICIDE
