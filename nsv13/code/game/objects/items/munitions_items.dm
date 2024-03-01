///////Munitions Department Items///////

///////DEPARTMENT BUDGET CARD///////

/obj/item/card/id/departmental_budget/mun
	department_ID = ACCOUNT_MUN
	department_name = ACCOUNT_MUN_NAME
	icon_state = "budget_mun"

///////DEPARTMENT DOOR REMOTE//////

/obj/item/door_remote/master_at_arms
	name = "munitions door remote"
	icon_state = "gangtool-red"
	region_access = 8

///////ENCRYPTION KEYS///////

/obj/item/encryptionkey/atc
	name = "air traffic control radio encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_ATC = 1, RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_COMMAND = 1)
	independent = TRUE

/obj/item/encryptionkey/pilot
	name = "fighter pilot radio encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_ATC = 1, RADIO_CHANNEL_MUNITIONS = 1)
	independent = TRUE

/obj/item/encryptionkey/heads/master_at_arms
	name = "master at arms radio encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_ATC = 1)
	independent = TRUE

/obj/item/encryptionkey/heads/master_at_arms/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)
	independent = FALSE

/obj/item/encryptionkey/munitions_tech
	name = "munitions department encryption key"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_SUPPLY = 1)

///////RADIO HEADSETS//////

/obj/item/radio/headset/munitions
	name = "munitions radio headset"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	desc = "A base model for every munitions headset, even comes with ear protection!"
	icon_state = "mun_headset"
	keyslot = new /obj/item/encryptionkey/munitions_tech
	bang_protect = 1

/obj/item/radio/headset/munitions/atc
	name = "air traffic controller radio headset"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	desc = "A headset capable of accessing the Nanotrasen blue channel via a special DRADIS satellite uplink, allowing fighter pilots to communicate from anywhere inside of Nanotrasen's airspace. Use :q to access the air traffic control frequency. Use :w to access the department frequency. Use :c to access the command department frequency."
	icon_state = "mun_headset_alt"
	keyslot = new /obj/item/encryptionkey/atc

/obj/item/radio/headset/munitions/pilot
	name = "pilot radio headset"
	desc = "A headset capable of accessing the Nanotrasen blue channel via a special DRADIS satellite uplink, allowing fighter pilots to communicate from anywhere inside of Nanotrasen's airspace. Use :q to access the air traffic control frequency. Use :w to access the department frequency while on the ship."
	icon_state = "mun_headset"
	keyslot = new /obj/item/encryptionkey/pilot

/obj/item/radio/headset/heads/master_at_arms
	name = "\proper the master at arms' headset"
	desc = "Use :w to access the department frequency. Use :u to access the supply frequency. Use :c to access the command frequency. Use :q to access the ATC frequency."
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_headset_alt"
	keyslot = new /obj/item/encryptionkey/heads/master_at_arms
	bang_protect = 1

/obj/item/radio/headset/munitions/munitions_tech
	name = "munitions technician radio headset"
	desc = "Use :w to access the department frequency. Use :u to access the supply frequency."
	icon_state = "mun_headset"
	keyslot = new /obj/item/encryptionkey/munitions_tech

/obj/item/radio/headset/munitions/munitions_tech/alt
	name = "munitions technician bowmans headset"
	desc = "Use :w to access the department frequency. Use :u to access the supply frequency"
	icon_state = "mun_headset_alt"

/obj/item/radio/headset/munitions/munitions_security_alt
	name = "munitions-security bowman headset"
	desc = "The headset used by your local munitions mall cop, but with ear protection! Now you won't go deaf!"
	icon_state = "munsec_headset_alt"
	keyslot2 = new /obj/item/encryptionkey/headset_sec
	bang_protect = 1

/obj/item/radio/headset/munitions/munitions_security
	name = "munitions-security radio headset"
	desc = "The headset used by your local munitions mall cop."
	icon_state = "munsec_headset"
	keyslot2 = new /obj/item/encryptionkey/headset_sec

////////BACKPACKS////////

/obj/item/storage/backpack/duffelbag/munitions
	name = "munitions duffel bag"
	desc = "A large duffel bag for holding extra munitions supplies."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "duffel-mun"
	item_state = "duffel-mun"
	lefthand_file = 'nsv13/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/backpack_righthand.dmi'

/obj/item/storage/backpack/munitions
	name = "munitions backpack"
	desc = "A hardy oil-resistant backpack designed for use in ordanance filled environment."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "munitionspack"
	item_state = "munitionspack"
	lefthand_file = 'nsv13/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/backpack_righthand.dmi'

/obj/item/storage/backpack/satchel/munitions
	name = "munitions satchel"
	desc = "A tough satchel with extra pockets."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "satchel-mun"
	item_state = "satchel-mun"
	lefthand_file = 'nsv13/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/backpack_righthand.dmi'


//armband for midshipmen or security

/obj/item/clothing/accessory/armband/munitions
	name = "munitions guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is black and orange."
	icon_state = "muniband"


///////ATC STICKS///////
/obj/item/flashlight/atc_wavy_sticks //I dont know what theyre actually called :)
	name = "Aircraft signalling sticks"
	desc = "A large set of fluorescent sticks used to direct aircraft around the hangar bay."
	icon = 'nsv13/icons/objects/lighting.dmi'
	icon_state = "wavystick"
	item_state = "glowstick"
	w_class = WEIGHT_CLASS_SMALL
	light_range = 6
	color = LIGHT_COLOR_GREEN
	color = COLOR_RED
	grind_results = list(/datum/reagent/phenol = 15, /datum/reagent/hydrogen = 10, /datum/reagent/oxygen = 5) //Meth-in-a-stick
	actions_types = list(/datum/action/item_action/pick_color, /datum/action/item_action/toggle_light)
	var/turf/start_turf
	var/turf/end_turf

/datum/action/item_action/change_color
	name = "Toggle Light"

/obj/item/flashlight/atc_wavy_sticks/ui_action_click(mob/user, var/datum/action/A)
	if(istype(A, /datum/action/item_action/pick_color))
		if(!usr.stat)
			if(light_color == LIGHT_COLOR_GREEN)
				light_color = LIGHT_COLOR_RED
				color = COLOR_RED
			else
				light_color = LIGHT_COLOR_GREEN
				color = COLOR_GREEN
	else
		. = ..()

/obj/effect/temp_visual/dir_setting/wavystick
	icon = 'icons/mob/aibots.dmi'
	icon_state = "path_indicator"
	color = "#ccffcc" //Light green
	duration = 5 SECONDS

/obj/item/flashlight/atc_wavy_sticks/afterattack(atom/target, mob/user, proximity)
	if(!start_turf)
		start_turf = get_turf(target)
		to_chat(user, "<span class='warning'>You point [src] at [target]. Point it at another turf to form a path or alt-click [src] to cancel.</span>")
		new /obj/effect/temp_visual/impact_effect/green_laser(start_turf)
		return
	if(!end_turf)
		var/testDir = get_dir(start_turf,target)
		if((testDir in GLOB.cardinals)) //Because otherwise the icon states glitch the hell out and look disgusting
			end_turf = get_turf(target)
			addtimer(VARSET_CALLBACK(src, start_turf, null), 5 SECONDS) //Clear the path after a while
			addtimer(VARSET_CALLBACK(src, end_turf, null), 5 SECONDS) //Clear the path after a while
			visible_message("<span class='warning'>[user] waves [src] around in a controlled motion.</span>")
			var/turf/last_turf = start_turf
			for(var/turf/T in getline(start_turf,end_turf))
				var/pdir = SOUTH
				if(T == start_turf)
					pdir = testDir
				else
					pdir  = get_dir(last_turf, T)
				new /obj/effect/temp_visual/dir_setting/wavystick(T, pdir)
				last_turf = T
			return
		else
			to_chat(user, "<span class='warning'>You can only indicate in straight lines, not diagonally.</span>")
			return
	. = ..()

/obj/item/flashlight/atc_wavy_sticks/AltClick(mob/user)
	. = ..()
	if(start_turf)
		start_turf = null
		to_chat(user, "<span class='warning'>Cleared target selection</span>")
		add_fingerprint(user)
