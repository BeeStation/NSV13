/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list()
	resistance_flags = ACID_PROOF
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	var/ignore_flags = 0
	var/infinite = FALSE

/obj/item/reagent_containers/hypospray/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/reagent_containers/hypospray/attack(mob/living/M, mob/user)
	inject(M, user)

///Handles all injection checks, injection and logging.
/obj/item/reagent_containers/hypospray/proc/inject(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return FALSE
	if(!iscarbon(M))
		return FALSE

	//Always log attemped injects for admins
	var/list/injected = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		injected += R.name
	var/contained = english_list(injected)
	log_combat(user, M, "attempted to inject", src, "([contained])")

	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1))) // Ignore flag should be checked first or there will be an error message.
		to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")
		to_chat(user, "<span class='notice'>You inject [M] with [src].</span>")
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, INJECT, fraction)

		if(M.reagents)
			var/trans = 0
			if(!infinite)
				trans = reagents.trans_to(M, amount_per_transfer_from_this, transfered_by = user)
			else
				trans = reagents.copy_to(M, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>[trans] unit\s injected.  [reagents.total_volume] unit\s remaining in [src].</span>")
			log_combat(user, M, "injected", src, "([contained])")
		return TRUE
	return FALSE


/obj/item/reagent_containers/hypospray/CMO
	list_reagents = list(/datum/reagent/medicine/omnizine = 30)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 10
	icon_state = "combat_hypo"
	volume = 90
	ignore_flags = 1 // So they can heal their comrades.
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30, /datum/reagent/medicine/omnizine = 30, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/atropine = 15)

/obj/item/reagent_containers/hypospray/combat/nanites
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with experimental medical compounds for rapid healing."
	volume = 100
	list_reagents = list(/datum/reagent/medicine/adminordrazine/quantum_heal = 80, /datum/reagent/medicine/synaptizine = 20)

/obj/item/reagent_containers/hypospray/magillitis
	name = "experimental autoinjector"
	desc = "A modified air-needle autoinjector with a small single-use reservoir. It contains an experimental serum."
	icon_state = "combat_hypo"
	volume = 5
	reagent_flags = NONE
	list_reagents = list(/datum/reagent/magillitis = 5)

//MediPens

/obj/item/reagent_containers/hypospray/medipen
	name = "epinephrine medipen"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge."
	icon_state = "medipen"
	item_state = "medipen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount_per_transfer_from_this = 10
	volume = 10
	ignore_flags = 1 //so you can medipen through hardsuits
	reagent_flags = DRAWABLE
	flags_1 = null
	list_reagents = list(/datum/reagent/medicine/epinephrine = 10)
	custom_price = 40

/obj/item/reagent_containers/hypospray/medipen/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to choke on \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS//ironic. he could save others from oxyloss, but not himself.

/obj/item/reagent_containers/hypospray/medipen/inject(mob/living/M, mob/user)
	. = ..()
	if(.)
		reagents.maximum_volume = 0 //Makes them useless afterwards
		reagents.flags = NONE
		update_icon()

/obj/item/reagent_containers/hypospray/medipen/attack_self(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		inject(user, user)

/obj/item/reagent_containers/hypospray/medipen/update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/reagent_containers/hypospray/medipen/examine()
	. = ..()
	if(reagents && reagents.reagent_list.len)
		. += "<span class='notice'>It is currently loaded.</span>"
	else
		. += "<span class='notice'>It is spent.</span>"

/obj/item/reagent_containers/hypospray/medipen/stimpack //goliath kiting
	name = "stimpack medipen"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/consumable/coffee = 10)

/obj/item/reagent_containers/hypospray/medipen/stimpack/traitor
	desc = "A modified stimulants autoinjector for use in combat situations. Has a mild healing effect."
	list_reagents = list(/datum/reagent/medicine/stimulants = 10, /datum/reagent/medicine/omnizine = 10)

/obj/item/reagent_containers/hypospray/medipen/morphine
	name = "morphine medipen"
	desc = "A rapid way to get you out of a tight situation and fast! You'll feel rather drowsy, though."
	list_reagents = list(/datum/reagent/medicine/morphine = 10)

/obj/item/reagent_containers/hypospray/medipen/oxandrolone
	name = "oxandrolone medipen"
	desc = "A autoinjector containing oxandrolone, used to treat severe burns."
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 10)

/obj/item/reagent_containers/hypospray/medipen/penacid
	name = "pentetic acid medipen"
	desc = "A autoinjector containing pentetic acid, used to reduce high levels of radiations and moderate toxins."
	list_reagents = list(/datum/reagent/medicine/pen_acid = 10)

/obj/item/reagent_containers/hypospray/medipen/salacid
	name = "salicyclic acid medipen"
	desc = "A autoinjector containing salicyclic acid, used to treat severe brute damage."
	list_reagents = list(/datum/reagent/medicine/sal_acid = 10)

/obj/item/reagent_containers/hypospray/medipen/salbutamol
	name = "salbutamol medipen"
	desc = "A autoinjector containing salbutamol, used to heal oxygen damage quickly."
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10)

/obj/item/reagent_containers/hypospray/medipen/tuberculosiscure
	name = "BVAK autoinjector"
	desc = "Bio Virus Antidote Kit autoinjector. Has a two use system for yourself, and someone else. Inject when infected."
	icon_state = "stimpen"
	volume = 60
	amount_per_transfer_from_this = 30
	list_reagents = list(/datum/reagent/medicine/atropine = 10, /datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/omnizine = 20, /datum/reagent/medicine/perfluorodecalin = 15, /datum/reagent/medicine/spaceacillin = 20)

/obj/item/reagent_containers/hypospray/medipen/survival
	name = "survival medipen"
	desc = "A medipen for surviving in the harshest of environments, heals and protects from environmental hazards. WARNING: Do not inject more than one pen in quick succession."
	icon_state = "stimpen"
	volume = 57
	amount_per_transfer_from_this = 57
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/lavaland_extract = 2, /datum/reagent/medicine/omnizine = 5)

/obj/item/reagent_containers/hypospray/combat/heresypurge
	name = "holy water autoinjector"
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with 5 doses of a holy water mixture."
	volume = 250
	list_reagents = list(/datum/reagent/water/holywater = 150, /datum/reagent/peaceborg/tire = 50, /datum/reagent/peaceborg/confuse = 50)
	amount_per_transfer_from_this = 50

/obj/item/reagent_containers/hypospray/medipen/atropine
	name = "atropine autoinjector"
	desc = "A rapid way to save a person from a critical injury state!"
	list_reagents = list(/datum/reagent/medicine/atropine = 10)

/obj/item/reagent_containers/hypospray/medipen/snail
	name = "snail shot"
	desc = "All-purpose snail medicine! Do not use on non-snails!"
	list_reagents = list(/datum/reagent/snail = 10)
	icon_state = "snail"
