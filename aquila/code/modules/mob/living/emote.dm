
/datum/emote/living/choke/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return 'aquila/sound/voice/human/femalechoke.ogg'
		else
			return 'aquila/sound/voice/human/choke.ogg'

/datum/emote/living/cough/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pick('aquila/sound/voice/human/femalecough1.ogg', 'aquila/sound/voice/human/femalecough2.ogg', 'aquila/sound/voice/human/cough.ogg')
		else
			return pick('aquila/sound/voice/human/malecough1.ogg', 'aquila/sound/voice/human/cough.ogg')

/datum/emote/living/deathgasp/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pickweight(list('aquila/sound/voice/human/femaledeath1.ogg'=49, 'aquila/sound/voice/human/femaledeath2.ogg'=49, 'aquila/sound/voice/human/maledeath1.ogg'=2))
		else
			return pickweight(list('aquila/sound/voice/human/maledeath3.ogg'=49, 'aquila/sound/voice/human/maledeath5.ogg'=49, 'aquila/sound/voice/human/maledeath2.ogg'=1, 'aquila/sound/voice/human/maledeath4.ogg'=1))
	else
		return

/datum/emote/living/gag/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/gag.ogg'

/datum/emote/living/gasp/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pick('aquila/sound/voice/human/femalegasp1.ogg', 'aquila/sound/voice/human/femalegasp2.ogg')
		else
			return 'aquila/sound/voice/human/gasp.ogg'

/datum/emote/living/gnome
	key = "gnome"
	key_third_person = "gnomes"
	message = "gnomuje"

/datum/emote/living/gnome/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/misc/gnome.ogg'

/datum/emote/living/sigh/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pick('aquila/sound/voice/human/femalesigh1.ogg', 'aquila/sound/voice/human/femalesigh2.ogg', 'aquila/sound/voice/human/femalesigh3.ogg', 'aquila/sound/voice/human/femalesigh4.ogg')
		else
			return 'aquila/sound/voice/human/sigh.ogg'

/datum/emote/living/sneeze/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pick('aquila/sound/voice/human/femalesneeze1.ogg', 'aquila/sound/voice/human/femalesneeze2.ogg')
		else
			return pick('aquila/sound/voice/human/malesneeze1.ogg', 'aquila/sound/voice/human/sneeze.ogg')

/datum/emote/living/burp/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/burp.ogg'

/datum/emote/living/dance/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/misc/dance.ogg'

/datum/emote/living/groan/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/groan.ogg'

/datum/emote/living/kiss/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/kiss.ogg'

/datum/emote/living/sniff/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/sniff.ogg'

/datum/emote/living/snore/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/snore.ogg'

/datum/emote/living/yawn/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/yawn.ogg'

