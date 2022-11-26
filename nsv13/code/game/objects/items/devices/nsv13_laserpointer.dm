/obj/item/laser_pointer/random
	name = "\improper laser pointer"
	icon_state = "debug"
	desc = "How... how do you even shine this in your eyes? (You should contact your friendly neighborhood coders if you somehow encountered this!"

/obj/item/laser_pointer/random/Initialize()
	var laser_type = pick(subtypesof(/obj/item/laser_pointer/) - /obj/item/laser_pointer/random/)
	new laser_type(loc)
	return INITIALIZE_HINT_QDEL
