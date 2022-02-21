/datum/emote/living/click
	key = "click"
	key_third_person = "clicks their tongue"
	message = "clicks their tongue"
	message_ipc = "makes a click sound"
	message_moth = "clicks their mandibles"

/datum/emote/living/click/get_sound(mob/living/user)
	if(ismoth(user))
		return 'sound/creatures/rattle.ogg'
	else if(isipc(user))
		return 'sound/machines/click.ogg'
	else
		return FALSE

/datum/emote/living/zap
	key = "zap"
	key_third_person = "zaps"
	message = "zaps"

/datum/emote/living/zap/can_run_emote(mob/user, status_check = TRUE , intentional)
	. = ..()
	if(isethereal(user))
		return TRUE
	else
		return FALSE

/datum/emote/living/zap/get_sound(mob/living/user)
	if(isethereal(user))
		return 'sound/machines/defib_zap.ogg'

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

/datum/emote/living/hum
	key = "hum"
	key_third_person = "hums"
	message = "hums"

/datum/emote/living/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses"

/datum/emote/living/hiss/get_sound(mob/living/user)
	if(islizard(user))
		return pick('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg', 'sound/voice/hiss5.ogg', 'sound/voice/hiss6.ogg')
