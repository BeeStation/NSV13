obj/item/banner/munitions
    name = "the people's republic of munitions banner"
    desc = "the banner of the people's republic of munitions, masters of arms and ammunition"
	icon = 'nsv13/icon/obj/banner'
    icon_state = "banner_munitions"
    item_state = "banner_munitions"
    lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
    righthand_file = 'nsv13/icons/mob/inhands/equipment/baners_righthand.dmi'
    job_loyalties = list("Master At Arms", "Munitions Technician", "Flight Leader", "Fighter Pilot", "Air Traffic Controller")
    warcry = "EARS RINGING, GUNS SINGING!"

/obj/item/banner/munitions/mundane
    inspiration_available = FALSE

/obj/item/banner/munitions/special_inspiration(mob/living/carbon/human/H)
    return HAS_TRAIT(H, TRAIT_DEAF)

/datum/crafting_recipe/munitions
    name = "People's Republic of Munitions Banner"
    result = /obj/item/banner/munitions/mundane
    time = 40
    reqs = list(/obj/item/stack/rods = 2
                /obj/item/clothing/under/rank/munitions_tech = 1)
    category = CAT_MISC
