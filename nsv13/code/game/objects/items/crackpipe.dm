/obj/item/clothing/mask/cigarette/pipe/crackpipe
	name = "crackpipe"
	desc = "A glass pipe used to smoke drugs, or other things."
	icon = 'nsv13/icons/obj/clothing/masks.dmi'
	item_state = "crackpipe_item"
	icon_state = "crackpipe"
	icon_off = "crackpipe"
	icon_on = "crackpipe"

/obj/item/clothing/mask/cigarette/pipe/crackpipe/afterattack(obj/item/reagent_containers/glass/glass, mob/user, proximity)//literally just ripped from cig code cause i suck
	. = ..()
	if(!proximity || lit) //can't dip if cigarette is lit (it will heat the reagents in the glass instead)
		return
	if(istype(glass))	//you can dip cigarettes into beakers
		if(glass.reagents.trans_to(src, chem_volume, transfered_by = user))	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You fill \the [src] from \the [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>The [glass] is empty.</span>")
			else
				to_chat(user, "<span class='notice'>The [src] is full.</span>")

/obj/machinery/vending/cigarette/Initialize()
	contraband += list(/obj/item/clothing/mask/cigarette/crackpipe = 1)
	. = ..()
