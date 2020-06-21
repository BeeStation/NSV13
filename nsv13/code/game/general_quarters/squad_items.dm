//Helper method to compile an overlay onto a clothing object.
//@params: target: The clothing item you want to "paint". decal: The icon_state of the decal to apply (eg: suit_stripes). colour: the colour you want the decal to be, or leave this blank.

/proc/generate_clothing_overlay(obj/item/clothing/target, decal, colour)
	//Firstly, paint the stripes on the icon_state.
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
	target.alternate_worn_icon = final
	return final

// Squad merch! Show off that squad pride baby.
/datum/gear/squad
	subtype_path = /datum/gear/squad
	sort_category = "Squad Items"
	species_blacklist = list("plasmaman") //Envirosuit moment
	cost = 100

/datum/gear/squad/headband
	display_name = "Squad headband"
	path = /obj/item/clothing/head/ship/squad/headband

/obj/item/clothing/suit/ship/squad
	name = "Armour"
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	alternate_worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "squad"
	item_color = "squad"
	desc = "A light piece of armour, designed to protect its wearer from basic workplace hazards during general quarters. It has been lined with protective materials to allow the wearer to survive in space for slightly longer than usual."
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

//When initialized, if passed a squad already, apply its reskin.

/obj/item/clothing/suit/ship/squad/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		addtimer(CALLBACK(src, .proc/apply_squad), 2 SECONDS)
		return
	apply_squad(squad)

/obj/item/clothing/head/ship/squad/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		addtimer(CALLBACK(src, .proc/apply_squad), 2 SECONDS)
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
	generate_clothing_overlay(src, "squad_stripes", squad.colour)

/obj/item/clothing/head/ship/squad/proc/apply_squad(datum/squad/squad)
	if(!squad || !istype(squad))
		var/mob/living/carbon/human/user = (ishuman(loc)) ? loc : loc.loc //Two layers of recursion should suffice in most cases. If this fails, go see the XO to get it resprayed.
		if(!ishuman(user) || !user.client || !user.squad)
			return
		squad = user.squad
	name = "[squad] [initial(name)]"
	generate_clothing_overlay(src, "squad_stripes", squad.colour)

/obj/item/clothing/head/ship/squad/headband
	name = "Headband"
	icon_state = "squadheadband"
	item_color = "squadheadband"
	desc = "A headband which bears the colour of the wearer's squad."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	dynamic_hair_suffix = "" //So it doesn't hide your hair

/obj/item/clothing/head/ship/squad/headband/apply_squad(datum/squad/squad)
	if(!squad || !istype(squad))
		var/mob/living/carbon/human/user = (ishuman(loc)) ? loc : loc.loc //Two layers of recursion should suffice in most cases. If this fails, go see the XO to get it resprayed.
		if(!ishuman(user) || !user.client || !user.squad)
			return
		squad = user.squad
	color = squad.colour
	name = "[squad.name] [initial(name)]"