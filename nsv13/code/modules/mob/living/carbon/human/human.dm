/mob/living/carbon/human/handle_high_gravity(gravity)
	if(!wear_suit || !head)
		return ..()
	if(!istype(wear_suit, /obj/item/clothing/suit/space/hardsuit) || !istype(head, /obj/item/clothing/head/helmet/space/hardsuit))
		return ..()
	if(istype(wear_suit, /obj/item/clothing/suit/space/hardsuit/skinsuit) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/skinsuit)) //I dislike these being hardsuit subtypes.
		return ..()
	gravity -= 1 //Wearing a full hardsuit gives you 1G of bonus grav tolerance, at least in how much your body can withstand. Movement is very difficult regardless.
	if(gravity <= 1) //This is fine.
		return
	return ..()
