/obj/item/ship_weapon/ammunition/countermeasure_charge //A single use of the countermeasure system
	name = "Countermeasure Charge" //temp
	desc = "words" //temp
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff" //temp
	w_class = 4
//	projectile_type = //temp

/obj/item/ship_weapon/ammunition/countermeasure_charge/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)