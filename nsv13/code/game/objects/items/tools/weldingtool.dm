// Welding tool upgrade for Cyborgs

/obj/item/weldingtool/experimental/cyborg
	name = "integrated experimental welding tool"
	desc = "An experimental welder designed to be used in robotic systems. Custom framework doubles the speed of welding."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "indwelder_cyborg"
	toolspeed = 0.5

/obj/item/weldingtool/experimental/cyborg/cyborg_unequip(mob/user)
	if(!isOn())
		return
	switched_on(user)