//Helper method to compile an overlay onto a clothing object.
//@params: target: The clothing item you want to "paint". decal: The icon_state of the decal to apply (eg: suit_stripes). colour: the colour you want the decal to be, or leave this blank.

/proc/generate_clothing_overlay(obj/item/clothing/target, decal, colour)
	//Firstly, paint the stripes on the icon_state.
	target.cut_overlays()
	target.worn_icon = initial(target.worn_icon)
	var/mutable_appearance/stripes = new()
	stripes.icon = target.icon
	stripes.icon_state = decal
	stripes.color = colour
	target.add_overlay(new /mutable_appearance(stripes))
	//Next, paint the stripes onto the actual worn icon of the clothes.
	stripes.icon = target.worn_icon
	//How this works is, we're basically making a dummy clothing item that takes the appearance of the worn icon. We then rotate it around to all 4 dirs and take snapshots of it, with its overlays on. Finally, we get an icon out of it with icon_states filled with the output.
	var/obj/item/clothing/D = new()
	D.icon = target.worn_icon
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
	target.worn_icon = fcopy_rsc(final) //Manually copy over the newly generated icon, so that everyone will see it.
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
	desc = "A small device that allows you to listen to and broadcast over squad comms."
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
		squad_channel = AddComponent(S.squad_channel_type, override = TRUE)
		squad_channel.squad = squad

/obj/item/squad_pager/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		return
	apply_squad(squad)

/obj/item/squad_pager/attack_self(mob/user)
	if(!squad_channel && squad)
		squad_channel = AddComponent(squad.squad_channel_type)
		squad_channel.squad = squad
	squad_channel.show_last_message(user)

/obj/item/squad_pager/equipped(mob/equipper, slot)
	. = ..()
	if(global_access)
		return FALSE
	if(ishuman(equipper))
		var/mob/living/carbon/human/H = equipper
		if(H.squad && H.squad != squad)
			apply_squad(H.squad)

/obj/item/squad_pager/proc/apply_squad(datum/squad/squad)
	if(squad_channel)
		squad_channel.RemoveComponent()
		QDEL_NULL(squad_channel)
	cut_overlays()
	src.squad = squad //Ahoy mr squadward! Ack ack ack.
	name = "[squad] pager"
	var/mutable_appearance/stripes = new()
	stripes.icon = icon
	stripes.icon_state = "squadpager_stripes"
	stripes.color = squad.colour
	add_overlay(new /mutable_appearance(stripes))
	if(squad)
		squad_channel = AddComponent(squad.squad_channel_type)
		squad_channel.squad = squad

/obj/item/clothing/suit/ship/squad
	name = "Armour"
	desc = "A light piece of armour, designed to protect its wearer from basic workplace hazards during general quarters. It has been lined with protective materials to allow the wearer to survive in space for slightly longer than usual."
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "squad"
	w_class = 2
	armor = list("melee" = 30, "bullet" = 40, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 20, "rad" = 25, "fire" = 25, "acid" = 50)
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	var/datum/squad/squad = null

/obj/item/clothing/suit/ship/squad/space
	name = "Armoured Skinsuit"
	icon_state = "skinsuit_squad"
	w_class = WEIGHT_CLASS_NORMAL
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	slowdown = 1
	armor = list("melee" = 20, "bullet" = 30, "laser" = 5,"energy" = 0, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70, "stamina" = 10)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	equip_delay_other = 80
	resistance_flags = NONE

/obj/item/clothing/head/helmet/ship/squad
	name = "Helmet"
	desc = "A bulky helmet that's designed to keep your head in-tact while you perform essential repairs on the ship."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "squad"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list("melee" = 30, "bullet" = 40, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 20, "rad" = 25, "fire" = 25, "acid" = 50)
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	var/has_headcam = TRUE
	var/datum/squad/squad = null

/obj/item/clothing/head/helmet/ship/squad/space
	name = "Space Helmet"
	icon_state = "skinsuit_squad"
	item_state = "spaceold"
	desc = "A special helmet with solar UV shielding to protect your eyes from harmful rays. It bears a squad's insignia."
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT
	permeability_coefficient = 0.01
	armor = list("melee" = 15, "bullet" = 10, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70, "stamina" = 10)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	dynamic_hair_suffix = ""
	dynamic_fhair_suffix = ""
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = 2
	strip_delay = 50
	equip_delay_other = 50
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	resistance_flags = NONE
	dog_fashion = null

/obj/item/clothing/head/helmet/ship/squad/equipped(mob/equipper, slot)
	. = ..()
	if(ishuman(equipper))
		var/mob/living/carbon/human/H = equipper
		if(H.squad)
			if(H.squad != squad)
				apply_squad(H.squad)

/obj/item/clothing/head/helmet/ship/squad/leader
	name = "Squad Lead Helmet"
	desc = "A helmet which denotes the leader of a squad. The modern version of dead man's shoes."
	icon_state = "squad_leader"

/obj/item/clothing/neck/squad
	name = "Lanyard"
	desc = "A holographic lanyard which, when passed to someone who isn't in a squad, will allow them to join the squad registered to it!"
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "hudsquad"
	w_class = 1
	var/datum/squad/squad = null

/obj/item/clothing/neck/squad/examine( mob/user )
	. = ..()
	. += "<span class='notice'>Use the lanyard to update the appearance of the squad role indicator.</span>"

/obj/item/clothing/neck/squad/attack_self(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user) || user.stat || user.restrained())
		return
	if(!squad)
		to_chat(user, "<span class='warning'>This lanyard hasn't got a registered squad on it...</span>")
		return FALSE
	if(user.squad && user.squad == squad)
		to_chat(user, "<span class='notice'>The lanyard updates with your current squad role.</span>")
		apply_squad( user.squad )
		return FALSE
	if(alert(user, "Join [squad] Squad?",name,"Yes","No") == "Yes")
		if(user.squad)
			user.squad.remove_member(user)
		squad.add_member(user)
		apply_squad( user.squad )

/obj/item/clothing/neck/squad/Initialize(mapload, datum/squad/squad)
	. = ..()
	apply_squad(squad)


//When initialized, if passed a squad already, apply its reskin.

/obj/item/clothing/suit/ship/squad/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		addtimer(CALLBACK(src, PROC_REF(apply_squad)), 5 SECONDS)
		return
	apply_squad(squad)

/obj/item/clothing/suit/ship/squad/equipped(mob/equipper, slot)
	. = ..()
	if(ishuman(equipper))
		var/mob/living/carbon/human/H = equipper
		if(H.squad && H.squad != squad)
			apply_squad(H.squad)

/obj/item/clothing/head/helmet/ship/squad/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		addtimer(CALLBACK(src, PROC_REF(apply_squad)), 5 SECONDS)
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
	src.squad = squad
	generate_clothing_overlay(src, "[icon_state]_stripes", squad.colour)

/obj/item/clothing/head/helmet/ship/squad/proc/apply_squad(datum/squad/squad)
	var/mob/living/carbon/human/user = null
	if(!squad || !istype(squad))
		user = (ishuman(loc)) ? loc : loc.loc //Two layers of recursion should suffice in most cases. If this fails, go see the XO to get it resprayed.
		if(!ishuman(user) || !user.client || !user.squad)
			return
		squad = user.squad
	name = "[squad] [initial(name)]"
	src.squad = squad
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
		generate_clothing_overlay(src, "hudsquad_lead_stripes", squad.colour)
		return
	name = "[squad] [initial(name)]"
	icon_state = "hudsquad"
	if ( user && ishuman( user ) )
		if ( user.squad.role == MEDICAL_SQUAD )
			icon_state = "hudsquad_medic"
		else if ( user.squad.role == DC_SQUAD )
			icon_state = "hudsquad_engineer"
	generate_clothing_overlay(src, "[icon_state]_stripes", squad.colour)

//If your squad hat doesnt get stripes, but merely gets recoloured.
/obj/item/clothing/head/helmet/ship/squad/colouronly
	has_headcam = FALSE

/obj/item/clothing/head/helmet/ship/squad/colouronly/apply_squad(datum/squad/squad)
	if(!squad || !istype(squad))
		var/mob/living/carbon/human/user = (ishuman(loc)) ? loc : loc.loc //Two layers of recursion should suffice in most cases. If this fails, go see the XO to get it resprayed.
		if(!ishuman(user) || !user.client || !user.squad)
			return
		squad = user.squad
	color = squad.colour
	src.squad = squad
	name = "[squad.name] [initial(name)]"

/obj/item/clothing/head/ship/squad
	var/datum/squad/squad = null

/obj/item/clothing/head/ship/squad/equipped(mob/equipper, slot)
	. = ..()
	if(ishuman(equipper))
		var/mob/living/carbon/human/H = equipper
		if(H.squad)
			apply_squad(H.squad)

/obj/item/clothing/head/ship/squad/proc/apply_squad(datum/squad/squad)
	if(!squad || !istype(squad))
		var/mob/living/carbon/human/user = (ishuman(loc)) ? loc : loc.loc //Two layers of recursion should suffice in most cases. If this fails, go see the XO to get it resprayed.
		if(!ishuman(user) || !user.client || !user.squad)
			return
		squad = user.squad
	color = squad.colour
	src.squad = squad
	name = "[squad.name] [initial(name)]"

//Credit to CM / TGMC for this sprite!
/obj/item/clothing/head/ship/squad/colouronly/headband
	name = "Headband"
	icon_state = "squadheadband"
	desc = "A headband which bears the colour of the wearer's squad."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	dynamic_hair_suffix = "" //So it doesn't hide your hair


/obj/item/clothing/head/ship/squad/colouronly/cap
	name = "Cap"
	icon_state = "squadsoft"
	desc = "A stylish, coloured cap which bears the colour and insignia of the wearer's squad."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

//Credit goes to Eris for this sprite!

/obj/item/clothing/suit/ship/squad/bomber
	name = "Jacket"
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "squadbomber"
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

/obj/structure/inflatable/Initialize(mapload)
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
	return ..()

/obj/structure/inflatable/proc/deflate(violent=FALSE)
	set waitfor = FALSE
	playsound(src, 'sound/machines/hiss.ogg', 75, 1)
	if(violent)
		visible_message("<span class='warning'>\The [src] rapidly deflates!</span>")
		var/obj/item/inflatable/torn/R = new /obj/item/inflatable/torn(loc)
		transfer_fingerprints_to(R)
	else
		visible_message("<span class='warning'>\The [src] slowly deflates.</span>")
		animate(src, transform = transform.Scale(0.125), time = 15)
		sleep(15)
		var/obj/item/inflatable/R = new inflatable_type(loc)
		transfer_fingerprints_to(R)
		qdel(src)

/obj/structure/inflatable/attack_hand(mob/user)
	. = ..()
	if(user.stat || user.restrained())
		return
	if(alert(user, "Deflate [src]?",name,"Yes","Reconsider") == "Yes")
		deflate()

//this proc makes squad items take
/obj/item/clothing/suit/ship/squad/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed
