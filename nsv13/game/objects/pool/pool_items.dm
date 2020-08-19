//Return TRUE if the item makes you float
/obj/item/proc/check_float(mob/living/holder)
	return FALSE

/obj/item/twohanded/pool_noodle
	icon = 'nsv13/icons/obj/pool.dmi'
	icon_state = "pool_noodle"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/melee_righthand.dmi'
	name = "pool noodle"
	desc = "A long noodle made of foam. Helping those with fears of swimming swim since the 1980s."
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

/obj/item/twohanded/pool_noodle/Initialize()
	. = ..()
	AddComponent(/datum/component/twohanded, force_unwielded, force_wielded, wieldsound, unwieldsound)
	//Pick a random color
	color = pick(COLOR_YELLOW, COLOR_GREEN, COLOR_RED, COLOR_BLUE, COLOR_CYAN, COLOR_PINK)

/obj/item/twohanded/pool_noodle/attack(mob/target, mob/living/carbon/human/user)
	. = ..()
	var/wielded  = SEND_SIGNAL(src, COMSIG_ITEM_IS_WIELDED) & COMPONENT_WIELDED
	if(wielded && prob(50))
		INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/twohanded/pool_noodle/proc/jedi_spin(mob/living/user) //rip complex code, but this fucked up blocking
	user.emote("flip")

/obj/item/twohanded/pool_noodle/check_float(mob/living/holder)
	var/wielded = SEND_SIGNAL(src, COMSIG_ITEM_IS_WIELDED) & COMPONENT_WIELDED
	if(wielded)
		return TRUE
	return FALSE
