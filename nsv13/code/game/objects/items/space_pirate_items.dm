//Radio Stuff

/obj/item/radio/headset/pirate
	name = "space pirate radio headset"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	desc = "Use :z to access the Space Pirate frequency"
	icon_state = "pirate_headset"
	keyslot = new /obj/item/encryptionkey/pirate
	//freqlock = TRUE

/obj/item/encryptionkey/pirate
	name = "space pirate radio encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "pirate_cypherkey"
	channels = list(RADIO_CHANNEL_PIRATE = 1)
	independent = TRUE

//Portable lootening
/obj/item/loot_locator
	name = "Mobile Loot Locator"
	desc = "This sophisticated machine scans the nearby space for items of value."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/cooldown = 500
	var/next_use = 0

/obj/item/loot_locator/interact(mob/user)
	if(world.time <= next_use)
		to_chat(user,"<span class='warning'>[src] is recharging.</span>")
		return
	next_use = world.time + cooldown
	var/atom/movable/AM = find_random_loot()
	if(!AM)
		say("No valuables located. Try again later.")
	else
		say("Located: [AM.name] at [get_area_name(AM)]")

/obj/item/loot_locator/proc/find_random_loot()
	if(!GLOB.exports_list.len)
		setupExports()
	var/list/possible_loot = list()
	for(var/datum/export/pirate/E in GLOB.exports_list)
		possible_loot += E
	var/datum/export/pirate/P
	var/atom/movable/AM
	while(!AM && possible_loot.len)
		P = pick_n_take(possible_loot)
		AM = P.find_loot()
	return AM

//Clothes
/obj/item/clothing/suit/space/pirate/boarder
	name = "space pirate vested spacesuit"
	desc = "Yarr."
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	alternate_worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "spacepirate_vest"
	item_state = "spacepirate_vest"
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	slowdown = 1

/obj/item/clothing/suit/space/pirate/boarder/lead
	name = "space pirate coated spacesuit"
	desc = "Yarr."
	icon_state = "spacepirate_jacket"
	item_state = "spacepirate_jacket"

/obj/item/clothing/head/helmet/space/pirate/boarder
	name = "space pirate hatted space helmet"
	desc = "Yarr."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	alternate_worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "spacepirate_hat"
	item_state = "spacepirate_hat"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/helmet/space/pirate/bandana/boarder
	name = "space pirate bandanaed space helmet"
	desc = "Yarr."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	alternate_worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "spacepirate_bandana"
	item_state = "spacepirate_bandana"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
