//Helper method to compile an overlay onto a clothing object.
//@params: target: The clothing item you want to "paint". decal: The icon_state of the decal to apply (eg: suit_stripes). colour: the colour you want the decal to be, or leave this blank.

/proc/generate_clothing_overlay(obj/item/clothing/target, decal, colour)
	//Firstly, paint the stripes on the icon_state.
	target.cut_overlays()
	target.alternate_worn_icon = initial(target.alternate_worn_icon)
	var/mutable_appearance/stripes = new()
	stripes.icon = target.icon
	stripes.icon_state = decal
	stripes.color = colour
	target.add_overlay(new /mutable_appearance(stripes))
	//Next, paint the stripes onto the actual worn icon of the clothes.
	stripes.icon = target.alternate_worn_icon
	//How this works is, we're basically making a dummy clothing item that takes the appearance of the worn icon. We then rotate it around to all 4 dirs and take snapshots of it, with its overlays on. Finally, we get an icon out of it with icon_states filled with the output.
	var/obj/item/clothing/D = new()
	D.icon = target.alternate_worn_icon
	D.icon_state = target.icon_state
	var/icon/final = icon()
	for(var/dir in list(2, 1, 4, 8)) //A little bit hacky, but does the trick. BYOND's icon format starts with a south facing dir, while cardinals starts with NORTH.
		CHECK_TICK
		stripes.dir = dir
		D.setDir(dir) //Set the dir of the mannequin to face the next direction
		D.cut_overlays()
		D.add_overlay(new /mutable_appearance(stripes))
		COMPILE_OVERLAYS(D) //Prepare it for an image capture
		var/icon/I = icon(getFlatIcon(D), frame = 1) //And finally clone the appearance of our new dummy character.
		final.Insert(I, target.icon_state, frame=1, dir=dir) //Then, we add this new icon_state and direction to the icon we're generating. This is then cleanly applied to the dummy mob to give it its appearance.
	target.alternate_worn_icon = fcopy_rsc(final) //Manually copy over the newly generated icon, so that everyone will see it.
	return final

// Squad merch! Show off that squad pride baby.
/datum/gear/squad
	subtype_path = /datum/gear/squad
	sort_category = "Squad Items"
	species_blacklist = list("plasmaman") //Envirosuit moment
	cost = 100

/datum/gear/squad/headband
	display_name = "Squad headband"
	path = /obj/item/clothing/head/ship/squad/colouronly/headband
	slot = ITEM_SLOT_HEAD

/datum/gear/squad/jacket
	display_name = "Squad jacket"
	path = /obj/item/clothing/suit/ship/squad/bomber
	slot = ITEM_SLOT_OCLOTHING

/datum/gear/squad/cap
	display_name = "Squad cap"
	path = /obj/item/clothing/head/ship/squad/colouronly/cap
	slot = ITEM_SLOT_HEAD

/obj/item/squad_pager
	name = "squad pager"
	desc = "A small device that allows you to listen to and broadcast over squad comms. Use :f to page your squad with a message."
	icon = 'nsv13/icons/obj/squad.dmi'
	icon_state = "squadpager"
	w_class = 1
	slot_flags = ITEM_SLOT_BELT
	var/datum/component/simple_teamchat/radio_dependent/squad/squad_channel = null
	var/datum/squad/squad = null
	var/global_access = FALSE


/obj/item/squad_pager/all_channels
	name = "Global Squad Pager"
	desc = "A pager that's tuned to every single squad's comms simultaneously, allowing for overwatch to communicate with shipside fireteams more efficiently."
	global_access = TRUE

/obj/item/squad_pager/all_channels/Initialize(mapload, datum/squad/squad)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/squad_pager/all_channels/LateInitialize()
	. = ..()
	//Lets you choose any squad to message, at any time.
	for(var/datum/squad/S in GLOB.squad_manager.squads)
		squad_channel = src.AddComponent(S.squad_channel_type)
		squad_channel.squad = squad

/obj/item/squad_pager/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		return
	apply_squad(squad)

/obj/item/squad_pager/proc/apply_squad(datum/squad/squad)
	squad_channel?.RemoveComponent()
	qdel(squad_channel)
	cut_overlays()
	src.squad = squad //Ahoy mr squadward! Ack ack ack.
	name = "[squad] pager"
	var/mutable_appearance/stripes = new()
	stripes.icon = icon
	stripes.icon_state = "squadpager_stripes"
	stripes.color = squad.colour
	add_overlay(new /mutable_appearance(stripes))
	if(squad)
		squad_channel = src.AddComponent(squad.squad_channel_type)
		squad_channel.squad = squad

/obj/item/clothing/suit/ship/squad
	name = "Armour"
	desc = "A light piece of armour, designed to protect its wearer from basic workplace hazards during general quarters. It has been lined with protective materials to allow the wearer to survive in space for slightly longer than usual."
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	alternate_worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "squad"
	item_color = "squad"
	w_class = 2
	armor = list("melee" = 30, "bullet" = 40, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 20, "rad" = 25, "fire" = 25, "acid" = 50)
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET

/obj/item/clothing/head/ship/squad
	name = "Helmet"
	desc = "A bulky helmet that's designed to keep your head in-tact while you perform essential repairs on the ship."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	alternate_worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "squad"
	item_color = null
	w_class = 1
	armor = list("melee" = 30, "bullet" = 40, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 20, "rad" = 25, "fire" = 25, "acid" = 50)
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/neck/squad
	name = "Lanyard"
	desc = "A lanyard which can clearly identify someone as a member of a given squad. <i>Click it while it's in your hand to update its registered squad.</i>"
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	alternate_worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "hudsquad"
	item_color = "hudsquad"
	w_class = 1
	var/next_squad_change = 0
	var/datum/squad/squad = null

/obj/item/clothing/neck/squad/GetAccess()
	return (GLOB.security_level >= SEC_LEVEL_RED) ? squad?.access : list()

/obj/item/storage/box/squad_lanyards
	name = "Spare squad lanyards"
	desc = "A box filled with lanyards for assigning personnel into squads. Repaint them using the squad management console and pass them out."

/obj/item/storage/box/squad_lanyards/PopulateContents()
	for(var/I = 0; I < 10; I++){
		new /obj/item/clothing/neck/squad(src)
	}

/obj/item/clothing/neck/squad/attack_self(mob/living/user)
	. = ..()
	if(!ishuman(user))
		return
	if(world.time < next_squad_change)
		to_chat(user, "<span class='sciradio'>[src]'s holographics circuits are recharging.</span>")
		return
	var/mob/living/carbon/human/H = user
	if(src.squad)
		if(src.squad != H.squad)
			var/answer = alert(usr, "Join [src.squad]?",name,"Yes","No")
			if(answer == "Yes")
				if(H.squad)
					H.squad -= H
				H.squad = squad
				H.squad += H
	if(H.squad)
		apply_squad(H.squad)
		next_squad_change = world.time + 10 SECONDS
		to_chat(user, "<span class='notice'>Squad insignia updated. Holographic circuits recharging.</span>")
		return

//When initialized, if passed a squad already, apply its reskin.

/obj/item/clothing/suit/ship/squad/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		addtimer(CALLBACK(src, .proc/apply_squad), 5 SECONDS)
		return
	apply_squad(squad)

/obj/item/clothing/head/ship/squad/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		addtimer(CALLBACK(src, .proc/apply_squad), 5 SECONDS)
		return
	apply_squad(squad)

/obj/item/clothing/neck/squad/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		addtimer(CALLBACK(src, .proc/apply_squad), 5 SECONDS)
		return
	apply_squad(squad)

//Methods to let you reskin a piece of squad clothing to whatever squad's colours you wish.

/obj/item/clothing/suit/ship/squad/proc/apply_squad(datum/squad/squad)
	if(!squad || !istype(squad))
		var/mob/living/carbon/human/user = (ishuman(loc)) ? loc : loc.loc //Two layers of recursion should suffice in most cases. If this fails, go see the XO to get it resprayed.
		if(!ishuman(user) || !user.client || !user.squad)
			return
		squad = user.squad
	name = "[squad] [initial(name)]"
	generate_clothing_overlay(src, "[icon_state]_stripes", squad.colour)

/obj/item/clothing/head/ship/squad/proc/apply_squad(datum/squad/squad)
	if(!squad || !istype(squad))
		var/mob/living/carbon/human/user = (ishuman(loc)) ? loc : loc.loc //Two layers of recursion should suffice in most cases. If this fails, go see the XO to get it resprayed.
		if(!ishuman(user) || !user.client || !user.squad)
			return
		squad = user.squad
	name = "[squad] [initial(name)]"
	generate_clothing_overlay(src, "[icon_state]_stripes", squad.colour)

/obj/item/clothing/neck/squad/proc/apply_squad(datum/squad/squad)
	var/mob/living/carbon/human/user = (ishuman(loc)) ? loc : loc.loc //Two layers of recursion should suffice in most cases. If this fails, go see the XO to get it resprayed.
	if(!squad || !istype(squad))
		if(!ishuman(user) || !user.client || !user.squad)
			return
		squad = user.squad
	src.squad = squad
	if(user && squad.leader == user)
		name = "[squad] Leader Lanyard"
		icon_state = "hudsquad_lead"
		item_color = "hudsquad_lead"
		generate_clothing_overlay(src, "hudsquad_lead_stripes", squad.colour)
		return
	name = "[squad] [initial(name)]"
	icon_state = "hudsquad"
	item_color = "hudsquad"
	generate_clothing_overlay(src, "[icon_state]_stripes", squad.colour)

//If your squad hat doesnt get stripes, but merely gets recoloured.
/obj/item/clothing/head/ship/squad/colouronly

/obj/item/clothing/head/ship/squad/colouronly/apply_squad(datum/squad/squad)
	if(!squad || !istype(squad))
		var/mob/living/carbon/human/user = (ishuman(loc)) ? loc : loc.loc //Two layers of recursion should suffice in most cases. If this fails, go see the XO to get it resprayed.
		if(!ishuman(user) || !user.client || !user.squad)
			return
		squad = user.squad
	color = squad.colour
	name = "[squad.name] [initial(name)]"

//Credit to CM / TGMC for this sprite!

/obj/item/clothing/head/ship/squad/colouronly/headband
	name = "Headband"
	icon_state = "squadheadband"
	item_color = "squadheadband"
	desc = "A headband which bears the colour of the wearer's squad."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	dynamic_hair_suffix = "" //So it doesn't hide your hair


/obj/item/clothing/head/ship/squad/colouronly/cap
	name = "Cap"
	icon_state = "squadsoft"
	item_color = "squadsoft"
	desc = "A stylish, coloured cap which bears the colour and insignia of the wearer's squad."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

//Credit goes to Eris for this sprite!

/obj/item/clothing/suit/ship/squad/bomber
	name = "Jacket"
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	alternate_worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "squadbomber"
	item_color = "squadbomber"
	desc = "A stylish jacket bearing a squad's insignia and distinctive colours."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	body_parts_covered = CHEST

//DC stuff:

//Legally not flex seal. We promise.

/obj/item/sealant
	name = "Flexi seal"
	desc = "A neat spray can that can repair torn inflatable segments, and more!"
	icon = 'nsv13/icons/obj/inflatable.dmi'
	icon_state = "sealant"
	w_class = 1

/obj/item/inflatable
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. Click a tile with it to place a temporary wall there."
	icon = 'nsv13/icons/obj/inflatable.dmi'
	icon_state = "folded_wall"
	w_class = 1
	var/inflatable_type = /obj/structure/inflatable
	var/torn = FALSE

/obj/item/inflatable/torn
	name = "torn inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. It is too torn to be usable, but could be patched up with some sealant."
	icon = 'nsv13/icons/obj/inflatable.dmi'
	icon_state = "folded_wall_torn"
	torn = TRUE

/obj/item/inflatable/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/sealant))
		if(!torn)
			return
		if (do_after(user,5 SECONDS, target = src))
			playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
			to_chat(user, "<span class='notice'>You seal up [src], good as new!</span>")
			torn = FALSE
			name = "inflatable wall"
			desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
			icon_state = "folded_wall"

/obj/item/inflatable/attack_self(mob/user)
	. = ..()
	if(torn)
		return
	inflate(get_turf(user), user)

/obj/item/inflatable/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(torn)
		return
	inflate(get_turf(target), user)

/obj/item/inflatable/proc/inflate(turf/target, mob/user)
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	to_chat(user, "<span class='notice'>You inflate [src].</span>")
	var/obj/structure/inflatable/R = new inflatable_type(target)
	src.transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/inflatable
	name = "inflatable wall"
	desc = "An inflated membrane used by damage control teams to contain pressure damage though it comes apart easily under duress. Do not puncture."
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	CanAtmosPass = ATMOS_PASS_DENSITY
	obj_integrity = 25
	max_integrity = 25

	icon = 'nsv13/icons/obj/inflatable.dmi'
	icon_state = "wall"
	var/inflatable_type = /obj/item/inflatable

/obj/structure/inflatable/Initialize()
	. = ..()
	air_update_turf(TRUE)

/obj/structure/inflatable/obj_destruction()
	deflate(TRUE)
	return ..()

/obj/structure/inflatable/attackby(obj/item/W, mob/user, params)
	if(W.is_sharp() || is_pointed(W))
		visible_message("<span class='danger'>[user] pierces [src] with [W]!</span>")
		deflate(1)
		qdel(src)
	if(istype(W, /obj/item/sealant))
		if(obj_integrity >= max_integrity)
			return
		to_chat(user, "<span class='notice'>You start filling up the holes in [src]...</span>")
		if (do_after(user,5 SECONDS, target = src))
			playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
			to_chat(user, "<span class='notice'>You seal up [src], good as new!</span>")
			obj_integrity = max_integrity
	. = ..()

/obj/structure/inflatable/proc/deflate(violent=FALSE)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(violent)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/torn/R = new /obj/item/inflatable/torn(loc)
		src.transfer_fingerprints_to(R)
	else
		visible_message("[src] slowly deflates.")
		transform = new /matrix()
		for(var/I = 0; I < 3; I ++){
			transform = transform.Scale(0.5)
			sleep(0.5 SECONDS)
		}
		var/obj/item/inflatable/R = new inflatable_type(loc)
		src.transfer_fingerprints_to(R)
		qdel(src)

/obj/structure/inflatable/attack_hand(mob/user)
	. = ..()
	if(user.stat || user.restrained())
		return
	if(alert(user, "Deflate [src]?",name,"Yes","Reconsider") == "Yes")
		deflate()
