/obj/structure/closet/secure_closet/master_at_arms
	name = "\proper master at arms' locker"
	req_access = list(ACCESS_MAA)
	icon = 'nsv13/icons/obj/custom_closet.dmi'
	icon_state = "maa"
	anchored = TRUE

/obj/structure/closet/secure_closet/master_at_arms/PopulateContents()
	..()
	new /obj/item/card/id/departmental_budget/mun(src)
	new /obj/item/door_remote/master_at_arms(src)
	new /obj/item/radio/headset/headset_sec/alt/master_at_arms(src)
	new /obj/item/clothing/under/trek/engsec(src)
	new /obj/item/clothing/head/bomb_hood(src)
	new /obj/item/clothing/suit/bomb_suit(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/clothing/neck/petcollar(src)
