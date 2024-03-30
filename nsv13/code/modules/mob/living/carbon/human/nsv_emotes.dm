/datum/emote/living/purr
	key = "purr"
	key_third_person = "purrs"
	message = "purrs"

//This is going to piss so many people off, I can't wait.
/datum/emote/living/purr/can_run_emote(mob/user, status_check = TRUE , intentional)
	. = ..()
	if(iscatperson(user))
		return TRUE
	else
		return FALSE

/datum/emote/living/purr/get_sound(mob/living/user)
	if(iscatperson(user))
		return 'nsv13/sound/misc/coals_purr.ogg'

/datum/emote/living/growl
	key = "growl"
	key_third_person = "growls"
	message = "growls"

/datum/emote/living/growl/get_sound(mob/living/user)
	if(islizard(user))
		return 'nsv13/sound/voice/lizard/liz_growl.ogg'

/datum/emote/living/cheers
	key = "cheers"
	key_third_person = "cheers"
	message = "raises their glass"

/datum/emote/living/cheers/can_run_emote(mob/user, status_check = TRUE , intentional)
	. = ..()
	if(istype(user.get_active_held_item(), /obj/item/reagent_containers/food/drinks/drinkingglass))
		return TRUE
	else
		to_chat(user, "<span class='warning'>You don't have a glass in your hand!</span>")
		return FALSE
