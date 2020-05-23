/datum/gear/donator
	subtype_path = /datum/gear/donator
	unlocktype = GEAR_DONATOR
	sort_category = "Donator"
	cost = null //Unused in this category

/datum/gear/purchase(client/C)
	//This can be used to explain the code function of the item or otherwise cover ass.
	to_chat(C, "<span class='boldwarning'>Your donator item has been added to your account. It will be removed automatically if your donation lapses.</span>")

/datum/gear/donator/example
	display_name = "Example Donator Item"
	description = "Example Donator Description"
	ckey = "jimthefish" //ckey should be in canonical format.
	path = /obj/item/toy/plush/carpplushie
