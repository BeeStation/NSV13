/obj/item/banner/munitions
	name = "People's Republic of Munistotska banner"
	desc = "the banner of the People's Republic of Munistotska, masters of arms and ammunition. Glory to Munistotska!"
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_munitions"
	item_state = "banner_munitions"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list("Master At Arms", "Munitions Technician", "Pilot", "Air Traffic Controller")
	warcry = "EARS RINGING, GUNS SINGING!"

/obj/item/banner/munitions/mundane
    inspiration_available = FALSE

/obj/item/banner/munitions/check_inspiration(mob/living/carbon/human/H)
	return HAS_TRAIT(H, TRAIT_DEAF)

/obj/item/banner/munitions/special_inspiration(mob/living/carbon/human/H)
	H.restoreEars()

/datum/crafting_recipe/munitions
    name = "People's Republic of Munistotska banner"
    result = /obj/item/banner/munitions/mundane
    time = 40
    reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/munitions_tech = 1)
    category = CAT_MISC

/obj/item/banner/solgov
	name = "Government of Sol banner"
	desc = "the banner of the Solar Confederate Government, the most powerful member of the Galactic Federation"
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_solgov"
	item_state = "banner_solgov"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = null
	warcry = "For Heart! For Home! For Luna! For Sol!"

/obj/item/banner/solgov/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/solgov
	name = "Government of Sol banner"
	result = /obj/item/banner/solgov/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/ship/solgov = 1)
	category = CAT_MISC

/obj/item/banner/draconic
	name = "Banner of the Draconian Empire"
	desc = "the banner of the Draconian Empire, main body and governmental force of the lizardfolk homeworld and its moons"
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_draconic"
	item_state = "banner_draconic"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = null
	warcry = "HISSSSSSSS"

/obj/item/banner/draconic/inspiration(mob/living/carbon/human/H)
	playsound(H, 'sound/voice/lizard/lizard_scream_1.ogg', 25, FALSE)

/obj/item/banner/draconic/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/draconic
	name = "Banner of the Draconian Empire"
	result = /obj/item/banner/draconic/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/stack/sheet/durathread = 10,
				/obj/item/reagent_containers/food/snacks/grown/moonflower = 1)
	category = CAT_MISC

/obj/item/banner/dominion
	name = "Dominion of Light banner"
	desc = "the banner of the Dominion of Light, the non-confrontationalist body that comprises a majority of the Ethereal and Mothperson population"
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_dominion"
	item_state = "banner_dominion"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = null
	warcry = "May the light of the torch guide us!"

/obj/item/banner/dominion/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/dominion
	name = "Dominion of Light banner"
	result = /obj/item/banner/dominion/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/candle = 1,
				/obj/item/stack/sheet/durathread = 10)
	category = CAT_MISC

/obj/item/banner/dominion/check_inspiration(mob/living/carbon/human/H)
    return HAS_TRAIT(H, TRAIT_BLIND)

/obj/item/banner/dominion/special_inspiration(mob/living/carbon/human/H)
	H.reagents.add_reagent(/datum/reagent/medicine/oculine, 5)

/obj/item/banner/syndicate
	name = "Syndicate banner"
	desc = "the banner of the Criminal Syndicate, the organized criminals responsible for detonating Luna"
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_syndicate"
	item_state = "banner_syndicate"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list("Traitor", "Nuclear Operative", "Syndicate Drop Trooper")
	warcry = "Death to Nanotrasen! Death to Solgov!"

/datum/uplink_item/badass/banner //Traitor Uplink Item
	name = "Syndicate Banner"
	desc = "A banner signifying your devotion and loyalty to the Syndicate. The Syndicate will prevail!"
	item = /obj/item/banner/syndicate
	cost = 10
