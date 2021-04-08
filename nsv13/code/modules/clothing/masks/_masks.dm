/obj/item/clothing/mask
	var/breathing_sound = null //Set this if you want to have a gasmask like breathing sound when used.
	var/datum/looping_sound/gasmask/soundloop

/obj/item/clothing/mask/breath
	breathing_sound = TRUE

/obj/item/clothing/mask/Initialize()
	. = ..()
	if(breathing_sound)
		soundloop = new(list(src), FALSE)

/obj/item/clothing/mask/gas
	breathing_sound = TRUE

/obj/item/clothing/mask/gas/tiki_mask
	breathing_sound = null

/obj/item/clothing/mask/gas/sexymime
	breathing_sound = null

/obj/item/clothing/mask/gas/monkeymask
	breathing_sound = null

/obj/item/clothing/mask/gas/mime
	breathing_sound = null

/obj/item/clothing/mask/gas/sexyclown
	breathing_sound = null

/obj/item/clothing/mask/gas/clown_hat
	breathing_sound = null

/obj/item/clothing/mask/gas/sechailer
	breathing_sound = null

/obj/item/clothing/mask/equipped(mob/living/M, slot)
	. = ..()
	if(M.stat == DEAD)
		soundloop?.stop()
		return
	if(slot == ITEM_SLOT_MASK)
		soundloop?.start()
	else
		soundloop?.stop()

/obj/item/clothing/mask/adjustmask(mob/living/user)
	. = ..()
	if(user.stat == DEAD)
		soundloop?.stop()
		return
	if(!mask_adjusted)
		soundloop?.start()
	else
		soundloop?.stop()

/obj/item/clothing/mask/dropped(mob/M)
	. = ..()
	soundloop?.stop()

/datum/looping_sound/gasmask
	mid_sounds = list('nsv13/sound/effects/ship/reactor/gasmask.ogg')
	mid_length = 3 SECONDS
	volume = 30