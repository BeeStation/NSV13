/obj/item/ship_weapon/ammunition/countermeasure_charge //A single use of the countermeasure system
	name = "\improper Countermeasure Tri-Charge" //temp
	desc = "A tri-charge of countermeasure chaff for a fighter" //temp
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff" //temp
	w_class = 4

/obj/item/ship_weapon/ammunition/countermeasure_charge/Initialize()
	..()
	AddComponent(/datum/component/twohanded/required)
