/obj/item/toy/plush/random
	name = "\improper Random Plush"
	icon_state = "debug"
	desc = "Oh no! What have you done! (if you see this, contact an upper being as soon as possible)."

/obj/item/toy/plush/random/Initialize()
	var/plush_type = pick(subtypesof(/obj/item/toy/plush/) - /obj/item/toy/plush/random/)
	new plush_type(loc)
	return INITIALIZE_HINT_QDEL
