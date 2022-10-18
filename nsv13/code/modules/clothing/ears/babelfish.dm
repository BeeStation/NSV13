/obj/item/clothing/ears/babelfish
	name = "babelfish"
	desc = "A symbiotic fish that can translate any language."
	icon = 'nsv13/icons/obj/clothing/ears.dmi'
	icon_state = "babelfish"
	item_state = "babelfish"
	strip_delay = 45
	equip_delay_other = 5
	resistance_flags = UNACIDABLE

/obj/item/clothing/ears/babelfish/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/hearlanguage)

/datum/element/hearlanguage
	element_flags = ELEMENT_DETACH

/datum/element/hearlanguage/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/equippedChanged)

/datum/element/hearlanguage/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/element/hearlanguage/proc/equippedChanged(datum/source, mob/living/carbon/user, slot)
	var/datum/language_holder/L = user.get_language_holder()
	if(slot == ITEM_SLOT_EARS && istype(user))
		L.grant_all_languages(TRUE, FALSE, FALSE, LANGUAGE_BABEL)
	else
		L.remove_all_languages(LANGUAGE_BABEL)


