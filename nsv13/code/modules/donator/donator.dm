/*

NSV13 Donator Item Definitions

*/


//Ceyella

/datum/gear/donator/ceyella
	display_name = "Crystalline Sword"
	ckey = "ceyella"
	path = /obj/item/donator_reskin/ceyella

/obj/item/donator_reskin/ceyella
	ckey = "ceyella"
	requisite_type = /obj/item/melee/classic_baton/telescopic

/obj/item/donator_reskin/ceyella/apply_reskin(obj/item/melee/classic_baton/telescopic/A)
	if(!istype(A))
		return
	playsound(src, 'sound/effects/spray.ogg', 5, 1, 5)
	A.icon = reskin_icon
	A.name = "Crystalline sword"
	A.desc = "A sword made out of an otherworldy crystal which hums gently as you hold it."
	A.icon_state = "ceyellasword_off"
	A.on_icon_state = "ceyellasword"
	A.off_icon_state = "ceyellasword_off"
	A.hitsound = 'sound/weapons/rapierhit.ogg'
	A.lefthand_file = 'nsv13/icons/mob/inhands/weapons/melee_lefthand.dmi'
	A.righthand_file = 'nsv13/icons/mob/inhands/weapons/melee_righthand.dmi'
	A.on_item_state = "ceyellasword"
	A.item_state = "ceyellasword_off"
	A.AddComponent(/datum/component/donator, ckey)
	qdel(src)
